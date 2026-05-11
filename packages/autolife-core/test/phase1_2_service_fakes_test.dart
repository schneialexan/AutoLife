import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

/// `null` stands in for [`void`] inside [Success] (`Result<void>`).
Result<void> _voidOk() => const Success<Null>(null) as Result<void>;

class _FakeEventProducer implements EventProducer {
  SystemEvent? last;

  @override
  Future<Result<SystemEvent>> publish(SystemEvent event) async {
    last = event;
    return Result.success(event);
  }
}

class _FakeEventConsumerRegistry implements EventConsumerRegistry {
  final Map<String, SystemEventHandler> _handlers = {};

  @override
  Future<Result<void>> dispatchTo(String consumerId, SystemEvent event) async {
    final handler = _handlers[consumerId];
    if (handler == null) {
      return Result.failure(Failure(code: 'unknown_consumer'));
    }
    await handler(event);
    return _voidOk();
  }

  @override
  void register(String consumerId, SystemEventHandler handler) {
    _handlers[consumerId] = handler;
  }
}

class _Entity {
  const _Entity(this.id, this.name);

  final String id;
  final String name;
}

class _FakeRepository implements Repository<_Entity, String> {
  final Map<String, _Entity> store = {};

  @override
  Future<Result<_Entity>> getById(String id) async {
    final entity = store[id];
    return entity != null
        ? Result.success(entity)
        : Result.failure(Failure(code: 'missing'));
  }

  @override
  Future<Result<List<_Entity>>> list({int? limit, int? offset}) async =>
      Result.success(store.values.toList());

  @override
  Future<Result<void>> upsert(_Entity entity) async {
    store[entity.id] = entity;
    return _voidOk();
  }

  @override
  Future<Result<void>> delete(String id) async {
    store.remove(id);
    return _voidOk();
  }
}

class _FakeIntegrationConnector implements IntegrationConnector {
  var connected = false;

  _FakeIntegrationConnector();

  @override
  String get connectorId => 'fake';

  @override
  IntegrationConnectorDirection get directions =>
      IntegrationConnectorDirection.twoWay;

  @override
  Future<Result<void>> connect({Tenant? tenant}) async {
    connected = true;
    return _voidOk();
  }

  @override
  Future<Result<void>> disconnect() async {
    connected = false;
    return _voidOk();
  }

  @override
  Future<Result<void>> healthcheck({Tenant? tenant}) async => _voidOk();

  @override
  Future<Result<Map<String, dynamic>>> pullChanges({Tenant? tenant}) async =>
      Result.success({});

  @override
  Future<Result<void>> pushChanges({
    Tenant? tenant,
    required Map<String, dynamic> payload,
  }) async =>
      _voidOk();

  @override
  Future<Result<void>> refresh({Tenant? tenant}) async => _voidOk();
}

class _FakeOfflineQueue implements OfflineWriteQueue {
  final List<Map<String, dynamic>> backing = [];

  @override
  Future<Result<int>> depth() async => Result.success(backing.length);

  @override
  Future<Result<Map<String, dynamic>?>> dequeue() async {
    if (backing.isEmpty) {
      return const Result.success(null);
    }
    return Result.success(backing.removeAt(0));
  }

  @override
  Future<Result<void>> enqueue(Map<String, dynamic> payload) async {
    backing.add(payload);
    return _voidOk();
  }
}

void main() {
  final sampleEvent = SystemEvent(
    tenantId: 't',
    actorId: 'a',
    module: 'm',
    type: 't',
    payload: const {},
    idempotencyKey: 'ik',
    occurredAt: DateTime.utc(2026),
    orderingTag: 'o',
    schemaVersion: 1,
  );

  test('EventProducer fake persists last publish', () async {
    final fake = _FakeEventProducer();
    final out = await fake.publish(sampleEvent);
    expect(identical(fake.last, sampleEvent), isTrue);
    expect(fake.last, sampleEvent);
    expect(out.maybeWhen(success: (e) => e, orElse: () => null), sampleEvent);
  });

  test('EventConsumerRegistry fake dispatches handlers', () async {
    final reg = _FakeEventConsumerRegistry();
    var touched = false;
    reg.register('c1', (e) async {
      touched = true;
      expect(e.tenantId, 't');
    });
    await reg.dispatchTo('c1', sampleEvent);
    expect(touched, isTrue);

    final miss = await reg.dispatchTo('nope', sampleEvent);
    expect(
      miss.maybeWhen(failure: (f) => f.code, orElse: () => ''),
      'unknown_consumer',
    );
  });

  test('Repository fake round-trips entity', () async {
    final r = _FakeRepository();
    const e = _Entity('1', 'a');
    await r.upsert(e);
    final got = await r.getById('1');
    expect(got.maybeWhen(success: (v) => v, orElse: () => null), e);
    final listed = await r.list();
    expect(listed.maybeWhen(success: (l) => l.length, orElse: () => 0), 1);
    await r.delete('1');
    expect(await r.getById('1'), isA<Result<_Entity>>());
  });

  test('IntegrationConnector fake tracks connection', () async {
    final c = _FakeIntegrationConnector();
    await c.connect(tenant: const Tenant(tenantId: 'z'));
    expect(c.connected, isTrue);
    await c.disconnect();
    expect(c.connected, isFalse);
  });

  test('OfflineWriteQueue fake depth / dequeue ordering', () async {
    final q = _FakeOfflineQueue();
    await q.enqueue({'x': 1});
    await q.enqueue({'y': 2});
    expect(await q.depth(), isA<Result<int>>());
    final d = await q.dequeue().then(
      (r) => r.maybeWhen(success: (x) => x, orElse: () => null),
    );
    expect(d, {'x': 1});
    final d2 = await q.dequeue().then(
      (r) => r.maybeWhen(success: (x) => x, orElse: () => null),
    );
    expect(d2, {'y': 2});
    expect(
      await q.dequeue().then(
        (r) => r.maybeWhen(success: (x) => x, orElse: () => 'ERR'),
      ),
      isNull,
    );
  });
}

import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingEventProducer implements EventProducer {
  final List<SystemEvent> events = [];

  @override
  Future<Result<SystemEvent>> publish(SystemEvent event) async {
    events.add(event);
    return Result.success(event);
  }
}

class _RecordingOfflineQueue implements OfflineWriteQueue {
  final List<Map<String, dynamic>> backing = [];

  @override
  Future<Result<int>> depth() async => Result.success(backing.length);

  @override
  Future<Result<Map<String, dynamic>?>> dequeue() async {
    if (backing.isEmpty) return const Result.success(null);
    return Result.success(backing.removeAt(0));
  }

  @override
  Future<Result<void>> enqueue(Map<String, dynamic> payload) async {
    backing.add(payload);
    return const Result.success(null);
  }
}

void main() {
  test('ConnectorRegistry rejects duplicate connector ids', () {
    final registry = ConnectorRegistry();
    registry.register(MockConnector());
    expect(() => registry.register(MockConnector()), throwsStateError);
  });

  test(
    'Coordinator logs connector_event rows for each lifecycle call',
    () async {
      final audit = InMemoryConnectorAuditLogger();
      final producer = RecordingEventProducer();
      final registry = ConnectorRegistry();
      registry.register(MockConnector());
      final tracker = ConnectorStatusTracker();
      final coordinator = ConnectorLifecycleCoordinator(
        registry: registry,
        statusTracker: tracker,
        audit: audit,
        eventProducer: producer,
        actorId: 'tester',
        defaultTenantId: 'tenant-x',
      );

      final tenant = const Tenant(tenantId: 'tenant-x');
      await coordinator.connect('mock', tenant: tenant);
      await coordinator.refresh('mock', tenant: tenant);
      await coordinator.healthcheck('mock', tenant: tenant);
      await coordinator.pullChanges('mock', tenant: tenant);
      await coordinator.pushChanges(
        'mock',
        tenant: tenant,
        payload: const {'sample': true},
      );
      await coordinator.disconnect('mock', tenant: tenant);

      final kinds = audit.records.map((r) => r.kind).toList();
      expect(kinds, [
        'connect',
        'refresh',
        'healthcheck',
        'pull_changes',
        'push_changes',
        'disconnect',
      ]);

      expect(
        producer.events.where((e) => e.type == 'connector_connected').length,
        1,
      );
      expect(
        producer.events.where((e) => e.type == 'connector_disconnected').length,
        1,
      );
      expect(
        producer.events.where((e) => e.type == 'connector_error').length,
        0,
      );
    },
  );

  test(
    'OfflineAwareIntegrationConnector queues pushChanges when offline',
    () async {
      final inner = MockConnector();
      await inner.connect();
      final queue = _RecordingOfflineQueue();
      final offlineConnector = OfflineAwareIntegrationConnector(
        inner: inner,
        offlineQueue: queue,
        probeOnline: () async => false,
        defaultTenantId: 'tenant-off',
        defaultActorId: 'actor-off',
      );

      final out = await offlineConnector.pushChanges(
        tenant: const Tenant(tenantId: 'tenant-off'),
        payload: const {'change': 1},
      );

      expect(out.maybeWhen(success: (_) => true, orElse: () => false), isTrue);
      expect(queue.backing.length, 1);
      expect(
        queue.backing.first['target_table'],
        OfflineAwareIntegrationConnector.connectorPushTargetTable,
      );
    },
  );
}

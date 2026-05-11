import 'dart:convert';
import 'dart:typed_data';

import 'package:autolife_core/autolife_core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:test/test.dart';

class _RecordingGateway implements RemoteSyncGateway {
  final calls = <String>[];

  @override
  Future<List<Map<String, dynamic>>> pullTable({
    required String tenantId,
    String? tenancyFamilyScopeId,
    String? tenancyProfileScopeId,
    required String table,
    DateTime? updatedAfter,
    int limit = 200,
  }) async => [];

  @override
  Future<void> applyWrite({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    calls.add('$table|$operation|${jsonEncode(payload)}');
  }
}

class _PullingGateway implements RemoteSyncGateway {
  _PullingGateway({required this.remoteSystemEvent});

  final Map<String, dynamic> remoteSystemEvent;

  @override
  Future<List<Map<String, dynamic>>> pullTable({
    required String tenantId,
    String? tenancyFamilyScopeId,
    String? tenancyProfileScopeId,
    required String table,
    DateTime? updatedAfter,
    int limit = 200,
  }) async {
    if (table != 'system_event') return [];
    return [remoteSystemEvent];
  }

  @override
  Future<void> applyWrite({
    required String table,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {}
}

class _FakeProducer implements EventProducer {
  SystemEvent? last;

  @override
  Future<Result<SystemEvent>> publish(SystemEvent event) async {
    last = event;
    return Result.success(event);
  }
}

SyncEngine _engine({
  required AutolifeDatabase db,
  required RemoteSyncGateway gw,
  PayloadCipher? cipher,
  EventProducer? conflictEvents,
}) {
  final c = cipher ?? PayloadCipher(SecretKey(Uint8List(32)));
  return SyncEngine(
    db: db,
    gateway: gw,
    connectivity: ConnectivityWatcher.fake(
      stream: const Stream<bool>.empty(),
      initialOnline: false,
    ),
    cipher: c,
    conflictResolver: LastWriterWinsResolver(),
    tenantId: 'tenant-a',
    conflictEvents: conflictEvents,
  );
}

void main() {
  test('merging emits conflict_detected when timestamps diverge', () async {
    final db = AutolifeDatabase.memory();
    await db
        .into(db.systemEventCache)
        .insert(
          SystemEventCacheCompanion.insert(
            id: 'evt-1',
            tenantId: 'tenant-a',
            actorId: 'actor',
            module: 'm',
            type: 't',
            payloadJson: '{}',
            idempotencyKey: 'ik',
            occurredAt: DateTime.utc(2026, 1, 1),
            orderingTag: 'o',
            schemaVersion: 1,
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        );
    final remote = {
      'id': 'evt-1',
      'tenant_id': 'tenant-a',
      'actor_id': 'actor',
      'module': 'm',
      'type': 't',
      'payload': <String, dynamic>{},
      'idempotency_key': 'ik',
      'occurred_at': '2026-01-01T00:00:00.000Z',
      'ordering_tag': 'o',
      'schema_version': 1,
      'updated_at': '2026-06-01T00:00:00.000Z',
    };
    final producer = _FakeProducer();
    final engine = _engine(
      db: db,
      gw: _PullingGateway(remoteSystemEvent: remote),
      conflictEvents: producer,
    );
    await engine.runCycle();
    expect(producer.last?.type, 'conflict_detected');
    engine.dispose();
  });

  test('runCycle drains queue in table-name order', () async {
    final db = AutolifeDatabase.memory();
    final cipher = PayloadCipher(SecretKey(Uint8List(32)));
    final q = DriftOfflineWriteQueue(db, cipher);
    await q.enqueue(
      OfflineWritePayloadBuilder.build(
        tenantId: 'tenant-a',
        actorId: 'actor',
        targetTable: 'zzz',
        operation: 'insert',
        idempotencyKey: 'k1',
        payload: {'id': '1'},
      ),
    );
    await q.enqueue(
      OfflineWritePayloadBuilder.build(
        tenantId: 'tenant-a',
        actorId: 'actor',
        targetTable: 'aaa',
        operation: 'insert',
        idempotencyKey: 'k2',
        payload: {'id': '2'},
      ),
    );
    final rec = _RecordingGateway();
    final engine = _engine(db: db, gw: rec, cipher: cipher);
    await engine.runCycle();
    expect(rec.calls.length, 2);
    expect(rec.calls[0].startsWith('aaa|'), isTrue);
    expect(rec.calls[1].startsWith('zzz|'), isTrue);
    engine.dispose();
  });
}

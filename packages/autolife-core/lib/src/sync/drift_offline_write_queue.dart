import 'package:drift/drift.dart';

import '../common/failure.dart';
import '../common/result.dart';
import '../services/offline_write_queue.dart';
import 'autolife_database.dart';
import 'payload_cipher.dart';

/// Standard [OfflineWriteQueue.enqueue] keys (values are JSON-serializable).
abstract final class OfflineWritePayloadKeys {
  static const tenantId = 'tenant_id';
  static const actorId = 'actor_id';
  static const targetTable = 'target_table';
  static const operation = 'operation';
  static const idempotencyKey = 'idempotency_key';
  static const payload = 'payload';
}

/// Drift-backed `pending_write` queue with encrypted payloads.
class DriftOfflineWriteQueue implements OfflineWriteQueue {
  DriftOfflineWriteQueue(this._db, this._cipher);

  final AutolifeDatabase _db;
  final PayloadCipher _cipher;

  String? _requireString(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is! String || v.isEmpty) return null;
    return v;
  }

  @override
  Future<Result<void>> enqueue(Map<String, dynamic> envelope) async {
    final tenantId = _requireString(envelope, OfflineWritePayloadKeys.tenantId);
    final actorId = _requireString(envelope, OfflineWritePayloadKeys.actorId);
    final targetTable = _requireString(
      envelope,
      OfflineWritePayloadKeys.targetTable,
    );
    final op = _requireString(envelope, OfflineWritePayloadKeys.operation);
    final idem = _requireString(
      envelope,
      OfflineWritePayloadKeys.idempotencyKey,
    );
    final body = envelope[OfflineWritePayloadKeys.payload];
    if (tenantId == null ||
        actorId == null ||
        targetTable == null ||
        op == null ||
        idem == null) {
      return Result.failure(
        Failure(
          code: 'offline_write_missing_field',
          message: envelope.toString(),
        ),
      );
    }
    if (op != 'insert' && op != 'update' && op != 'delete') {
      return Result.failure(
        Failure(code: 'offline_write_bad_operation', message: op),
      );
    }
    if (body is! Map) {
      return Result.failure(
        Failure(
          code: 'offline_write_bad_payload',
          message: '${body.runtimeType}',
        ),
      );
    }
    final prior =
        await (_db.select(_db.pendingWrites)..where(
              (t) =>
                  t.tenantId.equals(tenantId) & t.idempotencyKey.equals(idem),
            ))
            .getSingleOrNull();
    if (prior != null) {
      return const Result.success(null);
    }
    final enc = await _cipher.encryptJson(Map<String, dynamic>.from(body));
    await _db
        .into(_db.pendingWrites)
        .insert(
          PendingWritesCompanion.insert(
            tenantId: tenantId,
            actorId: actorId,
            targetTable: targetTable,
            operation: op,
            payload: enc,
            idempotencyKey: idem,
            status: 'pending',
            createdAt: DateTime.now().toUtc(),
          ),
        );
    return const Result.success(null);
  }

  @override
  Future<Result<Map<String, dynamic>?>> dequeue() async {
    final row =
        await (_db.select(_db.pendingWrites)
              ..where((t) => t.status.equals('pending'))
              ..orderBy([
                (t) => OrderingTerm(expression: t.targetTable),
                (t) => OrderingTerm(expression: t.createdAt),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) {
      return const Result.success(null);
    }
    final clear = await _cipher.decryptJson(Uint8List.fromList(row.payload));
    return Result.success({
      '_meta': {
        'queue_row_id': row.id,
        OfflineWritePayloadKeys.tenantId: row.tenantId,
        OfflineWritePayloadKeys.actorId: row.actorId,
        OfflineWritePayloadKeys.targetTable: row.targetTable,
        OfflineWritePayloadKeys.operation: row.operation,
        OfflineWritePayloadKeys.idempotencyKey: row.idempotencyKey,
      },
      OfflineWritePayloadKeys.payload: clear,
    });
  }

  @override
  Future<Result<int>> depth() async {
    final rows = await (_db.select(
      _db.pendingWrites,
    )..where((t) => t.status.equals('pending'))).get();
    return Result.success(rows.length);
  }
}

/// Convenience helpers used by enqueue paths.
abstract final class OfflineWritePayloadBuilder {
  static Map<String, dynamic> build({
    required String tenantId,
    required String actorId,
    required String targetTable,
    required String operation,
    required String idempotencyKey,
    required Map<String, dynamic> payload,
  }) => {
    OfflineWritePayloadKeys.tenantId: tenantId,
    OfflineWritePayloadKeys.actorId: actorId,
    OfflineWritePayloadKeys.targetTable: targetTable,
    OfflineWritePayloadKeys.operation: operation,
    OfflineWritePayloadKeys.idempotencyKey: idempotencyKey,
    OfflineWritePayloadKeys.payload: payload,
  };
}

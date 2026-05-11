import 'package:drift/drift.dart';

/// Durable mutation queue (`pending_write` — see [docs/offline-sync-contract.md]).
@TableIndex(
  name: 'pending_write_tenant_idempotency',
  columns: {#tenantId, #idempotencyKey},
  unique: true,
)
class PendingWrites extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tenantId => text()();
  TextColumn get actorId => text()();
  TextColumn get targetTable => text()();
  TextColumn get operation => text()();
  BlobColumn get payload => blob()();
  TextColumn get idempotencyKey => text()();
  IntColumn get attempt => integer().withDefault(const Constant(0))();
  TextColumn get status => text()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
}

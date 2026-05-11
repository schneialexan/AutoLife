import 'package:drift/drift.dart';

/// Local cache of `public.system_event` (see `0001_init_system_events.sql` + `0011`).
class SystemEventCache extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get actorId => text()();
  TextColumn get module => text()();
  TextColumn get type => text()();
  TextColumn get payloadJson => text()();
  TextColumn get idempotencyKey => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get orderingTag => text()();
  IntColumn get schemaVersion => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

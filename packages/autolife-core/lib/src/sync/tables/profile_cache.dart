import 'package:drift/drift.dart';

/// Local cache of `public.profile`.
class ProfileCache extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get activeFamilyId => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

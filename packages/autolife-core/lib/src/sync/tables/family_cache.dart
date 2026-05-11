import 'package:drift/drift.dart';

/// Local cache of `public.family`.
class FamilyCache extends Table {
  TextColumn get id => text()();
  TextColumn get displayName => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

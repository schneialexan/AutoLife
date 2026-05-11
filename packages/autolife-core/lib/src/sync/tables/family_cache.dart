import 'package:drift/drift.dart';

/// Local cache of `public.families`.
class FamilyCache extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

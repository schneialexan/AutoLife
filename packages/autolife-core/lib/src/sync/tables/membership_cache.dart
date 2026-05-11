import 'package:drift/drift.dart';

/// Local cache of `public.memberships`.
class MembershipCache extends Table {
  TextColumn get familyId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text()();
  DateTimeColumn get joinedAt => dateTime().nullable()();
  DateTimeColumn get removedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {familyId, userId};
}

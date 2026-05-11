import 'package:drift/drift.dart';

import 'membership_role_map.dart';

/// Local cache of `public.membership`.
class MembershipCache extends Table {
  TextColumn get id => text()();
  TextColumn get familyId => text()();
  TextColumn get profileId => text()();
  TextColumn get role => text().map(const MembershipRoleConverter())();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';

import '../../models/role.dart';

class MembershipRoleConverter extends TypeConverter<Role, String> {
  const MembershipRoleConverter();

  @override
  Role fromSql(String fromDb) {
    return Role.values.firstWhere((e) => e.name == fromDb, orElse: () => Role.member);
  }

  @override
  String toSql(Role value) => value.name;
}

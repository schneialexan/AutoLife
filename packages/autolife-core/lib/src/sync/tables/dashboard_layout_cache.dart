import 'package:drift/drift.dart';

/// Local cache row for dashboard layout JSON (phase 3.1.5).
@TableIndex(
  name: 'dashboard_layout_family_member',
  columns: {#familyId, #memberScope},
  unique: true,
)
class DashboardLayoutCache extends Table {
  TextColumn get familyId => text()();
  TextColumn get memberScope => text()();
  TextColumn get payloadJson => text()();
  IntColumn get layoutVersion =>
      integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {familyId, memberScope};
}

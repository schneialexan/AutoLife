import 'dart:convert';

import 'package:drift/drift.dart';

import '../sync/autolife_database.dart';
import 'dashboard_defaults.dart';
import 'dashboard_form_factor.dart';
import 'dashboard_layout.dart';

/// Drift-backed dashboard layout read/write + lazy personal seed (phase 3.1.5).
class DashboardLayoutRepository {
  DashboardLayoutRepository(this._db);

  final AutolifeDatabase _db;

  /// Sentinel [memberScope] for the family-default row (`member_id IS NULL` remote).
  static const String familyDefaultMemberScope = '__family_default__';

  /// Read-through: personal → family default → [kDefaultDashboardLayouts] + seed personal.
  Future<DashboardLayout> getCurrent({
    required String familyId,
    required String memberId,
    required DashboardFormFactor formFactor,
  }) async {
    final personal = await (_db.select(_db.dashboardLayoutCache)
          ..where(
            (t) =>
                t.familyId.equals(familyId) & t.memberScope.equals(memberId),
          ))
        .getSingleOrNull();

    if (personal != null) {
      return DashboardLayout.fromJson(
        jsonDecode(personal.payloadJson) as Map<String, dynamic>,
      );
    }

    DashboardLayout seed;
    final fam = await (_db.select(_db.dashboardLayoutCache)
          ..where(
            (t) =>
                t.familyId.equals(familyId) &
                t.memberScope.equals(familyDefaultMemberScope),
          ))
        .getSingleOrNull();
    if (fam != null) {
      seed = DashboardLayout.fromJson(
        jsonDecode(fam.payloadJson) as Map<String, dynamic>,
      );
    } else {
      seed = kDefaultDashboardLayouts[formFactor]!;
    }

    final v2 = seed.migrateToV2();
    await _db.into(_db.dashboardLayoutCache).insert(
          DashboardLayoutCacheCompanion.insert(
            familyId: familyId,
            memberScope: memberId,
            payloadJson: jsonEncode(v2.toJson()),
            updatedAt: DateTime.now(),
          ),
        );
    return v2;
  }

  Future<void> upsertLayout({
    required String familyId,
    required String memberScope,
    required DashboardLayout layout,
  }) async {
    final v2 = layout.migrateToV2();
    await _db.into(_db.dashboardLayoutCache).insertOnConflictUpdate(
          DashboardLayoutCacheCompanion.insert(
            familyId: familyId,
            memberScope: memberScope,
            payloadJson: jsonEncode(v2.toJson()),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<DashboardLayout?> readFamilyDefault(String familyId) async {
    final row = await (_db.select(_db.dashboardLayoutCache)
          ..where(
            (t) =>
                t.familyId.equals(familyId) &
                t.memberScope.equals(familyDefaultMemberScope),
          ))
        .getSingleOrNull();
    if (row == null) return null;
    return DashboardLayout.fromJson(
      jsonDecode(row.payloadJson) as Map<String, dynamic>,
    );
  }
}

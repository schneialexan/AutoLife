import 'package:autolife_core/autolife_core.dart';

import '../../providers/time_of_day_provider.dart';

/// Reorders high-priority rows for evening emphasis (phase 3.1 / 3.1.5).
DashboardLayout adaptDashboardLayout(
  DashboardLayout base,
  DashboardDayPhase phase,
) {
  if (phase != DashboardDayPhase.evening && phase != DashboardDayPhase.night) {
    return base;
  }
  final v2 = base.migrateToV2();
  final rows = DashboardLayout.cloneRows(v2.base);
  var rowUp = -1;
  var rowQa = -1;
  for (var i = 0; i < rows.length; i++) {
    if (rows[i].tiles.any((t) => t.widgetId == 'upcoming_strip')) {
      rowUp = i;
    }
    if (rows[i].tiles.any((t) => t.widgetId == 'quick_actions')) {
      rowQa = i;
    }
  }
  if (rowUp != -1 && rowQa != -1 && rowUp > rowQa) {
    final moved = rows.removeAt(rowUp);
    rows.insert(rowQa, moved);
  }
  return DashboardLayout(
    schemaVersion: 2,
    base: rows,
    rowOverrides: v2.rowOverrides,
  );
}

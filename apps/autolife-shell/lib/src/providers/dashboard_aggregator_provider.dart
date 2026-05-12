import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shell_providers.dart';

/// Aggregates dashboard headline counts from the offline Drift cache (phase 3.1).
///
/// Calendar/tasks/assets modules will tighten module/type filters in later phases.
final dashboardSummaryProvider = StreamProvider<DashboardSummary>((ref) {
  final db = ref.watch(autolifeDatabaseProvider);
  final tenant = ref.watch(shellTenantIdProvider);
  final connectors = ref.watch(connectorListProvider);

  return db.select(db.systemEventCache).watch().map((rows) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    var calendarLike = 0;
    var tasksLike = 0;
    var assetsLike = 0;

    for (final row in rows) {
      if (row.tenantId != tenant) continue;
      final at = row.occurredAt.toLocal();
      if (at.isBefore(start) || !at.isBefore(end)) continue;

      switch (row.module) {
        case 'calendar':
          calendarLike++;
          break;
        case 'tasks':
          tasksLike++;
          break;
        case 'assets':
          assetsLike++;
          break;
        case 'smoke':
          calendarLike++;
          break;
        default:
          break;
      }
    }

    final weatherSummary =
        connectors.contains('mock') ? 'Mock weather · connector OK' : null;

    return DashboardSummary(
      eventCount: calendarLike,
      taskCount: tasksLike,
      assetSignalCount: assetsLike,
      weatherSummary: weatherSummary,
      connectorHealthy: connectors.isNotEmpty,
    );
  });
});

final dashboardQueryProvider = Provider<DashboardQuery>((ref) {
  final ws = ref.watch(shellWorkspaceProvider);
  final tenant = ref.watch(shellTenantIdProvider);
  final day = DateTime.now();
  return DashboardQuery(
    tenantId: tenant,
    familyId: ws.activeFamilyId,
    dayLocal: DateTime(day.year, day.month, day.day),
  );
});

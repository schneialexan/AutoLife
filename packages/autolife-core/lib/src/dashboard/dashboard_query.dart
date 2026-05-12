/// Input contract for dashboard aggregation (phase 3.1).
///
/// Repository implementations (later phases 3.2–3.4) satisfy this query against
/// Drift + Supabase; the shell consumes only [DashboardSummary].
class DashboardQuery {
  const DashboardQuery({
    required this.tenantId,
    required this.familyId,
    required this.dayLocal,
  });

  final String tenantId;
  final String familyId;

  /// Calendar day for “today” summaries (family-local midnight semantics TBD).
  final DateTime dayLocal;
}

/// Aggregated Home headline metrics for the Today card / omnibar hints.
class DashboardSummary {
  const DashboardSummary({
    required this.eventCount,
    required this.taskCount,
    required this.assetSignalCount,
    this.weatherSummary,
    this.connectorHealthy = true,
  });

  final int eventCount;
  final int taskCount;

  /// Warranty / asset reminders due soon — stub until AutoAssets lands.
  final int assetSignalCount;

  /// Short weather line when integration gateway returns data (phase 1.7).
  final String? weatherSummary;

  /// Mock connector health bit surfaced on dashboard debug rows.
  final bool connectorHealthy;

  static const empty = DashboardSummary(
    eventCount: 0,
    taskCount: 0,
    assetSignalCount: 0,
  );
}

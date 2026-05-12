import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable clock for tests / QA overrides (phase 3.1).
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Morning / evening presets keyed off local wall-clock unless overridden.
enum DashboardDayPhase {
  morning,
  midday,
  evening,
  night,
}

DashboardDayPhase resolveDashboardDayPhase(DateTime local) {
  final h = local.hour;
  if (h >= 6 && h < 12) return DashboardDayPhase.morning;
  if (h >= 12 && h < 18) return DashboardDayPhase.midday;
  if (h >= 18) return DashboardDayPhase.evening;
  return DashboardDayPhase.night;
}

DashboardAdaptiveMode dashboardAdaptiveForPhase(DashboardDayPhase phase) {
  switch (phase) {
    case DashboardDayPhase.morning:
      return DashboardAdaptiveMode.morning;
    case DashboardDayPhase.evening:
    case DashboardDayPhase.night:
      return DashboardAdaptiveMode.evening;
    case DashboardDayPhase.midday:
      return DashboardAdaptiveMode.anyTime;
  }
}

final dashboardDayPhaseProvider = Provider<DashboardDayPhase>((ref) {
  final clock = ref.watch(clockProvider);
  return resolveDashboardDayPhase(clock());
});

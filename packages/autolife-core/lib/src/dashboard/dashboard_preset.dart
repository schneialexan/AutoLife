import 'dashboard_defaults.dart';
import 'dashboard_form_factor.dart';
import 'dashboard_layout.dart';

/// Built-in dashboard presets (phase 3.1.5).
enum BuiltinDashboardPreset {
  defaultPreset,
  morning,
  evening,
  weekend,
}

/// Returns a fresh v2 layout for [preset]. Uses per-[formFactor] defaults for [defaultPreset].
DashboardLayout layoutForBuiltinPreset({
  required BuiltinDashboardPreset preset,
  required DashboardFormFactor formFactor,
}) {
  switch (preset) {
    case BuiltinDashboardPreset.defaultPreset:
      return DashboardLayout.fromJson(
        kDefaultDashboardLayouts[formFactor]!.toJson(),
      );
    case BuiltinDashboardPreset.morning:
    case BuiltinDashboardPreset.evening:
    case BuiltinDashboardPreset.weekend:
      return DashboardLayout.fromJson(
        kDefaultDashboardLayouts[formFactor]!.toJson(),
      );
  }
}

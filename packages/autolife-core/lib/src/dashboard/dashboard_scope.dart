import 'dashboard_adaptive_mode.dart';
import 'dashboard_form_factor.dart';

/// A `(formFactor, adaptive)` pair used as an override map key.
class DashboardScope {
  const DashboardScope({
    required this.formFactor,
    required this.adaptive,
  });

  final DashboardFormFactor formFactor;
  final DashboardAdaptiveMode adaptive;

  /// Stable codec: `"mobile:morning"`, `"web:anyTime"`, …
  String get cacheKey => '${formFactor.name}:${adaptive.name}';

  @override
  bool operator ==(Object other) {
    return other is DashboardScope &&
        other.formFactor == formFactor &&
        other.adaptive == adaptive;
  }

  @override
  int get hashCode => Object.hash(formFactor, adaptive);
}

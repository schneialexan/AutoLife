import 'package:autolife_core/autolife_core.dart';

import '../screens/home/home_dashboard_specs.dart';

/// Hook modules call from `main` / bootstrap ([registerHomeDashboardSpecs] today).
void registerShellDashboardWidgets(DashboardWidgetRegistry registry) {
  registerHomeDashboardSpecs(registry);
}

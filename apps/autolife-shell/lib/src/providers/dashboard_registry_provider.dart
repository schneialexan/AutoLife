import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../registration/dashboard_registration.dart';

final dashboardWidgetRegistryProvider = Provider<DashboardWidgetRegistry>((ref) {
  final registry = DashboardWidgetRegistry();
  registerShellDashboardWidgets(registry);
  return registry;
});

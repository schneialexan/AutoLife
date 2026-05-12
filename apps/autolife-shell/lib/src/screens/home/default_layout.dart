import 'package:autolife_core/autolife_core.dart';

/// Re-export built-in layouts from core (phase 3.1.5).
DashboardLayout get kDefaultDashboardLayout =>
    kDefaultDashboardLayouts[DashboardFormFactor.mobile]!.migrateToV2();

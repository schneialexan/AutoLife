import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True while Home dashboard edit mode is active.
final dashboardEditActiveProvider = StateProvider<bool>((ref) => false);

/// Working copy of the layout JSON while editing (full document).
final dashboardEditWorkingProvider = StateProvider<DashboardLayout?>((ref) => null);

/// Preview scope for device / adaptive simulation during edit mode.
final dashboardEditPreviewScopeProvider =
    StateProvider<DashboardScope?>((ref) => null);

/// When true, mutations write [DashboardLayout.base]; when false, current override key.
final dashboardEditAllScopesProvider = StateProvider<bool>((ref) => true);

/// Whether the owner is editing the `(family_id, NULL)` family-default row.
final dashboardEditFamilyDefaultProvider = StateProvider<bool>((ref) => false);

/// Whether the auto-fit host fell back to vertical scroll (edit-mode banner).
final dashboardAutoFitScrollFallbackProvider = StateProvider<bool>((ref) => false);

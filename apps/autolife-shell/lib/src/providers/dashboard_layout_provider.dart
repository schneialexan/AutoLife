import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shell_providers.dart';

/// Optional: bound when [autolifeDatabaseProvider] is available.
final dashboardLayoutRepositoryProvider =
    Provider<DashboardLayoutRepository?>((ref) {
  try {
    final db = ref.watch(autolifeDatabaseProvider);
    return DashboardLayoutRepository(db);
  } on StateError {
    return null;
  }
});

/// Cached personal layout for Home (lazy-seeded when repo is available).
///
/// Depends on [shellWorkspaceProvider] so tenancy can override workspace in a
/// nested [ProviderScope] without Riverpod's override graph assertion
/// ("dependencies were overridden but the provider is not").
final homeDashboardLayoutProvider =
    FutureProvider.family<DashboardLayout, DashboardFormFactor>(
  (ref, ff) async {
    final familyId = ref.watch(shellWorkspaceProvider).activeFamilyId.isEmpty
        ? shellDemoFamilyScopeUuid
        : ref.watch(shellWorkspaceProvider).activeFamilyId;
    const memberId = shellDemoProfileUuid;

    final repo = ref.watch(dashboardLayoutRepositoryProvider);
    if (repo == null) {
      return kDefaultDashboardLayouts[ff]!.migrateToV2();
    }
    return repo.getCurrent(
      familyId: familyId,
      memberId: memberId,
      formFactor: ff,
    );
  },
  dependencies: [shellWorkspaceProvider],
);

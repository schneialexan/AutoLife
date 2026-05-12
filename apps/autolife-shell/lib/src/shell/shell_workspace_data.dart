import 'package:flutter/foundation.dart';

import 'package:autolife_core/autolife_core.dart';

/// Tenancy payload mirrored into Riverpod via [shellWorkspaceProvider] (phase 3.1).
class ShellWorkspaceData {
  const ShellWorkspaceData({
    required this.enrollments,
    required this.activeFamilyId,
    required this.reloadTenancy,
    this.tenancyResolved = true,
  });

  factory ShellWorkspaceData.demo() => ShellWorkspaceData(
        enrollments: const [],
        activeFamilyId: '',
        reloadTenancy: () {},
        tenancyResolved: false,
      );

  final List<TenancyEnrollment> enrollments;
  final String activeFamilyId;
  final VoidCallback reloadTenancy;

  /// False for local demo bootstrap — tenant id stays `local-dev`.
  final bool tenancyResolved;
}

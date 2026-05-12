import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shell/shell_workspace_data.dart';
import 'edit_mode_providers.dart';

/// Owner-only toggle between personal layout and family default (phase 3.1.5).
class DashboardScopeSelector extends ConsumerWidget {
  const DashboardScopeSelector({super.key, required this.isOwner});

  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOwner) return const SizedBox.shrink();
    final famDefault = ref.watch(dashboardEditFamilyDefaultProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: false, label: Text('My layout')),
          ButtonSegment(value: true, label: Text('Family default')),
        ],
        selected: {famDefault},
        onSelectionChanged: (s) {
          ref.read(dashboardEditFamilyDefaultProvider.notifier).state =
              s.first;
        },
      ),
    );
  }
}

/// Whether the active enrollment is [FamilyRole.owner] for [activeFamilyId].
bool isActiveFamilyOwner(ShellWorkspaceData ws) {
  if (ws.activeFamilyId.isEmpty) return false;
  for (final TenancyEnrollment e in ws.enrollments) {
    if (e.family.id == ws.activeFamilyId &&
        e.membership.role == FamilyRole.owner) {
      return true;
    }
  }
  return false;
}

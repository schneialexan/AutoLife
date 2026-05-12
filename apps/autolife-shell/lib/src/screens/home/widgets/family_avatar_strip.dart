import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/family_selection_provider.dart';
import '../../../providers/shell_providers.dart';

/// Family-scoped member chips (phase 3.1 stub uses enrollment projections).
class FamilyAvatarStrip extends ConsumerWidget {
  const FamilyAvatarStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ws = ref.watch(shellWorkspaceProvider);
    final selected = ref.watch(selectedHouseholdMemberIdProvider);
    final tokens = context.autoLifeTokens;

    final members = ws.enrollments
        .where((e) => e.family.id == ws.activeFamilyId)
        .where(
          (e) =>
              e.membership.role != FamilyRole.babysitter &&
              e.membership.role != FamilyRole.guest,
        )
        .toList();

    return AutoLifeSurfaceCard(
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Family',
              key: const Key('family_strip_heading'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: tokens.spaceSm),
            if (members.isEmpty)
              Text(
                'No household members loaded yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: tokens.spaceSm,
                runSpacing: tokens.spaceSm,
                children: [
                  ChoiceChip(
                    key: const Key('family_chip_all'),
                    label: const Text('Everyone'),
                    selected: selected == null,
                    onSelected: (_) => ref
                        .read(selectedHouseholdMemberIdProvider.notifier)
                        .setSelection(null),
                  ),
                  for (final m in members)
                    ChoiceChip(
                      key: Key('family_chip_${m.membership.userId}'),
                      avatar: AutoLifeMemberAvatar(
                        memberId: m.membership.userId,
                        displayName: m.family.name,
                        radius: 14,
                      ),
                      label: Text(_shortId(m.membership.userId)),
                      selected: selected == m.membership.userId,
                      onSelected: (_) => ref
                          .read(selectedHouseholdMemberIdProvider.notifier)
                          .setSelection(m.membership.userId),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static String _shortId(String userId) =>
      userId.length <= 8 ? userId : userId.substring(0, 8);
}

final DashboardWidgetSpec familyAvatarStripDashboardSpec = DashboardWidgetSpec(
  widgetId: 'family_avatar_strip',
  moduleId: 'shell',
  title: 'Family',
  supportedSizes: const [
    DashboardSize.s,
    DashboardSize.m,
    DashboardSize.l,
    DashboardSize.xl,
  ],
  build: (context, slot) => const FamilyAvatarStrip(),
);

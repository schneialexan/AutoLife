import 'package:flutter/material.dart';

import 'package:autolife_ui/src/theme/member_palette.dart';
import 'package:autolife_ui/src/tokens/radii.dart';
import 'package:autolife_ui/src/tokens/spacing.dart';

/// Compact pill badge using member accent colors.
class AutoLifeMemberBadge extends StatelessWidget {
  /// Label rendered on a tinted capsule.
  const AutoLifeMemberBadge({
    super.key,
    required this.memberId,
    required this.label,
  });

  final String memberId;
  final String label;

  @override
  Widget build(BuildContext context) {
    final accent = MemberPalette.colorFor(memberId);
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AutoLifeSpacing.sm,
        vertical: AutoLifeSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AutoLifeRadii.pill),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

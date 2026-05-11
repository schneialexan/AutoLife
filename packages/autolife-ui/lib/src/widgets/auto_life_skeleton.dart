import 'package:flutter/material.dart';

import 'package:autolife_ui/src/tokens/radii.dart';
import 'package:autolife_ui/src/tokens/spacing.dart';

/// Low-fidelity loading placeholders for lists and cards.
class AutoLifeSkeleton extends StatelessWidget {
  /// Single rounded bar; stack multiple for list placeholders.
  const AutoLifeSkeleton({
    super.key,
    this.width,
    this.height = AutoLifeSpacing.md,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = borderRadius ?? AutoLifeRadii.sm;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

/// Vertical stack of skeleton rows for card-like layouts.
class AutoLifeSkeletonBlock extends StatelessWidget {
  /// Multiple lines with optional trailing short row.
  const AutoLifeSkeletonBlock({
    super.key,
    this.lines = 3,
    this.spacing = AutoLifeSpacing.sm,
  });

  final int lines;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines; i++) ...[
          AutoLifeSkeleton(
            width: i == lines - 1 ? 120 : double.infinity,
            height: AutoLifeSpacing.md,
          ),
          if (i != lines - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

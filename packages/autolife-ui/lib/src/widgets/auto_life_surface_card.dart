import 'package:flutter/material.dart';

import 'package:autolife_ui/src/theme/autolife_theme.dart';
import 'package:autolife_ui/src/tokens/spacing.dart';

/// Elevated surface container using tokenized radius and shadow.
class AutoLifeSurfaceCard extends StatelessWidget {
  /// Card with optional tap handler wrapping [child].
  const AutoLifeSurfaceCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.autoLifeTokens;
    final radius = BorderRadius.circular(tokens.radiusMd);

    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AutoLifeSpacing.md),
      child: child,
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: radius,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: tokens.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: onTap == null
              ? content
              : InkWell(onTap: onTap, child: content),
        ),
      ),
    );

    return decorated;
  }
}

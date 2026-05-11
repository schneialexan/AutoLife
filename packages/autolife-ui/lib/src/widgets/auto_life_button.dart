import 'package:flutter/material.dart';

import 'package:autolife_ui/src/tokens/radii.dart';
import 'package:autolife_ui/src/tokens/spacing.dart';

/// Filled button variants mapped to semantic colors.
enum AutoLifeButtonVariant { primary, secondary, destructive }

/// Shared filled button styles mapped from design tokens.
class AutoLifeButton extends StatelessWidget {
  /// Creates a styled button with optional leading icon.
  const AutoLifeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AutoLifeButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AutoLifeButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = switch (variant) {
      AutoLifeButtonVariant.primary => (scheme.primary, scheme.onPrimary),
      AutoLifeButtonVariant.secondary => (
        scheme.surfaceContainerHighest,
        scheme.onSurface,
      ),
      AutoLifeButtonVariant.destructive => (scheme.error, scheme.onError),
    };

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: AutoLifeSpacing.xs),
        ],
        Text(
          label,
          style: TextStyle(color: fg, fontWeight: FontWeight.w600),
        ),
      ],
    );

    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: scheme.surfaceContainerHighest,
        disabledForegroundColor: scheme.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(
          horizontal: AutoLifeSpacing.lg,
          vertical: AutoLifeSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.md),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

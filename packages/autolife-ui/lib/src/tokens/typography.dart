import 'package:flutter/material.dart';

/// Text styles derived from Material 3 type roles, tuned for AutoLife density.
///
/// Pair with [ThemeData.textTheme] from [AutoLifeTheme]; these factories expect
/// a [ColorScheme] for `onSurface` / `onSurfaceVariant` coloring.
abstract final class AutoLifeTypography {
  AutoLifeTypography._();

  /// Material 3-aligned text roles tinted with [ColorScheme] foreground colors.
  static TextTheme textTheme(ColorScheme scheme) {
    final base = Typography.material2021(
      platform: TargetPlatform.android,
    ).black;
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: scheme.onSurface),
      bodyMedium: base.bodyMedium?.copyWith(color: scheme.onSurface),
      bodySmall: base.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      labelMedium: base.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
      labelSmall: base.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
    );
  }
}

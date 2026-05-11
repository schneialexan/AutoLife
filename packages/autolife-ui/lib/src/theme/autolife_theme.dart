import 'package:flutter/material.dart';

import 'package:autolife_ui/src/tokens/colors.dart';
import 'package:autolife_ui/src/tokens/radii.dart';
import 'package:autolife_ui/src/tokens/shadows.dart';
import 'package:autolife_ui/src/tokens/spacing.dart';
import 'package:autolife_ui/src/tokens/typography.dart';

/// Theme-accessible design tokens; attach via [ThemeData.extensions].
@immutable
class AutoLifeTokens extends ThemeExtension<AutoLifeTokens> {
  /// Creates tokens bound to the current brightness for shadows.
  const AutoLifeTokens({required this.brightness});

  /// Brightness used to pick elevation shadows.
  final Brightness brightness;

  List<BoxShadow> get cardShadow => brightness == Brightness.dark
      ? AutoLifeShadows.cardDark
      : AutoLifeShadows.cardLight;

  /// Resolved spacing constants (same values as [AutoLifeSpacing]; exposed for extension API consistency).
  double get spaceXxs => AutoLifeSpacing.xxs;

  double get spaceXs => AutoLifeSpacing.xs;

  double get spaceSm => AutoLifeSpacing.sm;

  double get spaceMd => AutoLifeSpacing.md;

  double get spaceLg => AutoLifeSpacing.lg;

  double get spaceXl => AutoLifeSpacing.xl;

  double get spaceXxl => AutoLifeSpacing.xxl;

  double get radiusXs => AutoLifeRadii.xs;

  double get radiusSm => AutoLifeRadii.sm;

  double get radiusMd => AutoLifeRadii.md;

  double get radiusLg => AutoLifeRadii.lg;

  double get radiusField => AutoLifeRadii.field;

  double get radiusPill => AutoLifeRadii.pill;

  @override
  AutoLifeTokens copyWith({Brightness? brightness}) {
    return AutoLifeTokens(brightness: brightness ?? this.brightness);
  }

  @override
  AutoLifeTokens lerp(ThemeExtension<AutoLifeTokens>? other, double t) {
    if (other is! AutoLifeTokens) return this;
    return t < 0.5 ? this : other;
  }
}

/// Resolve [AutoLifeTokens] from [ThemeData.extensions].
extension AutoLifeTokensX on BuildContext {
  AutoLifeTokens get autoLifeTokens =>
      Theme.of(this).extension<AutoLifeTokens>() ??
      AutoLifeTokens(brightness: Theme.of(this).brightness);
}

/// Light and dark [ThemeData] factories for AutoLife apps.
abstract final class AutoLifeTheme {
  AutoLifeTheme._();

  static ColorScheme _lightScheme() {
    return ColorScheme.light(
      primary: AutoLifeColors.brandPrimary,
      onPrimary: AutoLifeColors.brandOnPrimary,
      primaryContainer: AutoLifeColors.brandPrimaryContainer,
      onPrimaryContainer: AutoLifeColors.brandOnPrimaryContainer,
      secondary: AutoLifeColors.brandPrimary,
      onSecondary: AutoLifeColors.brandOnPrimary,
      surface: AutoLifeColors.lightSurface,
      onSurface: AutoLifeColors.lightOnSurface,
      surfaceContainerHighest: AutoLifeColors.lightSurfaceContainerHigh,
      surfaceContainerHigh: AutoLifeColors.lightSurfaceContainer,
      surfaceContainer: AutoLifeColors.lightSurfaceContainer,
      outline: AutoLifeColors.lightOutline,
      outlineVariant: AutoLifeColors.lightOutlineVariant,
      error: AutoLifeColors.error,
      onError: AutoLifeColors.onError,
    );
  }

  static ColorScheme _darkScheme() {
    return ColorScheme.dark(
      primary: AutoLifeColors.brandPrimary,
      onPrimary: AutoLifeColors.brandOnPrimary,
      primaryContainer: AutoLifeColors.brandOnPrimaryContainer,
      onPrimaryContainer: AutoLifeColors.brandPrimaryContainer,
      secondary: AutoLifeColors.brandPrimary,
      onSecondary: AutoLifeColors.brandOnPrimary,
      surface: AutoLifeColors.darkSurface,
      onSurface: AutoLifeColors.darkOnSurface,
      surfaceContainerHighest: AutoLifeColors.darkSurfaceContainerHigh,
      surfaceContainerHigh: AutoLifeColors.darkSurfaceContainer,
      surfaceContainer: AutoLifeColors.darkSurfaceContainer,
      outline: AutoLifeColors.darkOutline,
      outlineVariant: AutoLifeColors.darkOutlineVariant,
      error: AutoLifeColors.error,
      onError: AutoLifeColors.onError,
    );
  }

  /// Material 3 light theme with [AutoLifeTokens] attached.
  static ThemeData light() {
    final scheme = _lightScheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: AutoLifeTypography.textTheme(scheme),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.card),
        ),
        color: scheme.surfaceContainerLowest,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.field),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.field),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.field),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AutoLifeSpacing.md,
          vertical: AutoLifeSpacing.sm,
        ),
      ),
      extensions: const [AutoLifeTokens(brightness: Brightness.light)],
    );
  }

  /// Material 3 dark theme with [AutoLifeTokens] attached.
  static ThemeData dark() {
    final scheme = _darkScheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: AutoLifeTypography.textTheme(scheme),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.card),
        ),
        color: scheme.surfaceContainerLowest,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.field),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.field),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AutoLifeRadii.field),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AutoLifeSpacing.md,
          vertical: AutoLifeSpacing.sm,
        ),
      ),
      extensions: const [AutoLifeTokens(brightness: Brightness.dark)],
    );
  }
}

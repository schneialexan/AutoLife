import 'package:flutter/material.dart';

import 'autolife_colors.dart';

abstract final class AutoLifeTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AutoLifeColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AutoLifeColors.surface,
    );
  }
}

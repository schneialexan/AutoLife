import 'package:flutter/material.dart';

/// Elevation shadows applied to elevated surfaces (theme chooses light vs dark list).
abstract final class AutoLifeShadows {
  AutoLifeShadows._();

  static List<BoxShadow> cardLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

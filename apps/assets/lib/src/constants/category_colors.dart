import 'package:flutter/material.dart';

/// Preset accent palette for category types. Stored as hex strings so the
/// choice survives serialization. All 12 are visibly distinct and chosen to
/// keep ≥3:1 contrast against card surfaces in light and dark themes — no
/// near-neutral grays.
class CategoryColors {
  const CategoryColors._();

  static const String defaultColor = blue;

  static const String blue = '#2563EB';
  static const String indigo = '#4F46E5';
  static const String cyan = '#0891B2';
  static const String teal = '#0D9488';
  static const String green = '#16A34A';
  static const String lime = '#65A30D';
  static const String amber = '#D97706';
  static const String orange = '#EA580C';
  static const String red = '#DC2626';
  static const String pink = '#DB2777';
  static const String purple = '#9333EA';
  static const String brown = '#92400E';

  /// Ordered palette shown as swatches in the create/edit type dialog.
  static const List<String> palette = <String>[
    blue,
    indigo,
    cyan,
    teal,
    green,
    lime,
    amber,
    orange,
    red,
    pink,
    purple,
    brown,
  ];

  /// Parses a `#RRGGBB` hex string into a [Color]. Falls back to the default
  /// accent if the value is malformed.
  static Color parse(String hex) {
    var value = hex.replaceFirst('#', '').trim();
    if (value.length == 6) {
      value = 'FF$value';
    }
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) {
      return parse(defaultColor);
    }
    return Color(parsed);
  }
}

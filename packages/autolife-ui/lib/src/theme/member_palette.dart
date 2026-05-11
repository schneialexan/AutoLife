import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

/// Deterministic accent colors for family members from stable string ids.
abstract final class MemberPalette {
  MemberPalette._();

  static const List<Color> _swatches = [
    Color(0xFF0D9488),
    Color(0xFF6366F1),
    Color(0xFFDB2777),
    Color(0xFFD97706),
    Color(0xFF16A34A),
    Color(0xFF7C3AED),
    Color(0xFFDC2626),
    Color(0xFF0891B2),
    Color(0xFFCA8A04),
    Color(0xFF4F46E5),
    Color(0xFFC026D3),
    Color(0xFFEA580C),
  ];

  /// Returns a stable color for [memberId] across platforms and runs.
  static Color colorFor(String memberId) {
    final digest = sha256.convert(utf8.encode(memberId));
    var acc = 0;
    for (final byte in digest.bytes) {
      acc = (acc * 31 + byte) % 997;
    }
    return _swatches[acc % _swatches.length];
  }
}

import 'package:flutter/material.dart';

import 'package:autolife_ui/src/theme/member_palette.dart';

/// Circular avatar tinted by [MemberPalette] from [memberId].
class AutoLifeMemberAvatar extends StatelessWidget {
  /// Shows initials derived from [displayName] when non-empty.
  const AutoLifeMemberAvatar({
    super.key,
    required this.memberId,
    required this.displayName,
    this.radius = 20,
  });

  final String memberId;
  final String displayName;
  final double radius;

  String _initials() {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.single;
      return s.isEmpty ? '?' : s.substring(0, 1).toUpperCase();
    }
    final a = parts.first.isNotEmpty ? parts.first[0] : '';
    final b = parts.last.isNotEmpty ? parts.last[0] : '';
    return ('$a$b').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final accent = MemberPalette.colorFor(memberId);
    final onAccent =
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return CircleAvatar(
      radius: radius,
      backgroundColor: accent.withValues(alpha: 0.25),
      foregroundColor: onAccent,
      child: Text(
        _initials(),
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: radius * 0.85),
      ),
    );
  }
}

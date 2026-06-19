import 'package:flutter/material.dart';

import '../constants/category_colors.dart';
import '../constants/category_icons.dart';
import '../models/category_type.dart';

/// Renders a catalog icon or emoji at [size], tinted with [color] (icons only;
/// emojis keep their native glyph color).
class CategoryIconView extends StatelessWidget {
  const CategoryIconView({
    super.key,
    required this.iconKey,
    required this.color,
    this.size = 18,
  });

  final String iconKey;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final spec = CategoryIcons.specFor(iconKey);
    if (spec.isEmoji) {
      return Text(spec.emoji!, style: TextStyle(fontSize: size));
    }
    return Icon(spec.iconData, size: size, color: color);
  }
}

/// Neutral rounded tile carrying a category type's icon drawn in its accent
/// color — the single element that conveys both icon + color (with the name
/// always shown alongside for colorblind safety).
class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.type, this.size = 36});

  final CategoryType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = CategoryColors.parse(type.accentColor);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(size * 0.24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      alignment: Alignment.center,
      child: CategoryIconView(
        iconKey: type.displayIcon,
        color: accent,
        size: (size - 14).clamp(14, 28).toDouble(),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../constants/category_colors.dart';
import '../constants/category_icons.dart';
import 'category_icon.dart';

/// Grid of catalog icons + emojis, grouped under "Icons" and "Emoji" headers.
///
/// When [query] is non-empty, only specs whose label matches (case-insensitive)
/// are shown, and groups with no matches are hidden entirely.
class IconGridPicker extends StatelessWidget {
  const IconGridPicker({
    super.key,
    required this.selected,
    required this.accentColor,
    required this.onSelected,
    this.query = '',
  });

  final String selected;
  final String accentColor;
  final ValueChanged<String> onSelected;
  final String query;

  List<CategoryIconSpec> _filter(List<CategoryIconSpec> specs) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return specs;
    }
    return specs
        .where((spec) => spec.label.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final icons = _filter(CategoryIcons.materialIcons);
    final emojis = _filter(CategoryIcons.emojis);

    if (icons.isEmpty && emojis.isEmpty) {
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No icons match',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icons.isNotEmpty) ...[
          _GroupLabel('Icons'),
          _grid(context, icons),
        ],
        if (icons.isNotEmpty && emojis.isNotEmpty)
          const SizedBox(height: 12),
        if (emojis.isNotEmpty) ...[
          _GroupLabel('Emoji'),
          _grid(context, emojis),
        ],
      ],
    );
  }

  Widget _grid(BuildContext context, List<CategoryIconSpec> specs) {
    final theme = Theme.of(context);
    final accent = CategoryColors.parse(accentColor);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final spec in specs)
          Semantics(
            label: spec.label,
            selected: spec.key == selected,
            button: true,
            child: InkWell(
              onTap: () => onSelected(spec.key),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: spec.key == selected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: spec.key == selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                    width: spec.key == selected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: CategoryIconView(
                  iconKey: spec.key,
                  color: accent,
                  size: 22,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

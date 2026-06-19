import 'package:flutter/material.dart';

import '../constants/category_colors.dart';

/// Grid of circular color swatches from the preset palette.
class ColorSwatchPicker extends StatelessWidget {
  const ColorSwatchPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final hex in CategoryColors.palette)
          Semantics(
            label: 'Color $hex',
            selected: hex == selected,
            button: true,
            child: InkWell(
              onTap: () => onSelected(hex),
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hex == selected
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.outlineVariant,
                        width: hex == selected ? 3 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: CategoryColors.parse(hex),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

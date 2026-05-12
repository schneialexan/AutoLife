import 'package:flutter/material.dart';

Future<void> showTileWidthPopover(
  BuildContext context,
  int currentFlex,
  void Function(int w) onPick,
) async {
  final chosen = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: Text('Tile width ($currentFlex / 6)'),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var w = 1; w <= 6; w++)
                    FilterChip(
                      label: Text('$w'),
                      selected: w == currentFlex,
                      onSelected: (_) => Navigator.of(ctx).pop(w),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
  );
  if (chosen != null) onPick(chosen);
}

Future<void> showRowHeightPopover(
  BuildContext context,
  int currentUnits,
  void Function(int h) onPick,
) async {
  final chosen = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: Text('Row height ($currentUnits / 6)'),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var h = 1; h <= 6; h++)
                    FilterChip(
                      label: Text('$h'),
                      selected: h == currentUnits,
                      onSelected: (_) => Navigator.of(ctx).pop(h),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
  );
  if (chosen != null) onPick(chosen);
}

import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';

Future<DashboardOverflowMode?> showPresentationPicker(
  BuildContext context,
  DashboardOverflowMode current,
) {
  return showModalBottomSheet<DashboardOverflowMode>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Display mode'),
              subtitle: Text('How your dashboard uses the screen'),
            ),
            RadioGroup<DashboardOverflowMode>(
              groupValue: current,
              onChanged: (v) {
                Navigator.of(ctx).pop(v);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: DashboardOverflowMode.values
                    .map(
                      (m) => RadioListTile<DashboardOverflowMode>(
                        value: m,
                        title: Text(_label(m)),
                        subtitle: Text(_hint(m)),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

String _label(DashboardOverflowMode m) {
  switch (m) {
    case DashboardOverflowMode.autoFit:
      return 'Auto-fit (default)';
    case DashboardOverflowMode.scrollVertical:
      return 'Scroll vertically';
    case DashboardOverflowMode.scrollSnap:
      return 'Vertical pages (snap)';
    case DashboardOverflowMode.boards:
      return 'Horizontal boards';
  }
}

String _hint(DashboardOverflowMode m) {
  switch (m) {
    case DashboardOverflowMode.autoFit:
      return 'Fill the screen; scrolls only if tiles need more space.';
    case DashboardOverflowMode.scrollVertical:
      return 'Always a scrollable column of bands.';
    case DashboardOverflowMode.scrollSnap:
      return 'Swipe up/down between pages of tiles.';
    case DashboardOverflowMode.boards:
      return 'Swipe left/right between boards of tiles.';
  }
}

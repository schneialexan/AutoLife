import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';

Future<BuiltinDashboardPreset?> showPresetPicker(BuildContext context) {
  return showDialog<BuiltinDashboardPreset>(
    context: context,
    builder: (ctx) {
      return SimpleDialog(
        title: const Text('Dashboard preset'),
        children: [
          for (final p in BuiltinDashboardPreset.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, p),
              child: Text(_presetLabel(p)),
            ),
        ],
      );
    },
  );
}

String _presetLabel(BuiltinDashboardPreset p) {
  switch (p) {
    case BuiltinDashboardPreset.defaultPreset:
      return 'Default';
    case BuiltinDashboardPreset.morning:
      return 'Morning';
    case BuiltinDashboardPreset.evening:
      return 'Evening';
    case BuiltinDashboardPreset.weekend:
      return 'Weekend';
  }
}

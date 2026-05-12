import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/dashboard_registry_provider.dart';
import 'edit_mode_providers.dart';

Future<String?> showWidgetPickerSheet(BuildContext context, WidgetRef ref) {
  final registry = ref.read(dashboardWidgetRegistryProvider);
  final working = ref.read(dashboardEditWorkingProvider);
  if (working == null) {
    return Future.value();
  }
  final usedIds = working
      .migrateToV2()
      .base
      .expand((r) => r.tiles)
      .map((t) => t.widgetId)
      .toSet();
  final available = registry.all
      .where((s) => !usedIds.contains(s.widgetId))
      .toList()
    ..sort((a, b) {
      final c = a.moduleId.compareTo(b.moduleId);
      if (c != 0) return c;
      return a.title.compareTo(b.title);
    });

  return showModalBottomSheet<String>(
    context: context,
    builder: (ctx) {
      if (available.isEmpty) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No additional widgets registered yet.'),
          ),
        );
      }
      return SafeArea(
        child: ListView(
          children: [
            const ListTile(title: Text('Add widget')),
            for (final s in available)
              ListTile(
                title: Text(s.title),
                subtitle: Text(s.moduleId),
                onTap: () => Navigator.pop(ctx, s.widgetId),
              ),
          ],
        ),
      );
    },
  );
}

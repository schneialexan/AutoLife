import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'edit_mode_providers.dart';

Future<void> showManageOverridesSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final w = ref.read(dashboardEditWorkingProvider)?.migrateToV2();
  if (w == null) return;
  final keys = w.rowOverrides.keys.toList()..sort();
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Layout overrides',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            if (keys.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No per-scope overrides yet.'),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: keys.length,
                  itemBuilder: (c, i) {
                    final k = keys[i];
                    return ListTile(
                      title: Text(k),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          final cur = ref.read(dashboardEditWorkingProvider)!;
                          final v2 = cur.migrateToV2();
                          final next = Map<String, List<DashboardRow>>.from(
                            v2.rowOverrides,
                          )..remove(k);
                          ref.read(dashboardEditWorkingProvider.notifier).state =
                              DashboardLayout(
                            schemaVersion: 2,
                            base: v2.base,
                            rowOverrides: next,
                          );
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    },
  );
}

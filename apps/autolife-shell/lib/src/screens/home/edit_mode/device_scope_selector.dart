import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'edit_mode_providers.dart';

/// Form factor + adaptive + all/this-scope toggle (phase 3.1.5).
class DeviceScopeSelector extends ConsumerWidget {
  const DeviceScopeSelector({super.key, required this.runtimeScope});

  final DashboardScope runtimeScope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(dashboardEditPreviewScopeProvider) ?? runtimeScope;
    final allScopes = ref.watch(dashboardEditAllScopesProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preview', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final ff in DashboardFormFactor.values)
                  ChoiceChip(
                    label: Text(ff.name),
                    selected: preview.formFactor == ff,
                    onSelected: (_) {
                      ref.read(dashboardEditPreviewScopeProvider.notifier).state =
                          DashboardScope(
                        formFactor: ff,
                        adaptive: preview.adaptive,
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                for (final ad in DashboardAdaptiveMode.values)
                  ChoiceChip(
                    label: Text(ad.name),
                    selected: preview.adaptive == ad,
                    onSelected: (_) {
                      ref.read(dashboardEditPreviewScopeProvider.notifier).state =
                          DashboardScope(
                        formFactor: preview.formFactor,
                        adaptive: ad,
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                FilterChip(
                  label: const Text('All scopes'),
                  selected: allScopes,
                  onSelected: (_) {
                    ref.read(dashboardEditAllScopesProvider.notifier).state =
                        true;
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('This scope only'),
                  selected: !allScopes,
                  onSelected: (_) {
                    ref.read(dashboardEditAllScopesProvider.notifier).state =
                        false;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

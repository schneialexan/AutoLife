import 'dart:convert';

import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shell_providers.dart';

/// Minimal dashboard strip backed exclusively by Drift ([todaySmokeEventsProvider]).
class TodayWidget extends ConsumerWidget {
  const TodayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(todaySmokeEventsProvider);
    final tokens = context.autoLifeTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Today',
          key: const Key('smoke_today_heading'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: tokens.spaceSm),
        async.when(
          data: (rows) {
            if (rows.isEmpty) {
              return AutoLifeEmptyState(
                title: 'No smoke events yet',
                message: 'Add an event above after syncing.',
              );
            }
            return ListView.separated(
              key: const Key('smoke_today_list'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              separatorBuilder: (_, _) => SizedBox(height: tokens.spaceXs),
              itemBuilder: (context, i) {
                final row = rows[i];
                final payload =
                    jsonDecode(row.payloadJson) as Map<String, dynamic>;
                final title = payload['title'] as String? ?? row.type;
                return Text(
                  title,
                  key: Key('smoke_today_row_${row.id}'),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
              },
            );
          },
          loading: () => const AutoLifeSkeleton(height: 48),
          error: (e, _) => Text(
            'Error: $e',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ),
      ],
    );
  }
}

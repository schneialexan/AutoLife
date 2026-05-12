import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/dashboard_aggregator_provider.dart';

/// Today headline counts + weather stub (phase 3.1).
class TodaySummaryCard extends ConsumerWidget {
  const TodaySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.autoLifeTokens;
    final summary = ref.watch(dashboardSummaryProvider);
    return AutoLifeSurfaceCard(
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        child: summary.when(
          data: (s) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today',
                key: const Key('today_summary_heading'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: tokens.spaceSm),
              Text(
                '${s.eventCount} events · ${s.taskCount} tasks',
                key: const Key('today_summary_counts'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              if (s.weatherSummary != null) ...[
                SizedBox(height: tokens.spaceXs),
                Text(
                  s.weatherSummary!,
                  key: const Key('today_summary_weather'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
          loading: () => const AutoLifeSkeleton(height: 72),
          error: (e, _) => Text(
            'Summary error: $e',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ),
      ),
    );
  }
}

final DashboardWidgetSpec todaySummaryDashboardSpec = DashboardWidgetSpec(
  widgetId: 'today_summary',
  moduleId: 'shell',
  title: 'Today summary',
  supportedSizes: DashboardSize.values,
  build: (context, slot) => const TodaySummaryCard(),
);

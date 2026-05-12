import 'dart:convert';

import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/shell_providers.dart';

/// Recent `process-event` inputs surfaced from Drift cache (phase 3.1).
class ActivityFeedWidget extends ConsumerWidget {
  const ActivityFeedWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(autolifeDatabaseProvider);
    final tenant = ref.watch(shellTenantIdProvider);
    final tokens = context.autoLifeTokens;

    final query = db.select(db.systemEventCache)
      ..where((t) => t.tenantId.equals(tenant))
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.occurredAt, mode: OrderingMode.desc),
      ])
      ..limit(25);

    return StreamBuilder<List<SystemEventCacheData>>(
      stream: query.watch(),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const [];

        return AutoLifeSurfaceCard(
          child: Padding(
            padding: EdgeInsets.all(tokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity',
                  key: const Key('activity_feed_heading'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spaceSm),
                Expanded(
                  child: rows.isEmpty
                      ? const AutoLifeEmptyState(
                          title: 'No activity yet',
                          message:
                              'Publish events via quick actions or modules.',
                        )
                      : ListView.builder(
                          itemCount: rows.length,
                          itemBuilder: (ctx, i) =>
                              _ActivityTile(row: rows[i]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.row});

  final SystemEventCacheData row;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> payload;
    try {
      payload =
          jsonDecode(row.payloadJson) as Map<String, dynamic>? ?? const {};
    } catch (_) {
      payload = const {};
    }
    final title =
        payload['title'] as String? ?? '${row.module}.${row.type}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AutoLifeSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            key: Key('activity_tile_$title'),
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${row.module} · ${row.type} · ${_fmt(row.occurredAt.toLocal())}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.month}/${d.day} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

final DashboardWidgetSpec activityFeedDashboardSpec = DashboardWidgetSpec(
  widgetId: 'activity_feed',
  moduleId: 'shell',
  title: 'Activity feed',
  supportedSizes: const [
    DashboardSize.s,
    DashboardSize.m,
    DashboardSize.l,
    DashboardSize.xl,
  ],
  build: (context, slot) => const ActivityFeedWidget(),
);

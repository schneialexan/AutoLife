import 'dart:convert';

import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_ui/autolife_ui.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/family_selection_provider.dart';
import '../../../providers/shell_providers.dart';

/// Upcoming items merged from cached bus projections (phase 3.1).
class UpcomingStrip extends ConsumerWidget {
  const UpcomingStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(autolifeDatabaseProvider);
    final tenant = ref.watch(shellTenantIdProvider);
    final filterId = ref.watch(selectedHouseholdMemberIdProvider);
    final tokens = context.autoLifeTokens;

    final query = db.select(db.systemEventCache)
      ..where((t) => t.tenantId.equals(tenant))
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.occurredAt, mode: OrderingMode.asc),
      ])
      ..limit(80);

    return StreamBuilder<List<SystemEventCacheData>>(
      stream: query.watch(),
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const [];
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);

        Iterable<SystemEventCacheData> visible = rows.where((r) {
          final at = r.occurredAt.toLocal();
          return !at.isBefore(start);
        });

        if (filterId != null && filterId.isNotEmpty) {
          visible = visible.where(
            (r) => r.actorId == filterId || r.payloadJson.contains(filterId),
          );
        }

        final list = visible.take(12).toList();

        return AutoLifeSurfaceCard(
          child: Padding(
            padding: EdgeInsets.all(tokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming',
                  key: const Key('upcoming_strip_heading'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: tokens.spaceSm),
                Expanded(
                  child: list.isEmpty
                      ? const AutoLifeEmptyState(
                          title: 'Nothing scheduled',
                          message:
                              'Create an event or task — shell aggregates cached rows.',
                        )
                      : ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (ctx, i) => _UpcomingRow(row: list[i]),
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

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.row});

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
    final tone = MemberPalette.colorFor(row.actorId);

    return Padding(
      padding: const EdgeInsets.only(bottom: AutoLifeSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 36,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: AutoLifeSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${row.module} · ${_fmt(row.occurredAt.toLocal())}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

final DashboardWidgetSpec upcomingStripDashboardSpec = DashboardWidgetSpec(
  widgetId: 'upcoming_strip',
  moduleId: 'shell',
  title: 'Upcoming',
  supportedSizes: const [
    DashboardSize.s,
    DashboardSize.m,
    DashboardSize.l,
    DashboardSize.xl,
  ],
  build: (context, slot) => const UpcomingStrip(),
);

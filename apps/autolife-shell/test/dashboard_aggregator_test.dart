import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/src/providers/dashboard_aggregator_provider.dart';
import 'package:autolife_shell/src/providers/shell_providers.dart';
import 'package:autolife_shell/src/providers/time_of_day_provider.dart';
import 'package:autolife_shell/src/screens/home/adaptive_layout_resolver.dart';
import 'package:autolife_shell/src/shell/shell_workspace_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dashboardSummaryProvider counts today cached rows by module', () async {
    final db = AutolifeDatabase.memory();
    final now = DateTime.now();
    final tenant = 'local-dev';

    await db.into(db.systemEventCache).insert(
          SystemEventCacheCompanion.insert(
            id: 'ce1',
            tenantId: tenant,
            actorId: 'actor-a',
            module: 'calendar',
            type: 'event.created',
            payloadJson: '{"title":"Meet"}',
            idempotencyKey: 'ik-cal',
            occurredAt: now,
            orderingTag: 'cal:t',
            schemaVersion: 1,
            updatedAt: now,
          ),
        );

    await db.into(db.systemEventCache).insert(
          SystemEventCacheCompanion.insert(
            id: 'tk1',
            tenantId: tenant,
            actorId: 'actor-b',
            module: 'tasks',
            type: 'task.created',
            payloadJson: '{"title":"Todo"}',
            idempotencyKey: 'ik-task',
            occurredAt: now,
            orderingTag: 'task:t',
            schemaVersion: 1,
            updatedAt: now,
          ),
        );

    final container = ProviderContainer(
      overrides: [
        autolifeDatabaseProvider.overrideWithValue(db),
        shellTenantIdProvider.overrideWithValue(tenant),
        connectorListProvider.overrideWith((ref) => ['mock']),
        shellWorkspaceProvider.overrideWithValue(ShellWorkspaceData.demo()),
      ],
    );

    addTearDown(container.dispose);

    AsyncValue<DashboardSummary>? last;
    container.listen<AsyncValue<DashboardSummary>>(
      dashboardSummaryProvider,
      (_, next) => last = next,
      fireImmediately: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 80));

    expect(last, isNotNull);
    final snapshot = last!;
    expect(snapshot.hasValue, isTrue);
    final summary = snapshot.requireValue;
    expect(summary.eventCount, 1);
    expect(summary.taskCount, 1);
    expect(summary.weatherSummary, isNotNull);
  });

  test('adaptDashboardLayout moves upcoming ahead of quick actions in evening',
      () {
    final base = const DashboardLayout(
      schemaVersion: 1,
      slots: [
        DashboardSlot(
          widgetId: 'today_summary',
          requestedSize: DashboardSize.l,
        ),
        DashboardSlot(
          widgetId: 'quick_actions',
          requestedSize: DashboardSize.xl,
        ),
        DashboardSlot(
          widgetId: 'upcoming_strip',
          requestedSize: DashboardSize.l,
        ),
      ],
    );

    final adapted =
        adaptDashboardLayout(base, DashboardDayPhase.evening);
    final v2 = adapted.migrateToV2();
    final ids =
        v2.base.expand((r) => r.tiles.map((t) => t.widgetId)).toList();
    expect(ids.indexOf('upcoming_strip'), lessThan(ids.indexOf('quick_actions')));
  });
}

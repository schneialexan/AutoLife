import 'package:autolife_core/autolife_core.dart';
import 'package:autolife_shell/main.dart' as shell;
import 'package:autolife_shell/src/smoke/dashboard_events_consumer.dart';
import 'package:autolife_shell/src/smoke/smoke_test_harness.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase/supabase.dart';

const _testSupabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);
const _testSupabaseKey = String.fromEnvironment(
  'SUPABASE_SERVICE_ROLE_KEY',
  defaultValue: '',
);

bool get _haveSupabase =>
    _testSupabaseUrl.isNotEmpty && _testSupabaseKey.isNotEmpty;

Future<void> _flushProcessEvent(SupabaseClient client, String eventId) async {
  final res = await client.functions.invoke(
    'process-event',
    body: {'event_id': eventId},
  );
  if (res.status != 200) {
    throw StateError(
      'process-event failed: HTTP ${res.status} data=${res.data}',
    );
  }
}

Future<void> _flushStalled(SupabaseClient client) async {
  final res = await client.functions.invoke(
    'process-event',
    body: {'scan_stalled': true},
  );
  if (res.status != 200) {
    throw StateError('process-event scan failed: HTTP ${res.status}');
  }
}

Future<void> _waitForDashboardDelivery(
  SupabaseClient supabase,
  String eventId,
) async {
  for (var i = 0; i < 80; i++) {
    final row = await supabase
        .from('event_delivery')
        .select('status')
        .eq('event_id', eventId)
        .eq('consumer', dashboardEventsConsumerId)
        .maybeSingle();
    if (row != null && row['status'] == 'succeeded') return;
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await _flushStalled(supabase);
    await _flushProcessEvent(supabase, eventId);
  }
  throw StateError('timeout waiting for dashboard delivery on $eventId');
}

Future<void> _waitForDriftTitle(
  WidgetTester tester,
  SyncEngine engine,
  String title, {
  Duration timeout = const Duration(seconds: 45),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await engine.runCycle();
    await tester.pump(const Duration(milliseconds: 150));
    if (find.text(title).evaluate().isNotEmpty) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  throw StateError('timeout waiting for Today widget to show: $title');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  tearDownAll(SmokeTestHarness.disposeIntegrationTest);

  testWidgets('phase 1.8 smoke: online, offline drain, flaky retry', (
    tester,
  ) async {
    await shell.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final supabase = SupabaseClient(_testSupabaseUrl, _testSupabaseKey);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
      listen: false,
    );
    final engine = container.read(syncEngineProvider);

    await tester.tap(find.byIcon(Icons.science_outlined));
    await tester.pumpAndSettle();

    Future<String?> findEventIdWithTitle(String title) async {
      final rows = await supabase
          .from('system_event')
          .select('id,payload')
          .eq('tenant_id', 'local-dev')
          .eq('type', 'smoke.note');
      final list = rows as List<dynamic>;
      for (final r in list) {
        final m = Map<String, dynamic>.from(r as Map);
        final p = m['payload'];
        if (p is Map && p['title'] == title) {
          return m['id'] as String?;
        }
      }
      return null;
    }

    await tester.enterText(
      find.byKey(const Key('smoke_add_title_field')),
      'e2e-online-note',
    );
    await tester.tap(find.text('Add Event'));
    await tester.pumpAndSettle();

    String? eventId;
    for (var i = 0; i < 100 && eventId == null; i++) {
      eventId = await findEventIdWithTitle('e2e-online-note');
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
    expect(eventId, isNotNull);

    await _flushProcessEvent(supabase, eventId!);
    await _waitForDashboardDelivery(supabase, eventId);
    await _waitForDriftTitle(tester, engine, 'e2e-online-note');

    await tester.enterText(
      find.byKey(const Key('smoke_add_title_field')),
      'e2e-flaky-retry-flaky',
    );
    await tester.tap(find.text('Add Event'));
    await tester.pumpAndSettle();

    String? flakyId;
    for (var i = 0; i < 120 && flakyId == null; i++) {
      final rows = await supabase
          .from('system_event')
          .select('id,payload')
          .eq('tenant_id', 'local-dev')
          .eq('type', 'smoke.note');
      final list = rows as List<dynamic>;
      for (final r in list) {
        final m = Map<String, dynamic>.from(r as Map);
        final p = m['payload'];
        if (p is Map &&
            p['title'] == 'e2e-flaky-retry-flaky' &&
            p['smoke_flaky'] == true) {
          flakyId = m['id'] as String?;
          break;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
    expect(flakyId, isNotNull);

    await _flushProcessEvent(supabase, flakyId!);
    await _waitForDashboardDelivery(supabase, flakyId);
    await _waitForDriftTitle(tester, engine, 'e2e-flaky-retry-flaky');

    SmokeTestHarness.setOnline(false);
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(
      find.byKey(const Key('smoke_add_title_field')),
      'e2e-offline-note',
    );
    await tester.tap(find.text('Add Event'));
    await tester.pumpAndSettle();
    expect(engine.status.pendingQueueDepth, greaterThan(0));

    SmokeTestHarness.setOnline(true);
    await tester.pump(const Duration(milliseconds: 400));

    String? offlineId;
    for (var i = 0; i < 150 && offlineId == null; i++) {
      await engine.runCycle();
      await tester.pump(const Duration(milliseconds: 100));
      offlineId = await findEventIdWithTitle('e2e-offline-note');
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
    expect(offlineId, isNotNull);

    await _flushProcessEvent(supabase, offlineId!);
    await _waitForDashboardDelivery(supabase, offlineId);
    await _waitForDriftTitle(tester, engine, 'e2e-offline-note');
  }, skip: !_haveSupabase);
}

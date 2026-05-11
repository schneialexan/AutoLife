import 'package:autolife_core/autolife_core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase/supabase.dart';

/// Resolved tenant for smoke / shell demo (`system_event.tenant_id`, text).
final shellTenantIdProvider = Provider<String>((ref) => 'local-dev');

/// Seeded `family.id` for local Supabase (`supabase/seed.sql`); used for UUID-scoped tables on pull.
const shellDemoFamilyScopeUuid = String.fromEnvironment(
  'AUTOLIFE_DEMO_FAMILY_UUID',
  defaultValue: '11111111-1111-1111-1111-111111111111',
);

/// Bound only in Supabase smoke mode.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => throw StateError('supabaseClientProvider unbound'),
);

/// Bound only in Supabase smoke mode.
final autolifeDatabaseProvider = Provider<AutolifeDatabase>(
  (ref) => throw StateError('autolifeDatabaseProvider unbound'),
);

/// Bound only in Supabase smoke mode (real device or [SmokeTestHarness]).
final shellConnectivityProvider = Provider<ConnectivityWatcher>(
  (ref) => throw StateError('shellConnectivityProvider unbound'),
);

final shellPayloadCipherProvider = Provider<PayloadCipher>(
  (ref) => PayloadCipher(SecretKey(Uint8List(32))),
);

final shellEventProducerProvider = Provider<EventProducer>((ref) {
  final sync = ref.read(syncEngineProvider);
  final client = ref.watch(supabaseClientProvider);
  return OfflineAwareEventProducer(
    onlineProducer: SupabaseEventProducer(client),
    offlineQueue: sync.offlineWriteQueue,
    probeOnline: () => ref.read(syncEngineProvider).connectivityWatcher.isOnline(),
    defaultActorId: 'shell-actor',
  );
});

List<Override> smokeSupabaseOverrides({
  required SupabaseClient client,
  required AutolifeDatabase database,
  required ConnectivityWatcher connectivity,
}) {
  return [
    supabaseClientProvider.overrideWithValue(client),
    autolifeDatabaseProvider.overrideWithValue(database),
    shellConnectivityProvider.overrideWithValue(connectivity),
    syncEngineProvider.overrideWith((ref) {
      final engine = SyncEngine(
        db: ref.watch(autolifeDatabaseProvider),
        gateway: SupabaseRemoteSyncGateway(ref.watch(supabaseClientProvider)),
        connectivity: ref.watch(shellConnectivityProvider),
        cipher: ref.watch(shellPayloadCipherProvider),
        conflictResolver: LastWriterWinsResolver(),
        tenantId: ref.watch(shellTenantIdProvider),
        tenancyFamilyScopeId: shellDemoFamilyScopeUuid,
      );
      void onEngineUpdate() {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ref.read(syncStatusTickProvider.notifier).state++;
        });
      }

      engine.addListener(onEngineUpdate);
      ref.onDispose(() {
        engine.removeListener(onEngineUpdate);
        engine.dispose();
      });
      return engine;
    }),
    connectorRegistryProvider.overrideWith((ref) {
      final registry = ConnectorRegistry();
      final sync = ref.read(syncEngineProvider);
      registry.register(
        OfflineAwareIntegrationConnector(
          inner: MockConnector(),
          offlineQueue: sync.offlineWriteQueue,
          probeOnline: () => sync.connectivityWatcher.isOnline(),
          defaultTenantId: ref.read(shellTenantIdProvider),
          defaultActorId: 'shell-actor',
        ),
      );
      return registry;
    }),
    connectorEventProducerProvider.overrideWith((ref) {
      final client = ref.watch(supabaseClientProvider);
      final sync = ref.read(syncEngineProvider);
      return OfflineAwareEventProducer(
        onlineProducer: SupabaseEventProducer(client),
        offlineQueue: sync.offlineWriteQueue,
        probeOnline: () =>
            ref.read(syncEngineProvider).connectivityWatcher.isOnline(),
        defaultActorId: 'shell-actor',
      );
    }),
  ];
}

/// Today's smoke-module events from the local Drift cache (phase 1.8).
final todaySmokeEventsProvider =
    StreamProvider<List<SystemEventCacheData>>((ref) {
  final db = ref.watch(autolifeDatabaseProvider);
  final tenant = ref.watch(shellTenantIdProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return (db.select(db.systemEventCache)
        ..where(
          (t) =>
              t.tenantId.equals(tenant) &
              t.module.equals('smoke') &
              t.occurredAt.isBiggerOrEqualValue(start) &
              t.occurredAt.isSmallerThanValue(end),
        )
        ..orderBy([
          (t) => OrderingTerm(expression: t.occurredAt, mode: OrderingMode.desc),
        ]))
      .watch();
});
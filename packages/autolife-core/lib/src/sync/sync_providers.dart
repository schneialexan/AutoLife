import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shell_placeholder_sync.dart';
import 'sync_engine.dart';

/// Bumps when [SyncEngine] notifies; avoids [CircularDependencyError] from
/// `invalidate(syncStatusProvider)` while [syncStatusProvider] still transitively
/// depends on [syncEngineProvider].
final syncStatusTickProvider = StateProvider<int>((ref) => 0);

/// Live sync controller; override in [ProviderScope] to bind a real [SyncEngine].
///
/// Uses a plain [Provider] (not [ChangeNotifierProvider]) so Riverpod does not
/// subscribe to [ChangeNotifier] during [ProviderScope] activation — that path
/// can trigger Flutter web's `!_dirty` assert when nested providers watch this
/// engine during the first frame.
final Provider<SyncEngine> syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = createShellPlaceholderSyncEngine(tenantId: 'local-dev');
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
});

/// Read-only [`SyncStatus`](sync_engine.dart) + queue depth for UI.
final Provider<SyncStatus> syncStatusProvider = Provider<SyncStatus>(
  (ref) {
    ref.watch(syncStatusTickProvider);
    return ref.read(syncEngineProvider).status;
  },
);

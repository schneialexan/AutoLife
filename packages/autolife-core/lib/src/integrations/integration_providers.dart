import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/event_producer.dart';
import 'connector_audit_logger.dart';
import 'connector_lifecycle_coordinator.dart';
import 'connector_registry.dart';
import 'connector_status.dart';
import 'connector_status_tracker.dart';

final connectorRegistryProvider = Provider<ConnectorRegistry>((ref) {
  return ConnectorRegistry();
});

/// Bumps when [ConnectorStatusTracker] notifies; avoids [CircularDependencyError]
/// from `invalidate(connectorStatusProvider)` (that provider must not invalidate a
/// dependency of the notifier that triggered the update).
final connectorStatusTickProvider = StateProvider<int>((ref) => 0);

/// Plain [Provider] (not [ChangeNotifierProvider]) for the same web `!_dirty` reason
/// as [syncEngineProvider].
final Provider<ConnectorStatusTracker> connectorStatusTrackerProvider =
    Provider<ConnectorStatusTracker>((ref) {
      final tracker = ConnectorStatusTracker();
      void onTrackerUpdate() {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ref.read(connectorStatusTickProvider.notifier).state++;
        });
      }

      tracker.addListener(onTrackerUpdate);
      ref.onDispose(() {
        tracker.removeListener(onTrackerUpdate);
        tracker.dispose();
      });
      return tracker;
    });

final connectorAuditLoggerProvider = Provider<ConnectorAuditLogger>((ref) {
  return SilentConnectorAuditLogger();
});

final connectorEventProducerProvider = Provider<EventProducer>((ref) {
  return const IgnoringEventProducer();
});

/// Stable connector ids registered in [connectorRegistryProvider].
final connectorListProvider = Provider<List<String>>((ref) {
  return ref.watch(connectorRegistryProvider).connectorIds;
});

/// Latest status snapshot per connector id for shell dashboards.
final Provider<Map<String, ConnectorStatus>> connectorStatusProvider =
    Provider<Map<String, ConnectorStatus>>((ref) {
      ref.watch(connectorStatusTickProvider);
      return ref.read(connectorStatusTrackerProvider).snapshot;
    });

final connectorLifecycleCoordinatorProvider =
    Provider<ConnectorLifecycleCoordinator>((ref) {
      return ConnectorLifecycleCoordinator(
        registry: ref.watch(connectorRegistryProvider),
        statusTracker: ref.watch(connectorStatusTrackerProvider),
        audit: ref.watch(connectorAuditLoggerProvider),
        eventProducer: ref.watch(connectorEventProducerProvider),
        actorId: 'shell',
        defaultTenantId: 'local-dev',
      );
    });

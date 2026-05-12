import 'package:auto_calendar/src/services/external_calendar_sync_service.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectorRegistryProvider = Provider<ConnectorRegistry>((ref) {
  return ConnectorRegistry();
});

final externalSyncServiceProvider = Provider<ExternalCalendarSyncService>((ref) {
  return ExternalCalendarSyncService(ref.watch(connectorRegistryProvider));
});

final externalSyncControllerProvider =
    StateNotifierProvider<ExternalSyncController, ExternalSyncState>((ref) {
  return ExternalSyncController(ref.watch(externalSyncServiceProvider));
});

final class ExternalSyncController extends StateNotifier<ExternalSyncState> {
  ExternalSyncController(this._service)
      : super(_service.state);

  final ExternalCalendarSyncService _service;

  Future<void> pullGoogle() async {
    await _service.pullGoogle(
      tenant: const Tenant(tenantId: 'local-demo'),
    );
    state = _service.state;
  }
}

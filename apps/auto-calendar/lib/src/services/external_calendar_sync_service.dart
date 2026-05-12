import 'package:autolife_core/autolife_core.dart';
import 'package:meta/meta.dart';

/// Google-first two-way sync seam; uses connector registry when shell wires it.
@immutable
final class ExternalSyncState {
  const ExternalSyncState({
    required this.lastPullAt,
    required this.pendingConflicts,
  });

  final DateTime? lastPullAt;
  final int pendingConflicts;
}

final class ExternalCalendarSyncService {
  ExternalCalendarSyncService(this._registry);

  final ConnectorRegistry _registry;

  ExternalSyncState _state = const ExternalSyncState(
    lastPullAt: null,
    pendingConflicts: 0,
  );

  ExternalSyncState get state => _state;

  Future<void> pullGoogle({required Tenant tenant}) async {
    final c = _registry['google_calendar'];
    if (c == null) {
      _state = ExternalSyncState(
        lastPullAt: DateTime.now().toUtc(),
        pendingConflicts: 0,
      );
      return;
    }
    await c.pullChanges(tenant: tenant);
    _state = ExternalSyncState(
      lastPullAt: DateTime.now().toUtc(),
      pendingConflicts: 0,
    );
  }
}

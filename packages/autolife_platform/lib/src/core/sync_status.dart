/// High-level state of the sync subsystem, surfaced to the UI as a status chip.
enum SyncStatus {
  /// No network connectivity.
  offline,

  /// Authenticated session absent — the app runs purely on local Hive data and
  /// outbox entries accumulate without being pushed.
  localOnly,

  /// A push/pull cycle is currently running.
  syncing,

  /// Last cycle completed and the local store is up to date with the server.
  synced,

  /// Last cycle failed; the outbox is retained for retry.
  error;

  String get label {
    switch (this) {
      case SyncStatus.offline:
        return 'Offline';
      case SyncStatus.localOnly:
        return 'Local only';
      case SyncStatus.syncing:
        return 'Syncing';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.error:
        return 'Sync error';
    }
  }
}

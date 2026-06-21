import 'sync_mutation.dart';

/// The expandable seam. Each AutoLife module implements one gateway and
/// registers it with the [SyncCoordinator] at startup. AutoLife's shell will
/// register every composed module's gateway against a single auth session.
///
/// A gateway owns the mapping between its local Hive records and the module's
/// Supabase tables, including stamping/reading `schema_version` and last-write-
/// wins resolution.
abstract class ModuleSyncGateway {
  /// Stable module id, e.g. `assets`.
  String get moduleId;

  /// Highest payload schema version this build can read/write.
  int get schemaVersion;

  /// Upserts/deletes the given local mutations to the module's remote tables.
  /// Implementations must be idempotent (the record id is the idempotency key)
  /// so retries are safe.
  Future<void> pushMutations(List<SyncMutation> mutations);

  /// Pulls remote changes with `server_updated_at` strictly after [cursor],
  /// paginated, invoking [onRemoteChange] for each. Returns the maximum
  /// `server_updated_at` observed (for cursor advancement), or null if nothing
  /// changed.
  Future<DateTime?> pullSince(
    DateTime? cursor, {
    required void Function(SyncMutation change) onRemoteChange,
  });

  /// Writes a batch of pulled changes into the local Hive repositories,
  /// applying last-write-wins and `schema_version` upgrade-on-read.
  Future<void> applyRemoteChanges(List<SyncMutation> changes);

  /// Bulk idempotent upsert of all local records on first sign-in
  /// ([AuthService.claimLocalVault]). Returns the mutations representing the
  /// full local state.
  Future<List<SyncMutation>> collectLocalState();
}

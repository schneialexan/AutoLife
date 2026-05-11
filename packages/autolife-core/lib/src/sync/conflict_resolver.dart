/// Which replica to keep when local and remote diverge on the same primary key.
enum ConflictWinner { local, remote }

/// Resolves merge collisions for cached rows (see `docs/offline-sync-contract.md`).
abstract class ConflictResolver {
  ConflictWinner resolve({
    required Map<String, dynamic> localRow,
    required Map<String, dynamic> remoteRow,
    required String? actorRole,
    DateTime? localUpdated,
    DateTime? remoteUpdated,
  });
}

DateTime? _parseUpdated(Map<String, dynamic> row) {
  final v = row['updated_at'];
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

/// Last-writer-wins using monotonic `updated_at` (tie → remote wins).
class LastWriterWinsResolver implements ConflictResolver {
  @override
  ConflictWinner resolve({
    required Map<String, dynamic> localRow,
    required Map<String, dynamic> remoteRow,
    required String? actorRole,
    DateTime? localUpdated,
    DateTime? remoteUpdated,
  }) {
    final l = localUpdated ?? _parseUpdated(localRow);
    final r = remoteUpdated ?? _parseUpdated(remoteRow);
    if (l == null && r == null) {
      return ConflictWinner.remote;
    }
    if (l == null) return ConflictWinner.remote;
    if (r == null) return ConflictWinner.local;
    if (l.isAfter(r)) return ConflictWinner.local;
    return ConflictWinner.remote;
  }
}

/// When roles disagree, prefers the row whose `actor_role` field equals [parentRole]
/// (product tests use `parent`). Falls back to [LastWriterWinsResolver].
class ParentOverrideResolver implements ConflictResolver {
  ParentOverrideResolver({this.parentRole = 'parent'});

  final String parentRole;
  final LastWriterWinsResolver _lww = LastWriterWinsResolver();

  @override
  ConflictWinner resolve({
    required Map<String, dynamic> localRow,
    required Map<String, dynamic> remoteRow,
    required String? actorRole,
    DateTime? localUpdated,
    DateTime? remoteUpdated,
  }) {
    final localR = (localRow['actor_role'] as String?) ?? actorRole;
    final remoteR = remoteRow['actor_role'] as String?;
    final lp = localR == parentRole;
    final rp = remoteR == parentRole;
    if (lp && !rp) return ConflictWinner.local;
    if (rp && !lp) return ConflictWinner.remote;
    return _lww.resolve(
      localRow: localRow,
      remoteRow: remoteRow,
      actorRole: actorRole,
      localUpdated: localUpdated,
      remoteUpdated: remoteUpdated,
    );
  }
}

/// Delegates to a custom predicate while preserving injection seam for tests.
class CallbackConflictResolver implements ConflictResolver {
  CallbackConflictResolver(this._fn);

  final ConflictWinner Function({
    required Map<String, dynamic> localRow,
    required Map<String, dynamic> remoteRow,
    required String? actorRole,
    DateTime? localUpdated,
    DateTime? remoteUpdated,
  }) _fn;

  @override
  ConflictWinner resolve({
    required Map<String, dynamic> localRow,
    required Map<String, dynamic> remoteRow,
    required String? actorRole,
    DateTime? localUpdated,
    DateTime? remoteUpdated,
  }) {
    return _fn(
      localRow: localRow,
      remoteRow: remoteRow,
      actorRole: actorRole,
      localUpdated: localUpdated,
      remoteUpdated: remoteUpdated,
    );
  }
}

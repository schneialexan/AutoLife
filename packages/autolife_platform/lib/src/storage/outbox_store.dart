import 'dart:convert';

import 'package:hive/hive.dart';

import '../core/sync_mutation.dart';

/// Durable queue of local edits awaiting push. Repeated edits to the same
/// entity **coalesce** (only the latest mutation per entity is kept), and the
/// record id doubles as the idempotency key so retries are safe.
///
/// Backed by an encrypted `Box<String>` of JSON-encoded [SyncMutation]s keyed
/// by [SyncMutation.coalesceKey].
class OutboxStore {
  OutboxStore(this._box);

  final Box<String> _box;

  int get length => _box.length;

  bool get isEmpty => _box.isEmpty;

  /// Enqueues [mutation], replacing any earlier pending mutation for the same
  /// entity (coalescing).
  Future<void> enqueue(SyncMutation mutation) async {
    await _box.put(mutation.coalesceKey, jsonEncode(mutation.toJson()));
  }

  /// All pending mutations, ordered by model `updatedAt` for stable batching.
  List<SyncMutation> pending() {
    final list = _box.values
        .map(
          (raw) =>
              SyncMutation.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        )
        .toList();
    list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    return list;
  }

  List<SyncMutation> pendingForModule(String moduleId) {
    return pending().where((m) => m.moduleId == moduleId).toList();
  }

  /// Removes mutations that were successfully pushed, but only when no newer
  /// edit for the same entity has arrived since (compared on `updatedAt`),
  /// which prevents a concurrent edit from being silently dropped.
  Future<void> removeProcessed(Iterable<SyncMutation> processed) async {
    for (final mutation in processed) {
      final raw = _box.get(mutation.coalesceKey);
      if (raw == null) {
        continue;
      }
      final current = SyncMutation.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (!current.updatedAt.isAfter(mutation.updatedAt)) {
        await _box.delete(mutation.coalesceKey);
      }
    }
  }

  Future<void> clear() async {
    await _box.clear();
  }
}

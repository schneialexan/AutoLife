import 'package:autolife_platform/autolife_platform.dart';

import '../models/asset.dart';
import '../sync/assets_sync_schema.dart';
import 'asset_repository.dart';

/// [AssetRepository] decorator that keeps Hive as the source of truth and
/// enqueues a [SyncMutation] on every write. When sync is off the outbox simply
/// accumulates and the coordinator no-ops, so the app behaves identically to
/// the local-only build.
class SyncingAssetRepository implements AssetRepository {
  SyncingAssetRepository(
    this._inner, {
    required OutboxStore outbox,
    required String deviceId,
    Future<void> Function()? onMutation,
  }) : _outbox = outbox,
       _deviceId = deviceId,
       _onMutation = onMutation;

  final AssetRepository _inner;
  final OutboxStore _outbox;
  final String _deviceId;
  final Future<void> Function()? _onMutation;

  @override
  List<Asset> getAll() => _inner.getAll();

  @override
  Asset? getById(String id) => _inner.getById(id);

  @override
  Future<void> save(Asset asset) async {
    await _inner.save(asset);
    await _outbox.enqueue(
      SyncMutation(
        moduleId: AssetsSyncSchema.moduleId,
        entityType: AssetsSyncSchema.itemEntity,
        entityId: asset.id,
        operation: SyncOperation.upsert,
        payload: asset.toJson(),
        schemaVersion: AssetsSyncSchema.version,
        updatedAt: asset.updatedAt,
        deviceId: _deviceId,
      ),
    );
    await _kick();
  }

  @override
  Future<void> delete(String id) async {
    final existing = _inner.getById(id);
    await _inner.delete(id);
    await _outbox.enqueue(
      SyncMutation(
        moduleId: AssetsSyncSchema.moduleId,
        entityType: AssetsSyncSchema.itemEntity,
        entityId: id,
        operation: SyncOperation.delete,
        payload: existing?.toJson(),
        schemaVersion: AssetsSyncSchema.version,
        updatedAt: DateTime.now().toUtc(),
        deviceId: _deviceId,
      ),
    );
    await _kick();
  }

  Future<void> _kick() async {
    final callback = _onMutation;
    if (callback == null) {
      return;
    }
    // Best-effort background trigger: the write is already durable in Hive and
    // queued in the outbox, so a sync failure here must not fail the local
    // save. Errors surface via the live sync status / explicit "Sync now".
    try {
      await callback();
    } catch (_) {
      // Swallowed on purpose; see above.
    }
  }
}

import 'package:autolife_platform/autolife_platform.dart';

import '../models/category_type.dart';
import '../sync/assets_sync_schema.dart';
import 'category_type_repository.dart';

/// [CategoryTypeRepository] decorator mirroring saves/deletes to the outbox.
/// Delegates seeding and reads to the wrapped Hive repository unchanged.
class SyncingCategoryTypeRepository implements CategoryTypeRepository {
  SyncingCategoryTypeRepository(
    this._inner, {
    required OutboxStore outbox,
    required String deviceId,
    Future<void> Function()? onMutation,
  }) : _outbox = outbox,
       _deviceId = deviceId,
       _onMutation = onMutation;

  final CategoryTypeRepository _inner;
  final OutboxStore _outbox;
  final String _deviceId;
  final Future<void> Function()? _onMutation;

  @override
  List<CategoryType> getAll() => _inner.getAll();

  @override
  List<CategoryType> getActive() => _inner.getActive();

  @override
  CategoryType? getById(String id) => _inner.getById(id);

  @override
  Future<void> seedDefaults() => _inner.seedDefaults();

  @override
  Future<void> save(CategoryType type) async {
    await _inner.save(type);
    await _outbox.enqueue(
      SyncMutation(
        moduleId: AssetsSyncSchema.moduleId,
        entityType: AssetsSyncSchema.categoryTypeEntity,
        entityId: type.id,
        operation: SyncOperation.upsert,
        payload: type.toJson(),
        schemaVersion: AssetsSyncSchema.version,
        updatedAt: DateTime.now().toUtc(),
        deviceId: _deviceId,
      ),
    );
    await _kick();
  }

  @override
  Future<void> delete(String id) async {
    await _inner.delete(id);
    await _outbox.enqueue(
      SyncMutation(
        moduleId: AssetsSyncSchema.moduleId,
        entityType: AssetsSyncSchema.categoryTypeEntity,
        entityId: id,
        operation: SyncOperation.delete,
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

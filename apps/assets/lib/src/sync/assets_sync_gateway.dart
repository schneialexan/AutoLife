import 'package:autolife_platform/autolife_platform.dart';

import '../data/asset_repository.dart';
import '../data/category_type_repository.dart';
import '../models/asset.dart';
import '../models/category_type.dart';
import '../services/asset_image_store.dart';
import 'assets_sync_schema.dart';
import 'blob_payload_rewriter.dart';

/// Mirrors AutoAssets' local Hive records to the `assets.*` Supabase tables.
///
/// Exported from `auto_assets.dart` (public API) so the AutoLife shell can
/// register the *same* gateway alongside other modules' gateways against one
/// auth session.
///
/// Writes from [applyRemoteChanges] go straight to the **plain** Hive repos
/// (never the syncing decorators), so pulled changes don't re-enter the outbox.
class AssetsSyncGateway implements ModuleSyncGateway {
  AssetsSyncGateway({
    required AssetRepository assetRepository,
    required CategoryTypeRepository categoryTypeRepository,
    required RemoteModuleTable itemsTable,
    required RemoteModuleTable categoryTypesTable,
    required String deviceId,
    AssetImageStore? imageStore,
    BlobPayloadRewriter? blobRewriter,
    void Function()? onLocalDataChanged,
  }) : _assets = assetRepository,
       _categoryTypes = categoryTypeRepository,
       _itemsTable = itemsTable,
       _categoryTypesTable = categoryTypesTable,
       _deviceId = deviceId,
       _imageStore = imageStore,
       _blobRewriter = blobRewriter,
       _onLocalDataChanged = onLocalDataChanged;

  static const int _pageSize = 200;

  final AssetRepository _assets;
  final CategoryTypeRepository _categoryTypes;
  final RemoteModuleTable _itemsTable;
  final RemoteModuleTable _categoryTypesTable;
  final String _deviceId;
  final AssetImageStore? _imageStore;
  final BlobPayloadRewriter? _blobRewriter;
  final void Function()? _onLocalDataChanged;

  @override
  String get moduleId => AssetsSyncSchema.moduleId;

  @override
  int get schemaVersion => AssetsSyncSchema.version;

  // ---------------------------------------------------------------------------
  // Push
  // ---------------------------------------------------------------------------
  @override
  Future<void> pushMutations(List<SyncMutation> mutations) async {
    final itemRows = <Map<String, dynamic>>[];
    final categoryRows = <Map<String, dynamic>>[];
    for (final mutation in mutations) {
      switch (mutation.entityType) {
        case AssetsSyncSchema.itemEntity:
          itemRows.add(await _rowForPush(mutation, rewriteBlobs: true));
        case AssetsSyncSchema.categoryTypeEntity:
          categoryRows.add(await _rowForPush(mutation, rewriteBlobs: false));
      }
    }
    if (itemRows.isNotEmpty) {
      await _itemsTable.upsertRows(itemRows);
    }
    if (categoryRows.isNotEmpty) {
      await _categoryTypesTable.upsertRows(categoryRows);
    }
  }

  Future<Map<String, dynamic>> _rowForPush(
    SyncMutation mutation, {
    required bool rewriteBlobs,
  }) async {
    var effective = mutation;
    final rewriter = _blobRewriter;
    if (rewriteBlobs &&
        rewriter != null &&
        mutation.operation == SyncOperation.upsert &&
        mutation.payload != null) {
      final rewritten = await rewriter.toRemote(
        mutation.payload!,
        mutation.entityId,
      );
      effective = mutation.copyWith(payload: rewritten);
    }
    return AssetsSyncSchema.rowFromMutation(effective);
  }

  // ---------------------------------------------------------------------------
  // Pull
  // ---------------------------------------------------------------------------
  @override
  Future<DateTime?> pullSince(
    DateTime? cursor, {
    required void Function(SyncMutation change) onRemoteChange,
  }) async {
    final itemMax = await _pullTable(
      _itemsTable,
      cursor,
      AssetsSyncSchema.itemEntity,
      onRemoteChange,
    );
    final categoryMax = await _pullTable(
      _categoryTypesTable,
      cursor,
      AssetsSyncSchema.categoryTypeEntity,
      onRemoteChange,
    );
    return _laterOf(itemMax, categoryMax);
  }

  Future<DateTime?> _pullTable(
    RemoteModuleTable table,
    DateTime? cursor,
    String entityType,
    void Function(SyncMutation) onRemoteChange,
  ) async {
    DateTime? pageCursor = cursor;
    DateTime? maxSeen;
    while (true) {
      final rows = await table.fetchSince(pageCursor, limit: _pageSize);
      if (rows.isEmpty) {
        break;
      }
      for (final row in rows) {
        final mutation = AssetsSyncSchema.mutationFromRow(
          row,
          entityType: entityType,
        );
        onRemoteChange(mutation);
        final server = mutation.serverUpdatedAt;
        if (server != null) {
          maxSeen = _laterOf(maxSeen, server);
          pageCursor = _laterOf(pageCursor, server);
        }
      }
      if (rows.length < _pageSize) {
        break;
      }
    }
    return maxSeen;
  }

  // ---------------------------------------------------------------------------
  // Apply (remote -> local Hive)
  // ---------------------------------------------------------------------------
  @override
  Future<void> applyRemoteChanges(List<SyncMutation> changes) async {
    var changed = false;
    for (final change in changes) {
      final applied = switch (change.entityType) {
        AssetsSyncSchema.itemEntity => await _applyItem(change),
        AssetsSyncSchema.categoryTypeEntity => await _applyCategoryType(change),
        _ => false,
      };
      changed = changed || applied;
    }
    if (changed) {
      _onLocalDataChanged?.call();
    }
  }

  Future<bool> _applyItem(SyncMutation change) async {
    if (!AssetsSyncSchema.canRead(change.schemaVersion)) {
      return false;
    }
    final local = _assets.getById(change.entityId);
    if (!AssetsSyncSchema.remoteWins(
      remoteUpdatedAt: change.updatedAt,
      localUpdatedAt: local?.updatedAt,
    )) {
      return false;
    }
    if (change.operation == SyncOperation.delete) {
      if (local == null) {
        return false;
      }
      await _assets.delete(change.entityId);
      await _imageStore?.deleteAll(local.localFilePaths());
      return true;
    }
    final payload = change.payload;
    if (payload == null) {
      return false;
    }
    final upgraded = AssetsSyncSchema.upgradePayload(
      payload,
      change.schemaVersion,
    );
    final localized = _blobRewriter == null
        ? upgraded
        : await _blobRewriter.toLocal(upgraded, change.entityId);
    await _assets.save(Asset.fromJson(localized));
    return true;
  }

  Future<bool> _applyCategoryType(SyncMutation change) async {
    if (!AssetsSyncSchema.canRead(change.schemaVersion)) {
      return false;
    }
    final local = _categoryTypes.getById(change.entityId);
    final localUpdatedAt = local?.createdAt;
    if (!AssetsSyncSchema.remoteWins(
      remoteUpdatedAt: change.updatedAt,
      localUpdatedAt: localUpdatedAt,
    )) {
      // Category types have no model updatedAt; fall through to apply when the
      // record is missing locally, otherwise keep the local copy.
      if (local != null) {
        return false;
      }
    }
    if (change.operation == SyncOperation.delete) {
      if (local == null) {
        return false;
      }
      await _categoryTypes.delete(change.entityId);
      return true;
    }
    final payload = change.payload;
    if (payload == null) {
      return false;
    }
    await _categoryTypes.save(CategoryType.fromJson(payload));
    return true;
  }

  // ---------------------------------------------------------------------------
  // Claim local vault
  // ---------------------------------------------------------------------------
  @override
  Future<List<SyncMutation>> collectLocalState() async {
    final now = DateTime.now().toUtc();
    final mutations = <SyncMutation>[];
    for (final asset in _assets.getAll()) {
      mutations.add(
        SyncMutation(
          moduleId: moduleId,
          entityType: AssetsSyncSchema.itemEntity,
          entityId: asset.id,
          operation: SyncOperation.upsert,
          payload: asset.toJson(),
          schemaVersion: schemaVersion,
          updatedAt: asset.updatedAt,
          deviceId: _deviceId,
        ),
      );
    }
    for (final type in _categoryTypes.getAll()) {
      mutations.add(
        SyncMutation(
          moduleId: moduleId,
          entityType: AssetsSyncSchema.categoryTypeEntity,
          entityId: type.id,
          operation: SyncOperation.upsert,
          payload: type.toJson(),
          schemaVersion: schemaVersion,
          updatedAt: type.createdAt.isUtc ? type.createdAt : now,
          deviceId: _deviceId,
        ),
      );
    }
    return mutations;
  }

  DateTime? _laterOf(DateTime? a, DateTime? b) {
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }
    return a.isAfter(b) ? a : b;
  }
}

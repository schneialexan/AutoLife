import 'package:autolife_platform/autolife_platform.dart';

/// Shared identifiers and pure mapping/merge logic for the AutoAssets sync
/// gateway. Kept free of Supabase/Hive so it can be unit-tested directly.
class AssetsSyncSchema {
  AssetsSyncSchema._();

  static const String moduleId = 'assets';

  /// Entity types within the module — one per remote table.
  static const String itemEntity = 'item';
  static const String categoryTypeEntity = 'category_type';

  /// Highest payload schema version this build understands. Bump when the
  /// model JSON changes in a non-backward-compatible way and add an
  /// [upgradePayload] branch.
  static const int version = 1;

  /// Builds the remote row for a push mutation. `user_id` and
  /// `server_updated_at` are intentionally omitted — both are server-assigned
  /// (RLS default `auth.uid()` and the DB trigger).
  static Map<String, dynamic> rowFromMutation(SyncMutation mutation) {
    final isDelete = mutation.operation == SyncOperation.delete;
    return <String, dynamic>{
      'id': mutation.entityId,
      'payload': mutation.payload ?? <String, dynamic>{},
      'schema_version': mutation.schemaVersion,
      'updated_at': mutation.updatedAt.toUtc().toIso8601String(),
      'deleted_at': isDelete
          ? mutation.updatedAt.toUtc().toIso8601String()
          : null,
      'device_id': mutation.deviceId,
    };
  }

  /// Converts a pulled remote row into a [SyncMutation].
  static SyncMutation mutationFromRow(
    Map<String, dynamic> row, {
    required String entityType,
  }) {
    final deletedAt = row['deleted_at'];
    final rawPayload = row['payload'];
    return SyncMutation(
      moduleId: moduleId,
      entityType: entityType,
      entityId: row['id'] as String,
      operation: deletedAt == null
          ? SyncOperation.upsert
          : SyncOperation.delete,
      payload: rawPayload == null
          ? null
          : (rawPayload as Map).cast<String, dynamic>(),
      schemaVersion: (row['schema_version'] as num?)?.toInt() ?? 1,
      updatedAt: DateTime.parse(row['updated_at'] as String),
      deviceId: row['device_id'] as String? ?? 'unknown',
      serverUpdatedAt: row['server_updated_at'] == null
          ? null
          : DateTime.parse(row['server_updated_at'] as String),
    );
  }

  /// Whether a remote change should overwrite the local record. Last-write-wins
  /// on model `updatedAt`; on an exact tie the remote write is preferred for a
  /// deterministic outcome across devices.
  static bool remoteWins({
    required DateTime remoteUpdatedAt,
    required DateTime? localUpdatedAt,
  }) {
    if (localUpdatedAt == null) {
      return true;
    }
    return !remoteUpdatedAt.isBefore(localUpdatedAt);
  }

  /// Whether this build can read a payload at [payloadVersion]. A payload newer
  /// than [version] is refused (surface "update the app to sync this item")
  /// rather than silently corrupting it.
  static bool canRead(int payloadVersion) => payloadVersion <= version;

  /// Upgrades an older payload to the current schema on read. v1 is the base
  /// version, so this is currently an identity transform; future versions add
  /// branches here.
  static Map<String, dynamic> upgradePayload(
    Map<String, dynamic> payload,
    int fromVersion,
  ) {
    return payload;
  }
}

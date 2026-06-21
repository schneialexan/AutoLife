import 'package:auto_assets/src/sync/assets_sync_schema.dart';
import 'package:autolife_platform/autolife_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssetsSyncSchema mapping', () {
    test('upsert mutation -> row -> mutation round-trip', () {
      final mutation = SyncMutation(
        moduleId: AssetsSyncSchema.moduleId,
        entityType: AssetsSyncSchema.itemEntity,
        entityId: 'asset-1',
        operation: SyncOperation.upsert,
        payload: const <String, dynamic>{'id': 'asset-1', 'name': 'Air Fryer'},
        schemaVersion: 1,
        updatedAt: DateTime.utc(2026, 3, 15, 10),
        deviceId: 'device-1',
      );

      final row = AssetsSyncSchema.rowFromMutation(mutation);
      expect(row['id'], 'asset-1');
      expect(row['deleted_at'], isNull);
      expect(row['schema_version'], 1);
      expect(row['device_id'], 'device-1');

      // Simulate the server stamping server_updated_at.
      row['server_updated_at'] = DateTime.utc(
        2026,
        3,
        15,
        10,
        1,
      ).toIso8601String();

      final back = AssetsSyncSchema.mutationFromRow(
        row,
        entityType: AssetsSyncSchema.itemEntity,
      );
      expect(back.entityId, 'asset-1');
      expect(back.operation, SyncOperation.upsert);
      expect(back.payload, mutation.payload);
      expect(back.updatedAt, mutation.updatedAt);
      expect(back.serverUpdatedAt, DateTime.utc(2026, 3, 15, 10, 1));
    });

    test('delete mutation stamps deleted_at and maps back to delete', () {
      final mutation = SyncMutation(
        moduleId: AssetsSyncSchema.moduleId,
        entityType: AssetsSyncSchema.itemEntity,
        entityId: 'gone',
        operation: SyncOperation.delete,
        payload: const <String, dynamic>{'id': 'gone'},
        schemaVersion: 1,
        updatedAt: DateTime.utc(2026, 4, 1),
        deviceId: 'd',
      );
      final row = AssetsSyncSchema.rowFromMutation(mutation);
      expect(row['deleted_at'], isNotNull);

      final back = AssetsSyncSchema.mutationFromRow(
        row,
        entityType: AssetsSyncSchema.itemEntity,
      );
      expect(back.operation, SyncOperation.delete);
    });
  });

  group('AssetsSyncSchema merge & versioning', () {
    test('remoteWins is last-write-wins, remote on tie, always vs missing', () {
      final older = DateTime.utc(2026, 1, 1);
      final newer = DateTime.utc(2026, 2, 1);

      expect(
        AssetsSyncSchema.remoteWins(
          remoteUpdatedAt: newer,
          localUpdatedAt: older,
        ),
        isTrue,
      );
      expect(
        AssetsSyncSchema.remoteWins(
          remoteUpdatedAt: older,
          localUpdatedAt: newer,
        ),
        isFalse,
      );
      expect(
        AssetsSyncSchema.remoteWins(
          remoteUpdatedAt: older,
          localUpdatedAt: older,
        ),
        isTrue,
        reason: 'tie prefers remote for determinism',
      );
      expect(
        AssetsSyncSchema.remoteWins(
          remoteUpdatedAt: older,
          localUpdatedAt: null,
        ),
        isTrue,
        reason: 'missing local always loses',
      );
    });

    test('canRead refuses payloads newer than this build', () {
      expect(AssetsSyncSchema.canRead(AssetsSyncSchema.version), isTrue);
      expect(AssetsSyncSchema.canRead(AssetsSyncSchema.version + 1), isFalse);
    });
  });
}

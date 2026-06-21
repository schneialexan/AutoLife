import 'package:autolife_platform/autolife_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncMutation', () {
    test('round-trips through JSON', () {
      final mutation = SyncMutation(
        moduleId: 'assets',
        entityType: 'item',
        entityId: 'abc',
        operation: SyncOperation.upsert,
        payload: const <String, dynamic>{'id': 'abc', 'name': 'Air Fryer'},
        schemaVersion: 1,
        updatedAt: DateTime.utc(2026, 3, 15, 10, 30),
        deviceId: 'device-1',
        serverUpdatedAt: DateTime.utc(2026, 3, 15, 10, 31),
      );

      final restored = SyncMutation.fromJson(mutation.toJson());

      expect(restored.moduleId, 'assets');
      expect(restored.entityType, 'item');
      expect(restored.entityId, 'abc');
      expect(restored.operation, SyncOperation.upsert);
      expect(restored.payload, mutation.payload);
      expect(restored.schemaVersion, 1);
      expect(restored.updatedAt, mutation.updatedAt);
      expect(restored.deviceId, 'device-1');
      expect(restored.serverUpdatedAt, mutation.serverUpdatedAt);
    });

    test('coalesceKey is stable per entity', () {
      SyncMutation make(SyncOperation op) => SyncMutation(
        moduleId: 'assets',
        entityType: 'item',
        entityId: 'abc',
        operation: op,
        schemaVersion: 1,
        updatedAt: DateTime.utc(2026),
        deviceId: 'd',
      );
      expect(
        make(SyncOperation.upsert).coalesceKey,
        make(SyncOperation.delete).coalesceKey,
      );
      expect(make(SyncOperation.upsert).coalesceKey, 'assets|item|abc');
    });

    test('delete mutation tolerates null payload', () {
      final mutation = SyncMutation(
        moduleId: 'assets',
        entityType: 'item',
        entityId: 'gone',
        operation: SyncOperation.delete,
        schemaVersion: 1,
        updatedAt: DateTime.utc(2026),
        deviceId: 'd',
      );
      final restored = SyncMutation.fromJson(mutation.toJson());
      expect(restored.operation, SyncOperation.delete);
      expect(restored.payload, isNull);
    });
  });
}

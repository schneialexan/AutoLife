import 'dart:io';

import 'package:auto_assets/src/data/asset_repository.dart';
import 'package:auto_assets/src/data/syncing_asset_repository.dart';
import 'package:auto_assets/src/models/asset.dart';
import 'package:auto_assets/src/sync/assets_sync_schema.dart';
import 'package:autolife_platform/autolife_platform.dart';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryAssetRepository implements AssetRepository {
  final Map<String, Asset> store = <String, Asset>{};

  @override
  List<Asset> getAll() => store.values.toList();

  @override
  Asset? getById(String id) => store[id];

  @override
  Future<void> save(Asset asset) async => store[asset.id] = asset;

  @override
  Future<void> delete(String id) async => store.remove(id);
}

void main() {
  late Directory dir;
  late Box<String> box;
  late OutboxStore outbox;
  late _InMemoryAssetRepository inner;
  late SyncingAssetRepository repo;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('syncing_repo_test');
    Hive.init(dir.path);
    box = await Hive.openBox<String>('sync_outbox');
    outbox = OutboxStore(box);
    inner = _InMemoryAssetRepository();
    repo = SyncingAssetRepository(inner, outbox: outbox, deviceId: 'device-1');
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
  });

  test('save writes through to Hive and enqueues an upsert mutation', () async {
    final asset = Asset(
      id: 'a1',
      name: 'Lamp',
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    await repo.save(asset);

    expect(inner.getById('a1')?.name, 'Lamp');
    final pending = outbox.pending();
    expect(pending, hasLength(1));
    expect(pending.single.operation, SyncOperation.upsert);
    expect(pending.single.entityType, AssetsSyncSchema.itemEntity);
    expect(pending.single.deviceId, 'device-1');
    expect(pending.single.payload?['name'], 'Lamp');
  });

  test(
    'delete removes locally and coalesces to a single delete mutation',
    () async {
      final asset = Asset(
        id: 'a1',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      await repo.save(asset);
      await repo.delete('a1');

      expect(inner.getById('a1'), isNull);
      final pending = outbox.pending();
      expect(pending, hasLength(1), reason: 'save+delete coalesce per entity');
      expect(pending.single.operation, SyncOperation.delete);
    },
  );
}

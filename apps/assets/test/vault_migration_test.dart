import 'dart:io';

import 'package:auto_assets/src/data/asset_repository.dart';
import 'package:auto_assets/src/data/category_type_repository.dart';
import 'package:auto_assets/src/migration/asset_vault_bundle.dart';
import 'package:auto_assets/src/migration/vault_migration_service.dart';
import 'package:auto_assets/src/models/asset.dart';
import 'package:auto_assets/src/models/category_type.dart';
import 'package:auto_assets/src/models/value_kind.dart';
import 'package:auto_assets/src/services/asset_image_store.dart';
import 'package:auto_assets/src/sync/assets_sync_schema.dart';
import 'package:path/path.dart' as p;
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

class _InMemoryCategoryTypeRepository implements CategoryTypeRepository {
  final Map<String, CategoryType> store = <String, CategoryType>{};
  @override
  List<CategoryType> getAll() => store.values.toList();
  @override
  List<CategoryType> getActive() =>
      store.values.where((t) => !t.isArchived).toList();
  @override
  CategoryType? getById(String id) => store[id];
  @override
  Future<void> save(CategoryType type) async => store[type.id] = type;
  @override
  Future<void> delete(String id) async => store.remove(id);
  @override
  Future<void> seedDefaults() async {}
}

void main() {
  group('AssetVaultBundle', () {
    test('round-trips through JSON', () {
      final bundle = AssetVaultBundle(
        schemaVersion: 1,
        exportedAt: DateTime.utc(2026, 6, 1),
        categoryTypes: const [
          <String, dynamic>{'id': 'brand'},
        ],
        assets: const [
          <String, dynamic>{'id': 'a1'},
        ],
        blobs: const {'/old/path.jpg': 'AAAA'},
      );
      final restored = AssetVaultBundle.fromJson(bundle.toJson());
      expect(restored.schemaVersion, 1);
      expect(restored.assets.single['id'], 'a1');
      expect(restored.blobs['/old/path.jpg'], 'AAAA');
      expect(restored.canImport, isTrue);
    });

    test('rejects a non-bundle map', () {
      expect(
        () => AssetVaultBundle.fromJson(const {'format': 'nope'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('canImport refuses a newer schema version', () {
      final bundle = AssetVaultBundle(
        schemaVersion: AssetsSyncSchema.version + 1,
        exportedAt: DateTime.utc(2026),
        categoryTypes: const [],
        assets: const [],
        blobs: const {},
      );
      expect(bundle.canImport, isFalse);
    });
  });

  group('VaultMigrationService round-trip', () {
    late Directory work;

    setUp(() async {
      work = await Directory.systemTemp.createTemp('vault_migration_test');
    });

    tearDown(() async {
      if (work.existsSync()) {
        await work.delete(recursive: true);
      }
    });

    test(
      'export then import on a fresh device restores data + blobs',
      () async {
        // Source device: a receipt file on disk + one asset + one type.
        final receipt = File(p.join(work.path, 'receipt.jpg'));
        await receipt.writeAsBytes(<int>[1, 2, 3, 4]);

        final srcAssets = _InMemoryAssetRepository();
        final srcTypes = _InMemoryCategoryTypeRepository();
        await srcTypes.save(
          CategoryType(
            id: 'brand',
            name: 'Brand',
            valueKind: ValueKind.text,
            accentColor: '#000000',
            displayIcon: 'icon:tag',
            sortOrder: 0,
            createdAt: DateTime.utc(2026),
          ),
        );
        await srcAssets.save(
          Asset(
            id: 'a1',
            name: 'Air Fryer',
            receiptPhotoPath: receipt.path,
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
          ),
        );

        final exportService = VaultMigrationService(
          assetRepository: srcAssets,
          categoryTypeRepository: srcTypes,
          imageStore: AssetImageStore(
            baseDirectory: Directory(p.join(work.path, 'src_store')),
          ),
        );
        final bundlePath = p.join(work.path, 'backup.json');
        await exportService.exportToFile(bundlePath);
        expect(File(bundlePath).existsSync(), isTrue);

        // Fresh device: empty repos + a different image store directory.
        final dstAssets = _InMemoryAssetRepository();
        final dstTypes = _InMemoryCategoryTypeRepository();
        final dstStoreDir = Directory(p.join(work.path, 'dst_store'));
        final importService = VaultMigrationService(
          assetRepository: dstAssets,
          categoryTypeRepository: dstTypes,
          imageStore: AssetImageStore(baseDirectory: dstStoreDir),
        );

        final result = await importService.importFromFile(bundlePath);
        expect(result.assets, 1);
        expect(result.categoryTypes, 1);
        expect(result.blobs, 1);

        final imported = dstAssets.getById('a1');
        expect(imported, isNotNull);
        expect(imported!.name, 'Air Fryer');
        final newReceipt = imported.receiptPhotoPath;
        expect(newReceipt, isNotNull);
        expect(
          newReceipt,
          isNot(receipt.path),
          reason: 'path is remapped locally',
        );
        expect(File(newReceipt!).existsSync(), isTrue);
        expect(await File(newReceipt).readAsBytes(), <int>[1, 2, 3, 4]);
      },
    );
  });
}

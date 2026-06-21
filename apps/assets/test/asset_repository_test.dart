import 'package:auto_assets/src/data/asset_storage.dart';
import 'package:auto_assets/src/data/hive_asset_repository.dart';
import 'package:auto_assets/src/models/asset.dart';
import 'package:auto_assets/src/models/asset_document.dart';
import 'package:auto_assets/src/models/money.dart';
import 'package:auto_assets/src/models/property_value.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_storage.dart';

void main() {
  late AppStorage storage;
  late HiveAssetRepository repo;

  setUp(() async {
    storage = await openTestStorage();
    repo = HiveAssetRepository(storage);
  });

  tearDown(closeTestStorage);

  Asset emptyAsset(String id) {
    final now = DateTime(2026, 6, 19);
    return Asset(id: id, createdAt: now, updatedAt: now);
  }

  test(
    'saves and reloads a completely empty asset as "Untitled asset"',
    () async {
      await repo.save(emptyAsset('a1'));
      final reloaded = repo.getById('a1');
      expect(reloaded, isNotNull);
      expect(reloaded!.displayLabel, 'Untitled asset');
    },
  );

  test('full CRUD round-trip preserves typed values', () async {
    final now = DateTime(2026, 3, 15);
    final asset = Asset(
      id: 'fryer',
      name: 'Air Fryer',
      purchaseDate: now,
      price: const Money(amount: 129.95, currency: 'CHF'),
      propertyValues: {
        'brand': const TextValue('Schneider'),
        'model': const TextValue('X17'),
      },
      createdAt: now,
      updatedAt: now,
    );
    await repo.save(asset);

    final reloaded = repo.getById('fryer')!;
    expect(reloaded.name, 'Air Fryer');
    expect(reloaded.price!.amount, 129.95);
    expect((reloaded.propertyValues['brand'] as TextValue).value, 'Schneider');

    await repo.delete('fryer');
    expect(repo.getById('fryer'), isNull);
  });

  test('propertyValues only stores types that were added', () async {
    final now = DateTime(2026);
    await repo.save(
      Asset(
        id: 'x',
        propertyValues: {'brand': const TextValue('Sony')},
        createdAt: now,
        updatedAt: now,
      ),
    );
    final reloaded = repo.getById('x')!;
    expect(reloaded.propertyValues.keys, ['brand']);
  });

  test('getAll returns newest first', () async {
    await repo.save(
      Asset(id: 'old', createdAt: DateTime(2025), updatedAt: DateTime(2025)),
    );
    await repo.save(
      Asset(
        id: 'new',
        createdAt: DateTime(2026, 6, 19),
        updatedAt: DateTime(2026, 6, 19),
      ),
    );
    expect(repo.getAll().first.id, 'new');
  });

  test('round-trips product photo and warranty documents', () async {
    final now = DateTime(2026, 4, 1);
    await repo.save(
      Asset(
        id: 'media',
        productPhotoPath: '/data/product.png',
        warrantyDocuments: const [
          AssetDocument(path: '/data/warranty.pdf', name: 'warranty.pdf'),
          AssetDocument(path: '/data/card.jpg', name: 'card.jpg'),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    );
    final reloaded = repo.getById('media')!;
    expect(reloaded.productPhotoPath, '/data/product.png');
    expect(reloaded.warrantyDocuments.length, 2);
    expect(reloaded.warrantyDocuments.first.name, 'warranty.pdf');
    expect(reloaded.warrantyDocuments.first.isPdf, isTrue);
    expect(reloaded.warrantyDocuments[1].isPdf, isFalse);
  });

  test('detects a PDF receipt and reports it via receiptIsPdf', () async {
    final now = DateTime(2026, 4, 2);
    await repo.save(
      Asset(
        id: 'pdf-receipt',
        receiptPhotoPath: '/data/receipt.PDF',
        createdAt: now,
        updatedAt: now,
      ),
    );
    final reloaded = repo.getById('pdf-receipt')!;
    expect(reloaded.hasReceipt, isTrue);
    expect(reloaded.receiptIsPdf, isTrue);
  });

  test('an image receipt is not flagged as a PDF', () {
    final now = DateTime(2026, 4, 3);
    final asset = Asset(
      id: 'img-receipt',
      receiptPhotoPath: '/data/receipt.jpg',
      createdAt: now,
      updatedAt: now,
    );
    expect(asset.hasReceipt, isTrue);
    expect(asset.receiptIsPdf, isFalse);
  });

  test('localFilePaths covers receipt, product photo, photos, warranty', () {
    final now = DateTime(2026, 4, 4);
    final asset = Asset(
      id: 'paths',
      receiptPhotoPath: '/data/receipt.pdf',
      productPhotoPath: '/data/product.jpg',
      warrantyDocuments: const [
        AssetDocument(path: '/data/w1.pdf', name: 'w1.pdf'),
      ],
      propertyValues: {'shot': const PhotoValue('/data/photo.png')},
      createdAt: now,
      updatedAt: now,
    );
    expect(
      asset.localFilePaths(),
      containsAll(<String>[
        '/data/receipt.pdf',
        '/data/product.jpg',
        '/data/photo.png',
        '/data/w1.pdf',
      ]),
    );
    expect(asset.localFilePaths().length, 4);
  });

  test('AssetDocument JSON round-trip preserves path and name', () {
    const doc = AssetDocument(path: '/data/manual.pdf', name: 'manual.pdf');
    final restored = AssetDocument.fromJson(doc.toJson());
    expect(restored.path, doc.path);
    expect(restored.name, doc.name);
    expect(restored.isPdf, isTrue);
  });
}

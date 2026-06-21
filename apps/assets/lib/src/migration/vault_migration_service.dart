import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../data/asset_repository.dart';
import '../data/category_type_repository.dart';
import '../models/asset.dart';
import '../models/category_type.dart';
import '../services/asset_image_store.dart';
import '../sync/assets_sync_schema.dart';
import 'asset_vault_bundle.dart';

/// Summary of an [VaultMigrationService.importFromFile] run.
class VaultImportResult {
  const VaultImportResult({
    required this.categoryTypes,
    required this.assets,
    required this.blobs,
  });

  final int categoryTypes;
  final int assets;
  final int blobs;
}

/// Cloud-independent export/import of the local vault as a single self-contained
/// bundle file. Covers users who never want an account but still want to move
/// data between apps or keep a backup.
class VaultMigrationService {
  VaultMigrationService({
    required AssetRepository assetRepository,
    required CategoryTypeRepository categoryTypeRepository,
    required AssetImageStore imageStore,
  }) : _assets = assetRepository,
       _categoryTypes = categoryTypeRepository,
       _imageStore = imageStore;

  final AssetRepository _assets;
  final CategoryTypeRepository _categoryTypes;
  final AssetImageStore _imageStore;

  /// Builds a bundle of all local data + referenced blobs and writes it to
  /// [destinationPath]. Returns the written file.
  Future<File> exportToFile(String destinationPath) async {
    final assets = _assets.getAll();
    final categoryTypes = _categoryTypes.getAll();

    final blobs = <String, String>{};
    for (final asset in assets) {
      for (final path in asset.localFilePaths()) {
        if (blobs.containsKey(path)) {
          continue;
        }
        final file = File(path);
        if (file.existsSync()) {
          blobs[path] = base64Encode(await file.readAsBytes());
        }
      }
    }

    final bundle = AssetVaultBundle(
      schemaVersion: AssetsSyncSchema.version,
      exportedAt: DateTime.now().toUtc(),
      categoryTypes: categoryTypes.map((t) => t.toJson()).toList(),
      assets: assets.map((a) => a.toJson()).toList(),
      blobs: blobs,
    );

    final file = File(destinationPath);
    await file.writeAsString(jsonEncode(bundle.toJson()));
    return file;
  }

  /// Reads a bundle from [path], rematerializes its blobs locally, and upserts
  /// its category types and assets through the repositories. Throws
  /// [FormatException] if the bundle is newer than this build understands.
  Future<VaultImportResult> importFromFile(String path) async {
    final raw = await File(path).readAsString();
    final bundle = AssetVaultBundle.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    if (!bundle.canImport) {
      throw FormatException(
        'Bundle schema v${bundle.schemaVersion} is newer than this app '
        'supports (v${AssetsSyncSchema.version}). Update the app to import it.',
      );
    }

    // Rematerialize blobs and build an old-path -> new-path remap.
    final remap = <String, String>{};
    for (final entry in bundle.blobs.entries) {
      final bytes = base64Decode(entry.value);
      final ext = p.extension(entry.key);
      remap[entry.key] = await _imageStore.saveBytes(
        bytes,
        ext.isEmpty ? '.bin' : ext,
      );
    }

    for (final json in bundle.categoryTypes) {
      await _categoryTypes.save(CategoryType.fromJson(json));
    }
    for (final json in bundle.assets) {
      await _assets.save(Asset.fromJson(_remapPaths(json, remap)));
    }

    return VaultImportResult(
      categoryTypes: bundle.categoryTypes.length,
      assets: bundle.assets.length,
      blobs: bundle.blobs.length,
    );
  }

  /// Returns a copy of an asset JSON with every embedded blob path rewritten via
  /// [remap]; paths not present in the map are left unchanged.
  static Map<String, dynamic> _remapPaths(
    Map<String, dynamic> assetJson,
    Map<String, String> remap,
  ) {
    final copy = Map<String, dynamic>.of(assetJson);
    copy['receiptPhotoPath'] = _remap(copy['receiptPhotoPath'], remap);
    copy['productPhotoPath'] = _remap(copy['productPhotoPath'], remap);

    final docs = copy['warrantyDocuments'];
    if (docs is List) {
      copy['warrantyDocuments'] = docs.map((d) {
        final doc = Map<String, dynamic>.of((d as Map).cast<String, dynamic>());
        doc['path'] = _remap(doc['path'], remap);
        return doc;
      }).toList();
    }

    final values = copy['propertyValues'];
    if (values is Map) {
      copy['propertyValues'] = values.map((key, value) {
        final v = Map<String, dynamic>.of(
          (value as Map).cast<String, dynamic>(),
        );
        if (v['kind'] == 'photo') {
          v['value'] = _remap(v['value'], remap);
        }
        return MapEntry(key, v);
      });
    }
    return copy;
  }

  static dynamic _remap(dynamic value, Map<String, String> remap) {
    if (value is String && remap.containsKey(value)) {
      return remap[value];
    }
    return value;
  }
}

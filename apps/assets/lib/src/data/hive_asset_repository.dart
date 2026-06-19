import 'dart:convert';

import '../models/asset.dart';
import 'asset_repository.dart';
import 'asset_storage.dart';

class HiveAssetRepository implements AssetRepository {
  HiveAssetRepository(this._storage);

  final AppStorage _storage;

  @override
  List<Asset> getAll() {
    final assets = _storage.assetBox.values
        .map((raw) => Asset.fromJson(jsonDecode(raw) as Map<String, dynamic>))
        .toList();
    assets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return assets;
  }

  @override
  Asset? getById(String id) {
    final raw = _storage.assetBox.get(id);
    if (raw == null) {
      return null;
    }
    return Asset.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(Asset asset) async {
    await _storage.assetBox.put(asset.id, jsonEncode(asset.toJson()));
  }

  @override
  Future<void> delete(String id) async {
    await _storage.assetBox.delete(id);
  }
}

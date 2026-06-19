import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/asset_repository.dart';
import '../data/hive_asset_repository.dart';
import '../models/asset.dart';
import '../services/asset_image_store.dart';
import '../services/property_value_suggestions.dart';
import 'category_type_providers.dart';

final assetImageStoreProvider = Provider<AssetImageStore>((ref) {
  return AssetImageStore();
});

final propertyValueSuggestionsProvider = Provider<PropertyValueSuggestions>((
  ref,
) {
  return const PropertyValueSuggestions();
});

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return HiveAssetRepository(ref.watch(appStorageProvider));
});

final assetsProvider = StateNotifierProvider<AssetNotifier, List<Asset>>((ref) {
  return AssetNotifier(
    ref.watch(assetRepositoryProvider),
    ref.watch(assetImageStoreProvider),
  );
});

/// Looks up a single asset by id from the in-memory list.
final assetByIdProvider = Provider.family<Asset?, String>((ref, id) {
  for (final asset in ref.watch(assetsProvider)) {
    if (asset.id == id) {
      return asset;
    }
  }
  return null;
});

class AssetNotifier extends StateNotifier<List<Asset>> {
  AssetNotifier(this._repository, this._imageStore) : super(const <Asset>[]) {
    _load();
  }

  final AssetRepository _repository;
  final AssetImageStore _imageStore;

  void _load() {
    state = _repository.getAll();
  }

  Future<void> save(Asset asset) async {
    await _repository.save(asset);
    _load();
  }

  Future<void> delete(String id) async {
    final existing = _repository.getById(id);
    await _repository.delete(id);
    if (existing != null) {
      await _imageStore.deleteAll(existing.imagePaths());
    }
    _load();
  }
}

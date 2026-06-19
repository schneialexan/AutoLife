import '../models/asset.dart';

/// Read/write access to persisted [Asset]s.
abstract class AssetRepository {
  List<Asset> getAll();

  Asset? getById(String id);

  Future<void> save(Asset asset);

  Future<void> delete(String id);
}

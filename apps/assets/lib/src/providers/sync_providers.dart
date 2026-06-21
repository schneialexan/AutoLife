import 'package:autolife_platform/autolife_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/hive_asset_repository.dart';
import '../data/hive_category_type_repository.dart';
import '../sync/assets_sync_gateway.dart';
import '../sync/assets_sync_schema.dart';
import '../sync/blob_payload_rewriter.dart';
import 'asset_providers.dart';
import 'category_type_providers.dart';

/// Builds the [AssetsSyncGateway] and registers it with the platform
/// coordinator. Returns true when a remote gateway was registered (i.e. sync is
/// configured). Watched once from the app root so registration happens on
/// startup. A no-op (returns false) in local-only builds.
final assetsSyncBootstrapProvider = Provider<bool>((ref) {
  final platform = ref.watch(autolifePlatformProvider);
  final client = platform.client;
  if (client == null) {
    return false;
  }

  final storage = ref.watch(appStorageProvider);
  final imageStore = ref.watch(assetImageStoreProvider);
  final blobSync = platform.blobSync;

  final gateway = AssetsSyncGateway(
    assetRepository: HiveAssetRepository(storage),
    categoryTypeRepository: HiveCategoryTypeRepository(storage),
    itemsTable: SupabaseModuleTable(
      client,
      schema: AssetsSyncSchema.moduleId,
      table: 'items',
    ),
    categoryTypesTable: SupabaseModuleTable(
      client,
      schema: AssetsSyncSchema.moduleId,
      table: 'category_types',
    ),
    deviceId: platform.deviceId,
    imageStore: imageStore,
    blobRewriter: blobSync == null
        ? null
        : BlobPayloadRewriter(blobSync: blobSync, imageStore: imageStore),
    onLocalDataChanged: () {
      ref.read(assetsProvider.notifier).reload();
      ref.read(categoryTypesProvider.notifier).reload();
    },
  );

  platform.registerGateway(gateway);
  return true;
});

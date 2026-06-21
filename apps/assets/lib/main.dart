import 'package:autolife_platform/autolife_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/data/asset_storage.dart';
import 'src/data/hive_asset_repository.dart';
import 'src/data/hive_category_type_repository.dart';
import 'src/data/syncing_asset_repository.dart';
import 'src/data/syncing_category_type_repository.dart';
import 'src/providers/asset_providers.dart';
import 'src/providers/category_type_providers.dart';
import 'src/sync/sync_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await AppStorage.open();
  await HiveCategoryTypeRepository(storage).seedDefaults();

  final platform = await AutolifePlatform.initialize(
    supabaseUrl: SyncConfig.supabaseUrl,
    supabaseAnonKey: SyncConfig.supabaseAnonKey,
  );

  runApp(
    ProviderScope(
      overrides: [
        appStorageProvider.overrideWithValue(storage),
        autolifePlatformProvider.overrideWithValue(platform),
        // Hive stays the source of truth; the decorators enqueue outbox entries
        // and kick a sync on every write.
        assetRepositoryProvider.overrideWith((ref) {
          return SyncingAssetRepository(
            HiveAssetRepository(ref.watch(appStorageProvider)),
            outbox: platform.outbox,
            deviceId: platform.deviceId,
            onMutation: platform.coordinator.syncNow,
          );
        }),
        categoryTypeRepositoryProvider.overrideWith((ref) {
          return SyncingCategoryTypeRepository(
            HiveCategoryTypeRepository(ref.watch(appStorageProvider)),
            outbox: platform.outbox,
            deviceId: platform.deviceId,
            onMutation: platform.coordinator.syncNow,
          );
        }),
      ],
      child: const AutoAssetsApp(),
    ),
  );
}

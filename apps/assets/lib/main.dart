import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/data/asset_storage.dart';
import 'src/data/hive_category_type_repository.dart';
import 'src/providers/category_type_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await AppStorage.open();
  await HiveCategoryTypeRepository(storage).seedDefaults();
  runApp(
    ProviderScope(
      overrides: [appStorageProvider.overrideWithValue(storage)],
      child: const AutoAssetsApp(),
    ),
  );
}

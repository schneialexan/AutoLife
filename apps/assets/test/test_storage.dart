import 'dart:io';

import 'package:auto_assets/src/data/asset_storage.dart';
import 'package:hive/hive.dart';

/// Opens an [AppStorage] backed by a fresh on-disk Hive instance in a temp
/// directory. Call [closeTestStorage] in tearDown to wipe state between tests.
Future<AppStorage> openTestStorage() async {
  final dir = await Directory.systemTemp.createTemp('autoassets_test');
  Hive.init(dir.path);
  return AppStorage(
    assetBox: await Hive.openBox<String>(AppStorage.assetBoxName),
    categoryTypeBox: await Hive.openBox<String>(AppStorage.categoryTypeBoxName),
    metaBox: await Hive.openBox<dynamic>(AppStorage.metaBoxName),
  );
}

Future<void> closeTestStorage() async {
  await Hive.deleteFromDisk();
  await Hive.close();
}

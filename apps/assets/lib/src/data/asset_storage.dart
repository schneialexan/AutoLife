import 'package:hive_flutter/hive_flutter.dart';

/// Owns Hive initialization and the app's three boxes. Values are stored as
/// JSON-encoded strings keyed by id, so no TypeAdapter / `build_runner` is
/// needed.
class AppStorage {
  AppStorage({
    required this.assetBox,
    required this.categoryTypeBox,
    required this.metaBox,
  });

  static const String assetBoxName = 'assets';
  static const String categoryTypeBoxName = 'category_types';
  static const String metaBoxName = 'app_meta';

  /// Meta key guarding the one-time starter seed.
  static const String seededKey = 'seeded_v1';

  final Box<String> assetBox;
  final Box<String> categoryTypeBox;
  final Box<dynamic> metaBox;

  static Future<AppStorage> open() async {
    await Hive.initFlutter();
    final assetBox = await Hive.openBox<String>(assetBoxName);
    final categoryTypeBox = await Hive.openBox<String>(categoryTypeBoxName);
    final metaBox = await Hive.openBox<dynamic>(metaBoxName);
    return AppStorage(
      assetBox: assetBox,
      categoryTypeBox: categoryTypeBox,
      metaBox: metaBox,
    );
  }
}

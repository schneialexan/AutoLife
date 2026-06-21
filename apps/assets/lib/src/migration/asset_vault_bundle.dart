import '../sync/assets_sync_schema.dart';

/// A portable, cloud-independent export of a local vault: category types,
/// assets, and their referenced blobs (base64-inlined so the bundle is a single
/// self-contained file). Stamped with [schemaVersion] so the importing app can
/// refuse a bundle it doesn't understand (forward/backward version safety).
class AssetVaultBundle {
  const AssetVaultBundle({
    required this.schemaVersion,
    required this.exportedAt,
    required this.categoryTypes,
    required this.assets,
    required this.blobs,
  });

  static const String format = 'autoassets.bundle';

  final int schemaVersion;
  final DateTime exportedAt;

  /// Raw `CategoryType.toJson()` maps.
  final List<Map<String, dynamic>> categoryTypes;

  /// Raw `Asset.toJson()` maps.
  final List<Map<String, dynamic>> assets;

  /// Original local file path -> base64-encoded bytes.
  final Map<String, String> blobs;

  /// Whether this build can import a bundle at [schemaVersion].
  bool get canImport => schemaVersion <= AssetsSyncSchema.version;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'format': format,
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt.toIso8601String(),
    'categoryTypes': categoryTypes,
    'assets': assets,
    'blobs': blobs,
  };

  factory AssetVaultBundle.fromJson(Map<String, dynamic> json) {
    if (json['format'] != format) {
      throw const FormatException('Not an AutoAssets bundle.');
    }
    final rawCategories = (json['categoryTypes'] as List?) ?? const <dynamic>[];
    final rawAssets = (json['assets'] as List?) ?? const <dynamic>[];
    final rawBlobs = (json['blobs'] as Map?) ?? const <dynamic, dynamic>{};
    return AssetVaultBundle(
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      categoryTypes: rawCategories
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList(),
      assets: rawAssets.map((e) => (e as Map).cast<String, dynamic>()).toList(),
      blobs: rawBlobs.map(
        (key, value) => MapEntry(key as String, value as String),
      ),
    );
  }
}

import 'dart:io';

import 'package:autolife_platform/autolife_platform.dart';

import '../services/asset_image_store.dart';
import 'assets_sync_schema.dart';

/// Rewrites the local file paths embedded in an [Asset] payload to/from
/// Supabase Storage keys so synced devices can share receipts/photos/docs.
///
/// Remote keys are tagged with the [scheme] prefix to distinguish them from
/// on-device paths. Rewriting is best-effort: a missing local file or failed
/// download leaves the original value untouched rather than dropping data.
class BlobPayloadRewriter {
  BlobPayloadRewriter({
    required BlobSyncService blobSync,
    required AssetImageStore imageStore,
  }) : _blob = blobSync,
       _imageStore = imageStore;

  static const String scheme = 'blob://';

  final BlobSyncService _blob;
  final AssetImageStore _imageStore;

  /// Uploads any local blobs in [payload] and returns a copy with their paths
  /// replaced by storage keys.
  Future<Map<String, dynamic>> toRemote(
    Map<String, dynamic> payload,
    String recordId,
  ) async {
    final copy = Map<String, dynamic>.of(payload);
    copy['receiptPhotoPath'] = await _upload(
      copy['receiptPhotoPath'] as String?,
      recordId,
    );
    copy['productPhotoPath'] = await _upload(
      copy['productPhotoPath'] as String?,
      recordId,
    );
    copy['warrantyDocuments'] = await _mapDocuments(
      copy['warrantyDocuments'],
      recordId,
      _upload,
    );
    copy['propertyValues'] = await _mapPhotoValues(
      copy['propertyValues'],
      recordId,
      _upload,
    );
    return copy;
  }

  /// Downloads any storage-key blobs in [payload] and returns a copy with their
  /// keys replaced by fresh local paths.
  Future<Map<String, dynamic>> toLocal(
    Map<String, dynamic> payload,
    String recordId,
  ) async {
    final copy = Map<String, dynamic>.of(payload);
    copy['receiptPhotoPath'] = await _download(
      copy['receiptPhotoPath'] as String?,
      recordId,
    );
    copy['productPhotoPath'] = await _download(
      copy['productPhotoPath'] as String?,
      recordId,
    );
    copy['warrantyDocuments'] = await _mapDocuments(
      copy['warrantyDocuments'],
      recordId,
      _download,
    );
    copy['propertyValues'] = await _mapPhotoValues(
      copy['propertyValues'],
      recordId,
      _download,
    );
    return copy;
  }

  Future<String?> _upload(String? path, String recordId) async {
    if (path == null || path.isEmpty || path.startsWith(scheme)) {
      return path;
    }
    if (!File(path).existsSync()) {
      return path;
    }
    final key = await _blob.upload(
      localPath: path,
      moduleId: AssetsSyncSchema.moduleId,
      recordId: recordId,
    );
    return '$scheme$key';
  }

  Future<String?> _download(String? value, String recordId) async {
    if (value == null || value.isEmpty || !value.startsWith(scheme)) {
      return value;
    }
    final key = value.substring(scheme.length);
    final dir = await _imageStore.directoryPath();
    final local = await _blob.downloadToLocal(
      storageKey: key,
      destinationDir: dir,
    );
    return local ?? value;
  }

  Future<List<dynamic>> _mapDocuments(
    dynamic raw,
    String recordId,
    Future<String?> Function(String?, String) transform,
  ) async {
    if (raw is! List) {
      return const <dynamic>[];
    }
    final result = <dynamic>[];
    for (final entry in raw) {
      final doc = Map<String, dynamic>.of(
        (entry as Map).cast<String, dynamic>(),
      );
      doc['path'] = await transform(doc['path'] as String?, recordId);
      result.add(doc);
    }
    return result;
  }

  Future<Map<String, dynamic>> _mapPhotoValues(
    dynamic raw,
    String recordId,
    Future<String?> Function(String?, String) transform,
  ) async {
    if (raw is! Map) {
      return <String, dynamic>{};
    }
    final result = <String, dynamic>{};
    for (final entry in raw.entries) {
      final value = Map<String, dynamic>.of(
        (entry.value as Map).cast<String, dynamic>(),
      );
      if (value['kind'] == 'photo') {
        value['value'] = await transform(value['value'] as String?, recordId);
      }
      result[entry.key as String] = value;
    }
    return result;
  }
}

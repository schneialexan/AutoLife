import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Uploads/downloads local files referenced in payloads to a **private**
/// Supabase Storage bucket, keyed `{user_id}/{module}/{record_id}/{filename}`.
/// Access is via signed URLs only; there is no public read.
abstract class BlobSyncService {
  /// Uploads [localPath] and returns its storage key. Idempotent (upsert).
  Future<String> upload({
    required String localPath,
    required String moduleId,
    required String recordId,
  });

  /// Downloads the object at [storageKey] into [destinationDir] and returns the
  /// new local path, or null on failure.
  Future<String?> downloadToLocal({
    required String storageKey,
    required String destinationDir,
  });

  Future<void> delete(String storageKey);
}

class SupabaseBlobSyncService implements BlobSyncService {
  SupabaseBlobSyncService(
    this._client, {
    required String Function() currentUserId,
    this.bucket = defaultBucket,
  }) : _currentUserId = currentUserId;

  static const String defaultBucket = 'user-files';

  final sb.SupabaseClient _client;
  final String Function() _currentUserId;
  final String bucket;

  sb.StorageFileApi get _store => _client.storage.from(bucket);

  @override
  Future<String> upload({
    required String localPath,
    required String moduleId,
    required String recordId,
  }) async {
    final file = File(localPath);
    final filename = p.basename(localPath);
    final key = '${_currentUserId()}/$moduleId/$recordId/$filename';
    await _store.uploadBinary(
      key,
      await file.readAsBytes(),
      fileOptions: const sb.FileOptions(upsert: true),
    );
    return key;
  }

  @override
  Future<String?> downloadToLocal({
    required String storageKey,
    required String destinationDir,
  }) async {
    try {
      final bytes = await _store.download(storageKey);
      final dir = Directory(destinationDir);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      final destination = p.join(destinationDir, p.basename(storageKey));
      await File(destination).writeAsBytes(bytes);
      return destination;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String storageKey) async {
    try {
      await _store.remove(<String>[storageKey]);
    } catch (_) {
      // Best-effort: a missing object is already in the desired state.
    }
  }
}

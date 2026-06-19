import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies picked images into app-private storage and removes orphans when a
/// photo is cleared, replaced, or its asset is deleted.
class AssetImageStore {
  AssetImageStore({Directory? baseDirectory}) : _baseDirectory = baseDirectory;

  static const String _subdir = 'asset_images';

  Directory? _baseDirectory;

  Future<Directory> _imagesDir() async {
    final base = _baseDirectory ??= await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, _subdir));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copies [sourcePath] into app storage and returns the new local path.
  Future<String> saveImage(String sourcePath) async {
    final dir = await _imagesDir();
    final ext = p.extension(sourcePath);
    final filename = '${DateTime.now().microsecondsSinceEpoch}$ext';
    final destination = p.join(dir.path, filename);
    await File(sourcePath).copy(destination);
    return destination;
  }

  /// Deletes the file at [path] if it exists. Safe to call with null/empty.
  Future<void> delete(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Deletes any number of image paths, ignoring missing files.
  Future<void> deleteAll(Iterable<String> paths) async {
    for (final path in paths) {
      await delete(path);
    }
  }
}

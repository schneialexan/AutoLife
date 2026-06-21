import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies picked images and documents into app-private storage and removes
/// orphans when a file is cleared, replaced, or its asset is deleted.
class AssetImageStore {
  AssetImageStore({Directory? baseDirectory, http.Client? httpClient})
    : _baseDirectory = baseDirectory,
      _httpClient = httpClient ?? http.Client();

  static const String _subdir = 'asset_images';

  Directory? _baseDirectory;
  final http.Client _httpClient;

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

  /// Copies any picked file (PDF or image) into app storage by extension and
  /// returns the new local path.
  Future<String> saveFile(String sourcePath) async {
    final dir = await _imagesDir();
    final ext = p.extension(sourcePath);
    final filename = '${DateTime.now().microsecondsSinceEpoch}$ext';
    final destination = p.join(dir.path, filename);
    await File(sourcePath).copy(destination);
    return destination;
  }

  /// Downloads an image from [url], validates it is a JPEG or PNG, writes it
  /// locally, and returns the new path. Returns null on any failure.
  Future<String?> saveImageFromUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || !uri.host.isNotEmpty) {
      return null;
    }
    try {
      final response = await _httpClient.get(uri);
      if (response.statusCode != 200) {
        return null;
      }
      final bytes = response.bodyBytes;
      final ext = _imageExtension(bytes, response.headers['content-type']);
      if (ext == null) {
        return null;
      }
      final dir = await _imagesDir();
      final filename = '${DateTime.now().microsecondsSinceEpoch}$ext';
      final destination = p.join(dir.path, filename);
      await File(destination).writeAsBytes(bytes);
      return destination;
    } catch (_) {
      return null;
    }
  }

  /// Detects JPEG/PNG from magic bytes (falling back to content-type), or null
  /// when the payload is neither.
  String? _imageExtension(Uint8List bytes, String? contentType) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return '.jpg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return '.png';
    }
    final type = contentType?.toLowerCase() ?? '';
    if (type.contains('jpeg') || type.contains('jpg')) {
      return '.jpg';
    }
    if (type.contains('png')) {
      return '.png';
    }
    return null;
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

import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

/// Owns the platform's **encrypted** Hive boxes (outbox + sync meta/cursors).
///
/// The AES key lives in [FlutterSecureStorage]; sensitive queued payloads
/// (serials, receipts) are therefore never stored in plaintext on device.
/// Assumes Hive has already been initialised by the host app
/// (`Hive.initFlutter()`), so a single Hive instance is shared.
class PlatformStorage {
  PlatformStorage({required this.outboxBox, required this.metaBox});

  static const String outboxBoxName = 'sync_outbox';
  static const String metaBoxName = 'sync_meta';
  static const String _secureKeyName = 'autolife_platform_hive_key_v1';

  final Box<String> outboxBox;
  final Box<String> metaBox;

  static Future<PlatformStorage> open({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) async {
    final key = await _resolveEncryptionKey(secureStorage);
    final cipher = HiveAesCipher(key);
    final outboxBox = await Hive.openBox<String>(
      outboxBoxName,
      encryptionCipher: cipher,
    );
    final metaBox = await Hive.openBox<String>(
      metaBoxName,
      encryptionCipher: cipher,
    );
    return PlatformStorage(outboxBox: outboxBox, metaBox: metaBox);
  }

  static Future<List<int>> _resolveEncryptionKey(
    FlutterSecureStorage secureStorage,
  ) async {
    final existing = await secureStorage.read(key: _secureKeyName);
    if (existing != null) {
      return base64Decode(existing);
    }
    final key = _generateKey();
    await secureStorage.write(key: _secureKeyName, value: base64Encode(key));
    return key;
  }

  static List<int> _generateKey() {
    final random = Random.secure();
    return List<int>.generate(32, (_) => random.nextInt(256));
  }

  Future<void> close() async {
    await outboxBox.close();
    await metaBox.close();
  }
}

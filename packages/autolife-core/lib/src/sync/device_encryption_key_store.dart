import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists a random 256-bit DEK in the platform keychain (see contract doc).
class DeviceEncryptionKeyStore {
  DeviceEncryptionKeyStore({
    FlutterSecureStorage? storage,
    this.storageKey = _defaultKey,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  final String storageKey;

  static const _defaultKey = 'autolife_offline_dek_v1';

  Future<SecretKey> loadOrCreate() async {
    final b64 = await _storage.read(key: storageKey);
    if (b64 != null && b64.isNotEmpty) {
      return SecretKey(base64Decode(b64));
    }
    final rnd = Random.secure();
    final raw = Uint8List(32);
    for (var i = 0; i < raw.length; i++) {
      raw[i] = rnd.nextInt(256);
    }
    await _storage.write(key: storageKey, value: base64Encode(raw));
    return SecretKey(raw);
  }
}

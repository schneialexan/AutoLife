import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Key/value persistence for [BiometricLockService] (secure storage in production).
abstract class SecurePrefsStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

final class FlutterSecurePrefsStore implements SecurePrefsStore {
  FlutterSecurePrefsStore([FlutterSecureStorage? inner])
    : _inner = inner ?? const FlutterSecureStorage();

  final FlutterSecureStorage _inner;

  @override
  Future<String?> read(String key) => _inner.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _inner.write(key: key, value: value);
}

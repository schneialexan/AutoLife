import 'dart:convert';

import '../common/failure.dart';
import '../common/result.dart';
import 'local_auth_facade.dart';
import 'privacy_events.dart';
import 'secure_prefs_store.dart';

/// Persists per-module biometric gates and runs `local_auth` prompts.
final class BiometricLockService {
  BiometricLockService({
    SecurePrefsStore? prefs,
    LocalAuthFacade? localAuth,
    void Function(PrivacyTelemetryEvent event)? onTelemetry,
  }) : _prefs = prefs ?? FlutterSecurePrefsStore(),
       _localAuth = localAuth ?? DefaultLocalAuthFacade(),
       _onTelemetry = onTelemetry;

  static const _storageKey = 'autolife.privacy.biometric_locks.v1';

  final SecurePrefsStore _prefs;
  final LocalAuthFacade _localAuth;
  final void Function(PrivacyTelemetryEvent event)? _onTelemetry;

  /// When false, [lock] succeeds without prompting (module not opted in).
  Future<Result<bool>> isLockEnabled(String moduleId) async {
    final map = await _loadMap();
    return Result.success(map[moduleId] == true);
  }

  Future<Result<void>> setLockEnabled(String moduleId, bool enabled) async {
    final map = await _loadMap();
    map[moduleId] = enabled;
    await _prefs.write(_storageKey, jsonEncode(map));
    return const Result.success(null);
  }

  /// Prompts biometric / device credentials when the module lock is enabled.
  Future<Result<void>> lock(
    String moduleId, {
    String localizedReason = 'Authenticate to view this protected content.',
  }) async {
    final map = await _loadMap();
    if (map[moduleId] != true) {
      return const Result.success(null);
    }

    final supported = await _localAuth.isDeviceSupported();
    if (!supported) {
      _emitLockFailed(moduleId);
      return Result.failure(
        Failure(
          code: 'biometric_unsupported',
          message: 'This device cannot show a lock prompt.',
        ),
      );
    }

    final ok = await _localAuth.authenticate(
      localizedReason: localizedReason,
      biometricOnly: false,
    );
    if (ok) {
      return const Result.success(null);
    }

    _emitLockFailed(moduleId);
    return Result.failure(
      Failure(
        code: 'biometric_failed',
        message: 'Authentication was not completed.',
      ),
    );
  }

  void _emitLockFailed(String moduleId) {
    _onTelemetry?.call(PrivacyLockFailed(moduleId));
  }

  Future<Map<String, bool>> _loadMap() async {
    final raw = await _prefs.read(_storageKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      final out = <String, bool>{};
      for (final e in decoded.entries) {
        if (e.value is bool) {
          out[e.key] = e.value as bool;
        }
      }
      return out;
    } catch (_) {
      return {};
    }
  }
}

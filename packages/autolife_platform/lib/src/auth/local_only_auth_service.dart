import 'dart:async';

import 'auth_service.dart';

/// [AuthService] used when no Supabase config is supplied. The app stays fully
/// usable offline; any attempt to sign in reports that sync is not configured.
class LocalOnlyAuthService implements AuthService {
  @override
  PlatformAuthState get state => PlatformAuthState.localOnly;

  @override
  String? get userId => null;

  @override
  Stream<PlatformAuthState> get stateChanges =>
      const Stream<PlatformAuthState>.empty();

  @override
  Future<void> signUp({required String email, required String password}) async {
    throw const AuthException(
      'Sync is not configured for this build.',
      code: 'sync_not_configured',
    );
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    throw const AuthException(
      'Sync is not configured for this build.',
      code: 'sync_not_configured',
    );
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<PairingCode> startDevicePairing() async {
    throw const AuthException(
      'Sync is not configured for this build.',
      code: 'sync_not_configured',
    );
  }

  @override
  Future<void> completeDevicePairing(String code) async {
    throw const AuthException(
      'Sync is not configured for this build.',
      code: 'sync_not_configured',
    );
  }
}

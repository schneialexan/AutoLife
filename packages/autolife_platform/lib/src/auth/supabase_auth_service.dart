import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'auth_service.dart';

/// [AuthService] backed by `supabase_flutter`. Sessions and refresh are handled
/// by the SDK (tokens persisted in its secure storage). Device pairing calls
/// the `pair-device` Edge Function — the service-role key never reaches the
/// client.
class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client) {
    _authSub = _client.auth.onAuthStateChange.listen((data) {
      _stateController.add(state);
    });
  }

  final sb.SupabaseClient _client;
  final StreamController<PlatformAuthState> _stateController =
      StreamController<PlatformAuthState>.broadcast();
  late final StreamSubscription<sb.AuthState> _authSub;

  @override
  PlatformAuthState get state => _client.auth.currentSession == null
      ? PlatformAuthState.localOnly
      : PlatformAuthState.authenticated;

  @override
  String? get userId => _client.auth.currentUser?.id;

  @override
  Stream<PlatformAuthState> get stateChanges => _stateController.stream;

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _client.auth.signUp(email: email, password: password);
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, code: e.code);
    }
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, code: e.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<PairingCode> startDevicePairing() async {
    if (state != PlatformAuthState.authenticated) {
      throw const AuthException(
        'Must be signed in to start pairing.',
        code: 'not_authenticated',
      );
    }
    try {
      final res = await _client.functions.invoke(
        'pair-device',
        body: <String, dynamic>{'action': 'start'},
      );
      final data = (res.data as Map).cast<String, dynamic>();
      return PairingCode(
        code: data['code'] as String,
        expiresAt: DateTime.parse(data['expires_at'] as String),
      );
    } on sb.FunctionException catch (e) {
      throw AuthException(
        'Could not create pairing code: ${e.details ?? e.reasonPhrase}',
        code: 'pairing_start_failed',
      );
    }
  }

  @override
  Future<void> completeDevicePairing(String code) async {
    final sanitized = code.trim().toUpperCase();
    if (sanitized.isEmpty) {
      throw const AuthException('Enter a pairing code.', code: 'empty_code');
    }
    try {
      final res = await _client.functions.invoke(
        'pair-device',
        body: <String, dynamic>{'action': 'complete', 'code': sanitized},
      );
      final data = (res.data as Map).cast<String, dynamic>();
      final email = data['email'] as String;
      final token = data['token'] as String;
      await _client.auth.verifyOTP(
        type: sb.OtpType.magiclink,
        email: email,
        token: token,
      );
    } on sb.FunctionException {
      throw const AuthException(
        'Pairing code is invalid, used, or expired.',
        code: 'pairing_invalid',
      );
    } on sb.AuthException catch (e) {
      throw AuthException(e.message, code: e.code);
    }
  }

  Future<void> dispose() async {
    await _authSub.cancel();
    await _stateController.close();
  }
}

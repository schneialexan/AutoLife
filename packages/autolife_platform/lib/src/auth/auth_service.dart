/// Whether the platform currently has an authenticated Supabase session.
///
/// `localOnly` is the default for a never-signed-in device: the app is fully
/// usable, outbox entries accumulate, and the coordinator no-ops.
enum PlatformAuthState { localOnly, authenticated }

/// A short-lived, high-entropy device-pairing code shown to the user on the
/// already-signed-in device. The plaintext lives only on that device; the
/// server stores a hash.
class PairingCode {
  const PairingCode({required this.code, required this.expiresAt});

  final String code;
  final DateTime expiresAt;
}

/// Raised when an auth or pairing operation fails. [code] is a stable machine
/// string (e.g. `invalid_credentials`, `pairing_invalid`).
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AuthException(${code ?? 'error'}): $message';
}

/// Account + device-linking surface. Email/password is the primary multi-device
/// path; device pairing is an optional convenience implemented via a
/// service-role Edge Function (the client never mints sessions).
abstract class AuthService {
  PlatformAuthState get state;

  /// `auth.uid()` of the active session, or null when local-only.
  String? get userId;

  /// Emits whenever [state] changes (sign-in / sign-out / token refresh).
  Stream<PlatformAuthState> get stateChanges;

  Future<void> signUp({required String email, required String password});

  Future<void> signIn({required String email, required String password});

  /// Ends the session but **keeps** all local Hive data; sync simply stops.
  Future<void> signOut();

  /// Generates a high-entropy, short-TTL, single-use pairing code on this
  /// (authenticated) device, stored hashed server-side.
  Future<PairingCode> startDevicePairing();

  /// Redeems [code] on a fresh device via the service-role Edge Function and
  /// exchanges the returned one-time token for this device's own session.
  Future<void> completeDevicePairing(String code);
}

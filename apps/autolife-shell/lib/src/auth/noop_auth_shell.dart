import 'package:autolife_core/autolife_core.dart';
import 'package:supabase/supabase.dart' hide AuthUser;

/// Placeholder [`AuthService`] when the shell runs without Supabase bindings.
///
/// Offline demos keep working without Riverpod overrides.
final class ShellNoopAuthService implements AuthService {
  ShellNoopAuthService() {
    _state = AutoLifeAuthState(
      phase: AutoLifeAuthPhase.unauthenticated,
      updatedAtUtc: DateTime.now().toUtc(),
    );
  }

  late AutoLifeAuthState _state;

  @override
  AutoLifeAuthState get currentState => _state;

  @override
  Stream<AutoLifeAuthState> get authStates =>
      Stream<AutoLifeAuthState>.fromIterable(<AutoLifeAuthState>[_state]);

  @override
  Future<void> initialize() async {}

  @override
  Future<Result<String>> oauthAuthorizeUrl({
    required OAuthProvider provider,
    required String redirectTo,
    String scopes = '',
    bool skipBrowserRedirect = true,
  }) async => Result.failure(Failure(code: 'auth_disabled'));

  @override
  Future<Result<void>> completeAuthRedirect(Uri uri) async =>
      Result.failure(Failure(code: 'auth_disabled'));

  @override
  Future<Result<void>> logoutAllDevices() async => const Result.success(null);

  @override
  Future<Result<void>> logoutCurrentSession() async =>
      const Result.success(null);

  @override
  Future<Result<void>> refreshSessionExplicit() async =>
      const Result.success(null);

  @override
  Future<Result<void>> requestPasswordResetEmail({
    required String email,
    required String redirectTo,
  }) async => Result.failure(Failure(code: 'auth_disabled'));

  @override
  Future<Result<void>> signInWithPassword({
    required String email,
    required String password,
  }) async => Result.failure(Failure(code: 'auth_disabled'));

  @override
  Future<Result<void>> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
    String? emailRedirectTo,
  }) async => Result.failure(Failure(code: 'auth_disabled'));

  @override
  Future<Result<void>> updatePassword(String newPassword) async =>
      Result.failure(Failure(code: 'auth_disabled'));

  @override
  void dispose() {}
}

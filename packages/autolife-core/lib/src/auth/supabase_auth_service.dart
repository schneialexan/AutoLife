import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import 'package:supabase/supabase.dart' hide AuthUser;

import '../common/failure.dart';
import '../common/result.dart';
import 'auth_service.dart';
import 'models/auth_error.dart';
import 'models/auth_session.dart';
import 'models/auth_user.dart';

/// Store PKCE material for GoTrue (required when [AuthFlowType.pkce] is enabled).
///
/// Implemented with Flutter Secure Storage consistent with `.cursor`/offline sync conventions.
final class FlutterSecureGotrueStorage implements GotrueAsyncStorage {
  FlutterSecureGotrueStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> getItem({required String key}) => _storage.read(key: key);

  @override
  Future<void> setItem({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> removeItem({required String key}) => _storage.delete(key: key);
}

/// Persisted Gotrue [`Session`] JSON for cold starts.
abstract interface class PersistentAuthSessionRepository {
  Future<String?> loadSessionJson();

  Future<void> persistSessionJson(String raw);

  Future<void> clear();
}

final class SecurePersistentAuthSessionRepository
    implements PersistentAuthSessionRepository {
  SecurePersistentAuthSessionRepository({
    FlutterSecureStorage? storage,
    this.storageKey = 'autolife_supabase_auth_session_v1',
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  final String storageKey;

  @override
  Future<String?> loadSessionJson() => _storage.read(key: storageKey);

  @override
  Future<void> persistSessionJson(String raw) =>
      _storage.write(key: storageKey, value: raw);

  @override
  Future<void> clear() => _storage.delete(key: storageKey);
}

/// Non-persistent test double (in-memory blob).
final class MemoryPersistentAuthSessionRepository
    implements PersistentAuthSessionRepository {
  String? _blob;

  @override
  Future<void> clear() async {
    _blob = null;
  }

  @override
  Future<String?> loadSessionJson() async => _blob;

  @override
  Future<void> persistSessionJson(String raw) async {
    _blob = raw;
  }
}

/// PKCE verifier storage purely in-memory (unit tests).
final class MemoryGotrueStorage implements GotrueAsyncStorage {
  final Map<String, String> _backing = {};

  @override
  Future<String?> getItem({required String key}) async => _backing[key];

  @override
  Future<void> removeItem({required String key}) async {
    _backing.remove(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    _backing[key] = value;
  }
}

/// Builds a PKCE-ready [SupabaseClient] + matching [SupabaseAuthService].
abstract final class AutoLifeSupabaseBootstrap {
  /// Production-style wiring: anon or service-role key drives API permissions.
  ///
  /// [testPkce] replaces Flutter secure storage-backed PKCE in tests where a
  /// platform plugin is unavailable or unnecessary.
  static ({SupabaseClient client, SupabaseAuthService auth}) createServices({
    required String supabaseUrl,
    required String supabaseKey,
    FlutterSecureStorage? secureStorage,
    PersistentAuthSessionRepository? sessionRepo,
    GotrueAsyncStorage? testPkce,
  }) {
    final pkce = testPkce ?? FlutterSecureGotrueStorage(storage: secureStorage);

    final client = SupabaseClient(
      supabaseUrl,
      supabaseKey,
      authOptions: AuthClientOptions(
        pkceAsyncStorage: pkce,
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
      ),
    );

    final auth = SupabaseAuthService(
      client: client,
      sessionRepository:
          sessionRepo ??
          SecurePersistentAuthSessionRepository(storage: secureStorage),
    );
    return (client: client, auth: auth);
  }
}

/// Supabase Auth backed implementation (`packages/autolife-core` canonical service).
///
/// Persistence + refresh smoothing live here instead of scattering across shells.
final class SupabaseAuthService implements AuthService {
  SupabaseAuthService({
    required SupabaseClient client,
    PersistentAuthSessionRepository? sessionRepository,
  }) : _client = client,
       _sessions =
           sessionRepository ?? SecurePersistentAuthSessionRepository() {
    _state = AutoLifeAuthState.bootstrapping;
  }

  factory SupabaseAuthService.testHarness({
    required SupabaseClient client,
    required PersistentAuthSessionRepository sessionRepository,
  }) =>
      SupabaseAuthService(client: client, sessionRepository: sessionRepository);

  final SupabaseClient _client;

  PersistentAuthSessionRepository _sessions;

  final StreamController<AutoLifeAuthState> _controller =
      StreamController<AutoLifeAuthState>.broadcast();

  late AutoLifeAuthState _state;

  StreamSubscription<AuthState>? _sub;

  Future<void>? _refreshUiFlight;

  @override
  AutoLifeAuthState get currentState => _state;

  @override
  Stream<AutoLifeAuthState> get authStates => _controller.stream;

  void _emit(AutoLifeAuthState next) {
    _state = next;
    if (!_controller.isClosed) {
      _controller.add(next);
    }
  }

  @override
  Future<void> initialize() async {
    if (_sub != null) return;

    _sub = _client.auth.onAuthStateChange.listen(
      _onGotrueAuthState,
      onError: (Object e, StackTrace st) {
        developer.log(
          'auth stream failure',
          name: 'SupabaseAuthService',
          error: e,
          stackTrace: st,
        );
      },
    );

    final persisted = await _sessions.loadSessionJson();
    if (persisted != null && persisted.isNotEmpty) {
      await _recoverFromStorage(persisted);
    }

    await _finalizeBootstrapSnapshot();
  }

  Future<void> _recoverFromStorage(String persisted) async {
    _emit(
      AutoLifeAuthState(
        phase: AutoLifeAuthPhase.hydrating,
        updatedAtUtc: DateTime.now().toUtc(),
      ),
    );

    try {
      await _client.auth.recoverSession(persisted);
    } catch (e, st) {
      developer.log(
        'persisted session unreadable — clearing blob',
        name: 'SupabaseAuthService',
        error: e,
        stackTrace: st,
      );
      await _sessions.clear();
    }
  }

  Future<void> _finalizeBootstrapSnapshot() async {
    final session = _client.auth.currentSession;
    final user = _client.auth.currentUser;
    if (session != null && user != null) {
      await _sessions.persistSessionJson(jsonEncode(session.toJson()));
      _emit(_authenticated(session));
      return;
    }

    _emit(
      AutoLifeAuthState(
        phase: AutoLifeAuthPhase.unauthenticated,
        updatedAtUtc: DateTime.now().toUtc(),
      ),
    );
  }

  Future<void> _persistOrClear(Session? session) async {
    if (session == null) {
      await _sessions.clear();
      return;
    }
    await _sessions.persistSessionJson(jsonEncode(session.toJson()));
  }

  bool _handlesSignedInVariants(AuthChangeEvent ev) =>
      ev == AuthChangeEvent.initialSession ||
      ev == AuthChangeEvent.signedIn ||
      ev == AuthChangeEvent.userUpdated ||
      ev == AuthChangeEvent.tokenRefreshed;

  void _onGotrueAuthState(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.signedOut:
        unawaited(_sessions.clear());
        _emit(
          AutoLifeAuthState(
            phase: AutoLifeAuthPhase.unauthenticated,
            rawEvent: state.event,
            updatedAtUtc: DateTime.now().toUtc(),
          ),
        );

      case final AuthChangeEvent ev when _handlesSignedInVariants(ev):
        final sess = state.session ?? _client.auth.currentSession;
        if (sess == null) {
          _emit(
            AutoLifeAuthState(
              phase: AutoLifeAuthPhase.unauthenticated,
              rawEvent: state.event,
              updatedAtUtc: DateTime.now().toUtc(),
            ),
          );
          return;
        }
        unawaited(_persistOrClear(sess));
        _emit(
          _authenticated(sess).copyWith(
            rawEvent: state.event,
            updatedAtUtc: DateTime.now().toUtc(),
          ),
        );

      case AuthChangeEvent.passwordRecovery:
        final sess = state.session ?? _client.auth.currentSession!;
        unawaited(_persistOrClear(sess));
        _emit(
          AutoLifeAuthState(
            phase: AutoLifeAuthPhase.awaitingPasswordRecovery,
            user: AuthUser.fromGotrue(sess.user),
            session: AuthSessionView.fromGotrue(sess),
            pendingRecoveryRedirectType: 'recovery',
            rawEvent: state.event,
            updatedAtUtc: DateTime.now().toUtc(),
          ),
        );

      default:
        developer.log(
          'unhandled auth event ${state.event}',
          name: 'SupabaseAuthService',
        );
    }
  }

  AutoLifeAuthState _authenticated(Session session) {
    return AutoLifeAuthState(
      phase: AutoLifeAuthPhase.authenticated,
      user: AuthUser.fromGotrue(session.user),
      session: AuthSessionView.fromGotrue(session),
      updatedAtUtc: DateTime.now().toUtc(),
    );
  }

  @override
  Future<Result<void>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final session = res.session;
      if (session == null) {
        return Result.failure(
          Failure(
            code: AuthErrorKind.invalidCredentials.name,
            message: AuthMappedError(
              kind: AuthErrorKind.invalidCredentials,
            ).displayMessage,
          ),
        );
      }
      await _persistOrClear(session);
      _emit(_authenticated(session));
      return const Result.success(null);
    } catch (e, _) {
      final mapped = mapAuthException(e);
      return Result.failure(
        Failure(code: mapped.kind.name, message: mapped.displayMessage),
      );
    }
  }

  @override
  Future<Result<void>> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
    String? emailRedirectTo,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null && displayName.trim().isNotEmpty) {
        data['full_name'] = displayName.trim();
      }
      final res = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        emailRedirectTo: emailRedirectTo,
        data: data.isEmpty ? null : data,
      );
      final session = res.session;
      if (session != null) {
        await _persistOrClear(session);
        _emit(_authenticated(session));
      }
      return const Result.success(null);
    } catch (e, _) {
      final mapped = mapAuthException(e);
      return Result.failure(
        Failure(code: mapped.kind.name, message: mapped.displayMessage),
      );
    }
  }

  @override
  Future<Result<void>> requestPasswordResetEmail({
    required String email,
    required String redirectTo,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: redirectTo,
      );
      return const Result.success(null);
    } catch (e, _) {
      final mapped = mapAuthException(e);
      return Result.failure(
        Failure(code: mapped.kind.name, message: mapped.displayMessage),
      );
    }
  }

  @override
  Future<Result<void>> completeAuthRedirect(Uri uri) async {
    try {
      await _client.auth.getSessionFromUrl(uri, storeSession: true);
      return const Result.success(null);
    } catch (e, _) {
      final mapped = mapAuthException(e);
      return Result.failure(
        Failure(code: mapped.kind.name, message: mapped.displayMessage),
      );
    }
  }

  @override
  Future<Result<String>> oauthAuthorizeUrl({
    required OAuthProvider provider,
    required String redirectTo,
    String scopes = '',
    bool skipBrowserRedirect = true,
  }) async {
    try {
      final res = await _client.auth.getOAuthSignInUrl(
        provider: provider,
        redirectTo: redirectTo,
        scopes: scopes.isEmpty ? null : scopes,
        queryParams: skipBrowserRedirect
            ? const {'skip_http_redirect': 'true'}
            : null,
      );
      return Result.success(res.url);
    } catch (e, _) {
      final mapped = mapAuthException(e);
      return Result.failure(
        Failure(code: mapped.kind.name, message: mapped.displayMessage),
      );
    }
  }

  @override
  Future<Result<void>> refreshSessionExplicit() async {
    if (_refreshUiFlight != null) {
      try {
        await _refreshUiFlight;
        return const Result.success(null);
      } catch (_) {
        /* retry below */
      }
    }

    final phaseBeforeRecovery =
        currentState.phase == AutoLifeAuthPhase.awaitingPasswordRecovery;
    final snapBefore = currentState;

    if (_client.auth.currentSession?.refreshToken == null) {
      return Result.failure(Failure(code: 'no_refresh_token'));
    }

    _emit(
      AutoLifeAuthState(
        phase: AutoLifeAuthPhase.refreshing,
        user: snapBefore.user,
        session: snapBefore.session,
        updatedAtUtc: DateTime.now().toUtc(),
      ),
    );

    Future<void> runRefresh() async {
      try {
        await _client.auth.refreshSession();
      } finally {
        final session = _client.auth.currentSession;
        if (session != null) {
          await _persistOrClear(session);
          _emit(_authenticated(session));
        } else {
          _emit(
            AutoLifeAuthState(
              phase: phaseBeforeRecovery
                  ? AutoLifeAuthPhase.awaitingPasswordRecovery
                  : AutoLifeAuthPhase.unauthenticated,
              updatedAtUtc: DateTime.now().toUtc(),
            ),
          );
        }
      }
    }

    final f = runRefresh();
    _refreshUiFlight = f;
    try {
      await f;
      return const Result.success(null);
    } catch (e, _) {
      final mapped = mapAuthException(e);
      final session = _client.auth.currentSession;
      if (session != null) {
        _emit(_authenticated(session));
      } else {
        _emit(
          AutoLifeAuthState(
            phase: AutoLifeAuthPhase.unauthenticated,
            updatedAtUtc: DateTime.now().toUtc(),
          ),
        );
      }
      return Result.failure(
        Failure(code: mapped.kind.name, message: mapped.displayMessage),
      );
    } finally {
      _refreshUiFlight = null;
    }
  }

  @override
  Future<Result<void>> logoutCurrentSession() async {
    try {
      await _client.auth.signOut(scope: SignOutScope.local);
      await _sessions.clear();
      return const Result.success(null);
    } catch (e, _) {
      final mapped = mapAuthException(e);
      return Result.failure(
        Failure(code: mapped.kind.name, message: mapped.displayMessage),
      );
    }
  }

  @override
  Future<Result<void>> logoutAllDevices() async {
    try {
      await _client.auth.signOut(scope: SignOutScope.global);
      await _sessions.clear();
      return const Result.success(null);
    } catch (e, _) {
      final mapped = mapAuthException(e);
      return Result.failure(
        Failure(code: mapped.kind.name, message: mapped.displayMessage),
      );
    }
  }

  @override
  Future<Result<void>> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      final sess = _client.auth.currentSession;
      if (sess != null) {
        await _persistOrClear(sess);
        _emit(_authenticated(sess));
      }
      return const Result.success(null);
    } catch (e, _) {
      final mapped = mapAuthException(e);
      return Result.failure(
        Failure(code: mapped.kind.name, message: mapped.displayMessage),
      );
    }
  }

  /// Test-only swaps persister implementations.
  @visibleForTesting
  void swapSessionRepository(PersistentAuthSessionRepository repo) {
    _sessions = repo;
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel() ?? Future<void>.value());
    _sub = null;
    unawaited(_controller.close());
  }
}

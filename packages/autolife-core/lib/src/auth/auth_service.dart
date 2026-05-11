import 'package:supabase/supabase.dart' hide AuthUser;

import '../common/result.dart';
import 'models/auth_session.dart';
import 'models/auth_user.dart';

/// High-level UX phase for reactive surfaces.
///
/// Raw provider events arrive from GoTrue ([AuthChangeEvent]) and are smoothed here.
enum AutoLifeAuthPhase {
  /// Startup / storage restore outstanding.
  bootstrapping,

  /// Recovering persisted session silently.
  hydrating,

  /// Access token renewal in-flight (shows alongside current session snapshot).
  refreshing,

  unauthenticated,

  authenticated,

  /// Password recovery completes when [updatePassword] succeeds.
  awaitingPasswordRecovery,
}

class AutoLifeAuthState {
  const AutoLifeAuthState({
    required this.phase,
    this.user,
    this.session,
    this.pendingRecoveryRedirectType,
    this.rawEvent,
    this.updatedAtUtc,
  });

  final AutoLifeAuthPhase phase;

  /// Present when authenticated or hydrating from storage.
  final AuthUser? user;

  /// Present when authenticated, recovering, hydrating, refreshing.
  final AuthSessionView? session;

  final String? pendingRecoveryRedirectType;
  final AuthChangeEvent? rawEvent;

  /// Last transition time — helps UX debounce overlays.
  final DateTime? updatedAtUtc;

  bool get isSignedIn =>
      phase == AutoLifeAuthPhase.authenticated ||
      phase == AutoLifeAuthPhase.awaitingPasswordRecovery ||
      phase == AutoLifeAuthPhase.refreshing ||
      phase == AutoLifeAuthPhase.hydrating;

  static const bootstrapping = AutoLifeAuthState(
    phase: AutoLifeAuthPhase.bootstrapping,
  );

  AutoLifeAuthState copyWith({
    AutoLifeAuthPhase? phase,
    AuthUser? user,
    AuthSessionView? session,
    String? pendingRecoveryRedirectType,
    AuthChangeEvent? rawEvent,
    DateTime? updatedAtUtc,
  }) {
    return AutoLifeAuthState(
      phase: phase ?? this.phase,
      user: user ?? this.user,
      session: session ?? this.session,
      pendingRecoveryRedirectType:
          pendingRecoveryRedirectType ?? this.pendingRecoveryRedirectType,
      rawEvent: rawEvent ?? this.rawEvent,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    );
  }
}

/// Platform-agnostic auth contract for shells and integration modules (phase 2.1).
abstract interface class AuthService {
  /// Last known state (replay before listening).
  AutoLifeAuthState get currentState;

  /// Cold start: restore persisted session and subscribe to upstream events.
  Future<void> initialize();

  Stream<AutoLifeAuthState> get authStates;

  Future<Result<void>> signInWithPassword({
    required String email,
    required String password,
  });

  Future<Result<void>> signUpWithPassword({
    required String email,
    required String password,
    String? displayName,
    String? emailRedirectTo,
  });

  /// Request password reset email (`/recover`).
  Future<Result<void>> requestPasswordResetEmail({
    required String email,
    required String redirectTo,
  });

  /// Complete PKCE/password recovery exchanges from OAuth-style callback [uri].
  Future<Result<void>> completeAuthRedirect(Uri uri);

  /// Begin browser-based OAuth (`/authorize`).
  ///
  /// [redirectTo] must match allow-listed URLs in Supabase Auth settings.
  Future<Result<String>> oauthAuthorizeUrl({
    required OAuthProvider provider,
    required String redirectTo,
    String scopes = '',
    bool skipBrowserRedirect = true,
  });

  Future<Result<void>> refreshSessionExplicit();

  Future<Result<void>> logoutCurrentSession();

  /// Revokes refresh tokens globally for the signed-in account.
  ///
  /// GoTrue clears the device session afterward.
  Future<Result<void>> logoutAllDevices();

  /// Sets a new password after `password_recovery` establishes a provisional session.
  Future<Result<void>> updatePassword(String newPassword);

  void dispose();
}

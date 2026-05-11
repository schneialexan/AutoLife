import 'package:supabase/supabase.dart' hide AuthUser;

/// User-safe auth surface (no raw provider strings forwarded to UX).
///
/// Consumers map each [kind] via [messageFor].
enum AuthErrorKind {
  invalidCredentials,
  emailNotConfirmed,
  userAlreadyRegistered,
  weakPassword,
  rateLimited,
  network,
  oauthCancelled,
  sessionExpired,
  invalidRecoveryLink,
  unknown,
}

class AuthMappedError implements Exception {
  const AuthMappedError({
    required this.kind,
    this.developerHint,
    this.original,
  });

  final AuthErrorKind kind;
  final String? developerHint;
  final Object? original;

  String get displayMessage => messageFor(kind);

  @override
  String toString() => 'AuthMappedError(kind: $kind, hint: $developerHint)';
}

String messageFor(AuthErrorKind kind) {
  return switch (kind) {
    AuthErrorKind.invalidCredentials =>
      'Incorrect email or password. Please try again.',
    AuthErrorKind.emailNotConfirmed =>
      'Confirm your email from the signup message before signing in.',
    AuthErrorKind.userAlreadyRegistered =>
      'An account already exists for this email. Try signing in instead.',
    AuthErrorKind.weakPassword =>
      'That password does not meet the minimum requirements.',
    AuthErrorKind.rateLimited =>
      'Too many attempts. Wait a minute and try again.',
    AuthErrorKind.network => 'Network error. Check your connection and retry.',
    AuthErrorKind.oauthCancelled => 'Sign-in was cancelled.',
    AuthErrorKind.sessionExpired =>
      'Your session expired. Please sign in again.',
    AuthErrorKind.invalidRecoveryLink =>
      'This reset link is invalid or expired. Request a new one.',
    AuthErrorKind.unknown => 'Something went wrong. Please try again.',
  };
}

AuthMappedError mapAuthException(dynamic error, [StackTrace? st]) {
  if (error is AuthWeakPasswordException) {
    return AuthMappedError(
      kind: AuthErrorKind.weakPassword,
      developerHint: error.message,
      original: error,
    );
  }
  if (error is AuthPKCEGrantCodeExchangeError) {
    return AuthMappedError(
      kind: AuthErrorKind.invalidRecoveryLink,
      developerHint: error.message,
      original: error,
    );
  }

  if (error is AuthException) {
    final hint = '${error.message} ${error.statusCode ?? ''}'.trim();
    final code = error.code?.toLowerCase();
    switch (code) {
      case 'weak_password':
        return AuthMappedError(
          kind: AuthErrorKind.weakPassword,
          developerHint: hint.isEmpty ? null : hint,
          original: error,
        );
      case 'over_request_rate_limit':
      case 'too_many_requests':
        return AuthMappedError(
          kind: AuthErrorKind.rateLimited,
          developerHint: hint.isEmpty ? null : hint,
          original: error,
        );
      case 'otp_expired':
      case 'otp_disabled':
      case 'flow_state_expired':
        return AuthMappedError(
          kind: AuthErrorKind.invalidRecoveryLink,
          developerHint: hint.isEmpty ? null : hint,
          original: error,
        );
      case 'email_not_confirmed':
        return AuthMappedError(
          kind: AuthErrorKind.emailNotConfirmed,
          developerHint: hint.isEmpty ? null : hint,
          original: error,
        );
      case 'user_already_exists':
        return AuthMappedError(
          kind: AuthErrorKind.userAlreadyRegistered,
          developerHint: hint.isEmpty ? null : hint,
          original: error,
        );
      case 'invalid_credentials':
      case 'invalid_grant':
      case 'invalid_login_credentials':
      case null:
      case '':
        break;
      default:
        break;
    }

    final lower = hint.toLowerCase();
    if (lower.contains('already registered')) {
      return AuthMappedError(
        kind: AuthErrorKind.userAlreadyRegistered,
        developerHint: hint.isEmpty ? null : hint,
        original: error,
      );
    }
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid credentials')) {
      return AuthMappedError(
        kind: AuthErrorKind.invalidCredentials,
        developerHint: hint.isEmpty ? null : hint,
        original: error,
      );
    }
    if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return AuthMappedError(
        kind: AuthErrorKind.rateLimited,
        developerHint: hint.isEmpty ? null : hint,
        original: error,
      );
    }
    if (lower.contains('expired') && lower.contains('link')) {
      return AuthMappedError(
        kind: AuthErrorKind.invalidRecoveryLink,
        developerHint: hint.isEmpty ? null : hint,
        original: error,
      );
    }
    if (lower.contains('minimum password')) {
      return AuthMappedError(
        kind: AuthErrorKind.weakPassword,
        developerHint: hint.isEmpty ? null : hint,
        original: error,
      );
    }
    if (lower.contains('socket') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection refused')) {
      return AuthMappedError(
        kind: AuthErrorKind.network,
        developerHint: hint.isEmpty ? null : hint,
        original: error,
      );
    }

    return AuthMappedError(
      kind: AuthErrorKind.unknown,
      developerHint: hint.isEmpty ? null : hint,
      original: error,
    );
  }

  final str = '$error'.toLowerCase();
  if (str.contains('socketexception') ||
      str.contains('connection') ||
      str.contains('handshake')) {
    return AuthMappedError(
      kind: AuthErrorKind.network,
      developerHint: '$error',
      original: error,
    );
  }

  return AuthMappedError(
    kind: AuthErrorKind.unknown,
    developerHint: '$error',
    original: error,
  );
}

import 'dart:convert';

import 'package:supabase/supabase.dart' hide AuthUser;

/// Non-secret projections of server session state for UX.
///
/// Sensitive tokens remain inside [Gotrue]'s managed [Session] only.
class AuthSessionView {
  const AuthSessionView({
    required this.userId,
    required this.accessTokenExpiresAtEpochSec,
    this.sessionIdClaim,
    this.oauthProviderHints = const [],
  });

  /// UTC epoch seconds aligned with JWT `exp`.
  final int accessTokenExpiresAtEpochSec;

  /// User UUID from JWT claim `sub`.
  final String userId;

  /// `session_id` when present on Supabase JWTs.
  final String? sessionIdClaim;

  /// Identities/providers linked to account (hints only).
  final List<String> oauthProviderHints;

  static AuthSessionView fromGotrue(Session session, {User? user}) {
    final u = user ?? session.user;
    final exp = session.expiresAt ?? 0;
    final hints = [...(u.identities ?? []).map((e) => e.provider)];

    final claims = JwtPayload.decode(session.accessToken);
    final sid = claims?['session_id'] as String?;

    return AuthSessionView(
      userId: u.id,
      accessTokenExpiresAtEpochSec: exp,
      sessionIdClaim: sid,
      oauthProviderHints: hints,
    );
  }
}

class JwtPayload {
  static Map<String, dynamic>? decode(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length < 2) return null;
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

import 'package:supabase/supabase.dart' hide AuthUser;

/// Domain projection of Supabase/Gotrue [User].
class AuthUser {
  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
    this.metadata = const {},
  });

  final String id;
  final String? email;
  final String? displayName;
  final Map<String, dynamic> metadata;

  static AuthUser fromGotrue(User u) {
    final meta = {...?u.userMetadata};
    final name = meta['full_name'] as String? ?? meta['name'] as String?;
    return AuthUser(
      id: u.id,
      email: u.email,
      displayName: name ?? u.email ?? u.phone,
      metadata: meta,
    );
  }
}

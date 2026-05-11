import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase/supabase.dart' hide AuthUser;

void main() {
  group('mapAuthException', () {
    test('maps invalid credentials', () {
      final mapped = mapAuthException(
        const AuthException(
          'Invalid login credentials',
          code: 'invalid_credentials',
        ),
      );
      expect(mapped.kind, AuthErrorKind.invalidCredentials);
      expect(
        mapped.displayMessage,
        messageFor(AuthErrorKind.invalidCredentials),
      );
    });

    test('maps weak password sentinel', () {
      final mapped = mapAuthException(
        AuthWeakPasswordException(
          message: 'Weak',
          statusCode: '422',
          reasons: const ['short'],
        ),
      );
      expect(mapped.kind, AuthErrorKind.weakPassword);
    });
  });
}

import 'package:autolife_shell/main.dart' as shell;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _testSupabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: '',
);
const _anon = String.fromEnvironment(
  'AUTOLIFE_SUPABASE_ANON_KEY',
  defaultValue: '',
);

bool get _haveAnonAuth => _testSupabaseUrl.isNotEmpty && _anon.isNotEmpty;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('phase 2.1: email/password sign-up reaches shell', (
    tester,
  ) async {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'phase21.$stamp@example.com';
    const password = 'localPass99!';

    await shell.main();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle(const Duration(seconds: 4));

    await tester.tap(find.byKey(const Key('auth_nav_sign_up')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('auth_sign_up_email_field')),
      email,
    );
    await tester.enterText(
      find.byKey(const Key('auth_sign_up_password_field')),
      password,
    );

    await tester.tap(find.byKey(const Key('auth_sign_up_button')));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    expect(find.byType(NavigationBar), findsOneWidget);
  }, skip: !_haveAnonAuth);
}

import 'package:autolife_shell/main.dart' as shell;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Offline-friendly round-trip: quick action → Drift cache → upcoming strip text.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('quick action publishes event.created into cache (phase 3.1)', (
    tester,
  ) async {
    await shell.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final quick = find.byKey(const Key('quick_action_add_event'));
    expect(quick, findsOneWidget);
    await tester.ensureVisible(quick);
    await tester.tap(quick);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('New event'), findsWidgets);
  });
}

import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AutoLifeTheme attaches AutoLifeTokens', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AutoLifeTheme.light(),
        home: Builder(
          builder: (context) {
            final ext = Theme.of(context).extension<AutoLifeTokens>();
            expect(ext, isNotNull);
            expect(ext!.brightness, Brightness.light);
            return const SizedBox();
          },
        ),
      ),
    );
  });

  testWidgets('AutoLifeButton pumps', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AutoLifeTheme.light(),
        home: Scaffold(
          body: AutoLifeButton(label: 'Ok', onPressed: () {}),
        ),
      ),
    );
    expect(find.text('Ok'), findsOneWidget);
  });
}

import 'package:autolife_ui/autolife_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AutolifePlaceholder builds', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AutolifePlaceholder())),
    );
    expect(find.byType(AutolifePlaceholder), findsOneWidget);
  });
}

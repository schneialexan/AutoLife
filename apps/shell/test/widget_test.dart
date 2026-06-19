import 'package:flutter_test/flutter_test.dart';

import 'package:shell/main.dart';

void main() {
  testWidgets('Shell renders the AutoLife placeholder', (tester) async {
    await tester.pumpWidget(const AutoLifeShellApp());

    expect(find.text('AutoLife'), findsOneWidget);
    expect(find.text('Shell · MVP #1'), findsOneWidget);
  });
}

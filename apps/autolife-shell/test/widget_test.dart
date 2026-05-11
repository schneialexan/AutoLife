import 'package:autolife_shell/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('placeholder home renders', (WidgetTester tester) async {
    await tester.pumpWidget(const AutolifeShellApp());
    expect(find.text('AutoLife'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Shell placeholder'), findsOneWidget);
  });
}

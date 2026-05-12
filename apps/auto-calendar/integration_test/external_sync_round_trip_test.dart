import 'package:auto_calendar/main.dart';
import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('standalone calendar boots', (tester) async {
    final repo = MemoryCalendarRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarRepositoryProvider.overrideWithValue(repo),
        ],
        child: const AutoCalendarApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Calendar'), findsOneWidget);
  });
}

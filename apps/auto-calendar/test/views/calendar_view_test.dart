import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/calendar_screen.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tuesday 2026-05-12 UTC: same week page 0 as Monday (Mon–Tue columns).
final _kTestWeekAnchorUtc = DateTime.utc(2026, 5, 12, 12);

void main() {
  testWidgets('calendar segments and app bar render', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = MemoryCalendarRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(
          home: CalendarScreen(familyId: 'f1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('Agenda'), findsOneWidget);
    expect(find.byTooltip('Go to today'), findsOneWidget);
  });

  testWidgets(
      'phone week view shows 2-day/agenda toggle and two-column table by default',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = MemoryCalendarRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarRepositoryProvider.overrideWithValue(repo),
          calendarSelectedViewProvider.overrideWith(
            (ref) => CalendarViewPrefsNotifier.seeded(CalendarViewMode.week),
          ),
          calendarAnchorProvider.overrideWith((ref) => _kTestWeekAnchorUtc),
          calendarMobileWeekModeProvider.overrideWith(
            (ref) => MobileWeekPrefsNotifier.seeded(MobileWeekMode.threeDaySwipe),
          ),
        ],
        child: MediaQuery(
          data: const MediaQueryData(size: Size(375, 800)),
          child: MaterialApp(
            home: CalendarScreen(familyId: 'f1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2-day'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('week-mobile-swipe')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('week-desktop-grid')),
      findsNothing,
    );
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Tue'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<MobileWeekMode>),
        matching: find.text('Agenda'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('week-mobile-agenda')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('week-mobile-swipe')),
      findsNothing,
    );
  });

  testWidgets('tablet week view keeps 7-column grid without mobile toggle',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = MemoryCalendarRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarRepositoryProvider.overrideWithValue(repo),
          calendarSelectedViewProvider.overrideWith(
            (ref) => CalendarViewPrefsNotifier.seeded(CalendarViewMode.week),
          ),
        ],
        child: MediaQuery(
          data: const MediaQueryData(size: Size(900, 800)),
          child: MaterialApp(
            home: CalendarScreen(familyId: 'f1'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2-day'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('week-desktop-grid')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('week-mobile-swipe')),
      findsNothing,
    );
  });

  testWidgets('month view marks today cell when clock matches', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = MemoryCalendarRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarRepositoryProvider.overrideWithValue(repo),
          calendarSelectedViewProvider.overrideWith(
            (ref) => CalendarViewPrefsNotifier.seeded(CalendarViewMode.month),
          ),
          calendarAnchorProvider.overrideWith((ref) => DateTime.utc(2026, 5, 1)),
          calendarTodayUtcProvider.overrideWith(
            (ref) => DateTime.utc(2026, 5, 15, 12),
          ),
        ],
        child: const MaterialApp(
          home: CalendarScreen(familyId: 'f1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('month-day-today')),
      findsOneWidget,
    );
  });

  testWidgets('go to today resets anchor from app bar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final repo = MemoryCalendarRepository();
    final container = ProviderContainer(
      overrides: [
        calendarRepositoryProvider.overrideWithValue(repo),
        calendarSelectedViewProvider.overrideWith(
          (ref) => CalendarViewPrefsNotifier.seeded(CalendarViewMode.month),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: CalendarScreen(familyId: 'f1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    container.read(calendarAnchorProvider.notifier).state =
        DateTime.utc(2030, 6, 15);
    await tester.tap(find.byTooltip('Go to today'));
    await tester.pump();
    final anchor = container.read(calendarAnchorProvider);
    final now = DateTime.now().toUtc();
    expect(anchor.year, now.year);
    expect(anchor.month, now.month);
    expect(anchor.day, now.day);
  });

  testWidgets('restores week mode from SharedPreferences on narrow screen',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'auto_calendar.selected_view_mode': 'week',
    });
    final repo = MemoryCalendarRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          calendarRepositoryProvider.overrideWithValue(repo),
        ],
        child: MediaQuery(
          data: const MediaQueryData(size: Size(375, 800)),
          child: MaterialApp(
            home: CalendarScreen(familyId: 'f1'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('2-day'), findsOneWidget);
  });
}

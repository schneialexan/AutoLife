import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('CalendarViewPrefsNotifier restores from prefs', () async {
    SharedPreferences.setMockInitialValues({
      'auto_calendar.selected_view_mode': 'agenda',
    });
    final container = ProviderContainer();
    try {
      // Eagerly build notifier + start async restore.
      container.read(calendarSelectedViewProvider);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(
        container.read(calendarSelectedViewProvider),
        CalendarViewMode.agenda,
      );
    } finally {
      container.dispose();
    }
  });

  test('CalendarViewPrefsNotifier setView writes prefs', () async {
    final container = ProviderContainer();
    try {
      await container
          .read(calendarSelectedViewProvider.notifier)
          .setView(CalendarViewMode.week);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auto_calendar.selected_view_mode'), 'week');
    } finally {
      container.dispose();
    }
  });

  test('MobileWeekPrefsNotifier setMode writes prefs', () async {
    final container = ProviderContainer();
    try {
      await container.read(calendarMobileWeekModeProvider.notifier).setMode(
            MobileWeekMode.stackedAgenda,
          );
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('auto_calendar.mobile_week_mode'), 'stackedAgenda');
    } finally {
      container.dispose();
    }
  });
}

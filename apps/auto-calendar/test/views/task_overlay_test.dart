import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tasksDueOnDayProvider hides when overlay off', () {
    final container = ProviderContainer(
      overrides: [
        calendarShowTasksOverlayProvider
            .overrideWith((ref) => CalendarShowTasksOverlayNotifier.seeded(false)),
        calendarTaskRepositoryProvider.overrideWith((ref) => MemoryTaskRepository()),
        calendarFamilyIdProvider.overrideWithValue('f'),
      ],
    );
    final day = DateTime.utc(2026, 5, 12);
    expect(container.read(tasksDueOnDayProvider(day)), isEmpty);
    container.dispose();
  });
}

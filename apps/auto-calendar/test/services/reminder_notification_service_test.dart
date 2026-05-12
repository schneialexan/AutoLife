import 'package:auto_calendar/src/services/reminder_notification_service.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reminder dedupe key stable per event', () async {
    final svc = ReminderNotificationService();
    final now = DateTime.now().toUtc();
    final e = CalendarEvent(
      id: 'e1',
      familyId: 'f1',
      title: 'T',
      startAt: now,
      endAt: now.add(const Duration(hours: 1)),
      allDay: false,
      reminders: const [
        CalendarReminder(
          offsetBeforeStart: Duration(minutes: -10),
          dedupeKey: 'x',
        ),
      ],
      createdBy: 'u1',
      syncSource: 'internal',
      createdAt: now,
      updatedAt: now,
    );
    await svc.schedule(e);
    await svc.schedule(e);
    expect(svc.wasDeduped('e1', 'x'), isTrue);
    expect(svc.scheduled.length, 1);
  });
}

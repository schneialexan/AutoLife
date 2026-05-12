import 'package:autolife_core/autolife_core.dart';
import 'package:uuid/uuid.dart';

List<CalendarEvent> demoCalendarEvents(String familyId) {
  final now = DateTime.now().toUtc();
  final day = DateTime.utc(now.year, now.month, now.day);
  const u = Uuid();
  String id() => u.v4();
  return [
    CalendarEvent(
      id: id(),
      familyId: familyId,
      title: 'School pickup',
      startAt: day.add(const Duration(hours: 15)),
      endAt: day.add(const Duration(hours: 15, minutes: 30)),
      allDay: false,
      taggedMemberIds: const ['22222222-2222-2222-2222-222222222222'],
      createdBy: '11111111-1111-1111-1111-111111111111',
      syncSource: 'internal',
      location: 'Lincoln Elementary',
      notes: 'Bring umbrella if rain.',
      reminders: const [
        CalendarReminder(
          offsetBeforeStart: Duration(minutes: -30),
          dedupeKey: 'pickup-30',
        ),
      ],
      createdAt: now,
      updatedAt: now,
      color: '#1E88E5',
    ),
    CalendarEvent(
      id: id(),
      familyId: familyId,
      title: 'Soccer practice',
      startAt: day.add(const Duration(hours: 17)),
      endAt: day.add(const Duration(hours: 18, minutes: 30)),
      allDay: false,
      taggedMemberIds: const [
        '33333333-3333-3333-3333-333333333333',
        '11111111-1111-1111-1111-111111111111',
      ],
      createdBy: '11111111-1111-1111-1111-111111111111',
      syncSource: 'internal',
      location: 'Riverside Park Field 2',
      createdAt: now,
      updatedAt: now,
      color: '#43A047',
    ),
    CalendarEvent(
      id: id(),
      familyId: familyId,
      title: 'Family dinner',
      startAt: day.add(const Duration(hours: 19)),
      endAt: day.add(const Duration(hours: 20, minutes: 30)),
      allDay: false,
      taggedMemberIds: const [
        '11111111-1111-1111-1111-111111111111',
        '22222222-2222-2222-2222-222222222222',
      ],
      createdBy: '11111111-1111-1111-1111-111111111111',
      syncSource: 'internal',
      createdAt: now,
      updatedAt: now,
      recurrenceRule: const CalendarRecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        interval: 1,
        byWeekday: [1, 3, 5],
      ),
      color: '#E53935',
    ),
  ];
}

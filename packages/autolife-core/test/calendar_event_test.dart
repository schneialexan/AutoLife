import 'package:autolife_core/autolife_core.dart';
import 'package:test/test.dart';

void main() {
  test('CalendarEvent JSON roundtrip', () {
    final value = CalendarEvent(
      id: 'c1',
      familyId: 'f1',
      title: 'Dentist',
      description: 'Cleaning',
      location: 'Clinic',
      startAt: DateTime.utc(2026, 5, 10, 9),
      endAt: DateTime.utc(2026, 5, 10, 10),
      allDay: false,
      assignedTo: 'u1',
      createdBy: 'u1',
      color: '#FF0000',
      syncSource: 'google',
      externalId: 'gcal-1',
      syncedByUserId: 'u1',
      lastSyncedAt: DateTime.utc(2026, 5, 2, 9),
      createdAt: DateTime.utc(2026, 5, 1),
      updatedAt: DateTime.utc(2026, 5, 2),
    );

    final json = value.toJson();
    final parsed = CalendarEvent.fromJson(json);

    expect(parsed.title, value.title);
    expect(parsed.allDay, false);
    expect(parsed.color, '#FF0000');
    expect(parsed.syncSource, 'google');
    expect(parsed.externalId, 'gcal-1');
    expect(parsed.startAt.toUtc(), value.startAt.toUtc());
  });

  test('CalendarEvent handles null optionals', () {
    final json = <String, dynamic>{
      'id': 'c1',
      'family_id': 'f1',
      'title': 'All day',
      'description': null,
      'location': null,
      'start_at': '2026-05-10T00:00:00.000Z',
      'end_at': '2026-05-10T23:59:59.000Z',
      'all_day': true,
      'assigned_to': null,
      'created_by': 'u1',
      'color': null,
      'sync_source': 'internal',
      'external_id': null,
      'synced_by_user_id': null,
      'last_synced_at': null,
      'created_at': '2026-05-01T00:00:00.000Z',
      'updated_at': '2026-05-01T00:00:00.000Z',
    };

    final parsed = CalendarEvent.fromJson(json);
    expect(parsed.allDay, true);
    expect(parsed.description, isNull);
    expect(parsed.assignedTo, isNull);
    expect(parsed.color, isNull);
    expect(parsed.externalId, isNull);
  });
}

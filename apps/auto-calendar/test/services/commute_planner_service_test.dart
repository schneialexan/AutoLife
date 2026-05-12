import 'package:auto_calendar/src/services/commute_planner_service.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('commute block removed when location cleared', () async {
    final planner = CommutePlannerService();
    final now = DateTime.now().toUtc();
    final withLoc = CalendarEvent(
      id: 'e1',
      familyId: 'f1',
      title: 'A',
      startAt: now,
      endAt: now.add(const Duration(hours: 1)),
      allDay: false,
      location: 'Somewhere',
      createdBy: 'u1',
      syncSource: 'internal',
      createdAt: now,
      updatedAt: now,
    );
    final travel = await planner.buildTravelBlock(anchor: withLoc);
    expect(travel, isNotNull);
    final noLoc = CalendarEvent(
      id: 'e2',
      familyId: 'f1',
      title: 'B',
      startAt: now,
      endAt: now.add(const Duration(hours: 1)),
      allDay: false,
      createdBy: 'u1',
      syncSource: 'internal',
      createdAt: now,
      updatedAt: now,
    );
    final none = await planner.buildTravelBlock(anchor: noLoc);
    expect(none, isNull);
  });
}

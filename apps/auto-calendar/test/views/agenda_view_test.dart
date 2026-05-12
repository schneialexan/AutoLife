import 'dart:async';

import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/views/agenda_view.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manual push so the first [StreamBuilder] frame has `snap.data == null`, then an
/// unmodifiable list — both used to break in-place [List.sort].
final class _ManualPushRangeRepo implements CalendarRepository {
  _ManualPushRangeRepo(this._events);

  final StreamController<List<CalendarEvent>> _events;

  @override
  Stream<List<CalendarEvent>> watchFamily(String familyId) =>
      const Stream.empty();

  @override
  Stream<List<CalendarEvent>> watchRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
  }) =>
      _events.stream;

  @override
  Future<void> upsert(CalendarEvent event) async {}

  @override
  Future<void> delete({required String familyId, required String eventId}) async {}
}

void main() {
  testWidgets(
    'AgendaView does not throw when range stream is late or unmodifiable',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final later = CalendarEvent(
        id: 'b',
        familyId: 'f1',
        title: 'later',
        startAt: DateTime.utc(2026, 5, 14, 10),
        endAt: DateTime.utc(2026, 5, 14, 11),
        allDay: false,
        createdBy: 'u',
        syncSource: 'test',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final earlier = CalendarEvent(
        id: 'a',
        familyId: 'f1',
        title: 'earlier',
        startAt: DateTime.utc(2026, 5, 13, 10),
        endAt: DateTime.utc(2026, 5, 13, 11),
        allDay: false,
        createdBy: 'u',
        syncSource: 'test',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final controller = StreamController<List<CalendarEvent>>();
      addTearDown(controller.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarRepositoryProvider.overrideWithValue(
              _ManualPushRangeRepo(controller),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AgendaView(
                familyId: 'f1',
                anchor: DateTime.utc(2026, 5, 12),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      controller.add(List<CalendarEvent>.unmodifiable(<CalendarEvent>[
        later,
        earlier,
      ]));
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
}

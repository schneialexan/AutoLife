import 'package:auto_calendar/src/services/calendar_import_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ICS import idempotent on duplicate UID', () {
    const raw = '''
BEGIN:VCALENDAR
BEGIN:VEVENT
UID:dup
DTSTART:20260515T150000Z
DTEND:20260515T160000Z
SUMMARY:First
END:VEVENT
BEGIN:VEVENT
UID:dup
DTSTART:20260516T150000Z
DTEND:20260516T160000Z
SUMMARY:Second
END:VEVENT
END:VCALENDAR
''';
    final svc = CalendarImportService();
    final preview = svc.previewIcs(raw);
    expect(preview.eventCount, 1);
  });

  test('ICS surfaces unsupported RRULE', () {
    const raw = '''
BEGIN:VCALENDAR
BEGIN:VEVENT
UID:r1
DTSTART:20260515T150000Z
DTEND:20260515T160000Z
SUMMARY:Ruled
RRULE:FREQ=DAILY
END:VEVENT
END:VCALENDAR
''';
    final svc = CalendarImportService();
    final preview = svc.previewIcs(raw);
    expect(preview.unsupportedFields, contains('RRULE'));
  });
}

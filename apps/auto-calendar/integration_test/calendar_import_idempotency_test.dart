import 'package:auto_calendar/src/services/calendar_import_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('calendar import idempotency harness', () {
    const raw = '''
BEGIN:VCALENDAR
BEGIN:VEVENT
UID:stable
DTSTART:20260515T150000Z
DTEND:20260515T160000Z
SUMMARY:Once
END:VEVENT
END:VCALENDAR
''';
    final svc = CalendarImportService();
    final a = svc.previewIcs(raw);
    final b = svc.previewIcs(raw);
    expect(a.events.single.externalUid, b.events.single.externalUid);
  });
}

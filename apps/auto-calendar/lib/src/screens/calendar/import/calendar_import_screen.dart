import 'package:auto_calendar/src/services/calendar_import_service.dart';
import 'package:auto_calendar/src/screens/calendar/import/calendar_import_preview_screen.dart';
import 'package:flutter/material.dart';

class CalendarImportScreen extends StatefulWidget {
  const CalendarImportScreen({super.key, required this.familyId});

  final String familyId;

  @override
  State<CalendarImportScreen> createState() => _CalendarImportScreenState();
}

class _CalendarImportScreenState extends State<CalendarImportScreen> {
  final _ics = TextEditingController(text: _sampleIcs);
  final _service = CalendarImportService();

  @override
  void dispose() {
    _ics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import calendar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Paste .ics contents for a dry-run preview. Unsupported VEVENT '
            'properties are surfaced in the summary — nothing is silently dropped '
            'without disclosure.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ics,
            minLines: 8,
            maxLines: 20,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              final preview = _service.previewIcs(_ics.text);
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CalendarImportPreviewScreen(
                    familyId: widget.familyId,
                    preview: preview,
                  ),
                ),
              );
            },
            child: const Text('Preview import'),
          ),
        ],
      ),
    );
  }
}

const _sampleIcs = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//AutoLife//EN
BEGIN:VEVENT
UID:test-uid-1
DTSTART:20260515T150000Z
DTEND:20260515T160000Z
SUMMARY:Sample ICS Event
LOCATION:DEMO
END:VEVENT
END:VCALENDAR
''';

import 'package:meta/meta.dart';

@immutable
class ParsedIcsEvent {
  const ParsedIcsEvent({
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.externalUid,
    this.location,
  });

  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String externalUid;
  final String? location;
}

@immutable
class CalendarImportPreview {
  const CalendarImportPreview({
    required this.events,
    required this.duplicatesSkipped,
    required this.unsupportedFields,
    required this.source,
  });

  final List<ParsedIcsEvent> events;
  final int duplicatesSkipped;
  final List<String> unsupportedFields;
  final String source;

  int get eventCount => events.length;
}

/// Minimal ICS parser + idempotent preview (phase 3.2).
final class CalendarImportService {
  CalendarImportPreview previewIcs(String raw, {String source = 'ics'}) {
    final unsupported = <String>{};
    final events = <ParsedIcsEvent>[];
    final seenUid = <String>{};
    String? uid;
    String? summary;
    String? loc;
    String? dtStart;
    String? dtEnd;

    void flush() {
      if (uid != null &&
          summary != null &&
          dtStart != null &&
          dtEnd != null) {
        final start = _parseIcsDate(dtStart!);
        final end = _parseIcsDate(dtEnd!);
        if (start != null && end != null) {
          if (!seenUid.contains(uid)) {
            seenUid.add(uid!);
            events.add(
              ParsedIcsEvent(
                title: summary!,
                startAt: start,
                endAt: end,
                externalUid: uid!,
                location: loc,
              ),
            );
          }
        }
      }
      uid = summary = loc = dtStart = dtEnd = null;
    }

    for (final line in raw.split(RegExp(r'\r?\n'))) {
      final t = line.trimRight();
      if (t == 'BEGIN:VEVENT') {
        // Start accumulating
      } else if (t == 'END:VEVENT') {
        flush();
      } else if (t.startsWith('UID:')) {
        uid = t.substring(4).trim();
      } else if (t.startsWith('SUMMARY:')) {
        summary = _unfold(t.substring(8));
      } else if (t.startsWith('LOCATION:')) {
        loc = _unfold(t.substring(9));
      } else if (t.startsWith('DTSTART')) {
        final idx = t.indexOf(':');
        if (idx != -1) {
          dtStart = t.substring(idx + 1).trim();
          if (t.contains('TZID=')) {
            unsupported.add('TZID on DTSTART');
          }
        }
      } else if (t.startsWith('DTEND')) {
        final idx = t.indexOf(':');
        if (idx != -1) {
          dtEnd = t.substring(idx + 1).trim();
        }
      } else if (t.startsWith('RRULE:')) {
        unsupported.add('RRULE');
      }
    }

    return CalendarImportPreview(
      events: events,
      duplicatesSkipped: 0,
      unsupportedFields: unsupported.toList()..sort(),
      source: source,
    );
  }

  String _unfold(String s) =>
      s.replaceAll('\\n', '\n').replaceAll('\\,', ',');

  DateTime? _parseIcsDate(String v) {
    if (v.endsWith('Z')) {
      final core = v.substring(0, v.length - 1);
      if (core.length == 8) {
        final y = int.parse(core.substring(0, 4));
        final mo = int.parse(core.substring(4, 6));
        final d = int.parse(core.substring(6, 8));
        return DateTime.utc(y, mo, d);
      }
      if (core.length >= 15) {
        final y = int.parse(core.substring(0, 4));
        final mo = int.parse(core.substring(4, 6));
        final d = int.parse(core.substring(6, 8));
        final h = int.parse(core.substring(9, 11));
        final mi = int.parse(core.substring(11, 13));
        final sec = int.parse(core.substring(13, 15));
        return DateTime.utc(y, mo, d, h, mi, sec);
      }
    }
    return DateTime.tryParse(v)?.toUtc();
  }

  /// Provider import path (Google first) — stub until OAuth connector lands.
  CalendarImportPreview previewGoogle({String source = 'google'}) {
    return CalendarImportPreview(
      events: [
        ParsedIcsEvent(
          title: 'Google sample',
          startAt: DateTime.now().toUtc(),
          endAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
          externalUid: 'google:stub',
        ),
      ],
      duplicatesSkipped: 0,
      unsupportedFields: const ['Conference metadata'],
      source: source,
    );
  }
}

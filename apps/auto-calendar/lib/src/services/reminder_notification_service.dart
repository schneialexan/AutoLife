import 'package:autolife_core/autolife_core.dart';
import 'package:meta/meta.dart';

/// Local notification scheduling with per-[CalendarReminder.dedupeKey] dedupe.
@immutable
final class ReminderScheduleRecord {
  const ReminderScheduleRecord({
    required this.eventId,
    required this.dedupeKey,
    required this.fireAt,
  });

  final String eventId;
  final String dedupeKey;
  final DateTime fireAt;
}

final class ReminderNotificationService {
  final Map<String, ReminderScheduleRecord> _scheduled = {};

  Iterable<ReminderScheduleRecord> get scheduled => _scheduled.values;

  /// Schedules reminders derived from [event]; duplicates override same dedupe key.
  Future<void> schedule(CalendarEvent event) async {
    final base = event.startAt.toUtc();
    for (final r in event.reminders) {
      final fireAt = base.add(r.offsetBeforeStart);
      final key = '${event.id}:${r.dedupeKey}';
      _scheduled[key] = ReminderScheduleRecord(
        eventId: event.id,
        dedupeKey: r.dedupeKey,
        fireAt: fireAt,
      );
    }
  }

  bool wasDeduped(String eventId, String dedupeKey) =>
      _scheduled.containsKey('$eventId:$dedupeKey');
}

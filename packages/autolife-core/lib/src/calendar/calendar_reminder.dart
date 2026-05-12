import 'package:meta/meta.dart';

/// Reminder relative to event start; persisted in `calendar_events.reminders` jsonb.
@immutable
class CalendarReminder {
  const CalendarReminder({
    required this.offsetBeforeStart,
    required this.dedupeKey,
    this.quietHoursAware = true,
  });

  /// Offset added to [CalendarEvent.startAt] to get notification time.
  /// Use **negative** durations for "before start" (e.g. `-15 minutes`);
  /// **zero** fires at start; positive values fire after start.
  final Duration offsetBeforeStart;

  /// Stable per-event reminder id for deduped notification dispatch.
  final String dedupeKey;
  final bool quietHoursAware;

  Map<String, dynamic> toJson() => {
    'offset_ms': offsetBeforeStart.inMilliseconds,
    'dedupe_key': dedupeKey,
    'quiet_hours_aware': quietHoursAware,
  };

  factory CalendarReminder.fromJson(Map<String, dynamic> json) {
    final ms = (json['offset_ms'] as num?)?.toInt() ?? 0;
    return CalendarReminder(
      offsetBeforeStart: Duration(milliseconds: ms),
      dedupeKey: json['dedupe_key'] as String? ?? 'default',
      quietHoursAware: json['quiet_hours_aware'] as bool? ?? true,
    );
  }
}

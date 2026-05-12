import 'package:meta/meta.dart';

/// How a user edits one instance of a recurring series.
enum SeriesEditScope {
  /// Edit only this occurrence (creates exception + instance row).
  thisOccurrence,

  /// Edit this and future occurrences (split series).
  thisAndFollowing,

  /// Edit the entire series (master rule).
  allEventsInSeries,
}

/// RFC5545-aligned subset used by AutoLife calendar + Postgres `recurrence` jsonb.
enum RecurrenceFrequency { daily, weekly, monthly, yearly }

@immutable
class CalendarRecurrenceRule {
  const CalendarRecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.byWeekday = const [],
    this.until,
    this.count,
  }) : assert(interval >= 1);

  final RecurrenceFrequency frequency;
  final int interval;

  /// Monday=1 … Sunday=7 (ISO weekday), empty = every day in freq bucket.
  final List<int> byWeekday;
  final DateTime? until;
  final int? count;

  Map<String, dynamic> toJson() => {
    'frequency': frequency.name,
    'interval': interval,
    'by_weekday': byWeekday,
    if (until != null) 'until': until!.toUtc().toIso8601String(),
    if (count != null) 'count': count,
  };

  factory CalendarRecurrenceRule.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const CalendarRecurrenceRule(frequency: RecurrenceFrequency.daily);
    }
    final freq = RecurrenceFrequency.values.firstWhere(
      (e) => e.name == json['frequency'],
      orElse: () => RecurrenceFrequency.daily,
    );
    final wd = <int>[];
    final rawWd = json['by_weekday'];
    if (rawWd is List) {
      for (final e in rawWd) {
        if (e is int) {
          wd.add(e);
        } else if (e is num) {
          wd.add(e.toInt());
        }
      }
    }
    DateTime? until;
    final u = json['until'];
    if (u is String) until = DateTime.tryParse(u)?.toUtc();
    final c = json['count'];
    return CalendarRecurrenceRule(
      frequency: freq,
      interval: (json['interval'] as num?)?.toInt().clamp(1, 999) ?? 1,
      byWeekday: wd,
      until: until,
      count: c is num ? c.toInt() : null,
    );
  }
}

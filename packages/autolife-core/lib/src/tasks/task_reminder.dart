import 'package:meta/meta.dart';

/// Reminder for a task (mirrors [CalendarReminder] semantics).
@immutable
class TaskReminder {
  const TaskReminder({
    required this.offsetBeforeDue,
    required this.dedupeKey,
    this.quietHoursAware = true,
    /// When true, [offsetBeforeDue] is relative to [Task.dueAt] when set,
    /// otherwise treated as offset from [Task.scheduledFor].
    this.anchorToDue = true,
  });

  final Duration offsetBeforeDue;
  final String dedupeKey;
  final bool quietHoursAware;
  final bool anchorToDue;

  Map<String, dynamic> toJson() => {
    'offset_ms': offsetBeforeDue.inMilliseconds,
    'dedupe_key': dedupeKey,
    'quiet_hours_aware': quietHoursAware,
    'anchor_to_due': anchorToDue,
  };

  factory TaskReminder.fromJson(Map<String, dynamic> json) {
    final ms = (json['offset_ms'] as num?)?.toInt() ?? 0;
    return TaskReminder(
      offsetBeforeDue: Duration(milliseconds: ms),
      dedupeKey: json['dedupe_key'] as String? ?? 'default',
      quietHoursAware: json['quiet_hours_aware'] as bool? ?? true,
      anchorToDue: json['anchor_to_due'] as bool? ?? true,
    );
  }
}

import 'package:autolife_core/autolife_core.dart';
import 'package:uuid/uuid.dart';

/// Spawns the next task instance when a recurring task is completed.
class RecurrenceTaskSpawn {
  const RecurrenceTaskSpawn();

  /// Returns null if no recurrence.
  Task? nextAfterComplete(Task completed) {
    final rule = completed.recurrenceRule;
    if (rule == null) return null;
    final now = DateTime.now().toUtc();
    final base = completed.dueAt ?? completed.scheduledFor ?? now;
    DateTime? nextDue;
    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        nextDue = base.add(Duration(days: rule.interval));
      case RecurrenceFrequency.weekly:
        nextDue = base.add(Duration(days: 7 * rule.interval));
      case RecurrenceFrequency.monthly:
        nextDue = DateTime.utc(
          base.year,
          base.month + rule.interval,
          base.day,
          base.hour,
          base.minute,
        );
      case RecurrenceFrequency.yearly:
        nextDue = DateTime.utc(
          base.year + rule.interval,
          base.month,
          base.day,
          base.hour,
          base.minute,
        );
    }
    final seriesId = completed.seriesId ?? completed.id;
    return completed.copyWith(
      id: const Uuid().v4(),
      status: TaskStatus.inbox,
      dueAt: nextDue,
      seriesId: seriesId,
      completedAt: null,
      completedBy: null,
      createdAt: now,
      updatedAt: now,
    );
  }
}

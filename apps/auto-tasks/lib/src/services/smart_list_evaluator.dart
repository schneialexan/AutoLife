import 'package:autolife_core/autolife_core.dart';

/// Applies [TaskSmartRule] to tasks in memory / repository projections.
class SmartListEvaluator {
  const SmartListEvaluator();

  bool matches({
    required Task task,
    required TaskSmartRule rule,
    required DateTime nowUtc,
    required String? currentUserId,
  }) {
    if (rule.listIdsAny.isNotEmpty && !rule.listIdsAny.contains(task.listId)) {
      return false;
    }
    if (rule.sourceModuleIn.isNotEmpty) {
      final m = task.sourceModule;
      if (m == null || !rule.sourceModuleIn.contains(m)) return false;
    }
    if (rule.tagsAny.isNotEmpty) {
      final has = rule.tagsAny.any(task.tags.contains);
      if (!has) return false;
    }
    if (rule.assigneeIdsAny.isNotEmpty && currentUserId != null) {
      if (!rule.assigneeIdsAny.any(task.assigneeIds.contains)) return false;
    } else if (rule.assigneeIdsAny.isNotEmpty) {
      if (!rule.assigneeIdsAny.any(task.assigneeIds.contains)) return false;
    }
    if (rule.priorityAtLeast != null) {
      final order = [TaskPriority.low, TaskPriority.medium, TaskPriority.high];
      final minIx = order.indexOf(rule.priorityAtLeast!);
      final tIx = order.indexOf(task.priority);
      if (tIx < minIx) return false;
    }
    final d = rule.dueWithinDays;
    if (d != null) {
      final due = task.dueAt;
      if (due == null) return false;
      final end = nowUtc.add(Duration(days: d));
      if (due.isAfter(end)) return false;
    }
    return true;
  }

  List<Task> filter({
    required Iterable<Task> tasks,
    required TaskSmartRule rule,
    required DateTime nowUtc,
    String? currentUserId,
  }) {
    return tasks
        .where(
          (t) => matches(
            task: t,
            rule: rule,
            nowUtc: nowUtc,
            currentUserId: currentUserId,
          ),
        )
        .toList();
  }
}

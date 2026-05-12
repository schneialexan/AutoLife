/// Task priority (distinct from [Task.importance] / star).
enum TaskPriority { low, medium, high }

extension TaskPriorityName on TaskPriority {
  String get wireName => name;
}

TaskPriority? taskPriorityFromWire(String? raw) {
  if (raw == null) return null;
  for (final v in TaskPriority.values) {
    if (v.name == raw) return v;
  }
  return null;
}

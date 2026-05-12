enum TaskStatus { inbox, active, completed, canceled }

TaskStatus taskStatusFromWire(String raw) {
  for (final v in TaskStatus.values) {
    if (v.name == raw) return v;
  }
  return TaskStatus.inbox;
}

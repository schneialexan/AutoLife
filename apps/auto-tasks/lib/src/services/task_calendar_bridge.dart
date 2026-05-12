import 'package:autolife_core/autolife_core.dart';
import 'package:uuid/uuid.dart';

/// Cross-module calendar ↔ tasks bridge (idempotent on `sourceEventId`).
class TaskCalendarBridge {
  TaskCalendarBridge({
    required this.taskRepo,
    required this.calendarRepo,
    required this.tasksEmitter,
    required this.calendarEmitter,
    required this.actorId,
  });

  final TaskRepository taskRepo;
  final CalendarRepository calendarRepo;
  final TasksEventsEmitter tasksEmitter;
  final CalendarEventsEmitter calendarEmitter;
  final String actorId;

  EventEnvelope _taskEnv(String key) => EventEnvelope(
    idempotencyKey: key,
    orderingTag: key,
    occurredAt: DateTime.now().toUtc(),
    sourceModule: kTasksModuleName,
  );

  /// Consumes payload from `event.convert_to_task` (`{ event: CalendarEvent json }`).
  Future<Task> onConvertToTaskEnvelope(
    Map<String, dynamic> payload,
    String targetListId,
  ) async {
    final ev = payload['event'];
    if (ev is! Map<String, dynamic>) {
      throw ArgumentError('event.convert_to_task missing event map');
    }
    final event = CalendarEvent.fromJson(ev);
    final existing = await _findBySourceEvent(event.familyId, event.id);
    if (existing != null) return existing;

    final now = DateTime.now().toUtc();
    final task = Task(
      id: const Uuid().v4(),
      familyId: event.familyId,
      listId: targetListId,
      title: event.title,
      description: event.description ?? event.notes,
      status: TaskStatus.inbox,
      priority: TaskPriority.medium,
      importance: false,
      dueAt: event.startAt,
      scheduledFor: event.startAt,
      sourceEventId: event.id,
      reminders: const [],
      createdBy: actorId,
      createdAt: now,
      updatedAt: now,
    );
    await taskRepo.upsertTask(task);
    await tasksEmitter.emitCreated(task, _taskEnv('task:create:${task.id}'));
    return task;
  }

  Future<Task?> _findBySourceEvent(String familyId, String eventId) async {
    // TaskRepository has no listAll; Memory implementation used in apps.
    if (taskRepo is MemoryTaskRepository) {
      final m = taskRepo as MemoryTaskRepository;
      for (final t in m.snapshotTasks(familyId)) {
        if (t.sourceEventId == eventId) return t;
      }
    }
    return null;
  }

  Future<void> promoteTaskToEvent(Task task, EventEnvelope envelope) async {
    final now = DateTime.now().toUtc();
    final start = task.scheduledFor ?? task.dueAt ?? now;
    final event = CalendarEvent(
      id: const Uuid().v4(),
      familyId: task.familyId,
      title: task.title,
      description: task.description,
      startAt: start,
      endAt: start.add(task.estimatedDuration ?? const Duration(hours: 1)),
      allDay: false,
      createdBy: actorId,
      syncSource: 'internal',
      linkedTaskId: task.id,
      createdAt: now,
      updatedAt: now,
    );
    await calendarRepo.upsert(event);
    final completed = task.copyWith(
      status: TaskStatus.completed,
      sourceTaskId: event.id,
      completedAt: now,
      completedBy: actorId,
      updatedAt: now,
    );
    await taskRepo.upsertTask(completed);
    await tasksEmitter.emitPromoteToEvent(task: completed, envelope: envelope);
    await calendarEmitter.emitCreated(event, envelope);
  }

  Future<CalendarEvent> scheduleTaskBlock({
    required Task task,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    final env = _taskEnv(
      'task:scheduled:${task.id}:${startUtc.millisecondsSinceEpoch}',
    );
    final now = DateTime.now().toUtc();
    final event = CalendarEvent(
      id: const Uuid().v4(),
      familyId: task.familyId,
      title: task.title,
      description: 'Task block',
      startAt: startUtc,
      endAt: endUtc,
      allDay: false,
      createdBy: actorId,
      syncSource: 'internal',
      isTaskBlock: true,
      linkedTaskId: task.id,
      createdAt: now,
      updatedAt: now,
    );
    await calendarRepo.upsert(event);
    final updated = task.copyWith(
      scheduledEventId: event.id,
      scheduledFor: startUtc,
      estimatedDuration: endUtc.difference(startUtc),
      updatedAt: now,
    );
    await taskRepo.upsertTask(updated);
    await tasksEmitter.emitScheduled(
      taskId: task.id,
      familyId: task.familyId,
      startAt: startUtc,
      endAt: endUtc,
      linkedEventId: event.id,
      envelope: env,
    );
    await calendarEmitter.emitCreated(event, env);
    return event;
  }

  /// Handles `event.linked_task_update` from calendar when a task block moves.
  Future<void> onLinkedTaskUpdateEnvelope(Map<String, dynamic> payload) async {
    final familyId = payload['family_id'] as String?;
    final tid = payload['linked_task_id'] as String?;
    final startRaw = payload['start_at'] as String?;
    final endRaw = payload['end_at'] as String?;
    if (familyId == null || tid == null || startRaw == null || endRaw == null) {
      return;
    }
    final task = await taskRepo.getTask(familyId: familyId, taskId: tid);
    if (task == null) return;
    final start = DateTime.parse(startRaw).toUtc();
    final end = DateTime.parse(endRaw).toUtc();
    final now = DateTime.now().toUtc();
    await taskRepo.upsertTask(
      task.copyWith(
        scheduledFor: start,
        estimatedDuration: end.difference(start),
        updatedAt: now,
      ),
    );
  }
}

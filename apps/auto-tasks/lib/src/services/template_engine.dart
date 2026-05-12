import 'package:autolife_core/autolife_core.dart';
import 'package:uuid/uuid.dart';

/// Expands [TaskTemplate] into concrete tasks and dependency edges.
class TemplateEngine {
  const TemplateEngine();

  /// Creates one task per template item; prerequisite indices map to generated ids.
  Future<List<Task>> apply({
    required TaskTemplate template,
    required String listId,
    required String familyId,
    required String createdBy,
    required DateTime anchorUtc,
    required MemoryTaskRepository repo,
  }) async {
    final items = template.items;
    final ids = List.generate(items.length, (_) => const Uuid().v4());
    final now = DateTime.now().toUtc();
    final tasks = <Task>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      DateTime? due;
      if (item.dueOffsetMinutes != null) {
        due = anchorUtc.add(Duration(minutes: item.dueOffsetMinutes!));
      }
      tasks.add(
        Task(
          id: ids[i],
          familyId: familyId,
          listId: listId,
          title: item.title,
          description: item.description,
          status: TaskStatus.active,
          priority: item.priority,
          importance: false,
          dueAt: due,
          steps: item.steps,
          tags: item.tags,
          assigneeIds: item.assigneeIds,
          createdBy: createdBy,
          requiresApproval: false,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    for (final t in tasks) {
      await repo.upsertTask(t);
    }
    for (var i = 0; i < items.length; i++) {
      for (final pi in items[i].prerequisiteIndices) {
        if (pi < 0 || pi >= ids.length || pi == i) continue;
        await repo.addDependency(
          TaskDependency(
            id: const Uuid().v4(),
            familyId: familyId,
            taskId: ids[i],
            prerequisiteTaskId: ids[pi],
            createdAt: now,
          ),
        );
      }
    }
    return tasks;
  }
}

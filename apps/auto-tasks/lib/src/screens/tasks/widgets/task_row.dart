import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/screens/tasks/task_detail_screen.dart';
import 'package:auto_tasks/src/screens/tasks/widgets/dependency_chip.dart';
import 'package:auto_tasks/src/screens/tasks/widgets/snooze_sheet.dart';
import 'package:auto_tasks/src/services/dependency_resolver.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TaskRow extends ConsumerWidget {
  const TaskRow({super.key, required this.task, required this.familyId});

  final Task task;
  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(taskRepositoryProvider);
    final bulk = ref.watch(taskBulkModeProvider);
    final selected = ref.watch(taskBulkSelectionProvider);
    final deps = repo.snapshotDependencies(familyId);
    final all = repo.snapshotTasks(familyId);
    final resolver = const DependencyResolver();
    var locked = false;
    try {
      locked = resolver.isLocked(task: task, allTasks: all, edges: deps);
    } on TaskDependencyCycleException {
      locked = true;
    }

    final timeFmt = DateFormat.jm('en');
    final due = task.dueAt != null ? timeFmt.format(task.dueAt!.toLocal()) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: bulk
            ? Checkbox(
                value: selected.contains(task.id),
                onChanged: (v) {
                  final next = Set<String>.from(selected);
                  if (v == true) {
                    next.add(task.id);
                  } else {
                    next.remove(task.id);
                  }
                  ref.read(taskBulkSelectionProvider.notifier).state = next;
                },
              )
            : Checkbox(
                value: task.status == TaskStatus.completed,
                onChanged: locked
                    ? null
                    : (v) async {
                        final now = DateTime.now().toUtc();
                        if (v == true) {
                          await repo.upsertTask(
                            task.copyWith(
                              status: TaskStatus.completed,
                              completedAt: now,
                              completedBy:
                                  ref.read(taskCurrentUserIdProvider),
                              updatedAt: now,
                            ),
                          );
                        } else {
                          await repo.upsertTask(
                            task.copyWith(
                              status: TaskStatus.active,
                              completedAt: null,
                              completedBy: null,
                              updatedAt: now,
                            ),
                          );
                        }
                      },
              ),
        title: Text(task.title),
        subtitle: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (due != null) Text('Due $due'),
            if (task.importance) const Icon(Icons.star, size: 16),
            if (locked) const DependencyChip(),
            if (task.requiresApproval)
              const Chip(
                label: Text('Approval'),
                visualDensity: VisualDensity.compact,
              ),
            if (task.sourceEventId != null)
              const Icon(Icons.calendar_month, size: 16),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Snooze'),
                      onTap: () {
                        Navigator.pop(ctx);
                        showSnoozeSheet(context, ref, task);
                      },
                    ),
                    ListTile(
                      title: Text(
                        task.importance ? 'Remove star' : 'Star',
                      ),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await repo.upsertTask(
                          task.copyWith(
                            importance: !task.importance,
                            updatedAt: DateTime.now().toUtc(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TaskDetailScreen(
                familyId: familyId,
                taskId: task.id,
              ),
            ),
          );
        },
        onLongPress: () {
          ref.read(taskBulkModeProvider.notifier).state = true;
          ref.read(taskBulkSelectionProvider.notifier).state = {task.id};
        },
      ),
    );
  }
}

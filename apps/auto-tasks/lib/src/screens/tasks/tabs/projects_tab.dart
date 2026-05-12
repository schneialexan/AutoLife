import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/screens/tasks/widgets/task_row.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectsTab extends ConsumerWidget {
  const ProjectsTab({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listId = ref.watch(taskSelectedListIdProvider);
    final repo = ref.watch(taskRepositoryProvider);
    return StreamBuilder<List<Task>>(
      stream: repo.watchFamilyTasks(familyId),
      builder: (context, snap) {
        var list = (snap.data ?? const [])
            .where(
              (t) =>
                  t.status == TaskStatus.active &&
                  (t.steps.isNotEmpty || t.tags.isNotEmpty),
            )
            .toList();
        if (listId != null) {
          list = list.where((t) => t.listId == listId).toList();
        }
        if (list.isEmpty) {
          return const Center(child: Text('No active projects in this list'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: list.length,
          itemBuilder: (c, i) => TaskRow(task: list[i], familyId: familyId),
        );
      },
    );
  }
}

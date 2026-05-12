import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/screens/tasks/widgets/task_row.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlannedTab extends ConsumerWidget {
  const PlannedTab({super.key, required this.familyId});

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
                  t.status != TaskStatus.completed &&
                  (t.dueAt != null || t.scheduledFor != null),
            )
            .toList();
        if (listId != null) {
          list = list.where((t) => t.listId == listId).toList();
        }
        list.sort(
          (a, b) => (a.dueAt ?? a.scheduledFor ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(b.dueAt ?? b.scheduledFor ?? DateTime.fromMillisecondsSinceEpoch(0)),
        );
        if (list.isEmpty) {
          return const Center(child: Text('No planned tasks'));
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

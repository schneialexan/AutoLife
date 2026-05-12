import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/screens/tasks/widgets/task_row.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

List<Task> _byList(Iterable<Task> tasks, String? listId) {
  if (listId == null) return tasks.toList();
  return tasks.where((t) => t.listId == listId).toList();
}

class InboxTab extends ConsumerWidget {
  const InboxTab({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listId = ref.watch(taskSelectedListIdProvider);
    final repo = ref.watch(taskRepositoryProvider);
    return StreamBuilder<List<Task>>(
      stream: repo.watchFamilyTasks(familyId),
      builder: (context, snap) {
        final open = _byList(snap.data ?? const [], listId)
            .where((t) => t.status == TaskStatus.inbox)
            .toList();
        if (open.isEmpty) return const Center(child: Text('Inbox empty'));
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: open.length,
          itemBuilder: (c, i) => TaskRow(task: open[i], familyId: familyId),
        );
      },
    );
  }
}

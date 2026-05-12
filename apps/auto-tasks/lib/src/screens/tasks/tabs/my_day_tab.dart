import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/screens/tasks/widgets/my_day_suggestions_panel.dart';
import 'package:auto_tasks/src/screens/tasks/widgets/task_row.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDayTab extends ConsumerWidget {
  const MyDayTab({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(taskRepositoryProvider);
    final today = DateTime.now().toUtc();
    final bucket = DateTime.utc(today.year, today.month, today.day);
    return StreamBuilder<List<Task>>(
      stream: repo.watchFamilyTasks(familyId),
      builder: (context, snap) {
        final tasks = snap.data ?? const [];
        final myDay = tasks
            .where(
              (t) =>
                  t.myDayDate != null &&
                  t.myDayDate!.year == bucket.year &&
                  t.myDayDate!.month == bucket.month &&
                  t.myDayDate!.day == bucket.day &&
                  t.status != TaskStatus.completed,
            )
            .toList();
        return ListView(
          padding: const EdgeInsets.all(8),
          children: [
            MyDaySuggestionsPanel(familyId: familyId, tasks: tasks),
            const SizedBox(height: 8),
            if (myDay.isEmpty)
              const Text('Nothing in My Day yet. Try suggestions below.')
            else
              ...myDay.map((t) => TaskRow(task: t, familyId: familyId)),
          ],
        );
      },
    );
  }
}

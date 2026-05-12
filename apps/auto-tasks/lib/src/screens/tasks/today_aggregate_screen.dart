import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/screens/tasks/widgets/task_row.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodayAggregateScreen extends ConsumerWidget {
  const TodayAggregateScreen({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(taskRepositoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Today (all lists)')),
      body: StreamBuilder<List<Task>>(
        stream: repo.watchFamilyTasks(familyId),
        builder: (context, snap) {
          final now = DateTime.now().toUtc();
          final day = DateTime.utc(now.year, now.month, now.day);
          final next = day.add(const Duration(days: 14));
          final list = (snap.data ?? const [])
              .where((t) {
                final d = t.dueAt;
                if (d == null || t.status == TaskStatus.completed) return false;
                return !d.isBefore(day) && !d.isAfter(next);
              })
              .toList()
            ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
          if (list.isEmpty) {
            return const Center(child: Text('No tasks in the next 14 days'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: list.length,
            itemBuilder: (c, i) => TaskRow(task: list[i], familyId: familyId),
          );
        },
      ),
    );
  }
}

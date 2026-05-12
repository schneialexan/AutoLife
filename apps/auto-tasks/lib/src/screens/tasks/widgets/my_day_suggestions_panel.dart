import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Suggestions: overdue, scheduled today, recent adds.
class MyDaySuggestionsPanel extends ConsumerWidget {
  const MyDaySuggestionsPanel({
    super.key,
    required this.familyId,
    required this.tasks,
  });

  final String familyId;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final overdue = tasks
        .where(
          (t) =>
              t.dueAt != null &&
              t.dueAt!.isBefore(now) &&
              t.status != TaskStatus.completed,
        )
        .take(5)
        .toList();
    final schedToday = tasks
        .where(
          (t) =>
              t.scheduledFor != null &&
              t.scheduledFor!.year == today.year &&
              t.scheduledFor!.month == today.month &&
              t.scheduledFor!.day == today.day &&
              t.status != TaskStatus.completed,
        )
        .take(5)
        .toList();
    if (overdue.isEmpty && schedToday.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suggestions',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (overdue.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Overdue', style: Theme.of(context).textTheme.labelMedium),
              ...overdue.map(
                (t) => ListTile(
                  dense: true,
                  title: Text(t.title),
                  trailing: TextButton(
                    child: const Text('Add to My Day'),
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.upsertTask(
                        t.copyWith(
                          myDayDate: today,
                          updatedAt: DateTime.now().toUtc(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            if (schedToday.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Scheduled today', style: Theme.of(context).textTheme.labelMedium),
              ...schedToday.map(
                (t) => ListTile(
                  dense: true,
                  title: Text(t.title),
                  trailing: TextButton(
                    child: const Text('Add to My Day'),
                    onPressed: () async {
                      final repo = ref.read(taskRepositoryProvider);
                      await repo.upsertTask(
                        t.copyWith(
                          myDayDate: today,
                          updatedAt: DateTime.now().toUtc(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

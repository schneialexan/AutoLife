import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BulkActionBar extends ConsumerWidget {
  const BulkActionBar({super.key, required this.familyId});

  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(taskBulkModeProvider);
    final sel = ref.watch(taskBulkSelectionProvider);
    if (!on) return const SizedBox.shrink();
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Text('${sel.length} selected'),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final repo = ref.read(taskRepositoryProvider);
                  final now = DateTime.now().toUtc();
                  for (final id in sel) {
                    final t = await repo.getTask(familyId: familyId, taskId: id);
                    if (t == null) continue;
                    await repo.upsertTask(
                      t.copyWith(importance: true, updatedAt: now),
                    );
                  }
                  ref.read(taskBulkSelectionProvider.notifier).state = {};
                  ref.read(taskBulkModeProvider.notifier).state = false;
                },
                child: const Text('Star all'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(taskBulkSelectionProvider.notifier).state = {};
                  ref.read(taskBulkModeProvider.notifier).state = false;
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

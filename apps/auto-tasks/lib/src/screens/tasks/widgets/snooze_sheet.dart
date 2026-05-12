import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showSnoozeSheet(
  BuildContext context,
  WidgetRef ref,
  Task task,
) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Tomorrow'),
            onTap: () async {
              final repo = ref.read(taskRepositoryProvider);
              final tomorrow = DateTime.now().toUtc().add(const Duration(days: 1));
              final d = DateTime.utc(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
              await repo.upsertTask(
                task.copyWith(
                  scheduledFor: d,
                  updatedAt: DateTime.now().toUtc(),
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
          ListTile(
            title: const Text('Next week'),
            onTap: () async {
              final repo = ref.read(taskRepositoryProvider);
              final d = DateTime.now().toUtc().add(const Duration(days: 7));
              await repo.upsertTask(
                task.copyWith(
                  scheduledFor: d,
                  updatedAt: DateTime.now().toUtc(),
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
          ),
        ],
      ),
    ),
  );
}

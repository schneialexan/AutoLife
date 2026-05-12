import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ListSettingsScreen extends ConsumerWidget {
  const ListSettingsScreen({
    super.key,
    required this.familyId,
    required this.listId,
  });

  final String familyId;
  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(taskRepositoryProvider);
    return StreamBuilder<List<TaskList>>(
      stream: repo.watchLists(familyId),
      builder: (context, snap) {
        final list =
            (snap.data ?? const []).firstWhereOrNull((l) => l.id == listId);
        if (list == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('List')),
            body: const Center(child: Text('List not found')),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(list.name)),
          body: ListView(
            children: [
              SwitchListTile(
                title: const Text('Smart list'),
                subtitle: const Text('TaskSmartRule editor — phase 3.3+'),
                value: list.isSmart,
                onChanged: (v) {
                  repo.upsertList(list.copyWith(isSmart: v));
                },
              ),
              const ListTile(
                title: Text('Sharing'),
                subtitle: Text('Phase 2.3 + guest links'),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/screens/tasks/task_lists_screen.dart';
import 'package:auto_tasks/src/seed/demo_tasks_seed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Embeddable tasks module (shell wraps with [ProviderScope]).
class TasksModule extends ConsumerStatefulWidget {
  const TasksModule({
    super.key,
    required this.familyId,
    this.showAppBar = true,
  });

  final String familyId;
  final bool showAppBar;

  @override
  ConsumerState<TasksModule> createState() => _TasksModuleState();
}

class _TasksModuleState extends ConsumerState<TasksModule> {
  var _seeded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_seeded) return;
      final repo = ref.read(taskRepositoryProvider);
      repo.seedLists(demoTaskLists(widget.familyId));
      repo.seedTasks(demoTasks(widget.familyId));
      ref.read(taskSelectedListIdProvider.notifier).state =
          demoTaskLists(widget.familyId).first.id;
      _seeded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TaskListsScreen(
      familyId: widget.familyId,
      showAppBar: widget.showAppBar,
    );
  }
}

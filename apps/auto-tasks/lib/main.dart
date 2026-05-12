import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/tasks_module.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  final repo = MemoryTaskRepository();
  runApp(
    ProviderScope(
      overrides: [
        taskRepositoryProvider.overrideWithValue(repo),
      ],
      child: const _AutoTasksApp(),
    ),
  );
}

class _AutoTasksApp extends ConsumerWidget {
  const _AutoTasksApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId = ref.watch(taskFamilyIdProvider);
    return MaterialApp(
      title: 'Auto Tasks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyB, meta: true): () {
            ref.read(taskBulkModeProvider.notifier).state =
                !ref.read(taskBulkModeProvider);
          },
          const SingleActivator(LogicalKeyboardKey.keyB, control: true): () {
            ref.read(taskBulkModeProvider.notifier).state =
                !ref.read(taskBulkModeProvider);
          },
        },
        child: Focus(
          autofocus: true,
          child: TasksModule(familyId: familyId),
        ),
      ),
    );
  }
}

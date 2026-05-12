import 'package:auto_calendar/src/calendar_module.dart';
import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  final repo = MemoryCalendarRepository();
  final taskRepo = MemoryTaskRepository();
  final now = DateTime.now().toUtc();
  const fam = 'demo-family';
  taskRepo.seedLists([
    TaskList(
      id: 'list-grocery',
      familyId: fam,
      name: 'Groceries',
      createdAt: now,
      updatedAt: now,
    ),
  ]);
  taskRepo.seedTasks([
    Task(
      id: 'task-due-sample',
      familyId: fam,
      listId: 'list-grocery',
      title: 'Buy milk',
      status: TaskStatus.active,
      priority: TaskPriority.medium,
      importance: false,
      dueAt: DateTime.utc(now.year, now.month, now.day, 17, 0),
      createdBy: '11111111-1111-1111-1111-111111111111',
      createdAt: now,
      updatedAt: now,
    ),
  ]);
  runApp(
    ProviderScope(
      overrides: [
        calendarRepositoryProvider.overrideWithValue(repo),
        calendarTaskRepositoryProvider.overrideWithValue(taskRepo),
      ],
      child: const AutoCalendarApp(),
    ),
  );
}

class AutoCalendarApp extends ConsumerWidget {
  const AutoCalendarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId = ref.watch(calendarFamilyIdProvider);
    return MaterialApp(
      title: 'Auto Calendar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: CallbackShortcuts(
        bindings: calendarShortcutBindings(ref),
        child: Focus(
          autofocus: true,
          child: CalendarModule(
            familyId: familyId,
          ),
        ),
      ),
    );
  }
}

Map<ShortcutActivator, VoidCallback> calendarShortcutBindings(WidgetRef ref) {
  return {
    const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
        ref.read(calendarQuickCreateSignalProvider.notifier).state++,
    const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
        ref.read(calendarQuickCreateSignalProvider.notifier).state++,
    const SingleActivator(LogicalKeyboardKey.keyT, meta: true): () =>
        ref.read(calendarGoToTodaySignalProvider.notifier).state++,
    const SingleActivator(LogicalKeyboardKey.keyT, control: true): () =>
        ref.read(calendarGoToTodaySignalProvider.notifier).state++,
  };
}

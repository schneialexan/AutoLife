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
  runApp(
    ProviderScope(
      overrides: [
        calendarRepositoryProvider.overrideWithValue(repo),
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

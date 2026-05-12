import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Repository + family scope (shell overrides in phase 4).
// ---------------------------------------------------------------------------
final taskRepositoryProvider = Provider<MemoryTaskRepository>((ref) {
  return MemoryTaskRepository();
});

final taskFamilyIdProvider = Provider<String>((ref) => 'demo-family');

final taskCurrentUserIdProvider = Provider<String>(
  (ref) => '11111111-1111-1111-1111-111111111111',
);

/// Known user ids for assignee pickers (shell will inject membership later).
final taskKnownAssigneeIdsProvider = Provider<List<String>>((ref) {
  final me = ref.watch(taskCurrentUserIdProvider);
  return [me, '22222222-2222-2222-2222-222222222222'];
});

/// Selected list for tab content (non-smart physical list).
final taskSelectedListIdProvider = StateProvider<String?>((ref) => null);

/// Bulk select mode.
final taskBulkModeProvider = StateProvider<bool>((ref) => false);

final taskBulkSelectionProvider =
    StateProvider<Set<String>>((ref) => <String>{});

const _kShowTasksOnCalendar = 'auto_calendar.show_tasks_on_calendar';

final taskOverlayOnCalendarProvider =
    StateNotifierProvider<TaskOverlayPrefsNotifier, bool>((ref) {
  return TaskOverlayPrefsNotifier();
});

class TaskOverlayPrefsNotifier extends StateNotifier<bool> {
  TaskOverlayPrefsNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = p.getBool(_kShowTasksOnCalendar) ?? true;
  }

  Future<void> setShow(bool v) async {
    state = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kShowTasksOnCalendar, v);
  }
}

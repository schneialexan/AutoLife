import 'package:autolife_core/autolife_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum CalendarViewMode { day, week, month, agenda }

/// Phone-only layout when [CalendarViewMode.week] is selected.
enum MobileWeekMode {
  /// Horizontally paged week table: two day-columns per page (Sun alone on last page).
  threeDaySwipe,

  /// Single scroll: all seven days stacked with headers.
  stackedAgenda,
}

/// Below this width, week view uses mobile layouts (2-day table pager / agenda).
const double kCalendarWeekPhoneLayoutWidth = 600;

const _kPrefCalendarViewMode = 'auto_calendar.selected_view_mode';
const _kPrefMobileWeekMode = 'auto_calendar.mobile_week_mode';

CalendarViewMode? _parseCalendarViewMode(String? raw) {
  if (raw == null) return null;
  for (final v in CalendarViewMode.values) {
    if (v.name == raw) return v;
  }
  return null;
}

MobileWeekMode? _parseMobileWeekMode(String? raw) {
  if (raw == null) return null;
  for (final v in MobileWeekMode.values) {
    if (v.name == raw) return v;
  }
  return null;
}

DateTime calendarUtcDateOnly(DateTime d) {
  final u = d.toUtc();
  return DateTime.utc(u.year, u.month, u.day);
}

bool calendarIsSameUtcDate(DateTime a, DateTime b) {
  final ua = calendarUtcDateOnly(a);
  final ub = calendarUtcDateOnly(b);
  return ua.year == ub.year && ua.month == ub.month && ua.day == ub.day;
}

/// Wall-clock "now" for today checks; override in tests for deterministic UI.
final calendarTodayUtcProvider = Provider<DateTime>((ref) {
  return DateTime.now().toUtc();
});

final calendarFamilyIdProvider = Provider<String>((ref) => 'demo-family');

final calendarRepositoryProvider =
    Provider<CalendarRepository>((ref) => MemoryCalendarRepository());

/// Demo member profiles for chips / palette borders (ids are arbitrary UUID strings).
final calendarMemberSeedsProvider = Provider<List<CalendarMemberSeed>>((ref) {
  return const [
    CalendarMemberSeed(id: '11111111-1111-1111-1111-111111111111', label: 'Alex', colorHex: '#E53935'),
    CalendarMemberSeed(id: '22222222-2222-2222-2222-222222222222', label: 'Sam', colorHex: '#1E88E5'),
    CalendarMemberSeed(id: '33333333-3333-3333-3333-333333333333', label: 'Riley', colorHex: '#43A047'),
  ];
});

/// Persists last main calendar view (day/week/month/agenda).
class CalendarViewPrefsNotifier extends StateNotifier<CalendarViewMode> {
  CalendarViewPrefsNotifier({this.restoreFromDisk = true})
      : super(CalendarViewMode.month) {
    if (restoreFromDisk) {
      _restore();
    }
  }

  /// Fixed initial mode without disk I/O (widget/integration tests).
  CalendarViewPrefsNotifier.seeded(super.mode) : restoreFromDisk = false;

  final bool restoreFromDisk;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final parsed = _parseCalendarViewMode(
      prefs.getString(_kPrefCalendarViewMode),
    );
    if (parsed != null) {
      state = parsed;
    }
  }

  Future<void> setView(CalendarViewMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    await prefs.setString(_kPrefCalendarViewMode, mode.name);
  }
}

final calendarSelectedViewProvider =
    StateNotifierProvider<CalendarViewPrefsNotifier, CalendarViewMode>((ref) {
  return CalendarViewPrefsNotifier();
});

final calendarAnchorProvider =
    StateProvider<DateTime>((ref) => DateTime.now().toUtc());

final calendarMemberFilterProvider = StateProvider<String?>((ref) => null);

final calendarQuickCreateSignalProvider = StateProvider<int>((ref) => 0);

final calendarGoToTodaySignalProvider = StateProvider<int>((ref) => 0);

/// Control-center flags (phase 3.13 will source real prefs).
final calendarCommuteEnabledProvider = Provider<bool>((ref) => true);

final calendarWeatherStressProvider = Provider<double>((ref) => 0.5);

const _kPrefShowTasksOnCalendar = 'auto_calendar.show_tasks_on_calendar';

/// In-memory task list for calendar overlay + convert flows (override in shell).
final calendarTaskRepositoryProvider =
    Provider<MemoryTaskRepository>((ref) => MemoryTaskRepository());

class CalendarShowTasksOverlayNotifier extends StateNotifier<bool> {
  CalendarShowTasksOverlayNotifier({this.restoreFromDisk = true})
      : super(true) {
    if (restoreFromDisk) _restore();
  }

  CalendarShowTasksOverlayNotifier.seeded(super.initial)
      : restoreFromDisk = false;

  final bool restoreFromDisk;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    state = prefs.getBool(_kPrefShowTasksOnCalendar) ?? true;
  }

  Future<void> setShow(bool v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    await prefs.setBool(_kPrefShowTasksOnCalendar, v);
  }
}

final calendarShowTasksOverlayProvider =
    StateNotifierProvider<CalendarShowTasksOverlayNotifier, bool>((ref) {
  return CalendarShowTasksOverlayNotifier();
});

/// Incomplete tasks with `dueAt` on the same UTC calendar day as [dayUtc].
final tasksDueOnDayProvider =
    Provider.family<List<Task>, DateTime>((ref, dayUtc) {
  final show = ref.watch(calendarShowTasksOverlayProvider);
  if (!show) return const [];
  final repo = ref.watch(calendarTaskRepositoryProvider);
  final familyId = ref.watch(calendarFamilyIdProvider);
  final day = calendarUtcDateOnly(dayUtc);
  return repo.snapshotTasks(familyId).where((t) {
    if (t.status == TaskStatus.completed) return false;
    final d = t.dueAt;
    if (d == null) return false;
    return calendarIsSameUtcDate(d, day);
  }).toList()
    ..sort(
      (a, b) => (a.dueAt ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
            b.dueAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          ),
    );
});

/// Persists phone week sub-mode (2-day table pager vs stacked agenda).
class MobileWeekPrefsNotifier extends StateNotifier<MobileWeekMode> {
  MobileWeekPrefsNotifier({this.restoreFromDisk = true})
      : super(MobileWeekMode.threeDaySwipe) {
    if (restoreFromDisk) {
      _restore();
    }
  }

  MobileWeekPrefsNotifier.seeded(super.mode) : restoreFromDisk = false;

  final bool restoreFromDisk;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final parsed = _parseMobileWeekMode(
      prefs.getString(_kPrefMobileWeekMode),
    );
    if (parsed != null) {
      state = parsed;
    }
  }

  Future<void> setMode(MobileWeekMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    await prefs.setString(_kPrefMobileWeekMode, mode.name);
  }
}

final calendarMobileWeekModeProvider =
    StateNotifierProvider<MobileWeekPrefsNotifier, MobileWeekMode>((ref) {
  return MobileWeekPrefsNotifier();
});

class CalendarMemberSeed {
  const CalendarMemberSeed({
    required this.id,
    required this.label,
    required this.colorHex,
  });

  final String id;
  final String label;
  final String colorHex;
}

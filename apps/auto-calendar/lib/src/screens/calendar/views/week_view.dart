import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/event_card.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

DateTime _weekStart(DateTime d) {
  final utc = d.toUtc();
  final wd = utc.weekday - 1;
  return DateTime.utc(utc.year, utc.month, utc.day).subtract(
    Duration(days: wd),
  );
}

int _dayIndexInWeek(DateTime weekStart, DateTime anchor) {
  final utc = anchor.toUtc();
  final a = DateTime.utc(utc.year, utc.month, utc.day);
  return a.difference(weekStart).inDays.clamp(0, 6);
}

/// Pages: Mon–Tue, Wed–Thu, Fri–Sat, Sun.
const int _mobileWeekPageCount = 4;

int _pageForDayIndex(int dayIndex) {
  if (dayIndex < 2) return 0;
  if (dayIndex < 4) return 1;
  if (dayIndex < 6) return 2;
  return 3;
}

List<int> _dayIndicesForPage(int page) {
  return switch (page) {
    0 => [0, 1],
    1 => [2, 3],
    2 => [4, 5],
    _ => [6],
  };
}

List<CalendarEvent> _eventsForDayUtc(
  List<CalendarEvent> events,
  DateTime dayStartUtc,
) {
  final dayEnd = dayStartUtc.add(const Duration(days: 1));
  return events.where((e) {
    final s = e.startAt.toUtc();
    return !s.isBefore(dayStartUtc) && s.isBefore(dayEnd);
  }).toList()
    ..sort((a, b) => a.startAt.compareTo(b.startAt));
}

/// Single day column matching desktop week styling (for mobile table pages).
Widget _weekDayTableColumn(
  BuildContext context, {
  required DateTime dayUtc,
  required DateTime todayUtc,
  required List<CalendarEvent> events,
  required int columnIndex,
  required int columnCount,
}) {
  final forDay = _eventsForDayUtc(events, dayUtc);
  final isToday = calendarIsSameUtcDate(dayUtc, todayUtc);
  final scheme = Theme.of(context).colorScheme;
  return Expanded(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: isToday ? scheme.primaryContainer.withValues(alpha: 0.45) : null,
        border: Border(
          right: columnIndex < columnCount - 1
              ? BorderSide(color: Theme.of(context).dividerColor)
              : BorderSide.none,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(6),
        children: [
          Text(
            DateFormat.E('en').format(dayUtc.toLocal()),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: isToday ? FontWeight.w800 : null,
                  color: isToday ? scheme.primary : null,
                ),
            textAlign: TextAlign.center,
          ),
          Text(
            '${dayUtc.month}/${dayUtc.day}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isToday ? FontWeight.w700 : null,
                  color: isToday ? scheme.primary : null,
                ),
          ),
          const Divider(),
          ...forDay.map((e) => EventCard(event: e)),
        ],
      ),
    ),
  );
}

class WeekView extends ConsumerWidget {
  const WeekView({
    super.key,
    required this.familyId,
    required this.anchor,
  });

  final String familyId;
  final DateTime anchor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(calendarRepositoryProvider);
    final ws = _weekStart(anchor);
    final we = ws.add(const Duration(days: 6, hours: 23, minutes: 59));
    final filterMember = ref.watch(calendarMemberFilterProvider);
    final isPhone =
        MediaQuery.sizeOf(context).width < kCalendarWeekPhoneLayoutWidth;
    final mobileMode = ref.watch(calendarMobileWeekModeProvider);
    final todayUtc = ref.watch(calendarTodayUtcProvider);

    return StreamBuilder<List<CalendarEvent>>(
      stream: repo.watchRange(familyId: familyId, start: ws, end: we),
      builder: (context, snap) {
        var events = snap.data ?? const <CalendarEvent>[];
        if (filterMember != null) {
          events = events
              .where((e) => e.taggedMemberIds.contains(filterMember))
              .toList();
        }

        if (isPhone) {
          return switch (mobileMode) {
            MobileWeekMode.threeDaySwipe => _WeekMobileSwipe(
                key: const ValueKey<String>('week-mobile-swipe'),
                weekStart: ws,
                events: events,
                anchor: anchor,
                todayUtc: todayUtc,
              ),
            MobileWeekMode.stackedAgenda => _WeekMobileAgenda(
                key: const ValueKey<String>('week-mobile-agenda'),
                weekStart: ws,
                events: events,
                todayUtc: todayUtc,
              ),
          };
        }

        return _WeekDesktopGrid(
          key: const ValueKey<String>('week-desktop-grid'),
          weekStart: ws,
          events: events,
          todayUtc: todayUtc,
        );
      },
    );
  }
}

class _WeekDesktopGrid extends StatelessWidget {
  const _WeekDesktopGrid({
    super.key,
    required this.weekStart,
    required this.events,
    required this.todayUtc,
  });

  final DateTime weekStart;
  final List<CalendarEvent> events;
  final DateTime todayUtc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(7, (i) {
        final day = weekStart.add(Duration(days: i));
        return _weekDayTableColumn(
          context,
          dayUtc: day,
          todayUtc: todayUtc,
          events: events,
          columnIndex: i,
          columnCount: 7,
        );
      }),
    );
  }
}

class _WeekMobileSwipe extends StatefulWidget {
  const _WeekMobileSwipe({
    super.key,
    required this.weekStart,
    required this.events,
    required this.anchor,
    required this.todayUtc,
  });

  final DateTime weekStart;
  final List<CalendarEvent> events;
  final DateTime anchor;
  final DateTime todayUtc;

  @override
  State<_WeekMobileSwipe> createState() => _WeekMobileSwipeState();
}

class _WeekMobileSwipeState extends State<_WeekMobileSwipe> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final dayIx = _dayIndexInWeek(widget.weekStart, widget.anchor);
    _pageController = PageController(
      initialPage: _pageForDayIndex(dayIx),
    );
  }

  @override
  void didUpdateWidget(covariant _WeekMobileSwipe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weekStart != widget.weekStart ||
        oldWidget.anchor != widget.anchor) {
      final dayIx = _dayIndexInWeek(widget.weekStart, widget.anchor);
      final p = _pageForDayIndex(dayIx);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(p);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: _mobileWeekPageCount,
      itemBuilder: (context, page) {
        final indices = _dayIndicesForPage(page);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var c = 0; c < indices.length; c++)
              _weekDayTableColumn(
                context,
                dayUtc: widget.weekStart.add(Duration(days: indices[c])),
                todayUtc: widget.todayUtc,
                events: widget.events,
                columnIndex: c,
                columnCount: indices.length,
              ),
          ],
        );
      },
    );
  }
}

class _WeekMobileAgenda extends StatelessWidget {
  const _WeekMobileAgenda({
    super.key,
    required this.weekStart,
    required this.events,
    required this.todayUtc,
  });

  final DateTime weekStart;
  final List<CalendarEvent> events;
  final DateTime todayUtc;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      itemCount: 7,
      itemBuilder: (context, i) {
        final day = weekStart.add(Duration(days: i));
        final forDay = _eventsForDayUtc(events, day);
        final isToday = calendarIsSameUtcDate(day, todayUtc);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat.yMMMEd('en').format(day.toLocal()),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: isToday
                                ? Theme.of(context).colorScheme.primary
                                : null,
                            fontWeight:
                                isToday ? FontWeight.w800 : FontWeight.w600,
                          ),
                    ),
                  ),
                  if (isToday)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: const Text('Today'),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            if (forDay.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'No events',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ...forDay.map((e) => EventCard(event: e)),
            const Divider(height: 24),
          ],
        );
      },
    );
  }
}

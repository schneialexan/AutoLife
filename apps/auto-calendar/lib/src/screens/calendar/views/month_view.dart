import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/views/month_day_cell.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Month grid with titled event rows per day, scroll-on-hover, stable row height.
class MonthView extends ConsumerWidget {
  const MonthView({
    super.key,
    required this.familyId,
    required this.anchor,
  });

  final String familyId;
  final DateTime anchor;

  /// Row height fits ~3 two-line event rows + day header.
  static const double rowHeight = 140;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(calendarRepositoryProvider);
    final stress = ref.watch(calendarWeatherStressProvider);
    final monthStart = DateTime.utc(anchor.year, anchor.month);
    final nextMonth = DateTime.utc(anchor.year, anchor.month + 1);
    final gridStart = monthStart.subtract(
      Duration(days: monthStart.weekday - 1),
    );
    return StreamBuilder<List<CalendarEvent>>(
      stream: repo.watchRange(
        familyId: familyId,
        start: gridStart,
        end: nextMonth,
      ),
      builder: (context, snap) {
        final events = snap.data ?? const <CalendarEvent>[];
        final byDay = <DateTime, List<CalendarEvent>>{};
        for (final e in events) {
          final k = DateTime.utc(
            e.startAt.year,
            e.startAt.month,
            e.startAt.day,
          );
          byDay.putIfAbsent(k, () => []).add(e);
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMM('en').format(monthStart.toLocal()),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    tooltip: 'Previous month',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      ref.read(calendarAnchorProvider.notifier).state =
                          DateTime.utc(anchor.year, anchor.month - 1);
                    },
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      ref.read(calendarAnchorProvider.notifier).state =
                          DateTime.utc(anchor.year, anchor.month + 1);
                    },
                  ),
                ],
              ),
            ),
            const _WeekdayHeaderRow(),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: rowHeight,
                ),
                itemCount: 42,
                itemBuilder: (context, i) {
                  final day = gridStart.add(Duration(days: i));
                  final inMonth = day.month == monthStart.month;
                  final list = (byDay[day] ?? const []).toList();
                  return MonthDayCell(
                    day: day,
                    inMonth: inMonth,
                    events: list,
                    familyId: familyId,
                    precipProbability: (day.day % 7) * 0.1,
                    stressThreshold: stress,
                    gridIndex: i,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WeekdayHeaderRow extends StatelessWidget {
  const _WeekdayHeaderRow();

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.E('en');
    final monday = DateTime.utc(2026, 5, 11);
    return SizedBox(
      height: 24,
      child: Row(
        children: List.generate(7, (i) {
          return Expanded(
            child: Text(
              fmt.format(monday.add(Duration(days: i))),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          );
        }),
      ),
    );
  }
}

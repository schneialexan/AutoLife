import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/event_card.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AgendaView extends ConsumerWidget {
  const AgendaView({
    super.key,
    required this.familyId,
    required this.anchor,
  });

  final String familyId;
  final DateTime anchor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(calendarRepositoryProvider);
    final start = DateTime.utc(anchor.year, anchor.month, anchor.day);
    final end = start.add(const Duration(days: 21));
    final filterMember = ref.watch(calendarMemberFilterProvider);
    return StreamBuilder<List<CalendarEvent>>(
      stream: repo.watchRange(familyId: familyId, start: start, end: end),
      builder: (context, snap) {
        var events = List<CalendarEvent>.from(
          snap.data ?? const <CalendarEvent>[],
        );
        if (filterMember != null) {
          events = events
              .where((e) => e.taggedMemberIds.contains(filterMember))
              .toList();
        }
        events.sort((a, b) => a.startAt.compareTo(b.startAt));
        final todayUtc = ref.watch(calendarTodayUtcProvider);
        final byDay = <DateTime, List<CalendarEvent>>{};
        for (final e in events) {
          final k = DateTime.utc(
            e.startAt.year,
            e.startAt.month,
            e.startAt.day,
          );
          byDay.putIfAbsent(k, () => []).add(e);
        }
        final keys = byDay.keys.toList()..sort();
        return ListView.builder(
          itemCount: keys.length,
          itemBuilder: (context, i) {
            final day = keys[i];
            final list = byDay[day]!;
            final isToday = calendarIsSameUtcDate(day, todayUtc);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          DateFormat.yMMMEd('en').format(day.toLocal()),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: isToday
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                    fontWeight: isToday
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                        ),
                      ),
                      if (isToday)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Chip(
                            label: const Text('Today'),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                ...list.map((e) => EventCard(event: e, compactSnippet: true)),
              ],
            );
          },
        );
      },
    );
  }
}

import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/event_card.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/weather_overlay.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/day_due_strip.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DayView extends ConsumerWidget {
  const DayView({
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
    final end = start.add(const Duration(days: 1));
    final filterMember = ref.watch(calendarMemberFilterProvider);
    return StreamBuilder<List<CalendarEvent>>(
      stream: repo.watchRange(familyId: familyId, start: start, end: end),
      builder: (context, snap) {
        final raw = snap.data ?? const <CalendarEvent>[];
        var visible = List<CalendarEvent>.from(raw);
        if (filterMember != null) {
          visible = raw
              .where((e) => e.taggedMemberIds.contains(filterMember))
              .toList();
        }
        visible.sort((a, b) => a.startAt.compareTo(b.startAt));
        final stress = ref.watch(calendarWeatherStressProvider);
        final todayUtc = ref.watch(calendarTodayUtcProvider);
        final isToday = calendarIsSameUtcDate(start, todayUtc);
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            WeatherOverlayHeader(
              day: start,
              precipitationProbability: 0.42,
              stressThreshold: stress,
            ),
            Row(
              children: [
                const Text('Tagged filter:'),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: filterMember,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All'),
                    ),
                    ...ref.watch(calendarMemberSeedsProvider).map(
                      (m) => DropdownMenuItem<String?>(
                        value: m.id,
                        child: Text(m.label),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    ref.read(calendarMemberFilterProvider.notifier).state = v;
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat.yMMMEd('en').format(start.toLocal()),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isToday
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w600,
                        ),
                  ),
                ),
                if (isToday)
                  Chip(
                    label: const Text('Today'),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.6),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            DayDueStrip(dayUtc: start),
            if (visible.isEmpty)
              const Center(child: Text('No events this day'))
            else
              ...visible.map(
                (e) => EventCard(event: e, compactSnippet: true),
              ),
          ],
        );
      },
    );
  }
}

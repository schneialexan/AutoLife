import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/event_detail_screen.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/event_accent_color.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/weather_overlay.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// One month-grid day: header + scrollable timed/all-day event rows.
class MonthDayCell extends ConsumerStatefulWidget {
  const MonthDayCell({
    super.key,
    required this.day,
    required this.inMonth,
    required this.events,
    required this.familyId,
    required this.precipProbability,
    required this.stressThreshold,
    required this.gridIndex,
  });

  final DateTime day;
  final bool inMonth;
  final List<CalendarEvent> events;
  final String familyId;
  final double precipProbability;
  final double stressThreshold;
  final int gridIndex;

  @override
  ConsumerState<MonthDayCell> createState() => _MonthDayCellState();
}

class _MonthDayCellState extends ConsumerState<MonthDayCell> {
  final ScrollController _scrollController = ScrollController();
  bool _hover = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seeds = ref.watch(calendarMemberSeedsProvider);
    final todayUtc = ref.watch(calendarTodayUtcProvider);
    final isToday = calendarIsSameUtcDate(widget.day, todayUtc);
    final allDay = widget.events.where((e) => e.allDay).toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    final timed = widget.events.where((e) => !e.allDay).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    final rows = <CalendarEvent>[...allDay, ...timed];

    final timeFmt = DateFormat.jm('en');
    return Container(
      key: isToday ? const ValueKey<String>('month-day-today') : null,
      decoration: BoxDecoration(
        border: GridBorder.side(context, widget.gridIndex),
        color: isToday
            ? Theme.of(context).colorScheme.primaryContainer.withValues(
                  alpha: 0.35,
                )
            : null,
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.day.day}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.inMonth
                        ? (isToday
                            ? Theme.of(context).colorScheme.primary
                            : null)
                        : Theme.of(context).disabledColor,
                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              WeatherOverlayCompact(
                precipitationProbability: widget.precipProbability,
                stressThreshold: widget.stressThreshold,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Expanded(
            child: MouseRegion(
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: _hover,
                interactive: true,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  itemCount: rows.length,
                  itemBuilder: (context, i) {
                    final e = rows[i];
                    final accent = calendarEventAccentColor(e, seeds);
                    final timeLabel = e.allDay
                        ? 'All-day'
                        : timeFmt.format(e.startAt.toLocal());
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => EventDetailScreen(
                                eventId: e.id,
                                familyId: widget.familyId,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 3,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      timeLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    Text(
                                      e.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridBorder {
  static Border side(BuildContext context, int index) {
    final c = Theme.of(context).dividerColor;
    final col = index % 7;
    return Border(
      top: BorderSide(color: c),
      left: col == 0 ? BorderSide.none : BorderSide(color: c),
      right: col == 6 ? BorderSide(color: c) : BorderSide.none,
      bottom: BorderSide(color: c),
    );
  }
}

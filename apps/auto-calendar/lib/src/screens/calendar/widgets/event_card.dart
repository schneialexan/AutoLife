import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/event_detail_screen.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/commute_block.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/event_accent_color.dart';
import 'package:auto_calendar/src/services/commute_planner_service.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _commutePlanner = CommutePlannerService();

class EventCard extends ConsumerWidget {
  const EventCard({
    super.key,
    required this.event,
    this.compactSnippet = false,
  });

  final CalendarEvent event;
  final bool compactSnippet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFmt = DateFormat.jm('en');
    final members = ref.watch(calendarMemberSeedsProvider);
    final snippet = compactSnippet && (event.notes?.isNotEmpty ?? false)
        ? event.notes!.split('\n').first
        : null;
    final commuteOn = ref.watch(calendarCommuteEnabledProvider);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => EventDetailScreen(
                eventId: event.id,
                familyId: event.familyId,
              ),
            ),
          );
        },
        onLongPress: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Convert to task — emit event.convert_to_task (wire to bus in shell).',
              ),
            ),
          );
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: calendarEventAccentColor(event, members),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(4),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${timeFmt.format(event.startAt.toLocal())} — '
                        '${timeFmt.format(event.endAt.toLocal())}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (event.location != null)
                        Text(
                          event.location!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (snippet != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          snippet,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (commuteOn &&
                          event.location != null &&
                          event.location!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        CommuteBlockPreview(
                          travelMinutes: _commutePlanner.defaultEta.inMinutes,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

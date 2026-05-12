import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/event_detail_screen.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/commute_block.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/event_accent_color.dart';
import 'package:auto_calendar/src/services/commute_planner_service.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final _commutePlanner = CommutePlannerService();

class EventCard extends ConsumerWidget {
  const EventCard({
    super.key,
    required this.event,
    this.compactSnippet = false,
  });

  final CalendarEvent event;
  final bool compactSnippet;

  Future<void> _convertToTask(BuildContext context, WidgetRef ref) async {
    final taskRepo = ref.read(calendarTaskRepositoryProvider);
    final lists = await taskRepo.watchLists(event.familyId).first;
    if (!context.mounted) return;
    String? selected = lists.isNotEmpty ? lists.first.id : null;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Convert to task',
                      style: Theme.of(ctx).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (lists.isEmpty)
                      const Text('Create a task list in Tasks first.')
                    else
                      DropdownButtonFormField<String>(
                        key: ValueKey(selected),
                        initialValue: selected,
                        items: lists
                            .map(
                              (l) => DropdownMenuItem(
                                value: l.id,
                                child: Text(l.name),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setModal(() => selected = v),
                      ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: selected == null
                          ? null
                          : () async {
                          final now = DateTime.now().toUtc();
                          final snap =
                              taskRepo.snapshotTasks(event.familyId);
                          for (final t in snap) {
                            if (t.sourceEventId == event.id) {
                              if (ctx.mounted) Navigator.pop(ctx);
                              return;
                            }
                          }
                          final task = Task(
                            id: const Uuid().v4(),
                            familyId: event.familyId,
                            listId: selected!,
                            title: event.title,
                            description: event.description ?? event.notes,
                            status: TaskStatus.inbox,
                            priority: TaskPriority.medium,
                            importance: false,
                            dueAt: event.startAt,
                            scheduledFor: event.startAt,
                            sourceEventId: event.id,
                            reminders: const [],
                            createdBy: event.createdBy,
                            createdAt: now,
                            updatedAt: now,
                          );
                          await taskRepo.upsertTask(task);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Created task: ${task.title}'),
                              ),
                            );
                          }
                        },
                      child: const Text('Create linked task'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeFmt = DateFormat.jm('en');
    final members = ref.watch(calendarMemberSeedsProvider);
    final snippet = compactSnippet && (event.notes?.isNotEmpty ?? false)
        ? event.notes!.split('\n').first
        : null;
    final commuteOn = ref.watch(calendarCommuteEnabledProvider);
    final taskRepo = ref.watch(calendarTaskRepositoryProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: event.isTaskBlock
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.9),
                width: 1.5,
              ),
            )
          : null,
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
        onLongPress: event.isTaskBlock
            ? null
            : () => _convertToTask(context, ref),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (event.isTaskBlock && event.linkedTaskId != null)
                SizedBox(
                  width: 44,
                  child: Center(
                    child: IconButton(
                      tooltip: 'Mark task done',
                      onPressed: () async {
                        final t = await taskRepo.getTask(
                          familyId: event.familyId,
                          taskId: event.linkedTaskId!,
                        );
                        if (t == null) return;
                        final now = DateTime.now().toUtc();
                        await taskRepo.upsertTask(
                          t.copyWith(
                            status: TaskStatus.completed,
                            completedAt: now,
                            completedBy: event.createdBy,
                            updatedAt: now,
                          ),
                        );
                      },
                      icon: const Icon(Icons.check_box_outlined),
                    ),
                  ),
                ),
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
                      Row(
                        children: [
                          if (event.isTaskBlock)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.task_alt,
                                size: 18,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              event.title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
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

import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single due-task chip for month cells / strips.
class TaskDueChip extends StatelessWidget {
  const TaskDueChip({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task: ${task.title} (${task.id})')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}

/// Horizontal strip of tasks due on [dayUtc] (max [maxChips] visible).
class DayDueStrip extends ConsumerWidget {
  const DayDueStrip({
    super.key,
    required this.dayUtc,
    this.maxChips = 5,
  });

  final DateTime dayUtc;
  final int maxChips;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksDueOnDayProvider(dayUtc));
    if (tasks.isEmpty) return const SizedBox.shrink();
    final show = tasks.take(maxChips).toList();
    final more = tasks.length - show.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.checklist_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 6),
            Text(
              'Due',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...show.map((t) => TaskDueChip(task: t)),
            if (more > 0)
              Chip(
                label: Text('+$more more'),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

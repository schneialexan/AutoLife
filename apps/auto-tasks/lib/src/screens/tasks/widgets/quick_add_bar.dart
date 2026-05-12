import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/services/quick_add_parser.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class QuickAddBar extends ConsumerStatefulWidget {
  const QuickAddBar({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends ConsumerState<QuickAddBar> {
  final _controller = TextEditingController();
  final _parser = const QuickAddParser();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    final repo = ref.read(taskRepositoryProvider);
    final listId = ref.read(taskSelectedListIdProvider);
    final lists = await repo.watchLists(widget.familyId).first;
    final parsed = _parser.parse(raw);
    var targetListId = listId;
    if (parsed.listSlug != null) {
      final slug = parsed.listSlug!.toLowerCase();
      for (final l in lists) {
        final name = l.name.toLowerCase();
        if (name == slug || name.contains(slug)) {
          targetListId = l.id;
          break;
        }
      }
    }
    targetListId ??= lists.isNotEmpty ? lists.first.id : null;
    if (targetListId == null) return;

    final me = ref.read(taskCurrentUserIdProvider);
    final assignees = <String>[];
    if (parsed.assigneeHint != null) {
      for (final m in const [
        ('alex', '11111111-1111-1111-1111-111111111111'),
        ('sam', '22222222-2222-2222-2222-222222222222'),
      ]) {
        if (m.$1 == parsed.assigneeHint!.toLowerCase()) {
          assignees.add(m.$2);
        }
      }
    }

    final now = DateTime.now().toUtc();
    var reminders = const <TaskReminder>[];
    final listMeta = lists.firstWhereOrNull((l) => l.id == targetListId);
    final defMin = listMeta?.defaultReminderMinutesBeforeDue;
    if (defMin != null && parsed.dueAt != null) {
      reminders = [
        TaskReminder(
          offsetBeforeDue: Duration(minutes: -defMin),
          dedupeKey: 'quickadd-${now.millisecondsSinceEpoch}',
        ),
      ];
    }

    final task = Task(
      id: const Uuid().v4(),
      familyId: widget.familyId,
      listId: targetListId,
      title: parsed.title,
      status: TaskStatus.inbox,
      priority: parsed.priority,
      importance: parsed.importance,
      dueAt: parsed.dueAt,
      assigneeIds: assignees,
      reminders: reminders,
      createdBy: me,
      createdAt: now,
      updatedAt: now,
    );
    await repo.upsertTask(task);
    _controller.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: MediaQuery.paddingOf(context).bottom + 8,
          top: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Quick add (try: Buy milk tomorrow 5pm #groceries !! @sam *)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

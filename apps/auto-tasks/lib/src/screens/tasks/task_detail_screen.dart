import 'package:auto_tasks/src/providers/task_providers.dart';
import 'package:auto_tasks/src/screens/tasks/widgets/template_picker_sheet.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.familyId,
    required this.taskId,
  });

  final String familyId;
  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _stepAddCtrl = TextEditingController();
  final _linkUrlCtrl = TextEditingController();
  final _linkLabelCtrl = TextEditingController();

  String? _boundTaskId;
  DateTime? _lastBoundUpdated;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _tagCtrl.dispose();
    _stepAddCtrl.dispose();
    _linkUrlCtrl.dispose();
    _linkLabelCtrl.dispose();
    super.dispose();
  }

  void _syncControllersIfNeeded(Task task) {
    if (_boundTaskId != task.id) {
      _boundTaskId = task.id;
      _titleCtrl.text = task.title;
      _notesCtrl.text = task.description ?? '';
      _lastBoundUpdated = task.updatedAt;
      return;
    }
    if (task.updatedAt != _lastBoundUpdated) {
      _lastBoundUpdated = task.updatedAt;
      if (_titleCtrl.text != task.title) _titleCtrl.text = task.title;
      if (_notesCtrl.text != (task.description ?? '')) {
        _notesCtrl.text = task.description ?? '';
      }
    }
  }

  Future<void> _persist(Task t) async {
    await ref.read(taskRepositoryProvider).upsertTask(
          t.copyWith(updatedAt: DateTime.now().toUtc()),
        );
  }

  String _fmtTs(DateTime? t) {
    if (t == null) return 'None';
    return DateFormat.yMMMd().add_jm().format(t.toLocal());
  }

  String _fmtDay(DateTime? t) {
    if (t == null) return 'None';
    return DateFormat.yMMMd().format(DateTime(t.year, t.month, t.day));
  }

  Future<DateTime?> _pickDateTime(BuildContext context, DateTime? initial) async {
    final base = initial ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(base.year, base.month, base.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d == null || !context.mounted) return null;
    final tod = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (tod == null || !context.mounted) return null;
    final local = DateTime(d.year, d.month, d.day, tod.hour, tod.minute);
    return local.toUtc();
  }

  Future<DateTime?> _pickDateLocalToUtcDay(
    BuildContext context,
    DateTime? initial,
  ) async {
    final base = initial ?? DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(base.year, base.month, base.day),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d == null) return null;
    return DateTime.utc(d.year, d.month, d.day);
  }

  Future<void> _applyStatus(Task t, TaskStatus s) async {
    final uid = ref.read(taskCurrentUserIdProvider);
    final now = DateTime.now().toUtc();
    switch (s) {
      case TaskStatus.completed:
        await _persist(
          t.copyWith(
            status: s,
            completedAt: now,
            completedBy: uid,
            canceledAt: null,
            canceledBy: null,
          ),
        );
      case TaskStatus.canceled:
        await _persist(
          t.copyWith(
            status: s,
            canceledAt: now,
            canceledBy: uid,
            completedAt: null,
            completedBy: null,
          ),
        );
      case TaskStatus.inbox:
      case TaskStatus.active:
        await _persist(
          t.copyWith(
            status: s,
            completedAt: null,
            completedBy: null,
            canceledAt: null,
            canceledBy: null,
          ),
        );
    }
  }

  Future<void> _showReminderDialog(
    BuildContext context,
    Task task, {
    TaskReminder? existing,
    int? index,
  }) async {
    var anchorDue = existing?.anchorToDue ?? true;
    var quiet = existing?.quietHoursAware ?? true;
    final minutesCtrl = TextEditingController(
      text: existing != null ? '${existing.offsetBeforeDue.inMinutes}' : '15',
    );
    final dedupeCtrl = TextEditingController(
      text: existing?.dedupeKey ?? 'r-${DateTime.now().millisecondsSinceEpoch}',
    );

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(existing == null ? 'Add reminder' : 'Edit reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: minutesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Minutes before anchor',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dedupeCtrl,
                  decoration: const InputDecoration(labelText: 'Dedupe key'),
                ),
                const SizedBox(height: 8),
                RadioListTile<bool>(
                  title: const Text('Anchor to due date'),
                  value: true,
                  groupValue: anchorDue,
                  onChanged: (v) => setSt(() => anchorDue = v ?? true),
                ),
                RadioListTile<bool>(
                  title: const Text('Anchor to planned time'),
                  value: false,
                  groupValue: anchorDue,
                  onChanged: (v) => setSt(() => anchorDue = v ?? false),
                ),
                SwitchListTile(
                  title: const Text('Quiet-hours aware (planned)'),
                  value: quiet,
                  onChanged: (v) => setSt(() => quiet = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (ok != true || !context.mounted) {
      minutesCtrl.dispose();
      dedupeCtrl.dispose();
      return;
    }

    final min = int.tryParse(minutesCtrl.text.trim()) ?? 15;
    final rem = TaskReminder(
      offsetBeforeDue: Duration(minutes: min.clamp(0, 525600)),
      dedupeKey: dedupeCtrl.text.trim().isEmpty
          ? 'r-${DateTime.now().millisecondsSinceEpoch}'
          : dedupeCtrl.text.trim(),
      quietHoursAware: quiet,
      anchorToDue: anchorDue,
    );
    final list = List<TaskReminder>.from(task.reminders);
    if (index != null && index >= 0 && index < list.length) {
      list[index] = rem;
    } else {
      list.add(rem);
    }
    await _persist(task.copyWith(reminders: list));
    minutesCtrl.dispose();
    dedupeCtrl.dispose();
  }

  Future<void> _showRecurrenceDialog(BuildContext context, Task task) async {
    var freq = task.recurrenceRule?.frequency ?? RecurrenceFrequency.daily;
    final intervalCtrl = TextEditingController(
      text: '${task.recurrenceRule?.interval ?? 1}',
    );
    var weekdays = List<int>.from(task.recurrenceRule?.byWeekday ?? const []);
    DateTime? until = task.recurrenceRule?.until;
    final countCtrl = TextEditingController(
      text: task.recurrenceRule?.count?.toString() ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Recurrence'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<RecurrenceFrequency>(
                  value: freq,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: RecurrenceFrequency.values
                      .map(
                        (f) => DropdownMenuItem(value: f, child: Text(f.name)),
                      )
                      .toList(),
                  onChanged: (v) => setSt(() => freq = v ?? RecurrenceFrequency.daily),
                ),
                TextField(
                  controller: intervalCtrl,
                  decoration: const InputDecoration(labelText: 'Interval'),
                  keyboardType: TextInputType.number,
                ),
                if (freq == RecurrenceFrequency.weekly) ...[
                  const SizedBox(height: 8),
                  const Text('Weekdays (ISO 1=Mon … 7=Sun)'),
                  Wrap(
                    spacing: 4,
                    children: List.generate(7, (i) {
                      final d = i + 1;
                      final on = weekdays.contains(d);
                      return FilterChip(
                        label: Text('$d'),
                        selected: on,
                        onSelected: (v) {
                          setSt(() {
                            if (v) {
                              weekdays = [...weekdays, d]..sort();
                            } else {
                              weekdays = weekdays.where((e) => e != d).toList();
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
                ListTile(
                  title: Text(until == null ? 'Until: none' : 'Until: ${_fmtTs(until)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.event),
                    onPressed: () async {
                      final u = await _pickDateTime(ctx, until);
                      if (u != null) setSt(() => until = u);
                    },
                  ),
                ),
                TextButton(
                  onPressed: () => setSt(() => until = null),
                  child: const Text('Clear until'),
                ),
                TextField(
                  controller: countCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Count (optional)',
                    hintText: 'Leave empty if using until',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'clear'),
              child: const Text('Clear recurrence'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'save'),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    try {
      if (result == 'clear') {
        await _persist(task.copyWith(recurrenceRule: null));
        return;
      }
      if (result != 'save' || !context.mounted) return;

      final iv = int.tryParse(intervalCtrl.text.trim()) ?? 1;
      int? ct;
      final cs = countCtrl.text.trim();
      if (cs.isNotEmpty) ct = int.tryParse(cs);

      final rule = CalendarRecurrenceRule(
        frequency: freq,
        interval: iv.clamp(1, 999),
        byWeekday: freq == RecurrenceFrequency.weekly ? weekdays : const [],
        until: until,
        count: ct,
      );
      await _persist(task.copyWith(recurrenceRule: rule));
    } finally {
      intervalCtrl.dispose();
      countCtrl.dispose();
    }
  }

  Future<void> _showLinkDialog(BuildContext context, Task task) async {
    _linkUrlCtrl.clear();
    _linkLabelCtrl.clear();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _linkUrlCtrl,
              decoration: const InputDecoration(labelText: 'URL (https://…)'),
              keyboardType: TextInputType.url,
            ),
            TextField(
              controller: _linkLabelCtrl,
              decoration: const InputDecoration(labelText: 'Label (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final raw = _linkUrlCtrl.text.trim();
    var uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      final withScheme = raw.startsWith('http') ? raw : 'https://$raw';
      uri = Uri.tryParse(withScheme);
    }
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      return;
    }
    final label = _linkLabelCtrl.text.trim();
    final next = [
      ...task.links,
      TaskLink(url: uri.toString(), label: label.isEmpty ? null : label),
    ];
    await _persist(task.copyWith(links: next));
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(taskRepositoryProvider);
    final knownAssignees = ref.watch(taskKnownAssigneeIdsProvider);

    return StreamBuilder<List<Task>>(
      stream: repo.watchFamilyTasks(widget.familyId),
      builder: (context, tsnap) {
        final task =
            (tsnap.data ?? const []).firstWhereOrNull((t) => t.id == widget.taskId);
        if (task == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Task not found')),
          );
        }

        _syncControllersIfNeeded(task);
        final meId = ref.watch(taskCurrentUserIdProvider);

        return StreamBuilder<List<TaskList>>(
          stream: repo.watchLists(widget.familyId),
          builder: (context, lsnap) {
            final lists = lsnap.data ?? const <TaskList>[];

            return Scaffold(
              appBar: AppBar(
                title: const SizedBox.shrink(),
                actions: [
                  IconButton(
                    tooltip: task.importance ? 'Remove importance' : 'Mark important',
                    icon: Icon(
                      task.importance ? Icons.star : Icons.star_border,
                    ),
                    onPressed: () => _persist(
                      task.copyWith(importance: !task.importance),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.dashboard_customize_outlined),
                    onPressed: () => showTemplatePickerSheet(context),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onEditingComplete: () async {
                      final v = _titleCtrl.text.trim();
                      if (v.isEmpty) {
                        _titleCtrl.text = task.title;
                        return;
                      }
                      if (v != task.title) {
                        await _persist(task.copyWith(title: v));
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    minLines: 3,
                    maxLines: 8,
                    onEditingComplete: () async {
                      final v = _notesCtrl.text.trim();
                      await _persist(
                        task.copyWith(
                          description: v.isEmpty ? null : v,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () async {
                        await _persist(task.copyWith(description: null));
                        _notesCtrl.clear();
                      },
                      child: const Text('Clear notes'),
                    ),
                  ),

                  /// List
                  DropdownButtonFormField<String>(
                    value: lists.any((l) => l.id == task.listId)
                        ? task.listId
                        : (lists.isEmpty ? null : lists.first.id),
                    decoration: const InputDecoration(labelText: 'List'),
                    items: lists
                        .map(
                          (l) => DropdownMenuItem(value: l.id, child: Text(l.name)),
                        )
                        .toList(),
                    onChanged: lists.isEmpty
                        ? null
                        : (v) async {
                            if (v != null && v != task.listId) {
                              await _persist(task.copyWith(listId: v));
                            }
                          },
                  ),

                  const SizedBox(height: 12),
                  /// Status & priority
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<TaskStatus>(
                          value: task.status,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: TaskStatus.values
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.name),
                                ),
                              )
                              .toList(),
                          onChanged: (s) async {
                            if (s != null) await _applyStatus(task, s);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<TaskPriority>(
                          value: task.priority,
                          decoration: const InputDecoration(labelText: 'Priority'),
                          items: TaskPriority.values
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text(p.name),
                                ),
                              )
                              .toList(),
                          onChanged: (p) async {
                            if (p != null) {
                              await _persist(task.copyWith(priority: p));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('Requires approval'),
                    value: task.requiresApproval,
                    onChanged: (v) => _persist(task.copyWith(requiresApproval: v)),
                  ),

                  const Divider(),
                  Text('Schedule', style: Theme.of(context).textTheme.titleSmall),
                  ListTile(
                    title: const Text('Due'),
                    subtitle: Text(_fmtTs(task.dueAt)),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: () async {
                            final dt = await _pickDateTime(context, task.dueAt);
                            if (dt != null) await _persist(task.copyWith(dueAt: dt));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _persist(task.copyWith(dueAt: null)),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Planned (scheduled for)'),
                    subtitle: Text(_fmtTs(task.scheduledFor)),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_calendar),
                          onPressed: () async {
                            final dt = await _pickDateTime(context, task.scheduledFor);
                            if (dt != null) {
                              await _persist(task.copyWith(scheduledFor: dt));
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              _persist(task.copyWith(scheduledFor: null)),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('My Day'),
                    subtitle: Text(_fmtDay(task.myDayDate)),
                    trailing: Wrap(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final d = await _pickDateLocalToUtcDay(
                              context,
                              task.myDayDate,
                            );
                            if (d != null) await _persist(task.copyWith(myDayDate: d));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              _persist(task.copyWith(myDayDate: null)),
                        ),
                      ],
                    ),
                  ),
                  DropdownButtonFormField<int?>(
                    value: () {
                      final ms = task.estimatedDuration?.inMinutes;
                      const presets = [15, 30, 60, 120];
                      if (ms == null) return null;
                      return presets.contains(ms) ? ms : -1;
                    }(),
                    decoration: const InputDecoration(
                      labelText: 'Estimated duration',
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('None')),
                      DropdownMenuItem(value: 15, child: Text('15 min')),
                      DropdownMenuItem(value: 30, child: Text('30 min')),
                      DropdownMenuItem(value: 60, child: Text('1 hour')),
                      DropdownMenuItem(value: 120, child: Text('2 hours')),
                      DropdownMenuItem(value: -1, child: Text('Custom…')),
                    ],
                    onChanged: (v) async {
                      if (v == null) {
                        await _persist(task.copyWith(estimatedDuration: null));
                      } else if (v == -1) {
                        final c = await showDialog<int>(
                          context: context,
                          builder: (ctx) {
                            final ctrl = TextEditingController(
                              text: '${task.estimatedDuration?.inMinutes ?? 60}',
                            );
                            return AlertDialog(
                              title: const Text('Minutes'),
                              content: TextField(
                                controller: ctrl,
                                keyboardType: TextInputType.number,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(
                                    ctx,
                                    int.tryParse(ctrl.text.trim()),
                                  ),
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                        if (c != null && c > 0) {
                          await _persist(
                            task.copyWith(
                              estimatedDuration: Duration(minutes: c),
                            ),
                          );
                        }
                      } else {
                        await _persist(
                          task.copyWith(
                            estimatedDuration: Duration(minutes: v),
                          ),
                        );
                      }
                    },
                  ),

                  const Divider(),
                  Text('Reminders', style: Theme.of(context).textTheme.titleSmall),
                  ...task.reminders.asMap().entries.map((e) {
                    final r = e.value;
                    return ListTile(
                      title: Text(
                        '${r.offsetBeforeDue.inMinutes} min before '
                        '${r.anchorToDue ? 'due' : 'planned'}',
                      ),
                      subtitle: Text('key: ${r.dedupeKey}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showReminderDialog(
                              context,
                              task,
                              existing: r,
                              index: e.key,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final next = List<TaskReminder>.from(task.reminders)
                                ..removeAt(e.key);
                              await _persist(task.copyWith(reminders: next));
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _showReminderDialog(context, task),
                      icon: const Icon(Icons.add_alarm),
                      label: const Text('Add reminder'),
                    ),
                  ),

                  const Divider(),
                  ListTile(
                    title: Text(
                      task.recurrenceRule == null
                          ? 'Recurrence: none'
                          : 'Recurrence: ${task.recurrenceRule!.frequency.name} '
                              'every ${task.recurrenceRule!.interval}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.repeat),
                      onPressed: () => _showRecurrenceDialog(context, task),
                    ),
                  ),

                  const Divider(),
                  Text('Steps', style: Theme.of(context).textTheme.titleSmall),
                  ...task.steps.map((s) {
                    return Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: s.done,
                                onChanged: (v) async {
                                  final next = task.steps
                                      .map(
                                        (x) => x.id == s.id
                                            ? x.copyWith(done: v ?? false)
                                            : x,
                                      )
                                      .toList();
                                  await _persist(task.copyWith(steps: next));
                                },
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: s.title,
                                  decoration: const InputDecoration(
                                    hintText: 'Step title',
                                    border: InputBorder.none,
                                  ),
                                  onFieldSubmitted: (v) async {
                                    final t2 = v.trim();
                                    if (t2.isEmpty) return;
                                    final next = task.steps
                                        .map(
                                          (x) => x.id == s.id
                                              ? x.copyWith(title: t2)
                                              : x,
                                        )
                                        .toList();
                                    await _persist(task.copyWith(steps: next));
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final next = task.steps
                                      .where((x) => x.id != s.id)
                                      .toList();
                                  await _persist(task.copyWith(steps: next));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _stepAddCtrl,
                          decoration: const InputDecoration(
                            hintText: 'New step',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () async {
                          final t2 = _stepAddCtrl.text.trim();
                          if (t2.isEmpty) return;
                          final next = [
                            ...task.steps,
                            TaskStep(id: Uuid().v4(), title: t2),
                          ];
                          _stepAddCtrl.clear();
                          await _persist(task.copyWith(steps: next));
                        },
                      ),
                    ],
                  ),

                  const Divider(),
                  Text('Tags', style: Theme.of(context).textTheme.titleSmall),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ...task.tags.map(
                        (tag) => InputChip(
                          label: Text(tag),
                          onDeleted: () async {
                            final next = task.tags.where((e) => e != tag).toList();
                            await _persist(task.copyWith(tags: next));
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('task_detail_tag_add'),
                          controller: _tagCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Add tag',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (v) async {
                            final t2 = v.trim().toLowerCase();
                            if (t2.isEmpty) return;
                            if (task.tags.contains(t2)) return;
                            await _persist(
                              task.copyWith(tags: [...task.tags, t2]),
                            );
                            _tagCtrl.clear();
                          },
                        ),
                      ),
                    ],
                  ),

                  const Divider(),
                  Text('Assignees', style: Theme.of(context).textTheme.titleSmall),
                  Wrap(
                    spacing: 6,
                    children: knownAssignees.map((id) {
                      final on = task.assigneeIds.contains(id);
                      return FilterChip(
                        label: Text(
                          id == meId ? 'Me' : id.substring(0, 8),
                        ),
                        selected: on,
                        onSelected: (v) async {
                          final next = List<String>.from(task.assigneeIds);
                          if (v) {
                            if (!next.contains(id)) next.add(id);
                          } else {
                            next.remove(id);
                          }
                          await _persist(task.copyWith(assigneeIds: next));
                        },
                      );
                    }).toList(),
                  ),

                  const Divider(),
                  Text('Links', style: Theme.of(context).textTheme.titleSmall),
                  ...task.links.asMap().entries.map(
                    (e) => ListTile(
                      title: Text(e.value.label ?? e.value.url),
                      subtitle: Text(e.value.url),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final next = List<TaskLink>.from(task.links)
                            ..removeAt(e.key);
                          await _persist(task.copyWith(links: next));
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => _showLinkDialog(context, task),
                      icon: const Icon(Icons.link),
                      label: const Text('Add link'),
                    ),
                  ),

                  const Divider(),
                  Text('Attachments', style: Theme.of(context).textTheme.titleSmall),
                  ...task.attachments.asMap().entries.map(
                    (e) => ListTile(
                      title: Text(e.value.filename ?? e.value.localUri ?? 'File'),
                      subtitle: Text(e.value.localUri ?? e.value.storagePath ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          final next = List<TaskAttachment>.from(task.attachments)
                            ..removeAt(e.key);
                          await _persist(task.copyWith(attachments: next));
                        },
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final res = await FilePicker.platform.pickFiles(
                        withData: true,
                      );
                      if (res == null || res.files.isEmpty) return;
                      final f = res.files.single;
                      final path = f.path;
                      final next = [
                        ...task.attachments,
                        TaskAttachment(
                          filename: f.name,
                          localUri: path,
                          mimeType: null,
                          sizeBytes: f.size,
                        ),
                      ];
                      await _persist(task.copyWith(attachments: next));
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Add attachment…'),
                  ),

                  const Divider(),
                  DropdownButtonFormField<String?>(
                    value: task.color,
                    decoration: const InputDecoration(labelText: 'Color (hex)'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Default')),
                      DropdownMenuItem(value: '#1565C0', child: Text('Blue')),
                      DropdownMenuItem(value: '#43A047', child: Text('Green')),
                      DropdownMenuItem(value: '#E65100', child: Text('Orange')),
                      DropdownMenuItem(value: '#6A1B9A', child: Text('Purple')),
                    ],
                    onChanged: (c) => _persist(task.copyWith(color: c)),
                  ),

                  const Divider(),
                  Text('Linked calendar', style: Theme.of(context).textTheme.titleSmall),
                  if (task.sourceEventId != null)
                    ListTile(
                      title: const Text('Source calendar event'),
                      subtitle: Text(task.sourceEventId!),
                    ),
                  if (task.scheduledEventId != null)
                    ListTile(
                      title: const Text('Scheduled calendar block'),
                      subtitle: Text(task.scheduledEventId!),
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
}

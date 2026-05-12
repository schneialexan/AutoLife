import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/event_form_screen.dart';
import 'package:auto_calendar/src/screens/calendar/recurrence_editor_sheet.dart';
import 'package:auto_calendar/src/providers/reminder_notification_provider.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class QuickCreateSheet extends ConsumerStatefulWidget {
  const QuickCreateSheet({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<QuickCreateSheet> createState() => _QuickCreateSheetState();
}

class _QuickCreateSheetState extends ConsumerState<QuickCreateSheet> {
  final _title = TextEditingController();
  DateTime _start = DateTime.now().toUtc();
  DateTime _end = DateTime.now().toUtc().add(const Duration(hours: 1));
  String? _memberId;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start.toLocal()),
    );
    if (t != null) {
      final l = _start.toLocal();
      setState(() {
        _start = DateTime(l.year, l.month, l.day, t.hour, t.minute).toUtc();
        if (!_end.isAfter(_start)) {
          _end = _start.add(const Duration(hours: 1));
        }
      });
    }
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty) return;
    final repo = ref.read(calendarRepositoryProvider);
    final reminders = ref.read(reminderNotificationServiceProvider);
    final id = const Uuid().v4();
    final now = DateTime.now().toUtc();
    final uid = '11111111-1111-1111-1111-111111111111';
    final event = CalendarEvent(
      id: id,
      familyId: widget.familyId,
      title: _title.text.trim(),
      startAt: _start,
      endAt: _end,
      allDay: false,
      taggedMemberIds: _memberId != null ? [_memberId!] : const [],
      createdBy: uid,
      syncSource: 'internal',
      reminders: const [
        CalendarReminder(
          offsetBeforeStart: Duration(minutes: -15),
          dedupeKey: 'qc-default',
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
    await repo.upsert(event);
    await reminders.schedule(event);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final seeds = ref.watch(calendarMemberSeedsProvider);
    final timeFmt = DateFormat.jm('en');
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Quick create', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              '${timeFmt.format(_start.toLocal())} — ${timeFmt.format(_end.toLocal())}',
            ),
            trailing: TextButton(onPressed: _pickStart, child: const Text('Time')),
          ),
          DropdownButtonFormField<String?>(
            key: ValueKey(_memberId ?? ''),
            decoration: const InputDecoration(labelText: 'Tagged member'),
            initialValue: _memberId,
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('None'),
              ),
              ...seeds.map(
                (s) => DropdownMenuItem(value: s.id, child: Text(s.label)),
              ),
            ],
            onChanged: (v) => setState(() => _memberId = v),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const RecurrenceEditorSheet(),
                );
              },
              child: const Text('Recurrence (advanced)'),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        EventFormScreen(familyId: widget.familyId),
                  ),
                );
              },
              child: const Text('Open full form'),
            ),
          ),
          FilledButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

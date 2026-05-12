import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/recurrence_editor_sheet.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/conflict_bar.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Full event editor with persisted rich fields.
class EventFormScreen extends ConsumerStatefulWidget {
  const EventFormScreen({
    super.key,
    required this.familyId,
    this.existing,
  });

  final String familyId;
  final CalendarEvent? existing;

  @override
  ConsumerState<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends ConsumerState<EventFormScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _notes = TextEditingController();
  final _location = TextEditingController();

  late DateTime _startLocal;
  late DateTime _endLocal;
  bool _allDay = false;

  final Set<String> _tagged = {};
  final List<CalendarAttendee> _attendees = [];
  final List<CalendarEventLink> _links = [];
  final List<CalendarEventAttachment> _attachments = [];
  final Set<String> _related = {};
  CalendarRecurrenceRule? _recurrence;
  final List<CalendarReminder> _reminders = [];

  int _reminderPresetMinutes = 15;

  final _attendeeName = TextEditingController();
  final _attendeeEmail = TextEditingController();
  final _linkUrl = TextEditingController();
  final _linkLabel = TextEditingController();

  static const _demoCreatedBy = '11111111-1111-1111-1111-111111111111';

  String _reminderListTitle(CalendarReminder r) {
    final m = r.offsetBeforeStart.inMinutes;
    if (m == 0) return 'At event start';
    if (m < 0) return '${-m} min before start';
    return '$m min after start';
  }

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final now = DateTime.now();
    if (e != null) {
      _title.text = e.title;
      _description.text = e.description ?? '';
      _notes.text = e.notes ?? '';
      _location.text = e.location ?? '';
      _startLocal = e.startAt.toLocal();
      _endLocal = e.endAt.toLocal();
      _allDay = e.allDay;
      _tagged.addAll(e.taggedMemberIds);
      _attendees.addAll(e.attendees);
      _links.addAll(e.links);
      _attachments.addAll(e.attachments);
      _related.addAll(e.relatedEventIds);
      _recurrence = e.recurrenceRule;
      _reminders.addAll(e.reminders);
    } else {
      _startLocal = DateTime(now.year, now.month, now.day, now.hour);
      _endLocal = _startLocal.add(const Duration(hours: 1));
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _notes.dispose();
    _location.dispose();
    _attendeeName.dispose();
    _attendeeEmail.dispose();
    _linkUrl.dispose();
    _linkLabel.dispose();
    super.dispose();
  }

  List<DateTime> _suggest(CalendarEvent candidate, List<CalendarEvent> existing) {
    final conflicts = existing.where((ev) {
      return ev.id != candidate.id &&
          ev.startAt.toUtc().isBefore(candidate.endAt.toUtc()) &&
          ev.endAt.toUtc().isAfter(candidate.startAt.toUtc());
    });
    if (conflicts.isEmpty) return const [];
    final alt = candidate.endAt.difference(candidate.startAt);
    return [
      conflicts.first.endAt.toUtc(),
      conflicts.first.endAt.toUtc().add(const Duration(hours: 1)),
    ].map((s) => s.add(alt)).toList();
  }

  Future<void> _pickStartDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startLocal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    setState(() {
      _startLocal = DateTime(
        d.year,
        d.month,
        d.day,
        _startLocal.hour,
        _startLocal.minute,
      );
      if (!_endLocal.isAfter(_startLocal)) {
        _endLocal = _startLocal.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickEndDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _endLocal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    setState(() {
      _endLocal = DateTime(
        d.year,
        d.month,
        d.day,
        _endLocal.hour,
        _endLocal.minute,
      );
      if (!_endLocal.isAfter(_startLocal)) {
        _endLocal = _startLocal.add(const Duration(minutes: 30));
      }
    });
  }

  Future<void> _pickStartTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startLocal),
    );
    if (t == null) return;
    setState(() {
      _startLocal = DateTime(
        _startLocal.year,
        _startLocal.month,
        _startLocal.day,
        t.hour,
        t.minute,
      );
      if (!_endLocal.isAfter(_startLocal)) {
        _endLocal = _startLocal.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickEndTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endLocal),
    );
    if (t == null) return;
    setState(() {
      _endLocal = DateTime(
        _endLocal.year,
        _endLocal.month,
        _endLocal.day,
        t.hour,
        t.minute,
      );
      if (!_endLocal.isAfter(_startLocal)) {
        _endLocal = _startLocal.add(const Duration(minutes: 30));
      }
    });
  }

  Future<void> _openRecurrence() async {
    final rule = await showModalBottomSheet<CalendarRecurrenceRule?>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          RecurrenceEditorSheet(initial: _recurrence),
    );
    setState(() => _recurrence = rule);
  }

  Future<void> _pickAttachment() async {
    final res = await FilePicker.platform.pickFiles();
    if (res == null || res.files.isEmpty) return;
    final f = res.files.single;
    setState(() {
      _attachments.add(
        CalendarEventAttachment(
          filename: f.name,
          sizeBytes: f.size,
          mimeType: f.extension != null ? 'application/${f.extension}' : null,
          localUri: f.path ?? f.identifier,
        ),
      );
    });
  }

  Future<void> _pickRelated() async {
    final repo = ref.read(calendarRepositoryProvider);
    final all = await repo.watchFamily(widget.familyId).first;
    final curId = widget.existing?.id;
    final others = all.where((e) => e.id != curId).toList();
    if (!mounted) return;
    final selected = Set<String>.from(_related);
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Link related events'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: others.length,
                  itemBuilder: (c, i) {
                    final e = others[i];
                    return CheckboxListTile(
                      value: selected.contains(e.id),
                      onChanged: (v) {
                        setDialogState(() {
                          if (v == true) {
                            selected.add(e.id);
                          } else {
                            selected.remove(e.id);
                          }
                        });
                      },
                      title: Text(e.title),
                      subtitle: Text(
                        '${e.startAt.toLocal()}'.split('.').first,
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _related
                        ..clear()
                        ..addAll(selected);
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addAttendee() {
    final name = _attendeeName.text.trim();
    final email = _attendeeEmail.text.trim();
    if (name.isEmpty && email.isEmpty) return;
    setState(() {
      _attendees.add(CalendarAttendee(displayName: name.isEmpty ? null : name, email: email.isEmpty ? null : email));
      _attendeeName.clear();
      _attendeeEmail.clear();
    });
  }

  void _addLink() {
    final url = _linkUrl.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _links.add(CalendarEventLink(url: url, label: _linkLabel.text.trim().isEmpty ? null : _linkLabel.text.trim()));
      _linkUrl.clear();
      _linkLabel.clear();
    });
  }

  void _addReminder() {
    final minutes = _reminderPresetMinutes;
    final offset = Duration(minutes: -minutes);
    setState(() {
      _reminders.add(
        CalendarReminder(
          offsetBeforeStart: offset,
          dedupeKey: minutes == 0
              ? 'form-${_reminders.length}-at-start'
              : 'form-${_reminders.length}-$minutes',
        ),
      );
    });
  }

  Future<void> _save() async {
    final repo = ref.read(calendarRepositoryProvider);
    final list = await repo.watchFamily(widget.familyId).first;
    final now = DateTime.now().toUtc();
    final existing = widget.existing;
    final id = existing?.id ?? const Uuid().v4();
    final startUtc = _startLocal.toUtc();
    var endUtc = _endLocal.toUtc();
    if (_allDay) {
      endUtc = DateTime.utc(_startLocal.year, _startLocal.month, _startLocal.day, 23, 59, 59);
    }
    if (!endUtc.isAfter(startUtc)) {
      endUtc = startUtc.add(const Duration(hours: 1));
    }

    final cand = CalendarEvent(
      id: id,
      familyId: widget.familyId,
      title: _title.text.trim().isEmpty ? 'Untitled' : _title.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      location: _location.text.trim().isEmpty ? null : _location.text.trim(),
      startAt: startUtc,
      endAt: endUtc,
      allDay: _allDay,
      taggedMemberIds: _tagged.toList(),
      attendees: List.unmodifiable(_attendees),
      links: List.unmodifiable(_links),
      attachments: List.unmodifiable(_attachments),
      relatedEventIds: _related.toList(),
      createdBy: existing?.createdBy ?? _demoCreatedBy,
      syncSource: existing?.syncSource ?? 'internal',
      externalId: existing?.externalId,
      provider: existing?.provider,
      externalUid: existing?.externalUid,
      syncedByUserId: existing?.syncedByUserId,
      lastSyncedAt: existing?.lastSyncedAt,
      recurrenceRule: _recurrence,
      reminders: List.unmodifiable(_reminders),
      seriesId: existing?.seriesId,
      exceptionOriginalStart: existing?.exceptionOriginalStart,
      commuteMeta: existing?.commuteMeta,
      color: existing?.color,
      assignedTo: existing?.assignedTo,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    final alts = _suggest(cand, list);
    if (alts.isNotEmpty && mounted) {
      final go = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Scheduling conflict'),
          content: ConflictBar(
            title: 'Suggested alternative start times:',
            alternatives: alts,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save anyway'),
            ),
          ],
        ),
      );
      if (go != true) return;
    }

    await repo.upsert(cand);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final seeds = ref.watch(calendarMemberSeedsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New event' : 'Edit event'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _description,
            decoration: const InputDecoration(labelText: 'Description'),
            minLines: 1,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('All day'),
            value: _allDay,
            onChanged: (v) => setState(() => _allDay = v),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _allDay
                  ? 'Date: ${_startLocal.toLocal().toString().split(' ').take(1).join()}'
                  : 'Starts: ${_startLocal.toString().split('.').first}',
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickStartDate,
          ),
          if (!_allDay)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start time'),
              trailing: Text(MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_startLocal))),
              onTap: _pickStartTime,
            ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _allDay
                  ? 'Ends (date): ${_endLocal.toLocal().toString().split(' ').take(1).join()}'
                  : 'Ends: ${_endLocal.toString().split('.').first}',
            ),
            trailing: const Icon(Icons.event_outlined),
            onTap: _pickEndDate,
          ),
          if (!_allDay)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('End time'),
              trailing: Text(MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_endLocal))),
              onTap: _pickEndTime,
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _location,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          const SizedBox(height: 16),
          Text('Tagged members', style: Theme.of(context).textTheme.titleSmall),
          Wrap(
            spacing: 8,
            children: seeds.map((m) {
              final on = _tagged.contains(m.id);
              return FilterChip(
                label: Text(m.label),
                selected: on,
                onSelected: (v) => setState(() {
                  if (v) {
                    _tagged.add(m.id);
                  } else {
                    _tagged.remove(m.id);
                  }
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Attendees', style: Theme.of(context).textTheme.titleSmall),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _attendeeName,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _attendeeEmail,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ),
              IconButton(onPressed: _addAttendee, icon: const Icon(Icons.add)),
            ],
          ),
          ..._attendees.map(
            (a) => ListTile(
              title: Text(a.displayName ?? a.email ?? 'Guest'),
              subtitle: a.email != null ? Text(a.email!) : null,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => _attendees.remove(a)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Notes', style: Theme.of(context).textTheme.titleSmall),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notes'),
            minLines: 4,
            maxLines: 10,
          ),
          const SizedBox(height: 16),
          Text('Links', style: Theme.of(context).textTheme.titleSmall),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _linkUrl,
                  decoration: const InputDecoration(labelText: 'URL'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _linkLabel,
                  decoration: const InputDecoration(labelText: 'Label'),
                ),
              ),
              IconButton(onPressed: _addLink, icon: const Icon(Icons.add_link)),
            ],
          ),
          ..._links.map(
            (l) => ListTile(
              title: Text(l.label ?? l.url),
              subtitle: Text(l.url),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => _links.remove(l)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Attachments', style: Theme.of(context).textTheme.titleSmall),
          OutlinedButton.icon(
            onPressed: _pickAttachment,
            icon: const Icon(Icons.attach_file),
            label: const Text('Add file…'),
          ),
          ..._attachments.map(
            (a) => ListTile(
              title: Text(a.filename ?? 'Attachment'),
              subtitle: Text(a.localUri ?? a.storagePath ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => _attachments.remove(a)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _recurrence == null ? 'Does not repeat' : 'Recurrence set',
            ),
            trailing: const Icon(Icons.repeat),
            onTap: _openRecurrence,
          ),
          const SizedBox(height: 8),
          Text('Reminders', style: Theme.of(context).textTheme.titleSmall),
          Row(
            children: [
              DropdownButton<int>(
                value: _reminderPresetMinutes,
                items: const [0, 5, 10, 15, 30, 60, 1440]
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(m == 0 ? 'At start' : '$m min before'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _reminderPresetMinutes = v ?? 15),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(onPressed: _addReminder, child: const Text('Add')),
            ],
          ),
          ..._reminders.asMap().entries.map(
            (e) => ListTile(
              title: Text(_reminderListTitle(e.value)),
              subtitle: Text(e.value.dedupeKey),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => setState(() => _reminders.removeAt(e.key)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Related events (${_related.length})'),
            trailing: const Icon(Icons.hub_outlined),
            onTap: _pickRelated,
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}

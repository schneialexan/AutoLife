import 'package:auto_calendar/src/providers/calendar_providers.dart';
import 'package:auto_calendar/src/screens/calendar/event_form_screen.dart';
import 'package:auto_calendar/src/screens/calendar/widgets/event_accent_color.dart';
import 'package:autolife_core/autolife_core.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

String _describeRecurrence(CalendarRecurrenceRule? r) {
  if (r == null) return 'Does not repeat';
  final freq = r.frequency.name;
  final interval = r.interval;
  final wd = r.byWeekday.isEmpty
      ? ''
      : ' on weekdays ${r.byWeekday.join(', ')}';
  final until = r.until != null
      ? ' until ${DateFormat.yMMMd('en').format(r.until!.toLocal())}'
      : '';
  final count = r.count != null ? ' (${r.count} occurrences max)' : '';
  return 'Every $interval $freq$wd$until$count';
}

String _reminderTitle(CalendarReminder r) {
  final m = r.offsetBeforeStart.inMinutes;
  if (m == 0) return 'At event start';
  if (m < 0) return '${-m} min before start';
  return '$m min after start';
}

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({
    super.key,
    required this.eventId,
    required this.familyId,
  });

  final String eventId;
  final String familyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(calendarRepositoryProvider);
    final seeds = ref.watch(calendarMemberSeedsProvider);
    return StreamBuilder<List<CalendarEvent>>(
      stream: repo.watchFamily(familyId),
      builder: (context, snap) {
        final events = snap.data ?? const [];
        final event = events.firstWhereOrNull((e) => e.id == eventId);
        if (event == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Event not found')),
          );
        }
        final dateFmt = DateFormat.yMMMEd('en');
        final accent = calendarEventAccentColor(event, seeds);

        String? memberLabel(String id) =>
            seeds.firstWhereOrNull((m) => m.id == id)?.label;

        Future<void> openUrl(String url) async {
          final uri = Uri.tryParse(url);
          if (uri == null) return;
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open: $url')),
              );
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(event.title),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => EventFormScreen(
                        familyId: familyId,
                        existing: event,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.allDay
                              ? '${dateFmt.format(event.startAt.toLocal())} (all day)'
                              : '${DateFormat.jm('en').format(event.startAt.toLocal())} – '
                                  '${DateFormat.jm('en').format(event.endAt.toLocal())}\n'
                                  '${dateFmt.format(event.startAt.toLocal())}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (event.description != null &&
                            event.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              event.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionTitle(context, 'Where'),
              if (event.location != null && event.location!.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined),
                  title: Text(event.location!),
                )
              else
                _emptyHint(context, 'No location'),
              const SizedBox(height: 16),
              _sectionTitle(context, 'Scheduling'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.repeat),
                title: Text(_describeRecurrence(event.recurrenceRule)),
                subtitle: event.seriesId != null
                    ? Text('Series id: ${event.seriesId}')
                    : null,
              ),
              if (event.exceptionOriginalStart != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_repeat),
                  title: const Text('Exception instance'),
                  subtitle: Text(
                    'Original occurrence: ${event.exceptionOriginalStart!.toLocal()}',
                  ),
                ),
              if (event.reminders.isNotEmpty) ...[
                const SizedBox(height: 8),
                _sectionTitle(context, 'Reminders'),
                ...event.reminders.map(
                  (r) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(_reminderTitle(r)),
                    subtitle: Text('Dedupe: ${r.dedupeKey}'),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _sectionTitle(context, 'People'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: Text(memberLabel(event.createdBy) ?? 'Organizer'),
                subtitle: Text('Profile: ${event.createdBy}'),
              ),
              if (event.assignedTo != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.assignment_ind_outlined),
                  title: Text(
                    memberLabel(event.assignedTo!) ?? 'Assignee',
                  ),
                  subtitle: Text(event.assignedTo!),
                ),
              if (event.taggedMemberIds.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Tagged members',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: event.taggedMemberIds
                      .map(
                        (id) => Chip(
                          label: Text(memberLabel(id) ?? id),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (event.attendees.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Attendees',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ...event.attendees.map(
                  (a) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.group_outlined),
                    title: Text(a.displayName ?? a.email ?? a.profileId ?? 'Guest'),
                    subtitle: a.email != null ? Text(a.email!) : null,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _sectionTitle(context, 'Notes'),
              if (event.notes != null && event.notes!.isNotEmpty)
                Text(event.notes!)
              else
                _emptyHint(context, 'No notes'),
              const SizedBox(height: 16),
              _sectionTitle(context, 'Links'),
              if (event.links.isEmpty)
                _emptyHint(context, 'No links')
              else
                ...event.links.map(
                  (l) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.link),
                    title: Text(l.label ?? l.url),
                    subtitle: Text(l.url),
                    onTap: () => openUrl(l.url),
                  ),
                ),
              const SizedBox(height: 16),
              _sectionTitle(context, 'Attachments'),
              if (event.attachments.isEmpty)
                _emptyHint(context, 'No attachments')
              else
                ...event.attachments.map(
                  (a) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.attach_file),
                    title: Text(a.filename ?? 'File'),
                    subtitle: Text(
                      [
                        if (a.mimeType != null) a.mimeType!,
                        if (a.localUri != null) a.localUri!,
                        if (a.storagePath != null) a.storagePath!,
                      ].where((s) => s.isNotEmpty).join('\n'),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              _sectionTitle(context, 'Related events'),
              if (event.relatedEventIds.isEmpty)
                _emptyHint(context, 'None linked')
              else
                ...event.relatedEventIds.map((rid) {
                  final other = events.firstWhereOrNull((e) => e.id == rid);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.hub_outlined),
                    title: Text(other?.title ?? 'Unknown event'),
                    subtitle: Text(rid),
                    onTap: other == null
                        ? null
                        : () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => EventDetailScreen(
                                  eventId: other.id,
                                  familyId: familyId,
                                ),
                              ),
                            );
                          },
                  );
                }),
              const SizedBox(height: 16),
              _sectionTitle(context, 'Sync & metadata'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.sync),
                title: Text('Source: ${event.syncSource}'),
                subtitle: Text(
                  [
                    if (event.provider != null) 'Provider: ${event.provider}',
                    if (event.externalId != null) 'External id: ${event.externalId}',
                    if (event.externalUid != null) 'External UID: ${event.externalUid}',
                    if (event.lastSyncedAt != null)
                      'Last synced: ${event.lastSyncedAt}',
                  ].whereType<String>().join('\n'),
                ),
              ),
              if (event.commuteMeta != null && event.commuteMeta!.isNotEmpty)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.directions_car_outlined),
                  title: const Text('Commute meta'),
                  subtitle: Text(event.commuteMeta.toString()),
                ),
            ],
          ),
        );
      },
    );
  }
}

Widget _sectionTitle(BuildContext context, String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        t,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );

Widget _emptyHint(BuildContext context, String t) => Text(
      t,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).hintColor,
          ),
    );

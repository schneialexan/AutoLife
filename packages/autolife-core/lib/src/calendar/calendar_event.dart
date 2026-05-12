import 'calendar_attendee.dart';
import 'calendar_event_attachment.dart';
import 'calendar_event_link.dart';
import 'calendar_recurrence.dart';
import 'calendar_reminder.dart';

/// Row shape for `calendar_events` (PostgREST + local cache).
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.familyId,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.allDay,
    required this.createdBy,
    required this.syncSource,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.notes,
    this.location,
    this.assignedTo,
    this.taggedMemberIds = const [],
    this.color,
    this.externalId,
    this.provider,
    this.externalUid,
    this.syncedByUserId,
    this.lastSyncedAt,
    this.recurrenceRule,
    this.reminders = const [],
    this.seriesId,
    this.exceptionOriginalStart,
    this.commuteMeta,
    this.links = const [],
    this.attachments = const [],
    this.relatedEventIds = const [],
    this.attendees = const [],
    this.isTaskBlock = false,
    this.linkedTaskId,
  });

  final String id;
  final String familyId;
  final String title;
  final String? description;
  final String? notes;
  final String? location;
  final DateTime startAt;
  final DateTime endAt;
  final bool allDay;
  final String? assignedTo;
  final List<String> taggedMemberIds;
  final String createdBy;
  final String? color;
  final String syncSource;
  final String? externalId;
  final String? provider;
  final String? externalUid;
  final String? syncedByUserId;
  final DateTime? lastSyncedAt;
  final CalendarRecurrenceRule? recurrenceRule;
  final List<CalendarReminder> reminders;
  final String? seriesId;
  final DateTime? exceptionOriginalStart;
  final Map<String, dynamic>? commuteMeta;
  final List<CalendarEventLink> links;
  final List<CalendarEventAttachment> attachments;
  final List<String> relatedEventIds;
  final List<CalendarAttendee> attendees;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// When true, this event is a scheduled work block for [linkedTaskId].
  final bool isTaskBlock;
  final String? linkedTaskId;

  CalendarEvent copyWith({
    String? id,
    String? familyId,
    String? title,
    String? description,
    String? notes,
    String? location,
    DateTime? startAt,
    DateTime? endAt,
    bool? allDay,
    String? assignedTo,
    List<String>? taggedMemberIds,
    String? createdBy,
    String? color,
    String? syncSource,
    String? externalId,
    String? provider,
    String? externalUid,
    String? syncedByUserId,
    DateTime? lastSyncedAt,
    CalendarRecurrenceRule? recurrenceRule,
    List<CalendarReminder>? reminders,
    String? seriesId,
    DateTime? exceptionOriginalStart,
    Map<String, dynamic>? commuteMeta,
    List<CalendarEventLink>? links,
    List<CalendarEventAttachment>? attachments,
    List<String>? relatedEventIds,
    List<CalendarAttendee>? attendees,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isTaskBlock,
    String? linkedTaskId,
  }) => CalendarEvent(
    id: id ?? this.id,
    familyId: familyId ?? this.familyId,
    title: title ?? this.title,
    description: description ?? this.description,
    notes: notes ?? this.notes,
    location: location ?? this.location,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    allDay: allDay ?? this.allDay,
    assignedTo: assignedTo ?? this.assignedTo,
    taggedMemberIds: taggedMemberIds ?? this.taggedMemberIds,
    createdBy: createdBy ?? this.createdBy,
    color: color ?? this.color,
    syncSource: syncSource ?? this.syncSource,
    externalId: externalId ?? this.externalId,
    provider: provider ?? this.provider,
    externalUid: externalUid ?? this.externalUid,
    syncedByUserId: syncedByUserId ?? this.syncedByUserId,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    recurrenceRule: recurrenceRule ?? this.recurrenceRule,
    reminders: reminders ?? this.reminders,
    seriesId: seriesId ?? this.seriesId,
    exceptionOriginalStart:
        exceptionOriginalStart ?? this.exceptionOriginalStart,
    commuteMeta: commuteMeta ?? this.commuteMeta,
    links: links ?? this.links,
    attachments: attachments ?? this.attachments,
    relatedEventIds: relatedEventIds ?? this.relatedEventIds,
    attendees: attendees ?? this.attendees,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isTaskBlock: isTaskBlock ?? this.isTaskBlock,
    linkedTaskId: linkedTaskId ?? this.linkedTaskId,
  );

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    DateTime parseTs(String key) {
      final raw = json[key];
      if (raw is! String) {
        throw FormatException('Missing or invalid timestamp: $key');
      }
      return DateTime.parse(raw);
    }

    List<String> parseTagged(Object? raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return const [];
    }

    List<CalendarReminder> parseReminders(Object? raw) {
      if (raw is! List) return const [];
      final out = <CalendarReminder>[];
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          out.add(CalendarReminder.fromJson(e));
        }
      }
      return out;
    }

    List<CalendarEventLink> parseLinks(Object? raw) {
      if (raw is! List) return const [];
      final out = <CalendarEventLink>[];
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          final link = CalendarEventLink.fromJson(e);
          if (link.url.isNotEmpty) out.add(link);
        }
      }
      return out;
    }

    List<CalendarEventAttachment> parseAttachments(Object? raw) {
      if (raw is! List) return const [];
      final out = <CalendarEventAttachment>[];
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          out.add(CalendarEventAttachment.fromJson(e));
        }
      }
      return out;
    }

    List<String> parseRelated(Object? raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return const [];
    }

    List<CalendarAttendee> parseAttendees(Object? raw) {
      if (raw is! List) return const [];
      final out = <CalendarAttendee>[];
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          out.add(CalendarAttendee.fromJson(e));
        }
      }
      return out;
    }

    CalendarRecurrenceRule? rec;
    final rawRec = json['recurrence'];
    if (rawRec is Map<String, dynamic>) {
      rec = CalendarRecurrenceRule.fromJson(rawRec);
    }

    return CalendarEvent(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      startAt: parseTs('start_at'),
      endAt: parseTs('end_at'),
      allDay: json['all_day'] as bool? ?? false,
      assignedTo: json['assigned_to']?.toString(),
      taggedMemberIds: parseTagged(json['tagged_members']),
      createdBy: json['created_by'].toString(),
      color: json['color'] as String?,
      syncSource: json['sync_source'] as String? ?? 'internal',
      externalId: json['external_id'] as String?,
      provider: json['provider'] as String?,
      externalUid: json['external_uid'] as String?,
      syncedByUserId: json['synced_by_user_id']?.toString(),
      lastSyncedAt: json['last_synced_at'] == null
          ? null
          : parseTs('last_synced_at'),
      recurrenceRule: rec,
      reminders: parseReminders(json['reminders']),
      seriesId: json['series_id'] as String?,
      exceptionOriginalStart: json['exception_original_start'] == null
          ? null
          : parseTs('exception_original_start'),
      commuteMeta: json['commute_meta'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['commute_meta'] as Map)
          : null,
      links: parseLinks(json['event_links']),
      attachments: parseAttachments(json['event_attachments']),
      relatedEventIds: parseRelated(json['related_event_ids']),
      attendees: parseAttendees(json['event_attendees']),
      createdAt: parseTs('created_at'),
      updatedAt: parseTs('updated_at'),
      isTaskBlock: json['is_task_block'] as bool? ?? false,
      linkedTaskId: json['linked_task_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'family_id': familyId,
    'title': title,
    'description': description,
    'notes': notes,
    'location': location,
    'start_at': startAt.toUtc().toIso8601String(),
    'end_at': endAt.toUtc().toIso8601String(),
    'all_day': allDay,
    'assigned_to': assignedTo,
    'tagged_members': taggedMemberIds,
    'created_by': createdBy,
    'color': color,
    'sync_source': syncSource,
    'external_id': externalId,
    'provider': provider,
    'external_uid': externalUid,
    'synced_by_user_id': syncedByUserId,
    'last_synced_at': lastSyncedAt?.toUtc().toIso8601String(),
    'recurrence': recurrenceRule?.toJson(),
    'reminders': reminders.map((e) => e.toJson()).toList(),
    'series_id': seriesId,
    'exception_original_start':
        exceptionOriginalStart?.toUtc().toIso8601String(),
    'commute_meta': commuteMeta,
    'event_links': links.map((e) => e.toJson()).toList(),
    'event_attachments': attachments.map((e) => e.toJson()).toList(),
    'related_event_ids': relatedEventIds,
    'event_attendees': attendees.map((e) => e.toJson()).toList(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'is_task_block': isTaskBlock,
    'linked_task_id': linkedTaskId,
  };
}

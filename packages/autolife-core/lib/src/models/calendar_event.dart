/// Row shape for `calendar_events` (shell + Supabase).
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
    this.location,
    this.assignedTo,
    this.color,
    this.externalId,
    this.syncedByUserId,
    this.lastSyncedAt,
  });

  final String id;
  final String familyId;
  final String title;
  final String? description;
  final String? location;
  final DateTime startAt;
  final DateTime endAt;
  final bool allDay;
  final String? assignedTo;
  final String createdBy;
  final String? color;
  final String syncSource;
  final String? externalId;
  final String? syncedByUserId;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    DateTime parseTs(String key) {
      final raw = json[key];
      if (raw is! String) {
        throw FormatException('Missing or invalid timestamp: $key');
      }
      return DateTime.parse(raw);
    }

    return CalendarEvent(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      location: json['location'] as String?,
      startAt: parseTs('start_at'),
      endAt: parseTs('end_at'),
      allDay: json['all_day'] as bool? ?? false,
      assignedTo: json['assigned_to'] as String?,
      createdBy: json['created_by'] as String,
      color: json['color'] as String?,
      syncSource: json['sync_source'] as String? ?? 'internal',
      externalId: json['external_id'] as String?,
      syncedByUserId: json['synced_by_user_id'] as String?,
      lastSyncedAt: json['last_synced_at'] == null
          ? null
          : parseTs('last_synced_at'),
      createdAt: parseTs('created_at'),
      updatedAt: parseTs('updated_at'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'family_id': familyId,
    'title': title,
    'description': description,
    'location': location,
    'start_at': startAt.toUtc().toIso8601String(),
    'end_at': endAt.toUtc().toIso8601String(),
    'all_day': allDay,
    'assigned_to': assignedTo,
    'created_by': createdBy,
    'color': color,
    'sync_source': syncSource,
    'external_id': externalId,
    'synced_by_user_id': syncedByUserId,
    'last_synced_at': lastSyncedAt?.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };
}

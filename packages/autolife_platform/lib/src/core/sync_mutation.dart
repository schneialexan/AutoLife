/// The kind of change a [SyncMutation] represents.
enum SyncOperation {
  upsert,
  delete;

  static SyncOperation fromName(String name) {
    return SyncOperation.values.firstWhere(
      (o) => o.name == name,
      orElse: () => SyncOperation.upsert,
    );
  }
}

/// A single record-level change to be mirrored to the server (push) or applied
/// from the server (pull).
///
/// The same shape is used by the outbox (queued local edits), the gateway push
/// path, and the gateway pull path. [payload] mirrors the local model JSON; for
/// [SyncOperation.delete] it may be null.
class SyncMutation {
  const SyncMutation({
    required this.moduleId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.schemaVersion,
    required this.updatedAt,
    required this.deviceId,
    this.payload,
    this.serverUpdatedAt,
  });

  /// Module that owns this entity, e.g. `assets`.
  final String moduleId;

  /// Entity table within the module, e.g. `item` or `category_type`.
  final String entityType;

  /// Stable record id (doubles as the upsert idempotency key).
  final String entityId;

  final SyncOperation operation;

  /// Full model JSON (`Model.toJson()`); null for deletes.
  final Map<String, dynamic>? payload;

  /// Payload schema version, used for upgrade-on-read / refuse-if-newer.
  final int schemaVersion;

  /// Model-level last-modified timestamp, used for last-write-wins.
  final DateTime updatedAt;

  /// Device that produced the change (LWW tie-break).
  final String deviceId;

  /// Server-assigned ordering timestamp; only populated on pulled mutations.
  final DateTime? serverUpdatedAt;

  /// Coalescing key — only the most recent mutation per entity is retained in
  /// the outbox.
  String get coalesceKey => '$moduleId|$entityType|$entityId';

  SyncMutation copyWith({
    SyncOperation? operation,
    Map<String, dynamic>? payload,
    int? schemaVersion,
    DateTime? updatedAt,
    String? deviceId,
    DateTime? serverUpdatedAt,
  }) {
    return SyncMutation(
      moduleId: moduleId,
      entityType: entityType,
      entityId: entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'moduleId': moduleId,
    'entityType': entityType,
    'entityId': entityId,
    'operation': operation.name,
    'payload': payload,
    'schemaVersion': schemaVersion,
    'updatedAt': updatedAt.toIso8601String(),
    'deviceId': deviceId,
    'serverUpdatedAt': serverUpdatedAt?.toIso8601String(),
  };

  factory SyncMutation.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    final rawServer = json['serverUpdatedAt'];
    return SyncMutation(
      moduleId: json['moduleId'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      operation: SyncOperation.fromName(json['operation'] as String),
      payload: rawPayload == null
          ? null
          : (rawPayload as Map).cast<String, dynamic>(),
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deviceId: json['deviceId'] as String? ?? 'unknown',
      serverUpdatedAt: rawServer == null
          ? null
          : DateTime.parse(rawServer as String),
    );
  }
}

class SystemEvent {
  const SystemEvent({
    required this.id,
    required this.familyId,
    required this.idempotencyKey,
    required this.type,
    required this.sourceModule,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final String familyId;
  final String idempotencyKey;
  final String type;
  final String sourceModule;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  factory SystemEvent.fromJson(Map<String, dynamic> json) {
    return SystemEvent(
      id: json['id'] as String,
      familyId: json['family_id'] as String,
      idempotencyKey: json['idempotency_key'] as String,
      type: json['type'] as String,
      sourceModule: json['source_module'] as String,
      payload: (json['payload'] as Map).cast<String, dynamic>(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'family_id': familyId,
        'idempotency_key': idempotencyKey,
        'type': type,
        'source_module': sourceModule,
        'payload': payload,
        'created_at': createdAt.toIso8601String(),
      };
}

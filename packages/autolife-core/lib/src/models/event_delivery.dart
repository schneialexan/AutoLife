class EventDelivery {
  const EventDelivery({
    required this.id,
    required this.eventId,
    required this.consumerModule,
    required this.status,
    required this.retryCount,
    required this.createdAt,
    this.processedAt,
    this.lastError,
  });

  final String id;
  final String eventId;
  final String consumerModule;
  final String status;
  final DateTime? processedAt;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;

  factory EventDelivery.fromJson(Map<String, dynamic> json) {
    return EventDelivery(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      consumerModule: json['consumer_module'] as String,
      status: json['status'] as String,
      processedAt: json['processed_at'] == null
          ? null
          : DateTime.parse(json['processed_at'] as String),
      retryCount: (json['retry_count'] as num).toInt(),
      lastError: json['last_error'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'consumer_module': consumerModule,
        'status': status,
        'processed_at': processedAt?.toIso8601String(),
        'retry_count': retryCount,
        'last_error': lastError,
        'created_at': createdAt.toIso8601String(),
      };
}

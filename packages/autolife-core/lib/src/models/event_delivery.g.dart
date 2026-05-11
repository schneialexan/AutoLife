// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_delivery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventDelivery _$EventDeliveryFromJson(Map<String, dynamic> json) =>
    _EventDelivery(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      consumer: json['consumer'] as String,
      attempt: (json['attempt'] as num).toInt(),
      status: $enumDecode(_$EventDeliveryStatusEnumMap, json['status']),
      lastError: json['last_error'] as String?,
      nextAttemptAt: json['next_attempt_at'] == null
          ? null
          : DateTime.parse(json['next_attempt_at'] as String),
    );

Map<String, dynamic> _$EventDeliveryToJson(_EventDelivery instance) =>
    <String, dynamic>{
      'id': instance.id,
      'event_id': instance.eventId,
      'consumer': instance.consumer,
      'attempt': instance.attempt,
      'status': _$EventDeliveryStatusEnumMap[instance.status]!,
      'last_error': instance.lastError,
      'next_attempt_at': instance.nextAttemptAt?.toIso8601String(),
    };

const _$EventDeliveryStatusEnumMap = {
  EventDeliveryStatus.pending: 'pending',
  EventDeliveryStatus.succeeded: 'succeeded',
  EventDeliveryStatus.failed: 'failed',
  EventDeliveryStatus.deadLetter: 'dead_letter',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EventEnvelope _$EventEnvelopeFromJson(Map<String, dynamic> json) =>
    _EventEnvelope(
      idempotencyKey: json['idempotency_key'] as String,
      orderingTag: json['ordering_tag'] as String,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      sourceModule: json['source_module'] as String,
    );

Map<String, dynamic> _$EventEnvelopeToJson(_EventEnvelope instance) =>
    <String, dynamic>{
      'idempotency_key': instance.idempotencyKey,
      'ordering_tag': instance.orderingTag,
      'occurred_at': instance.occurredAt.toIso8601String(),
      'source_module': instance.sourceModule,
    };

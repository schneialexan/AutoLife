// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SystemEvent _$SystemEventFromJson(Map<String, dynamic> json) => _SystemEvent(
  id: json['id'] as String?,
  tenantId: json['tenant_id'] as String,
  actorId: json['actor_id'] as String,
  module: json['module'] as String,
  type: json['type'] as String,
  payload: _payloadFromJson(json['payload']),
  idempotencyKey: json['idempotency_key'] as String,
  occurredAt: DateTime.parse(json['occurred_at'] as String),
  orderingTag: json['ordering_tag'] as String,
  schemaVersion: (json['schema_version'] as num).toInt(),
);

Map<String, dynamic> _$SystemEventToJson(_SystemEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenant_id': instance.tenantId,
      'actor_id': instance.actorId,
      'module': instance.module,
      'type': instance.type,
      'payload': _payloadToJson(instance.payload),
      'idempotency_key': instance.idempotencyKey,
      'occurred_at': instance.occurredAt.toIso8601String(),
      'ordering_tag': instance.orderingTag,
      'schema_version': instance.schemaVersion,
    };

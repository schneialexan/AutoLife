import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_event.freezed.dart';
part 'system_event.g.dart';

/// Canonical row in `system_event` (phase 1.4). Column names are snake_case in
/// JSON to match Supabase / PostgREST payloads.
@freezed
abstract class SystemEvent with _$SystemEvent {
  const factory SystemEvent({
    String? id,
    @JsonKey(name: 'tenant_id') required String tenantId,
    @JsonKey(name: 'actor_id') required String actorId,
    required String module,
    required String type,
    @JsonKey(fromJson: _payloadFromJson, toJson: _payloadToJson)
    required Map<String, dynamic> payload,
    @JsonKey(name: 'idempotency_key') required String idempotencyKey,
    @JsonKey(name: 'occurred_at') required DateTime occurredAt,
    @JsonKey(name: 'ordering_tag') required String orderingTag,
    @JsonKey(name: 'schema_version') required int schemaVersion,
  }) = _SystemEvent;

  factory SystemEvent.fromJson(Map<String, dynamic> json) =>
      _$SystemEventFromJson(json);
}

Map<String, dynamic> _payloadFromJson(Object? json) =>
    Map<String, dynamic>.from(json as Map);

Map<String, dynamic> _payloadToJson(Map<String, dynamic> payload) => payload;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_envelope.freezed.dart';
part 'event_envelope.g.dart';

/// Producer-side envelope fields that accompany an event payload for ordering
/// and idempotency. Runtime wiring lives in phase 1.5 (`process-event`).
@freezed
abstract class EventEnvelope with _$EventEnvelope {
  const factory EventEnvelope({
    @JsonKey(name: 'idempotency_key') required String idempotencyKey,
    @JsonKey(name: 'ordering_tag') required String orderingTag,
    @JsonKey(name: 'occurred_at') required DateTime occurredAt,
    @JsonKey(name: 'source_module') required String sourceModule,
  }) = _EventEnvelope;

  factory EventEnvelope.fromJson(Map<String, dynamic> json) =>
      _$EventEnvelopeFromJson(json);
}

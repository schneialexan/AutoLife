import 'package:freezed_annotation/freezed_annotation.dart';

import 'event_delivery_status.dart';

part 'event_delivery.freezed.dart';
part 'event_delivery.g.dart';

/// Row in `event_delivery` tracking fan-out attempts for a [SystemEvent].
@freezed
abstract class EventDelivery with _$EventDelivery {
  const factory EventDelivery({
    required String id,
    @JsonKey(name: 'event_id') required String eventId,
    required String consumer,
    required int attempt,
    required EventDeliveryStatus status,
    @JsonKey(name: 'last_error') String? lastError,
    @JsonKey(name: 'next_attempt_at') DateTime? nextAttemptAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _EventDelivery;

  factory EventDelivery.fromJson(Map<String, dynamic> json) =>
      _$EventDeliveryFromJson(json);
}

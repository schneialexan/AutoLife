import 'package:json_annotation/json_annotation.dart';

/// `event_delivery.status` values in Postgres (phase 1.4).
@JsonEnum(fieldRename: FieldRename.snake)
enum EventDeliveryStatus { pending, succeeded, failed, deadLetter }

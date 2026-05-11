import 'package:drift/drift.dart';

import '../../models/event_delivery_status.dart';

/// Maps [EventDeliveryStatus] to the Supabase enum text values.
class EventDeliveryStatusConverter
    extends TypeConverter<EventDeliveryStatus, String> {
  const EventDeliveryStatusConverter();

  @override
  EventDeliveryStatus fromSql(String fromDb) {
    return switch (fromDb) {
      'pending' => EventDeliveryStatus.pending,
      'succeeded' => EventDeliveryStatus.succeeded,
      'failed' => EventDeliveryStatus.failed,
      'dead_letter' => EventDeliveryStatus.deadLetter,
      _ => EventDeliveryStatus.pending,
    };
  }

  @override
  String toSql(EventDeliveryStatus value) => switch (value) {
    EventDeliveryStatus.deadLetter => 'dead_letter',
    _ => value.name,
  };
}

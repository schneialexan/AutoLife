import 'package:drift/drift.dart';

import 'event_delivery_status_map.dart';

/// Local cache of `public.event_delivery`.
class EventDeliveryCache extends Table {
  TextColumn get id => text()();
  TextColumn get eventId => text()();
  TextColumn get consumer => text()();
  IntColumn get attempt => integer()();
  TextColumn get status => text().map(const EventDeliveryStatusConverter())();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

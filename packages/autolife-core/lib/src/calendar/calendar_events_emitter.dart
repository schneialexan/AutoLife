import '../events/event_envelope.dart';
import '../models/system_event.dart';
import '../services/event_producer.dart';
import 'calendar_event.dart';

const String kCalendarModuleName = 'auto_calendar';

/// Emits bus envelopes consumed by shell activity feed, auto-tasks, etc.
class CalendarEventsEmitter {
  CalendarEventsEmitter({
    required EventProducer producer,
    required this.tenantId,
    required this.actorId,
    this.module = kCalendarModuleName,
  }) : _producer = producer;

  final EventProducer _producer;
  final String tenantId;
  final String actorId;
  final String module;

  Future<void> emitCreated(CalendarEvent event, EventEnvelope envelope) =>
      _emit(
        'event.created',
        _eventPayload(event),
        envelope,
      );

  Future<void> emitUpdated(CalendarEvent event, EventEnvelope envelope) =>
      _emit(
        'event.updated',
        _eventPayload(event),
        envelope,
      );

  Future<void> emitDeleted({
    required String eventId,
    required String familyId,
    required EventEnvelope envelope,
  }) => _emit(
    'event.deleted',
    {'event_id': eventId, 'family_id': familyId},
    envelope,
  );

  /// Long-press / overflow: auto-tasks consumes this to create a linked task.
  Future<void> emitConvertToTask({
    required CalendarEvent event,
    required EventEnvelope envelope,
  }) => _emit(
    'event.convert_to_task',
    {
      ..._eventPayload(event),
      'requested_at': envelope.occurredAt.toUtc().toIso8601String(),
    },
    envelope,
  );

  Map<String, dynamic> _eventPayload(CalendarEvent e) => {
    'event': e.toJson(),
  };

  Future<void> _emit(
    String type,
    Map<String, dynamic> payload,
    EventEnvelope envelope,
  ) async {
    final event = SystemEvent(
      tenantId: tenantId,
      actorId: actorId,
      module: module,
      type: type,
      payload: payload,
      idempotencyKey: envelope.idempotencyKey,
      occurredAt: envelope.occurredAt,
      orderingTag: envelope.orderingTag,
      schemaVersion: 1,
    );
    await _producer.publish(event);
  }
}

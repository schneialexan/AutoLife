import '../events/event_envelope.dart';
import '../models/system_event.dart';
import '../services/event_producer.dart';
import 'task.dart';

const String kTasksModuleName = 'auto_tasks';

/// Emits task-related bus envelopes consumed by shell, calendar, assets.
class TasksEventsEmitter {
  TasksEventsEmitter({
    required EventProducer producer,
    required this.tenantId,
    required this.actorId,
    this.module = kTasksModuleName,
  }) : _producer = producer;

  final EventProducer _producer;
  final String tenantId;
  final String actorId;
  final String module;

  Future<void> emitCreated(Task task, EventEnvelope envelope) => _emit(
    'task.created',
    {'task': task.toJson()},
    envelope,
  );

  Future<void> emitUpdated(Task task, EventEnvelope envelope) => _emit(
    'task.updated',
    {'task': task.toJson()},
    envelope,
  );

  Future<void> emitCompleted(Task task, EventEnvelope envelope) => _emit(
    'task.completed',
    {'task': task.toJson()},
    envelope,
  );

  Future<void> emitUnblocked({
    required String taskId,
    required String familyId,
    required EventEnvelope envelope,
  }) => _emit(
    'task.unblocked',
    {'task_id': taskId, 'family_id': familyId},
    envelope,
  );

  Future<void> emitPromoteToEvent({
    required Task task,
    required EventEnvelope envelope,
  }) => _emit(
    'task.promote_to_event',
    {'task': task.toJson()},
    envelope,
  );

  Future<void> emitScheduled({
    required String taskId,
    required String familyId,
    required DateTime startAt,
    required DateTime endAt,
    required String linkedEventId,
    required EventEnvelope envelope,
  }) => _emit(
    'task.scheduled',
    {
      'task_id': taskId,
      'family_id': familyId,
      'start_at': startAt.toUtc().toIso8601String(),
      'end_at': endAt.toUtc().toIso8601String(),
      'linked_event_id': linkedEventId,
    },
    envelope,
  );

  Future<void> emitUnscheduled({
    required String taskId,
    required String familyId,
    required EventEnvelope envelope,
  }) => _emit(
    'task.unscheduled',
    {'task_id': taskId, 'family_id': familyId},
    envelope,
  );

  Future<void> emitDueChanged({
    required String taskId,
    required String familyId,
    required DateTime? dueAt,
    required EventEnvelope envelope,
  }) => _emit(
    'task.due_changed',
    {
      'task_id': taskId,
      'family_id': familyId,
      'due_at': dueAt?.toUtc().toIso8601String(),
    },
    envelope,
  );

  Future<void> emitMyDayChanged({
    required String taskId,
    required String familyId,
    required DateTime? myDayDate,
    required EventEnvelope envelope,
  }) => _emit(
    'task.my_day_changed',
    {
      'task_id': taskId,
      'family_id': familyId,
      'my_day_date': myDayDate == null
          ? null
          : '${myDayDate.year}-'
              '${myDayDate.month.toString().padLeft(2, '0')}-'
              '${myDayDate.day.toString().padLeft(2, '0')}',
    },
    envelope,
  );

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

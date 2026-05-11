import '../common/result.dart';
import '../models/system_event.dart';
import 'event_producer.dart';
import 'offline_write_queue.dart';
import '../sync/drift_offline_write_queue.dart';

/// Publishes [SystemEvent] via [onlineProducer] when online, otherwise enqueues
/// a `system_event` insert for [offlineQueue] (phase 1.6 drain).
class OfflineAwareEventProducer implements EventProducer {
  OfflineAwareEventProducer({
    required EventProducer onlineProducer,
    required OfflineWriteQueue offlineQueue,
    required Future<bool> Function() probeOnline,
    required String defaultActorId,
  }) : _online = onlineProducer,
       _queue = offlineQueue,
       _probeOnline = probeOnline,
       _defaultActorId = defaultActorId;

  final EventProducer _online;
  final OfflineWriteQueue _queue;
  final Future<bool> Function() _probeOnline;
  final String _defaultActorId;

  Map<String, dynamic> _insertPayload(SystemEvent event) {
    final json = event.toJson()..remove('id');
    json.remove('updated_at');
    return Map<String, dynamic>.from(json);
  }

  @override
  Future<Result<SystemEvent>> publish(SystemEvent event) async {
    if (await _probeOnline()) {
      return _online.publish(event);
    }
    final actor = event.actorId.isNotEmpty ? event.actorId : _defaultActorId;
    final enqueued = await _queue.enqueue(
      OfflineWritePayloadBuilder.build(
        tenantId: event.tenantId,
        actorId: actor,
        targetTable: 'system_event',
        operation: 'insert',
        idempotencyKey: event.idempotencyKey,
        payload: _insertPayload(event),
      ),
    );
    return enqueued.when(
      success: (_) => Result<SystemEvent>.success(event),
      failure: Result<SystemEvent>.failure,
    );
  }
}

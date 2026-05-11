import '../common/result.dart';
import '../models/system_event.dart';

typedef SystemEventHandler = Future<void> Function(SystemEvent event);

/// Registry of named consumers (dashboard, tasks, mail, …). Dispatch and retry
/// semantics are implemented in phase 1.5 `process-event`.
abstract class EventConsumerRegistry {
  void register(String consumerId, SystemEventHandler handler);

  /// Invokes a single consumer; used by workers, not UI directly.
  Future<Result<void>> dispatchTo(String consumerId, SystemEvent event);
}

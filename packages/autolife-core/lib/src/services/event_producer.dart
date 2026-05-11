import '../common/result.dart';
import '../models/system_event.dart';

/// Emits [SystemEvent] rows into the bus. Implementation inserts into
/// `system_event` (phase 1.5 worker + Supabase client).
abstract class EventProducer {
  /// Persists [event]. The server may assign [SystemEvent.id].
  Future<Result<SystemEvent>> publish(SystemEvent event);
}

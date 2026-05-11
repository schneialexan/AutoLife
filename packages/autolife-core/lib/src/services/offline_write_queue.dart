import '../common/result.dart';

/// Outbox for offline mutations. Runtime flushing and Drift persistence are
/// phase 1.6; this interface is consumed by shell/modules only.
abstract class OfflineWriteQueue {
  Future<Result<void>> enqueue(Map<String, dynamic> payload);

  Future<Result<Map<String, dynamic>?>> dequeue();

  Future<Result<int>> depth();
}

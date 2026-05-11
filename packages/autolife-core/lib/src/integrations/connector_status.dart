import 'package:flutter/foundation.dart';

/// High-level UI/sync posture for a registered connector instance.
enum ConnectorConnectionPhase {
  disconnected,
  connecting,
  connected,
  refreshing,
  error,
}

@immutable
class ConnectorStatus {
  const ConnectorStatus({
    required this.phase,
    this.lastError,
  });

  final ConnectorConnectionPhase phase;
  final String? lastError;
}

/// Structured privacy telemetry surfaced to hosts (analytics wiring in Phase 3+).
sealed class PrivacyTelemetryEvent {
  const PrivacyTelemetryEvent();
}

/// Emitted when biometric (or device-credential) auth fails for a gated module.
final class PrivacyLockFailed extends PrivacyTelemetryEvent {
  const PrivacyLockFailed(this.moduleId);

  final String moduleId;

  static const String analyticsName = 'privacy.lock_failed';
}

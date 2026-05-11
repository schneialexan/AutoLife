/// Shared AutoLife domain contracts (events, tenancy stubs, service shapes).
///
/// ### Models
/// - [SystemEvent], [EventDelivery] — `system_event` / `event_delivery` rows.
/// - [Profile], [Family], [Membership], [Role] — tenancy stubs through phase 2.2.
///
/// ### Events
/// - [EventEnvelope] — producer metadata (idempotency, ordering, module).
///
/// ### Common
/// - [Result], [Failure] — lightweight result type for service boundaries.
/// - [Tenant] — resolved tenant context.
///
/// ### Service interfaces (implementations in later phases)
/// - [EventProducer] — phase 1.5 producer / Supabase insert.
/// - [EventConsumerRegistry] — phase 1.5 `process-event` dispatch.
/// - [Repository] — data access in apps / phase 1.6 Drift.
/// - [IntegrationConnector] — phase 1.7 gateway.
/// - [OfflineWriteQueue] — phase 1.6 offline queue.
library;

/// Structured error for [Result.failure] and service boundaries.
export 'src/common/failure.dart';

/// Discriminated union [Result] (`success` / `failure`).
export 'src/common/result.dart';

/// Active tenant context for requests and connectors.
export 'src/common/tenant.dart';

/// Idempotency, ordering, timing, and module metadata for emitted events.
export 'src/events/event_envelope.dart';

/// Delivery attempt row for a persisted [SystemEvent].
export 'src/models/event_delivery.dart';

/// Lifecycle of an [EventDelivery] row (`pending` … `dead_letter`).
export 'src/models/event_delivery_status.dart';

/// Household / tenant aggregate (stub through phase 2.2).
export 'src/models/family.dart';

/// Profile↔family link with [Role] (stub through phase 2.2).
export 'src/models/membership.dart';

/// Human-facing user record (stub through phase 2.2).
export 'src/models/profile.dart';

/// Coarse tenancy role enum (expanded in phase 2.3).
export 'src/models/role.dart';

/// Canonical persisted event for the AutoLife event bus (`system_event`).
export 'src/models/system_event.dart';

/// Fan-out dispatch registry consumed by phase 1.5 workers.
export 'src/services/event_consumer.dart';

/// Inserts canonical events into `system_event` (phase 1.5).
export 'src/services/event_producer.dart';

/// Minimal integration handshake shape (lifecycle in phase 1.7).
export 'src/services/integration_connector.dart';

/// Offline mutation outbox API (backing store in phase 1.6).
export 'src/services/offline_write_queue.dart';

/// Generic CRUD persistence contract for feature modules.
export 'src/services/repository.dart';

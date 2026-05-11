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
/// - [IntegrationConnector], [OfflineAwareIntegrationConnector], [ConnectorRegistry], [MockConnector] — phase 1.7 gateway.
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

/// Local calendar row model (feature schemas may extend in later phases).
export 'src/models/calendar_event.dart';

/// Fan-out dispatch registry consumed by phase 1.5 workers.
export 'src/services/event_consumer.dart';

/// Inserts canonical events into `system_event` (phase 1.5).
export 'src/services/event_producer.dart';

/// Concrete `EventProducer` that inserts canonical events through Supabase/PostgREST.
export 'src/services/supabase_event_producer.dart';

/// Offline-aware [EventProducer] (phase 1.8).
export 'src/services/offline_aware_event_producer.dart';

/// Minimal integration handshake export (canonical types live under `src/integrations/`).
export 'src/services/integration_connector.dart';

/// Connector gateway registry, coordinator, and Riverpod providers (phase 1.7).
export 'src/integrations/connector_audit_logger.dart';
export 'src/integrations/connector_lifecycle_coordinator.dart';
export 'src/integrations/connector_registry.dart';
export 'src/integrations/connector_status.dart';
export 'src/integrations/connector_status_tracker.dart';
export 'src/integrations/integration_providers.dart';
export 'src/integrations/mock_connector.dart';
export 'src/integrations/supabase_connector_audit_logger.dart';

/// Offline mutation outbox API (backing store in phase 1.6).
export 'src/services/offline_write_queue.dart';

/// Generic CRUD persistence contract for feature modules.
export 'src/services/repository.dart';

/// Drift cache, offline queue, sync engine, and Riverpod surfaces (phase 1.6).
export 'src/sync/autolife_database.dart';
export 'src/sync/conflict_resolver.dart';
export 'src/sync/connectivity_watcher.dart';
export 'src/sync/device_encryption_key_store.dart';
export 'src/sync/drift_offline_write_queue.dart';
export 'src/sync/payload_cipher.dart';
export 'src/sync/remote_sync_gateway.dart';
export 'src/sync/shell_placeholder_sync.dart';
export 'src/sync/sync_engine.dart';
export 'src/sync/sync_providers.dart';

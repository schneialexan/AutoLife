/// Shared AutoLife domain contracts (events, family tenancy, service shapes).
///
/// ### Models
/// - [SystemEvent], [EventDelivery] — `system_event` / `event_delivery` rows.
/// - [Profile], [Family], [Membership], [FamilyRole] — tenancy (`families` / `memberships`).
///
/// ### Events
/// - [EventEnvelope] — producer metadata (idempotency, ordering, module).
///
/// ### Common
/// - [Result], [Failure] — lightweight result type for service boundaries.
/// - [Tenant] — resolved tenant context.
///
/// ### Service interfaces (implementations in later phases)
/// - [AuthService], [SupabaseAuthService], [AutoLifeSupabaseBootstrap] — phase 2.1 auth flows.
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

/// Household / tenant (`public.families`).
export 'src/tenancy/models/family.dart';

/// User↔family membership (`public.memberships`).
export 'src/tenancy/models/membership.dart';

/// Invitation row (`public.family_invitations`).
export 'src/tenancy/models/family_invitation.dart';

/// Tenancy service interface + Supabase implementation.
export 'src/tenancy/tenancy_service.dart';
export 'src/tenancy/supabase_tenancy_service.dart';

/// Human-facing user record (stub through phase 2.2).
export 'src/models/profile.dart';

/// Canonical `family_role` enum (matches Postgres enum + policy matrices).
export 'src/models/role.dart';

export 'src/policy/approval_engine.dart';
export 'src/policy/capability.dart';
export 'src/policy/capability_grant_defaults.dart';
export 'src/policy/chore_task_completion_guard.dart';
export 'src/policy/matrix_model.dart';
export 'src/policy/role_policy_service.dart';

/// Canonical persisted event for the AutoLife event bus (`system_event`).
export 'src/models/system_event.dart';

/// Local calendar row model (feature schemas may extend in later phases).
export 'src/models/calendar_event.dart';

/// Supabase-backed auth façade (phase 2.1).
export 'src/auth/auth_service.dart';
export 'src/auth/models/auth_error.dart';
export 'src/auth/models/auth_session.dart';
export 'src/auth/models/auth_user.dart';
export 'src/auth/supabase_auth_service.dart';

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

/// Privacy: sensitivity tiers, babysitter links, biometric module locks (phase 2.5).
export 'src/privacy/babysitter_link_crypto.dart';
export 'src/privacy/babysitter_link_service.dart';
export 'src/privacy/biometric_lock_service.dart';
export 'src/privacy/local_auth_facade.dart';
export 'src/privacy/models/babysitter_link.dart';
export 'src/privacy/models/babysitter_scope_toggles.dart';
export 'src/privacy/privacy_events.dart';
export 'src/privacy/secure_prefs_store.dart';
export 'src/privacy/sensitivity_tier.dart';

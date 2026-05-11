---
name: phase1.2_autolife_core_contracts
overview: Define the canonical shared domain models, event schema, and service interfaces in packages/autolife-core that every app, edge function, and later phase must consume rather than redefining.
todos: []
isProject: false
---

# Phase 1.2 - autolife-core Contracts

## Objective
Establish `packages/autolife-core` as the single source of truth for cross-module domain primitives: the `system_event` and `event_delivery` schema, the `Profile`/`Family`/`Membership` tenancy stubs, and the service interfaces (event bus producer, repository, sync queue) that every app and Supabase function will import. This plan owns those contracts; later plans reference this file rather than redefining them.

## In scope
- `SystemEvent` and `EventDelivery` Dart models with stable JSON serialization matching the Supabase tables that will be created in phase 1.4.
- Shared tenancy stubs: `Profile`, `Family`, `Membership`, `Role` enum (stubbed; full role matrix is owned by phase 2.3).
- Common value types: `EventEnvelope` (idempotency key, ordering tag, occurred-at, source module), `Result` / `Failure`, `Tenant` context.
- Service interfaces (abstract classes) for: event producer, event consumer registry, repository, integration connector (shape only; lifecycle owned by 1.7), offline write queue (shape only; queue runtime owned by 1.6).
- Code-generation setup (`freezed` + `json_serializable`) wired into Melos so models compile across the workspace.
- Unit tests covering JSON round-trips, equality, and copy semantics for every model.
- Public API barrel file with documented exports.

## Out of scope
- Concrete implementations of repositories, producers, or queues (those live in phase 1.5 worker, 1.6 sync layer, 1.7 gateway, or the app code).
- SQL schema or RLS policies (owned by phase 1.4 baseline and phase 2.4).
- Full role matrix and approval engine (owned by phase 2.3).
- UI widgets or theming (owned by phase 1.3).

## Key deliverables
- [packages/autolife-core/lib/autolife_core.dart](packages/autolife-core/lib/autolife_core.dart) - public barrel.
- [packages/autolife-core/lib/src/models/system_event.dart](packages/autolife-core/lib/src/models/system_event.dart) - canonical event model.
- [packages/autolife-core/lib/src/models/event_delivery.dart](packages/autolife-core/lib/src/models/event_delivery.dart) - delivery/attempt record.
- [packages/autolife-core/lib/src/models/profile.dart](packages/autolife-core/lib/src/models/profile.dart).
- [packages/autolife-core/lib/src/models/family.dart](packages/autolife-core/lib/src/models/family.dart).
- [packages/autolife-core/lib/src/models/membership.dart](packages/autolife-core/lib/src/models/membership.dart).
- [packages/autolife-core/lib/src/models/role.dart](packages/autolife-core/lib/src/models/role.dart) - enum stub.
- [packages/autolife-core/lib/src/events/event_envelope.dart](packages/autolife-core/lib/src/events/event_envelope.dart).
- [packages/autolife-core/lib/src/services/event_producer.dart](packages/autolife-core/lib/src/services/event_producer.dart) - abstract producer.
- [packages/autolife-core/lib/src/services/event_consumer.dart](packages/autolife-core/lib/src/services/event_consumer.dart) - consumer registry interface.
- [packages/autolife-core/lib/src/services/repository.dart](packages/autolife-core/lib/src/services/repository.dart) - generic repository contract.
- [packages/autolife-core/lib/src/services/integration_connector.dart](packages/autolife-core/lib/src/services/integration_connector.dart) - connector shape (full lifecycle owned by 1.7).
- [packages/autolife-core/lib/src/services/offline_write_queue.dart](packages/autolife-core/lib/src/services/offline_write_queue.dart) - queue shape (runtime owned by 1.6).
- [packages/autolife-core/test/](packages/autolife-core/test/) - unit tests per model and interface.
- [packages/autolife-core/CHANGELOG.md](packages/autolife-core/CHANGELOG.md) starting at `0.1.0`.

## Dependencies
- [.cursor/plans/phase1.1_monorepo_workspace_setup.plan.md](.cursor/plans/phase1.1_monorepo_workspace_setup.plan.md) - Melos workspace, analysis options, and CI must be in place so this package can build and ship code-gen.

## Acceptance criteria (gate)
- [ ] `dart run build_runner build --delete-conflicting-outputs` from `packages/autolife-core` succeeds and produces generated files committed to the repo.
- [ ] `dart analyze` and `dart format --set-exit-if-changed .` pass on the package.
- [ ] Every model has a unit test asserting `fromJson(toJson(x)) == x` and `copyWith` correctness.
- [ ] `SystemEvent` exposes `id`, `tenantId`, `actorId`, `module`, `type`, `payload`, `idempotencyKey`, `occurredAt`, `orderingTag`, and `schemaVersion`, all of which line up 1:1 with column names planned for phase 1.4.
- [ ] `EventDelivery` exposes `id`, `eventId`, `consumer`, `attempt`, `status` (enum: pending, succeeded, failed, dead_letter), `lastError`, `nextAttemptAt`.
- [ ] All abstract service interfaces have at least one passing fake/mocked implementation in tests proving the contract is usable.
- [ ] Public barrel `autolife_core.dart` re-exports every model and interface intended to be public, with `dartdoc` comments on each export.
- [ ] No app or function in the repo defines its own `SystemEvent`, `Profile`, `Family`, or `Membership` model (grep verification documented in PR description).

## Risks + mitigations
- **Risk**: Event schema drift between Dart models (here) and Supabase tables (phase 1.4) once the worker is live. / **Mitigation**: Treat the column names listed in Acceptance Criteria as the contract; phase 1.4 must mirror them exactly, and `process-event` integration tests in 1.5 will assert round-trip parity.
- **Risk**: Over-modelling tenancy here forces phase 2.2 to refactor. / **Mitigation**: Keep `Profile`/`Family`/`Membership` as deliberately minimal stubs (id, displayName, role enum) and explicitly defer ACL/approval fields to phase 2.2/2.3 with TODO markers.
- **Risk**: Code-gen drift between contributors. / **Mitigation**: Commit generated files, add a CI check that fails if `build_runner build` produces a diff.

## Implementation outline
1. Add `freezed`, `freezed_annotation`, `json_serializable`, `json_annotation`, and `build_runner` to the package pubspec under the right dev/runtime sections.
2. Define value types (`EventEnvelope`, `Result`, `Tenant`) first because models depend on them.
3. Implement `SystemEvent` and `EventDelivery` with the exact field set listed in Acceptance Criteria.
4. Implement `Profile`, `Family`, `Membership`, and the `Role` enum stub.
5. Define abstract service interfaces (`EventProducer`, `EventConsumer`, `Repository`, `IntegrationConnector`, `OfflineWriteQueue`) with dartdoc explaining where the runtime implementation lives.
6. Write unit tests for JSON round-trips, equality, copy semantics, and one fake implementation per interface.
7. Run `build_runner` and commit generated output.
8. Author the public barrel `autolife_core.dart` and document each export.
9. Update `CHANGELOG.md` to `0.1.0` and tag the merge commit `core-0.1.0`.
10. Confirm `apps/autolife-shell` still builds against the package via `path:` reference.

## Artifacts/links
- PR: (tbd)
- Migration: (tbd)
- Test report: (tbd)

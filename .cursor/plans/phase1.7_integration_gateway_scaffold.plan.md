---
name: phase1.7_integration_gateway_scaffold
overview: Scaffold the canonical integration gateway including the connector interface, lifecycle, credential storage via Supabase Vault, and OAuth flow surface that every external integration in AutoLife must use.
phase: 1.7
gate_owner: Phase 1 Gate
isProject: false
---

# Phase 1.7 - Integration Gateway Scaffold

## Objective
Provide the canonical `IntegrationConnector` lifecycle, credential storage via Supabase Vault, and OAuth flow surface so every Phase 3 app that integrates with an external system (Google/Apple/Outlook calendars, Google Maps, OCR vendors, Coop/Migros, Splitwise, email IMAP, etc.) plugs into one well-defined seam. This plan is the canonical owner of the connector interface; later plans must reference this file rather than defining their own connector contract or credential storage path.

## In scope
- Concrete `IntegrationConnector` interface in `packages/autolife-core` extending the shape from phase 1.2, adding lifecycle methods: `connect`, `refresh`, `disconnect`, `healthcheck`, `pullChanges`, `pushChanges`.
- `ConnectorRegistry` allowing apps to register implementations by stable connector-id.
- Credential storage: a Supabase Vault-backed `connector_credential` table with one row per `(tenant_id, connector_id)`; secrets stored via `pgsodium`/Vault, not plain JSON.
- OAuth flow surface: an Edge Function at `supabase/functions/oauth-callback/` that completes any connector's OAuth handshake and writes credentials into Vault.
- Universal direction flags (`one_way_out`, `one_way_in`, `two_way`) recorded per connector instance per Idea-Refined Part 5.6.
- One reference connector implementation: `MockConnector` (returns canned data) used by the smoke test in phase 1.8 and by integration tests here.
- Audit log table `connector_event` tracking every connect/refresh/disconnect/healthcheck/error.
- Riverpod providers exposing `connectorStatus` and `connectorList` to the shell.

## Out of scope
- Real external integrations (Google Calendar, Maps, OCR, Coop/Migros) -- each Phase 3 app introduces them on top of this scaffold.
- UI for managing connectors in the Control Center (owned by phase 3.13).
- Secret rotation policies (owned by phase 2.6).
- Email ingestion specifics (owned by phase 3.9).

## Key deliverables
- [packages/autolife-core/lib/src/integrations/integration_connector.dart](packages/autolife-core/lib/src/integrations/integration_connector.dart) - canonical interface (extends the stub from 1.2).
- [packages/autolife-core/lib/src/integrations/connector_registry.dart](packages/autolife-core/lib/src/integrations/connector_registry.dart).
- [packages/autolife-core/lib/src/integrations/connector_status.dart](packages/autolife-core/lib/src/integrations/connector_status.dart).
- [packages/autolife-core/lib/src/integrations/mock_connector.dart](packages/autolife-core/lib/src/integrations/mock_connector.dart) - reference impl for tests and the smoke flow.
- [packages/autolife-core/test/integrations/](packages/autolife-core/test/integrations/) - unit + integration tests.
- [supabase/migrations/0020_connector_credentials.sql](supabase/migrations/0020_connector_credentials.sql) - `connector_credential` (Vault-backed) and `connector_event` tables.
- [supabase/functions/oauth-callback/index.ts](supabase/functions/oauth-callback/index.ts) - generic OAuth-completion endpoint.
- [supabase/functions/oauth-callback/deno.json](supabase/functions/oauth-callback/deno.json).
- [supabase/functions/oauth-callback/__tests__/](supabase/functions/oauth-callback/__tests__/) - Deno tests.
- [docs/integration-connector-contract.md](docs/integration-connector-contract.md) - written spec of the lifecycle, credential storage, OAuth surface, and direction flags.

## Dependencies
- [.cursor/plans/phase1.2_autolife_core_contracts.plan.md](.cursor/plans/phase1.2_autolife_core_contracts.plan.md) - `IntegrationConnector` shape stub.
- [.cursor/plans/phase1.4_supabase_baseline.plan.md](.cursor/plans/phase1.4_supabase_baseline.plan.md) - Vault/pgsodium availability and Edge Function scaffold.
- [.cursor/plans/phase1.5_event_bus_process_event_worker.plan.md](.cursor/plans/phase1.5_event_bus_process_event_worker.plan.md) - emits `connector_*` events through the bus.
- [.cursor/plans/phase1.6_offline_sync_foundation.plan.md](.cursor/plans/phase1.6_offline_sync_foundation.plan.md) - `pushChanges` may route through the offline queue when offline.

## Acceptance criteria (gate)
- [ ] `IntegrationConnector` exposes `connect`, `refresh`, `disconnect`, `healthcheck`, `pullChanges`, `pushChanges`, and a `directions` field accepting `one_way_in`, `one_way_out`, or `two_way`.
- [ ] `connector_credential` rows store secrets via Supabase Vault; no plaintext secrets exist anywhere in the schema (audited via SQL check).
- [ ] OAuth callback function completes a mocked OAuth handshake end-to-end against `MockConnector` and persists encrypted credentials.
- [ ] Every lifecycle call writes one row to `connector_event` (success or failure), verified by integration test.
- [ ] `ConnectorRegistry` rejects duplicate connector-ids with a clear error.
- [ ] Calling `pushChanges` while offline routes the payload into the queue from phase 1.6 instead of failing.
- [ ] `docs/integration-connector-contract.md` documents lifecycle, credential storage path, OAuth flow, direction flags, and the "do not redefine" rule for later plans.
- [ ] The smoke flow in phase 1.8 imports `MockConnector` and proves the full registry/credential/audit path works.

## Risks + mitigations
- **Risk**: Vault misconfiguration leaking secrets in DB backups. / **Mitigation**: Add a SQL test that scans `connector_credential` columns for plaintext-looking values, run it in CI, and document the Vault setup in the contract doc.
- **Risk**: OAuth callback endpoint becoming a phishing target. / **Mitigation**: Require a state token signed with a per-tenant key, validate redirect URLs against an allowlist, and log all attempts to `connector_event` with IP/user-agent.
- **Risk**: Lifecycle drift between connectors. / **Mitigation**: Lock the interface here and require all connector PRs to include a contract-test from `packages/autolife-core` that asserts every method behaves correctly under the `MockConnector` harness.

## Implementation outline
1. Author `docs/integration-connector-contract.md` covering lifecycle, Vault storage, OAuth, direction flags, and audit-log semantics before code lands.
2. Land migration `0020_connector_credentials.sql` with the Vault-backed `connector_credential` table and the `connector_event` audit table.
3. Extend the `IntegrationConnector` interface from phase 1.2 with lifecycle methods and direction flags.
4. Implement `ConnectorRegistry` with duplicate-id rejection and dartdoc.
5. Build the generic OAuth-callback Edge Function with state-token validation and Vault writes.
6. Implement `MockConnector` and use it as the reference for the contract test harness.
7. Hook offline-aware `pushChanges` so writes route through phase 1.6's queue when connectivity is `offline`.
8. Emit `connector_connected`, `connector_disconnected`, and `connector_error` events through the bus from phase 1.5.
9. Add Deno tests for the OAuth function and Dart tests for the registry, lifecycle, and offline-routing behaviour.
10. Publish a Riverpod provider in `packages/autolife-core` exposing connector status for the shell.

## Artifacts/links
- PR: (tbd)
- Migration: (tbd)
- Test report: (tbd)

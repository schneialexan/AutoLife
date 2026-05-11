# Integration connector contract (phase 1.7)

This document is the canonical specification for external integrations in AutoLife. Later phases **must not** redefine the connector interface, credential storage model, or OAuth completion path; they extend this contract by adding new `connector_id` values and connector implementations registered in [`ConnectorRegistry`](../packages/autolife-core/lib/src/integrations/connector_registry.dart).

## Lifecycle

Every integration implements [`IntegrationConnector`](../packages/autolife-core/lib/src/integrations/integration_connector.dart):

| Method | Purpose |
|--------|---------|
| `connect` | Establish credentials/session (includes first-time OAuth completion on the client where applicable). |
| `refresh` | Rotate or reload tokens/session without full teardown. |
| `disconnect` | Tear down session and revoke local handles. |
| `healthcheck` | Cheap remote or local sanity check. |
| `pullChanges` | Inbound sync snapshot or delta (connector-defined payload shape). |
| `pushChanges` | Outbound mutations; when `probeOnline` reports offline, [`OfflineAwareIntegrationConnector`](../packages/autolife-core/lib/src/integrations/integration_connector.dart) enqueues via [`OfflineWriteQueue`](../packages/autolife-core/lib/src/services/offline_write_queue.dart) instead of failing (shells usually bind `probeOnline` to [`ConnectivityWatcher.isOnline()`](../packages/autolife-core/lib/src/sync/connectivity_watcher.dart)). |

Each lifecycle invocation **must** emit exactly one row to `connector_event` (success or failure), typically via [`ConnectorLifecycleCoordinator`](../packages/autolife-core/lib/src/integrations/connector_lifecycle_coordinator.dart). The OAuth Edge Function records `oauth_callback` rows the same way.

## Direction flags

[`IntegrationConnectorDirection`](../packages/autolife-core/lib/src/integrations/integration_connector.dart) (`one_way_in`, `one_way_out`, `two_way`) is exposed on the connector instance and stored per credential row as `connector_credential.direction` (Idea-Refined Part 5.6). Feature modules use it to decide whether pull, push, or both are meaningful for that integration.

## Credential storage (Supabase Vault)

- Table `connector_credential`: at most one row per `(tenant_id, connector_id)`.
- OAuth secrets and token bundles **never** appear as plaintext columns. The table stores `vault_secret_id` referencing encrypted rows managed through `vault.create_secret` / `vault.update_secret`.
- Application code calls SQL RPC `integration_store_connector_secret` (service role from trusted Edge Functions); clients must not hold DB Vault decryption privileges.
- `metadata` on `connector_credential` is JSON for non-sensitive labels only (provider ids, scopes granted, etc.).

## OAuth completion surface

- Edge Function [`supabase/functions/oauth-callback/`](../supabase/functions/oauth-callback/) completes OAuth redirects.
- **State token**: HMAC-signed payload (tenant id, connector id, optional success redirect URL, expiry). Secret: deployment env `OAUTH_STATE_SECRET`.
- **Redirect allowlist**: success redirect URL must match prefix from `OAUTH_SUCCESS_REDIRECT_ALLOWLIST` (comma-separated origins).
- **Mock connector** (`connector_id === 'mock'`): synthetic tokens without calling an external IdP; used for automated tests and smoke flows.
- Failed validations and suspicious redirects **must** still append an audit row to `connector_event` where feasible (Edge Function logs).

## Event bus (phase 1.5)

The coordinator publishes canonical `system_event` rows via [`EventProducer`](../packages/autolife-core/lib/src/services/event_producer.dart):

- `connector_connected`
- `connector_disconnected`
- `connector_error`

`module` is `integrations`. Payloads include `connector_id` and optional error codes/messages.

## Auditing

Table `connector_event` retains **every** lifecycle attempt (`connect`, `refresh`, `disconnect`, `healthcheck`, `pull_changes`, `push_changes`, `oauth_callback`, …) with `outcome` `success` or `failure`, optional `error_detail`, structured `detail` JSON, and HTTP metadata when known (`client_ip`, `user_agent`).

## CI / schema hygiene

Migrations and Dart parity tests assert `connector_credential` does not define plaintext token columns; automated checks scan migration SQL for forbidden column names tied to secrets.

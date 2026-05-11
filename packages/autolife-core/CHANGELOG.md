# Changelog

## 0.1.0

- Introduce canonical `SystemEvent` and `EventDelivery` models (JSON aligned with planned `system_event` / `event_delivery` tables).
- Add tenancy stubs: `Profile`, `Family`, `Membership`, and `Role`.
- Add shared types: `EventEnvelope`, `Tenant`, `Result`, `Failure`.
- Add service contracts: `EventProducer`, `EventConsumerRegistry`, `Repository`, `IntegrationConnector`, `OfflineWriteQueue`.
- Adopt `freezed` + `json_serializable` with committed generated files.

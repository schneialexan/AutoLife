# AutoMail

**Status:** planned · **Build order:** Expansion #9

Email ingestion + AI parsing. Built standalone first (inbox + rules + parsing preview),
then emits intents that other modules turn into events/tasks/renewals.

## Scope (standalone)
- Shared family inbox concept (e.g. `smith@auto.life`).
- AI parsing: emails → extracted action badges (Event created, Task created, Renewal detected).
- Filter chips (All / Events / Tasks / Renewals); inline preview of what was created.
- Rule builder ("if subject contains X → create Y").
- AI "leash" respected: Manual (ask) vs. Autonomous (act + notify).

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** ingested messages, parse results, rules.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard "parsed items" card; omnibar message results.

# Event Vocabulary

Cross-module intelligence is, mechanically, just **events**. One module announces that
something happened; other modules choose to react. This file is the shared dictionary of
those events.

It is the single most important seam for "build apps standalone, combine cleanly later."
As long as apps emit and consume events from this list, integration is wiring.

> **The registry below is intentionally empty.** Events are added **step by step**, only
> when a real app actually needs to emit or consume one. We do not pre-define events up
> front — that's the whole point of building each app standalone first.

## Naming

`<module>.<noun>.<verb>` — lowercase, dot-separated, past-tense or state-based verb.

> e.g. `assets.receipt.scanned`, `health.flow.logged`, `tasks.chore.completed`

## Rules

1. **Additive only.** Add new events; never silently change the meaning of an existing one.
2. **Producer owns the name.** The module that emits an event defines and documents it here.
3. **Standalone-safe.** Emitting must not require a consumer; consuming must tolerate the
   event never arriving.
4. **Automation events are gated.** If an event is emitted by an automation, the producing
   module must expose a setting to turn that automation off.
5. **Version on breaking payload change.** If a payload must change incompatibly, introduce
   `name@v2` rather than mutating `name`.

## Payload

Payload shapes are pinned the first time two real modules share an event. Until then,
assume a minimal payload: a stable id, the owning family/household scope, a timestamp, and
the few fields the event needs.

## Registry

_(empty — populated as apps are built)_

| Event | Emitted by | Consumed by | Carries | Resulting behavior |
|-------|-----------|-------------|---------|--------------------|
| | | | | |

## How to add an event

1. Pick a name following the convention.
2. Add a row to the registry (producer, expected consumers, what it carries, the effect).
3. If it's an automation, add the corresponding off-switch in the producing app's settings.
4. Update the emitting/consuming apps' `apps/<app>/README.md` contract sections.

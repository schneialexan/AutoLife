# Open Decisions

The design is deliberately open. This file is the register of decisions we have **not** made
yet. Each entry lists the **constraints** the eventual choice must satisfy, plus the leading
candidate (so the choice is principled, not arbitrary). Nothing here is binding until moved
to "Decided".

Update an entry's status as decisions get made: `Open` → `Leaning` → `Decided`.

---

## D1 — Frontend framework
**Status:** Decided → **Flutter** (3.41.x, stable)

Decided so the build/publish pipeline can produce installable Android APKs. Satisfies the
constraints: cross-platform from one codebase (Android/iOS/Web/Desktop), strong for rich
interactive calendars/lists, good offline UX, can consume a shared design-token system.

Currently scaffolded for **Android only** (target device: Poco F5); other platforms can be
re-enabled per app with `flutter create --platforms ...` later. See
[`distribution.md`](distribution.md).

---

## D2 — Backend & data platform
**Status:** Decided → **Supabase**

Decided so AutoAssets (and future modules) can opt into cross-device sync while
staying local-first. Supabase covers the constraints in one product: realtime +
auth + Storage + Postgres RLS.

Constraints (all satisfied by the v1 design):
- Realtime sync — Postgres + Realtime channels (polling on resume for MVP).
- Auth — email/password is the primary multi-device path; optional device
  pairing via a service-role Edge Function.
- File/blob storage — private Storage bucket, signed URLs only.
- Offline-first caching with conflict resolution — Hive stays the source of
  truth; an encrypted outbox + server-time pull cursor + last-write-wins.
- Row-level security — RLS on every table, `user_id = auth.uid()`.

**Tenancy (v1):** personal account — `user_id` on every row. Households/roles
(D6) are deferred.

**Topology — shared project:** standalone AutoAssets and the AutoLife shell are
both clients of **one Supabase project**, one identity namespace, and the same
`assets.*` tables. "Migrating" between apps is therefore just signing in — there
is no bespoke transfer step for synced users.

The platform lives in [`packages/autolife_platform`](../packages/autolife_platform);
each module ships a `ModuleSyncGateway`. SQL migrations + the `pair-device` Edge
Function live in [`platform/supabase`](../platform/supabase). Full design:
[`sync-architecture.md`](sync-architecture.md).

---

## D3 — AI / OCR provider
**Status:** Open · **Leading candidate:** Google Cloud Vision (or similar)

Constraints:
- OCR receipts (store, price, date, serial/IMEI).
- OCR nutrition labels (macros).
- Parse unstructured text (e.g. a forwarded school email → calendar events).
- Must sit behind a swappable interface (no app depends on a specific vendor directly).

---

## D4 — How modules combine (integration mechanism)
**Status:** Open

Options for delivering the [event vocabulary](event-vocabulary.md):
- A real message/event bus (e.g. backend-driven).
- In-process event dispatch (when apps share a runtime).
- Direct capability calls behind interfaces.

Decide **after** at least two apps need a real cross-module event — the right shape will be
obvious from the real seam. Until then, apps emit/consume events through a thin local
abstraction.

---

## D5 — Repo topology (monorepo vs. multi-repo)
**Status:** Open

Constraints:
- Each app must be independently buildable/runnable.
- Shared code is **extracted** from real overlap, not designed up front (`packages/`).
- Whatever is chosen must not force apps into lockstep releases prematurely.

Current working assumption: a single repo with `apps/*` kept independent; revisit once
tooling needs (D1) are known.

---

## D6 — Tenancy, roles & privacy model
**Status:** Open (requirements known)

Known requirements (the *what*, not the *how*):
- Households with multiple members; role templates (co-parent, teen, young child,
  grandparent, guest/babysitter) that change with age.
- Approval engine (e.g. child events need parent approval) — fully toggleable.
- Granular privacy tiers (hide health/finance details; share only a cycle phase).
- Scoped guest links (babysitter mode) with per-field toggles and expiry.
- Biometric locks per sensitive module.

The implementation depends on D2 and is decided alongside it.

---

## D7 — Distribution & CI
**Status:** Decided

- **Distribution:** sideload release APKs from **GitHub Releases** (free, no Play Console).
- **CI/CD:** **GitHub Actions** — `ci.yml` (analyze/test) + `release.yml` (build + publish
  APKs on `v*` tags). Both auto-discover apps under `apps/*`.
- Full details and phone-install steps in [`distribution.md`](distribution.md).

Revisit if/when Play Store distribution is wanted (needs a Play Console account + keystore).

---

## Decided

- **D1 — Frontend framework:** Flutter (3.41.x, stable), Android-first.
- **D2 — Backend & data platform:** Supabase (personal tenancy v1, shared-project
  topology). See [`sync-architecture.md`](sync-architecture.md).
- **D7 — Distribution & CI:** GitHub Releases sideload + GitHub Actions.

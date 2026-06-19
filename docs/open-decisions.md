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
**Status:** Open · **Leading candidate:** Supabase

Constraints:
- Realtime sync (shared family lists update live).
- Auth (multi-user households, roles).
- File/blob storage (receipts, PDFs, photos).
- Offline-first caching with conflict resolution.
- Row-level, multi-tenant security (per-family isolation).

Why Supabase is the front-runner: covers realtime + auth + storage + Postgres RLS in one.
Open alternatives remain on the table.

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
- **D7 — Distribution & CI:** GitHub Releases sideload + GitHub Actions.

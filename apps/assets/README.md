# AutoAssets

**Status:** v1 standalone (manual entry) · **Build order:** MVP #4

Purchase tracker / warranty vault. Built standalone first (manual entry now, scan
later), then drives calendar reminders and feeds finance/dine.

## v1 (this build)

A fully standalone Android app (`auto_assets`, `com.autolife.assets`) that persists
real user-entered assets locally on device — no demo data, no receipt scan, no
cross-app wiring.

- **Home** titled **AutoAssets** — vault list with search, filter chips, asset
  cards (name + price lead, ≤2 property pairs + "+N more"), FAB, empty &
  zero-result states. Settings icon top-right.
- **Settings** — links to the Categories manager; app-prefs placeholder.
- **Categories manager** — user-defined field types (e.g. `Brand`, `Model`,
  `Category`), each with a value kind, accent color, and icon/emoji. Starter
  types (`Category`, `Brand`, `Model`) are seeded once.
- **Value kinds** — Text, Number, Date, Money, Photo, and **Select** (dropdown
  with user-defined options).
- **Asset form** — fixed **Purchase** fields (name, date, price, **product
  photo**, **receipt**, all optional) plus **opt-in category fields** added via
  the **`+` on the Categories header** → scrollable bottom-sheet picker (with a
  "Create new type" footer), and a **Warranty** section. Nothing is required: an
  empty asset saves as "Untitled asset".
- **Product photo** — upload from camera/gallery or **paste an image URL**
  (downloaded and stored locally, so it works offline after save). *Search
  online* is a deferred placeholder.
- **Receipt** — a single slot holding **one image OR one PDF** (take photo,
  choose from gallery, or pick a PDF/file). *From QR / link* is deferred.
- **Warranty documents** — attach **multiple PDFs and/or images**; each is
  stored locally and opens in the system viewer. *Search online* is deferred.
- **Asset detail** — read-only; product photo is the hero, receipt and warranty
  docs are openable; only filled fields show; delete cleans up local files.

### Architecture

- **State:** `flutter_riverpod` · **Persistence:** Hive (JSON-encoded, no
  TypeAdapters) · **Images/files:** `image_picker`, `file_picker`,
  `path_provider`, `http` (URL download), `open_filex` (open docs).
- Source layout under `lib/src/`: `models/`, `constants/`, `data/`, `services/`,
  `providers/`, `widgets/`, `screens/`.

### Run / test

```bash
cd apps/assets
flutter pub get
flutter test
flutter run            # Android device/emulator
flutter build apk --release
```

UI wireframes: `autoassets-ui-design.canvas.tsx`.

## Scope (standalone roadmap)
- Vault of assets with product image, store, date, price, serial/IMEI, warranty status.
- Scan a receipt → AI extracts item, price, store, serial.
- Auto-protection: warranty-expiry + return-window reminders; optional PDF manual download
  — *download behavior is setting-gated*.
- Claim / breakage / maintenance timeline linked per asset (e.g. yearly motor checkup).

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** assets, category types (field definitions), per-asset property values,
  local images.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard "warranty/return alerts" card; omnibar asset results
  _(planned — out of scope for v1)_.

## Note
AutoMaintain (#11) may be absorbed here as a "Maintenance" tab — decide during its planning.

## Follow-up milestones
1. **Search online** for product photos and warranty docs (currently a "Soon"
   placeholder)
2. **Receipt from QR / link** — webview-render-and-screenshot capture (currently
   a "Soon" placeholder)
3. Receipt scan → pre-fill property values
4. Timeline / claims
5. Cross-module warranty reminders
6. Extract shared models to `packages/` when a second app needs them

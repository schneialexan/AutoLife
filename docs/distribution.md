# Distribution & Build Pipeline

How AutoLife apps get built and onto a phone (target device: **Poco F5**, Android).

**Decisions in play** (see [`open-decisions.md`](open-decisions.md)):
- **Stack:** Flutter (D1 — decided).
- **Distribution:** sideload APKs from **GitHub Releases** (free, no Play Console).
- **CI:** GitHub Actions.

## How the pipeline works

Two workflows live in [`.github/workflows`](../.github/workflows):

| Workflow | File | Trigger | What it does |
|----------|------|---------|--------------|
| **CI** | `ci.yml` | every push / PR | format-check + `flutter analyze` + `flutter test` for each app |
| **Release APKs** | `release.yml` | push a `v*` tag (or manual) | builds a release APK per app and attaches them to a GitHub Release |

Both **auto-discover** apps: any folder `apps/<app>/` that contains a `pubspec.yaml` is
picked up automatically. So as you add new Flutter apps, the pipeline includes them with no
config changes.

## Publish a build (cloud, recommended)

From the repo root:

```sh
git tag v0.1.0
git push origin v0.1.0
```

GitHub Actions then:
1. finds every Flutter app under `apps/*`,
2. builds `flutter build apk --release` for each,
3. publishes a **Release** at the tag with files named `autolife-<app>-v0.1.0.apk`.

You can also trigger it manually: GitHub → **Actions** → **Release APKs** → **Run workflow**
(this builds APK artifacts; a GitHub Release is only created for tag pushes).

## Install on the Poco F5 (sideload)

1. On the phone, open the **Releases** page of the repo (or the artifact link) in a browser.
2. Download `autolife-shell-v0.1.0.apk` (or whichever app).
3. Tap the downloaded file. Android will prompt to **allow installs from this source** —
   enable it (Settings → Apps → Special access → Install unknown apps → your browser).
4. Confirm the install. The app appears as e.g. **AutoLife Shell**.

## Release signing (so upgrades install in place)

Android only lets a new APK **upgrade** an installed app when both are signed with the
**same key**. The debug key is per-machine and CI generates a fresh one each run, so
debug-signed releases can't upgrade each other — you get
**"App not installed as package conflicts with an existing package."**

To fix this, releases are signed with a single **shared keystore** stored as encrypted
GitHub Actions secrets:

| Secret | What it is |
|--------|------------|
| `ANDROID_KEYSTORE_BASE64` | the keystore file, base64-encoded |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEY_ALIAS` | key alias (`autolife`) |
| `ANDROID_KEY_PASSWORD` | key password |

**One-time setup** (from the repo root):

```sh
./scripts/setup-release-keystore.sh      # macOS/Linux
# or
.\scripts\setup-release-keystore.ps1     # Windows
```

This generates `autolife-release.jks`, base64-encodes it, and (if the `gh` CLI is
installed) uploads all four secrets for you. The keystore file itself is gitignored —
**back it up somewhere safe and off GitHub**; if you lose it you can never push an
in-place upgrade to already-installed apps again.

How it wires up at build time:
- `release.yml` decodes the keystore and writes `apps/<app>/android/key.properties`
  before building.
- Each app's `android/app/build.gradle.kts` loads `key.properties` and signs `release`
  with it. If the file is absent (e.g. plain `flutter run`), it falls back to the debug
  key, so local dev needs no keystore.
- CI also sets `versionCode` from the workflow run number (`--build-number`), so each
  release is strictly newer than the last and avoids Android's downgrade ("App not
  installed") error.

Until the secrets are configured, releases still build but fall back to the debug key
(CI logs a warning), and cross-release upgrades will keep failing.

> The first signed release establishes the key. If apps were previously installed with a
> debug-signed APK, that **one** transition still requires an uninstall/reinstall (back up
> via Settings → Backup & restore first). Every release after that upgrades in place.
>
> For Google Play later, this same keystore can back a Play upload key — tracked as a
> future decision.

## Build & install locally (over USB, no CI)

Useful for fast iteration. With the Poco F5 connected via USB and USB debugging on:

```sh
cd apps/shell
flutter devices          # confirm the Poco F5 shows up
flutter run              # build, install, and hot-reload on the device
# or just install a release build:
flutter build apk --release
flutter install          # installs the built APK to the connected device
```

## Adding a new app to the pipeline

Nothing to configure — just scaffold the app so it has a `pubspec.yaml`:

```sh
flutter create --org com.autolife --project-name <app> --platforms android apps/<app>
```

The next CI run and the next tagged release will include it automatically. Each app gets a
unique application id (`com.autolife.<app>`), so multiple AutoLife apps can be installed
side by side on the same phone.

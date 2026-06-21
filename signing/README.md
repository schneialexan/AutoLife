# Release signing keystore

`autolife-release.jks` is committed here **on purpose** so CI can sign every
release with the same key without pasting a multi-kilobyte base64 string into
GitHub secrets (which is error-prone).

This repo is **private** and distribution is **sideload-only**. Do not make the
repo public while this file is present.

Passwords stay in GitHub Actions secrets:

- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS` (usually `autolife`)
- `ANDROID_KEY_PASSWORD`

To add the keystore: run `scripts/setup-release-keystore.ps1`, then commit
`signing/autolife-release.jks`.

To rotate the key: generate a new keystore, replace this file, and
uninstall/reinstall on devices (Android cannot upgrade across different signing keys).

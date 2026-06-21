#!/usr/bin/env bash
# One-time setup: generate a shared release keystore and register it as GitHub
# Actions secrets so every release APK is signed with the same key. This is what
# lets a freshly downloaded GitHub release APK upgrade an already-installed app
# in place (instead of failing with "package conflicts with an existing package").
#
# Requirements: keytool (ships with the JDK) and the GitHub CLI `gh` (logged in).
# Run once from the repo root:  ./scripts/setup-release-keystore.sh
#
# Re-running regenerates the keystore with a NEW key — only do that if you are
# willing to uninstall/reinstall every app on every device, because the new key
# will no longer match previously installed builds.

set -euo pipefail

KEYSTORE_FILE="autolife-release.jks"
KEY_ALIAS="autolife"
VALIDITY_DAYS=10000

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if ! command -v keytool >/dev/null 2>&1; then
  echo "error: keytool not found. Install a JDK (e.g. Temurin 17) first." >&2
  exit 1
fi

echo "This generates a release keystore and uploads it to GitHub as encrypted secrets."
read -r -s -p "Choose a keystore password: " store_pw; echo
read -r -s -p "Confirm keystore password: " store_pw2; echo
if [ "$store_pw" != "$store_pw2" ]; then
  echo "error: passwords do not match." >&2
  exit 1
fi

if [ -f "$KEYSTORE_FILE" ]; then
  echo "error: $KEYSTORE_FILE already exists. Refusing to overwrite." >&2
  echo "Delete it manually only if you intend to rotate the signing key." >&2
  exit 1
fi

keytool -genkeypair \
  -keystore "$KEYSTORE_FILE" \
  -alias "$KEY_ALIAS" \
  -keyalg RSA -keysize 2048 -validity "$VALIDITY_DAYS" \
  -storepass "$store_pw" -keypass "$store_pw" \
  -dname "CN=AutoLife, OU=AutoLife, O=AutoLife, L=, ST=, C="

echo "Created $KEYSTORE_FILE (alias: $KEY_ALIAS)."

keystore_b64="$(base64 -w0 "$KEYSTORE_FILE" 2>/dev/null || base64 "$KEYSTORE_FILE" | tr -d '\n')"

if command -v gh >/dev/null 2>&1; then
  echo "Uploading secrets to GitHub via gh..."
  printf '%s' "$keystore_b64" | gh secret set ANDROID_KEYSTORE_BASE64
  printf '%s' "$store_pw"     | gh secret set ANDROID_KEYSTORE_PASSWORD
  printf '%s' "$KEY_ALIAS"    | gh secret set ANDROID_KEY_ALIAS
  printf '%s' "$store_pw"     | gh secret set ANDROID_KEY_PASSWORD
  echo "Secrets uploaded: ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD"
else
  echo
  echo "gh CLI not found. Add these repository secrets manually"
  echo "(GitHub → Settings → Secrets and variables → Actions):"
  echo "  ANDROID_KEYSTORE_PASSWORD = <the password you just entered>"
  echo "  ANDROID_KEY_ALIAS         = $KEY_ALIAS"
  echo "  ANDROID_KEY_PASSWORD      = <the password you just entered>"
  echo "  ANDROID_KEYSTORE_BASE64   = (contents below)"
  echo "-------- ANDROID_KEYSTORE_BASE64 --------"
  echo "$keystore_b64"
  echo "-----------------------------------------"
fi

echo
echo "IMPORTANT: keep $KEYSTORE_FILE somewhere safe and OFF GitHub."
echo "It is gitignored, but if you lose it you can never ship an in-place"
echo "upgrade to already-installed apps again."

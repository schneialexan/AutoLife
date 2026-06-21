#!/usr/bin/env bash
# Re-upload ANDROID_KEYSTORE_BASE64 (and related secrets) from an existing
# autolife-release.jks without generating a new key. Use this when CI fails with
# "base64: invalid input" after manually pasting secrets into GitHub.
#
# Run from the repo root:  ./scripts/upload-release-keystore-secret.sh

set -euo pipefail

KEYSTORE_FILE="autolife-release.jks"
KEY_ALIAS="${ANDROID_KEY_ALIAS:-autolife}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [ ! -f "$KEYSTORE_FILE" ]; then
  echo "error: $KEYSTORE_FILE not found in repo root." >&2
  echo "Use the same keystore file created by setup-release-keystore.sh." >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh CLI not found. Install and log in, or paste secrets manually." >&2
  exit 1
fi

read -r -s -p "Keystore password: " store_pw; echo
read -r -s -p "Confirm keystore password: " store_pw2; echo
if [ "$store_pw" != "$store_pw2" ]; then
  echo "error: passwords do not match." >&2
  exit 1
fi

# Verify the password matches the file before uploading.
if ! keytool -list -keystore "$KEYSTORE_FILE" -storepass "$store_pw" -alias "$KEY_ALIAS" >/dev/null 2>&1; then
  echo "error: could not read $KEYSTORE_FILE with that password/alias." >&2
  exit 1
fi

keystore_b64="$(base64 -w0 "$KEYSTORE_FILE" 2>/dev/null || base64 "$KEYSTORE_FILE" | tr -d '\n')"

echo "Uploading secrets to GitHub..."
gh secret set ANDROID_KEYSTORE_BASE64 --body "$keystore_b64"
printf '%s' "$store_pw"  | gh secret set ANDROID_KEYSTORE_PASSWORD
printf '%s' "$KEY_ALIAS" | gh secret set ANDROID_KEY_ALIAS
printf '%s' "$store_pw"  | gh secret set ANDROID_KEY_PASSWORD
echo "Done. Re-run the Release APKs workflow (or push a new v* tag)."

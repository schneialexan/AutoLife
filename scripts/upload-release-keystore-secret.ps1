# Re-upload ANDROID_KEYSTORE_BASE64 (and related secrets) from an existing
# autolife-release.jks without generating a new key. Use this when CI fails with
# "base64: invalid input" after manually pasting secrets into GitHub.
#
# Run from the repo root:  .\scripts\upload-release-keystore-secret.ps1

$ErrorActionPreference = "Stop"

$KeystoreFile = "autolife-release.jks"
$KeyAlias = if ($env:ANDROID_KEY_ALIAS) { $env:ANDROID_KEY_ALIAS } else { "autolife" }

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $repoRoot

if (-not (Test-Path $KeystoreFile)) {
  Write-Error "$KeystoreFile not found in repo root. Use the keystore from setup-release-keystore.ps1."
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  Write-Error "gh CLI not found. Install and log in, or paste secrets manually."
}

$storePwSecure = Read-Host -AsSecureString "Keystore password"
$storePw2Secure = Read-Host -AsSecureString "Confirm keystore password"
$storePw = [System.Net.NetworkCredential]::new("", $storePwSecure).Password
$storePw2 = [System.Net.NetworkCredential]::new("", $storePw2Secure).Password
if ($storePw -ne $storePw2) {
  Write-Error "passwords do not match."
}

keytool -list -keystore $KeystoreFile -storepass $storePw -alias $KeyAlias | Out-Null
if ($LASTEXITCODE -ne 0) {
  Write-Error "Could not read $KeystoreFile with that password/alias."
}

$keystoreB64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path $KeystoreFile)))

Write-Host "Uploading secrets to GitHub..."
gh secret set ANDROID_KEYSTORE_BASE64 --body $keystoreB64
$storePw  | gh secret set ANDROID_KEYSTORE_PASSWORD
$KeyAlias | gh secret set ANDROID_KEY_ALIAS
$storePw  | gh secret set ANDROID_KEY_PASSWORD
Write-Host "Done. Re-run the Release APKs workflow (or push a new v* tag)."

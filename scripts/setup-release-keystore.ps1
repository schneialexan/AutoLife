# One-time setup: generate a shared release keystore and register it as GitHub
# Actions secrets so every release APK is signed with the same key. This is what
# lets a freshly downloaded GitHub release APK upgrade an already-installed app
# in place (instead of failing with "package conflicts with an existing package").
#
# Requirements: keytool (ships with the JDK) and the GitHub CLI `gh` (logged in).
# Run once from the repo root:  .\scripts\setup-release-keystore.ps1
#
# Re-running regenerates the keystore with a NEW key — only do that if you are
# willing to uninstall/reinstall every app on every device, because the new key
# will no longer match previously installed builds.

$ErrorActionPreference = "Stop"

$KeystoreFile = "autolife-release.jks"
$KeyAlias = "autolife"
$ValidityDays = 10000

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $repoRoot

if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) {
  Write-Error "keytool not found. Install a JDK (e.g. Temurin 17) first."
}

Write-Host "This generates a release keystore and uploads it to GitHub as encrypted secrets."
$storePwSecure = Read-Host -AsSecureString "Choose a keystore password"
$storePw2Secure = Read-Host -AsSecureString "Confirm keystore password"
$storePw = [System.Net.NetworkCredential]::new("", $storePwSecure).Password
$storePw2 = [System.Net.NetworkCredential]::new("", $storePw2Secure).Password
if ($storePw -ne $storePw2) {
  Write-Error "passwords do not match."
}

if (Test-Path $KeystoreFile) {
  Write-Error "$KeystoreFile already exists. Refusing to overwrite. Delete it manually only if you intend to rotate the signing key."
}

keytool -genkeypair `
  -keystore $KeystoreFile `
  -alias $KeyAlias `
  -keyalg RSA -keysize 2048 -validity $ValidityDays `
  -storepass $storePw -keypass $storePw `
  -dname "CN=AutoLife, OU=AutoLife, O=AutoLife, L=, ST=, C="

Write-Host "Created $KeystoreFile (alias: $KeyAlias)."

$keystoreB64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes((Resolve-Path $KeystoreFile)))

if (Get-Command gh -ErrorAction SilentlyContinue) {
  Write-Host "Uploading secrets to GitHub via gh..."
  $keystoreB64 | gh secret set ANDROID_KEYSTORE_BASE64
  $storePw     | gh secret set ANDROID_KEYSTORE_PASSWORD
  $KeyAlias    | gh secret set ANDROID_KEY_ALIAS
  $storePw     | gh secret set ANDROID_KEY_PASSWORD
  Write-Host "Secrets uploaded: ANDROID_KEYSTORE_BASE64, ANDROID_KEYSTORE_PASSWORD, ANDROID_KEY_ALIAS, ANDROID_KEY_PASSWORD"
} else {
  Write-Host ""
  Write-Host "gh CLI not found. Add these repository secrets manually"
  Write-Host "(GitHub -> Settings -> Secrets and variables -> Actions):"
  Write-Host "  ANDROID_KEYSTORE_PASSWORD = <the password you just entered>"
  Write-Host "  ANDROID_KEY_ALIAS         = $KeyAlias"
  Write-Host "  ANDROID_KEY_PASSWORD      = <the password you just entered>"
  Write-Host "  ANDROID_KEYSTORE_BASE64   = (contents below)"
  Write-Host "-------- ANDROID_KEYSTORE_BASE64 --------"
  Write-Host $keystoreB64
  Write-Host "-----------------------------------------"
}

Write-Host ""
Write-Host "IMPORTANT: keep $KeystoreFile somewhere safe and OFF GitHub."
Write-Host "It is gitignored, but if you lose it you can never ship an in-place"
Write-Host "upgrade to already-installed apps again."

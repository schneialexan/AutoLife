# Encode autolife-release.jks as a single-line base64 file for pasting into the
# ANDROID_KEYSTORE_BASE64 GitHub Actions secret.
#
# Run from the repo root:  .\scripts\getbase64.ps1

$ErrorActionPreference = "Stop"

$KeystoreFile = "autolife-release.jks"
$OutFile = "autolife-release.jks.b64"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $repoRoot

if (-not (Test-Path $KeystoreFile)) {
  Write-Error "$KeystoreFile not found in repo root."
}

$bytes = [IO.File]::ReadAllBytes((Resolve-Path $KeystoreFile))
$b64 = [Convert]::ToBase64String($bytes)
[IO.File]::WriteAllText((Join-Path $repoRoot $OutFile), $b64)

$decoded = [Convert]::FromBase64String($b64)
if ($decoded.Length -lt 4 -or $decoded[0] -ne 0xFE -or $decoded[1] -ne 0xED) {
  Write-Error "Encoded output does not look like a valid JKS file."
}

Write-Host "Wrote $OutFile ($($b64.Length) chars)."
Write-Host "Open the file, Ctrl+A, copy the single line, and paste into"
Write-Host "ANDROID_KEYSTORE_BASE64 (no quotes, no spaces before or after)."

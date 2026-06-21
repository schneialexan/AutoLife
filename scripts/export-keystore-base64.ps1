# Write a one-line base64 encoding of autolife-release.jks for pasting into
# ANDROID_KEYSTORE_BASE64. Prefer committing signing/autolife-release.jks instead.
#
# Run from repo root:  .\scripts\export-keystore-base64.ps1

$ErrorActionPreference = "Stop"

$KeystoreFile = "autolife-release.jks"
$OutFile = "autolife-release.jks.b64"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $repoRoot

$source = if (Test-Path "signing\$KeystoreFile") { "signing\$KeystoreFile" }
          elseif (Test-Path $KeystoreFile) { $KeystoreFile }
          else { $null }

if (-not $source) {
  Write-Error "No keystore found. Run .\scripts\setup-release-keystore.ps1 first."
}

$bytes = [IO.File]::ReadAllBytes((Resolve-Path $source))
$b64 = [Convert]::ToBase64String($bytes)
[IO.File]::WriteAllText((Join-Path $repoRoot $OutFile), $b64)

# Round-trip check + JKS magic bytes (0xFEEDFEED).
$decoded = [Convert]::FromBase64String($b64)
if ($decoded.Length -lt 4 -or $decoded[0] -ne 0xFE -or $decoded[1] -ne 0xED) {
  Write-Error "Encoded output does not look like a valid JKS file."
}

Write-Host "Wrote $OutFile ($($b64.Length) chars)."
Write-Host "If you must use a GitHub secret: open the file, Ctrl+A, copy the single line,"
Write-Host "and paste into ANDROID_KEYSTORE_BASE64 with no quotes or extra spaces."
Write-Host "Recommended instead: commit signing/$KeystoreFile and delete ANDROID_KEYSTORE_BASE64."

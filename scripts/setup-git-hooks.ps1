# Installs repo git hooks from .githooks/ into .git/hooks/.
# Run once after cloning:  .\scripts\setup-git-hooks.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$src = Join-Path $root ".githooks"
$dst = Join-Path $root ".git\hooks"

if (-not (Test-Path $src)) {
  Write-Error ".githooks directory not found at $src"
}

New-Item -ItemType Directory -Force -Path $dst | Out-Null

Get-ChildItem $src -File | ForEach-Object {
  $target = Join-Path $dst $_.Name
  Copy-Item $_.FullName $target -Force
  Write-Host "Installed hook: $($_.Name)"
}

Write-Host "Git hooks installed. Cursor attribution will be stripped from commit messages."

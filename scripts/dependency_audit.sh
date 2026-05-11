#!/usr/bin/env bash
# Runs dependency_audit_runner.dart (Dart + Flutter outdated + npm audit).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec dart run "$ROOT/scripts/dependency_audit_runner.dart" "$@"

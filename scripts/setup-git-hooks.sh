#!/usr/bin/env bash
# Installs repo git hooks from .githooks/ into .git/hooks/.
# Run once after cloning:  ./scripts/setup-git-hooks.sh

set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
src="$root/.githooks"
dst="$root/.git/hooks"

mkdir -p "$dst"
for hook in "$src"/*; do
  [ -f "$hook" ] || continue
  name="$(basename "$hook")"
  cp "$hook" "$dst/$name"
  chmod +x "$dst/$name"
  echo "Installed hook: $name"
done
echo "Git hooks installed. Cursor attribution will be stripped from commit messages."

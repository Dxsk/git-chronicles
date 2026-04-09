#!/usr/bin/env bash
#
# Run shellcheck on the project's bash scripts.
#
# Scope:
#   - scripts/**/*.sh            (CI + Makefile helpers + packaging)
#   - lib/common.sh              (verifier framework)
#   - exercises/**/verifier.sh   (end-user verifier scripts)
#   - exercises/**/preparer-archive.sh (scenario builders)
#   - tests/verifiers/helpers.bash
#
# Excluded:
#   - tests/verifiers/*.bats and tests/packaging/*.bats
#     bats has its own `set -e` / test-isolation semantics; `cd` without
#     `|| return` is normal inside a bats `@test` block and SC2164 would
#     fire on every test without catching real bugs.
#
# Severity is pinned to 'warning' (drops SC1090/SC1091 info noise about
# non-constant sourcing, which is legitimate here).

set -euo pipefail

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "✗ shellcheck not found. Install it to run bash static analysis." >&2
  echo "  Arch:   sudo pacman -S shellcheck" >&2
  echo "  Debian: sudo apt install shellcheck" >&2
  exit 1
fi

echo "▶ Running shellcheck…"

# Collect targets without failing if a glob matches nothing.
shopt -s nullglob
targets=(
  scripts/*.sh
  scripts/ci/*.sh
  scripts/makefile/*.sh
  lib/common.sh
  tests/verifiers/helpers.bash
)
targets+=(exercises/*/verifier.sh)
targets+=(exercises/*/preparer-archive.sh)

shellcheck --severity=warning --external-sources "${targets[@]}"
echo "✓ shellcheck: clean."

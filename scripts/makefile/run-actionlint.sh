#!/usr/bin/env bash
#
# Run actionlint on .github/workflows.
#
# actionlint is a single Go binary that statically validates GitHub
# Actions workflow YAML: syntax, action usage, expressions, shell
# scripts inside `run:` blocks (via shellcheck when available).
#
# If actionlint is not installed locally, the script gracefully skips
# with install instructions. CI jobs should run this via the
# rhysd/actionlint-docker image or download the static binary.

set -euo pipefail

if ! command -v actionlint >/dev/null 2>&1; then
  echo "⚠ actionlint not found, skipping workflow lint."
  echo "  Install: https://github.com/rhysd/actionlint/releases"
  echo "  Quick install to ~/.local/bin:"
  echo "    curl -sSL \"https://github.com/rhysd/actionlint/releases/latest/download/actionlint_\$(uname -s | tr A-Z a-z)_amd64.tar.gz\" | tar -xz -C ~/.local/bin actionlint"
  exit 0
fi

echo "▶ Running actionlint…"
actionlint
echo "✓ actionlint: clean."

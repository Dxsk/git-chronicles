#!/usr/bin/env bash
#
# Install the non-Node tooling required to run `make lint` and
# `make test` on a GitHub Actions ubuntu-latest runner.
#
# ubuntu-latest already ships with:
#   - node, npm
#   - pwsh (PowerShell 7)
#   - shellcheck
#
# It does NOT ship with:
#   - bats            (apt package, used by make test-bats / test-packaging)
#   - actionlint      (single Go binary, used by make lint-ci)
#   - Pester          (PowerShell module, bootstrapped by run-pester.sh)
#   - PSScriptAnalyzer (same, bootstrapped by run-psscriptanalyzer.sh)
#
# Pester and PSScriptAnalyzer are installed on demand by their respective
# helper scripts, so this script only needs to handle bats and actionlint.

set -euo pipefail

echo "▶ Installing CI test tools…"

# bats via apt (available on ubuntu-latest).
if ! command -v bats >/dev/null 2>&1; then
  echo "  • installing bats"
  sudo apt-get update -qq
  sudo apt-get install -y -qq bats
else
  echo "  • bats already present: $(bats --version)"
fi

# actionlint via the upstream install script (static Go binary).
if ! command -v actionlint >/dev/null 2>&1; then
  echo "  • installing actionlint"
  bindir="${HOME}/.local/bin"
  mkdir -p "$bindir"
  (
    cd "$(mktemp -d)"
    curl -sSL \
      "https://github.com/rhysd/actionlint/releases/latest/download/actionlint_$(uname -s | tr '[:upper:]' '[:lower:]')_amd64.tar.gz" \
      | tar -xz actionlint
    mv actionlint "$bindir/"
  )
  echo "$bindir" >> "${GITHUB_PATH:-/dev/null}"
  echo "  • actionlint installed to $bindir"
else
  echo "  • actionlint already present: $(actionlint --version | head -1)"
fi

echo "✓ test tools ready."

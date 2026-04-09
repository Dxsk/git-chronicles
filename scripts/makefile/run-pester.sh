#!/usr/bin/env bash
#
# Run Pester regression tests for verifier.ps1 scripts.
#
# Usage:
#   run-pester.sh <tests-dir> <pwsh-cmd...>
#
# Examples:
#   run-pester.sh tests/verifiers pwsh
#   run-pester.sh tests/verifiers distrobox enter multidev -- pwsh
#
# Bootstraps Pester 5.x on first run if missing, then invokes it on
# the given tests directory.

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "usage: $0 <tests-dir> <pwsh-cmd...>" >&2
  exit 2
fi

TESTS_DIR="$1"
shift

echo "Running Pester tests via: $*"

"$@" -NoProfile -Command "
if (-not (Get-Module -ListAvailable -Name Pester | Where-Object { \$_.Version -ge '5.0.0' })) {
    Write-Host '  Installing Pester (first run only)...'
    Install-Module -Name Pester -Force -Scope CurrentUser -SkipPublisherCheck
}
Import-Module Pester
\$cfg = New-PesterConfiguration
\$cfg.Run.Path = '$TESTS_DIR'
\$cfg.Run.Exit = \$true
\$cfg.Output.Verbosity = 'Detailed'
Invoke-Pester -Configuration \$cfg
"

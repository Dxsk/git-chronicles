#!/usr/bin/env bash
#
# Detect the PowerShell command to use for running Pester tests.
#
# Prints the resolved command on stdout (one line) or nothing if pwsh
# is unavailable. Consumed by the Makefile:
#
#   PWSH := $(shell scripts/makefile/detect-pwsh.sh)
#
# Lookup order:
#   1. pwsh on PATH (host install)
#   2. pwsh inside a distrobox container named "multidev" (common on
#      Arch and immutable distros where pwsh lives in a toolbox)

set -euo pipefail

if command -v pwsh >/dev/null 2>&1; then
  echo "pwsh"
  exit 0
fi

if command -v distrobox >/dev/null 2>&1; then
  if distrobox enter multidev -- bash -c 'command -v pwsh' >/dev/null 2>&1; then
    echo "distrobox enter multidev -- pwsh"
    exit 0
  fi
fi

# Not found: print nothing, Makefile will treat PWSH as empty.
exit 0

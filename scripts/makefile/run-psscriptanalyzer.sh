#!/usr/bin/env bash
#
# Run PSScriptAnalyzer on the project's PowerShell sources.
#
# Usage:
#   run-psscriptanalyzer.sh <pwsh-cmd...>
#
# Examples:
#   run-psscriptanalyzer.sh pwsh
#   run-psscriptanalyzer.sh distrobox enter multidev -- pwsh
#
# Bootstraps PSScriptAnalyzer on first run if missing (same pattern as
# run-pester.sh), then runs it against lib/, exercises/ and
# tests/verifiers/. Rule exclusions live in PSScriptAnalyzerSettings.psd1
# at the repo root — see that file for the justification of each exclusion.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "⚠ pwsh not found, skipping PSScriptAnalyzer."
  echo "  Install on host, or provide a distrobox container named 'multidev' with pwsh."
  exit 0
fi

echo "▶ Running PSScriptAnalyzer via: $*"

"$@" -NoProfile -Command '
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Write-Host "  Installing PSScriptAnalyzer (first run only)..."
    Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser -SkipPublisherCheck
}
Import-Module PSScriptAnalyzer

$settings = "./PSScriptAnalyzerSettings.psd1"
$results = @()
$results += Invoke-ScriptAnalyzer -Path lib             -Recurse -Settings $settings
$results += Invoke-ScriptAnalyzer -Path exercises       -Recurse -Settings $settings
$results += Invoke-ScriptAnalyzer -Path tests/verifiers -Recurse -Settings $settings

if ($results.Count -gt 0) {
    $results | Format-Table ScriptName,Line,RuleName,Message -AutoSize
    Write-Host "PSScriptAnalyzer: $($results.Count) issue(s) found." -ForegroundColor Red
    exit 1
}

Write-Host "PSScriptAnalyzer: clean."
'

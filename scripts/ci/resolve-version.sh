#!/usr/bin/env bash
#
# Resolve the release version label for the current CI run.
#
# Outputs two key=value lines suitable for GitHub Actions:
#   label=<version>
#   tagged=<true|false>
#
# When invoked from GitHub Actions, pass $GITHUB_OUTPUT as the first
# argument (or set it in the environment) and the lines are appended
# there. Otherwise they are printed to stdout so the script stays
# locally testable.
#
# Version rules:
#   refs/tags/vX.Y.Z   -> label=vX.Y.Z, tagged=true
#   anything else      -> label=latest, tagged=false

set -euo pipefail

ref="${GITHUB_REF:-}"
output_file="${1:-${GITHUB_OUTPUT:-}}"

if [[ "$ref" == refs/tags/* ]]; then
  label="${ref#refs/tags/}"
  tagged=true
else
  label=latest
  tagged=false
fi

if [[ -n "$output_file" ]]; then
  {
    echo "label=$label"
    echo "tagged=$tagged"
  } >> "$output_file"
else
  echo "label=$label"
  echo "tagged=$tagged"
fi

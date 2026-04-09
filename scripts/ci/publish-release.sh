#!/usr/bin/env bash
#
# Publish the Git Chronicles release zip to GitHub Releases.
#
# Reads configuration from environment variables so the script stays a
# single-responsibility unit that can be invoked from GitHub Actions
# or dry-run locally:
#
#   VERSION      Label resolved by scripts/ci/resolve-version.sh
#                ('latest' or 'vX.Y.Z')
#   TAGGED       'true' if $VERSION is an immutable tag, 'false' for
#                the rolling 'latest' release.
#   COMMIT_SHA   Commit SHA the release points at.
#   GH_TOKEN     GitHub token used by gh (github.token in Actions).
#   DRY_RUN      If set to any non-empty value, prints the gh commands
#                that would run instead of executing them. Useful for
#                local smoke tests.
#
# The script expects the release artifacts to already be built in
# ./build/ by scripts/package-release.sh :
#   build/git-chronicles.zip
#   build/git-chronicles.zip.sha256
#
# Behaviour:
#   tagged=true   -> gh release create $VERSION, never overwrites.
#   tagged=false  -> edit-or-create the 'latest' release, moving the
#                    tag to $COMMIT_SHA and replacing the assets.

set -euo pipefail

: "${VERSION:?VERSION is required}"
: "${TAGGED:?TAGGED is required (true|false)}"
: "${COMMIT_SHA:?COMMIT_SHA is required}"

if [[ -z "${DRY_RUN:-}" ]]; then
  : "${GH_TOKEN:?GH_TOKEN is required (unless DRY_RUN is set)}"
  export GH_TOKEN
fi

cd build

if [[ ! -f git-chronicles.zip || ! -f git-chronicles.zip.sha256 ]]; then
  echo "error: build/ does not contain the release artifacts." >&2
  echo "       run scripts/package-release.sh first." >&2
  exit 1
fi

zip_hash=$(awk '{print $1}' git-chronicles.zip.sha256)

notes="Automated build from commit ${COMMIT_SHA}.

SHA-256: \`${zip_hash}\`

Verify locally:
\`\`\`
sha256sum -c git-chronicles.zip.sha256
\`\`\`"

# Tiny shim so the script can be dry-run locally without touching GitHub.
run_gh() {
  if [[ -n "${DRY_RUN:-}" ]]; then
    printf 'DRY_RUN gh'
    printf ' %q' "$@"
    printf '\n'
  else
    gh "$@"
  fi
}

if [[ "$TAGGED" == "true" ]]; then
  # Immutable versioned release. Never overwrite an existing tag.
  run_gh release create "$VERSION" \
    --title "$VERSION" \
    --notes "$notes" \
    git-chronicles.zip git-chronicles.zip.sha256
else
  # Rolling 'latest' release: edit-or-create.
  if [[ -z "${DRY_RUN:-}" ]] && gh release view latest >/dev/null 2>&1; then
    run_gh release upload latest \
      git-chronicles.zip git-chronicles.zip.sha256 --clobber
    run_gh release edit latest \
      --target "$COMMIT_SHA" \
      --title "Latest build" \
      --notes "$notes"
  else
    run_gh release create latest \
      --target "$COMMIT_SHA" \
      --title "Latest build" \
      --notes "$notes" \
      git-chronicles.zip git-chronicles.zip.sha256
  fi
fi

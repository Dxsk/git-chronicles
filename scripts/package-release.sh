#!/usr/bin/env bash
#
# Build the Git Chronicles release zip.
#
# Uses `git archive` with .gitattributes export-ignore as the single
# source of truth for what gets packaged. Injects a BUILD_INFO stamp,
# produces a deterministic zip (reproducible for a given HEAD+version),
# computes SHA-256, enforces size/count guardrails, and verifies
# integrity via a round-trip rehash.
#
# Environment overrides (used by tests and CI):
#   PACKAGE_OUTPUT_DIR   where to write outputs (default: <repo>/build)
#   PACKAGE_VERSION      version label stamped in BUILD_INFO (default: latest)
#   PACKAGE_MIN_FILES    minimum file count guardrail (default: 10)
#   PACKAGE_MAX_BYTES    maximum zip size guardrail  (default: 20000000)

set -euo pipefail

ROOT=$(git rev-parse --show-toplevel)
cd "$ROOT"

OUTPUT_DIR="${PACKAGE_OUTPUT_DIR:-$ROOT/build}"
VERSION="${PACKAGE_VERSION:-latest}"
MIN_FILES="${PACKAGE_MIN_FILES:-10}"
MAX_BYTES="${PACKAGE_MAX_BYTES:-20000000}"

ARCHIVE_NAME="git-chronicles"
PREFIX="$ARCHIVE_NAME/"

STAGE="$OUTPUT_DIR/stage"
VERIFY="$OUTPUT_DIR/verify"
ZIP="$OUTPUT_DIR/$ARCHIVE_NAME.zip"
SHA="$OUTPUT_DIR/$ARCHIVE_NAME.zip.sha256"

COMMIT=$(git rev-parse HEAD)
COMMIT_DATE=$(git log -1 --format=%cI HEAD)
SOURCE_DATE_EPOCH=$(git log -1 --format=%ct HEAD)
export SOURCE_DATE_EPOCH TZ=UTC

rm -rf "$OUTPUT_DIR"
mkdir -p "$STAGE"

# Stage via git archive (honours .gitattributes export-ignore in HEAD).
git archive --format=tar --prefix="$PREFIX" HEAD | tar -x -C "$STAGE"

# Inject BUILD_INFO so any downloaded zip can be traced back to a commit.
cat > "$STAGE/${PREFIX}BUILD_INFO" <<EOF
commit: $COMMIT
date:   $COMMIT_DATE
tag:    $VERSION
EOF

# Normalise mtimes for reproducibility.
find "$STAGE/$PREFIX" -exec touch -d "@$SOURCE_DATE_EPOCH" {} +

# Hash the staged tree. This is the source of truth the verify step
# will compare against, not the file-at-rest hash.
STAGE_HASH=$(cd "$STAGE" && find "$PREFIX" -type f -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha256sum \
  | sha256sum \
  | awk '{print $1}')

# Deterministic zip: sorted file list, strip extra attributes (-X).
(
  cd "$STAGE"
  find "$PREFIX" -print0 \
    | LC_ALL=C sort -z \
    | xargs -0 zip -qX "$ZIP" >/dev/null
)

sha256sum "$ZIP" \
  | awk -v n="$ARCHIVE_NAME.zip" '{print $1 "  " n}' > "$SHA"
ZIP_HASH=$(awk '{print $1}' "$SHA")

# Guardrails: catch silent packaging regressions (broken excludes,
# accidental binary blobs, bloated exports).
FILE_COUNT=$(unzip -Z1 "$ZIP" | grep -cv '/$' || true)
SIZE_BYTES=$(stat -c%s "$ZIP")

if [ "$FILE_COUNT" -lt "$MIN_FILES" ]; then
  echo "::error::zip contains only $FILE_COUNT files (min: $MIN_FILES)" >&2
  exit 1
fi

if [ "$SIZE_BYTES" -gt "$MAX_BYTES" ]; then
  echo "::error::zip size ${SIZE_BYTES}B exceeds limit ${MAX_BYTES}B" >&2
  exit 1
fi

# Round-trip verify: unzip, re-normalise mtimes, rehash, compare.
rm -rf "$VERIFY"
mkdir -p "$VERIFY"
unzip -q "$ZIP" -d "$VERIFY"
find "$VERIFY/$PREFIX" -exec touch -d "@$SOURCE_DATE_EPOCH" {} +

VERIFY_HASH=$(cd "$VERIFY" && find "$PREFIX" -type f -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 sha256sum \
  | sha256sum \
  | awk '{print $1}')

if [ "$STAGE_HASH" != "$VERIFY_HASH" ]; then
  echo "::error::integrity check failed" >&2
  echo "  stage:  $STAGE_HASH" >&2
  echo "  verify: $VERIFY_HASH" >&2
  exit 1
fi

rm -rf "$STAGE" "$VERIFY"

cat <<EOF
Package built successfully.
  version:  $VERSION
  commit:   $COMMIT
  files:    $FILE_COUNT
  size:     ${SIZE_BYTES} bytes
  sha256:   $ZIP_HASH
  zip:      $ZIP
  checksum: $SHA
EOF

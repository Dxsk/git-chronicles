#!/usr/bin/env bats
#
# Regression tests for scripts/package-release.sh.

setup() {
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  SCRIPT="$REPO_ROOT/scripts/package-release.sh"
  export PACKAGE_OUTPUT_DIR="$BATS_TEST_TMPDIR/build"
}

@test "script exits 0 and produces zip + sha256" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -f "$PACKAGE_OUTPUT_DIR/git-chronicles.zip" ]
  [ -f "$PACKAGE_OUTPUT_DIR/git-chronicles.zip.sha256" ]
}

@test "sha256 sidecar matches the actual zip hash" {
  "$SCRIPT" >/dev/null
  actual=$(sha256sum "$PACKAGE_OUTPUT_DIR/git-chronicles.zip" | awk '{print $1}')
  recorded=$(awk '{print $1}' "$PACKAGE_OUTPUT_DIR/git-chronicles.zip.sha256")
  [ "$actual" = "$recorded" ]
}

@test "BUILD_INFO is injected with commit and default tag" {
  "$SCRIPT" >/dev/null
  extract="$BATS_TEST_TMPDIR/extract1"
  mkdir -p "$extract"
  unzip -q "$PACKAGE_OUTPUT_DIR/git-chronicles.zip" -d "$extract"

  [ -f "$extract/git-chronicles/BUILD_INFO" ]
  grep -q "^commit: " "$extract/git-chronicles/BUILD_INFO"
  grep -q "^tag:    latest$" "$extract/git-chronicles/BUILD_INFO"
}

@test "custom PACKAGE_VERSION is recorded in BUILD_INFO" {
  PACKAGE_VERSION=v1.2.3 "$SCRIPT" >/dev/null
  extract="$BATS_TEST_TMPDIR/extract2"
  mkdir -p "$extract"
  unzip -q "$PACKAGE_OUTPUT_DIR/git-chronicles.zip" -d "$extract"
  grep -q "^tag:    v1.2.3$" "$extract/git-chronicles/BUILD_INFO"
}

@test "build is reproducible for the same HEAD and version" {
  "$SCRIPT" >/dev/null
  first=$(sha256sum "$PACKAGE_OUTPUT_DIR/git-chronicles.zip" | awk '{print $1}')
  "$SCRIPT" >/dev/null
  second=$(sha256sum "$PACKAGE_OUTPUT_DIR/git-chronicles.zip" | awk '{print $1}')
  [ "$first" = "$second" ]
}

@test "guardrail fails when PACKAGE_MIN_FILES is set absurdly high" {
  PACKAGE_MIN_FILES=999999 run "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"min: 999999"* ]]
}

@test "guardrail fails when PACKAGE_MAX_BYTES is set absurdly low" {
  PACKAGE_MAX_BYTES=100 run "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"exceeds limit 100B"* ]]
}

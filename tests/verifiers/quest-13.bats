#!/usr/bin/env bats
#
# Regression tests for exercises/13-les-sceaux-magiques/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="13-les-sceaux-magiques"

build_pass_scenario() {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "Commit initial"
  git tag v1.0.0
  echo "b" > b.txt && git add b.txt && git commit -q -m "Deuxième"
  git tag -a v1.1.0 -m "Version mineure"
  cd - >/dev/null
}

@test "quest 13: verifier passes with 2 tags (one annotated, semver)" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"4 / 4"* ]]
}

@test "quest 13: fails when no tag follows the vX.Y.Z format" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "Initial"
  git tag release-one
  git tag -a release-two -m "Second"
  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"versionnage"* ]]
}

@test "quest 13: fails when no tag is annotated (all lightweight)" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "Initial"
  git tag v1.0.0
  git tag v1.1.0
  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"annoté"* ]]
}

@test "quest 13: fails when one of the tags does not follow semver" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "Initial"
  git tag v1.0.0
  git tag -a release-notes -m "Not a semver tag"
  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"versionnage"* ]]
}

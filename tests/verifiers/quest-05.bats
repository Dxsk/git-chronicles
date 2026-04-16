#!/usr/bin/env bats
#
# Regression tests for exercises/05-les-lignes-du-temps/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="05-les-lignes-du-temps"

# The quest ships an archive.bundle that the apprentice clones to start.
# We do the same to build a realistic pass scenario.
build_from_bundle() {
  cd "$TMP_DIR"
  git clone -q "$REPO_ROOT/exercises/$QUEST/archive.bundle" work
  cd work
}

@test "quest 05: ships archive.bundle and preparer-archive.sh" {
  [ -f "$REPO_ROOT/exercises/$QUEST/archive.bundle" ]
  [ -f "$REPO_ROOT/exercises/$QUEST/preparer-archive.sh" ]
}

@test "quest 05: verifier passes with .gitignore ignoring .log and a debug.log" {
  build_from_bundle
  echo "*.log" > .gitignore
  echo "noisy debug line" > debug.log
  git rm --cached debug.log 2>/dev/null || true
  git add .gitignore
  git commit -q -m "Ignore log files to keep archives clean"
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" == *"5 / 5"* ]]
}

@test "quest 05: fails without a .gitignore" {
  build_from_bundle
  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"5 / 5"* ]]
  [[ "$output" == *".gitignore"* ]]
}

@test "quest 05: fails when .gitignore exists but does not ignore .log files" {
  build_from_bundle
  echo "*.tmp" > .gitignore
  git rm --cached debug.log 2>/dev/null || true
  git add .gitignore
  git commit -q -m "Ignore temporary files but not logs"
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"5 / 5"* ]]
}

@test "quest 05: passes when .gitignore uses a nested glob such as **/*.log" {
  build_from_bundle
  echo "**/*.log" > .gitignore
  echo "noisy debug line" > debug.log
  git rm --cached debug.log 2>/dev/null || true
  git add .gitignore
  git commit -q -m "Ignore log files everywhere in the tree"
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" == *"5 / 5"* ]]
}

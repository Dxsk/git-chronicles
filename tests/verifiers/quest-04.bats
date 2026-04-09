#!/usr/bin/env bats
#
# Regression tests for exercises/04-larchive-est-partout/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="04-larchive-est-partout"

build_pass_scenario() {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"

  # Build an origin repo with one commit.
  mkdir mon-archive
  ( cd mon-archive && git init -q && echo "hello" > a.txt && git add a.txt && git commit -q -m "init" )

  # ma-copie/ is a clone of mon-archive via local path (so origin URL is a path).
  git clone -q ./mon-archive ma-copie

  # archive-centrale.git is a bare repo.
  git clone -q --bare ./mon-archive ./archive-centrale.git

  # clone-depuis-bare/ is cloned from the bare repo.
  git clone -q ./archive-centrale.git ./clone-depuis-bare

  cd - >/dev/null
}

@test "quest 04: verifier passes with full remote + clone + bare setup" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"4 / 4"* ]]
}

@test "quest 04: fails when ma-copie/ is missing" {
  build_pass_scenario
  rm -rf "$TMP_DIR/work/ma-copie"
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"ma-copie"* ]]
}

@test "quest 04: fails when archive-centrale.git is not a bare repo" {
  build_pass_scenario
  rm -rf "$TMP_DIR/work/archive-centrale.git"
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"bare"* ]]
}

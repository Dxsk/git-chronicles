#!/usr/bin/env bats
#
# Regression tests for exercises/09-les-portails-distants/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="09-les-portails-distants"

build_pass_scenario() {
  # Upstream bare repo the apprentice pushes to.
  git init -q --bare "$TMP_DIR/upstream.git"

  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "hello" > f.txt
  git add f.txt
  git commit -q -m "Initial"
  git remote add origin "$TMP_DIR/upstream.git"
  git push -q -u origin main
  git fetch -q origin
  cd - >/dev/null
}

@test "quest 09: verifier passes with remote configured + push + fetch" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"4 / 4"* ]]
}

@test "quest 09: fails without any remote configured" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "hello" > f.txt
  git add f.txt
  git commit -q -m "Initial"
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"remote"* ]]
}

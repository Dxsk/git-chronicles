#!/usr/bin/env bats
#
# Regression tests for exercises/06-larbre-des-possibles/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="06-larbre-des-possibles"

build_pass_scenario() {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "base" > base.txt
  git add base.txt
  git commit -q -m "Commit initial sur main"

  git checkout -q -b expedition-nord
  echo "nord" > nord.txt
  git add nord.txt
  git commit -q -m "Exploration du nord"

  git checkout -q main
  git checkout -q -b expedition-sud
  echo "sud" > sud.txt
  git add sud.txt
  git commit -q -m "Exploration du sud"

  git checkout -q main
  cd - >/dev/null
}

@test "quest 06: verifier passes with two expedition branches" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"7 / 7"* ]]
}

@test "quest 06: fails when expedition-nord branch is missing" {
  build_pass_scenario
  cd "$TMP_DIR/work"
  git branch -D expedition-nord
  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"7 / 7"* ]]
  [[ "$output" == *"expedition-nord"* ]]
}

@test "quest 06: fails when the student is left on an expedition branch" {
  build_pass_scenario
  cd "$TMP_DIR/work"
  git checkout -q expedition-nord
  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"7 / 7"* ]]
  [[ "$output" == *"main"* ]]
}

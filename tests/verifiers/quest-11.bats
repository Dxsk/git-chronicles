#!/usr/bin/env bats
#
# Regression tests for exercises/11-le-tisseur-de-temps/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="11-le-tisseur-de-temps"

@test "quest 11: verifier passes with stash activity and multiple branches" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "A"
  echo "b" > b.txt && git add b.txt && git commit -q -m "B"
  echo "c" > c.txt && git add c.txt && git commit -q -m "C"

  git checkout -q -b travail
  echo "wip" >> a.txt
  git stash push -q -m "Travail en cours"
  git stash pop -q
  git checkout -q main

  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"5 / 5"* ]]
}

@test "quest 11: fails when a stash is still pending (never popped/applied)" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "A"
  echo "b" > b.txt && git add b.txt && git commit -q -m "B"
  echo "c" > c.txt && git add c.txt && git commit -q -m "C"

  git checkout -q -b travail
  echo "wip" >> a.txt
  git stash push -q -m "Travail en cours"
  # Deliberately do NOT pop, so the stash stack stays non-empty.
  git checkout -q main

  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"5 / 5"* ]]
}

@test "quest 11: fails when the student is left on the work branch" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "A"
  echo "b" > b.txt && git add b.txt && git commit -q -m "B"
  echo "c" > c.txt && git add c.txt && git commit -q -m "C"
  git checkout -q -b travail
  echo "wip" >> a.txt
  git stash push -q -m "Travail en cours"
  git stash pop -q
  # Student forgets to switch back to main.
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"5 / 5"* ]]
  [[ "$output" == *"main"* ]]
}

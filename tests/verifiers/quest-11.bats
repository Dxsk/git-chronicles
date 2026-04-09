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
  # Trigger a real stash so refs/stash exists in the reflog. We don't pop it,
  # because `git stash pop` removes refs/stash once the stash stack is empty
  # and the verifier's step 3 needs a reflog entry on that ref.
  echo "wip" >> a.txt
  git stash push -q -m "Travail en cours"

  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"4 / 4"* ]]
}

@test "quest 11: fails without any stash activity" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "A"
  echo "b" > b.txt && git add b.txt && git commit -q -m "B"
  echo "c" > c.txt && git add c.txt && git commit -q -m "C"
  git checkout -q -b travail
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"stash"* ]]
}

#!/usr/bin/env bats
#
# Regression tests for exercises/08-reecrire-lhistoire/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="08-reecrire-lhistoire"

build_pass_scenario() {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q

  echo "a" > a.txt && git add a.txt && git commit -q -m "Commit A"
  echo "b" > b.txt && git add b.txt && git commit -q -m "Commit B"

  # amend
  echo "a1" >> a.txt && git add a.txt && git commit -q --amend -m "Commit A amended"

  # Create a third commit and a branch to rebase onto main.
  git checkout -q -b feature
  echo "c" > c.txt && git add c.txt && git commit -q -m "Commit C on feature"
  git checkout -q main
  echo "d" > d.txt && git add d.txt && git commit -q -m "Commit D on main"
  git checkout -q feature
  git rebase -q main

  cd - >/dev/null
}

@test "quest 08: verifier passes after amend + rebase + 3 commits" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"4 / 4"* ]]
}

@test "quest 08: fails without any amend or rebase" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "A"
  echo "b" > b.txt && git add b.txt && git commit -q -m "B"
  echo "c" > c.txt && git add c.txt && git commit -q -m "C"
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
}

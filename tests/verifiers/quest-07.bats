#!/usr/bin/env bats
#
# Regression tests for exercises/07-le-conflit-des-royaumes/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="07-le-conflit-des-royaumes"

@test "quest 07: ships archive.bundle and preparer-archive.sh" {
  [ -f "$REPO_ROOT/exercises/$QUEST/archive.bundle" ]
  [ -f "$REPO_ROOT/exercises/$QUEST/preparer-archive.sh" ]
}

@test "quest 07: verifier passes after a clean merge" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "base" > f.txt
  git add f.txt
  git commit -q -m "Initial"

  git checkout -q -b royaume-sud
  echo "sud" >> f.txt
  git commit -q -am "Contribution du sud"

  git checkout -q main
  git merge -q --no-ff -m "Fusion des royaumes après négociations" royaume-sud
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" == *"5 / 5"* ]]
}

@test "quest 07: fails when no merge has been performed" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "base" > f.txt
  git add f.txt
  git commit -q -m "Commit initial"
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"5 / 5"* ]]
  [[ "$output" == *"merge"* ]]
}

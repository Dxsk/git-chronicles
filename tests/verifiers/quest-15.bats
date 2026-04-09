#!/usr/bin/env bats
#
# Regression tests for exercises/15-les-forges-eternelles/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="15-les-forges-eternelles"

@test "quest 15: verifier passes with remote + pushed refs + 3+ commits" {
  git init -q --bare "$TMP_DIR/forge.git"

  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  for i in 1 2 3; do
    echo "commit $i" > "f$i.txt"
    git add "f$i.txt"
    git commit -q -m "Commit $i"
  done
  git remote add origin "$TMP_DIR/forge.git"
  git push -q -u origin main
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" == *"4 / 4"* ]]
}

@test "quest 15: fails without a remote" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  for i in 1 2 3; do
    echo "commit $i" > "f$i.txt"
    git add "f$i.txt"
    git commit -q -m "Commit $i"
  done
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"remote"* ]]
}

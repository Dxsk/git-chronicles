#!/usr/bin/env bats
#
# Regression tests for exercises/10-le-protocole-des-guildes/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="10-le-protocole-des-guildes"

@test "quest 10: verifier passes after --no-ff merge + branch cleanup" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "Commit A"
  echo "b" > b.txt && git add b.txt && git commit -q -m "Commit B"

  git checkout -q -b proposition
  echo "p" > p.txt && git add p.txt && git commit -q -m "Proposition de la guilde"
  git checkout -q main
  git merge -q --no-ff -m "Intégrer la proposition selon le Protocole" proposition
  git branch -D proposition
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" == *"6 / 6"* ]]
}

@test "quest 10: fails when the proposition branch has not been cleaned up" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "A"
  echo "b" > b.txt && git add b.txt && git commit -q -m "B"
  git checkout -q -b proposition
  echo "p" > p.txt && git add p.txt && git commit -q -m "Proposition"
  git checkout -q main
  git merge -q --no-ff -m "Merge de la proposition en main" proposition
  # NOT deleting the proposition branch on purpose.
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"6 / 6"* ]]
  [[ "$output" == *"nettoyée"* ]]
}

@test "quest 10: fails when the merge was fast-forward (no merge commit)" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "A"
  echo "b" > b.txt && git add b.txt && git commit -q -m "B"
  git checkout -q -b proposition
  echo "p" > p.txt && git add p.txt && git commit -q -m "Proposition"
  git checkout -q main
  git merge -q --ff-only proposition
  git branch -D proposition
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"6 / 6"* ]]
  [[ "$output" == *"Protocole"* ]]
}

@test "quest 10: fails when the student is still on the proposition branch" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "A"
  echo "b" > b.txt && git add b.txt && git commit -q -m "B"
  git checkout -q -b proposition
  echo "p" > p.txt && git add p.txt && git commit -q -m "Proposition"
  git checkout -q main
  git merge -q --no-ff -m "Intégrer la proposition" proposition
  # The student forgot to switch back to main and stays on proposition.
  git checkout -q proposition
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"6 / 6"* ]]
  [[ "$output" == *"main"* ]]
}

#!/usr/bin/env bats
#
# Regression tests for exercises/02-les-trois-salles-du-savoir/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="02-les-trois-salles-du-savoir"

@test "quest 02: verifier passes with parchemin.txt staged and no commit" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "contenu du parchemin" > parchemin.txt
  git add parchemin.txt
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" == *"4 / 4"* ]]
}

@test "quest 02: fails when parchemin.txt is not staged" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "contenu" > parchemin.txt
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"staging area"* ]]
}

@test "quest 02: fails once a commit has been made (the quest must stay uncommitted)" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "contenu" > parchemin.txt
  git add parchemin.txt
  git commit -q -m "Sceller le parchemin"
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"pas de commit"* ]]
}

@test "quest 02: fails when parchemin.txt is empty (zero bytes)" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  : > parchemin.txt
  git add parchemin.txt
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
}

@test "quest 02: fails when staged file is named mon-parchemin.txt instead of parchemin.txt" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "contenu du parchemin" > mon-parchemin.txt
  git add mon-parchemin.txt
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" == *"2 / 4"* ]]
}

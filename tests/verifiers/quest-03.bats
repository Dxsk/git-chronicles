#!/usr/bin/env bats
#
# Regression tests for exercises/03-le-premier-parchemin/verifier.sh
#
# These tests are NOT end-user verification scripts — they are CI/dev checks
# that protect the exercise + verifier pair against regressions.

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="03-le-premier-parchemin"

# --- Helpers --------------------------------------------------------------

# Build the canonical "happy path" scenario: a Git repo with 2 commits,
# the second one adding parchemins/mission.txt.
build_pass_scenario() {
  mkdir -p "$TMP_DIR/mon-archive"
  cd "$TMP_DIR/mon-archive"
  git init -q
  git commit -q --allow-empty -m "Initialiser l'archive de la Guilde"
  cp "$REPO_ROOT/exercises/$QUEST/parchemins/mission.txt" .
  git add mission.txt
  git commit -q -m "Ajouter l'ordre de mission de la Guilde"
  cd - >/dev/null
}

# --- The provided parchemin must exist ------------------------------------

@test "parchemins/mission.txt is shipped with the quest" {
  [ -f "$REPO_ROOT/exercises/$QUEST/parchemins/mission.txt" ]
  [ -s "$REPO_ROOT/exercises/$QUEST/parchemins/mission.txt" ]
}

# --- Pass case ------------------------------------------------------------

@test "verifier passes on a correctly-solved quest (EN)" {
  build_pass_scenario
  run run_verifier "$QUEST" "mon-archive"
  [ "$status" -eq 0 ]
  [[ "$output" == *"4 / 4"* ]]
  [[ "$output" == *"CONGRATULATIONS"* || "$output" == *"Congratulations"* ]]
}

@test "verifier passes on a correctly-solved quest (FR)" {
  build_pass_scenario
  run run_verifier "$QUEST" "mon-archive" --lang fr
  [ "$status" -eq 0 ]
  [[ "$output" == *"4 / 4"* ]]
  [[ "$output" == *"FÉLICITATIONS"* ]]
}

# --- Fail cases -----------------------------------------------------------
#
# NOTE: show_score() does not return a non-zero exit code on failure — the
# verifier is user-facing and prints an encouragement message instead. So we
# assert on the score line and the absence of the "congratulations" marker.

assert_failure_score() {
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" != *"Congratulations"* && "$output" != *"CONGRATULATIONS"* ]]
  [[ "$output" != *"FÉLICITATIONS"* ]]
}

@test "verifier fails when not run inside a Git repo" {
  mkdir -p "$TMP_DIR/not-a-repo"
  run run_verifier "$QUEST" "not-a-repo"
  assert_failure_score
}

@test "verifier fails with only one commit" {
  mkdir -p "$TMP_DIR/mon-archive"
  cd "$TMP_DIR/mon-archive"
  git init -q
  cp "$REPO_ROOT/exercises/$QUEST/parchemins/mission.txt" .
  git add mission.txt
  git commit -q -m "Ajouter l'ordre de mission"
  cd - >/dev/null

  run run_verifier "$QUEST" "mon-archive"
  assert_failure_score
  [[ "$output" == *"2 commits"* ]]
}

@test "verifier fails when mission.txt is untracked" {
  mkdir -p "$TMP_DIR/mon-archive"
  cd "$TMP_DIR/mon-archive"
  git init -q
  git commit -q --allow-empty -m "Initialiser"
  git commit -q --allow-empty -m "Deuxième commit vide"
  cp "$REPO_ROOT/exercises/$QUEST/parchemins/mission.txt" .
  cd - >/dev/null

  run run_verifier "$QUEST" "mon-archive"
  assert_failure_score
  [[ "$output" == *"mission.txt"* ]]
}

@test "verifier rejects generic first-commit messages" {
  mkdir -p "$TMP_DIR/mon-archive"
  cd "$TMP_DIR/mon-archive"
  git init -q
  git commit -q --allow-empty -m "Initial commit"
  cp "$REPO_ROOT/exercises/$QUEST/parchemins/mission.txt" .
  git add mission.txt
  git commit -q -m "Ajouter l'ordre de mission"
  cd - >/dev/null

  run run_verifier "$QUEST" "mon-archive"
  assert_failure_score
  [[ "$output" == *"personnalisé"* ]]
}

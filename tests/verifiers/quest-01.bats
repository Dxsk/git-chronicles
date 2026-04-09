#!/usr/bin/env bats
#
# Regression tests for exercises/01-la-guilde-des-archivistes/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="01-la-guilde-des-archivistes"

@test "quest 01: verifier passes with git + user.name + user.email configured" {
  # tmp_setup already sets user.name + user.email in the sandbox.
  mkdir -p "$TMP_DIR/work"
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"3 / 3"* ]]
  [[ "$output" == *"Congratulations"* || "$output" == *"CONGRATULATIONS"* ]]
}

@test "quest 01: fails when user.name is missing" {
  git config --global --unset user.name
  mkdir -p "$TMP_DIR/work"
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"3 / 3"* ]]
  [[ "$output" == *"nom est configuré"* ]]
}

@test "quest 01: fails when user.email is missing" {
  git config --global --unset user.email
  mkdir -p "$TMP_DIR/work"
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"3 / 3"* ]]
  [[ "$output" == *"email est configuré"* ]]
}

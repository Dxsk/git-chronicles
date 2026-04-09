#!/usr/bin/env bats
#
# Regression tests for exercises/20-les-chemins-libres/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="20-les-chemins-libres"

build_pass_scenario() {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "mon parcours à travers les Chroniques" > mon-parcours.txt
  git add mon-parcours.txt
  git commit -q -m "Mon parcours libre"
  git tag v1.0.0
  cd - >/dev/null
}

@test "quest 20: verifier passes with mon-parcours.txt tracked + tag" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"5 / 5"* ]]
  # The final "MAÎTRE VERSIONNEUR" ASCII banner only appears on full success.
  [[ "$output" == *"MAÎTRE VERSIONNEUR"* ]]
}

@test "quest 20: fails without mon-parcours.txt" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  git commit -q --allow-empty -m "empty"
  git tag v1.0.0
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"5 / 5"* ]]
  [[ "$output" == *"mon-parcours.txt"* ]]
}

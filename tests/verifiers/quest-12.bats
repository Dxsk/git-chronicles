#!/usr/bin/env bats
#
# Regression tests for exercises/12-loracle-du-code/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="12-loracle-du-code"

@test "quest 12: ships archive.bundle and preparer-archive.sh" {
  [ -f "$REPO_ROOT/exercises/$QUEST/archive.bundle" ]
  [ -f "$REPO_ROOT/exercises/$QUEST/preparer-archive.sh" ]
}

# Build a repo that mirrors the quest's shipped bundle: main with a
# CORROMPU bug, plus a 'correctif' branch whose tip fixes it. Simulates
# the student's full workflow (bisect + cherry-pick from correctif).
#
# The CORROMPU line is inserted in the middle of the file and
# subsequent commits append at the end, so the correctif's "remove
# CORROMPU" diff cherry-picks cleanly onto main.
build_pass_scenario() {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q

  printf 'ligne 1\nMARKER\nligne 3\n' > grimoire.txt
  git add grimoire.txt
  git commit -q -m "Grimoire initial"
  h1=$(git rev-parse HEAD)

  # Introduce a CORROMPU line by replacing MARKER (middle of file).
  sed -i 's/MARKER/CORROMPU/' grimoire.txt
  git commit -q -am "Ligne corrompue"
  h2=$(git rev-parse HEAD)

  # Later commits append lines at the end - they do not touch the
  # CORROMPU line, so the correctif diff stays clean.
  echo "ligne 4" >> grimoire.txt
  git commit -q -am "Ajout ligne 4"
  h3=$(git rev-parse HEAD)
  echo "ligne 5" >> grimoire.txt
  git commit -q -am "Ajout ligne 5"

  # Fix commit on a dedicated branch, mirroring origin/correctif.
  git checkout -q -b correctif "$h2"
  sed -i 's/CORROMPU/ligne 2/' grimoire.txt
  git commit -q -am "Corriger la formule corrompue de la Lance de Feu"
  fix_sha=$(git rev-parse HEAD)
  git checkout -q main

  # Simulate bisect traces (>= 2 hash->hash transitions).
  git -c advice.detachedHead=false checkout -q "$h1"
  git -c advice.detachedHead=false checkout -q "$h2"
  git -c advice.detachedHead=false checkout -q "$h3"
  git checkout -q main

  # Cherry-pick the fix onto main.
  git cherry-pick "$fix_sha" >/dev/null

  cd - >/dev/null
}

@test "quest 12: verifier passes with bisect + cherry-pick and clean grimoire" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"4 / 4"* ]]
}

@test "quest 12: fails when grimoire was fixed manually (no cherry-pick commit on HEAD)" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q

  printf 'ligne 1\nMARKER\nligne 3\n' > grimoire.txt
  git add grimoire.txt
  git commit -q -m "Grimoire initial"
  sed -i 's/MARKER/CORROMPU/' grimoire.txt
  git commit -q -am "Ligne corrompue"
  h2=$(git rev-parse HEAD)
  echo "ligne 4" >> grimoire.txt
  git commit -q -am "Ajout ligne 4"

  # Ship a fix on a separate branch (mirrors origin/correctif).
  git checkout -q -b correctif "$h2"
  sed -i 's/CORROMPU/ligne 2/' grimoire.txt
  git commit -q -am "Corriger la formule corrompue de la Lance de Feu"
  git checkout -q main

  # Student cheats: edits the file directly, commits under a different
  # subject. No cherry-pick of the correctif commit.
  sed -i 's/CORROMPU/ligne 2/' grimoire.txt
  git commit -q -am "Nettoyage express"

  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"correctif"* ]]
}

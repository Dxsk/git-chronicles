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

@test "quest 12: verifier passes with bisect + cherry-pick reflog and clean grimoire" {
  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q

  echo "ligne 1" > grimoire.txt
  git add grimoire.txt
  git commit -q -m "Grimoire initial"

  for i in 2 3 4; do
    echo "ligne $i" >> grimoire.txt
    git commit -q -am "Ajout ligne $i"
  done

  h1=$(git rev-parse HEAD)

  # Introduce a CORROMPU line (the "bug") then clean again.
  echo "CORROMPU" >> grimoire.txt
  git commit -q -am "Ligne corrompue"
  h2=$(git rev-parse HEAD)

  echo "ligne 6" >> grimoire.txt
  git commit -q -am "Ajout ligne 6"
  h3=$(git rev-parse HEAD)

  # Fix commit we will cherry-pick after bisect.
  git checkout -q -b fix
  sed -i '/CORROMPU/d' grimoire.txt
  git commit -q -am "Purifier le grimoire"
  fix_sha=$(git rev-parse HEAD)
  git checkout -q main

  # Simulate bisect traces: step 2 of the verifier counts reflog entries of
  # the form "checkout: moving from <hash> to <hash>" and needs >= 2. A plain
  # `checkout main` ends on a branch name (not a hash), so we chain at least
  # three detached checkouts to guarantee two hash→hash transitions.
  git -c advice.detachedHead=false checkout -q "$h1"
  git -c advice.detachedHead=false checkout -q "$h2"
  git -c advice.detachedHead=false checkout -q "$h3"
  git checkout -q main

  # Cherry-pick the fix onto main (cherry-pick has no -q flag).
  git cherry-pick "$fix_sha" >/dev/null

  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"4 / 4"* ]]
}

#!/usr/bin/env bats
#
# Regression tests for exercises/16-les-actions-du-royaume/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="16-les-actions-du-royaume"

build_pass_scenario() {
  mkdir -p "$TMP_DIR/work/.github/workflows"
  cd "$TMP_DIR/work"
  git init -q
  cat > .github/workflows/ci.yml <<'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
EOF
  git add .
  git commit -q -m "Add CI workflow"
  cd - >/dev/null
}

@test "quest 16: verifier passes with a minimal valid workflow" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"6 / 6"* ]]
}

@test "quest 16: fails when the workflow is missing the jobs: key" {
  build_pass_scenario
  cat > "$TMP_DIR/work/.github/workflows/ci.yml" <<'EOF'
name: CI
on: [push]
EOF
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"6 / 6"* ]]
  [[ "$output" == *"jobs:"* ]]
}

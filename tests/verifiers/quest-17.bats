#!/usr/bin/env bats
#
# Regression tests for exercises/17-les-epreuves-automatiques/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="17-les-epreuves-automatiques"

build_pass_scenario() {
  mkdir -p "$TMP_DIR/work/.github/workflows" "$TMP_DIR/work/tests"
  cd "$TMP_DIR/work"
  git init -q
  cat > .github/workflows/test.yml <<'EOF'
name: Epreuves
on: [push]
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Run tests
        run: bash tests/run.sh
EOF
  cat > tests/run.sh <<'EOF'
#!/usr/bin/env bash
echo "ok"
EOF
  chmod +x tests/run.sh
  git add .
  git commit -q -m "Setup CI matrix"
  cd - >/dev/null
}

@test "quest 17: verifier passes with matrix workflow + test script" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"5 / 5"* ]]
}

@test "quest 17: fails without a matrix strategy" {
  build_pass_scenario
  # Rewrite the workflow to drop matrix:
  cat > "$TMP_DIR/work/.github/workflows/test.yml" <<'EOF'
name: Epreuves
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
EOF
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"5 / 5"* ]]
  [[ "$output" == *"matrix"* ]]
}

@test "quest 17: fails when workflow has bare 'name:' lines but zero indented steps" {
  mkdir -p "$TMP_DIR/work/.github/workflows"
  cd "$TMP_DIR/work"
  git init -q
  cat > .github/workflows/ci.yml <<'YAML'
name: Fake Workflow
on: push
jobs:
  fake:
    runs-on: ubuntu-latest
    name: fake-job
    strategy:
      matrix:
        os: [ubuntu, macos]
YAML
  cat > test-script.sh <<'SH'
#!/usr/bin/env bash
echo ok
SH
  chmod +x test-script.sh
  git add . && git commit -q -m "fake workflow"
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  # Step 4 (multiple steps) should fail because the workflow has zero
  # indented '- name:' entries even though it has 2 bare 'name:' lines.
  [[ "$output" != *"5 / 5"* ]]
}

@test "quest 17: fails when workflow has exactly one indented step" {
  mkdir -p "$TMP_DIR/work/.github/workflows" "$TMP_DIR/work/tests"
  cd "$TMP_DIR/work"
  git init -q
  cat > .github/workflows/ci.yml <<'YAML'
name: Single Step Workflow
on: [push]
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4
YAML
  cat > tests/run.sh <<'SH'
#!/usr/bin/env bash
echo ok
SH
  chmod +x tests/run.sh
  git add . && git commit -q -m "single-step workflow"
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  # Step 4 requires at least TWO indented '- name:' entries. A workflow
  # with exactly one step should therefore fail step 4 and not reach 5/5.
  [[ "$output" != *"5 / 5"* ]]
}

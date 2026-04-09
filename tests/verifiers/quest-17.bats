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

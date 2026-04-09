#!/usr/bin/env bats
#
# Regression tests for exercises/19-les-autres-forges/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="19-les-autres-forges"

build_pass_scenario() {
  mkdir -p "$TMP_DIR/work/.github/workflows" "$TMP_DIR/work/scripts"
  cd "$TMP_DIR/work"
  git init -q

  cat > .github/workflows/ci.yml <<'EOF'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: bash scripts/test.sh
EOF

  cat > .gitlab-ci.yml <<'EOF'
test:
  script: bash scripts/test.sh
EOF

  cat > bitbucket-pipelines.yml <<'EOF'
pipelines:
  default:
    - step:
        script:
          - bash scripts/test.sh
EOF

  cat > scripts/test.sh <<'EOF'
#!/usr/bin/env bash
echo "ok"
EOF
  chmod +x scripts/test.sh

  git add .
  git commit -q -m "Setup multi-forge CI"
  cd - >/dev/null
}

@test "quest 19: verifier passes with workflows for all 3 forges + test script" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"6 / 6"* ]]
}

@test "quest 19: fails when .gitlab-ci.yml is missing" {
  build_pass_scenario
  rm "$TMP_DIR/work/.gitlab-ci.yml"
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"6 / 6"* ]]
  [[ "$output" == *"gitlab-ci"* ]]
}

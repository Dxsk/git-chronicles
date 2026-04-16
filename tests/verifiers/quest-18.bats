#!/usr/bin/env bats
#
# Regression tests for exercises/18-le-deploiement-sacre/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="18-le-deploiement-sacre"

build_pass_scenario() {
  mkdir -p "$TMP_DIR/work/.github/workflows"
  cd "$TMP_DIR/work"
  git init -q
  cat > .github/workflows/deploy.yml <<'EOF'
name: Deploy
on:
  push:
    tags:
      - 'v*'
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        run: echo "deploying to production"
EOF
  git add .
  git commit -q -m "Setup deploy workflow"
  git tag v1.0.0
  cd - >/dev/null
}

@test "quest 18: verifier passes with deploy workflow and a version tag" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"4 / 4"* ]]
}

@test "quest 18: fails without any tag" {
  build_pass_scenario
  cd "$TMP_DIR/work"
  git tag -d v1.0.0
  cd - >/dev/null
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"tag"* ]]
}

@test "quest 18: fails when deploy/production are only mentioned in comments" {
  mkdir -p "$TMP_DIR/work/.github/workflows"
  cd "$TMP_DIR/work"
  git init -q
  cat > .github/workflows/deploy.yml <<'EOF'
# This workflow will one day deploy to production.
name: Lint
on:
  push:
    branches: [main]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: echo "lint only, nothing real"
EOF
  git add .
  git commit -q -m "Add placeholder workflow"
  git tag v1.0.0
  cd - >/dev/null

  run run_verifier "$QUEST" "work"
  [[ "$output" != *"4 / 4"* ]]
  [[ "$output" == *"déploiement"* ]]
}

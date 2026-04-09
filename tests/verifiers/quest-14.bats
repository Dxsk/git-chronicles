#!/usr/bin/env bats
#
# Regression tests for exercises/14-les-outils-de-larchiviste/verifier.sh

load helpers

setup()    { tmp_setup; }
teardown() { tmp_teardown; }

QUEST="14-les-outils-de-larchiviste"

build_pass_scenario() {
  git config --global alias.st status

  mkdir -p "$TMP_DIR/work"
  cd "$TMP_DIR/work"
  git init -q
  echo "a" > a.txt && git add a.txt && git commit -q -m "Initial"

  # pre-commit hook that mentions TODO, made executable.
  cat > .git/hooks/pre-commit <<'EOF'
#!/usr/bin/env bash
# Block commits containing TODO markers.
if git diff --cached | grep -q "TODO"; then
  echo "TODO detected"
  exit 1
fi
EOF
  chmod +x .git/hooks/pre-commit

  cat > .git/hooks/commit-msg <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x .git/hooks/commit-msg

  cd - >/dev/null
}

@test "quest 14: verifier passes with alias + pre-commit + commit-msg hooks" {
  build_pass_scenario
  run run_verifier "$QUEST" "work"
  [[ "$output" == *"5 / 5"* ]]
}

@test "quest 14: fails when the pre-commit hook is missing the TODO check" {
  build_pass_scenario
  echo '#!/bin/bash' > "$TMP_DIR/work/.git/hooks/pre-commit"
  chmod +x "$TMP_DIR/work/.git/hooks/pre-commit"
  run run_verifier "$QUEST" "work"
  [[ "$output" != *"5 / 5"* ]]
  [[ "$output" == *"TODO"* ]]
}

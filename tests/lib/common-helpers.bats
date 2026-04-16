#!/usr/bin/env bats
#
# Tests for the predicate helpers added to lib/common.sh by the
# rigor-sweep work. These helpers are used by quest verifiers via
# check_step, so they must behave correctly in isolation first.

setup() {
  TMP_DIR="$(mktemp -d)"
  export TMP_DIR
  export GIT_CONFIG_GLOBAL="$TMP_DIR/.gitconfig"
  export GIT_CONFIG_SYSTEM=/dev/null
  git config --global user.email "test@git-chronicles.local"
  git config --global user.name  "Test Runner"
  git config --global init.defaultBranch main
  git config --global commit.gpgsign false

  REPO_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"
  # shellcheck source=/dev/null
  source "$REPO_ROOT/lib/common.sh"
}

teardown() {
  [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
}

# --- assert_remote_name ----------------------------------------------------

@test "assert_remote_name returns 0 when the named remote exists" {
  cd "$TMP_DIR"
  git init -q repo
  git -C repo remote add origin /tmp/dummy.git
  run assert_remote_name "$TMP_DIR/repo" "origin"
  [ "$status" -eq 0 ]
}

@test "assert_remote_name returns 1 when the named remote is missing" {
  cd "$TMP_DIR"
  git init -q repo
  git -C repo remote add origine /tmp/dummy.git
  run assert_remote_name "$TMP_DIR/repo" "origin"
  [ "$status" -eq 1 ]
}

@test "assert_remote_name returns 1 when the path is not a git repo" {
  mkdir -p "$TMP_DIR/not-a-repo"
  run assert_remote_name "$TMP_DIR/not-a-repo" "origin"
  [ "$status" -eq 1 ]
}

# --- assert_branch_is ------------------------------------------------------

@test "assert_branch_is returns 0 when the current branch matches" {
  cd "$TMP_DIR"
  git init -q repo
  ( cd repo && echo a > a.txt && git add a.txt && git commit -q -m "init" )
  run assert_branch_is "$TMP_DIR/repo" "main"
  [ "$status" -eq 0 ]
}

@test "assert_branch_is returns 1 when the current branch differs" {
  cd "$TMP_DIR"
  git init -q repo
  ( cd repo && echo a > a.txt && git add a.txt && git commit -q -m "init" \
    && git branch -m main master )
  run assert_branch_is "$TMP_DIR/repo" "main"
  [ "$status" -eq 1 ]
}

@test "assert_branch_is returns 1 on a non-repo path" {
  mkdir -p "$TMP_DIR/not-a-repo"
  run assert_branch_is "$TMP_DIR/not-a-repo" "main"
  [ "$status" -eq 1 ]
}

# --- assert_file_contains --------------------------------------------------

@test "assert_file_contains returns 0 when pattern matches" {
  echo "hello world" > "$TMP_DIR/f.txt"
  run assert_file_contains "$TMP_DIR/f.txt" "hello"
  [ "$status" -eq 0 ]
}

@test "assert_file_contains returns 1 when pattern is missing" {
  echo "hello world" > "$TMP_DIR/f.txt"
  run assert_file_contains "$TMP_DIR/f.txt" "goodbye"
  [ "$status" -eq 1 ]
}

@test "assert_file_contains returns 1 when file does not exist" {
  run assert_file_contains "$TMP_DIR/missing.txt" "anything"
  [ "$status" -eq 1 ]
}

# --- assert_same_head ------------------------------------------------------

@test "assert_same_head returns 0 when all repos share the same HEAD" {
  cd "$TMP_DIR"
  git init -q a
  ( cd a && echo x > x.txt && git add x.txt && git commit -q -m "init" )
  git clone -q a b
  git clone -q a c
  run assert_same_head "$TMP_DIR/a" "$TMP_DIR/b" "$TMP_DIR/c"
  [ "$status" -eq 0 ]
}

@test "assert_same_head returns 1 when one repo diverges" {
  cd "$TMP_DIR"
  git init -q a
  ( cd a && echo x > x.txt && git add x.txt && git commit -q -m "init" )
  git clone -q a b
  ( cd b && echo y > y.txt && git add y.txt && git commit -q -m "diverge" )
  run assert_same_head "$TMP_DIR/a" "$TMP_DIR/b"
  [ "$status" -eq 1 ]
}

@test "assert_same_head returns 1 when one path is not a git repo" {
  cd "$TMP_DIR"
  git init -q a
  ( cd a && echo x > x.txt && git add x.txt && git commit -q -m "init" )
  mkdir -p b
  run assert_same_head "$TMP_DIR/a" "$TMP_DIR/b"
  [ "$status" -eq 1 ]
}

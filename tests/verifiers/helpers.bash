# Shared helpers for bats verifier tests.
#
# Each test builds an isolated scenario in a temp dir, runs the quest verifier
# against it, and asserts on exit code / output.
#
# Usage from a .bats file:
#   load helpers
#   setup()    { tmp_setup; }
#   teardown() { tmp_teardown; }

# Resolve the repository root once (tests/verifiers -> repo).
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_ROOT

tmp_setup() {
  TMP_DIR="$(mktemp -d)"
  export TMP_DIR
  # Prevent the user's global git config from interfering.
  export GIT_CONFIG_GLOBAL="$TMP_DIR/.gitconfig"
  export GIT_CONFIG_SYSTEM=/dev/null
  git config --global user.email "test@git-chronicles.local"
  git config --global user.name  "Test Runner"
  git config --global init.defaultBranch main
  git config --global commit.gpgsign false
}

tmp_teardown() {
  [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"
}

# Run a quest verifier from inside a working dir.
# Args: <quest-dir-name> <working-subdir> [extra verifier args...]
run_verifier() {
  local quest="$1"; shift
  local workdir="$1"; shift
  ( cd "$TMP_DIR/$workdir" && bash "$REPO_ROOT/exercises/$quest/verifier.sh" "$@" )
}

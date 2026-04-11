#!/usr/bin/env bash
#
# Lint src/**/*.njk for forbidden git command patterns.
#
# This is a regression-prevention linter. Each pattern below corresponds to a
# bug that was fixed in the rigor sweep and should never be reintroduced in
# user-facing course content. Matches inside bash comments ('# ...') are
# ignored so pedagogical counter-examples (e.g. 'Instead of "git checkout
# main"') stay valid.

set -u

echo "▶ Running lint-content…"

fail=0

# -----------------------------------------------------------------------------
# Pattern 1 : 'origine' used as a git remote name (francization typo).
# Matches the token form: git (remote add|push|pull|fetch|clone) origine
# Any non-token use of the French word 'origine' in prose is left alone.
# -----------------------------------------------------------------------------
hits_origine=$(grep -rnE --include='*.njk' \
    'git[[:space:]]+(remote[[:space:]]+add|push|pull|fetch|clone)[[:space:]]+origine' \
    src/ 2>/dev/null | grep -v '#.*origine' || true)

if [ -n "$hits_origine" ]; then
    echo "$hits_origine"
    echo "✗ lint-content: 'origine' used as a git remote name (should be 'origin')" >&2
    fail=1
fi

# -----------------------------------------------------------------------------
# Pattern 2 : 'git checkout <branch>' in a code block.
# Since Git 2.23, 'git switch' is the preferred way to change branches and
# 'git switch -c' replaces 'git checkout -b'. Quest 06 explicitly teaches
# this, so no other quest should contradict it by using the legacy form.
#
# Filters applied:
#   * Matches inside bash comments ('# ...') are ignored so pedagogical
#     counter-examples (e.g. 'Instead of "git checkout main"') stay valid.
#   * Version tag checkouts ('git checkout v1.2.3') are allowed because
#     'git switch' cannot detach onto a tag without --detach. Quest 18
#     (le-deploiement-sacre) uses this form legitimately.
#   * Quest 06 files are allow-listed entirely: the quest intentionally
#     shows both 'git switch' (modern) and 'git checkout' (legacy) side by
#     side to teach the historical context.
#   * File-restore form ('git checkout -- <path>') is NOT matched because
#     its first argument starts with '--', which is rejected by the regex
#     requiring a word-character first char. That form is the job of
#     'git restore', but that is a separate sweep.
# -----------------------------------------------------------------------------
hits_checkout=$(grep -rnE --include='*.njk' \
    'git[[:space:]]+checkout[[:space:]]+(-[bB][[:space:]]+)?[a-zA-Z0-9._][a-zA-Z0-9._-]*' \
    src/ 2>/dev/null \
    | grep -vE '#.*git[[:space:]]+checkout' \
    | grep -vE 'git[[:space:]]+checkout[[:space:]]+v[0-9]' \
    | grep -vE '/06-larbre-des-possibles\.njk:' \
    | grep -vE '/06-the-tree-of-possibilities\.njk:' \
    || true)

if [ -n "$hits_checkout" ]; then
    echo "$hits_checkout"
    echo "✗ lint-content: 'git checkout <branch>' in code (prefer 'git switch')" >&2
    fail=1
fi

if [ "$fail" -eq 0 ]; then
    echo "✓ lint-content: clean."
fi

exit "$fail"

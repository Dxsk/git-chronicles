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
# Pattern 2 : 'git checkout main/master' in a code block.
# Since Git 2.23, 'git switch' is the preferred way to change branches. Quest
# 06 teaches this, so later quests should not contradict it by using the
# legacy form in their code blocks. Matches that are commented out ('# ...')
# are ignored so counter-example sentences remain valid.
# -----------------------------------------------------------------------------
hits_checkout=$(grep -rnE --include='*.njk' \
    'git[[:space:]]+checkout[[:space:]]+(main|master)' \
    src/ 2>/dev/null | grep -vE '#.*git[[:space:]]+checkout' || true)

if [ -n "$hits_checkout" ]; then
    echo "$hits_checkout"
    echo "✗ lint-content: 'git checkout main/master' in code (prefer 'git switch')" >&2
    fail=1
fi

if [ "$fail" -eq 0 ]; then
    echo "✓ lint-content: clean."
fi

exit "$fail"

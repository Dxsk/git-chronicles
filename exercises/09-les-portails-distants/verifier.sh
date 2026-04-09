#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 09 - Les Portails Distants - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"

# The check_step DSL from lib/common.sh receives test expressions
# as single-quoted strings and evaluates them later. Single quotes
# are intentional here, not a bug.
# shellcheck disable=SC2016
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 09 - Les Portails Distants"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Au moins un remote est configuré ----
check_step 2 "Au moins un remote est configuré" \
    '[ "$(git remote | wc -l)" -ge 1 ]'

# ---- Step 3 : Un push a été effectué (vérifie les refs de suivi distant) ----
check_step 3 "Tu as poussé au moins une fois vers un remote" \
    'git for-each-ref refs/remotes --format="%(refname)" 2>/dev/null | grep -q . || \
     git reflog show --all 2>/dev/null | grep -q "push"'

# ---- Step 4 : Un fetch ou pull a été effectué ----
check_step 4 "Tu as récupéré des changements depuis un remote" \
    '[ "$(git reflog show --all 2>/dev/null | grep -c "fetch\|pull")" -ge 1 ] || \
     [ "$(git log --all --oneline 2>/dev/null | wc -l)" -gt "$(git log --oneline 2>/dev/null | wc -l)" ]'

show_score

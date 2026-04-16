#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 11 - Le Tisseur de Temps - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 11 - Le Tisseur de Temps"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Au moins 2 branches existent ----
check_step 2 "Au moins 2 branches existent" \
    '[ "$(git branch -a 2>/dev/null | wc -l)" -ge 2 ]'

# ---- Step 3 : La pile de stash est vide (stash appliqué ou dépilé) ----
# Note: once git stash pop empties the stash stack, refs/stash is deleted,
# so there is no durable reflog evidence of past stash activity. We can
# only check the terminal state: nothing pending.
check_step 3 "Aucun stash en attente (le tissage du temps est complet)" \
    '[ -z "$(git stash list 2>/dev/null)" ]'

# ---- Step 4 : Au moins 3 commits existent ----
check_step 4 "Il y a au moins 3 commits dans l'historique" \
    '[ "$(git log --all --oneline 2>/dev/null | wc -l)" -ge 3 ]'

# ---- Step 5 : Retour sur main ----
check_step 5 "Tu es de retour sur la branche main" \
    'assert_branch_is . main'

show_score

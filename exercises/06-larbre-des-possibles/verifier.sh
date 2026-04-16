#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 06 - L'Arbre des Possibles - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 06 - L'Arbre des Possibles"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : La branche expedition-nord existe ----
check_step 2 "La branche expedition-nord existe" \
    'git branch --list expedition-nord | grep -q expedition-nord'

# ---- Step 3 : La branche expedition-sud existe ----
check_step 3 "La branche expedition-sud existe" \
    'git branch --list expedition-sud | grep -q expedition-sud'

# ---- Step 4 : expedition-nord a au moins un commit propre ----
check_step 4 "La branche expedition-nord contient un commit propre" \
    '[ "$(git log main..expedition-nord --oneline 2>/dev/null | wc -l)" -ge 1 ]'

# ---- Step 5 : expedition-sud a au moins un commit propre ----
check_step 5 "La branche expedition-sud contient un commit propre" \
    '[ "$(git log main..expedition-sud --oneline 2>/dev/null | wc -l)" -ge 1 ]'

# ---- Step 6 : Au moins 3 branches au total ----
check_step 6 "Il y a au moins 3 branches" \
    '[ "$(git branch | wc -l)" -ge 3 ]'

# ---- Step 7 : De retour sur main ----
check_step 7 "Tu es de retour sur la branche main" \
    'assert_branch_is . main'

show_score

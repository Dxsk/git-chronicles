#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 10 - Le Protocole des Guildes - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 10 - Le Protocole des Guildes"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : La branche main/master existe ----
check_step 2 "La branche principale (main ou master) existe" \
    'git branch --list main master | grep -qE "main|master"'

# ---- Step 3 : Au moins 3 commits au total ----
check_step 3 "Il y a au moins 3 commits dans l'historique" \
    '[ "$(git log --oneline 2>/dev/null | wc -l)" -ge 3 ]'

# ---- Step 4 : Un commit de merge existe (preuve du --no-ff) ----
check_step 4 "Un commit de merge existe (Protocole respecté)" \
    'git log --merges --oneline 2>/dev/null | grep -q .'

# ---- Step 5 : Pas de branche de proposition restante (nettoyée) ----
check_step 5 "La branche de proposition a été nettoyée" \
    '[ "$(git branch | grep -v "main\|master\|\*" | wc -l)" -eq 0 ]'

# ---- Step 6 : Retour sur la branche principale ----
check_step 6 "Tu es de retour sur la branche principale" \
    'assert_branch_is . main || assert_branch_is . master'

show_score

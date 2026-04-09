#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 12 - L'Oracle du Code - Verification script
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

QUEST_TITLE="Quête 12 - L'Oracle du Code"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : git bisect a été utilisé ----
# bisect laisse des traces : soit dans le reflog (checkouts multiples entre
# hashes détachés), soit via le fichier BISECT_LOG, soit au moins 3 checkouts
# vers des commits détachés (typique d'une recherche binaire).
check_step 2 "git bisect a été utilisé (trace dans le reflog)" \
    '[ "$(git reflog | grep -c "checkout: moving from [0-9a-f]\{7,\} to [0-9a-f]\{7,\}")" -ge 2 ]'

# ---- Step 3 : git cherry-pick a été utilisé (trace dans le reflog) ----
check_step 3 "git cherry-pick a été utilisé (trace dans le reflog)" \
    'git reflog | grep -q "cherry-pick"'

# ---- Step 4 : Le grimoire ne contient plus le mot CORROMPU ----
check_step 4 "Le grimoire ne contient plus le mot CORROMPU" \
    '! grep -q "CORROMPU" grimoire.txt 2>/dev/null'

show_score

#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 07 - Le Conflit des Royaumes - Verification script
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

QUEST_TITLE="Quête 07 - Le Conflit des Royaumes"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Un commit de merge existe dans l'historique ----
check_step 2 "Un merge a été effectué (commit de merge présent)" \
    '[ "$(git rev-list --merges --count HEAD)" -ge 1 ]'

# ---- Step 3 : Pas de marqueurs de conflit dans les fichiers trackés ----
check_step 3 "Aucun marqueur de conflit ne reste dans les fichiers" \
    '! git grep -l "^<<<<<<< \|^=======$\|^>>>>>>> " -- ":(exclude)verifier.sh" ":(exclude)verifier.ps1" ":(exclude)*.md" 2>/dev/null'

# ---- Step 4 : Pas de merge en cours (pas de MERGE_HEAD) ----
check_step 4 "Aucun merge n'est en cours (pas de conflit non résolu)" \
    '[ ! -f "$(git rev-parse --git-dir)/MERGE_HEAD" ]'

# ---- Step 5 : Le commit de merge a un message descriptif ----
check_step 5 "Le dernier commit de merge a un message descriptif (>= 10 caractères)" \
    '[ "$(git log --merges -1 --format=%s | wc -c)" -ge 10 ]'

show_score

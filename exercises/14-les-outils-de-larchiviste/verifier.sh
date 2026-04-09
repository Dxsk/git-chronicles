#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 14 - Les Outils de l'Archiviste - Verification script
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

QUEST_TITLE="Quête 14 - Les Outils de l'Archiviste"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Au moins un alias est configuré ----
check_step 2 "Au moins un alias Git est configuré" \
    'git config --get-regexp alias 2>/dev/null | grep -q .'

# ---- Step 3 : Le hook pre-commit existe et est exécutable ----
check_step 3 "Le hook pre-commit existe et est exécutable" \
    '[ -x "$(git rev-parse --git-dir)/hooks/pre-commit" ]'

# ---- Step 4 : Le hook pre-commit fonctionne (détecte les TODO) ----
check_step 4 "Le hook pre-commit détecte les TODO dans les fichiers" \
    'grep -q "TODO" "$(git rev-parse --git-dir)/hooks/pre-commit"'

# ---- Step 5 : Le hook commit-msg existe et est exécutable ----
check_step 5 "Le hook commit-msg existe et est exécutable" \
    '[ -x "$(git rev-parse --git-dir)/hooks/commit-msg" ]'

show_score

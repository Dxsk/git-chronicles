#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 17 - Les Épreuves Automatiques - Verification script
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

QUEST_TITLE="Quête 17 - Les Épreuves Automatiques"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Le dossier .github/workflows existe ----
check_step 2 "Le dossier .github/workflows existe" \
    '[ -d ".github/workflows" ]'

# ---- Step 3 : Un workflow YAML contient une stratégie de matrice ----
check_step 3 "Un workflow contient une stratégie de matrice (matrix)" \
    'grep -rl "matrix:" .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null | grep -q .'

# ---- Step 4 : Le workflow contient plusieurs étapes (steps) ----
check_step 4 "Le workflow contient plusieurs étapes (steps)" \
    'fichier=$(ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null | head -1) && [ -n "$fichier" ] && [ "$(grep -c "name:" "$fichier")" -ge 2 ]'

# ---- Step 5 : Au moins un script de test existe ----
check_step 5 "Au moins un script de test existe" \
    'ls test-*.sh test-*.bash tests/*.sh tests/*.bash 2>/dev/null | grep -q .'

show_score

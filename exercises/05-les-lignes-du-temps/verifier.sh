#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 05 - Les Lignes du Temps - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 05 - Les Lignes du Temps"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Le .gitignore existe ----
check_step 2 "Le fichier .gitignore existe" \
    '[ -f .gitignore ]'

# ---- Step 3 : Le .gitignore contient un pattern pour les .log ----
check_step 3 "Le .gitignore ignore les fichiers .log" \
    'grep -qE "^\*\.log$|^debug\.log$" .gitignore'

# ---- Step 4 : debug.log n'est plus tracké ----
check_step 4 "debug.log n'est plus suivi par Git" \
    '! git ls-files --error-unmatch debug.log 2>/dev/null'

# ---- Step 5 : Le dernier commit a un message d'au moins 10 caractères ----
check_step 5 "Le dernier commit a un message descriptif (≥ 10 caractères)" \
    '[ "$(git log -1 --format=%s | wc -c)" -ge 10 ]'

show_score

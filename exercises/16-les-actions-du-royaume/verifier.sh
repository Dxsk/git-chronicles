#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 16 - Les Actions du Royaume - Verification script
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

QUEST_TITLE="Quête 16 - Les Actions du Royaume"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Le dossier .github/workflows existe ----
check_step 2 "Le dossier .github/workflows existe" \
    '[ -d ".github/workflows" ]'

# ---- Step 3 : Au moins un fichier .yml existe dans .github/workflows ----
check_step 3 "Au moins un fichier .yml existe dans .github/workflows" \
    'ls .github/workflows/*.yml 1>/dev/null 2>&1 || ls .github/workflows/*.yaml 1>/dev/null 2>&1'

# ---- Step 4 : Le fichier YAML contient le mot-clé "name:" ----
check_step 4 "Le workflow contient le mot-clé 'name:'" \
    'grep -rq "^name:" .github/workflows/*.yml 2>/dev/null || grep -rq "^name:" .github/workflows/*.yaml 2>/dev/null'

# ---- Step 5 : Le fichier YAML contient le mot-clé "on:" ----
check_step 5 "Le workflow contient le mot-clé 'on:'" \
    'grep -rq "^on:" .github/workflows/*.yml 2>/dev/null || grep -rq "^on:" .github/workflows/*.yaml 2>/dev/null'

# ---- Step 6 : Le fichier YAML contient le mot-clé "jobs:" ----
check_step 6 "Le workflow contient le mot-clé 'jobs:'" \
    'grep -rq "^jobs:" .github/workflows/*.yml 2>/dev/null || grep -rq "^jobs:" .github/workflows/*.yaml 2>/dev/null'

show_score

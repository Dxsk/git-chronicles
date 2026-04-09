#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 19 - Les Autres Forges - Verification script
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

QUEST_TITLE="Quête 19 - Les Autres Forges"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Le fichier GitHub Actions existe ----
check_step 2 "Le fichier .github/workflows/ci.yml existe" \
    'ls .github/workflows/*.yml >/dev/null 2>&1'

# ---- Step 3 : Le fichier GitLab CI existe ----
check_step 3 "Le fichier .gitlab-ci.yml existe" \
    '[ -f ".gitlab-ci.yml" ]'

# ---- Step 4 : Le fichier Bitbucket Pipelines existe ----
check_step 4 "Le fichier bitbucket-pipelines.yml existe" \
    '[ -f "bitbucket-pipelines.yml" ]'

# ---- Step 5 : Le script de test existe ----
check_step 5 "Le script de test scripts/test.sh existe" \
    '[ -f "scripts/test.sh" ]'

# ---- Step 6 : Au moins un commit a été créé ----
check_step 6 "Au moins un commit a été créé" \
    'git log --oneline -1 >/dev/null 2>&1'

show_score

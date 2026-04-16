#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 18 - Le Déploiement Sacré - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 18 - Le Déploiement Sacré"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Le dossier .github/workflows existe avec au moins un fichier YAML ----
check_step 2 "Un dossier .github/workflows existe avec un workflow" \
    'ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null | grep -q .'

# ---- Step 3 : Le workflow mentionne le déploiement hors commentaires ----
# Strip comment-only lines before matching so a placeholder workflow
# with "# TODO: deploy to production" at the top does not pass.
check_step 3 "Le workflow mentionne le déploiement (production ou deploy)" \
    '
    find .github/workflows -type f \( -name "*.yml" -o -name "*.yaml" \) \
        -exec grep -hvE "^[[:space:]]*#" {} + 2>/dev/null \
        | grep -qE "(deploy|production)"
    '

# ---- Step 4 : Au moins un tag existe ----
check_step 4 "Au moins un tag de version existe" \
    '[ "$(git tag | wc -l)" -ge 1 ]'

show_score

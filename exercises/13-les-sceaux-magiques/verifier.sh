#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 13 - Les Sceaux Magiques - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 13 - Les Sceaux Magiques"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Au moins 2 tags existent ----
check_step 2 "Au moins 2 tags existent" \
    '[ "$(git tag | wc -l)" -ge 2 ]'

# ---- Step 3 : Au moins un tag annoté existe ----
check_step 3 "Au moins un tag annoté existe" \
    'found=false; for t in $(git tag); do if [ "$(git cat-file -t "$t" 2>/dev/null)" = "tag" ]; then found=true; break; fi; done; $found'

# ---- Step 4 : Les tags suivent le format de versionnage (v*) ----
check_step 4 "Les tags suivent le format de versionnage (v*)" \
    'git tag | grep -qE "^v[0-9]+\.[0-9]+\.[0-9]+$"'

show_score

#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 15 - Les Forges Éternelles - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 15 - Les Forges Éternelles"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Au moins un remote est configuré ----
check_step 2 "Au moins un remote est configuré" \
    'git remote 2>/dev/null | grep -q .'

# ---- Step 3 : Au moins un push a été effectué ----
check_step 3 "Au moins un push a été effectué (des refs distantes existent)" \
    'git branch -r 2>/dev/null | grep -q .'

# ---- Step 4 : Au moins 3 commits dans le dépôt ----
check_step 4 "Le dépôt contient au moins 3 commits" \
    '[ "$(git rev-list --count HEAD 2>/dev/null)" -ge 3 ]'

show_score

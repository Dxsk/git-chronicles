#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 11 - Le Tisseur de Temps - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 11 - Le Tisseur de Temps"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Au moins 2 branches existent ----
check_step 2 "Au moins 2 branches existent" \
    '[ "$(git branch -a 2>/dev/null | wc -l)" -ge 2 ]'

# ---- Step 3 : Le reflog montre une activité de stash ----
check_step 3 "Le reflog montre une activité de stash" \
    'git reflog show stash 2>/dev/null | grep -q . || git log -g refs/stash --oneline 2>/dev/null | grep -q . || git reflog 2>/dev/null | grep -qi stash'

# ---- Step 4 : Au moins 3 commits existent ----
check_step 4 "Il y a au moins 3 commits dans l'historique" \
    '[ "$(git log --all --oneline 2>/dev/null | wc -l)" -ge 3 ]'

show_score

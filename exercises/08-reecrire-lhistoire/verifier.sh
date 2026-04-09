#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 08 - Réécrire l'Histoire - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 08 - Réécrire l'Histoire"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Le reflog contient un amend ----
check_step 2 "Tu as utilisé git commit --amend (visible dans le reflog)" \
    'git reflog | grep -qi "amend"'

# ---- Step 3 : Le reflog contient un rebase ----
check_step 3 "Tu as effectué un rebase (visible dans le reflog)" \
    'git reflog | grep -qi "rebase"'

# ---- Step 4 : Au moins 3 commits existent ----
check_step 4 "Au moins 3 commits existent dans l'historique" \
    '[ "$(git rev-list --count HEAD)" -ge 3 ]'

show_score

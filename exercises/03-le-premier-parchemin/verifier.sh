#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 03 - Le Premier Parchemin - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
#
# Usage   : Run FROM the directory mon-archive/
#           bash ../verifier.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 03 - Le Premier Parchemin"
show_banner "$QUEST_TITLE"

# --- Step 1 : On est dans un dépôt git ---
check_step 1 "Tu es dans un dépôt Git" \
    'check_in_repo'

# --- Step 2 : Au moins 2 commits ---
check_step 2 "Tu as au moins 2 commits" \
    '[ "$(git rev-list --count HEAD 2>/dev/null)" -ge 2 ]'

# --- Step 3 : mission.txt est tracké ---
check_step 3 "Le fichier mission.txt est suivi par Git" \
    'git ls-files --error-unmatch mission.txt'

# --- Step 4 : Le premier message de commit n'est pas générique ---
check_step 4 "Ton premier commit a un message personnalisé" \
    '
    premier_msg="$(git log --reverse --format=%s | head -n1)"
    [ -n "$premier_msg" ] \
        && [ "$premier_msg" != "Initial commit" ] \
        && [ "$premier_msg" != "initial commit" ] \
        && [ "$premier_msg" != "first commit" ] \
        && [ "$premier_msg" != "init" ]
    '

# --- Step 5 : mission.txt a été modifié depuis le parchemin fourni ---
check_step 5 "Tu as complété le parchemin (mission.txt diffère du modèle fourni)" \
    '! cmp -s mission.txt "$SCRIPT_DIR/parchemins/mission.txt"'

show_score

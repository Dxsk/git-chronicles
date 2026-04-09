#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 01 - La Guilde des Archivistes - Verification script
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

QUEST_TITLE="Quête 01 - La Guilde des Archivistes"
show_banner "$QUEST_TITLE"

check_step 1 "Git est installé" 'command -v git >/dev/null 2>&1'
check_step 2 "Ton nom est configuré" '[ -n "$(git config --global user.name)" ]'
check_step 3 "Ton email est configuré" '[ -n "$(git config --global user.email)" ]'

show_score

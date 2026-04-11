#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quete 04 - L'Archive est Partout - Script de verification
# Project : Git Chronicles (Les Chroniques du Versionneur)
#
# Usage   : bash verifier.sh [parent_directory_path]
#           If no path is provided, uses the current directory.
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quete 04 - L'Archive est Partout"
show_banner "$QUEST_TITLE"

# Working directory: parameter or current directory
WORKDIR="${1:-.}"
WORKDIR="$(cd "$WORKDIR" 2>/dev/null && pwd)" || {
    printf "%sErreur : the directory '%s' n'existe pas.%s\n" \
        "${CLR_ROUGE}" "$1" "${CLR_RESET}" >&2
    exit 1
}

printf "  %sDossier analyse : %s%s\n\n" "${CLR_CYAN}" "$WORKDIR" "${CLR_RESET}"

show_section "Setup des depots"

# ---- Step 1 : ma-copie/ existe et c'est un repo git ----
check_step 1 "ma-copie/ existe et c'est un repo Git" \
    '[ -d "$WORKDIR/ma-copie/.git" ]'

# ---- Step 2 : ma-copie/ a une remote nommee 'origin' ----
check_step 2 "ma-copie/ a une remote nommee 'origin'" \
    'assert_remote_name "$WORKDIR/ma-copie" "origin"'

# ---- Step 3 : ma-copie/ est sur la branche 'main' ----
check_step 3 "ma-copie/ est sur la branche 'main'" \
    'assert_branch_is "$WORKDIR/ma-copie" "main"'

show_section "Depot central (bare)"

# ---- Step 4 : archive-centrale.git/ est un bare repo ----
check_step 4 "archive-centrale.git/ existe et c'est un bare repo" \
    '[ -f "$WORKDIR/archive-centrale.git/HEAD" ] && \
     [ -d "$WORKDIR/archive-centrale.git/objects" ] && \
     [ -d "$WORKDIR/archive-centrale.git/refs" ] && \
     ! [ -d "$WORKDIR/archive-centrale.git/.git" ]'

# ---- Step 5 : archive-centrale.git/HEAD pointe vers main ----
check_step 5 "archive-centrale.git/ pointe HEAD vers main" \
    '[ "$(cat "$WORKDIR/archive-centrale.git/HEAD" 2>/dev/null)" = "ref: refs/heads/main" ]'

show_section "Clone depuis le bare"

# ---- Step 6 : clone-depuis-bare/ existe et c'est un repo git ----
check_step 6 "clone-depuis-bare/ existe et c'est un repo Git" \
    '[ -d "$WORKDIR/clone-depuis-bare/.git" ]'

# ---- Step 7 : clone-depuis-bare/ est sur la branche 'main' ----
check_step 7 "clone-depuis-bare/ est sur la branche 'main'" \
    'assert_branch_is "$WORKDIR/clone-depuis-bare" "main"'

# ---- Step 8 : clone-depuis-bare/ a une remote nommee 'origin' ----
check_step 8 "clone-depuis-bare/ a une remote nommee 'origin'" \
    'assert_remote_name "$WORKDIR/clone-depuis-bare" "origin"'

show_section "Coherence inter-depots"

# ---- Step 9 : Les trois depots partagent le meme HEAD ----
check_step 9 "Les trois depots partagent le meme HEAD" \
    'assert_same_head "$WORKDIR/ma-copie" "$WORKDIR/clone-depuis-bare"'

show_score

#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# Quete 04 - L'Archive est Partout - Script de verification
# Project : Git Chronicles (Les Chroniques du Versionneur)
#
# Usage   : bash verifier.sh [parent_directory_path]
#           If no path is provided, uses the current directory.
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

# ---- Step 1 : ma-copie/ existe et c'est un repo git ----
check_step 1 "ma-copie/ existe et c'est un repo Git" \
    '[ -d "$WORKDIR/ma-copie/.git" ]'

# ---- Step 2 : ma-copie a une remote origin pointant vers un chemin local ----
check_step 2 "ma-copie/ a une remote origin vers un chemin local" \
    'grep -q "url = " "$WORKDIR/ma-copie/.git/config" 2>/dev/null && \
     ! grep "url = http" "$WORKDIR/ma-copie/.git/config" >/dev/null 2>&1 && \
     ! grep "url = git@" "$WORKDIR/ma-copie/.git/config" >/dev/null 2>&1'

# ---- Step 3 : archive-centrale.git/ est un bare repo ----
check_step 3 "archive-centrale.git/ existe et c'est un bare repo" \
    '[ -f "$WORKDIR/archive-centrale.git/HEAD" ] && \
     [ -d "$WORKDIR/archive-centrale.git/objects" ] && \
     [ -d "$WORKDIR/archive-centrale.git/refs" ] && \
     ! [ -d "$WORKDIR/archive-centrale.git/.git" ]'

# ---- Step 4 : clone-depuis-bare/ existe et c'est un repo git ----
check_step 4 "clone-depuis-bare/ existe et c'est un repo Git" \
    '[ -d "$WORKDIR/clone-depuis-bare/.git" ]'

show_score

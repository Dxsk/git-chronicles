#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 12 - L'Oracle du Code - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 12 - L'Oracle du Code"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : git bisect a été utilisé ----
# bisect laisse des traces : soit dans le reflog (checkouts multiples entre
# hashes détachés), soit via le fichier BISECT_LOG, soit au moins 3 checkouts
# vers des commits détachés (typique d'une recherche binaire).
check_step 2 "git bisect a été utilisé (trace dans le reflog)" \
    '[ "$(git reflog | grep -c "checkout: moving from [0-9a-f]\{7,\} to [0-9a-f]\{7,\}")" -ge 2 ]'

# ---- Step 3 : Le commit de la branche correctif est présent sur HEAD ----
# State-based check: the student must have cherry-picked the fix commit
# from origin/correctif (or a local 'correctif' branch in the test harness).
# Cherry-pick copies the subject line, so HEAD's log contains an entry
# whose subject matches the correctif tip. A manual edit with a
# different commit message cannot satisfy this check.
check_step 3 "Le commit de la branche correctif a été appliqué (cherry-pick)" \
    '
    (
        fix_ref=""
        for candidate in origin/correctif correctif refs/remotes/origin/correctif; do
            if git rev-parse --verify --quiet "$candidate" >/dev/null 2>&1; then
                fix_ref="$candidate"
                break
            fi
        done
        [ -n "$fix_ref" ] || exit 1
        fix_subject="$(git log -1 --format=%s "$fix_ref")"
        [ -n "$fix_subject" ] || exit 1
        git log HEAD --format=%s | grep -qF -- "$fix_subject"
    )
    '

# ---- Step 4 : Le grimoire ne contient plus le mot CORROMPU ----
check_step 4 "Le grimoire ne contient plus le mot CORROMPU" \
    '! grep -q "CORROMPU" grimoire.txt 2>/dev/null'

show_score

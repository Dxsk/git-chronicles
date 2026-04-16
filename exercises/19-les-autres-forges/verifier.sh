#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 19 - Les Autres Forges - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 19 - Les Autres Forges"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Le fichier GitHub Actions existe et déclare au moins un job
# Wrapped in a subshell so the loop-internal 'exit' only returns from the
# check, not from the verifier as a whole.
check_step 2 "Le fichier .github/workflows/*.yml déclare un 'jobs:'" \
    '
    (
        for f in .github/workflows/*.yml .github/workflows/*.yaml; do
            [ -f "$f" ] && assert_file_contains "$f" "^jobs:" && exit 0
        done
        exit 1
    )
    '

# ---- Step 3 : Le fichier GitLab CI existe et définit au moins un job
check_step 3 "Le fichier .gitlab-ci.yml définit au moins un job (script:)" \
    'assert_file_contains ".gitlab-ci.yml" "^[[:space:]]*script:"'

# ---- Step 4 : Le fichier Bitbucket Pipelines existe et déclare 'pipelines:'
check_step 4 "Le fichier bitbucket-pipelines.yml déclare 'pipelines:'" \
    'assert_file_contains "bitbucket-pipelines.yml" "^pipelines:"'

# ---- Step 5 : Le script de test existe ----
check_step 5 "Le script de test scripts/test.sh existe" \
    '[ -f "scripts/test.sh" ]'

# ---- Step 6 : Au moins un commit a été créé ----
check_step 6 "Au moins un commit a été créé" \
    'git log --oneline -1 >/dev/null 2>&1'

show_score

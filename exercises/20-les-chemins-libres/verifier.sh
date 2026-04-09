#!/usr/bin/env bash

# The check_step DSL (see lib/common.sh) receives test expressions as
# single-quoted strings and evaluates them later. Single quotes are
# deliberate in this file, not a bug.
# shellcheck disable=SC2016
# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 20 - Les Chemins Libres - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=SCRIPTDIR/../../lib/common.sh
source "$SCRIPT_DIR/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

QUEST_TITLE="Quête 20 - Les Chemins Libres"
show_banner "$QUEST_TITLE"

# ---- Step 1 : Est-on dans un dépôt Git ? ----
check_step 1 "Tu es dans un dépôt Git" \
    'git rev-parse --is-inside-work-tree'

# ---- Step 2 : Le fichier mon-parcours.txt existe ----
check_step 2 "Le fichier mon-parcours.txt existe" \
    '[ -f "mon-parcours.txt" ]'

# ---- Step 3 : Le fichier est suivi par Git ----
check_step 3 "Le fichier mon-parcours.txt est suivi par Git" \
    'git ls-files --error-unmatch mon-parcours.txt'

# ---- Step 4 : Au moins un commit a été créé ----
check_step 4 "Au moins un commit a été créé" \
    'git log --oneline -1 >/dev/null 2>&1'

# ---- Step 5 : Au moins un tag existe ----
check_step 5 "Au moins un tag existe" \
    '[ -n "$(git tag -l)" ]'

show_score

# Message spécial si toutes les étapes sont validées
if [[ "${SCORE}" -eq "${TOTAL}" ]] && [[ "${TOTAL}" -gt 0 ]]; then
    cat << 'FINALE'

    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║        ⚔️  MAÎTRE VERSIONNEUR  ⚔️                            ║
    ║                                                              ║
    ║           /\                                                 ║
    ║          /  \       Tu as complété les 20 quêtes             ║
    ║         / ⭐ \      des Chroniques du Versionneur.           ║
    ║        /______\                                              ║
    ║       /\      /\    Tu maîtrises :                           ║
    ║      /  \    /  \     - Les fondations de Git                ║
    ║     / ⭐ \  / ⭐ \    - La collaboration                     ║
    ║    /______\/______\   - Les arts avancés                     ║
    ║   /\      /\      /\  - Les forges automatiques              ║
    ║  /  \    /  \    /  \  - Les chemins libres                  ║
    ║ / ⭐ \  / ⭐ \  / ⭐ \                                       ║
    ║/______\/______\/______\                                      ║
    ║                                                              ║
    ║  « Gardien des chroniques du royaume, maître des branches    ║
    ║    et des fusions, tisseur du temps, forgeron des pipelines  ║
    ║    éternels, et marcheur des chemins libres. »               ║
    ║                                                              ║
    ║            Que tes commits soient clairs,                    ║
    ║            tes branches propres,                             ║
    ║            et tes merges sans conflits.                      ║
    ║                                                              ║
    ║                   FIN DES CHRONIQUES                         ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝

FINALE
fi

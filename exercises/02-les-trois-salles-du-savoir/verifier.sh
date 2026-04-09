#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# verifier.sh - Quête 02 : Les Trois Salles du Savoir
# Project : Git Chronicles (Les Chroniques du Versionneur)
# Verifies that the apprentice understands le flux Working Dir → Staging Area
# =============================================================================

# Load shared functions
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_DIR}/../../lib/common.sh"
_parse_lang_flag "$@"
_load_theme_messages

# Quest title
QUEST_TITLE="Quête 02 - Les Trois Salles du Savoir"
show_banner "${QUEST_TITLE}"

# ── Step 1 : On est dans un dépôt git ──────────────────────────────────────
check_step 1 \
    "Tu te trouves dans un dépôt git (git init a été fait)" \
    "git rev-parse --is-inside-work-tree" \
    || true

# ── Step 2 : Le fichier parchemin.txt existe ───────────────────────────────
check_step 2 \
    "Le fichier parchemin.txt existe dans la Salle de Travail" \
    "test -f parchemin.txt" \
    || true

# ── Step 3 : parchemin.txt est dans le staging area ────────────────────────
check_step 3 \
    "parchemin.txt est dans la Salle de Préparation (staging area)" \
    "git diff --cached --name-only | grep -q parchemin.txt" \
    || true

# ── Step 4 : Pas encore de commit (pas de HEAD valide) ─────────────────────
check_step 4 \
    "Aucun parchemin n'a encore été scellé (pas de commit)" \
    "! git rev-parse HEAD > /dev/null 2>&1" \
    || true

# ── Score final ──────────────────────────────────────────────────────────────
show_score

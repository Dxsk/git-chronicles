#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# =============================================================================
# messages_en.sh - Themed messages: Heroic Fantasy (English)
# Project : Git Chronicles (Les Chroniques du Versionneur)
# Theme   : Heroic Fantasy - Gamified Git course
# Version : 2.0.0
#
# This file is sourced automatically by common.sh.
# It defines theme variables that override the default messages.
#
# Compatibility : bash 3.2+ (macOS), bash 4+ (Linux)
# Encoding      : UTF-8
# =============================================================================

# These variables are consumed by lib/common.sh after this file is sourced.
# shellcheck disable=SC2034

# Active theme name (useful for debugging)
THEME_NAME="fantasy"

# -----------------------------------------------------------------------------
# Success messages
# Each successful check picks a random message from this array
# to vary the learning experience and maintain immersion.
# -----------------------------------------------------------------------------
MESSAGES_SUCCESS=(
    "The scroll is sealed!"
    "The archivist approves!"
    "The scribe validates your work!"
    "The rune glows bright!"
    "The Code Guardian bows before you."
    "The Oracle confirms: the path is true."
    "Your spell took effect, apprentice!"
    "The Guild of Versioners salutes your deed."
    "The magic ink has taken hold on the scroll."
    "Well forged, brave apprentice!"
)

# -----------------------------------------------------------------------------
# Failure messages
# Each failed check picks a random message from this array.
# Messages remain encouraging even on error.
# -----------------------------------------------------------------------------
MESSAGES_FAILURE=(
    "The scribe rejects this scroll."
    "The archive refuses this entry."
    "The guardian blocks the passage."
    "The rune stays dark... something is wrong."
    "The Oracle shakes their head: this is not the right path."
    "The Guild does not recognize this gesture."
    "The scroll burns before it can be sealed."
    "The magic ink refuses to take hold."
    "The ancient texts indicate a ritual error."
    "The verification crystal remains dim."
)

# -----------------------------------------------------------------------------
# End-of-quest global messages
# -----------------------------------------------------------------------------

# Displayed when all steps are successful
MSG_CONGRATULATIONS="CONGRATULATIONS! You have completed this quest!"

# Displayed when at least one step has failed
MSG_ENCOURAGEMENT="Courage, apprentice! Re-read the instructions and try again."

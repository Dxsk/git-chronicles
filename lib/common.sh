#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# shellcheck disable=SC2034
# This is a library sourced by every quest verifier — many of the theme /
# message / color variables declared below are referenced by the sourcer, not
# by common.sh itself, so SC2034 (unused variable) is noise here.
#
# =============================================================================
# common.sh - Shared functions for verification scripts
# Project : Git Chronicles (Les Chroniques du Versionneur)
# Theme   : Heroic Fantasy - Gamified Git course
# Version : 2.0.0
#
# Usage   : source "$(dirname "$0")/../lib/common.sh"
#
# Compatibility : bash 3.2+ (macOS), bash 4+ (Linux)
# Encoding      : UTF-8
# =============================================================================

# Guard against double loading
[[ -n "${_COMMON_LOADED:-}" ]] && return 0
readonly _COMMON_LOADED=1

# -----------------------------------------------------------------------------
# Language flag parsing
# Usage: _parse_lang_flag "$@" at the top of each quest verifier script.
# Defaults to English if no flag is provided.
# -----------------------------------------------------------------------------
LANG_CODE="${LANG_CODE:-en}"

_parse_lang_flag() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --lang|-L) LANG_CODE="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
}

_load_theme_messages() {
  local script_dir="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
  local theme_dir="${script_dir}/../../themes/${THEME:-fantasy}"
  local msg_file="${theme_dir}/messages_${LANG_CODE}.sh"
  if [[ -f "$msg_file" ]]; then
    # shellcheck source=/dev/null
    source "$msg_file"
  else
    # shellcheck source=/dev/null
    source "${theme_dir}/messages_en.sh"
  fi
}

# -----------------------------------------------------------------------------
# Global score variables
# -----------------------------------------------------------------------------
SCORE=0
TOTAL=0
QUEST_TITLE=""

# -----------------------------------------------------------------------------
# ANSI color detection
# The terminal must be a TTY AND support colors.
# -----------------------------------------------------------------------------
_init_colors() {
    if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && [[ "${NO_COLOR:-}" != "1" ]]; then
        CLR_RESET=$'\033[0m'
        CLR_BOLD=$'\033[1m'
        CLR_GREEN=$'\033[32m'
        CLR_RED=$'\033[31m'
        CLR_YELLOW=$'\033[33m'
        CLR_CYAN=$'\033[36m'
        CLR_MAGENTA=$'\033[35m'
        CLR_WHITE=$'\033[97m'
    else
        CLR_RESET=""
        CLR_BOLD=""
        CLR_GREEN=""
        CLR_RED=""
        CLR_YELLOW=""
        CLR_CYAN=""
        CLR_MAGENTA=""
        CLR_WHITE=""
    fi
}

_init_colors

# -----------------------------------------------------------------------------
# Optional theme loading
# Relative path from git/lib/ -> git/themes/fantasy/messages_<lang>.sh
# -----------------------------------------------------------------------------
_THEME_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)/../../themes/fantasy"

# Default messages (overridden if the theme is loaded)
THEME_NAME="default"
MESSAGES_SUCCESS=("Correct!" "Well done!" "Validated!" "Success!" "Perfect!" "Bravo!")
MESSAGES_FAILURE=("Incorrect." "Missed." "Needs fixing." "Not valid." "Failed." "Try again.")
MSG_CONGRATULATIONS="Congratulations! You have completed this quest!"
MSG_ENCOURAGEMENT="Courage! Re-read the instructions and try again."

# Load theme messages for the current language
_THEME_FILE="${_THEME_DIR}/messages_${LANG_CODE}.sh"
if [[ -f "${_THEME_FILE}" ]]; then
    # shellcheck source=../themes/fantasy/messages_en.sh
    source "${_THEME_FILE}"
fi

# -----------------------------------------------------------------------------
# _random_message <array_name>
# Returns a random message from a bash array.
# Compatible with bash 3.2 (no nameref, uses eval).
# -----------------------------------------------------------------------------
_random_message() {
    local array_name="$1"

    # bash 3.2 does not support namerefs; we use eval safely
    # (array name is controlled internally, never user-supplied)
    local size
    eval "size=\${#${array_name}[@]}"

    if [[ "${size}" -eq 0 ]]; then
        printf "Message unavailable."
        return
    fi

    local index=$(( RANDOM % size ))
    local msg
    eval "msg=\${${array_name}[${index}]}"
    printf "%s" "${msg}"
}

# -----------------------------------------------------------------------------
# show_banner <title>
# Displays a themed ASCII box with the title centered.
# -----------------------------------------------------------------------------
show_banner() {
    local title="${1:-Git Chronicles}"
    local width=60

    # Calculate padding to center the title
    local title_len=${#title}
    local space_total=$(( width - title_len - 2 ))   # -2 for the border chars
    local pad_left=$(( space_total / 2 ))
    local pad_right=$(( space_total - pad_left ))

    # Build horizontal line
    local line_h
    line_h="$(printf '%0.s═' $(seq 1 "${width}"))"

    printf "\n"
    printf "%s╔%s╗%s\n" "${CLR_MAGENTA}${CLR_BOLD}" "${line_h}" "${CLR_RESET}"
    printf "%s║%*s%s%*s║%s\n" \
        "${CLR_MAGENTA}${CLR_BOLD}" \
        "${pad_left}" "" \
        "${CLR_CYAN}${CLR_BOLD}${title}${CLR_MAGENTA}${CLR_BOLD}" \
        "${pad_right}" "" \
        "${CLR_RESET}"
    printf "%s╚%s╝%s\n" "${CLR_MAGENTA}${CLR_BOLD}" "${line_h}" "${CLR_RESET}"
    printf "\n"
}

# -----------------------------------------------------------------------------
# check_step <number> <description> <test_command>
# Executes <test_command> via eval.
# Shows a success or failure indicator with a themed random message.
# Increments TOTAL on each call; increments SCORE on success.
# -----------------------------------------------------------------------------
check_step() {
    local number="${1:?check_step: 'number' argument required}"
    local description="${2:?check_step: 'description' argument required}"
    local test_command="${3:?check_step: 'test_command' argument required}"

    TOTAL=$(( TOTAL + 1 ))

    # Silent execution of the test command
    local result=0
    eval "${test_command}" > /dev/null 2>&1 || result=$?

    if [[ "${result}" -eq 0 ]]; then
        SCORE=$(( SCORE + 1 ))
        local theme_msg
        theme_msg="$(_random_message MESSAGES_SUCCESS)"
        printf "  %s✅  Step %s - %s%s\n" \
            "${CLR_GREEN}${CLR_BOLD}" \
            "${number}" \
            "${description}" \
            "${CLR_RESET}"
        printf "      %s%s%s\n\n" \
            "${CLR_GREEN}" \
            "${theme_msg}" \
            "${CLR_RESET}"
    else
        local theme_msg
        theme_msg="$(_random_message MESSAGES_FAILURE)"
        printf "  %s❌  Step %s - %s%s\n" \
            "${CLR_RED}${CLR_BOLD}" \
            "${number}" \
            "${description}" \
            "${CLR_RESET}"
        printf "      %s%s%s\n\n" \
            "${CLR_RED}" \
            "${theme_msg}" \
            "${CLR_RESET}"
    fi

    return "${result}"
}

# -----------------------------------------------------------------------------
# show_score
# Displays the final score and a congratulation or encouragement message.
# -----------------------------------------------------------------------------
show_score() {
    local separator
    separator="$(printf '%0.s─' $(seq 1 60))"

    printf "%s%s%s\n" "${CLR_CYAN}" "${separator}" "${CLR_RESET}"
    printf "%s  Score : %s%d / %d%s\n" \
        "${CLR_BOLD}" \
        "${CLR_YELLOW}${CLR_BOLD}" \
        "${SCORE}" \
        "${TOTAL}" \
        "${CLR_RESET}"

    if [[ "${SCORE}" -eq "${TOTAL}" ]] && [[ "${TOTAL}" -gt 0 ]]; then
        printf "\n  %s%s%s\n" \
            "${CLR_GREEN}${CLR_BOLD}" \
            "${MSG_CONGRATULATIONS}" \
            "${CLR_RESET}"
    else
        printf "\n  %s%s%s\n" \
            "${CLR_YELLOW}" \
            "${MSG_ENCOURAGEMENT}" \
            "${CLR_RESET}"
    fi

    printf "%s%s%s\n\n" "${CLR_CYAN}" "${separator}" "${CLR_RESET}"
}

# -----------------------------------------------------------------------------
# check_git_installed
# Checks that the git command is available in the PATH.
# Returns 0 if git is found, 1 otherwise.
# -----------------------------------------------------------------------------
check_git_installed() {
    if command -v git > /dev/null 2>&1; then
        printf "%sgit is installed (%s).%s\n" \
            "${CLR_GREEN}" \
            "$(git --version)" \
            "${CLR_RESET}"
        return 0
    else
        printf "%sError: git is not installed or not in PATH.%s\n" \
            "${CLR_RED}" \
            "${CLR_RESET}" >&2
        return 1
    fi
}

# -----------------------------------------------------------------------------
# check_in_repo
# Checks that the current directory is inside a git repository.
# Returns 0 if inside a repo, 1 otherwise.
# -----------------------------------------------------------------------------
check_in_repo() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        local root
        root="$(git rev-parse --show-toplevel 2>/dev/null)"
        printf "%sRepository detected: %s%s\n" \
            "${CLR_GREEN}" \
            "${root}" \
            "${CLR_RESET}"
        return 0
    else
        printf "%sError: this directory is not inside a git repository.%s\n" \
            "${CLR_RED}" \
            "${CLR_RESET}" >&2
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Predicate helpers for rigor-focused verifier checks
#
# These helpers are silent (no output, return 0 or 1). They are designed to
# be called from inside check_step's test_command string, so the verifier's
# output stays uniform (handled by check_step itself).
#
# Usage from a verifier:
#   check_step 2 "ma-copie/ a une remote nommee 'origin'" \
#       'assert_remote_name "$WORKDIR/ma-copie" "origin"'
# -----------------------------------------------------------------------------

# Returns 0 if <repo> has a remote named exactly <expected_name>.
# Returns 1 if the path is not a git repo or the remote is missing.
assert_remote_name() {
    local repo="$1"
    local expected="$2"
    [ -d "$repo/.git" ] || return 1
    git -C "$repo" remote 2>/dev/null | grep -qx -- "$expected"
}

# Returns 0 if <repo> is currently on branch <expected>.
# Returns 1 if HEAD is detached, branch differs, or path is not a repo.
assert_branch_is() {
    local repo="$1"
    local expected="$2"
    local actual
    actual="$(git -C "$repo" symbolic-ref --short HEAD 2>/dev/null)" || return 1
    [ "$actual" = "$expected" ]
}

# Returns 0 if <file> exists AND its content matches the extended regex
# <pattern>. Returns 1 otherwise.
assert_file_contains() {
    local file="$1"
    local pattern="$2"
    [ -f "$file" ] && grep -qE -- "$pattern" "$file"
}

# Returns 0 if all <repo_paths> share the same HEAD commit SHA.
# Returns 1 if any path is not a repo, or if any HEAD differs from the first.
assert_same_head() {
    local first=""
    local repo
    for repo in "$@"; do
        local sha
        sha="$(git -C "$repo" rev-parse HEAD 2>/dev/null)" || return 1
        if [ -z "$first" ]; then
            first="$sha"
        elif [ "$sha" != "$first" ]; then
            return 1
        fi
    done
}

# -----------------------------------------------------------------------------
# show_section <title>
#
# Prints a small underlined cyan section header. Cosmetic only, does not
# affect SCORE/TOTAL. Use to group related check_step calls in a verifier.
# -----------------------------------------------------------------------------
show_section() {
    local title="$1"
    printf "\n  %s-- %s --%s\n" \
        "${CLR_CYAN}${CLR_BOLD}" "$title" "${CLR_RESET}"
}

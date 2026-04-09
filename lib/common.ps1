# SPDX-License-Identifier: MIT
# =============================================================================
# common.ps1 - Shared functions for verification scripts
# Project : Git Chronicles (Les Chroniques du Versionneur)
# Theme   : Heroic Fantasy - Gamified Git course
# Version : 2.0.0
#
# Usage   : . "$PSScriptRoot/../lib/common.ps1"
#
# Compatibility : PowerShell 5.1+ (Windows native) and PowerShell 7+ (cross-platform)
# Encoding      : UTF-8
# =============================================================================

# Guard against double loading
if ($script:_CommonLoaded) { return }
$script:_CommonLoaded = $true

# -----------------------------------------------------------------------------
# Language parameter support
# Quest verifier scripts should call: _Parse-LangFlag $args
# Defaults to English if no flag is provided.
# -----------------------------------------------------------------------------
if (-not $script:LangCode) { $script:LangCode = "en" }

function _Parse-LangFlag {
    param([string[]]$Arguments)
    for ($i = 0; $i -lt $Arguments.Count; $i++) {
        if ($Arguments[$i] -eq "--lang" -or $Arguments[$i] -eq "-L") {
            if ($i + 1 -lt $Arguments.Count) {
                $script:LangCode = $Arguments[$i + 1]
            }
        }
    }
}

function _Load-ThemeMessages {
    $themeDir = Join-Path $PSScriptRoot "..\themes\$($script:Theme ?? 'fantasy')"
    $msgFile  = Join-Path $themeDir "messages_$($script:LangCode).ps1"
    if (Test-Path $msgFile) {
        . $msgFile
    } else {
        $fallback = Join-Path $themeDir "messages_en.ps1"
        if (Test-Path $fallback) { . $fallback }
    }
}

# -----------------------------------------------------------------------------
# Shared script variables (score, total, quest title)
# -----------------------------------------------------------------------------
$script:Score      = 0
$script:Total      = 0
$script:QuestTitle = ""

# -----------------------------------------------------------------------------
# Optional theme loading
# Relative path from git/lib/ -> git/themes/fantasy/messages_<lang>.ps1
# -----------------------------------------------------------------------------
$_ThemeFile = Join-Path $PSScriptRoot "..\themes\fantasy\messages_$($script:LangCode).ps1"

# Default messages (overridden if the theme is loaded)
$script:ThemeName         = "default"
$script:MessagesSuccess   = @("Correct!", "Well done!", "Validated!", "Success!", "Perfect!", "Bravo!")
$script:MessagesFailure   = @("Incorrect.", "Missed.", "Needs fixing.", "Not valid.", "Failed.", "Try again.")
$script:MsgCongratulations = "Congratulations! You have completed this quest!"
$script:MsgEncouragement  = "Courage! Re-read the instructions and try again."

if (Test-Path $_ThemeFile) {
    . $_ThemeFile
}

# -----------------------------------------------------------------------------
# _Get-RandomMessage <array>
# Returns a random message from a PowerShell array.
# Internal function, prefixed by private convention.
# -----------------------------------------------------------------------------
function _Get-RandomMessage {
    param(
        [string[]]$Messages
    )
    if ($Messages.Count -eq 0) { return "Message unavailable." }
    $index = Get-Random -Minimum 0 -Maximum $Messages.Count
    return $Messages[$index]
}

# -----------------------------------------------------------------------------
# Show-Banner [-Title <string>]
# Displays a themed ASCII box with the title centered.
# -----------------------------------------------------------------------------
function Show-Banner {
    param(
        [string]$Title = "Git Chronicles"
    )

    $width      = 60
    $lineH      = "═" * $width
    $titleLen   = $Title.Length
    $spaceTotal = $width - $titleLen - 2  # -2 for the border chars
    $padLeft    = [Math]::Floor($spaceTotal / 2)
    $padRight   = $spaceTotal - $padLeft

    Write-Host ""
    Write-Host ("╔" + $lineH + "╗") -ForegroundColor Magenta
    Write-Host ("║" + (" " * $padLeft)) -NoNewline -ForegroundColor Magenta
    Write-Host $Title -NoNewline -ForegroundColor Cyan
    Write-Host ((" " * $padRight) + "║") -ForegroundColor Magenta
    Write-Host ("╚" + $lineH + "╝") -ForegroundColor Magenta
    Write-Host ""
}

# -----------------------------------------------------------------------------
# Check-Step -Number <int> -Description <string> -TestCommand <scriptblock>
# Executes the test script block.
# Shows a success or failure indicator with a themed random message.
# Increments $script:Total; increments $script:Score on success.
# -----------------------------------------------------------------------------
function Check-Step {
    param(
        [Parameter(Mandatory)]
        [int]$Number,

        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [scriptblock]$TestCommand
    )

    $script:Total++

    # Silent execution of the test
    $success = $false
    try {
        $result = & $TestCommand 2>&1
        # If the block returned an explicit boolean, trust it — some steps
        # deliberately treat a non-zero LASTEXITCODE as success (e.g. "HEAD
        # must not resolve", "file must not match pattern"). Falling back to
        # LASTEXITCODE here would invert their intent.
        if ($result -is [bool]) {
            $success = $result
        } elseif ($LASTEXITCODE -ne $null -and $LASTEXITCODE -ne 0) {
            $success = $false
        } elseif ($result -ne $null -and $result -ne $false -and $result -ne 0) {
            $success = $true
        } else {
            # Null, $false, 0, or an empty collection — treat as failure.
            # (The previous copy-paste bug here silently marked these as
            # success, masking broken step logic in several verifiers.)
            $success = $false
        }
    }
    catch {
        $success = $false
    }

    if ($success) {
        $script:Score++
        $themeMsg = _Get-RandomMessage -Messages $script:MessagesSuccess
        Write-Host ("  ✅  Step $Number - $Description") -ForegroundColor Green
        Write-Host ("      $themeMsg") -ForegroundColor Green
        Write-Host ""
    }
    else {
        $themeMsg = _Get-RandomMessage -Messages $script:MessagesFailure
        Write-Host ("  ❌  Step $Number - $Description") -ForegroundColor Red
        Write-Host ("      $themeMsg") -ForegroundColor Red
        Write-Host ""
    }

    return $success
}

# -----------------------------------------------------------------------------
# Show-Score
# Displays the final score and a congratulation or encouragement message.
# -----------------------------------------------------------------------------
function Show-Score {
    $separator = "─" * 60

    Write-Host $separator -ForegroundColor Cyan
    Write-Host ("  Score : $($script:Score) / $($script:Total)") -ForegroundColor Yellow

    if ($script:Score -eq $script:Total -and $script:Total -gt 0) {
        Write-Host ""
        Write-Host ("  $($script:MsgCongratulations)") -ForegroundColor Green
    }
    else {
        Write-Host ""
        Write-Host ("  $($script:MsgEncouragement)") -ForegroundColor Yellow
    }

    Write-Host $separator -ForegroundColor Cyan
    Write-Host ""
}

# -----------------------------------------------------------------------------
# Check-GitInstalled
# Checks that the git command is available in the PATH.
# Returns $true if git is found, $false otherwise.
# -----------------------------------------------------------------------------
function Check-GitInstalled {
    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if ($gitCmd) {
        $version = & git --version 2>&1
        Write-Host "git is installed ($version)." -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Error: git is not installed or not in PATH." -ForegroundColor Red
        return $false
    }
}

# -----------------------------------------------------------------------------
# Check-InRepo
# Checks that the current directory is inside a git repository.
# Returns $true if inside a repo, $false otherwise.
# -----------------------------------------------------------------------------
function Check-InRepo {
    $result = & git rev-parse --is-inside-work-tree 2>&1
    if ($LASTEXITCODE -eq 0) {
        $root = & git rev-parse --show-toplevel 2>&1
        Write-Host "Repository detected: $root" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Error: this directory is not inside a git repository." -ForegroundColor Red
        return $false
    }
}

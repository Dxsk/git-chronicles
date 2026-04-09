# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 12 - L'Oracle du Code - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\..\..\lib\common.ps1"
_Parse-LangFlag $args
_Load-ThemeMessages

$script:QuestTitle = "Quête 12 - L'Oracle du Code"
Show-Banner $script:QuestTitle

# ---- Step 1 : Est-on dans un dépôt Git ? ----
Check-Step 1 "Tu es dans un dépôt Git" {
    $result = & git rev-parse --is-inside-work-tree 2>&1
    $LASTEXITCODE -eq 0
}

# ---- Step 2 : git bisect a été utilisé ----
# bisect laisse des traces dans le reflog : checkouts multiples entre hashes
# détachés (typique d'une recherche binaire).
Check-Step 2 "git bisect a été utilisé (trace dans le reflog)" {
    $reflog = & git reflog 2>&1
    if ($LASTEXITCODE -ne 0) { return $false }
    $reflogText = $reflog | Out-String
    $checkoutMatches = [regex]::Matches($reflogText, "checkout: moving from [0-9a-f]{7,} to [0-9a-f]{7,}")
    $checkoutMatches.Count -ge 2
}

# ---- Step 3 : git cherry-pick a été utilisé (trace dans le reflog) ----
Check-Step 3 "git cherry-pick a été utilisé (trace dans le reflog)" {
    $reflog = & git reflog 2>&1
    if ($LASTEXITCODE -ne 0) { return $false }
    ($reflog | Out-String) -match "cherry-pick"
}

# ---- Step 4 : Le grimoire ne contient plus le mot CORROMPU ----
Check-Step 4 "Le grimoire ne contient plus le mot CORROMPU" {
    if (-not (Test-Path "grimoire.txt")) { return $false }
    $contenu = Get-Content "grimoire.txt" -Raw -ErrorAction SilentlyContinue
    -not ($contenu -match "CORROMPU")
}

Show-Score

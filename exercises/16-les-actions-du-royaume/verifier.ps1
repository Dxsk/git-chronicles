# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 16 - Les Actions du Royaume - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\..\..\lib\common.ps1"
_Parse-LangFlag $args
_Load-ThemeMessages

$script:QuestTitle = "Quête 16 - Les Actions du Royaume"
Show-Banner $script:QuestTitle

# ---- Step 1 : Est-on dans un dépôt Git ? ----
Check-Step 1 "Tu es dans un dépôt Git" {
    $result = & git rev-parse --is-inside-work-tree 2>&1
    $LASTEXITCODE -eq 0
}

# ---- Step 2 : Le dossier .github/workflows existe ----
Check-Step 2 "Le dossier .github/workflows existe" {
    Test-Path ".github/workflows" -PathType Container
}

# ---- Step 3 : Au moins un fichier .yml existe dans .github/workflows ----
Check-Step 3 "Au moins un fichier .yml existe dans .github/workflows" {
    if (-not (Test-Path ".github/workflows")) { return $false }
    $files = Get-ChildItem ".github/workflows" -Filter "*.yml" -ErrorAction SilentlyContinue
    if (-not $files) {
        $files = Get-ChildItem ".github/workflows" -Filter "*.yaml" -ErrorAction SilentlyContinue
    }
    ($files | Measure-Object).Count -ge 1
}

# ---- Step 4 : Le fichier YAML contient le mot-clé "name:" ----
Check-Step 4 "Le workflow contient le mot-clé 'name:'" {
    if (-not (Test-Path ".github/workflows")) { return $false }
    $files = @(Get-ChildItem ".github/workflows" -Filter "*.yml" -ErrorAction SilentlyContinue) + `
             @(Get-ChildItem ".github/workflows" -Filter "*.yaml" -ErrorAction SilentlyContinue)
    if (-not $files) { return $false }
    foreach ($f in $files) {
        $content = Get-Content $f.FullName -Raw
        if ($content -match "(?m)^name:") { return $true }
    }
    $false
}

# ---- Step 5 : Le fichier YAML contient le mot-clé "on:" ----
Check-Step 5 "Le workflow contient le mot-clé 'on:'" {
    if (-not (Test-Path ".github/workflows")) { return $false }
    $files = @(Get-ChildItem ".github/workflows" -Filter "*.yml" -ErrorAction SilentlyContinue) + `
             @(Get-ChildItem ".github/workflows" -Filter "*.yaml" -ErrorAction SilentlyContinue)
    if (-not $files) { return $false }
    foreach ($f in $files) {
        $content = Get-Content $f.FullName -Raw
        if ($content -match "(?m)^on:") { return $true }
    }
    $false
}

# ---- Step 6 : Le fichier YAML contient le mot-clé "jobs:" ----
Check-Step 6 "Le workflow contient le mot-clé 'jobs:'" {
    if (-not (Test-Path ".github/workflows")) { return $false }
    $files = @(Get-ChildItem ".github/workflows" -Filter "*.yml" -ErrorAction SilentlyContinue) + `
             @(Get-ChildItem ".github/workflows" -Filter "*.yaml" -ErrorAction SilentlyContinue)
    if (-not $files) { return $false }
    foreach ($f in $files) {
        $content = Get-Content $f.FullName -Raw
        if ($content -match "(?m)^jobs:") { return $true }
    }
    $false
}

Show-Score

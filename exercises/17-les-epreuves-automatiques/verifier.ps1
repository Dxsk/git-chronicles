# SPDX-License-Identifier: MIT
# =============================================================================
# Quête 17 - Les Épreuves Automatiques - Verification script
# Project : Git Chronicles (Les Chroniques du Versionneur)
# =============================================================================

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\..\..\lib\common.ps1"
_Parse-LangFlag $args
_Load-ThemeMessages

$script:QuestTitle = "Quête 17 - Les Épreuves Automatiques"
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

# ---- Step 3 : Un workflow YAML contient une stratégie de matrice ----
Check-Step 3 "Un workflow contient une stratégie de matrice (matrix)" {
    $fichiers = @(Get-ChildItem ".github/workflows" -Filter "*.yml" -ErrorAction SilentlyContinue) + `
                @(Get-ChildItem ".github/workflows" -Filter "*.yaml" -ErrorAction SilentlyContinue)
    if (-not $fichiers -or ($fichiers | Measure-Object).Count -eq 0) { return $false }
    foreach ($f in $fichiers) {
        $content = Get-Content $f.FullName -Raw
        if ($content -match "matrix:") { return $true }
    }
    return $false
}

# ---- Step 4 : Le workflow contient plusieurs étapes (steps) ----
Check-Step 4 "Le workflow contient plusieurs étapes (steps)" {
    $fichiers = @(Get-ChildItem ".github/workflows" -Filter "*.yml" -ErrorAction SilentlyContinue) + `
                @(Get-ChildItem ".github/workflows" -Filter "*.yaml" -ErrorAction SilentlyContinue)
    if (-not $fichiers -or ($fichiers | Measure-Object).Count -eq 0) { return $false }
    $fichier = $fichiers | Select-Object -First 1
    $content = Get-Content $fichier.FullName -Raw
    $stepNames = [regex]::Matches($content, "- name:")
    $stepNames.Count -ge 2
}

# ---- Step 5 : Au moins un script de test existe ----
Check-Step 5 "Au moins un script de test existe" {
    $testFiles = @()
    $testFiles += Get-ChildItem -Path "." -Filter "test-*.sh" -ErrorAction SilentlyContinue
    $testFiles += Get-ChildItem -Path "." -Filter "test-*.bash" -ErrorAction SilentlyContinue
    if (Test-Path "tests" -PathType Container) {
        $testFiles += @(Get-ChildItem "tests" -Filter "*.sh"   -ErrorAction SilentlyContinue) + `
                      @(Get-ChildItem "tests" -Filter "*.bash" -ErrorAction SilentlyContinue)
    }
    ($testFiles | Measure-Object).Count -ge 1
}

Show-Score

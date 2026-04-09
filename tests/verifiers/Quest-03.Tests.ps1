# SPDX-License-Identifier: MIT
#
# Pester regression tests for exercises/03-le-premier-parchemin/verifier.ps1
#
# These tests mirror tests/verifiers/quest-03.bats. They are NOT end-user
# verification — they are CI/dev checks that protect the exercise + verifier
# pair against regressions.

Describe 'Quest 03 — Le Premier Parchemin' {

    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot  = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Quest     = '03-le-premier-parchemin'
        $script:Verifier  = Join-Path $script:RepoRoot "exercises/$($script:Quest)/verifier.ps1"
        $script:Parchemin = Join-Path $script:RepoRoot "exercises/$($script:Quest)/parchemins/mission.txt"
    }

    BeforeEach {
        $script:TmpDir = New-TmpSandbox
    }

    AfterEach {
        Remove-TmpSandbox $script:TmpDir
    }

    Context 'Ressources fournies' {
        It 'ships parchemins/mission.txt with the quest' {
            Test-Path $script:Parchemin                | Should -BeTrue
            (Get-Item $script:Parchemin).Length -gt 0  | Should -BeTrue
        }
    }

    Context 'Happy path' {
        It 'passes on a correctly-solved quest (EN)' {
            $work = Join-Path $script:TmpDir 'mon-archive'
            New-Item -ItemType Directory -Path $work | Out-Null
            Push-Location $work
            try {
                & git init -q
                & git commit -q --allow-empty -m "Initialiser l'archive de la Guilde"
                Copy-Item $script:Parchemin -Destination .
                & git add mission.txt
                & git commit -q -m "Ajouter l'ordre de mission de la Guilde"
            } finally { Pop-Location }

            $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
            $out | Should -Match '4 / 4'
            $out | Should -Match '(?i)congratulations'
        }

        It 'passes on a correctly-solved quest (FR)' {
            $work = Join-Path $script:TmpDir 'mon-archive'
            New-Item -ItemType Directory -Path $work | Out-Null
            Push-Location $work
            try {
                & git init -q
                & git commit -q --allow-empty -m "Initialiser l'archive de la Guilde"
                Copy-Item $script:Parchemin -Destination .
                & git add mission.txt
                & git commit -q -m "Ajouter l'ordre de mission de la Guilde"
            } finally { Pop-Location }

            $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work -ExtraArgs @('--lang','fr')
            $out | Should -Match '4 / 4'
            $out | Should -Match 'FÉLICITATIONS'
        }
    }

    Context 'Failure cases' {
        It 'fails outside a Git repo' {
            $work = Join-Path $script:TmpDir 'not-a-repo'
            New-Item -ItemType Directory -Path $work | Out-Null
            $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
            $out | Should -Not -Match '4 / 4'
            $out | Should -Not -Match '(?i)congratulations'
        }

        It 'fails with only one commit' {
            $work = Join-Path $script:TmpDir 'mon-archive'
            New-Item -ItemType Directory -Path $work | Out-Null
            Push-Location $work
            try {
                & git init -q
                Copy-Item $script:Parchemin -Destination .
                & git add mission.txt
                & git commit -q -m "Ajouter l'ordre de mission"
            } finally { Pop-Location }

            $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
            $out | Should -Not -Match '4 / 4'
            $out | Should -Match '2 commits'
        }

        It 'fails when mission.txt is untracked' {
            $work = Join-Path $script:TmpDir 'mon-archive'
            New-Item -ItemType Directory -Path $work | Out-Null
            Push-Location $work
            try {
                & git init -q
                & git commit -q --allow-empty -m "Initialiser"
                & git commit -q --allow-empty -m "Deuxieme commit vide"
                Copy-Item $script:Parchemin -Destination .
            } finally { Pop-Location }

            $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
            $out | Should -Not -Match '4 / 4'
            $out | Should -Match 'mission.txt'
        }

        It 'rejects generic first-commit messages' {
            $work = Join-Path $script:TmpDir 'mon-archive'
            New-Item -ItemType Directory -Path $work | Out-Null
            Push-Location $work
            try {
                & git init -q
                & git commit -q --allow-empty -m "Initial commit"
                Copy-Item $script:Parchemin -Destination .
                & git add mission.txt
                & git commit -q -m "Ajouter l'ordre de mission"
            } finally { Pop-Location }

            $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
            $out | Should -Not -Match '4 / 4'
            $out | Should -Match 'personnalisé'
        }
    }
}

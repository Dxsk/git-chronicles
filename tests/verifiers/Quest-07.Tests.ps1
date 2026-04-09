# SPDX-License-Identifier: MIT
# Regression tests for exercises/07-le-conflit-des-royaumes/verifier.ps1

Describe 'Quest 07 — Le Conflit des Royaumes' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:QuestDir = Join-Path $script:RepoRoot 'exercises/07-le-conflit-des-royaumes'
        $script:Verifier = Join-Path $script:QuestDir 'verifier.ps1'
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'ships archive.bundle and preparer-archive.sh' {
        Test-Path (Join-Path $script:QuestDir 'archive.bundle')      | Should -BeTrue
        Test-Path (Join-Path $script:QuestDir 'preparer-archive.sh') | Should -BeTrue
    }

    It 'passes after a clean merge' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo base > f.txt
git add f.txt
git commit -q -m 'Initial'
git checkout -q -b royaume-sud
echo sud >> f.txt
git commit -q -am 'Contribution du sud'
git checkout -q main
git merge -q --no-ff -m 'Fusion des royaumes après négociations' royaume-sud
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '5 / 5'
    }

    It 'fails when no merge has been performed' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo base > f.txt
git add f.txt
git commit -q -m 'Commit initial'
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '5 / 5'
        $out | Should -Match 'merge'
    }
}

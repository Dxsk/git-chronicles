# SPDX-License-Identifier: MIT
# Regression tests for exercises/10-le-protocole-des-guildes/verifier.ps1

Describe 'Quest 10 — Le Protocole des Guildes' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/10-le-protocole-des-guildes/verifier.ps1'
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes after --no-ff merge + branch cleanup' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo a > a.txt && git add a.txt && git commit -q -m 'Commit A'
echo b > b.txt && git add b.txt && git commit -q -m 'Commit B'
git checkout -q -b proposition
echo p > p.txt && git add p.txt && git commit -q -m 'Proposition de la guilde'
git checkout -q main
git merge -q --no-ff -m 'Intégrer la proposition selon le Protocole' proposition
git branch -D proposition
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '5 / 5'
    }

    It 'fails when the proposition branch is still there' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo a > a.txt && git add a.txt && git commit -q -m A
echo b > b.txt && git add b.txt && git commit -q -m B
git checkout -q -b proposition
echo p > p.txt && git add p.txt && git commit -q -m Proposition
git checkout -q main
git merge -q --no-ff -m 'Merge de la proposition en main' proposition
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '5 / 5'
        $out | Should -Match 'nettoyée'
    }
}

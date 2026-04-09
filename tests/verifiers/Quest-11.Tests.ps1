# SPDX-License-Identifier: MIT
# Regression tests for exercises/11-le-tisseur-de-temps/verifier.ps1

Describe 'Quest 11 — Le Tisseur de Temps' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/11-le-tisseur-de-temps/verifier.ps1'
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with stash activity and multiple branches' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo a > a.txt && git add a.txt && git commit -q -m A
echo b > b.txt && git add b.txt && git commit -q -m B
echo c > c.txt && git add c.txt && git commit -q -m C
git checkout -q -b travail
echo wip >> a.txt
git stash push -q -m 'Travail en cours'
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '4 / 4'
    }

    It 'fails without any stash activity' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo a > a.txt && git add a.txt && git commit -q -m A
echo b > b.txt && git add b.txt && git commit -q -m B
echo c > c.txt && git add c.txt && git commit -q -m C
git checkout -q -b travail
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '4 / 4'
        $out | Should -Match 'stash'
    }
}

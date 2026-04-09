# SPDX-License-Identifier: MIT
# Regression tests for exercises/08-reecrire-lhistoire/verifier.ps1

Describe 'Quest 08 — Réécrire l''Histoire' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/08-reecrire-lhistoire/verifier.ps1'
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes after amend + rebase + 3 commits' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo a > a.txt && git add a.txt && git commit -q -m 'Commit A'
echo b > b.txt && git add b.txt && git commit -q -m 'Commit B'
echo a1 >> a.txt && git add a.txt && git commit -q --amend -m 'Commit A amended'
git checkout -q -b feature
echo c > c.txt && git add c.txt && git commit -q -m 'Commit C on feature'
git checkout -q main
echo d > d.txt && git add d.txt && git commit -q -m 'Commit D on main'
git checkout -q feature
git rebase -q main
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '4 / 4'
    }

    It 'fails without any amend or rebase' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo a > a.txt && git add a.txt && git commit -q -m A
echo b > b.txt && git add b.txt && git commit -q -m B
echo c > c.txt && git add c.txt && git commit -q -m C
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '4 / 4'
    }
}

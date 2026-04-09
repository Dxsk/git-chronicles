# SPDX-License-Identifier: MIT
# Regression tests for exercises/20-les-chemins-libres/verifier.ps1

Describe 'Quest 20 — Les Chemins Libres' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/20-les-chemins-libres/verifier.ps1'
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with mon-parcours.txt tracked + tag' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo 'mon parcours à travers les Chroniques' > mon-parcours.txt
git add mon-parcours.txt
git commit -q -m 'Mon parcours libre'
git tag v1.0.0
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '5 / 5'
    }

    It 'fails without mon-parcours.txt' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
git commit -q --allow-empty -m empty
git tag v1.0.0
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '5 / 5'
        $out | Should -Match 'mon-parcours.txt'
    }
}

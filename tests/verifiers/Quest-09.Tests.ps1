# SPDX-License-Identifier: MIT
# Regression tests for exercises/09-les-portails-distants/verifier.ps1

Describe 'Quest 09 — Les Portails Distants' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/09-les-portails-distants/verifier.ps1'
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with remote + push + fetch' {
        $work = Join-Path $script:TmpDir 'work'
        $upstream = Join-Path $script:TmpDir 'upstream.git'
        Invoke-BashSetup @"
set -e
git init -q --bare '$upstream'
mkdir -p '$work'
cd '$work'
git init -q
echo hello > f.txt
git add f.txt
git commit -q -m Initial
git remote add origin '$upstream'
git push -q -u origin main
git fetch -q origin
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '4 / 4'
    }

    It 'fails without any remote configured' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo hello > f.txt
git add f.txt
git commit -q -m Initial
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '4 / 4'
        $out | Should -Match 'remote'
    }
}

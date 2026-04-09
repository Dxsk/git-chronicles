# SPDX-License-Identifier: MIT
# Regression tests for exercises/15-les-forges-eternelles/verifier.ps1

Describe 'Quest 15 — Les Forges Éternelles' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/15-les-forges-eternelles/verifier.ps1'
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with remote + pushed refs + 3+ commits' {
        $work = Join-Path $script:TmpDir 'work'
        $forge = Join-Path $script:TmpDir 'forge.git'
        $env:WORK  = $work
        $env:FORGE = $forge
        Invoke-BashSetup @'
set -e
git init -q --bare "$FORGE"
mkdir -p "$WORK"
cd "$WORK"
git init -q
for i in 1 2 3; do echo "commit $i" > "f$i.txt"; git add "f$i.txt"; git commit -q -m "Commit $i"; done
git remote add origin "$FORGE"
git push -q -u origin main
'@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '4 / 4'
    }

    It 'fails without a remote' {
        $work = Join-Path $script:TmpDir 'work'
        $env:WORK = $work
        Invoke-BashSetup @'
set -e
mkdir -p "$WORK"
cd "$WORK"
git init -q
for i in 1 2 3; do echo "commit $i" > "f$i.txt"; git add "f$i.txt"; git commit -q -m "Commit $i"; done
'@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '4 / 4'
        $out | Should -Match 'remote'
    }
}

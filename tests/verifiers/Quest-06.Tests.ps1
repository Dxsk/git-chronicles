# SPDX-License-Identifier: MIT
# Regression tests for exercises/06-larbre-des-possibles/verifier.ps1

Describe 'Quest 06 — L''Arbre des Possibles' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/06-larbre-des-possibles/verifier.ps1'
        $script:BuildPass = {
            param([string]$Work)
            $env:WORK = $Work
            Invoke-BashSetup @'
set -e
mkdir -p "$WORK"
cd "$WORK"
git init -q
echo base > base.txt
git add base.txt
git commit -q -m 'Commit initial sur main'
git checkout -q -b expedition-nord
echo nord > nord.txt
git add nord.txt
git commit -q -m 'Exploration du nord'
git checkout -q main
git checkout -q -b expedition-sud
echo sud > sud.txt
git add sud.txt
git commit -q -m 'Exploration du sud'
git checkout -q main
'@
        }
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with two expedition branches' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '6 / 6'
    }

    It 'fails when expedition-nord is missing' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $env:WORK = $work
        Invoke-BashSetup 'cd "$WORK" && git branch -D expedition-nord'
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '6 / 6'
        $out | Should -Match 'expedition-nord'
    }
}

# SPDX-License-Identifier: MIT
# Regression tests for exercises/02-les-trois-salles-du-savoir/verifier.ps1

Describe 'Quest 02 — Les Trois Salles du Savoir' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/02-les-trois-salles-du-savoir/verifier.ps1'
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with parchemin.txt staged and no commit' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo 'contenu du parchemin' > parchemin.txt
git add parchemin.txt
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '4 / 4'
    }

    It 'fails when parchemin.txt is not staged' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo 'contenu' > parchemin.txt
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '4 / 4'
        $out | Should -Match 'staging area'
    }

    It 'fails once a commit has been made' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo 'contenu' > parchemin.txt
git add parchemin.txt
git commit -q -m 'Sceller le parchemin'
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '4 / 4'
        $out | Should -Match 'pas de commit'
    }
}

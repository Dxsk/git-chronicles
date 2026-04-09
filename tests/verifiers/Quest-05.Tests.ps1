# SPDX-License-Identifier: MIT
# Regression tests for exercises/05-les-lignes-du-temps/verifier.ps1

Describe 'Quest 05 — Les Lignes du Temps' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:QuestDir = Join-Path $script:RepoRoot 'exercises/05-les-lignes-du-temps'
        $script:Verifier = Join-Path $script:QuestDir 'verifier.ps1'
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'ships archive.bundle and preparer-archive.sh' {
        Test-Path (Join-Path $script:QuestDir 'archive.bundle')        | Should -BeTrue
        Test-Path (Join-Path $script:QuestDir 'preparer-archive.sh')   | Should -BeTrue
    }

    It 'passes with .gitignore ignoring .log and a debug.log' {
        $work = Join-Path $script:TmpDir 'work'
        $bundle = Join-Path $script:QuestDir 'archive.bundle'
        Invoke-BashSetup @"
set -e
cd '$script:TmpDir'
git clone -q '$bundle' work
cd work
echo '*.log' > .gitignore
echo 'noisy debug line' > debug.log
git rm --cached debug.log 2>/dev/null || true
git add .gitignore
git commit -q -m 'Ignore log files to keep archives clean'
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '5 / 5'
    }

    It 'fails without a .gitignore' {
        $work = Join-Path $script:TmpDir 'work'
        $bundle = Join-Path $script:QuestDir 'archive.bundle'
        Invoke-BashSetup @"
set -e
cd '$script:TmpDir'
git clone -q '$bundle' work
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '5 / 5'
        $out | Should -Match '\.gitignore'
    }
}

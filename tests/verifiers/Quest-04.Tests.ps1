# SPDX-License-Identifier: MIT
# Regression tests for exercises/04-larchive-est-partout/verifier.ps1

Describe 'Quest 04 — L''Archive est Partout' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/04-larchive-est-partout/verifier.ps1'
        $script:BuildPass = {
            param([string]$Work)
            $env:WORK = $Work
            Invoke-BashSetup @'
set -e
mkdir -p "$WORK"
cd "$WORK"
mkdir mon-archive
( cd mon-archive && git init -q && echo hello > a.txt && git add a.txt && git commit -q -m init )
git clone -q ./mon-archive ma-copie
git clone -q --bare ./mon-archive ./archive-centrale.git
git clone -q ./archive-centrale.git ./clone-depuis-bare
'@
        }
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with full remote + clone + bare setup' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '4 / 4'
    }

    It 'fails when ma-copie/ is missing' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        Remove-Item -Recurse -Force (Join-Path $work 'ma-copie')
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '4 / 4'
        $out | Should -Match 'ma-copie'
    }

    It 'fails when archive-centrale.git is not a bare repo' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        Remove-Item -Recurse -Force (Join-Path $work 'archive-centrale.git')
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '4 / 4'
        $out | Should -Match 'bare'
    }
}

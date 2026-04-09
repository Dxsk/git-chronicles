# SPDX-License-Identifier: MIT
# Regression tests for exercises/01-la-guilde-des-archivistes/verifier.ps1

Describe 'Quest 01 — La Guilde des Archivistes' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/01-la-guilde-des-archivistes/verifier.ps1'
    }

    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with git + user.name + user.email configured' {
        $work = Join-Path $script:TmpDir 'work'
        New-Item -ItemType Directory -Path $work | Out-Null
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '3 / 3'
    }

    It 'fails when user.name is missing' {
        & git config --global --unset user.name
        $work = Join-Path $script:TmpDir 'work'
        New-Item -ItemType Directory -Path $work | Out-Null
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '3 / 3'
        $out | Should -Match 'nom est configuré'
    }

    It 'fails when user.email is missing' {
        & git config --global --unset user.email
        $work = Join-Path $script:TmpDir 'work'
        New-Item -ItemType Directory -Path $work | Out-Null
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '3 / 3'
        $out | Should -Match 'email est configuré'
    }
}

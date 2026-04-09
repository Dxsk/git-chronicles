# SPDX-License-Identifier: MIT
# Regression tests for exercises/13-les-sceaux-magiques/verifier.ps1

Describe 'Quest 13 — Les Sceaux Magiques' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/13-les-sceaux-magiques/verifier.ps1'
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with 2 tags (one annotated, semver)' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo a > a.txt && git add a.txt && git commit -q -m 'Commit initial'
git tag v1.0.0
echo b > b.txt && git add b.txt && git commit -q -m 'Deuxième'
git tag -a v1.1.0 -m 'Version mineure'
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '4 / 4'
    }

    It 'fails when no tag follows vX.Y.Z format' {
        $work = Join-Path $script:TmpDir 'work'
        Invoke-BashSetup @"
set -e
mkdir -p '$work'
cd '$work'
git init -q
echo a > a.txt && git add a.txt && git commit -q -m Initial
git tag release-one
git tag -a release-two -m Second
"@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '4 / 4'
        $out | Should -Match 'versionnage'
    }
}

# SPDX-License-Identifier: MIT
# Regression tests for exercises/12-loracle-du-code/verifier.ps1

Describe 'Quest 12 — L''Oracle du Code' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:QuestDir = Join-Path $script:RepoRoot 'exercises/12-loracle-du-code'
        $script:Verifier = Join-Path $script:QuestDir 'verifier.ps1'
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'ships archive.bundle and preparer-archive.sh' {
        Test-Path (Join-Path $script:QuestDir 'archive.bundle')      | Should -BeTrue
        Test-Path (Join-Path $script:QuestDir 'preparer-archive.sh') | Should -BeTrue
    }

    It 'passes with bisect + cherry-pick reflog and clean grimoire' {
        $work = Join-Path $script:TmpDir 'work'
        $env:WORK = $work
        Invoke-BashSetup @'
set -e
mkdir -p "$WORK"
cd "$WORK"
git init -q
echo 'ligne 1' > grimoire.txt
git add grimoire.txt
git commit -q -m 'Grimoire initial'
for i in 2 3 4; do echo "ligne $i" >> grimoire.txt; git commit -q -am "Ajout ligne $i"; done
h1=$(git rev-parse HEAD)
echo CORROMPU >> grimoire.txt
git commit -q -am 'Ligne corrompue'
h2=$(git rev-parse HEAD)
echo 'ligne 6' >> grimoire.txt
git commit -q -am 'Ajout ligne 6'
h3=$(git rev-parse HEAD)
git checkout -q -b fix
sed -i '/CORROMPU/d' grimoire.txt
git commit -q -am 'Purifier le grimoire'
fix_sha=$(git rev-parse HEAD)
git checkout -q main
git -c advice.detachedHead=false checkout -q "$h1"
git -c advice.detachedHead=false checkout -q "$h2"
git -c advice.detachedHead=false checkout -q "$h3"
git checkout -q main
git cherry-pick "$fix_sha" >/dev/null
'@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '4 / 4'
    }
}

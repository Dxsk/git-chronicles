# SPDX-License-Identifier: MIT
# Regression tests for exercises/16-les-actions-du-royaume/verifier.ps1

Describe 'Quest 16 — Les Actions du Royaume' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/16-les-actions-du-royaume/verifier.ps1'
        $script:BuildPass = {
            param([string]$Work)
            $env:WORK = $Work
            Invoke-BashSetup @'
set -e
mkdir -p "$WORK/.github/workflows"
cd "$WORK"
git init -q
cat > .github/workflows/ci.yml <<'YAML'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
YAML
git add .
git commit -q -m 'Add CI workflow'
'@
        }
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with a minimal valid workflow' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '6 / 6'
    }

    It 'fails when the workflow is missing the jobs: key' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $env:WORK = $work
        Invoke-BashSetup @'
cat > "$WORK/.github/workflows/ci.yml" <<'YAML'
name: CI
on: [push]
YAML
'@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '6 / 6'
        $out | Should -Match 'jobs:'
    }
}

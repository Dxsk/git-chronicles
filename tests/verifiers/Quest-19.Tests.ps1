# SPDX-License-Identifier: MIT
# Regression tests for exercises/19-les-autres-forges/verifier.ps1

Describe 'Quest 19 — Les Autres Forges' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/19-les-autres-forges/verifier.ps1'
        $script:BuildPass = {
            param([string]$Work)
            $env:WORK = $Work
            Invoke-BashSetup @'
set -e
mkdir -p "$WORK/.github/workflows" "$WORK/scripts"
cd "$WORK"
git init -q
cat > .github/workflows/ci.yml <<'YAML'
name: CI
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: bash scripts/test.sh
YAML
cat > .gitlab-ci.yml <<'YAML'
test:
  script: bash scripts/test.sh
YAML
cat > bitbucket-pipelines.yml <<'YAML'
pipelines:
  default:
    - step:
        script:
          - bash scripts/test.sh
YAML
cat > scripts/test.sh <<'SH'
#!/usr/bin/env bash
echo ok
SH
chmod +x scripts/test.sh
git add .
git commit -q -m 'Setup multi-forge CI'
'@
        }
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with workflows for all 3 forges + test script' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '6 / 6'
    }

    It 'fails when .gitlab-ci.yml is missing' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        Remove-Item -Force (Join-Path $work '.gitlab-ci.yml')
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '6 / 6'
        $out | Should -Match 'gitlab-ci'
    }
}

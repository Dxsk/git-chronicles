# SPDX-License-Identifier: MIT
# Regression tests for exercises/18-le-deploiement-sacre/verifier.ps1

Describe 'Quest 18 — Le Déploiement Sacré' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/18-le-deploiement-sacre/verifier.ps1'
        $script:BuildPass = {
            param([string]$Work)
            $env:WORK = $Work
            Invoke-BashSetup @'
set -e
mkdir -p "$WORK/.github/workflows"
cd "$WORK"
git init -q
cat > .github/workflows/deploy.yml <<'YAML'
name: Deploy
on:
  push:
    tags:
      - 'v*'
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      - name: Deploy
        run: echo "deploying to production"
YAML
git add .
git commit -q -m 'Setup deploy workflow'
git tag v1.0.0
'@
        }
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with deploy workflow and a version tag' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '4 / 4'
    }

    It 'fails without any tag' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $env:WORK = $work
        Invoke-BashSetup 'cd "$WORK" && git tag -d v1.0.0'
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '4 / 4'
        $out | Should -Match 'tag'
    }
}

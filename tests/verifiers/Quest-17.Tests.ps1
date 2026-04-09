# SPDX-License-Identifier: MIT
# Regression tests for exercises/17-les-epreuves-automatiques/verifier.ps1

Describe 'Quest 17 — Les Épreuves Automatiques' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/17-les-epreuves-automatiques/verifier.ps1'
        $script:BuildPass = {
            param([string]$Work)
            $env:WORK = $Work
            Invoke-BashSetup @'
set -e
mkdir -p "$WORK/.github/workflows" "$WORK/tests"
cd "$WORK"
git init -q
cat > .github/workflows/test.yml <<'YAML'
name: Epreuves
on: [push]
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Run tests
        run: bash tests/run.sh
YAML
cat > tests/run.sh <<'SH'
#!/usr/bin/env bash
echo ok
SH
chmod +x tests/run.sh
git add .
git commit -q -m 'Setup CI matrix'
'@
        }
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with matrix workflow + test script' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '5 / 5'
    }

    It 'fails without a matrix strategy' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $env:WORK = $work
        Invoke-BashSetup @'
cat > "$WORK/.github/workflows/test.yml" <<'YAML'
name: Epreuves
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
YAML
'@
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '5 / 5'
        $out | Should -Match 'matrix'
    }
}

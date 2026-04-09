# SPDX-License-Identifier: MIT
# Regression tests for exercises/14-les-outils-de-larchiviste/verifier.ps1

Describe 'Quest 14 — Les Outils de l''Archiviste' {
    BeforeAll {
        . (Join-Path $PSScriptRoot 'helpers.ps1')
        $script:RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
        $script:Verifier = Join-Path $script:RepoRoot 'exercises/14-les-outils-de-larchiviste/verifier.ps1'
        $script:BuildPass = {
            param([string]$Work)
            $env:WORK = $Work
            Invoke-BashSetup @'
set -e
git config --global alias.st status
mkdir -p "$WORK"
cd "$WORK"
git init -q
echo a > a.txt && git add a.txt && git commit -q -m Initial
cat > .git/hooks/pre-commit <<'HOOK'
#!/usr/bin/env bash
# Block commits containing TODO markers.
if git diff --cached | grep -q "TODO"; then
  echo "TODO detected"
  exit 1
fi
HOOK
chmod +x .git/hooks/pre-commit
cat > .git/hooks/commit-msg <<'HOOK'
#!/usr/bin/env bash
exit 0
HOOK
chmod +x .git/hooks/commit-msg
'@
        }
    }
    BeforeEach { $script:TmpDir = New-TmpSandbox }
    AfterEach  { Remove-TmpSandbox $script:TmpDir }

    It 'passes with alias + pre-commit + commit-msg hooks' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Match '5 / 5'
    }

    It 'fails when the pre-commit hook is missing the TODO check' {
        $work = Join-Path $script:TmpDir 'work'
        & $script:BuildPass -Work $work
        $env:WORK = $work
        Invoke-BashSetup 'echo "#!/bin/bash" > "$WORK/.git/hooks/pre-commit" && chmod +x "$WORK/.git/hooks/pre-commit"'
        $out = Invoke-Verifier -Verifier $script:Verifier -WorkDir $work
        $out | Should -Not -Match '5 / 5'
        $out | Should -Match 'TODO'
    }
}

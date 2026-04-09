# SPDX-License-Identifier: MIT
#
# Shared Pester helpers for verifier regression tests.
#
# Dot-source from a BeforeAll block:
#   BeforeAll { . (Join-Path $PSScriptRoot 'helpers.ps1') }

function New-TmpSandbox {
    <#
    .SYNOPSIS
      Create an isolated temp dir with a clean global git config.
    #>
    $tmp = New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid()))
    $env:GIT_CONFIG_GLOBAL = Join-Path $tmp '.gitconfig'
    $env:GIT_CONFIG_SYSTEM = '/dev/null'
    & git config --global user.email 'test@git-chronicles.local' | Out-Null
    & git config --global user.name  'Test Runner'               | Out-Null
    & git config --global init.defaultBranch main                | Out-Null
    & git config --global commit.gpgsign false                   | Out-Null
    return $tmp.FullName
}

function Remove-TmpSandbox {
    param([string]$Path)
    if ($Path -and (Test-Path $Path)) {
        Remove-Item -Recurse -Force $Path -ErrorAction SilentlyContinue
    }
    Remove-Item Env:GIT_CONFIG_GLOBAL -ErrorAction SilentlyContinue
    Remove-Item Env:GIT_CONFIG_SYSTEM -ErrorAction SilentlyContinue
}

function Invoke-BashSetup {
    <#
    .SYNOPSIS
      Run a bash script to build a test scenario. Throws on non-zero exit.
      Lets Pester tests reuse the exact same setup logic as the .bats files
      without translating it to PowerShell.
    #>
    param([Parameter(Mandatory)][string]$Script)
    $out = & bash -c $Script 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "bash setup failed (exit $LASTEXITCODE): $out"
    }
}

function Invoke-Verifier {
    <#
    .SYNOPSIS
      Run a quest verifier.ps1 from inside $WorkDir and capture stdout+stderr
      as a single string.
    #>
    param(
        [Parameter(Mandatory)][string]$Verifier,
        [Parameter(Mandatory)][string]$WorkDir,
        [string[]]$ExtraArgs = @()
    )
    Push-Location $WorkDir
    try {
        return (& pwsh -NoProfile -File $Verifier @ExtraArgs 2>&1 | Out-String)
    } finally {
        Pop-Location
    }
}

<#
.SYNOPSIS
    Sync skills and commands from this repo into ~/.claude/.
.DESCRIPTION
    - Skills: creates directory junctions at ~/.claude/skills/<name> pointing to repo/skills/<name>
    - Commands: creates hard links at ~/.claude/commands/<name>.md pointing to repo/commands/<name>.md
    No admin rights required (junctions + hard links work without elevation on NTFS).
    Existing items are skipped unless -Force is passed, in which case they're replaced.
.PARAMETER Force
    Replace existing destinations even if they already exist.
.PARAMETER Target
    Target .claude directory. Defaults to $HOME/.claude.
#>
param(
    [switch]$Force,
    [string]$Target = (Join-Path $HOME '.claude')
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$skillsSrc = Join-Path $repoRoot 'skills'
$commandsSrc = Join-Path $repoRoot 'commands'
$skillsDst = Join-Path $Target 'skills'
$commandsDst = Join-Path $Target 'commands'

New-Item -ItemType Directory -Force -Path $skillsDst, $commandsDst | Out-Null

function Link-Skill($srcDir) {
    $name = Split-Path $srcDir -Leaf
    $dst = Join-Path $skillsDst $name
    if (Test-Path $dst) {
        if ($Force) {
            Write-Host "replace junction: $name" -ForegroundColor Yellow
            & cmd /c rmdir "`"$dst`"" | Out-Null
        } else {
            Write-Host "skip (exists):    $name" -ForegroundColor DarkGray
            return
        }
    }
    & cmd /c mklink /J "`"$dst`"" "`"$srcDir`"" | Out-Null
    Write-Host "linked skill:     $name" -ForegroundColor Green
}

function Link-Command($srcFile) {
    $name = Split-Path $srcFile -Leaf
    $dst = Join-Path $commandsDst $name
    if (Test-Path $dst) {
        if ($Force) {
            Remove-Item $dst -Force
        } else {
            Write-Host "skip (exists):    $name" -ForegroundColor DarkGray
            return
        }
    }
    New-Item -ItemType HardLink -Path $dst -Target $srcFile | Out-Null
    Write-Host "linked command:   $name" -ForegroundColor Green
}

Write-Host "Syncing to $Target`n"

Get-ChildItem -Directory $skillsSrc | ForEach-Object { Link-Skill $_.FullName }
Get-ChildItem -File -Filter *.md $commandsSrc | ForEach-Object { Link-Command $_.FullName }

Write-Host "`nDone. Restart Claude Code to pick up new skills/commands."

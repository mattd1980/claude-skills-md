<#
.SYNOPSIS
    Sync skills and commands from this repo into ~/.claude/ using directory junctions.
.DESCRIPTION
    - Per-skill junctions: ~/.claude/skills/<name> -> repo/skills/<name>
    - Whole-dir junction:  ~/.claude/commands      -> repo/commands
    Junctions work cross-drive without admin rights on NTFS.
    Existing destinations are left alone unless -Force is passed.
.PARAMETER Force
    Replace existing destinations. Required the first time you migrate from real
    directories (in ~/.claude/) to junctions pointing at this repo.
.PARAMETER Target
    Target .claude directory. Defaults to $HOME/.claude.
#>
param(
    [switch]$Force,
    [string]$Target = (Join-Path $HOME '.claude')
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$skillsSrc   = Join-Path $repoRoot 'skills'
$commandsSrc = Join-Path $repoRoot 'commands'
$skillsDst   = Join-Path $Target 'skills'
$commandsDst = Join-Path $Target 'commands'

New-Item -ItemType Directory -Force -Path $skillsDst | Out-Null

function Test-Junction($path) {
    if (-not (Test-Path $path)) { return $false }
    $item = Get-Item $path -Force
    return ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
}

function Remove-Destination($path) {
    if (-not (Test-Path $path)) { return }
    if (Test-Junction $path) {
        & cmd /c rmdir "`"$path`"" | Out-Null
    } else {
        Remove-Item $path -Recurse -Force
    }
}

function Link-Junction($src, $dst, $label) {
    $name = Split-Path $dst -Leaf
    if (Test-Path $dst) {
        if ($Force) {
            Write-Host "replace:          $name" -ForegroundColor Yellow
            Remove-Destination $dst
        } else {
            Write-Host "skip (exists):    $name" -ForegroundColor DarkGray
            return
        }
    }
    & cmd /c mklink /J "`"$dst`"" "`"$src`"" | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "linked $label`:  $name" -ForegroundColor Green
    } else {
        Write-Host "FAILED $label`:  $name" -ForegroundColor Red
    }
}

Write-Host "Syncing to $Target`n"

Get-ChildItem -Directory $skillsSrc | ForEach-Object {
    Link-Junction $_.FullName (Join-Path $skillsDst $_.Name) 'skill'
}

Link-Junction $commandsSrc $commandsDst 'commands-dir'

Write-Host "`nDone. Restart Claude Code to pick up new skills/commands."

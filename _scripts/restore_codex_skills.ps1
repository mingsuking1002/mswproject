<#
.SYNOPSIS
Restore Codex skills from this repo into the local Codex skills directory.

.DESCRIPTION
Copies skill folders from `<repo>\skill\` into `%USERPROFILE%\.codex\skills\`.
This lets you clone the repo on a new computer and install the same skills.

.PARAMETER SkillName
One or more skill folder names to restore. If omitted, restores all skills found under the repo skill directory.

.PARAMETER RepoSkillDir
Repo input directory (relative to repo root). Default: `skill`.

.PARAMETER Force
Overwrite existing local skill folders.

.EXAMPLE
./_scripts/restore_codex_skills.ps1 -Force

.EXAMPLE
./_scripts/restore_codex_skills.ps1 -SkillName mswproject-brain -Force
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$SkillName,

    [Parameter(Mandatory = $false)]
    [string]$RepoSkillDir = "skill",

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoSkillRoot = Join-Path $repoRoot $RepoSkillDir
$codexSkillRoot = Join-Path $env:USERPROFILE ".codex\\skills"

if (-not (Test-Path $repoSkillRoot)) {
    throw "Repo skill directory not found: $repoSkillRoot"
}

New-Item -ItemType Directory -Force -Path $codexSkillRoot | Out-Null

$skills =
    if ($SkillName -and $SkillName.Count -gt 0) {
        $SkillName
    } else {
        Get-ChildItem -Path $repoSkillRoot -Directory -Force | Select-Object -ExpandProperty Name
    }

$skills = @($skills)

if (-not $skills -or $skills.Length -eq 0) {
    Write-Host "No skills to restore."
    exit 0
}

foreach ($name in $skills) {
    $src = Join-Path $repoSkillRoot $name
    $dst = Join-Path $codexSkillRoot $name

    if (-not (Test-Path $src)) {
        Write-Warning "Skip (missing source): $src"
        continue
    }

    if (Test-Path $dst) {
        if (-not $Force) {
            throw "Local destination exists: $dst (re-run with -Force)"
        }
        Remove-Item -LiteralPath $dst -Recurse -Force
    }

    Copy-Item -LiteralPath $src -Destination $codexSkillRoot -Recurse -Force
    Write-Host "Restored -> local: $name"
}

Write-Host "Done. Restart Codex/CLI if it doesn't pick up the new skill immediately."

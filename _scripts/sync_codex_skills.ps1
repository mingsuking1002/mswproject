<#
.SYNOPSIS
Back up local Codex skills into this repo (for Git sync).

.DESCRIPTION
Copies skill folders from `%USERPROFILE%\.codex\skills\` into `<repo>\skill\`.
By default, it syncs all local skills except `.system`.

.PARAMETER SkillName
One or more skill folder names to sync. If omitted, syncs all local skills (excluding `.system`).

.PARAMETER RepoSkillDir
Repo output directory (relative to repo root). Default: `skill`.

.PARAMETER IncludeSystem
Include `.system` skills. (Not recommended; these are built-in/system skills.)

.PARAMETER Force
Overwrite existing destination folders in the repo.

.EXAMPLE
./_scripts/sync_codex_skills.ps1 -Force

.EXAMPLE
./_scripts/sync_codex_skills.ps1 -SkillName mswproject-brain -Force
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$SkillName,

    [Parameter(Mandatory = $false)]
    [string]$RepoSkillDir = "skill",

    [Parameter(Mandatory = $false)]
    [switch]$IncludeSystem,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoSkillRoot = Join-Path $repoRoot $RepoSkillDir
$codexSkillRoot = Join-Path $env:USERPROFILE ".codex\\skills"

if (-not (Test-Path $codexSkillRoot)) {
    throw "Codex skill root not found: $codexSkillRoot"
}

New-Item -ItemType Directory -Force -Path $repoSkillRoot | Out-Null

$skills =
    if ($SkillName -and $SkillName.Count -gt 0) {
        $SkillName
    } else {
        Get-ChildItem -Path $codexSkillRoot -Directory -Force |
            Where-Object { $IncludeSystem -or $_.Name -ne ".system" } |
            Select-Object -ExpandProperty Name
    }

$skills = @($skills)

if (-not $skills -or $skills.Length -eq 0) {
    Write-Host "No skills to sync."
    exit 0
}

foreach ($name in $skills) {
    if (-not $IncludeSystem -and $name -eq ".system") {
        continue
    }

    $src = Join-Path $codexSkillRoot $name
    $dst = Join-Path $repoSkillRoot $name

    if (-not (Test-Path $src)) {
        Write-Warning "Skip (missing source): $src"
        continue
    }

    if (Test-Path $dst) {
        if (-not $Force) {
            throw "Destination exists: $dst (re-run with -Force)"
        }
        Remove-Item -LiteralPath $dst -Recurse -Force
    }

    Copy-Item -LiteralPath $src -Destination $repoSkillRoot -Recurse -Force
    Write-Host "Synced -> repo: $name"
}

Write-Host "Done. Commit the '$RepoSkillDir' folder to Git to use on other machines."

<#
.SYNOPSIS
Convert an Antigravity brain backup into a Codex skill folder.

.DESCRIPTION
Copies Antigravity brain files (markdown + artifacts like .resolved/.json/.webp) into `skill/<skill-name>/references/brain/` and generates `SKILL.md`.

If -BrainRoot is not provided, this script uses the first existing path:
- <repo>\_scripts\.ai_backup\brain
- <repo>\.ai_backup\brain
- %USERPROFILE%\.gemini\antigravity\brain

.PARAMETER BrainRoot
Root folder containing brain snapshots (UUID directories).

.PARAMETER BrainId
Specific snapshot directory name (UUID). If omitted, selects the directory with the most `.md` files, then the newest.

.PARAMETER SkillName
Output skill folder name (letters/digits/hyphen). Default: mswproject-brain.

.PARAMETER OutDir
Output directory (relative to repo root). Default: skill.

.PARAMETER InstallToCodex
Also copies the generated skill to `%USERPROFILE%\.codex\skills\<skill-name>`.

.PARAMETER Force
Overwrite existing output folders.

.EXAMPLE
./_scripts/brain_to_skill.ps1 -Force

.EXAMPLE
./_scripts/brain_to_skill.ps1 -BrainId 8f48c3d3-7e67-47c1-b830-e1e1325a4fe7 -SkillName mswproject-brain -InstallToCodex -Force
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$BrainRoot,

    [Parameter(Mandatory = $false)]
    [string]$BrainId,

    [Parameter(Mandatory = $false)]
    [string]$SkillName = "mswproject-brain",

    [Parameter(Mandatory = $false)]
    [string]$OutDir = "skill",

    [Parameter(Mandatory = $false)]
    [switch]$InstallToCodex,

    [Parameter(Mandatory = $false)]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Normalize-SkillName {
    param([Parameter(Mandatory = $true)][string]$Name)

    $normalized = $Name.ToLowerInvariant()
    $normalized = $normalized -replace "[^a-z0-9-]", "-"
    $normalized = $normalized -replace "-{2,}", "-"
    $normalized = $normalized.Trim("-")

    if ([string]::IsNullOrWhiteSpace($normalized)) {
        throw "SkillName is empty after normalization. (input: '$Name')"
    }

    if ($normalized.Length -gt 64) {
        $normalized = $normalized.Substring(0, 64).Trim("-")
    }

    return $normalized
}

function Assert-SafeToRemove {
    param(
        [Parameter(Mandatory = $true)][string]$PathToRemove,
        [Parameter(Mandatory = $true)][string]$RepoRoot
    )

    $fullRepo = (Resolve-Path $RepoRoot).Path.TrimEnd("\")
    $fullTarget = (Resolve-Path -LiteralPath $PathToRemove).Path.TrimEnd("\")

    if ($fullTarget -eq $fullRepo) {
        throw "Safety check: refusing to remove repo root: $fullTarget"
    }

    if (-not $fullTarget.StartsWith($fullRepo, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Safety check: refusing to remove path outside repo: $fullTarget"
    }
}

$SkillName = Normalize-SkillName -Name $SkillName

$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not $BrainRoot) {
    $candidateRoots = @(
        (Join-Path $repoRoot "_scripts\\.ai_backup\\brain"),
        (Join-Path $repoRoot ".ai_backup\\brain"),
        (Join-Path $env:USERPROFILE ".gemini\\antigravity\\brain")
    ) | Where-Object { Test-Path $_ }

    if (-not $candidateRoots -or $candidateRoots.Count -eq 0) {
        throw "BrainRoot not found. Provide -BrainRoot. Searched: _scripts/.ai_backup/brain, .ai_backup/brain, ~/.gemini/antigravity/brain"
    }

    $BrainRoot = $candidateRoots[0]
}

$BrainRoot = (Resolve-Path $BrainRoot).Path

$brainDirs = Get-ChildItem -Path $BrainRoot -Directory -Force
if (-not $brainDirs -or $brainDirs.Count -eq 0) {
    throw "No brain snapshot directories found under: $BrainRoot"
}

if ($BrainId) {
    $selected = $brainDirs | Where-Object { $_.Name -eq $BrainId } | Select-Object -First 1
    if (-not $selected) {
        throw "BrainId '$BrainId' not found under: $BrainRoot"
    }
    $brainDir = $selected
} else {
    $scored = foreach ($d in $brainDirs) {
        $mdCount = (Get-ChildItem -Path $d.FullName -File -Force -Filter "*.md" | Measure-Object).Count
        [PSCustomObject]@{
            Dir           = $d
            MdCount       = $mdCount
            LastWriteTime = $d.LastWriteTimeUtc
        }
    }

    $brainDir = (
        $scored |
            Sort-Object -Property @(
                @{ Expression = "MdCount"; Descending = $true },
                @{ Expression = "LastWriteTime"; Descending = $true }
            ) |
            Select-Object -First 1
    ).Dir
    $BrainId = $brainDir.Name
}

Write-Host "BrainRoot: $BrainRoot"
Write-Host "BrainId:   $BrainId"

$outRoot = Join-Path $repoRoot $OutDir
$outSkillDir = Join-Path $outRoot $SkillName
$referencesDir = Join-Path $outSkillDir "references"
$brainRefsDir = Join-Path $referencesDir "brain"
$agentsDir = Join-Path $outSkillDir "agents"

if (Test-Path $outSkillDir) {
    if (-not $Force) {
        throw "Output folder already exists: $outSkillDir (re-run with -Force to overwrite)"
    }

    Assert-SafeToRemove -PathToRemove $outSkillDir -RepoRoot $repoRoot
    Remove-Item -LiteralPath $outSkillDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $brainRefsDir | Out-Null
New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null

# 1) Copy all brain files (markdown + artifacts like .resolved/.json/.webp)
Copy-Item -Path (Join-Path $brainDir.FullName "*") -Destination $brainRefsDir -Recurse -Force

# 2) Rewrite absolute file:// links to relative links (text files only)
$rewriteTargets = @()
$rewriteTargets += Get-ChildItem -Path $brainRefsDir -File -Force -Recurse -Filter "*.md"
$rewriteTargets += Get-ChildItem -Path $brainRefsDir -File -Force -Recurse -Filter "*.resolved"
$rewriteTargets += Get-ChildItem -Path $brainRefsDir -File -Force -Recurse -Filter "*.resolved.*"
$rewriteTargets = $rewriteTargets | Sort-Object FullName -Unique

foreach ($f in $rewriteTargets) {
    $text = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
    $rewritten = $text

    # Example: file:///c:/Users/<user>/.gemini/antigravity/brain/<uuid>/task.md -> ./task.md
    $rewritten = $rewritten -replace "(?i)file:///c:/users/[^/]+/\.gemini/antigravity/(brain|knowledge)/[^/]+/", "./"

    if ($rewritten -ne $text) {
        Set-Content -LiteralPath $f.FullName -Value $rewritten -Encoding UTF8
    }
}

# 3) Generate SKILL.md
$entryPath = Join-Path $brainRefsDir "knowledge_summary.md"
$entryRef = "references/brain/knowledge_summary.md"
if (-not (Test-Path $entryPath)) {
    $first = ($copiedMd | Sort-Object Name | Select-Object -First 1)
    if ($first) {
        $entryRef = "references/brain/$($first.Name)"
    } else {
        $entryRef = "references/brain/"
    }
}

$skillTitle = ($SkillName -replace "-", " ")

$skillMdTemplate = @'
---
name: {0}
description: Codex skill exposing Antigravity brain markdown references (MSW APIs, components, services, Lua scripting, project rules). Use when you need to search or summarize the brain docs.
---

# {1}

## Overview

This skill packages your Antigravity brain markdown backups as `references/` so Codex can quickly search and cite them while working.

## Usage

1. Search `references/brain/` for relevant keywords.
2. Prefer the docs as source of truth; ask clarifying questions when needed.

### Entry (recommended)

- `{2}`

## Notes

- Brain docs: `references/brain/*.md`
'@

$skillMd = $skillMdTemplate -f $SkillName, $skillTitle, $entryRef

Set-Content -LiteralPath (Join-Path $outSkillDir "SKILL.md") -Value $skillMd -Encoding UTF8

$openaiYamlTemplate = @'
interface:
  display_name: "{0}"
  short_description: "Antigravity brain references"
'@

$openaiYaml = $openaiYamlTemplate -f $skillTitle

Set-Content -LiteralPath (Join-Path $agentsDir "openai.yaml") -Value $openaiYaml -Encoding UTF8

Write-Host "Skill generated: $outSkillDir"

if ($InstallToCodex) {
    $codexRoot = Join-Path $env:USERPROFILE ".codex\\skills"
    $dest = Join-Path $codexRoot $SkillName

    if (Test-Path $dest) {
        if (-not $Force) {
            throw "Codex skill already exists: $dest (re-run with -Force to overwrite)"
        }
        Remove-Item -LiteralPath $dest -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $codexRoot | Out-Null
    Copy-Item -LiteralPath $outSkillDir -Destination $dest -Recurse -Force
    Write-Host "Installed to Codex: $dest"
}

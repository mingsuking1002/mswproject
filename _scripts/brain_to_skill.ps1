<#
.SYNOPSIS
Antigravity brain 백업을 Codex Skill 폴더로 변환합니다.

.DESCRIPTION
레포에 백업된 Antigravity brain(.md) 문서를 `skill/<skill-name>/references/brain/`로 복사하고,
Codex Skill 형식의 `SKILL.md`를 생성합니다.

기본적으로 아래 경로 중 존재하는 첫 번째 brain 루트를 사용합니다:
- `<repo>\\_scripts\\.ai_backup\\brain`
- `<repo>\\.ai_backup\\brain`
- `%USERPROFILE%\\.gemini\\antigravity\\brain`

.PARAMETER BrainRoot
brain 스냅샷(UUID 폴더들)이 들어있는 루트 경로.

.PARAMETER BrainId
특정 스냅샷 폴더(UUID). 미지정 시 `.md` 파일이 가장 많은 폴더를 우선 선택하고, 동률이면 최신 폴더를 선택합니다.

.PARAMETER SkillName
생성할 스킬 폴더 이름(소문자/숫자/하이픈 권장). 미지정 시 `mswproject-brain`.

.PARAMETER OutDir
레포 루트 기준 출력 폴더(기본 `skill`).

.PARAMETER InstallToCodex
생성한 스킬을 `%USERPROFILE%\\.codex\\skills\\<skill-name>`로도 복사합니다.

.PARAMETER Force
이미 출력 폴더가 존재하면 덮어씁니다.

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
        throw "SkillName이 비어있습니다. (입력값: '$Name')"
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
        throw "안전장치: 레포 루트를 삭제할 수 없습니다: $fullTarget"
    }

    if (-not $fullTarget.StartsWith($fullRepo, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "안전장치: 레포 바깥 경로는 삭제할 수 없습니다: $fullTarget"
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
        throw "BrainRoot를 찾지 못했습니다. -BrainRoot로 경로를 지정하세요. (기본 탐색: _scripts/.ai_backup/brain, .ai_backup/brain, ~/.gemini/antigravity/brain)"
    }

    $BrainRoot = $candidateRoots[0]
}

$BrainRoot = (Resolve-Path $BrainRoot).Path

$brainDirs = Get-ChildItem -Path $BrainRoot -Directory -Force
if (-not $brainDirs -or $brainDirs.Count -eq 0) {
    throw "brain 스냅샷 폴더가 없습니다: $BrainRoot"
}

if ($BrainId) {
    $selected = $brainDirs | Where-Object { $_.Name -eq $BrainId } | Select-Object -First 1
    if (-not $selected) {
        throw "BrainId '$BrainId'를 찾지 못했습니다: $BrainRoot"
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
        throw "이미 출력 폴더가 존재합니다: $outSkillDir (덮어쓰려면 -Force)"
    }

    Assert-SafeToRemove -PathToRemove $outSkillDir -RepoRoot $repoRoot
    Remove-Item -LiteralPath $outSkillDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $brainRefsDir | Out-Null
New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null

# 1) brain 문서(.md) 복사
$mdFiles = Get-ChildItem -Path $brainDir.FullName -File -Force -Filter "*.md"
foreach ($f in $mdFiles) {
    Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $brainRefsDir $f.Name) -Force
}

# 2) file:// 절대경로 링크를 상대경로로 치환 (복사본만 수정)
$copiedMd = Get-ChildItem -Path $brainRefsDir -File -Force -Filter "*.md"
foreach ($f in $copiedMd) {
    $text = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
    $rewritten = $text

    # 예: file:///c:/Users/<user>/.gemini/antigravity/brain/<uuid>/task.md -> ./task.md
    $rewritten = $rewritten -replace "(?i)file:///c:/users/[^/]+/\.gemini/antigravity/(brain|knowledge)/[^/]+/", "./"

    if ($rewritten -ne $text) {
        Set-Content -LiteralPath $f.FullName -Value $rewritten -Encoding UTF8
    }
}

# 3) SKILL.md 생성
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
description: Antigravity brain 백업(.md)을 Codex Skill 참고자료로 제공. MapleStory Worlds(MSW) API/컴포넌트/서비스/Lua 스크립팅 질문, 프로젝트 규칙 확인, Antigravity brain 문서 검색/요약이 필요할 때 사용.
---

# {1}

## 개요

이 스킬은 레포에 저장된 Antigravity brain 문서들을 `references/`로 제공해, Codex가 작업 중 근거 문서를 빠르게 찾고 요약할 수 있게 합니다.

## 사용

1. `references/brain/`에서 키워드로 검색해 관련 문서를 찾습니다.
2. 답변은 문서 내용을 우선으로 하고, 불명확하면 사용자에게 확인 질문을 합니다.

### 시작 문서(추천)

- `{2}`

## 참고

- Brain 문서: `references/brain/*.md`
'@

$skillMd = $skillMdTemplate -f $SkillName, $skillTitle, $entryRef

Set-Content -LiteralPath (Join-Path $outSkillDir "SKILL.md") -Value $skillMd -Encoding UTF8

$openaiYamlTemplate = @'
interface:
  display_name: "{0}"
  short_description: "Antigravity brain 지식/규칙"
'@

$openaiYaml = $openaiYamlTemplate -f $skillTitle

Set-Content -LiteralPath (Join-Path $agentsDir "openai.yaml") -Value $openaiYaml -Encoding UTF8

Write-Host "Skill 생성 완료: $outSkillDir"

if ($InstallToCodex) {
    $codexRoot = Join-Path $env:USERPROFILE ".codex\\skills"
    $dest = Join-Path $codexRoot $SkillName

    if (Test-Path $dest) {
        if (-not $Force) {
            throw "Codex 스킬 경로가 이미 존재합니다: $dest (덮어쓰려면 -Force)"
        }
        Remove-Item -LiteralPath $dest -Recurse -Force
    }

    New-Item -ItemType Directory -Force -Path $codexRoot | Out-Null
    Copy-Item -LiteralPath $outSkillDir -Destination $dest -Recurse -Force
    Write-Host "Codex 설치 완료: $dest"
}

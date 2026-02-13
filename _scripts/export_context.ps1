# AI Context Export Script v2.0 (모듈별 내보내기 지원)
# 사용법:
#   .\export_context.ps1           → 전체 내보내기
#   .\export_context.ps1 -Module combat  → 전투 모듈만 내보내기
#   .\export_context.ps1 -Module core,ui → 여러 모듈 지정

param(
    [string[]]$Module = @()   # 비어있으면 전체 내보내기
)

# --- 모듈별 키워드 매핑 (PROJECT_STRUCTURE.md 기준) ---
$moduleKeywords = @{
    "core"    = @("ECP", "Entity", "Component", "Lifecycle", "OnBeginPlay", "OnUpdate", "Property", "아키텍처")
    "combat"  = @("Attack", "Hit", "Damage", "Skill", "Battle", "전투", "CalcDamage", "HitComponent", "AttackComponent")
    "vn"      = @("VisualNovel", "Dialog", "Scene", "Story", "비주얼", "대화", "노벨")
    "ui"      = @("UI", "Button", "TextInput", "Tween", "애니메이션", "인터페이스")
    "data"    = @("DataStorage", "Save", "Load", "Schema", "JSON", "저장", "데이터")
    "physics" = @("Rigidbody", "Collider", "TileMap", "Joint", "물리", "이동", "Physics")
    "infra"   = @("Git", "Script", "Sync", "Export", "DevOps", "동기화", "스크립트")
}

$aiRoot = "$env:USERPROFILE\.gemini\antigravity"
$repoRoot = Split-Path -Parent $PSScriptRoot

$isModuleMode = $Module.Count -gt 0
if ($isModuleMode) {
    $moduleList = $Module -join ", "
    $exportFile = Join-Path $repoRoot "AI_CONTEXT_EXPORT_$($Module -join '_').md"
    Write-Host "🎯 모듈 필터 모드: [$moduleList]"
}
else {
    $exportFile = Join-Path $repoRoot "AI_CONTEXT_EXPORT.md"
    Write-Host "📦 전체 내보내기 모드"
}

if (-not (Test-Path "$aiRoot\brain")) {
    Write-Error "AI 브레인 데이터 폴더를 찾을 수 없습니다."
    return
}

# --- 모듈 필터 함수 ---
function Test-ModuleMatch {
    param([string]$Content, [string[]]$Modules)
    if ($Modules.Count -eq 0) { return $true }  # 전체 모드

    foreach ($mod in $Modules) {
        $keywords = $moduleKeywords[$mod]
        if ($null -eq $keywords) {
            Write-Warning "알 수 없는 모듈: $mod (사용 가능: $($moduleKeywords.Keys -join ', '))"
            continue
        }
        foreach ($kw in $keywords) {
            if ($Content -match [regex]::Escape($kw)) { return $true }
        }
    }
    return $false
}

# --- 헤더 생성 ---
$exportContent = @"
# 📦 AI Context Export$(if ($isModuleMode) { " [$moduleList]" } else { " (전체)" })
> 자동 생성일: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
> 모드: $(if ($isModuleMode) { "모듈 필터 ($moduleList)" } else { "전체 히스토리" })

---

"@

$totalFiles = 0
$includedFiles = 0

# --- 1. 최신 세션 수집 ---
$latestSession = Get-ChildItem -Path "$aiRoot\brain" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($null -ne $latestSession) {
    Write-Host "✅ 최신 세션: $($latestSession.Name)"
    $priorityFiles = @("brain_summary.md", "task.md", "implementation_plan.md", "walkthrough.md")
    foreach ($fileName in $priorityFiles) {
        $filePath = Join-Path $latestSession.FullName $fileName
        if (Test-Path $filePath) {
            $content = Get-Content -Path $filePath -Raw
            $totalFiles++
            if (Test-ModuleMatch -Content $content -Modules $Module) {
                $exportContent += "`n## 📄 [최신] $fileName`n"
                $exportContent += "````markdown`n$content`n````"
                $exportContent += "`n---`n"
                $includedFiles++
            }
        }
    }
}

# --- 2. 모든 세션의 마크다운 파일 수집 ---
Write-Host "📚 모든 세션 검색 중..."
$allBrainFiles = Get-ChildItem -Path "$aiRoot\brain" -Filter *.md -Recurse | Where-Object {
    $_.Name -ne "custom_rules.md" -and
    $_.FullName -notmatch $latestSession.Name  # 최신 세션 중복 방지
}

foreach ($file in $allBrainFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $totalFiles++
    if (Test-ModuleMatch -Content $content -Modules $Module) {
        $sessionID = $file.Directory.Name.Substring(0, [Math]::Min(8, $file.Directory.Name.Length))
        $exportContent += "`n### 📂 [$sessionID] $($file.Name)`n"
        $exportContent += "````markdown`n$content`n````"
        $exportContent += "`n---`n"
        $includedFiles++
        Write-Host "📎 $($file.Name)"
    }
}

$exportContent += @"

## 📊 내보내기 통계
- 검색된 파일: $totalFiles 개
- 포함된 파일: $includedFiles 개
- 필터: $(if ($isModuleMode) { $moduleList } else { "없음 (전체)" })

## 🤖 다음 AI에게
이 파일은 프로젝트의 $(if ($isModuleMode) { "**$moduleList 모듈**" } else { "**전체**" }) 맥락을 담고 있습니다.
`AI_KNOWLEDGE_BRIDGE.md`와 `PROJECT_STRUCTURE.md`도 함께 참고하세요.
"@

# --- 파일 저장 ---
$exportContent | Out-File -FilePath $exportFile -Encoding utf8
Write-Host ""
Write-Host "✨ 내보내기 완료!"
Write-Host "   📄 파일: $exportFile"
Write-Host "   📊 $totalFiles 개 중 $includedFiles 개 포함됨"
if ($isModuleMode) {
    Write-Host "   💡 전체 내보내기: .\export_context.ps1"
}

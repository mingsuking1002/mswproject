# AI Context Export Script v2.0 (Module-based export support)
# Usage:
#   .\export_context.ps1                  -> Export all
#   .\export_context.ps1 -Module combat   -> Export combat module only
#   .\export_context.ps1 -Module core,ui  -> Export multiple modules

param(
    [string[]]$Module = @()
)

# --- Module keyword mapping (from PROJECT_STRUCTURE.md) ---
$moduleKeywords = @{
    "core"    = @("ECP", "Entity", "Component", "Lifecycle", "OnBeginPlay", "OnUpdate", "Property", "Architecture")
    "combat"  = @("Attack", "Hit", "Damage", "Skill", "Battle", "CalcDamage", "HitComponent", "AttackComponent", "Combat", "phase3")
    "vn"      = @("VisualNovel", "Dialog", "Scene", "Story", "VNScene", "Glassmorphism")
    "ui"      = @("UI", "Button", "TextInput", "Tween", "Animation", "TweenLogic", "Interface")
    "data"    = @("DataStorage", "Save", "Load", "Schema", "JSON", "Storage", "BatchSet")
    "physics" = @("Rigidbody", "Collider", "TileMap", "Joint", "Physics", "PrismaticJoint", "BodyType")
    "infra"   = @("Git", "Script", "Sync", "Export", "DevOps", "sync_ai", "export_context", "PowerShell")
}

$aiRoot = "$env:USERPROFILE\.gemini\antigravity"
$repoRoot = Split-Path -Parent $PSScriptRoot

# --- Output Directory ---
$outputDir = Join-Path $repoRoot "text"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
    Write-Host "[INIT] Created output directory: $outputDir"
}

$isModuleMode = $Module.Count -gt 0
if ($isModuleMode) {
    $moduleList = $Module -join ", "
    $exportFile = Join-Path $outputDir "AI_CONTEXT_EXPORT_$($Module -join '_').md"
    Write-Host "[MODULE MODE] Filter: $moduleList"
}
else {
    $exportFile = Join-Path $outputDir "AI_CONTEXT_EXPORT.md"
    Write-Host "[FULL MODE] Exporting all sessions..."
}

if (-not (Test-Path "$aiRoot\brain")) {
    Write-Error "Brain data folder not found at: $aiRoot\brain"
    return
}

# --- Module filter function ---
function Test-ModuleMatch {
    param([string]$Content, [string[]]$Modules)
    if ($Modules.Count -eq 0) { return $true }

    foreach ($mod in $Modules) {
        $keywords = $moduleKeywords[$mod]
        if ($null -eq $keywords) {
            Write-Warning "Unknown module: $mod (Available: $($moduleKeywords.Keys -join ', '))"
            continue
        }
        foreach ($kw in $keywords) {
            if ($Content -match [regex]::Escape($kw)) { return $true }
        }
    }
    return $false
}

# --- Build header ---
$modeLabel = if ($isModuleMode) { $moduleList } else { "Full History" }
$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$exportContent = "# AI Context Export ($modeLabel)`n"
$exportContent += "> Auto-generated: $now`n"
$exportContent += "> Mode: $modeLabel`n`n---`n"

$totalFiles = 0
$includedFiles = 0

# --- 1. Latest session ---
$latestSession = Get-ChildItem -Path "$aiRoot\brain" -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($null -ne $latestSession) {
    Write-Host "[OK] Latest session: $($latestSession.Name)"
    $priorityFiles = @("brain_summary.md", "task.md", "implementation_plan.md", "walkthrough.md")
    foreach ($fileName in $priorityFiles) {
        $filePath = Join-Path $latestSession.FullName $fileName
        if (Test-Path $filePath) {
            $content = Get-Content -Path $filePath -Raw -Encoding UTF8
            $totalFiles++
            if (Test-ModuleMatch -Content $content -Modules $Module) {
                $exportContent += "`n## [Latest] $fileName`n"
                $exportContent += "``````markdown`n$content`n```````n"
                $exportContent += "`n---`n"
                $includedFiles++
            }
        }
    }
}

# --- 2. All sessions ---
Write-Host "[SCAN] Searching all sessions..."
$allBrainFiles = Get-ChildItem -Path "$aiRoot\brain" -Filter *.md -Recurse -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -ne "custom_rules.md" -and
    ($null -eq $latestSession -or $_.FullName -notmatch [regex]::Escape($latestSession.Name))
}

foreach ($file in $allBrainFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $totalFiles++
    if (Test-ModuleMatch -Content $content -Modules $Module) {
        $shortId = $file.Directory.Name
        if ($shortId.Length -gt 8) { $shortId = $shortId.Substring(0, 8) }
        $exportContent += "`n### [$shortId] $($file.Name)`n"
        $exportContent += "``````markdown`n$content`n```````n"
        $exportContent += "`n---`n"
        $includedFiles++
        Write-Host "  + $($file.Name)"
    }
}

# --- 3. Codex Chat Export (Clipboard-based) ---
# NOTE: Codex는 채팅 로그에 직접 접근할 수 없어서, 사용자가 복사(Ctrl+C)한 텍스트를
# `export_chat_clipboard.ps1`로 저장한 파일을 여기서 병합합니다.
$codexChatFiles = Get-ChildItem -Path $outputDir -Filter "CODEX_CHAT_EXPORT_*.md" -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime

if ($null -ne $codexChatFiles -and $codexChatFiles.Count -gt 0) {
    Write-Host "[MERGE] Including Codex chat exports: $($codexChatFiles.Count) file(s)"
    $exportContent += "`n## Codex Chat Exports`n"

    foreach ($chatFile in $codexChatFiles) {
        $chatContent = Get-Content -Path $chatFile.FullName -Raw -Encoding UTF8
        $totalFiles++
        if (Test-ModuleMatch -Content $chatContent -Modules $Module) {
            $exportContent += "`n### [Codex] $($chatFile.Name)`n"
            $exportContent += "``````markdown`n$chatContent`n```````n"
            $exportContent += "`n---`n"
            $includedFiles++
        }
    }
}

$exportContent += "`n## Export Stats`n"
$exportContent += "- Scanned: $totalFiles files`n"
$exportContent += "- Included: $includedFiles files`n"
$exportContent += "- Filter: $modeLabel`n`n"
$exportContent += "## For the next AI`n"
$exportContent += "This file contains the **$modeLabel** context of the project.`n"
$exportContent += "Also refer to ``AI_KNOWLEDGE_BRIDGE.md`` and ``PROJECT_STRUCTURE.md``.`n"

# --- Save ---
$exportContent | Out-File -FilePath $exportFile -Encoding utf8
Write-Host ""
Write-Host "[DONE] Export complete!"
Write-Host "  File: $exportFile"
Write-Host "  Stats: $includedFiles / $totalFiles files included"
if ($isModuleMode) {
    Write-Host "  Tip: Run without -Module for full export"
}

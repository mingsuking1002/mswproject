# Skill to Brain Loader Script
# 용도: Codex의 Skill을 현재 작업 폴더(text/imported_skills)로 가져와서 Brain이 학습할 수 있게 함.
# 사용법: .\skill_to_brain.ps1 -SkillName mswproject-brain

param(
    [string]$SkillName
)

$codexSkillRoot = Join-Path $env:USERPROFILE ".codex\skills"
$repoRoot = Split-Path -Parent $PSScriptRoot

# --- 1. 저장할 폴더 생성 (text/imported_skills) ---
$outputDir = Join-Path $repoRoot "text\imported_skills"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
    Write-Host "[INIT] Created import directory: $outputDir"
}

# --- 2. 스킬 찾기 ---
if ([string]::IsNullOrWhiteSpace($SkillName)) {
    Write-Host "사용 가능한 스킬 목록:"
    Get-ChildItem -Path $codexSkillRoot -Directory | ForEach-Object { Write-Host " - $($_.Name)" }
    Write-Error "스킬 이름을 입력해주세요. (예: .\skill_to_brain.ps1 -SkillName mswproject-brain)"
    return
}

$srcSkillDir = Join-Path $codexSkillRoot $SkillName
if (-not (Test-Path $srcSkillDir)) {
    Write-Error "스킬을 찾을 수 없습니다: $srcSkillDir"
    return
}

# --- 3. 스킬 내용 변환 및 복사 ---
$destDir = Join-Path $outputDir $SkillName
if (Test-Path $destDir) {
    Remove-Item -Path $destDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $destDir | Out-Null

Write-Host "📥 스킬 가져오는 중: $SkillName"
Get-ChildItem -Path $srcSkillDir -Recurse -File | ForEach-Object {
    $relPath = $_.FullName.Substring($srcSkillDir.Length + 1)
    $destFile = Join-Path $destDir $relPath
    $destParent = Split-Path -Parent $destFile
    
    if (-not (Test-Path $destParent)) {
        New-Item -ItemType Directory -Force -Path $destParent | Out-Null
    }
    
    Copy-Item -Path $_.FullName -Destination $destFile -Force
    Write-Host "  + $relPath"
}

# --- 4. 요약 생성 (선택 사항) ---
$summaryFile = Join-Path $outputDir "import_summary.md"
$logContent = "## [$((Get-Date).ToString('yyyy-MM-dd HH:mm'))] Skill Imported: $SkillName`n"
$logContent += "- Source: $srcSkillDir`n"
$logContent += "- Destination: $destDir`n"
$logContent += "- Files: $( (Get-ChildItem $destDir -Recurse -File).Count ) files`n`n"
Add-Content -Path $summaryFile -Value $logContent

Write-Host ""
Write-Host "✨ 완료! 스킬이 다음 폴더에 저장되었습니다:"
Write-Host "   📂 $destDir"
Write-Host "💡 이제 '이 폴더($destDir)의 내용을 읽고 학습해'라고 저에게 지시하시면 됩니다."

# Skill to Brain Loader Script
# Usage: .\skill_to_brain.ps1 -SkillName mswproject-brain

param(
    [string]$SkillName
)

$codexSkillRoot = Join-Path $env:USERPROFILE ".codex\skills"
$repoRoot = Split-Path -Parent $PSScriptRoot

# --- 1. Create import directory (text/imported_skills) ---
$outputDir = Join-Path $repoRoot "text\imported_skills"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
    Write-Host "[INIT] Created import directory: $outputDir"
}

# --- 2. Find Source Skill ---
if ([string]::IsNullOrWhiteSpace($SkillName)) {
    Write-Host "Available Skills:"
    Get-ChildItem -Path $codexSkillRoot -Directory | ForEach-Object { Write-Host " - $($_.Name)" }
    Write-Error "Please provide a SkillName. (e.g. .\skill_to_brain.ps1 -SkillName mswproject-brain)"
    return
}

$srcSkillDir = Join-Path $codexSkillRoot $SkillName
if (-not (Test-Path $srcSkillDir)) {
    Write-Error "Skill not found: $srcSkillDir"
    return
}

# --- 3. Copy Skill Content ---
$destDir = Join-Path $outputDir $SkillName
if (Test-Path $destDir) {
    Remove-Item -Path $destDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $destDir | Out-Null

Write-Host "[IMPORT] Importing skill: $SkillName"
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

# --- 4. Create Summary ---
$summaryFile = Join-Path $outputDir "import_summary.md"
$logContent = "## [$((Get-Date).ToString('yyyy-MM-dd HH:mm'))] Skill Imported: $SkillName`n"
$logContent += "- Source: $srcSkillDir`n"
$logContent += "- Destination: $destDir`n"
$logContent += "- Files: $( (Get-ChildItem $destDir -Recurse -File).Count ) files`n`n"
Add-Content -Path $summaryFile -Value $logContent

Write-Host ""
Write-Host "[DONE] Skill imported successfully!"
Write-Host "   Dir: $destDir"
Write-Host "Tip: You can now ask me to 'read and learn from this folder'."

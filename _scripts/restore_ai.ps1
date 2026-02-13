# Restore AI Memory from Repo (Restore)
# Run this on a NEW PC or to revert AI memory to the repo state.

$aiRoot = "$env:USERPROFILE\.gemini\antigravity"
$repoRoot = Split-Path -Parent $PSScriptRoot
$backupDir = Join-Path $PSScriptRoot ".ai_backup"

# 1. Restore AI data (Repo -> System)
Write-Host "Restoring AI data (brain/knowledge/conversations/annotations) from backup..."
if (Test-Path "$backupDir\brain") {
    if (!(Test-Path "$aiRoot\brain")) { New-Item -ItemType Directory -Force -Path "$aiRoot\brain" | Out-Null }
    Copy-Item -Path "$backupDir\brain\*" -Destination "$aiRoot\brain" -Recurse -Force
}
if (Test-Path "$backupDir\knowledge") {
    if (!(Test-Path "$aiRoot\knowledge")) { New-Item -ItemType Directory -Force -Path "$aiRoot\knowledge" | Out-Null }
    Copy-Item -Path "$backupDir\knowledge\*" -Destination "$aiRoot\knowledge" -Recurse -Force
}
if (Test-Path "$backupDir\conversations") {
    if (!(Test-Path "$aiRoot\conversations")) { New-Item -ItemType Directory -Force -Path "$aiRoot\conversations" | Out-Null }
    Copy-Item -Path "$backupDir\conversations\*" -Destination "$aiRoot\conversations" -Recurse -Force
}
if (Test-Path "$backupDir\annotations") {
    if (!(Test-Path "$aiRoot\annotations")) { New-Item -ItemType Directory -Force -Path "$aiRoot\annotations" | Out-Null }
    Copy-Item -Path "$backupDir\annotations\*" -Destination "$aiRoot\annotations" -Recurse -Force
}

# 2. Sync Custom Rules (Repo -> System)
$rulesFile = Join-Path $repoRoot "custom_rules.md"
if (Test-Path $rulesFile) {
    Write-Host "Restoring AI Custom Rules..."
    Get-ChildItem -Path "$aiRoot\brain" -Directory | ForEach-Object {
        Copy-Item -Path $rulesFile -Destination "$($_.FullName)\custom_rules.md" -Force
    }
}

Write-Host "Restore Complete! AI memory is now synced with this repository."

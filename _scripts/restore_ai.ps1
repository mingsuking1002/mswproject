# Restore AI Memory from Repo (Restore)
# Run this on a NEW PC or to revert AI memory to the repo state.

$aiRoot = "$env:USERPROFILE\.gemini\antigravity"
$repoRoot = Get-Location
$backupDir = "$repoRoot\.ai_backup"

# 1. Restore Brain & Knowledge (Repo -> System)
Write-Host "Restoring AI Brain and Knowledge from Backup..."
if (Test-Path "$backupDir\brain") {
    if (!(Test-Path "$aiRoot\brain")) { New-Item -ItemType Directory -Force -Path "$aiRoot\brain" | Out-Null }
    Copy-Item -Path "$backupDir\brain\*" -Destination "$aiRoot\brain" -Recurse -Force
}
if (Test-Path "$backupDir\knowledge") {
    if (!(Test-Path "$aiRoot\knowledge")) { New-Item -ItemType Directory -Force -Path "$aiRoot\knowledge" | Out-Null }
    Copy-Item -Path "$backupDir\knowledge\*" -Destination "$aiRoot\knowledge" -Recurse -Force
}

# 2. Sync Custom Rules (Repo -> System)
$rulesFile = "$repoRoot\custom_rules.md"
if (Test-Path $rulesFile) {
    Write-Host "Restoring AI Custom Rules..."
    Get-ChildItem -Path "$aiRoot\brain" -Directory | ForEach-Object {
        Copy-Item -Path $rulesFile -Destination "$($_.FullName)\custom_rules.md" -Force
    }
}

Write-Host "Restore Complete! AI memory is now synced with this repository."

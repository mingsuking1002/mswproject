# Sync AI Memory to Repo (Backup) & Rules to AI (Update)
# Run this BEFORE modifying code or committing to Git.

$aiRoot = "$env:USERPROFILE\.gemini\antigravity"
$repoRoot = Split-Path -Parent $PSScriptRoot
$backupDir = Join-Path $PSScriptRoot ".ai_backup"

# 1. Backup AI data (System -> Repo)
Write-Host "Backing up AI data (brain/knowledge/conversations/annotations)..."
if (Test-Path "$aiRoot\brain") {
    New-Item -ItemType Directory -Force -Path "$backupDir\brain" | Out-Null
    Copy-Item -Path "$aiRoot\brain\*" -Destination "$backupDir\brain" -Recurse -Force
}
if (Test-Path "$aiRoot\knowledge") {
    New-Item -ItemType Directory -Force -Path "$backupDir\knowledge" | Out-Null
    Copy-Item -Path "$aiRoot\knowledge\*" -Destination "$backupDir\knowledge" -Recurse -Force
}
if (Test-Path "$aiRoot\conversations") {
    New-Item -ItemType Directory -Force -Path "$backupDir\conversations" | Out-Null
    Copy-Item -Path "$aiRoot\conversations\*" -Destination "$backupDir\conversations" -Recurse -Force
}
if (Test-Path "$aiRoot\annotations") {
    New-Item -ItemType Directory -Force -Path "$backupDir\annotations" | Out-Null
    Copy-Item -Path "$aiRoot\annotations\*" -Destination "$backupDir\annotations" -Recurse -Force
}

# 2. Sync Custom Rules (Repo -> System)
# This allows you to edit rules in the repo and have the AI use them.
$rulesFile = Join-Path $repoRoot "custom_rules.md"
if (Test-Path $rulesFile) {
    Write-Host "Updating AI Custom Rules..."
    # Copy to all brain subdirectories to ensure it's picked up
    Get-ChildItem -Path "$aiRoot\brain" -Directory | ForEach-Object {
        Copy-Item -Path $rulesFile -Destination "$($_.FullName)\custom_rules.md" -Force
    }
}

Write-Host "Sync Complete! You can now commit your changes."

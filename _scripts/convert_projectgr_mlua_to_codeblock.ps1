param(
    [string]$ComponentsDir = "mswproject/RootDesk/MyDesk/ProjectGR/Components",
    [switch]$KeepMlua
)

$ErrorActionPreference = "Stop"

function Convert-MluaPair {
    param(
        [System.IO.FileInfo]$MluaFile
    )

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($MluaFile.Name)
    $codeblockPath = Join-Path $MluaFile.DirectoryName ($baseName + ".codeblock")

    if (-not (Test-Path -Path $codeblockPath)) {
        throw "Missing paired .codeblock file: $codeblockPath"
    }

    # Force plain string to avoid PowerShell ETS note properties being serialized.
    $scriptSource = [string](Get-Content -Path $MluaFile.FullName -Encoding UTF8 -Raw)
    $codeblockText = Get-Content -Path $codeblockPath -Encoding UTF8 -Raw

    if ([string]::IsNullOrWhiteSpace($codeblockText)) {
        throw "Invalid .codeblock content: $codeblockPath"
    }

    # Convert source text to a JSON-safe string so it can be stored in Target.
    $escapedSource = $scriptSource | ConvertTo-Json -Compress

    $updated = [regex]::Replace($codeblockText, '"Source"\s*:\s*\d+', '"Source": 1', 1)

    $updatedTarget = [regex]::Replace($updated, '"Target"\s*:\s*null', '"Target": ' + $escapedSource, 1)
    if ($updatedTarget -eq $updated) {
        $updatedTarget = [regex]::Replace(
            $updated,
            '"Target"\s*:\s*"(?:\\\\.|[^"])*"',
            '"Target": ' + $escapedSource,
            1
        )
    }

    if ($updatedTarget -eq $updated) {
        throw "Target field not found in .codeblock: $codeblockPath"
    }

    Set-Content -Path $codeblockPath -Encoding UTF8 -Value $updatedTarget

    if (-not $KeepMlua) {
        Remove-Item -Path $MluaFile.FullName -Force
    }

    Write-Host ("[UPDATED] {0}" -f $baseName)
}

$resolvedDir = (Resolve-Path -Path $ComponentsDir).Path
$mluaFiles = Get-ChildItem -Path $resolvedDir -Filter "*.mlua" -Recurse | Sort-Object FullName

if ($mluaFiles.Count -eq 0) {
    Write-Host "[INFO] No .mlua files found."
    exit 0
}

foreach ($mluaFile in $mluaFiles) {
    Convert-MluaPair -MluaFile $mluaFile
}

Write-Host ("[DONE] Converted {0} files." -f $mluaFiles.Count)

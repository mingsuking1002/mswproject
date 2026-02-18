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

    $targetIndex = $codeblockText.IndexOf('"Target"')
    if ($targetIndex -lt 0) {
        throw "Target field not found in .codeblock: $codeblockPath"
    }

    $prefix = $codeblockText.Substring(0, $targetIndex)
    $prefix = [regex]::Replace($prefix, '"Source"\s*:\s*\d+', '"Source": 1', 1)

    $rebuilt = $prefix + '"Target": ' + $escapedSource + "`r`n    }`r`n  }`r`n}`r`n"
    Set-Content -Path $codeblockPath -Encoding UTF8 -Value $rebuilt

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

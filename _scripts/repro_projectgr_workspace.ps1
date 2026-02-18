param(
    [switch]$Fix
)

$ErrorActionPreference = "Stop"

function Write-Result {
    param(
        [string]$Level,
        [string]$Message
    )
    Write-Host ("[{0}] {1}" -f $Level, $Message)
}

function Read-FirstLine {
    param(
        [string]$Path
    )

    $line = Get-Content -Path $Path -Encoding UTF8 -TotalCount 1
    if ($null -eq $line) {
        return ""
    }
    if ($line -is [array]) {
        if ($line.Count -eq 0) {
            return ""
        }
        return [string]$line[0]
    }
    return [string]$line
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Join-Path $repoRoot "mswproject"
$manifestPath = Join-Path $projectRoot "RootDesk\MyDesk\ProjectGR\REPRO_MANIFEST.json"
$agentsPath = Join-Path $repoRoot "AGENTS.md"
$worldConfigPath = Join-Path $projectRoot "Global\WorldConfig.config"

if (-not (Test-Path -Path $manifestPath)) {
    throw "Manifest not found: $manifestPath"
}

$manifest = Get-Content -Path $manifestPath -Encoding UTF8 -Raw | ConvertFrom-Json

$documentationRelative = $manifest.documentation_path
if ([string]::IsNullOrWhiteSpace($documentationRelative)) {
    $documentationRelative = "Code_Documentation.md"
}
$documentationPath = Join-Path $projectRoot $documentationRelative

$missing = New-Object System.Collections.Generic.List[string]
$invalid = New-Object System.Collections.Generic.List[string]
$fixed = New-Object System.Collections.Generic.List[string]

Write-Result "INFO" "Project Root: $projectRoot"
Write-Result "INFO" "Using Manifest: $manifestPath"

foreach ($relativePath in $manifest.required_files) {
    $fullPath = Join-Path $projectRoot $relativePath
    if (-not (Test-Path -Path $fullPath)) {
        $missing.Add($relativePath)
    }
}

if (Test-Path -Path $worldConfigPath) {
    try {
        [void](Get-Content -Path $worldConfigPath -Encoding UTF8 -Raw | ConvertFrom-Json)
    }
    catch {
        $invalid.Add(("Global/WorldConfig.config (invalid json: {0})" -f $_.Exception.Message))
    }
}
else {
    $missing.Add("Global/WorldConfig.config")
}

foreach ($relativePath in $manifest.required_files) {
    if ($relativePath -notlike "*.codeblock") {
        continue
    }

    $fullPath = Join-Path $projectRoot $relativePath
    if (-not (Test-Path -Path $fullPath)) {
        continue
    }

    try {
        $codeblock = Get-Content -Path $fullPath -Encoding UTF8 -Raw | ConvertFrom-Json
        $scriptJson = $codeblock.ContentProto.Json

        if ($scriptJson.Source -eq 1) {
            $target = $scriptJson.Target
            if (-not ($target -is [string]) -or [string]::IsNullOrWhiteSpace($target)) {
                $invalid.Add(("{0} (Source=1 requires Target script text)" -f $relativePath))
            }
        }
        elseif ($scriptJson.Source -eq 0) {
            $mluaRelativePath = [System.IO.Path]::ChangeExtension($relativePath, ".mlua")
            $mluaFullPath = Join-Path $projectRoot $mluaRelativePath
            if (-not (Test-Path -Path $mluaFullPath)) {
                $invalid.Add(("{0} (Source=0 requires paired .mlua: {1})" -f $relativePath, $mluaRelativePath))
            }
            else {
                $mluaText = Get-Content -Path $mluaFullPath -Encoding UTF8 -Raw
                if ([string]::IsNullOrWhiteSpace($mluaText)) {
                    $invalid.Add(("{0} (paired .mlua is empty: {1})" -f $relativePath, $mluaRelativePath))
                }
            }
        }
        else {
            $invalid.Add(("{0} (unsupported Source value: {1})" -f $relativePath, $scriptJson.Source))
        }
    }
    catch {
        $invalid.Add(("{0} (invalid codeblock json: {1})" -f $relativePath, $_.Exception.Message))
    }
}

if ($null -ne $manifest.required_map_checks) {
    foreach ($mapCheck in $manifest.required_map_checks) {
        $mapRelative = $mapCheck.map_file
        $mapFullPath = Join-Path $projectRoot $mapRelative

        if (-not (Test-Path -Path $mapFullPath)) {
            $missing.Add($mapRelative)
            continue
        }

        try {
            $mapData = Get-Content -Path $mapFullPath -Encoding UTF8 -Raw | ConvertFrom-Json
        }
        catch {
            $invalid.Add(("{0} (invalid json: {1})" -f $mapRelative, $_.Exception.Message))
            continue
        }

        $entities = $mapData.ContentProto.Entities
        if ($null -eq $entities) {
            $invalid.Add(("{0} (missing ContentProto.Entities)" -f $mapRelative))
            continue
        }

        foreach ($entityPath in $mapCheck.entity_paths) {
            $foundPath = $false
            foreach ($entity in $entities) {
                if ($entity.path -eq $entityPath) {
                    $foundPath = $true
                    break
                }
            }

            if (-not $foundPath) {
                $invalid.Add(("{0} missing entity path: {1}" -f $mapRelative, $entityPath))
            }
        }

        foreach ($componentName in $mapCheck.component_names) {
            $candidateNames = New-Object System.Collections.Generic.List[string]
            $candidateNames.Add($componentName)
            if ($componentName.StartsWith("script.")) {
                $candidateNames.Add($componentName.Substring(7))
            }
            else {
                $candidateNames.Add("script." + $componentName)
            }

            $foundComponent = $false
            foreach ($entity in $entities) {
                $componentNames = $entity.componentNames
                if ($null -ne $componentNames) {
                    $splitNames = $componentNames -split ","
                    foreach ($candidateName in $candidateNames) {
                        if ($splitNames -contains $candidateName) {
                            $foundComponent = $true
                            break
                        }
                    }
                    if ($foundComponent) {
                        break
                    }
                }

                $components = $entity.jsonString.'@components'
                if ($null -eq $components) {
                    continue
                }
                foreach ($component in $components) {
                    foreach ($candidateName in $candidateNames) {
                        if ($component.'@type' -eq $candidateName) {
                            $foundComponent = $true
                            break
                        }
                    }
                    if ($foundComponent) {
                        break
                    }
                }

                if ($foundComponent) {
                    break
                }
            }

            if (-not $foundComponent) {
                $invalid.Add(("{0} missing component type: {1}" -f $mapRelative, $componentName))
            }
        }
    }
}

foreach ($spec in $manifest.required_specs) {
    $specPath = Join-Path $projectRoot $spec.path
    if (-not (Test-Path -Path $specPath)) {
        $missing.Add($spec.path)
        continue
    }

    $firstLine = Read-FirstLine -Path $specPath
    if ($firstLine -ne $spec.expected_status) {
        if ($Fix) {
            $contents = Get-Content -Path $specPath -Encoding UTF8
            if ($contents.Count -gt 0) {
                $contents[0] = $spec.expected_status
                Set-Content -Path $specPath -Value $contents -Encoding UTF8
                $fixed.Add($spec.path)
            }
            else {
                $invalid.Add(("{0} (empty file)" -f $spec.path))
            }
        }
        else {
            $invalid.Add(("{0} (expected '{1}', got '{2}')" -f $spec.path, $spec.expected_status, $firstLine))
        }
    }
}

if (Test-Path -Path $documentationPath) {
    $documentation = Get-Content -Path $documentationPath -Encoding UTF8 -Raw
    foreach ($section in $manifest.required_doc_sections) {
        $pattern = "## [$section]"
        if ($documentation -notmatch [regex]::Escape($pattern)) {
            $invalid.Add(("Code_Documentation.md missing section: {0}" -f $section))
        }
    }
}
else {
    $missing.Add("기획서/4.부록/Code_Documentation.md")
}

if (Test-Path -Path $agentsPath) {
    $agentsContent = Get-Content -Path $agentsPath -Encoding UTF8 -Raw
    if ($agentsContent -notmatch [regex]::Escape($manifest.required_agents_pattern)) {
        $invalid.Add(("AGENTS.md missing pattern: {0}" -f $manifest.required_agents_pattern))
    }
}
else {
    $missing.Add("AGENTS.md")
}

if ($fixed.Count -gt 0) {
    Write-Result "FIXED" ("SPEC status updated: {0}" -f ($fixed -join ", "))
}

if ($missing.Count -gt 0) {
    foreach ($item in $missing) {
        Write-Result "MISSING" $item
    }
}

if ($invalid.Count -gt 0) {
    foreach ($item in $invalid) {
        Write-Result "INVALID" $item
    }
}

if ($missing.Count -eq 0 -and $invalid.Count -eq 0) {
    Write-Result "PASS" "Project GR workspace reproduction check passed."
    exit 0
}

Write-Result "FAIL" "Project GR workspace reproduction check failed."
if (-not $Fix) {
    Write-Result "INFO" "Run with -Fix to auto-correct SPEC status lines."
}
exit 1

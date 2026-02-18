param(
    [string]$SessionJsonl = "C:\Users\ksh00\.codex\sessions\2026\02\18\rollout-2026-02-18T02-29-25-019c6ca6-531e-7023-9c66-876f08e93cc2.jsonl"
)

$ErrorActionPreference = "Stop"

$targetFiles = @(
    "mswproject/RootDesk/MyDesk/ProjectGR/Components/CameraFollowComponent.mlua",
    "mswproject/RootDesk/MyDesk/ProjectGR/Components/HPSystemComponent.mlua",
    "mswproject/RootDesk/MyDesk/ProjectGR/Components/LobbyFlowComponent.mlua",
    "mswproject/RootDesk/MyDesk/ProjectGR/Components/Map01BootstrapComponent.mlua",
    "mswproject/RootDesk/MyDesk/ProjectGR/Components/SpeedrunTimerComponent.mlua",
    "mswproject/RootDesk/MyDesk/ProjectGR/Components/TagManagerComponent.mlua",
    "mswproject/RootDesk/MyDesk/ProjectGR/Components/WeaponSwapComponent.mlua"
)

if (-not (Test-Path -Path $SessionJsonl)) {
    throw "Session file not found: $SessionJsonl"
}

function Normalize-Newline {
    param([string]$Text)
    if ($null -eq $Text) {
        return ""
    }
    return ($Text -replace "`r", "")
}

function Split-Lines {
    param([string]$Text)
    $normalized = Normalize-Newline -Text $Text
    if ($normalized -eq "") {
        return @()
    }
    return $normalized -split "`n", 0, "SimpleMatch"
}

function Ensure-ParentDirectory {
    param([string]$Path)
    $parent = Split-Path -Parent $Path
    if ([string]::IsNullOrWhiteSpace($parent)) {
        return
    }
    if (-not (Test-Path -Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
}

function Write-TextFile {
    param(
        [string]$Path,
        [string]$Content
    )
    Ensure-ParentDirectory -Path $Path
    [System.IO.File]::WriteAllText((Resolve-Path -LiteralPath ".\" -ErrorAction Stop).Path + "\" + $Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

function Read-TextFileLines {
    param([string]$Path)
    if (-not (Test-Path -Path $Path)) {
        return @()
    }
    $text = Get-Content -Path $Path -Encoding UTF8 -Raw
    return Split-Lines -Text $text
}

function Find-SequenceIndex {
    param(
        [string[]]$Haystack,
        [string[]]$Needle,
        [int]$StartIndex
    )

    if ($Needle.Count -eq 0) {
        return $StartIndex
    }
    if ($Haystack.Count -eq 0) {
        return -1
    }

    $maxStart = $Haystack.Count - $Needle.Count
    if ($maxStart -lt $StartIndex) {
        return -1
    }

    for ($i = $StartIndex; $i -le $maxStart; $i++) {
        $matched = $true
        for ($j = 0; $j -lt $Needle.Count; $j++) {
            if ($Haystack[$i + $j] -ne $Needle[$j]) {
                $matched = $false
                break
            }
        }
        if ($matched) {
            return $i
        }
    }

    return -1
}

function Apply-Hunks {
    param(
        [string]$FilePath,
        [System.Collections.Generic.List[object]]$Hunks
    )

    $currentLines = New-Object System.Collections.Generic.List[string]
    foreach ($line in (Read-TextFileLines -Path $FilePath)) {
        [void]$currentLines.Add($line)
    }

    $searchStart = 0

    foreach ($hunk in $Hunks) {
        $oldLines = $hunk.OldLines
        $newLines = $hunk.NewLines

        $oldArr = @()
        foreach ($l in $oldLines) {
            $oldArr += [string]$l
        }
        $newArr = @()
        foreach ($l in $newLines) {
            $newArr += [string]$l
        }

        $idx = Find-SequenceIndex -Haystack $currentLines.ToArray() -Needle $oldArr -StartIndex $searchStart
        if ($idx -lt 0) {
            # Fallback: search from beginning.
            $idx = Find-SequenceIndex -Haystack $currentLines.ToArray() -Needle $oldArr -StartIndex 0
        }
        if ($idx -lt 0) {
            # If new block already exists, treat this hunk as already applied and continue.
            $idxNew = Find-SequenceIndex -Haystack $currentLines.ToArray() -Needle $newArr -StartIndex $searchStart
            if ($idxNew -lt 0) {
                $idxNew = Find-SequenceIndex -Haystack $currentLines.ToArray() -Needle $newArr -StartIndex 0
            }
            if ($idxNew -ge 0) {
                $searchStart = $idxNew + $newArr.Count
                continue
            }

            throw "Failed to apply hunk for $FilePath (context not found)."
        }

        # Remove old block
        for ($i = 0; $i -lt $oldArr.Count; $i++) {
            $currentLines.RemoveAt($idx)
        }

        # Insert new block
        for ($i = 0; $i -lt $newArr.Count; $i++) {
            $currentLines.Insert($idx + $i, $newArr[$i])
        }

        $searchStart = $idx + $newArr.Count
    }

    $result = ""
    if ($currentLines.Count -gt 0) {
        $result = ($currentLines -join "`n")
    }
    # Keep trailing newline for script files.
    $result += "`n"
    Write-TextFile -Path $FilePath -Content $result
}

function Parse-And-ApplyPatch {
    param([string]$PatchText)

    $lines = Split-Lines -Text $PatchText
    if ($lines.Count -eq 0) {
        return
    }
    if ($lines[0] -ne "*** Begin Patch") {
        return
    }

    $i = 1
    while ($i -lt $lines.Count) {
        $line = $lines[$i]
        if ($line -eq "*** End Patch") {
            break
        }

        if ($line.StartsWith("*** Add File: ")) {
            $path = $line.Substring("*** Add File: ".Length)
            $i++

            $addLines = New-Object System.Collections.Generic.List[string]
            while ($i -lt $lines.Count) {
                $cur = $lines[$i]
                if ($cur.StartsWith("*** ")) {
                    break
                }
                if ($cur.StartsWith("+")) {
                    [void]$addLines.Add($cur.Substring(1))
                }
                $i++
            }

            if ($targetFiles -contains $path) {
                $content = ""
                if ($addLines.Count -gt 0) {
                    $content = ($addLines -join "`n") + "`n"
                }
                Write-TextFile -Path $path -Content $content
            }
            continue
        }

        if ($line.StartsWith("*** Update File: ")) {
            $path = $line.Substring("*** Update File: ".Length)
            $i++

            $isTarget = ($targetFiles -contains $path)
            $hunks = New-Object System.Collections.Generic.List[object]
            $currentHunkOld = $null
            $currentHunkNew = $null

            while ($i -lt $lines.Count) {
                $cur = $lines[$i]

                if ($cur.StartsWith("*** ")) {
                    break
                }

                if ($cur.StartsWith("@@")) {
                    if ($currentHunkOld -ne $null) {
                        [void]$hunks.Add([pscustomobject]@{
                            OldLines = $currentHunkOld
                            NewLines = $currentHunkNew
                        })
                    }
                    $currentHunkOld = New-Object System.Collections.Generic.List[string]
                    $currentHunkNew = New-Object System.Collections.Generic.List[string]
                    $i++
                    continue
                }

                if ($cur -eq "*** End of File") {
                    $i++
                    continue
                }

                if ($currentHunkOld -eq $null) {
                    # Skip until first hunk marker.
                    $i++
                    continue
                }

                if ($cur.StartsWith(" ")) {
                    $text = $cur.Substring(1)
                    [void]$currentHunkOld.Add($text)
                    [void]$currentHunkNew.Add($text)
                }
                elseif ($cur.StartsWith("-")) {
                    [void]$currentHunkOld.Add($cur.Substring(1))
                }
                elseif ($cur.StartsWith("+")) {
                    [void]$currentHunkNew.Add($cur.Substring(1))
                }
                else {
                    # Unknown line type in hunk; treat as context.
                    [void]$currentHunkOld.Add($cur)
                    [void]$currentHunkNew.Add($cur)
                }

                $i++
            }

            if ($currentHunkOld -ne $null) {
                [void]$hunks.Add([pscustomobject]@{
                    OldLines = $currentHunkOld
                    NewLines = $currentHunkNew
                })
            }

            if ($isTarget -and $hunks.Count -gt 0) {
                Apply-Hunks -FilePath $path -Hunks $hunks
            }

            continue
        }

        $i++
    }
}

$lineNo = 0
$appliedCount = 0
Get-Content -Path $SessionJsonl -Encoding UTF8 | ForEach-Object {
    $lineNo++
    $jsonLine = $_
    $obj = $null
    try {
        $obj = $jsonLine | ConvertFrom-Json
    }
    catch {
        return
    }

    if ($obj.type -ne "response_item") {
        return
    }

    $payload = $obj.payload
    if ($payload.type -ne "custom_tool_call") {
        return
    }
    if ($payload.name -ne "apply_patch") {
        return
    }

    $patchText = [string]$payload.input
    if ([string]::IsNullOrWhiteSpace($patchText)) {
        return
    }

    $hasTargetHeader = $false
    foreach ($target in $targetFiles) {
        if ($patchText -match ("(?m)^\*\*\* (?:Add|Update) File: " + [regex]::Escape($target) + "$")) {
            $hasTargetHeader = $true
            break
        }
    }
    if (-not $hasTargetHeader) {
        return
    }

    try {
        Parse-And-ApplyPatch -PatchText $patchText
        $appliedCount++
    }
    catch {
        Write-Host ("[WARN] Failed patch replay at line {0}, call {1}: {2}" -f $lineNo, $payload.call_id, $_.Exception.Message)
    }
}

Write-Host ("[DONE] Replayed {0} component patch blocks from session log." -f $appliedCount)

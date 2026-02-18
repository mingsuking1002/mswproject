param(
    [string]$WorkspaceRoot = "mswproject",
    [string]$OutDir = "",
    [switch]$Deep
)

$ErrorActionPreference = "Stop"

$STATE_GREEN = [char]::ConvertFromUtf32(0x1F7E2)
$STATE_BLUE = [char]::ConvertFromUtf32(0x1F535)
$STATE_YELLOW = [char]::ConvertFromUtf32(0x1F7E1)
$BACKLOG_REGEX = "backlog|\uBC31\uB85C\uADF8"

function Get-StateIcon {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return "" }
    if ($Text.Contains($script:STATE_GREEN)) { return $script:STATE_GREEN }
    if ($Text.Contains($script:STATE_BLUE)) { return $script:STATE_BLUE }
    if ($Text.Contains($script:STATE_YELLOW)) { return $script:STATE_YELLOW }
    return ""
}

function Count-Matches {
    param([string]$Text, [string]$Pattern)
    if ([string]::IsNullOrWhiteSpace($Text)) { return 0 }
    return ([regex]::Matches($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
}

function Add-Item {
    param(
        [System.Collections.Generic.List[object]]$List,
        [string]$Type,
        [string]$Path,
        [string]$Message
    )
    $List.Add([ordered]@{
        type = $Type
        path = $Path
        message = $Message
    })
}

$root = (Resolve-Path -Path $WorkspaceRoot).Path

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $specSeed = Get-ChildItem -Path $root -Filter "SPEC_*.md" -File -Recurse -Depth 4 | Select-Object -First 1
    if ($null -eq $specSeed) {
        throw "Could not find any SPEC_*.md under $root"
    }
    $specDir = $specSeed.DirectoryName
} else {
    $specDir = (Resolve-Path -Path $OutDir).Path
}

$specFiles = Get-ChildItem -Path $specDir -Filter "SPEC_*.md" -File | Where-Object { $_.Name -ne "SPEC_AUDIT_REPORT.md" } | Sort-Object Name
if ($specFiles.Count -eq 0) {
    throw "No SPEC_*.md files found in $specDir"
}

$componentsDir = Join-Path $root "RootDesk/MyDesk/ProjectGR/Components"
$firePath = Join-Path $componentsDir "Combat/FireSystemComponent.mlua"
$gamesMapPath = Join-Path $root "map/games.map"

$specRows = New-Object System.Collections.Generic.List[object]
$docDrift = New-Object System.Collections.Generic.List[object]
$codeIssues = New-Object System.Collections.Generic.List[object]

foreach ($spec in $specFiles) {
    $content = Get-Content -Path $spec.FullName -Encoding UTF8 -Raw
    $lines = Get-Content -Path $spec.FullName -Encoding UTF8

    $topLine = ""
    if ($lines.Count -gt 0) { $topLine = $lines[0].Trim() }

    $metaLine = ""
    foreach ($line in $lines) {
        if (($line.Contains($STATE_GREEN) -or $line.Contains($STATE_BLUE) -or $line.Contains($STATE_YELLOW)) -and ($line.Contains("|") -or $line.Contains("**"))) {
            $metaLine = $line.Trim()
            break
        }
    }

    $checked = Count-Matches -Text $content -Pattern "^\s*-\s*\[x\]"
    $uncheckedTotal = Count-Matches -Text $content -Pattern "^\s*-\s*\[ \]"

    $uncheckedNonBacklog = 0
    $inBacklog = $false
    foreach ($line in $lines) {
        if ($line -match "^\s*##+\s+") {
            $inBacklog = [regex]::IsMatch($line, $BACKLOG_REGEX, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        }
        if ($line -match "^\s*-\s*\[ \]") {
            if ($inBacklog -eq $false) { $uncheckedNonBacklog += 1 }
        }
    }

    $map01Count = Count-Matches -Text $content -Pattern "\bmap01\b"
    $lobbyMapCount = Count-Matches -Text $content -Pattern "(/maps/lobby|map://lobby|\blobby\.map\b)"
    $globalUtilCount = Count-Matches -Text $content -Pattern "_GRUtil"

    $topState = Get-StateIcon -Text $topLine
    $metaState = Get-StateIcon -Text $metaLine
    if ($topState -ne "" -and $metaState -ne "" -and $topState -ne $metaState) {
        Add-Item -List $docDrift -Type "status_mismatch" -Path $spec.Name -Message ("top={0}, meta={1}" -f $topState, $metaState)
    }
    if ($topState -eq $STATE_GREEN -and $uncheckedNonBacklog -gt 0) {
        Add-Item -List $docDrift -Type "unchecked_in_green" -Path $spec.Name -Message ("unchecked_non_backlog={0}" -f $uncheckedNonBacklog)
    }

    $specRows.Add([ordered]@{
        name = $spec.Name
        top = $topLine
        meta = (($metaLine -replace "\|", " ") -replace "\s+", " ").Trim()
        checked = $checked
        unchecked_total = $uncheckedTotal
        unchecked_non_backlog = $uncheckedNonBacklog
        map01 = $map01Count
        lobby_map = $lobbyMapCount
        global__GRUtil = $globalUtilCount
    })
}

$mluaFiles = Get-ChildItem -Path $componentsDir -Filter "*.mlua" -File -Recurse | Sort-Object FullName
$codeblockFiles = Get-ChildItem -Path $componentsDir -Filter "*.codeblock" -File -Recurse | Sort-Object FullName

foreach ($mlua in $mluaFiles) {
    $pair = [System.IO.Path]::ChangeExtension($mlua.FullName, ".codeblock")
    if (-not (Test-Path -Path $pair)) {
        Add-Item -List $codeIssues -Type "missing_codeblock_pair" -Path $mlua.FullName -Message "paired .codeblock is missing"
    }
}

foreach ($codeblock in $codeblockFiles) {
    $pair = [System.IO.Path]::ChangeExtension($codeblock.FullName, ".mlua")
    if (-not (Test-Path -Path $pair)) {
        Add-Item -List $codeIssues -Type "missing_mlua_pair" -Path $codeblock.FullName -Message "paired .mlua is missing"
    }

    try {
        $json = Get-Content -Path $codeblock.FullName -Encoding UTF8 -Raw | ConvertFrom-Json
        $source = $json.ContentProto.Json.Source
        $target = [string]$json.ContentProto.Json.Target
        if ($source -ne 1) {
            Add-Item -List $codeIssues -Type "invalid_codeblock_source" -Path $codeblock.FullName -Message ("Source={0}, expected 1" -f $source)
        }
        if ([string]::IsNullOrWhiteSpace($target)) {
            Add-Item -List $codeIssues -Type "empty_codeblock_target" -Path $codeblock.FullName -Message "Target is empty"
        }
    } catch {
        Add-Item -List $codeIssues -Type "invalid_codeblock_json" -Path $codeblock.FullName -Message $_.Exception.Message
    }
}

if ($Deep.IsPresent) {
    $forbidden = @(
        @{ type = "forbidden_button_component_connect"; text = "ButtonComponent:ConnectEvent" },
        @{ type = "forbidden_button_component_disconnect"; text = "ButtonComponent:DisconnectEvent" },
        @{ type = "legacy_resolve_project_movement"; text = "ResolveProjectMovementComponent" },
        @{ type = "legacy_can_write_component_field"; text = "CanWriteComponentField" },
        @{ type = "legacy_try_set_movement_can_move"; text = "TrySetMovementCanMove" }
    )
    foreach ($mlua in $mluaFiles) {
        $text = Get-Content -Path $mlua.FullName -Encoding UTF8 -Raw
        foreach ($rule in $forbidden) {
            if ($text.Contains($rule.text)) {
                Add-Item -List $codeIssues -Type $rule.type -Path $mlua.FullName -Message ("found: " + $rule.text)
            }
        }
        if ($text.Contains("_GRUtil")) {
            $hits = Select-String -Path $mlua.FullName -Pattern "_GRUtil"
            foreach ($hit in $hits) {
                if ($hit.Line -notmatch "self\._T\.GRUtil") {
                    Add-Item -List $codeIssues -Type "global_grutil_direct_reference" -Path $mlua.FullName -Message "global _GRUtil reference found"
                    break
                }
            }
        }
        $senderHits = Select-String -Path $mlua.FullName -Pattern "senderUserId"
        foreach ($hit in $senderHits) {
            if ($hit.Line -match "method\s+") {
                Add-Item -List $codeIssues -Type "invalid_sender_user_id_param" -Path $mlua.FullName -Message "senderUserId appears in method declaration line"
                break
            }
        }
    }
}

$projectileModelId = ""
if (Test-Path -Path $firePath) {
    $fireText = Get-Content -Path $firePath -Encoding UTF8 -Raw
    $m = [regex]::Match($fireText, 'property\s+string\s+ProjectileModelId\s*=\s*"(?<id>[^"]*)"')
    if ($m.Success) { $projectileModelId = $m.Groups["id"].Value }
}

$hasTemplateEntity = $false
$hasTemplateScript = $false
$hasTemplateTrigger = $false
$hasTemplateSprite = $false
if (Test-Path -Path $gamesMapPath) {
    $mapText = Get-Content -Path $gamesMapPath -Encoding UTF8 -Raw
    $hasTemplateEntity = ($mapText -match '"/maps/games/GRProjectileTemplate"')
    $hasTemplateScript = ($mapText -match '"@type":\s*"script.ProjectileComponent"')
    $hasTemplateTrigger = ($mapText -match '"@type":\s*"MOD.Core.TriggerComponent"')
    $hasTemplateSprite = ($mapText -match '"@type":\s*"MOD.Core.SpriteRendererComponent"')
}

$fireOk = (($projectileModelId -ne "") -or ($hasTemplateEntity -and $hasTemplateScript -and $hasTemplateTrigger))
if (-not $fireOk) {
    Add-Item -List $codeIssues -Type "fire_spawn_precondition_missing" -Path $firePath -Message "ProjectileModelId empty and template requirements are missing"
}

$report = [ordered]@{
    generated_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    workspace_root = $root
    mode = $(if ($Deep.IsPresent) { "deep" } else { "light" })
    specs = $specRows
    component_check = [ordered]@{
        mlua_count = $mluaFiles.Count
        codeblock_count = $codeblockFiles.Count
    }
    fire_precondition = [ordered]@{
        default_projectile_model_id = $projectileModelId
        has_template_entity = $hasTemplateEntity
        has_template_script_component = $hasTemplateScript
        has_template_trigger_component = $hasTemplateTrigger
        has_template_sprite_component = $hasTemplateSprite
        ok = $fireOk
    }
    code_issues = $codeIssues
    doc_drift = $docDrift
}

$jsonPath = Join-Path $specDir "SPEC_AUDIT_REPORT.json"
$mdPath = Join-Path $specDir "SPEC_AUDIT_REPORT.md"

$report | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonPath -Encoding UTF8

$md = New-Object System.Collections.Generic.List[string]
$md.Add("# SPEC Audit Report")
$md.Add("")
$md.Add("- Generated: " + $report.generated_at)
$md.Add("- Workspace: " + $root)
$md.Add("- Mode: " + $report.mode)
$md.Add("")
$md.Add("## Summary")
$md.Add("")
$md.Add("| Item | Value |")
$md.Add("|---|---|")
$md.Add("| SPEC files | " + $specFiles.Count + " |")
$md.Add("| Component mlua count | " + $mluaFiles.Count + " |")
$md.Add("| Component codeblock count | " + $codeblockFiles.Count + " |")
$md.Add("| Code issues | " + $codeIssues.Count + " |")
$md.Add("| Document drift issues | " + $docDrift.Count + " |")
$md.Add("")
$md.Add("## Code Issues")
$md.Add("")
if ($codeIssues.Count -eq 0) {
    $md.Add("- None")
} else {
    foreach ($issue in $codeIssues) {
        $md.Add("- [" + $issue.type + "] " + $issue.path + ": " + $issue.message)
    }
}
$md.Add("")
$md.Add("## Document Drift")
$md.Add("")
if ($docDrift.Count -eq 0) {
    $md.Add("- None")
} else {
    foreach ($drift in $docDrift) {
        $md.Add("- [" + $drift.type + "] " + $drift.path + ": " + $drift.message)
    }
}
$md.Add("")
$md.Add("## Fire Precondition")
$md.Add("")
$md.Add("| Item | Value |")
$md.Add("|---|---|")
$md.Add("| default ProjectileModelId | " + $projectileModelId + " |")
$md.Add("| has /maps/games/GRProjectileTemplate | " + $hasTemplateEntity + " |")
$md.Add("| has script.ProjectileComponent on template | " + $hasTemplateScript + " |")
$md.Add("| has MOD.Core.TriggerComponent on template | " + $hasTemplateTrigger + " |")
$md.Add("| has MOD.Core.SpriteRendererComponent on template | " + $hasTemplateSprite + " |")
$md.Add("| fire precondition ok | " + $fireOk + " |")
$md.Add("")
$md.Add("## SPEC Matrix")
$md.Add("")
$md.Add("| SPEC | Top | Meta | Checked | Unchecked(total) | Unchecked(non-backlog) | map01 | lobby-map | _GRUtil |")
$md.Add("|---|---|---|---:|---:|---:|---:|---:|---:|")
foreach ($row in $specRows) {
    $md.Add("| " + $row.name + " | " + $row.top + " | " + $row.meta + " | " + $row.checked + " | " + $row.unchecked_total + " | " + $row.unchecked_non_backlog + " | " + $row.map01 + " | " + $row.lobby_map + " | " + $row.global__GRUtil + " |")
}

$md | Set-Content -Path $mdPath -Encoding UTF8

Write-Host ("[OK] Audit JSON: " + $jsonPath)
Write-Host ("[OK] Audit Markdown: " + $mdPath)

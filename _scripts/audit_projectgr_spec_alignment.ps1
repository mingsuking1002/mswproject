param(
    [string]$WorkspaceRoot = "mswproject",
    [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"

$STATE_GREEN = [char]::ConvertFromUtf32(0x1F7E2)
$STATE_BLUE = [char]::ConvertFromUtf32(0x1F535)
$STATE_YELLOW = [char]::ConvertFromUtf32(0x1F7E1)
$BACKLOG_REGEX = "backlog|\uBC31\uB85C\uADF8"

function Get-StateIcon {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }
    if ($Text.Contains($script:STATE_GREEN)) { return $script:STATE_GREEN }
    if ($Text.Contains($script:STATE_BLUE)) { return $script:STATE_BLUE }
    if ($Text.Contains($script:STATE_YELLOW)) { return $script:STATE_YELLOW }
    return ""
}

function Count-Regex {
    param(
        [string]$Text,
        [string]$Pattern
    )
    if ($null -eq $Text) {
        return 0
    }
    return ([regex]::Matches($Text, $Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
}

function Add-EntryIssue {
    param(
        [System.Collections.Generic.List[object]]$List,
        [string]$Type,
        [string]$File,
        [string]$Message
    )
    $List.Add([ordered]@{
        type = $Type
        file = $File
        message = $Message
    })
}

function Add-DocDrift {
    param(
        [System.Collections.Generic.List[object]]$List,
        [string]$SpecName,
        [string]$Type,
        [string]$Message
    )
    $List.Add([ordered]@{
        spec = $SpecName
        type = $Type
        message = $Message
    })
}

$resolvedRoot = (Resolve-Path -Path $WorkspaceRoot).Path

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $specFiles = Get-ChildItem -Path $resolvedRoot -Recurse -Filter "SPEC_*.md" -File | Sort-Object FullName
    if ($specFiles.Count -eq 0) {
        throw "No SPEC files found under $resolvedRoot"
    }
    $specDir = $specFiles[0].DirectoryName
    $specFiles = $specFiles | Where-Object { $_.DirectoryName -eq $specDir } | Sort-Object Name
} else {
    $specDir = (Resolve-Path -Path $OutDir).Path
    $specFiles = Get-ChildItem -Path $specDir -Filter "SPEC_*.md" -File | Sort-Object Name
    if ($specFiles.Count -eq 0) {
        throw "No SPEC files found under $specDir"
    }
}

$componentsDir = Join-Path $resolvedRoot "RootDesk/MyDesk/ProjectGR/Components"
$firePath = Join-Path $componentsDir "Combat/FireSystemComponent.mlua"
$gamesMapPath = Join-Path $resolvedRoot "map/games.map"

$specRows = New-Object System.Collections.Generic.List[object]
$docDrift = New-Object System.Collections.Generic.List[object]

foreach ($spec in $specFiles) {
    $content = Get-Content -Path $spec.FullName -Encoding UTF8 -Raw
    $lines = Get-Content -Path $spec.FullName -Encoding UTF8
    $topLine = ""
    if ($lines.Count -gt 0) {
        $topLine = $lines[0].Trim()
    }

    $metaStatus = ""
    foreach ($line in $lines) {
        if ($line -match "^\s*\|.*\|.*\|") {
            if ($line.Contains($STATE_GREEN) -or $line.Contains($STATE_BLUE) -or $line.Contains($STATE_YELLOW)) {
                $metaStatus = $line
                break
            }
        }
    }
    if ([string]::IsNullOrWhiteSpace($metaStatus)) {
        foreach ($line in $lines) {
            if ($line -match "^\s*-\s*\*\*.*\*\*:\s*") {
                if ($line.Contains($STATE_GREEN) -or $line.Contains($STATE_BLUE) -or $line.Contains($STATE_YELLOW)) {
                    $metaStatus = $line.Trim()
                    break
                }
            }
        }
    }

    $checked = Count-Regex -Text $content -Pattern "^\s*-\s*\[x\]"
    $uncheckedTotal = Count-Regex -Text $content -Pattern "^\s*-\s*\[ \]"

    $uncheckedNonBacklog = 0
    $inBacklog = $false
    foreach ($line in $lines) {
        if ($line -match "^\s*##+\s+") {
            $inBacklog = [regex]::IsMatch($line, $BACKLOG_REGEX, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        }
        if ($line -match "^\s*-\s*\[ \]") {
            if ($inBacklog -eq $false) {
                $uncheckedNonBacklog += 1
            }
        }
    }

    $rawMap01 = Count-Regex -Text $content -Pattern "\bmap01\b"
    $rawLobbyMap = Count-Regex -Text $content -Pattern "(/maps/lobby|map://lobby|\blobby\.map\b)"
    $rawGlobalUtil = Count-Regex -Text $content -Pattern "_GRUtil"

    $actionableLines = @()
    foreach ($line in $lines) {
        if ([regex]::IsMatch($line, $BACKLOG_REGEX, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            continue
        }
        if ($line -match "legacy|WORKSPACE_REPRODUCE|FLOW_TEST_GAP_PLAN") {
            continue
        }
        if ($line -match "Map01BootstrapComponent") {
            continue
        }
        $actionableLines += $line
    }
    $actionableText = [string]::Join("`n", $actionableLines)
    $actionableMap01 = Count-Regex -Text $actionableText -Pattern "\bmap01\b"
    $actionableLobbyMap = Count-Regex -Text $actionableText -Pattern "(/maps/lobby|map://lobby|\blobby\.map\b)"
    $actionableGlobalUtil = Count-Regex -Text $actionableText -Pattern "_GRUtil"

    $topState = Get-StateIcon -Text $topLine
    $metaState = Get-StateIcon -Text $metaStatus
    if ($topState -ne "" -and $metaState -ne "" -and $topState -ne $metaState) {
        Add-DocDrift -List $docDrift -SpecName $spec.Name -Type "status_mismatch" -Message ("top={0}, meta={1}" -f $topState, $metaState)
    }
    if ($topState -eq $STATE_GREEN -and $uncheckedNonBacklog -gt 0) {
        Add-DocDrift -List $docDrift -SpecName $spec.Name -Type "unchecked_in_green" -Message ("unchecked_non_backlog={0}" -f $uncheckedNonBacklog)
    }
    if (($actionableMap01 + $actionableLobbyMap + $actionableGlobalUtil) -gt 0) {
        Add-DocDrift -List $docDrift -SpecName $spec.Name -Type "keyword_drift" -Message ("map01={0}, lobbyMap={1}, _GRUtil={2}" -f $actionableMap01, $actionableLobbyMap, $actionableGlobalUtil)
    }

    $specRows.Add([ordered]@{
        name = $spec.Name
        top = $topLine
        meta = $metaStatus
        checked = $checked
        unchecked_total = $uncheckedTotal
        unchecked_non_backlog = $uncheckedNonBacklog
        raw_map01 = $rawMap01
        raw_lobby_map = $rawLobbyMap
        raw__GRUtil = $rawGlobalUtil
        actionable_map01 = $actionableMap01
        actionable_lobby_map = $actionableLobbyMap
        actionable__GRUtil = $actionableGlobalUtil
    })
}

$codeIssues = New-Object System.Collections.Generic.List[object]

$mluaFiles = Get-ChildItem -Path $componentsDir -Filter "*.mlua" -File -Recurse | Sort-Object FullName
$codeblockFiles = Get-ChildItem -Path $componentsDir -Filter "*.codeblock" -File -Recurse | Sort-Object FullName

foreach ($mlua in $mluaFiles) {
    $pairCodeblock = [System.IO.Path]::ChangeExtension($mlua.FullName, ".codeblock")
    if (-not (Test-Path -Path $pairCodeblock)) {
        Add-EntryIssue -List $codeIssues -Type "missing_codeblock_pair" -File $mlua.FullName -Message "paired .codeblock does not exist"
    }
}

foreach ($codeblock in $codeblockFiles) {
    $pairMlua = [System.IO.Path]::ChangeExtension($codeblock.FullName, ".mlua")
    if (-not (Test-Path -Path $pairMlua)) {
        Add-EntryIssue -List $codeIssues -Type "missing_mlua_pair" -File $codeblock.FullName -Message "paired .mlua does not exist"
    }

    try {
        $json = Get-Content -Path $codeblock.FullName -Encoding UTF8 -Raw | ConvertFrom-Json
        $sourceFlag = $json.ContentProto.Json.Source
        $targetText = [string]$json.ContentProto.Json.Target
        if ($sourceFlag -ne 1) {
            Add-EntryIssue -List $codeIssues -Type "invalid_codeblock_source" -File $codeblock.FullName -Message ("Source={0} (expected 1)" -f $sourceFlag)
        }
        if ([string]::IsNullOrWhiteSpace($targetText)) {
            Add-EntryIssue -List $codeIssues -Type "empty_codeblock_target" -File $codeblock.FullName -Message "Target is empty"
        }
    } catch {
        Add-EntryIssue -List $codeIssues -Type "invalid_codeblock_json" -File $codeblock.FullName -Message $_.Exception.Message
    }
}

$forbiddenPatterns = @(
    @{ type = "forbidden_button_component_connect"; pattern = "ButtonComponent\s*:\s*ConnectEvent"; message = "ButtonComponent:ConnectEvent is unsupported. Use Entity:ConnectEvent." },
    @{ type = "forbidden_button_component_disconnect"; pattern = "ButtonComponent\s*:\s*DisconnectEvent"; message = "ButtonComponent:DisconnectEvent is unsupported. Use Entity:DisconnectEvent." },
    @{ type = "legacy_resolve_project_movement"; pattern = "\bResolveProjectMovementComponent\b"; message = "Legacy helper should not exist in phase scope." },
    @{ type = "legacy_can_write_component_field"; pattern = "\bCanWriteComponentField\b"; message = "Legacy helper should not exist in phase scope." },
    @{ type = "legacy_try_set_movement_can_move"; pattern = "\bTrySetMovementCanMove\b"; message = "Legacy helper should not exist in phase scope." },
    @{ type = "invalid_sender_user_id_param"; pattern = "(?s)method\s+[^(]+\([^)]*\bsenderUserId\b"; message = "senderUserId parameter name is forbidden by LEA-4003." },
    @{ type = "global_grutil_direct_reference"; pattern = "(?<!self\._T\.)\b_GRUtil\b"; message = "Use self._T.GRUtil cache pattern instead of global direct reference." }
)

foreach ($mlua in $mluaFiles) {
    $text = Get-Content -Path $mlua.FullName -Encoding UTF8 -Raw
    foreach ($rule in $forbiddenPatterns) {
        if ([regex]::IsMatch($text, $rule.pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
            Add-EntryIssue -List $codeIssues -Type $rule.type -File $mlua.FullName -Message $rule.message
        }
    }
}

$fireDefaultModelId = ""
$hasFireFile = Test-Path -Path $firePath
if ($hasFireFile) {
    $fireText = Get-Content -Path $firePath -Encoding UTF8 -Raw
    $modelMatch = [regex]::Match($fireText, "property\s+string\s+ProjectileModelId\s*=\s*""(?<id>[^""]*)""")
    if ($modelMatch.Success) {
        $fireDefaultModelId = $modelMatch.Groups["id"].Value
    }
}

$gamesMapText = ""
$hasGamesMap = Test-Path -Path $gamesMapPath
if ($hasGamesMap) {
    $gamesMapText = Get-Content -Path $gamesMapPath -Encoding UTF8 -Raw
}

$hasTemplateEntity = $gamesMapText -match """/maps/games/GRProjectileTemplate"""
$hasTemplateScript = $gamesMapText -match """@type"":\s*""script.ProjectileComponent"""
$hasTemplateTrigger = $gamesMapText -match """@type"":\s*""MOD.Core.TriggerComponent"""
$hasTemplateSprite = $gamesMapText -match """@type"":\s*""MOD.Core.SpriteRendererComponent"""

$firePreconditionOk = (($fireDefaultModelId -ne "") -or ($hasTemplateEntity -and $hasTemplateScript -and $hasTemplateTrigger))
if (-not $firePreconditionOk) {
    Add-EntryIssue -List $codeIssues -Type "fire_spawn_precondition_missing" -File $firePath -Message "ProjectileModelId is empty and GRProjectileTemplate required components are missing."
}

$report = [ordered]@{
    generated_at = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    workspace_root = $resolvedRoot
    specs = $specRows
    component_check = [ordered]@{
        mlua_count = $mluaFiles.Count
        codeblock_count = $codeblockFiles.Count
    }
    fire_precondition = [ordered]@{
        fire_file_exists = $hasFireFile
        games_map_exists = $hasGamesMap
        default_projectile_model_id = $fireDefaultModelId
        has_template_entity = $hasTemplateEntity
        has_template_script_component = $hasTemplateScript
        has_template_trigger_component = $hasTemplateTrigger
        has_template_sprite_component = $hasTemplateSprite
        ok = $firePreconditionOk
    }
    code_issues = $codeIssues
    doc_drift = $docDrift
}

$jsonPath = Join-Path $specDir "SPEC_AUDIT_REPORT.json"
$mdPath = Join-Path $specDir "SPEC_AUDIT_REPORT.md"

$report | ConvertTo-Json -Depth 10 | Set-Content -Path $jsonPath -Encoding UTF8

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# SPEC Audit Report")
$lines.Add("")
$lines.Add("- Generated: " + $report.generated_at)
$lines.Add("- Workspace: " + $report.workspace_root)
$lines.Add("")
$lines.Add("## Summary")
$lines.Add("")
$lines.Add("| Item | Value |")
$lines.Add("|---|---|")
$lines.Add("| SPEC files | " + $specFiles.Count + " |")
$lines.Add("| Component mlua count | " + $mluaFiles.Count + " |")
$lines.Add("| Component codeblock count | " + $codeblockFiles.Count + " |")
$lines.Add("| Code issues | " + $codeIssues.Count + " |")
$lines.Add("| Document drift issues | " + $docDrift.Count + " |")
$lines.Add("")
$lines.Add("## Code Issues")
$lines.Add("")
if ($codeIssues.Count -eq 0) {
    $lines.Add("- None")
} else {
    foreach ($issue in $codeIssues) {
        $lines.Add("- [" + $issue.type + "] " + $issue.file + ": " + $issue.message)
    }
}
$lines.Add("")
$lines.Add("## Document Drift")
$lines.Add("")
if ($docDrift.Count -eq 0) {
    $lines.Add("- None")
} else {
    foreach ($drift in $docDrift) {
        $lines.Add("- [" + $drift.type + "] " + $drift.spec + ": " + $drift.message)
    }
}
$lines.Add("")
$lines.Add("## Fire Precondition")
$lines.Add("")
$lines.Add("| Item | Value |")
$lines.Add("|---|---|")
$lines.Add("| default ProjectileModelId | " + $fireDefaultModelId + " |")
$lines.Add("| has /maps/games/GRProjectileTemplate | " + $hasTemplateEntity + " |")
$lines.Add("| has script.ProjectileComponent on template | " + $hasTemplateScript + " |")
$lines.Add("| has MOD.Core.TriggerComponent on template | " + $hasTemplateTrigger + " |")
$lines.Add("| has MOD.Core.SpriteRendererComponent on template | " + $hasTemplateSprite + " |")
$lines.Add("| fire precondition ok | " + $firePreconditionOk + " |")
$lines.Add("")
$lines.Add("## SPEC Matrix")
$lines.Add("")
$lines.Add("| SPEC | Top | Meta | Checked | Unchecked(total) | Unchecked(non-backlog) | Actionable map01 | Actionable lobby-map | Actionable _GRUtil |")
$lines.Add("|---|---|---|---:|---:|---:|---:|---:|---:|")
foreach ($row in $specRows) {
    $lines.Add("| " + $row.name + " | " + $row.top + " | " + $row.meta + " | " + $row.checked + " | " + $row.unchecked_total + " | " + $row.unchecked_non_backlog + " | " + $row.actionable_map01 + " | " + $row.actionable_lobby_map + " | " + $row.actionable__GRUtil + " |")
}

$lines | Set-Content -Path $mdPath -Encoding UTF8

Write-Host ("[OK] Audit JSON: " + $jsonPath)
Write-Host ("[OK] Audit Markdown: " + $mdPath)

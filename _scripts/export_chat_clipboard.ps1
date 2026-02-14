# Codex 대화 내보내기 (클립보드 기반)
# 사용법:
#   1) Codex/Chat UI에서 내보낼 대화 내용을 전체 선택 후 복사(Ctrl+C)
#   2) PowerShell에서 실행:
#        ./_scripts/export_chat_clipboard.ps1
param(
    [string]$OutDir = (Join-Path (Split-Path -Parent $PSScriptRoot) "text"),
    [string]$Prefix = "CODEX_CHAT_EXPORT",
    [switch]$UpdateAIContextExport,
    [switch]$Open
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$now = Get-Date
$timestamp = $now.ToString("yyyy-MM-dd_HHmmss")

if (-not (Test-Path $OutDir)) {
    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    Write-Host "[INIT] 출력 폴더 생성: $OutDir"
}

$outFile = Join-Path $OutDir "$Prefix`_$timestamp.md"

try {
    $clip = Get-Clipboard -Raw -Format Text -ErrorAction Stop
}
catch {
    Write-Error "클립보드에서 텍스트를 읽지 못했습니다. 먼저 대화 내용을 복사(Ctrl+C)한 뒤 다시 실행하세요."
    exit 1
}

if ([string]::IsNullOrWhiteSpace($clip)) {
    Write-Error "클립보드가 비어 있습니다. 먼저 대화 내용을 복사(Ctrl+C)한 뒤 다시 실행하세요."
    exit 1
}

$export = @()
$export += "# Codex Chat Export"
$export += "> Auto-generated: $($now.ToString('yyyy-MM-dd HH:mm:ss'))"
$export += "> Source: Clipboard"
$export += ""
$export += "---"
$export += ""
$export += $clip

$export -join "`n" | Out-File -FilePath $outFile -Encoding utf8

Write-Host ""
Write-Host "[DONE] 대화 내보내기 완료!"
Write-Host "  File: $outFile"

if ($UpdateAIContextExport) {
    $exportContextScript = Join-Path $PSScriptRoot "export_context.ps1"
    if (-not (Test-Path $exportContextScript)) {
        Write-Error "export_context.ps1를 찾지 못했습니다: $exportContextScript"
        exit 1
    }

    Write-Host ""
    Write-Host "[RUN] AI_CONTEXT_EXPORT.md 갱신(export_context.ps1 실행)..."
    & $exportContextScript
}

if ($Open) {
    Invoke-Item $outFile
}

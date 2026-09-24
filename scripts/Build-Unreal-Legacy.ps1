param(
    [string]$EngineRoot = ''
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$UProject = Join-Path $ProjectRoot 'game\PromptFighterUltimate.uproject'

if (-not $EngineRoot) {
    $Candidates = Get-ChildItem -LiteralPath 'C:\Program Files\Epic Games' -Directory -Filter 'UE_5.*' -ErrorAction SilentlyContinue | Sort-Object Name -Descending
    $EngineRoot = $Candidates | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $EngineRoot) {
    throw 'Keine Unreal-Engine-Installation gefunden. EngineRoot kann als Parameter angegeben werden.'
}

$BuildBat = Join-Path $EngineRoot 'Engine\Build\BatchFiles\Build.bat'
if (-not (Test-Path -LiteralPath $BuildBat)) { throw "Build.bat fehlt: $BuildBat" }

& $BuildBat PromptFighterUltimateEditor Win64 Development "-Project=$UProject" -WaitMutex -NoHotReloadFromIDE
if ($LASTEXITCODE -ne 0) { throw "Unreal-Build fehlgeschlagen ($LASTEXITCODE)." }


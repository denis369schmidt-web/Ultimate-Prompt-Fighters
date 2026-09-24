param(
    [string]$EngineRoot = ''
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$UProject = Join-Path $ProjectRoot 'game\PromptFighterUltimate.uproject'

if (-not $EngineRoot) {
    $EngineRoot = Get-ChildItem -LiteralPath 'C:\Program Files\Epic Games' -Directory -Filter 'UE_5.*' -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName
}
if (-not $EngineRoot) { throw 'Keine Unreal-Engine-Installation gefunden.' }
$Editor = Join-Path $EngineRoot 'Engine\Binaries\Win64\UnrealEditor.exe'
if (-not (Test-Path -LiteralPath $Editor)) { throw "UnrealEditor.exe fehlt: $Editor" }

& $Editor $UProject -game -log


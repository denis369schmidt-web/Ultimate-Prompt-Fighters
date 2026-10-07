$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$GodotProject = Join-Path $ProjectRoot 'godot'

$defaultExe = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe'
$consoleExe = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe'

$Godot = if (Test-Path $defaultExe) { $defaultExe } elseif (Test-Path $consoleExe) { $consoleExe } else { 'godot' }

Write-Host "Starte Prompt Fighter Ultimate..." -ForegroundColor Cyan
& $Godot --path $GodotProject @args

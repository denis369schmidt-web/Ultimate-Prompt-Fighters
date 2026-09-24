param([string]$Godot = 'godot')
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
& $Godot --headless --path (Join-Path $ProjectRoot 'godot') --editor --import --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot-Import fehlgeschlagen.' }
& $Godot --headless --path (Join-Path $ProjectRoot 'godot') --script res://tests/test_game.gd -- "--report=$ProjectRoot/docs/godot-tests.json"
if ($LASTEXITCODE -ne 0) { throw 'Godot-Tests fehlgeschlagen.' }

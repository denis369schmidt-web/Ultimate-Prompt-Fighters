param([string]$Godot = 'godot')
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$GameRoot = Join-Path $ProjectRoot 'godot'
$BuildRoot = Join-Path $ProjectRoot 'builds\windows'
$Template = Join-Path $ProjectRoot 'tools\godot-templates\windows_release_x86_64.exe'
if (-not (Test-Path -LiteralPath $Template)) {
    throw 'Godot 4.7.2 Windows-Exportvorlage fehlt. Siehe docs/SETUP.md. Kein automatischer Download.'
}
$Version = & $Godot --version
if ($Version -notmatch '^4\.7\.2\.stable') { throw "Erwartet Godot 4.7.2 stable, gefunden: $Version" }
New-Item -ItemType Directory -Force -Path $BuildRoot | Out-Null
& $Godot --headless --path $GameRoot --editor --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot-Import fehlgeschlagen.' }
& $Godot --headless --path $GameRoot --script res://tests/test_game.gd -- "--report=$ProjectRoot/docs/godot-tests.json"
if ($LASTEXITCODE -ne 0) { throw 'Godot-Tests fehlgeschlagen; kein Export.' }
& $Godot --headless --path $GameRoot --export-release Windows (Join-Path $BuildRoot 'PromptFighterUltimate.exe')
if ($LASTEXITCODE -ne 0) { throw 'Godot-Windows-Export fehlgeschlagen.' }
& $Godot --headless --path $GameRoot --script res://tests/write_licenses.gd -- "--output=$BuildRoot/THIRD-PARTY-NOTICES.txt"
if ($LASTEXITCODE -ne 0) { throw 'Lizenzhinweise konnten nicht erzeugt werden.' }
Copy-Item -LiteralPath (Join-Path $ProjectRoot 'docs\BUILD_README.txt') -Destination (Join-Path $BuildRoot 'README.txt')
Write-Host "Windows-Build: $BuildRoot\PromptFighterUltimate.exe"

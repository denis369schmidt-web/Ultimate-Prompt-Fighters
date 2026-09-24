$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Blender = Join-Path $ProjectRoot 'tools\blender-4.5.5-windows-x64\blender.exe'

if (-not (Test-Path -LiteralPath $Blender)) {
    throw "Blender wurde nicht gefunden: $Blender"
}

& $Blender --background --factory-startup --python (Join-Path $PSScriptRoot 'blender_generate_fighters.py')
if ($LASTEXITCODE -ne 0) { throw 'Kämpfer-Erzeugung fehlgeschlagen.' }
& $Blender --background --factory-startup --python (Join-Path $PSScriptRoot 'blender_generate_arena.py')
if ($LASTEXITCODE -ne 0) { throw 'Arena-Erzeugung fehlgeschlagen.' }
python (Join-Path $PSScriptRoot 'generate_placeholder_audio.py')
if ($LASTEXITCODE -ne 0) { throw 'Audio-Erzeugung fehlgeschlagen.' }

Write-Host 'PFU assets generated successfully.'


$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$Blender = Join-Path $ProjectRoot 'tools\blender-4.5.5-windows-x64\blender.exe'
$Validator = Join-Path $PSScriptRoot 'blender_validate_asset.py'

python (Join-Path $PSScriptRoot 'test_pfu_local_simulation.py')
if ($LASTEXITCODE -ne 0) { throw 'Lokale Kampflogiktests fehlgeschlagen.' }

$Checks = @(
    @{Path=(Join-Path $ProjectRoot 'art\blender\PFU_ShadowNinja.blend'); Actions=7},
    @{Path=(Join-Path $ProjectRoot 'art\blender\PFU_LavaGolem.blend'); Actions=7},
    @{Path=(Join-Path $ProjectRoot 'art\blender\PFU_BrokenMoonkeep.blend'); Actions=0}
)
foreach ($Check in $Checks) {
    & $Blender $Check.Path --background --python $Validator -- source $Check.Actions
    if ($LASTEXITCODE -ne 0) { throw "Blender-Prüfung fehlgeschlagen: $($Check.Path)" }
}

Write-Host 'PFU local tests passed.'


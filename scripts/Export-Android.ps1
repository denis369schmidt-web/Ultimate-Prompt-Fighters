param(
    [switch]$Release
)
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$GodotProject = Join-Path $ProjectRoot 'godot'
$BuildDir = Join-Path $ProjectRoot 'builds\android'
$ApkPath = Join-Path $BuildDir 'PromptFighterUltimate.apk'

if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
}

$Godot = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe'
if (-not (Test-Path $Godot)) {
    $Godot = 'godot'
}

$exportFlag = if ($Release) { '--export-release' } else { '--export-debug' }
Write-Host "Baue Android APK ($exportFlag)..." -ForegroundColor Cyan

& $Godot --headless --path "$GodotProject" $exportFlag "Android Mobile" "$ApkPath"
if ($LASTEXITCODE -ne 0) {
    throw "Godot Android Export fehlgeschlagen mit Exit Code $LASTEXITCODE"
}

$apk = Get-Item $ApkPath
$sizeMb = [math]::Round($apk.Length / 1MB, 2)
Write-Host "Erfolgreich erstellt: $ApkPath ($sizeMb MB)" -ForegroundColor Green

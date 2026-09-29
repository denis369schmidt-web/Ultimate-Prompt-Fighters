param(
    [string]$Godot = '',
    [int]$TimeoutSeconds = 300,
    [switch]$SkipImport
)
# Runs every headless test suite with a per-suite timeout, so a stuck test can never
# block the run. Exit code 0 only when all suites pass.
$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$GodotProject = Join-Path $ProjectRoot 'godot'

if (-not $Godot) {
    $default = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe'
    $Godot = if (Test-Path $default) { $default } else { 'godot' }
}

$Suites = @(
    @{ Name = 'game';      Script = 'res://tests/test_game.gd'; Extra = @("--report=$ProjectRoot/docs/godot-tests.json") },
    @{ Name = 'mechanics'; Script = 'res://tests/test_mechanics.gd'; Extra = @() },
    @{ Name = 'roster';    Script = 'res://tests/test_roster.gd'; Extra = @() },
    @{ Name = 'story';     Script = 'res://tests/test_story.gd'; Extra = @() },
    @{ Name = 'combat';    Script = 'res://tests/test_combat_plus.gd'; Extra = @() }
)

if (-not $SkipImport) {
    & $Godot --headless --path $GodotProject --editor --import --quit | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Godot-Import fehlgeschlagen.' }
}

$failedSuites = @()
foreach ($suite in $Suites) {
    Write-Host "=== $($suite.Name) ===" -ForegroundColor Cyan
    $log = Join-Path $env:TEMP "pfu-test-$($suite.Name).log"
    $argList = @('--headless', '--path', "`"$GodotProject`"", '--script', $suite.Script, '--') + $suite.Extra
    $proc = Start-Process -FilePath $Godot -ArgumentList $argList -NoNewWindow -PassThru `
        -RedirectStandardOutput $log -RedirectStandardError "$log.err"
    $null = $proc.Handle  # caches the handle; without it ExitCode stays $null after exit
    if (-not $proc.WaitForExit($TimeoutSeconds * 1000)) {
        $proc.Kill()
        Write-Host "TIMEOUT nach $TimeoutSeconds s - Suite haengt." -ForegroundColor Red
        $failedSuites += $suite.Name
        continue
    }
    $output = Get-Content $log
    $output | Where-Object { $_ -match '^(PASS|FAIL|PFU_TEST_SUMMARY|BALANCE_SAMPLE)' } | ForEach-Object {
        $color = if ($_ -like 'FAIL*') { 'Red' } elseif ($_ -like 'PASS*') { 'Green' } else { 'Yellow' }
        Write-Host $_ -ForegroundColor $color
    }
    $errors = Get-Content "$log.err" -ErrorAction SilentlyContinue | Where-Object { $_ -match 'SCRIPT ERROR|Parse Error' }
    $errors | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    if ($proc.ExitCode -ne 0 -or $errors) { $failedSuites += $suite.Name }
}

if ($failedSuites.Count -gt 0) { throw "Fehlgeschlagene Suites: $($failedSuites -join ', ')" }
Write-Host 'Alle Test-Suites bestanden.' -ForegroundColor Green

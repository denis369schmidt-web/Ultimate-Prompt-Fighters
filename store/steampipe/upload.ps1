# Lädt builds/steam/ mit SteamCMD zu Steam hoch.
# Voraussetzungen: Steamworks SDK (partner.steamgames.com → SDK) entpackt, Pfad unten anpassen,
# APPID/DEPOTID in app_build.vdf und depot_windows.vdf eingetragen, Windows-Build "Steam" exportiert.
# Beim ersten Login fragt SteamCMD nach dem Steam-Guard-Code. Passwort nie in diese Datei schreiben.
param(
    [Parameter(Mandatory = $true)][string]$SteamUser,
    [string]$SteamCmd = "$env:USERPROFILE\steamworks_sdk\tools\ContentBuilder\builder\steamcmd.exe"
)
$ErrorActionPreference = "Stop"
$vdf = Join-Path $PSScriptRoot "app_build.vdf"
if (-not (Test-Path $SteamCmd)) { throw "SteamCMD nicht gefunden: $SteamCmd" }
if ((Get-Content $vdf -Raw) -match '"APPID"|"DEPOTID"') { throw "APPID/DEPOTID in den .vdf-Dateien noch nicht eingetragen." }
& $SteamCmd +login $SteamUser +run_app_build $vdf +quit

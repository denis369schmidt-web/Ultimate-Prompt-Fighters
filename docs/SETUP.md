# Entwicklungsumgebung

Erfasst am 2026-09-18. Der Nutzer hat Godot anstelle von Unreal genehmigt.

## Rechner

HP ProBook 450 G10, Windows 11 Enterprise 10.0.26100 x64, Intel Core i5-1335U (10 Kerne/12 Threads), 15,64 GB RAM, Intel UHD Graphics, Treiber 32.0.101.5763. OpenGL 3.3 Compatibility wurde beim tatsächlichen Spielstart bestätigt.

## Aktive Werkzeuge

- Godot: `4.7.2.stable.official.ed1daf0bf`, per `scoop install godot`.
- EXE: `C:\Users\durmaz\scoop\apps\godot\current\godot.exe`; Konsolenversion `godot.console.exe`; Shim `godot`.
- Blender 4.5.5 LTS: `C:\Users\durmaz\Documents\PromptFighterUltimate\tools\blender-4.5.5-windows-x64\blender.exe`.
- Git 2.55.0.windows.3: `C:\tools\git\cmd\git.exe`.
- Git LFS 3.7.1 repository-lokal; Scoop 0.5.3.
- Unreal/MSVC/Windows SDK sind für diesen GDScript-Windows-Export nicht erforderlich. Historische Inventur in `docs/legacy-unreal/SETUP.md`.

Scoop installiert Godot hier ins Benutzerkonto. Es hebt keine Berechtigungsgrenzen auf. Keine Sicherheitsrichtlinie wurde geändert.

## Herkunft und Verifikation

Blender: [offizielle ZIP](https://download.blender.org/release/Blender4.5/blender-4.5.5-windows-x64.zip), 398.872.872 Bytes, SHA-256 `0674f9ce87d65d35015645a24dd0a3221f93b95d81a5b2be72c49991f32f23af`. Versions- und Hintergrundtest bestanden.

Godot: Scoop-Manifest `extras/godot`, offizielle GitHub-Release-Binärdatei und Manifest-Hashprüfung. Verifiziert mit `godot --version`.

Exportvorlagen: [Godot 4.7.2 stable](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable), Datei `Godot_v4.7.2-stable_export_templates.tpz`, 1.281.349.702 Bytes. SHA-256 `f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011` stimmt mit dem veröffentlichten Release-Asset-Digest überein. Archiv liegt unter `tools/`; nur `windows_release_x86_64.exe` und `windows_debug_x86_64.exe` nach `tools/godot-templates/` extrahiert. Diese offiziellen unveränderten Vorlagen sind in `godot/export_presets.cfg` eingetragen.

## Start, Test, Build

Aus `C:\Users\durmaz\Documents\PromptFighterUltimate`:

```powershell
# Fertiges Spiel, ohne Editor oder Installation
.\Start-PFU.cmd

# Entwicklung
godot --editor --path godot
godot --path godot

# Echter Engine-Import und Test, ohne PowerShell-Richtlinienänderung
godot --headless --path godot --editor --import --quit
godot --headless --path godot --script res://tests/test_game.gd -- --report=C:/Users/durmaz/Documents/PromptFighterUltimate/docs/godot-tests.json

# Buildhelfer: prüft Version, importiert, testet, exportiert und legt Lizenzen bei
.\scripts\Build-Windows.ps1

# Direkter Export, wenn die vorhandenen Skripte nicht ausgeführt werden dürfen
godot --headless --path godot --export-release Windows ../builds/windows/PromptFighterUltimate.exe

# GLB-Dateien aus den editierbaren Blender-Quellen neu erzeugen
.\tools\blender-4.5.5-windows-x64\blender.exe --background --python-exit-code 1 --python scripts/export_godot_assets.py
```

Die Buildskripte installieren nichts und verändern keine ExecutionPolicy. Der Export verwendet die offiziellen vorgefertigten Engine-Vorlagen; es wird kein eigener C++-Engine-Build behauptet.

## Daten und Weitergabe

Die EXE und gleichnamige PCK liegen zusammen in `builds/windows/`. `THIRD-PARTY-NOTICES.txt` wird aus Godots eingebauten Lizenz-/Copyrightdaten erzeugt. Beide Dateien und die Hinweise bei einer Weitergabe zusammen belassen. Es findet keine automatische Veröffentlichung statt.

Prompt-Einstellungen speichert Godot lokal über `user://preferences.cfg` im benutzerspezifischen Anwendungsdatenverzeichnis. Automatisierte Headless-/Smoke-Tests schreiben keine Einstellungen.

`.blend`, `.fbx`, `.uasset`, `.png` und `.glb` sind für Git LFS konfiguriert. Builds, portable Tools und Godot-Cache werden ignoriert. Der lokale Unreal-Altstand und seine Build-/Referenztests wurden nicht gelöscht.

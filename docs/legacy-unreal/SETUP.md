# System- und Entwicklungsumgebung

Erfasst am 2026-09-18. Nur tatsächlich ermittelte Werte sind eingetragen.

## Hardware und Betriebssystem

- Gerät: HP ProBook 450 15.6 inch G10 Notebook PC
- Betriebssystem: Windows 11 Enterprise, Version 10.0.26100, Build 26100, 64-Bit
- CPU: Intel Core i5-1335U, 10 Kerne / 12 logische Prozessoren
- RAM: 15,64 GB
- GPU: Intel UHD Graphics
- Grafiktreiber: 32.0.101.5763 vom 2024-07-08
- Anzeige bei Prüfung: 1920 × 1080
- Laufwerk C: 475,7 GB gesamt, 62,5 GB frei

## Erkannte Werkzeuge

- Git: 2.55.0.windows.3 – `C:\tools\git\cmd\git.exe`
- winget: 1.29.290 – `C:\Users\durmaz\AppData\Local\Microsoft\WindowsApps\winget.exe`
- .NET: Kommando vorhanden – `C:\Program Files\dotnet\dotnet.exe`
- Visual Studio Community 2022: 17.12.4 (Installation 17.12.35707.178) – `C:\Program Files\Microsoft Visual Studio\2022\Community`
- Visual Studio Installer: `C:\Program Files (x86)\Microsoft Visual Studio\Installer`
- Blender: 4.5.5 LTS portable – `C:\Users\durmaz\Documents\PromptFighterUltimate\tools\blender-4.5.5-windows-x64\blender.exe`
- Unreal Engine: nicht gefunden
- Epic Games Launcher: nicht gefunden
- Windows SDK: nicht gefunden
- MSVC x64/x86 Build Tools: durch `vswhere -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64` nicht gefunden
- Scoop: 0.5.3 – `C:\Users\durmaz\scoop\shims\scoop.ps1`
- Git LFS: 3.7.1, repository-lokal aktiviert

## Blender-Verifikation

- Offizielle Quelle: `https://download.blender.org/release/Blender4.5/blender-4.5.5-windows-x64.zip`
- Größe: 398.872.872 Bytes
- Offizielle SHA-256: `0674f9ce87d65d35015645a24dd0a3221f93b95d81a5b2be72c49991f32f23af`
- Versionsausgabe: `Blender 4.5.5 LTS`
- Hintergrundtest: `PFU_BLENDER_SMOKE_OK 4.5.5 LTS 4`

## Unreal- und Visual-Studio-Auswahl

Geplant ist Unreal Engine 5.7. Die offizielle Epic-Kompatibilitätstabelle unterstützt dafür Visual Studio 2022 ab 17.8; 17.14 ist die empfohlene Standardversion. Die vorhandene Version 17.12.4 erfüllt damit die Mindestversion, benötigt aber noch den C++-Workload, MSVC v143 und ein Windows SDK. Unreal 5.8 wurde nicht gewählt, weil es Visual Studio 17.14 oder neuer voraussetzt.

Der Launcher ist über Scoop noch nicht installiert. Das geprüfte Manifest `games/epic-games-launcher` nutzt das offizielle Epic-MSI und dessen SHA-256, verlangt im Post-Install-Schritt aber Administratorrechte. Der nicht erhöhte Installationsversuch endete ohne Launcher mit `Install failed`.

## Geplante reduzierte Unreal-Konfiguration

Wegen integrierter GPU, 16 GB RAM und begrenztem freien Speicher:

- kleines C++-Projekt ohne Starter Content
- Scalable-/Mobile-Rendering statt High-End-Desktop-Vorgaben
- DirectX 11 als konservativer erster Windows-Testpfad, sofern die installierte Engine dies unterstützt
- kein Lumen, Nanite oder Virtual Shadow Maps als Pflichtbestandteil
- kleine Texturen, einfache Materialien, begrenzte Partikel und einfache Kollision
- Engine-/Build-Versionen erst nach tatsächlicher Installation ergänzen

## Git und große Binärdateien

Git LFS ist repository-lokal eingerichtet. `.blend`, `.fbx`, `.uasset` und `.png` sind in `.gitattributes` für LFS konfiguriert. Exportdateien und portable Werkzeuge bleiben zusätzlich über `.gitignore` aus normalen Commits ausgeschlossen.

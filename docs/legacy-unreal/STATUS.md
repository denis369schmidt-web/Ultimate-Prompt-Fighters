# Projektstatus

Letzte Aktualisierung: 2026-09-18

## Phase 1 – System prüfen und Projekt anlegen

Status: **abgeschlossen**

Tatsächlich erledigt:

- Windows-, Hardware-, Datenträger- und Werkzeugbestand per PowerShell gelesen.
- Netzwerkzugriff gegen die offizielle Blender-Webseite erfolgreich geprüft (HTTP 200).
- Browser-/Bildschirm-Automation ist verfügbar; aktuell wurden keine nativen App-Fenster aufgelistet.
- Neues Projekt unter `C:\Users\durmaz\Documents\PromptFighterUltimate` angelegt.
- Grundstruktur und Projektdokumentation erstellt.
- Git 2.55.0.windows.3 und winget 1.29.290 erkannt.
- Git-Repository auf Branch `main` initialisiert; Git LFS 3.7.1 lokal aktiviert.

Wichtige Systemgrenzen:

- 15,64 GB RAM.
- Intel UHD Graphics mit gemeinsamem Speicher; keine dedizierte GPU erkannt.
- 62,5 GB freier Speicher auf Laufwerk C: zum Prüfzeitpunkt.
- Unreal muss mit reduzierter Darstellung und kleinem Content-Umfang betrieben werden. Ein großer Engine-Download wird erst nach Größen-/Kompatibilitätsprüfung begonnen.

## Phase 2 – Werkzeuge

Status: **teilweise abgeschlossen, extern blockiert**

- Blender 4.5.5 LTS portable aus offizieller Blender-ZIP installiert.
- SHA-256 `0674f9ce87d65d35015645a24dd0a3221f93b95d81a5b2be72c49991f32f23af` gegen die offizielle Prüfsummendatei bestätigt.
- Blender-Versionsabfrage und Python-Hintergrundtest erfolgreich.
- Scoop 0.5.3 erkannt. Offiziellen bekannten `games`-Bucket hinzugefügt und Epic-Manifest geprüft.
- `scoop install epic-games-launcher` lud das offizielle MSI mit korrekter Prüfsumme, stoppte dann erwartungsgemäß bei `requires admin rights to install`.
- Scoop kennzeichnet den Eintrag als `Install failed`; keine `EpicGamesLauncher.exe` ist vorhanden.
- Unreal Engine, MSVC-C++-Werkzeugsatz und Windows SDK fehlen weiterhin.

## Phasen 3–4 – Produktziel und erster Kampf

Status: **als Quellcode implementiert, nicht in Unreal kompiliert oder gespielt**

- Unreal-5.7-C++-Projekt mit Laufzeit-Arena, Kamera, zwei getrennten Promptfeldern und zwei Startmodi erstellt.
- Manuell: A/D, F, G für Spieler 1; Pfeiltasten links/rechts, K, L für Spieler 2.
- Autonom: zwei `PFUAIController` nutzen dieselben `PFUCombatComponent`-Angriffe wie die manuelle Steuerung.
- Lebensanzeigen, 90-Sekunden-Timer, Ergebnis, Unentschieden und Neustart implementiert.
- Fallback-Geometrie ermöglicht später einen Start ohne zuvor gebaute Blueprint-Assets.

## Phase 5 – Konzeptgrafik

Status: **abgeschlossen und dokumentiert**

- Vier Konzeptbilder mit dem eingebauten Bildgenerator erzeugt und in `art/references/` gespeichert.
- Vorder-/Seiten-/Rückansichten, Materialdetails, Arena und Größenvergleich vorhanden.
- Erkannte Widersprüche sind in `docs/ART_DIRECTION.md` dokumentiert.

## Phase 6 – Blender-Produktion

Status: **für den Prototyp abgeschlossen und getestet**

- Zwei getrennte, gegliederte Kämpfer mit je 18 Bones, starr gewichteten Segmenten und modularen Teilen.
- Je sieben Actions: Idle, Move, LightAttack, SpecialAttack, HitReact, Defeat, Victory.
- Modulare Arena mit 138 Meshobjekten erzeugt.
- Bearbeitbare `.blend`-Dateien, reproduzierbare Python-Skripte, Vorschauen und FBX-Exporte vorhanden.
- Quellprüfung und echter FBX-Reimport erfolgreich; ein gefundener Action-Leak wurde behoben und erneut geprüft.

## Phasen 7–8 – Unreal-Architektur, Prompt und Balancing

Status: **implementiert; Engine-Build offen**

- Klassen für Definition, Promptinterpretation, Assemblierung, Kampf, Eingabe, KI, Match, Kamera und UI erstellt.
- FNV-basierter reproduzierbarer Seed, getrennte Spielerindizes, 100 Attributpunkte, Grenzen und 60-Punkte-Fähigkeitsbudget.
- Kontrollbegriffe wie „unbesiegbar“ ändern die festgelegten Grenzen nicht.
- Drei Unreal-Automationstests liegen vor; sie konnten ohne Engine nicht ausgeführt werden.
- Sieben engineunabhängige Referenztests sind erfolgreich gelaufen.

## Phase 9 – Variantenbibliothek

Status: **bewusst zurückgestellt**

Die 120 Vorlagen werden gemäß Vorgabe erst nach einem tatsächlich spielbaren lokalen Unreal-Kampf erzeugt.

## Phase 10 – Audio

Status: **Platzhalter erzeugt; Unreal-Import offen**

- Fünf selbst erzeugte Mono-WAV-Dateien mit 44,1 kHz vorhanden.
- Keine externe API und keine Drittanbieter-Samples verwendet.

## Phase 11 – Tests und echte Ausführung

Status: **lokale Tests abgeschlossen; Unreal-Lauf offen**

- 7/7 Python-Referenztests bestanden.
- Agentensimulation endet nach 10,0 s mit echten Treffern; Ergebnis bei diesem Seed: Spieler 2, 5,5 Restleben.
- Blender-Quellen und FBX-Reimporte bestanden.
- Unreal-Kompilierung, Editorstart, Tastaturtest, Agentenkampf im Editor und Windows-Paketbuild sind mangels Engine/Toolchain offen.

## Phase 12 – Mobile-Optimierung

Status: **Konfiguration vorbereitet; Gerätetest offen**

- Mobile/Scalable, Forward Shading, kein Lumen, keine Virtual Shadow Maps und einfache Geometrie voreingestellt.
- Android SDK/NDK/JDK bleiben bis nach dem stabilen Windows-Prototyp zurückgestellt.
- 60 FPS sind nur Ziel, keine gemessene Zusage.

## Phase 13 – Weitere Meilensteine

Status: **planmäßig zurückgestellt**

Arcade, Bosse, Online-Versus, Android-Build, Monetarisierung und Veröffentlichung beginnen erst nach dem lokalen Prototyp.

## Aktuelle Blockaden

1. Epic Games Launcher benötigt trotz Scoop eine echte Administratorfreigabe.
2. Epic-Anmeldung und die Preis-/EULA-Bestätigung müssen vom Benutzer erfolgen.
3. Visual Studio 17.12.4 ist vorhanden, aber `Game development with C++`, MSVC und Windows SDK fehlen. Scoop bietet dafür kein passendes Manifest.
4. Auf C: sind aktuell nur etwa 54,3 GB frei; vor Engine-Installation muss die im Launcher angezeigte Größe geprüft und ausreichend Build-Puffer belassen werden.

## Exakter nächster Arbeitsschritt

Benutzer hat ausdrücklich keine Administratorrechte. Der bisherige Vorschlag einer erhöhten PowerShell ist für ihn nicht ausführbar und zurückgenommen. Scoop hebt Windows-Berechtigungen nicht auf.

Am 2026-09-18 zusätzlich rein lesend geprüft: `AllowStandardUserControl` ist in den drei geprüften Visual-Studio-Setup-Registrypfaden nicht gesetzt. Es wurde keine Richtlinie geändert. Microsoft dokumentiert die Delegation an Standardbenutzer als Administratorentscheidung; damit ist aktuell kein freigegebener Weg zur Ergänzung der fehlenden VS-Komponenten nachgewiesen.

1. Für Unreal-C++ ist die Einrichtung durch die zuständige IT oder ein anderer geeigneter Rechner nötig. Epic nennt den Microsoft Store als alternativen Launcher-Bezugsweg; dessen Verfügbarkeit und Adminfreiheit auf diesem Gerät sind nicht bestätigt, und er löst den fehlenden C++-Werkzeugsatz nicht.
2. Alternativ kann der Benutzer einen zusätzlichen Prototyp mit einer portablen Engine genehmigen. Das wäre eine Änderung der bisherigen Unreal-Vorgabe und wird nicht stillschweigend vorgenommen.
3. Nach Bereitstellung der Unreal-Umgebung: `scripts\Build-Windows.ps1`, Fehlerkorrektur gegen die installierte API, Unreal-Import und echte Spieltests.

Quellen: https://learn.microsoft.com/en-us/visualstudio/ide/user-permissions-and-visual-studio und https://www.epicgames.com/help/c-32735058/a19757059?lang=en-US

# Testbericht

Letzte Aktualisierung: 2026-09-18

## Durchgeführte Prüfungen

### Systeminventur

- PowerShell-Hardwareabfragen: bestanden.
- Freier Speicher und Laufwerkszustand: bestanden; Laufwerk C: gesund, 62,5 GB frei.
- Git-Aufruf: bestanden (`git version 2.55.0.windows.3`).
- winget-Aufruf: bestanden (`v1.29.290`).
- Netzwerkprüfung zur offiziellen Blender-Webseite: bestanden (HTTP 200).
- Zielprojekt war vor Anlage nicht vorhanden; die neue Verzeichnisstruktur wurde anschließend bestätigt.

### Blender 4.5.5 LTS

- Versionsabfrage: bestanden.
- Python-Hintergrundtest: bestanden.
- Ninja-Quelle: 27 Meshes, 1.602 Vertices, 3.096 Dreiecke, 18 Bones, 7 Actions, 0 ungewichtete Vertices, 0 ungültige Normalen.
- Golem-Quelle: 33 Meshes, 1.076 Vertices, 2.020 Dreiecke, 18 Bones, 7 Actions, 0 ungewichtete Vertices, 0 ungültige Normalen.
- Arena-Quelle: 138 Meshes, 5.162 Vertices, 9.772 Dreiecke, 7 Materialien, 0 ungültige Normalen.
- FBX-Reimport für Ninja, Golem und Arena: bestanden.
- Beim ersten Golem-Export wurden zusätzlich Ninja-Actions erkannt. Ursache war ein nicht geleerter Action-Datenblock; behoben und mit exakt 7 Golem-Actions erneut bestanden.

### Lokale Kampf- und Promptlogik

Ausgeführt mit `python scripts\test_pfu_local_simulation.py`:

- getrennte Spielerprofile: bestanden
- exakt 100 Attributpunkte und Grenzwerte: bestanden
- ungültige/leere/übertriebene Prompts: bestanden
- reproduzierbare Seeds und Werte: bestanden
- keine Mehrfachschäden derselben Attack-ID: bestanden
- identische Regeln für manuell/autonom: bestanden
- Sieg, Unentschieden und Neustart: bestanden
- echter autonomer Simulationskampf: bestanden

Gesamt: 7/7 Tests bestanden. Demonstrationslauf: Spieler 2 gewinnt nach 10,0 Sekunden, 5,5 Restleben.

### Audio

- Fünf Mono-WAV-Dateien erfolgreich erzeugt und Header gelesen.
- Alle Dateien: 44.100 Hz, 16 Bit PCM, ein Kanal.

### Scoop/Epic

- Offizielles Epic-MSI geladen und Hashprüfung durch Scoop bestanden.
- Installation nicht bestanden: Post-Install benötigt Administratorrechte.
- Keine Launcher-EXE an Scoop- oder Standardpfaden vorhanden.

### Buildhelfer

- `scripts\Build-Windows.ps1` ausgeführt.
- Erwartetes, korrektes Ergebnis: Abbruch mit `Keine Unreal-Engine-Installation gefunden`; es wurde kein Build behauptet oder erzeugt.

## Noch nicht ausgeführt

- Unreal-Projektgenerierung und C++-Build.
- Agentenkampf und beide manuellen Steuerungen.
- Windows-Paketbuild und grafischer Lauf.
- Unreal-FBX-Importtest und Unreal-Materialnachbau.
- Unreal-Automationstests.
- Echte Laufzeit-/Leistungsmessungen auf Windows und Android.

Nicht ausgeführte Tests gelten ausdrücklich nicht als bestanden.

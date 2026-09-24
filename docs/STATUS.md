# Projektstatus

Stand: 2026-09-18. Aktive Engine: Godot 4.7.2 stable. Projekt: `C:\Users\durmaz\Documents\PromptFighterUltimate`.

## Aktuelle Etappe – Enginewechsel

Der Nutzer hat den Wechsel zu Godot ausdrücklich genehmigt. Godot wurde über Scoop im Benutzerkonto installiert; keine Adminfreigabe oder Umgehung von Windows-Richtlinien. Der Unreal-Quellstand bleibt erhalten, gehört aber nicht mehr zum aktiven Produkt. Die bisherigen Berichte wurden nach `docs/legacy-unreal/` kopiert.

Die Etappe liefert einen eigenständigen Windows-Prototyp. Sie erklärt nicht das gesamte ursprüngliche Spieleprojekt für abgeschlossen.

## Phase 1 – System und Projekt

Abgeschlossen. Windows 11 Enterprise, HP ProBook/i5-1335U, 15,64 GB RAM und Intel UHD Graphics ermittelt. Git/LFS und Projektstruktur vorhanden. Keine dedizierte GPU. Aktuelle native Computer-Use-Anbindung kann Fenster auflisten; beim Spieltest zeigte sie den gesperrten Windows-Desktop. Keine Eingabeversuche nach Erkennen der Sperre.

## Phase 2 – Werkzeuge

Für Godot abgeschlossen: Blender 4.5.5 LTS portable und Godot 4.7.2 stable. Offizielle Exportvorlagen geladen, SHA-256 geprüft und nur Windows-x86_64-Vorlagen ins Projekt extrahiert. Keine Unreal-/MSVC-/SDK-Installation mehr für diesen Windows-Build erforderlich. Details in SETUP.md.

## Phasen 3–4 – Erster lokaler Kampf

Implementiert und als Windows-Build ausgeführt:

- Zwei voneinander unabhängige Promptfelder.
- Ninja und Golem in der nächtlichen Zitadellen-Arena.
- Lokaler Tastatur-Versus und autonome regelbasierte Agenten.
- Gemeinsamer GDScript-Kampfkern für beide Modi.
- Bewegung, Standard-/Spezialangriff, Trefferreaktion, Schaden, Cooldowns.
- Lebensanzeigen, 90-Sekunden-Timer, Ergebnis, Unentschieden, Neustart, Pause und Rückkehr zur Auswahl.
- Lokale Speicherung beider Prompttexte; keine Online-Dienste.

Automatisierte Steuerungsprüfung und gerenderter Agentenkampf bestanden. Physischer Tastatur-/Maus-End-to-End-Test bleibt bis zum Entsperren des Desktops offen.

## Phase 5 – Konzeptgrafik

Vier generierte Referenzbilder und Konsistenzprüfung vorhanden. Sie sind Zielbilder, keine Screenshots des Spiels.

## Phase 6 – Blender und Import

Zwei gegliederte Low-Poly-Quellen mit je 18 Bones und sieben Actions sowie modulare Arena vorhanden. GLB-Export und echter Godot-Import bestanden. Maßstab und Kameradarstellung anhand echter Renderbilder geprüft. Farben/Emission werden in Godot angepasst. Animationsclips sind importiert und im Lauf in Benutzung; vollständige Gelenk-, Bodenkontakt- und Kontaktlesbarkeitsabnahme ist noch offen. Kein fertiger hochwertiger Art-Stand.

## Phasen 7–8 – Architektur, Prompt und Balancing

Aktiv in `godot/scripts/`:

- `prompt_interpreter.gd`: deterministische lokale Interpretation, getrennte Profile, zwei kompatible Skelett-/Modulfamilien, Elemente und Farben.
- `combat.gd`: Zustände, Bewegung, zentrale Trefferregeln, Angriffe, KI-Kommandos und Rundenende.
- `fighter_view.gd`: GLB-Modelle, Materialien, Animationen, Spielermarkierungen.
- `main.gd`: Kamera, UI, Eingaberouten, Audio, Speicherung und Laufzeittest.

Jedes Profil hat exakt 100 Attributpunkte (je 8–36), Fähigkeiten kosten zusammen maximal 60. Gleicher Prompt bleibt unabhängig vom Spielerslot reproduzierbar. Aktuell wählen die Module im Wesentlichen zwischen Ninja und Golem; eine reichhaltige austauschbare Ausrüstungsbibliothek ist nicht vorhanden. Technik hat noch keinen eigenen Kampfeffekt.

30 deterministische Ninja/Golem-Paarungen ergeben 5 Ninja- und 25 Golem-Siege. Das ist ein nachgewiesener Balance-Restpunkt, keine Fairness-Abnahme.

## Phase 9 – Variantenbibliothek

Noch nicht begonnen. Keine Behauptung von 120 eigenständigen Modellen oder Vorlagen. Erst manuellen Kernablauf abnehmen, Balancebasis und sichtbare austauschbare Module herstellen; dann 120 reproduzierbare Vorlagen über dieselben Datenstrukturen.

## Phase 10 – Audio

Fünf lokal synthetisierte WAV-Platzhalter importiert und an Treffer, Spezialangriff, Start und Sieg angeschlossen. Keine externen Samples/API-Kosten. Hörprüfung durch Menschen bleibt offen.

## Phase 11 – Tests und Ausführung

- 32/32 tatsächliche Godot-Tests bestanden; JSON-Bericht in `docs/godot-tests.json`.
- 1.000 Eingabefälle für Profilgrenzen geprüft.
- 30 autonome Simulationsmatches mit 691 Treffern beendet.
- Je sieben Animationen und 18 Bones aus beiden importierten GLBs bestätigt.
- Exportierter Windows-Build: zwei gerenderte Runden, 46 Treffer, ein Neustart; Abschlussmarker in `docs/godot-build-smoke.log`.
- Echte Viewport-Screenshots unter `docs/screenshots/`.
- Keine Fehler/Warnungen im abschließenden Test-/Build-Smoke-Protokoll.
- Native manuelle Abnahme wegen gesperrtem Desktop offen.

## Phase 12 – Mobile

Compatibility-Renderer, einfache Materialien/Geometrie und begrenzte Effekte. Android-Toolchain, Touchsteuerung, LODs und Gerätetests fehlen noch. 60 FPS sind Ziel, kein gemessener Leistungsnachweis.

## Phase 13 – Spätere Meilensteine

Arcade, Bosse, Online-Versus, Android, Monetarisierung und Veröffentlichung nicht begonnen. Keine Cloudressourcen oder kostenpflichtigen Dienste eingerichtet.

## Phase 14 – Übergabe und nächster Schritt

Start: `Start-PFU.cmd` oder `builds/windows/PromptFighterUltimate.exe`.
Editor: `godot --editor --path godot`.
Tests: `scripts/Test-Project.ps1`.
Build: `scripts/Build-Windows.ps1`.

Nächster Schritt: Nach Entsperren von Windows beide manuellen Steuerungen, Treffer, Spezialangriffe, Pause und Neustart am echten Fenster abnehmen. Anschließend Golem-Dominanz und Kampfanimationen verbessern, bevor Phase 9 erweitert wird. Es gibt keinen Adminblocker für Godot; der offene Interaktionstest benötigt einen entsperrten Desktop.

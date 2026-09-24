# Prompt Fighter Ultimate

Spielbarer lokaler Godot-4-Prototyp: zwei getrennte Spieler-Prompts, zwei 3D-Kämpfer und eine gemeinsame Kampfsimulation für Tastatur-Versus und autonome Agenten. Seit der ausdrücklichen Nutzerfreigabe am 18.09.2026 ersetzt Godot den nicht ausführbaren Unreal-Entwicklungspfad.

## Direkt starten

`Start-PFU.cmd` im Projektverzeichnis doppelklicken. Alternativ:

```powershell
.\builds\windows\PromptFighterUltimate.exe
```

Keine Installation oder Adminrechte nötig. EXE und PCK müssen zusammenbleiben. Der Build ist ein nicht signierter lokaler Entwicklungsbuild; Windows-Sicherheitsregeln bleiben unverändert.

Zwei eigene Prompts eingeben, dann **LOKALER VERSUS** oder **AGENTENKAMPF** wählen.

- Spieler 1: A/D bewegen, F Standardangriff, G Spezialangriff.
- Spieler 2: Pfeile links/rechts bewegen, K Standardangriff, L Spezialangriff.
- R startet die Runde neu; ESC pausiert/setzt fort; Auswahl öffnet die Promptfelder.
- Bei Fokusverlust pausiert der manuelle Modus. Danach ESC drücken.

## Verifizierter Stand

Godot 4.7.2 stable läuft auf der vorhandenen Intel UHD Graphics. 32/32 Tests im tatsächlichen GDScript-Spielcode bestanden. Der exportierte Windows-Build absolvierte zwei gerenderte Agentenrunden mit 46 Treffern und einem Neustart. Echte Spielbilder: [Kampf](docs/screenshots/godot-fight.png), [Ergebnis](docs/screenshots/godot-result.png), [Auswahl](docs/screenshots/godot-selection.png).

Manuelle OS-Tastatur-/Mausabnahme bleibt offen, weil der Windows-Desktop beim Test gesperrt war. Die getrennten Eingaberouten wurden in Godot automatisiert geprüft. Grafik und Animationen sind einfache Prototypen, Balancing ist vorläufig. Noch keine 120 modularen Vorlagen, Android-, Online- oder Arcade-Version.

## Entwicklung

Befehle aus dem Projektverzeichnis:

```powershell
godot --editor --path .\godot
godot --path .\godot
.\scripts\Test-Project.ps1
.\scripts\Build-Windows.ps1
```

Die Skripte umgehen keine Sicherheitsrichtlinien und führen keine Downloads aus. Ist die Skriptausführung organisatorisch gesperrt, nicht umgehen; die einzelnen Godot-Befehle stehen in [SETUP](docs/SETUP.md).

## Dateien

- `godot/` – aktives Projekt, GDScript und importierte GLB-/WAV-Assets.
- `art/blender/` – editierbare Ninja-, Golem- und Arena-Dateien.
- `art/references/` – Konzeptbilder, nicht mit Spielgrafik gleichzusetzen.
- `scripts/export_godot_assets.py` – reproduzierbarer Blender→GLB-Export.
- `builds/windows/` – eigenständiger lokaler Build und Lizenzhinweise.
- `game/` – erhaltener, unkompilierter Unreal-Altstand; nicht der aktive Build.
- `docs/` – [Phasenstatus](docs/STATUS.md), [Tests](docs/TEST_REPORT.md), [Art Direction](docs/ART_DIRECTION.md).
- `docs/legacy-unreal/` – Dokumentation vor dem Enginewechsel.

Prompts sind ausschließlich lokale Daten; kein kostenpflichtiges Modell, Netzwerkaufruf oder ausgeführter Promptcode. Große Produktionsdateien werden per Git LFS geführt. Tools, Export-Cache und Builds sind ignoriert.

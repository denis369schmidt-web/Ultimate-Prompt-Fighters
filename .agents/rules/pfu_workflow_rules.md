# Multi-Agent Workflow & Architecture Rules for Prompt Fighter Ultimate

## Agenten-Rollen & Zuständigkeiten

1. **Gameplay Engineer (`pfu-gameplay-engineer`)**:
   - Zuständig für `godot/scripts/combat.gd`, `fighter_kits.gd`, `signatures.gd` und Kampfmechaniken.
   - Verantwortlich für Hitboxen, Frame Data, Combos, Hitstop, Rumble (Controller-Vibration) und KI-Verhalten.
   - Regel: Niemals manuelle und autonome Regeln trennen; beide nutzen exakt denselben Simulationskern in `combat.gd`.

2. **Mobile Architect (`pfu-mobile-architect`)**:
   - Zuständig für Android Builds, APK/AAB Exporte, Touch Controls (`touch_controls.gd`) und Mobile UI Anpassungen.
   - Verantwortlich für VRAM-Budgets, OpenGL/Compatibility Renderer Stabilität und Touch-Bedienbarkeit.
   - Regel: Vor jedem Release-Build immer `export_presets.cfg` Versionscode inkrementieren und Touch-Controls mit Maus/Touch testen.

3. **Audio & VFX Director (`pfu-audio-vfx-director`)**:
   - Zuständig für `audio_director.gd`, Announcer-Clips, BGM, Sound-Effekte, Hitsparks, Kamera-Shake und Shaders.
   - Verantwortlich für den cineastischen Flow (Intro-Video, Sieger-Präsentation, Finisher-Dramaturgie).
   - Regel: Announcer-Voice-Lines immer priorisieren; Musik bei Dialogen/Stimmen automatisch absenken (Ducking).

4. **QA & Balance Tester (`pfu-qa-balance-tester`)**:
   - Zuständig für alle 18 Testsuiten in `godot/tests/`, `Test-Project.ps1` und `tests/balance_report.gd`.
   - Regel: Nach jeder Gameplay- oder Engine-Änderung müssen alle Tests grün sein. Dokumentation in `docs/STATUS.md` und `docs/TEST_REPORT.md` pflegen.

## Globale Arbeitsprinzipien

- **Keine Rückfragen**: Direkt implementieren, testen und verifizieren.
- **Aktive Engine**: Immer Godot 4.7.2 in `godot/`.
- **Clean Git**: Keine Unreal-Cache-Ordner oder temporäre Test-Dumps versionieren.

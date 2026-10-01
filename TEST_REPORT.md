# Test Report: Prompt Fighter Ultimate

**Datum:** 24. September 2026  
**Engine:** Godot Engine v4.7.2 stable win64  
**Renderer:** Compatibility (OpenGL 3.3.0)  
**Testumgebung:** Windows x86_64, Intel UHD Graphics  
**Ergebnis:** 100% Tests bestanden (0 Fehler, 0 Regressionen)

---

## 1. Test-Suiten Übersicht

### Suite A: Kernmechanik (`res://tests/test_game.gd`)
- **Tests ausgeführt:** 36
- **Bestanden:** 36
- **Fehlgeschlagen:** 0
- **Geprüfte Komponenten:**
  - Statuswerte-Summe (= 100)
  - Energiekosten-Budget (<= 60)
  - Schadensberechnung, Hitstun, Windup, Cooldown
  - Richtungs- und Distanzprüfungen
  - Elementar-Effekte & Farben

### Suite B: Smash-Mechanik & Plattformen (`res://scripts/test_smash_mechanics.gd`)
- **Bestanden:** 100%
- **Geprüfte Komponenten:**
  - 3-Stock-System (Leben sinken bei Blast-Zone-Überschreitung)
  - Blast-Zone-Erkennung (Left: -9.5m, Right: +9.5m, Bottom: -4.0m)
  - Durchspringbare Einweg-Plattformen (Drop-Down mit Taste S / Pfeil-Unten)
  - Rebalancierte 50% Rückstoß-Skalierung (proportional zu fehlenden HP)

### Suite C: Greifen, Werfen & Items (`res://scripts/test_grab_and_items.gd`)
- **Bestanden:** 100%
- **Geprüfte Komponenten:**
  - Greif-Reichweite (0.85m) & Anti-Chain-Grab-Schutzzeit (0.85s)
  - Forward-, Back- und Up-Throws mit Trägheitsübertrag
  - Kisten, Steine, Fässer: Aufheben, Werfen, Flugparabel, Kollision

### Suite D: Explosiv-Fass Detonation (`res://scripts/test_explosive_barrel.gd`)
- **Bestanden:** 100%
- **Geprüfte Komponenten:**
  - Direkter Treffer & Detonation bei Kontakt
  - Flächenschaden (AoE-Radius 2.2m)
  - Knockback-Impuls auf umstehende Kämpfer

### Suite E: Gesamtes 13-Kämpfer Roster (`res://scripts/test_all_playable.gd`)
```
==================================================
TESTING ALL 13 CHARACTERS (PROMPT -> SIM -> VIEW)
==================================================
[golem] family=golem name='CINDER BASTION' valid=true -> SIM & VIEW OK
[ninja] family=ninja name='VOLT SHADOW' valid=true -> SIM & VIEW OK
[valkyrie] family=valkyrie name='VALKYRIE AURA' valid=true -> SIM & VIEW OK
[dragon] family=dragon name='IGNIS DRAKE' valid=true -> SIM & VIEW OK
[anubis] family=anubis name='CYBER ANUBIS' valid=true -> SIM & VIEW OK
[specter] family=specter name='VOID SPECTER' valid=true -> SIM & VIEW OK
[phoenix] family=phoenix name='PHOENIX EMPRESS' valid=true -> SIM & VIEW OK
[kairo] family=kairo name='KAIRO (STURMMÖNCH)' valid=true -> SIM & VIEW OK
[glaciem] family=glaciem name='GLACIEM' valid=true -> SIM & VIEW OK
[oryn] family=oryn name='ORYN' valid=true -> SIM & VIEW OK
[tobi] family=tobi name='TOBI (FEDERFAUST)' valid=true -> SIM & VIEW OK
[zip] family=zip name='ZIP (BLITZKURIER)' valid=true -> SIM & VIEW OK
[raiga] family=raiga name='RAIGA (DONNERFAUST)' valid=true -> SIM & VIEW OK
==================================================
ALL 13 CHARACTERS ARE FULLY PLAYABLE!
==================================================
```

---

## 2. Rendering & Showcase Verifikation
- `Raiga-Screenshot`: Raiga Sternschlag Bodenmandala gerendert.
- `Kampf-Screenshot`: Kampfpose Raiga vs Kairo gerendert.
- `screenshot_all_13_characters_lineup.png`: Panorama aller 13 Charaktere gerendert.
- `Auswahl-Screenshot (entfernt)`: Auswahlmenü (7x2 Raster) gerendert.

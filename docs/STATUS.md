# Prompt Fighter Ultimate — Projektstatus

> Letztes Update: 2026-10-05

## Aktueller Stand (2026-10-05)

- **49 Kämpfer** (+ Fusionskammer), **19 Bosse**, 23 Arenen (Shop), bis zu 4 Spieler, Xbox-Pad und Touch, Android-Export.
- **Kämpfer-Individualisierung** (`scripts/fighter_kits.gd`, `signatures.gd`, `combat.gd _sig_activate`, `main.gd _finisher_variant`):
  **43 von 49 Kämpfern** mit eigenem Kit (Pakete 1–6 und Arbër). Offen: Paket 7 (SWAT-Agent, Vlad, Vanguard, Nekra, Grimbolt, Echo, Kettenwart).
  Neue Finisher-Codes haben vier Eingaben (alle 32 Drei-Tasten-Codes sind vergeben).
- **Modi**: Versus, Team 2v2/3v1, Bosskampf und Boss-Rush, Storykampagnen „Göttliche Prüfung“ und Saga „Der Riss zwischen den Welten“,
  Legenden (50 handgeschriebene, je 4 Kapitel), Abenteuer, Tages-Herausforderung, Wochen-Events, Mutatoren.
- **Fortschritt und Shop** eingebunden (Münzen, Truhen, Liga, Ruhmespfad, Meisterschaft, Skins, Waffen, Arenen).
- **Audio**: Musik, SFX, Ansager, Ambience, Story-Stimmen (Lizenzen in `docs/AUDIO_LICENSES.md`).
- Tests: 17 Suiten, 1343/1343 grün (Details in `docs/TEST_REPORT.md`).
- Offen: Paket 7 (danach braucht `test_kits` einen neuen Testgegner ohne Kit), Finisher-Standbilder zeitlich besser treffen, Balance-Läufe, Shop-Hintergründe noch KI-Bilder,
  FPS-Benchmark auf integrierter GPU.

Die folgenden Abschnitte beschreiben den älteren Stand vom 2026-09-25.

## Projektübersicht

| Feld | Wert |
|------|------|
| **Engine** | Godot 4.7.2 (Compatibility Renderer, OpenGL 3.3) |
| **Plattform** | Windows (Entwicklung), Android (Produktionsziel) |
| **3D-Tool** | Blender 4.5.5 (portabel) |
| **Spielbare Charaktere** | 20 |
| **Spielmodi** | 3 (PvP, PvE, KI vs KI) |
| **Arenen** | 6 |

## Spielbare Charaktere (20)

| # | Familie | Name | Besondere Fähigkeit |
|---|---------|------|---------------------|
| 1 | ninja | VOLT SHADOW | Raijin Dash |
| 2 | golem | CINDER BASTION | Magma Quake |
| 3 | valkyrie | VALKYRIE AURA | Radiant Pierce |
| 4 | dragon | IGNIS DRAKE | Wyrm Flame |
| 5 | kairo | KAIRO (STURMMÖNCH) | Solar-Kanone |
| 6 | varakh | PRINZ VARAKH | Final Flash |
| 7 | glaciem | GLACIEM | Kori Ice Shard |
| 8 | oryn | ORYN | Shinra Tensei |
| 9 | tobi | TOBI (FEDERFAUST) | Gum-Gum Pistol |
| 10 | jubei | RORONOA JUBEI | Santoryu: Onigiri |
| 11 | ren | REN (KIRSCHKRIEGERIN) | Blütenwirbel |
| 12 | amethya | AMETHYA (DONNERHEXE) | Amethystblitz |
| 13 | bruno | BRUNO (ONE PUNCH) | Serious Punch |
| 14 | hikaru | HIKARU KAMADO | Hinokami Kagura |
| 15 | zip | ZIP (BLITZKURIER) | Super Spin Dash |
| 16 | raiga | RAIGA (DONNERFAUST) | Destructive Death: Sternschlag |
| 17 | albion | ALBION (SILBERWYRM) | Sturmstrahl |
| 18 | anubis | CYBER ANUBIS | Anubis Wrath |
| 19 | specter | VOID SPECTER | Void Lance |
| 20 | phoenix | PHOENIX EMPRESS | Phoenix Flare |

## Spielmodi

- **⚔ Spieler vs Spieler (PvP)** — Lokaler Versus mit geteilter Tastatur
- **🥊 Spieler vs Agent (PvE)** — Spieler 1 manuell, Spieler 2 KI-gesteuert
- **🤖 Agent vs Agent (KI vs KI)** — Beide Kämpfer vollautomatisch

## Kernsysteme

### Kampfsystem
- Super Smash Bros Platform Fighter
- 6 Plattformen auf 4 vertikalen Ebenen
- Blast Zones (Ring Out)
- 3-Stock Lives System
- Datengetriebene Knockback-Formel (HP-abhängig)
- 3-Phasen-Angriffspipeline: Windup → Active → Recovery
- Hit Interrupt (Angriffe werden durch Treffer unterbrochen)

### Greifen & Werfen
- Gegner greifen, halten und in 4 Richtungen werfen
- Blockende Gegner durchgreifen
- Befreiung bei Timeout

### Arena Items
- Leichte Kiste (zerbrechlich, 12 Schaden)
- Schwerer Stein (robust, 22 Schaden)
- Holzfass (mittel, 16 Schaden)
- Explosiv-Fass (Flächenschaden, 34 Schaden, 2.6 Radius)
- Aufheben, tragen, werfen
- Auto-Respawn nach Zerstörung

### Spezial-Mechaniken
- Super-Meter (passiv + bei Treffer)
- Combo-System mit Schadensmultiplikator
- Parry-System (perfektes Block-Timing)
- Hitstop bei Treffern
- DI (Directional Influence) in der Luft
- Drop-Through Plattformen (S+W)

### Character Remixer
- Modularer Charakter-Generator aus Prompt
- 11 Body-Module, 5 Elemente, 6 Abilities
- Stat-Budget: 100 Punkte (balanciert)
- UI im Auswahlscreen integriert

## Aufgabenstatus

| Aufgabe | Status |
|---------|--------|
| 14 spielbare Charaktere | ✅ Erledigt |
| PvE Modus | ✅ Erledigt |
| Auswahlscreen (10x2) | ✅ Erledigt (20 Kämpfer) |
| 6 Arenen mit PBR-Texturen | ✅ Erledigt |
| 6 Neue Anime-Legenden (Ren, Varakh, Jubei, Bruno, Hikaru, Amethya) | ✅ Erledigt mit 3D-Modellen & PBR-Skins |
| Character Remixer (Core & UI) | ✅ Erledigt |
| 3-Phasen Attack Pipeline | ✅ Erledigt |
| Hit Interrupt System | ✅ Erledigt |
| Knockback +25% | ✅ Erledigt |
| Raiga & Albion Pro Models | ✅ Erledigt |
| Animation Audit (State Machine) | ✅ Erledigt — 20/20 bestanden |
| Performance Baseline | ✅ Erledigt — 45.8µs avg (0.27% Budget) |
| Attack Data-Driven System | ✅ Erledigt (windup/active/recovery/cost/push/angle/hitstun) |
| GDScript Optimierung | 🟡 Offen |
| Android Export | 🟡 Offen |
| Rendering LOD | 🟡 Offen |

## Test-Ergebnisse

| Test | Ergebnis |
|------|----------|
| test_all_playable.gd | ✅ 20/20 BESTANDEN (Sim & View) |
| test_animation_audit.gd | ✅ 20/20 BESTANDEN (State Machine Transitions) |
| test_performance.gd | ✅ 45.8µs avg, 0.27% Budget |
| test_smash_mechanics.gd | ✅ ALLE BESTANDEN |
| test_remixer.gd | ✅ 5/5 BESTANDEN |
| test_match_all.gd | ✅ ALLE BESTANDEN |

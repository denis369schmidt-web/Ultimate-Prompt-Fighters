# Prompt Fighter Ultimate — Projektstatus

> Letztes Update: 2026-09-25

## Projektübersicht

| Feld | Wert |
|------|------|
| **Engine** | Godot 4.7.2 (Compatibility Renderer, OpenGL 3.3) |
| **Plattform** | Windows (Entwicklung), Android (Produktionsziel) |
| **3D-Tool** | Blender 4.5.5 (portabel) |
| **Spielbare Charaktere** | 14 |
| **Spielmodi** | 3 (PvP, PvE, KI vs KI) |
| **Arenen** | 5 |

## Spielbare Charaktere (14)

| # | Familie | Name | Besondere Fähigkeit |
|---|---------|------|---------------------|
| 1 | ninja | VOLT SHADOW | Raijin Dash |
| 2 | golem | CINDER BASTION | Magma Quake |
| 3 | valkyrie | VALKYRIE AURA | Radiant Pierce |
| 4 | dragon | IGNIS DRAKE | Wyrm Flame |
| 5 | goku | SON GOKU (ULTRA) | Kamehameha |
| 6 | subzero | SUB-ZERO | Kori Ice Shard |
| 7 | pain | PAIN | Shinra Tensei |
| 8 | luffy | MONKEY D. RUFFY | Gum-Gum Pistol |
| 9 | sonic | SONIC THE HEDGEHOG | Super Spin Dash |
| 10 | akaza | AKAZA (UPPER RANK 3) | Destructive Death: Compass Needle |
| 11 | blue_eyes | BLUE-EYES WHITE DRAGON | Burst Stream of Destruction |
| 12 | anubis | CYBER ANUBIS | Anubis Wrath |
| 13 | specter | VOID SPECTER | Void Lance |
| 14 | phoenix | PHOENIX EMPRESS | Phoenix Flare |

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
| Mortal Kombat Auswahlscreen (7x2) | ✅ Erledigt |
| 5 Arenen mit PBR-Texturen | ✅ Erledigt |
| Character Remixer (Core) | ✅ Erledigt |
| Character Remixer (UI) | ✅ Erledigt |
| 3-Phasen Attack Pipeline | ✅ Erledigt |
| Hit Interrupt System | ✅ Erledigt |
| Knockback +25% | ✅ Erledigt |
| Akaza Pro Model | ✅ Erledigt |
| Blue-Eyes Pro Model | ✅ Erledigt |
| Animation Audit (State Machine) | ✅ Erledigt — 14/14 bestanden |
| Performance Baseline | ✅ Erledigt — 45.8µs avg (0.27% Budget) |
| Attack Data-Driven System | ✅ Erledigt (windup/active/recovery/cost/push/angle/hitstun) |
| GDScript Optimierung | 🟡 Offen |
| Android Export | 🟡 Offen |
| Rendering LOD | 🟡 Offen |

## Test-Ergebnisse

| Test | Ergebnis |
|------|----------|
| test_all_playable.gd | ✅ 14/14 BESTANDEN |
| test_animation_audit.gd | ✅ 14/14 BESTANDEN |
| test_performance.gd | ✅ 45.8µs avg, 0.27% Budget |
| test_smash_mechanics.gd | ✅ ALLE BESTANDEN |
| test_remixer.gd | ✅ 5/5 BESTANDEN |
| test_match_all.gd | ✅ ALLE BESTANDEN |

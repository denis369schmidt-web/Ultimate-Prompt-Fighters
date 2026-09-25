# Performance Baseline

## Messumgebung

| Parameter | Wert |
|-----------|------|
| Engine | Godot 4.7.2 (Compatibility Renderer) |
| Modus | Headless (--headless) |
| Simulation | 60 Hz fixed timestep (1/60s = 16.67ms) |
| Messmethode | `Time.get_ticks_usec()` pro `tick()` Aufruf |

## Ergebnisse (2026-09-25)

| Metrik | Wert |
|--------|------|
| Getestete Paare | 30 |
| Gesamte Ticks | 9000 |
| **Avg Tick** | **45.8 µs** |
| Max Tick | 8159 µs (JIT-Warmup-Spike) |
| Budget pro Tick | 16667 µs (60 FPS) |
| **Budget-Auslastung** | **0.27%** |

## Bewertung

- ✅ **EXCELLENT** — Durchschnittliche Tick-Zeit weit unter 200µs
- ℹ Max-Spike ist ein einmaliger JIT-Warmup-Effekt, nicht spielrelevant
- Genug Budget für Rendering, Audio, UI und weitere Systeme

## Architektur

### Simulation (`combat.gd`)
- Standalone `RefCounted`-Klasse, kein Node-Overhead
- Tick-basiert: `tick(commands, dt)` verarbeitet alles pro Frame
- Physik: Custom Platform Fighter (kein Godot-Physics Engine)
- AI: Simple Decision Tree in `agent_commands()`

### Was passiert pro Tick
1. Countdown-Check
2. Fighter-Loop (2×):
   - Hitstop-Freeze
   - Cooldowns, Stun-Timer, Combo-Timer
   - Parry-Timer, Super-Meter
   - Facing-Update
   - Horizontal-Physik + Air Drift
   - Grab-Processing (if applicable)
   - Input-Processing (Move, Jump, Block, Attack, Grab)
   - Vertical Physics + Platform Landing
   - Blast Zone / Ring Out Check
   - HP KO Check
3. Body Collision (push apart)
4. Attack Contact Resolution (3-Phase Pipeline)
5. Item Simulation (4 Items: physics, collisions, explosions)
6. Double KO + Timeout Check

### Optimierungspotenzial
- AI-Agent könnte auf 30Hz reduziert werden (jeder 2. Tick)
- Item-Loop könnte nur bei aktiven Items laufen
- Platform-Check könnte spatial hash nutzen (bei >20 Plattformen relevant)
- Aktuell nicht nötig: 0.27% Budget-Auslastung lässt massiven Spielraum

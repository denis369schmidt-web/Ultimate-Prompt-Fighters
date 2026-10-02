---
name: pfu-look
description: Renders real screenshots of Prompt Fighters (fights, heroes, arenas, finishers, story) and the FPS benchmark, then reviews them visually. Use whenever graphics, characters, arenas, VFX, animation or performance changed, before calling a visual change done.
---

# Prompt Fighters – Look & Performance check

Never judge a visual change from code alone: render it, open the PNG, look at it.

Godot binary: see the `pfu-test` skill. Render scripts need a GPU window (no `--headless`).
Write shots to the session scratchpad, not into the repo.

| What | Command (from `godot/`) |
|---|---|
| Fights in 4 arenas + menu | `"$G" --path . --resolution 1600x900 --script res://tests/render_fight.gd -- --out=<dir> --prefix=<name>` |
| House heroes close up | `... --script res://tests/render_heroes.gd -- --out=<dir> --only=kairo,zip [--pose=Charge]` |
| Fighter kits / specials | `... --script res://tests/render_kits.gd -- --out=<dir> --only=<family>` |
| Arenas | `... --script res://tests/render_arenas.gd -- --out=<dir>` |
| Finishers | `... --script res://tests/render_finishers.gd -- --out=<dir>` |
| Bosses | `... --script res://tests/render_bosses.gd -- --out=<dir>` |
| FPS benchmark | `... --resolution 1920x1080 --script res://tests/bench_render.gd -- --frames=600` → `PFU_BENCH` lines |

## Review checklist

- Characters: textures visible (no flat pastel silhouettes), readable at gameplay distance,
  silhouette distinct from the background, no clipping weapons, rim light not blown out.
- Arenas: depth (fore-, mid-, background), movement (particles, water, fire, foliage, crowds),
  lighting mood matches the arena, platforms textured, no stretched/blurry textures.
- VFX: soft glowing energy (shaders/beam_glow.gdshader), no opaque white boxes.
- Compare before/after shots side by side; note FPS before/after (target: stable 60 on Intel UHD).

---
name: pfu-assets
description: Sources music, sound effects, voices, textures and models for Prompt Fighters from public, freely licensed sources (CC0 first, CC-BY with credit) and records every file's license. Use when adding any third-party asset to the game.
---

# Prompt Fighters – Public assets

The user wants good content from public sources. Only use assets whose license allows
use in a (possibly commercial) game. Order of preference:

1. **CC0 / public domain** – no attribution needed: Kenney (kenney.nl, audio + voice packs),
   Poly Haven (HDRIs, PBR textures, models), ambientCG (PBR textures), OpenGameArt CC0 tag,
   Freesound CC0 filter.
2. **CC-BY 3.0/4.0** – allowed, credit is mandatory (OpenGameArt, Freesound, incompetech).
3. Never: CC-BY-NC, CC-BY-ND, "free for personal use", ripped game audio, unclear licenses,
   anything resembling third-party brands or characters (test_roster checks names).

## Voices

- Announcer and short combat shouts: CC0 voice packs (Kenney "Voiceover Pack").
- Story dialogue: generated offline with Piper TTS and CC0 voices (German: `de_DE-thorsten`,
  dataset CC0). Generated lines are our own files; record the voice model and its license.

## Procedure

1. Download into the session scratchpad, check the license on the source page.
2. Convert: music → OGG Vorbis (~160 kbps, loop points noted), SFX → OGG or WAV 44.1 kHz mono,
   normalized loudness (music about -16 LUFS, SFX peaks below -1 dBFS).
3. Copy into `godot/assets/audio/<music|sfx|voice>/`, run `godot --headless --path . --import`.
4. Add a row to `docs/AUDIO_LICENSES.md` (audio) or `ASSET_LICENSES.md` (everything else):
   file, title, author, source URL, license, changes made.
5. In-game credits must list every CC-BY author.

# Audioquellen und Lizenzen

Alle Audiodateien im Spiel sind gemeinfrei (CC0) oder selbst erzeugt – mit einer Ausnahme: die
Umgebungsgeräusche der Arenen stehen unter CC BY 4.0 und **müssen** mit „JC Sounds“ genannt werden
(Credits und diese Datei). Alle anderen Urheber:innen werden freiwillig in den Credits genannt.

## Musik (`godot/assets/audio/music/`)

Konvertiert nach OGG Vorbis (q5), Lautheit auf -16 LUFS normalisiert (ffmpeg loudnorm).

| Datei | Titel | Urheber:in | Quelle | Lizenz |
|---|---|---|---|---|
| menu_theme.ogg | Übermensch [Main Menu] | Cleyton Kauffman | https://opengameart.org/content/epic-main-menu-theme-loop | CC0 |
| battle_valor.ogg | Battle Theme A | cynicmusic | https://opengameart.org/content/battle-theme-a | CC0 |
| battle_tempest.ogg | Battle RPG Theme (Var) | Cleyton Kauffman | https://opengameart.org/content/boss-battle-theme | CC0 |
| boss_epic.ogg | Epic Boss Battle [Seamlessly Looping] | Juhani Junkala (SubspaceAudio) | https://opengameart.org/content/boss-battle-music | CC0 |
| boss_metal_intro.ogg, boss_metal_loop.ogg | Boss Battle #2 [Symphonic Metal] | nene | https://opengameart.org/content/boss-battle-2-symphonic-metal | CC0 |
| story_first_light.ogg | First Light Particles | Yoiyami | https://opengameart.org/content/first-light-particles-%E2%80%93-cc0-atmospheric-pianoambient-track | CC0 |
| story_emotional.ogg, story_emotional_solo.ogg | Emotional Piano | Centurion_of_war | https://opengameart.org/content/emotional-piano-0 | CC0 |

## Soundeffekte (`godot/assets/audio/sfx/<gruppe>/`)

Unverändert übernommen aus den Kenney-Paketen (https://kenney.nl, Lizenz CC0):
Impact Sounds (Treffer, Block, Landung, K.o.), RPG Audio (Kleidung, Klingen),
Sci-fi Sounds (Energie, Explosionen), Interface Sounds (Menü).

## Stimmen (`godot/assets/audio/voice/`)

- `announcer/`: Kenney „Voiceover Pack (Fighter)“, CC0 (https://kenney.nl/assets/voiceover-pack-fighter).
  Nicht übernommen: Zeilen mit Bezug zu fremden Spielen und Gewaltaufrufe.
- Story-Dialoge: offline erzeugt mit Piper TTS (https://github.com/rhasspy/piper) und den Stimmen
  `de_DE-thorsten-high`, `de_DE-thorsten_emotional-medium` (Thorsten-Voice-Datensatz, CC0) sowie
  `de_DE-kerstin-low` (Kerstin-Datensatz, CC0). Erzeugt durch `tools/voice_lines.py`.

## Alte Platzhalter

`PFU_*.wav` wurden lokal durch `scripts/generate_placeholder_audio.py` erzeugt (keine Fremdinhalte).
Sie werden nur noch für die Jingles „start“ und „victory“ genutzt.

## Umgebungsgeräusche (`godot/assets/audio/ambience/`)

Aus „Nature Ambient Pack Vol 1“ von **JC Sounds**, https://opengameart.org/content/jc-sounds-nature-ambient-pack-vol-1,
Lizenz **CC BY 4.0** (https://creativecommons.org/licenses/by/4.0/) – Namensnennung Pflicht.
Änderungen: auf 75 s gekürzt, Ein-/Ausblendung, Lautheit normalisiert, nach OGG Vorbis konvertiert.

| Datei | Original |
|---|---|
| bonfire.ogg | Fire & Elemental – Large Bonfire |
| torches.ogg | Fire & Elemental – Torch Flame |
| forest_enchanted.ogg | Forest Environments – Enchanted Forest |
| forest_night.ogg | Forest Environments – Forest Night |
| ocean.ogg | Water Environments – Ocean Waves |
| winter_wind.ogg | Weather – Winter Wind |
| desert_wind.ogg | Weather – Desert Wind |

Credit-Zeile: „Ambience: Nature Ambient Pack Vol 1 by JC Sounds (CC BY 4.0)“

## Selbst erzeugt

- `sfx/drill/drill_1..4.ogg` (Arbërs Bohrmaschinen): synthetisch erzeugt (Motorobertöne, Getriebe-Rattern, Bohr-Grit), eigenes Werk.

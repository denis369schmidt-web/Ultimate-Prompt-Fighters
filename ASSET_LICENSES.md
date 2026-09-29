# Asset & IP Licensing Documentation: Prompt Fighter Ultimate

## 1. Kommerzielle Klassifizierung & Grenzen

Dieses Repository unterscheidet strikt zwischen dem **kommerziell freigegebenen Kern-Roster** und **nicht-kommerziellen privaten Prototyp-Charakteren**:

### A. Kommerziell freigegebenes Original-Roster (Commercial Ready)
Diese Charaktere und Assets sind vollständig eigenständig erstellt oder basieren auf freien / permissiven Open-Source-Lizenzen:
- **Volt Ninja** (`ninja`): Eigene 3D-Geometrie, CC0 PBR Texturen, eigene Godot-Shader.
- **Lava Golem** (`golem`): Eigene 3D-Geometrie, prozedurale Basalt-PBR-Texturen.
- **Valkyrie** (`valkyrie`): Eigene Moe-Paladin-Modellierung, CC0 Texturen.
- **Ignis Drake** (`dragon`): Eigener Cyber-Drachenritter, PBR Schuppentexturen.
- **Cyber Anubis** (`anubis`): Mythologisches Thema (Gemeinfreiheit / Public Domain), eigene Obsidian/Gold-Meshes.
- **Void Specter** (`specter`): Eigene Kristallphantom-Meshes, Amethyst-PBR.
- **Phoenix Empress** (`phoenix`): Mythologisches Thema, eigene Gefieder-Geometrie & PBR.

### B. Nicht-kommerzielle private Prototyp-Charaktere (Private Research / Fan Prototype Only)
Die folgenden 6 Charaktere enthalten Hommagen an bekannte Franchises und sind **ausschließlich für private Testzwecke, Prototyping und Forschungsdemonstrationen** bestimmt. Sie dürfen **nicht** in einem kommerziellen Build ausgeliefert werden:
1. **Son Goku** (Dragon Ball / Akira Toriyama / Bird Studio / Shueisha / Toei Animation)
2. **Sub-Zero** (Mortal Kombat / NetherRealm Studios / Warner Bros. Games)
3. **Pain / Nagato** (Naruto / Masashi Kishimoto / Shueisha / Studio Pierrot)
4. **Monkey D. Ruffy** (One Piece / Eiichiro Oda / Shueisha / Toei Animation)
5. **Sonic the Hedgehog** (Sonic Team / SEGA Corporation)
6. **Akaza / Hakuji** (Demon Slayer: Kimetsu no Yaiba / Koyoharu Gotouge / Shueisha / Ufotable)

*Hinweis für Produktions-Release:* Ein Preprocessor-Flag oder separates Build-Target schließt die `non-commercial`-Charaktere für den kommerziellen App-Store-Build automatisch aus.

---

## 2. 3D-Werkzeuge & Basis-Meshes
- **Blender 4.5.5 LTS**: GNU General Public License (GPL). Zur Modellierung, Rigging und GLTF-Export.
- **Human Base Meshes Bundle (Blender Studio)**: Creative Commons CC0 Public Domain. Alle abgeleiteten Rigs und Basistopologien sind frei modifizierbar.
- **Godot Engine 4.7.2 stable**: MIT License (Copyright (c) 2014-present Godot Engine contributors).

---

## 3. Arenen & Hintergrund-Assets
- **Sky Panoramas** (Blood Moon, Volcano Sanctum, Imperial Colosseum, Pirate Galleon, Gladiator Bastion, Bioluminescent Grove):
  - Erstellt mit generativen Bild-Pipelines oder lizenziert unter CC0 / Public Domain.
- **Arena PBR Texturen** (Bodenstein, Lava, Fackeln, Basalt-Säulen):
  - 100% lokal prozedural erzeugt oder CC0-kompatibel.

---

## 4. Audio & Soundeffekte
- Alle SFX (Schläge, Treffer, Spezialeffekte, Wurf, Detonation):
  - Erstellt mit Synthesizern und CC0 Audio-Bibliotheken (siehe `docs/AUDIO_LICENSES.md`).


## Poly Haven (CC0 1.0) – Arenen

Quelle: https://polyhaven.com – alle Assets CC0 1.0 (gemeinfrei, kommerziell nutzbar, keine Namensnennung nötig).
Heruntergeladen und aufbereitet mit `scripts/fetch_polyhaven_assets.py` nach `godot/assets/polyhaven/`.

- **HDRIs** (2K-HDR für Licht/Reflexion + skaliertes Panorama als Himmel): rogland_moonlit_night, rogland_sunset, colosseum, small_harbour_sunset, teutonic_castle_moat, misty_pines, lago_disola, shanghai_bund
- **Texturen** (2K diffuse / normal / roughness): castle_wall_slates, japanese_stone_wall, volcanic_rock_tiles, dark_rock, marble_01, large_sandstone_blocks, brown_planks_07, dark_planks, large_sandstone_blocks_01, castle_brick_01, mossy_cobblestone, mossy_rock, snow_02, rock_wall_10, metal_plate, concrete_panels
- **3D-Modelle** (glTF, 1K-Texturen): rock_face_01, rock_face_02, namaqualand_cliff_01, boulder_01, rock_moss_set_01, rock_moss_set_02, moon_rock_03, rock_07, dead_tree_trunk_02, quiver_tree_01, fern_02, tree_stump_01, Barrel_01, wooden_barrels_01, wooden_crate_02, treasure_chest, cannon_01, modular_wooden_pier, Lantern_01, wooden_lantern_01, street_lamp_02, stone_fire_pit, gothic_statue, marble_bust_01, horse_statue_01, large_iron_gate, kite_shield, modular_industrial_pipes_01, security_light, ceramic_vase_02, brass_diya_lantern, wine_barrel_01, lion_head

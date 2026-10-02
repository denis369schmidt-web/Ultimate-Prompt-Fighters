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

### B. Eigene Helden (ersetzen die früheren Fan-Prototypen)
Die früheren Fan-Prototypen (Figuren fremder Marken) sind **vollständig entfernt**. Ihre Modelle, Texturen,
Screenshots und Entwickler-Skripte liegen in `_quarantine_ip/` außerhalb des Godot-Projekts; dieser Ordner wird
weder importiert noch exportiert und steht in `.gitignore`. An ihre Stelle treten 16 eigene Figuren:
Kairo, Varakh, Xylar, Glaciem, Oryn, Tobi, Jubei, Ren, Amethya, Bruno, Hikaru, Zip, Raiga, Albion, Pyrax, Lepora.

- **Namen, Movesets, Finisher, Texte:** eigene Erfindungen (`fighter_kits.gd`, `prompt_interpreter.gd`, `signatures.gd`).
- **Aussehen:** komplett im Code erzeugt (`scripts/hero_gear.gd`, `shaders/hero_recolor.gdshader`): Umfärbung
  der Kleidung in eine eigene Palette, prozedurale Ausrüstung (Heiligenschein, Kronen, Umhänge, Runenringe,
  Donnertrommeln, Membranflügel, Hörner, Jets, Gauntlets …), generierte Texturen (Rauschen, Runen, Adern) und Effekte.
- **Körper:** Mixamo-Charaktere (siehe Abschnitt 2), nur als Basis unter der eigenen Ausrüstung.
- **Effekt-Texturen:** `godot/scripts/generate_vfx_assets.py` (PIL, selbst erzeugt).
- Ein Test (`tests/test_roster.gd`) prüft, dass kein sichtbarer Text und keine Figuren-ID fremde Marken enthält
  und fremde Namen im Prompt keine eigenen Helden mehr auswählen.

### C. Eigene Kämpfer statt Tripo-Scans (2026-10-02)
Zehn Kämpfer basierten früher auf öffentlichen Tripo-Community-Modellen anderer Nutzer. Diese Dateien sind entfernt;
die Figuren sind neu und eigenständig aufgebaut wie die eigenen Helden in Abschnitt B:
Brunhild, Thorn Witch, Nyx, Shira, Frostwyrm, Cyborg Mech, Reaper Hound, Treant, Celestial Fox, Mossback.

- **IDs:** `brunhild`, `thorn_witch`, `nyx`, `shira`, `frostwyrm`, `cyborg_mech`, `reaper_hound`, `treant`, `celestial_fox`, `mossback`
  (alte Spielstände werden in `progression.gd` umgeschrieben).
- **Aussehen:** komplett im Code (`scripts/hero_gear.gd`): Flügelhelm und Bartaxt, Dornenkrone und Rankenpeitschen, Seelensense,
  Katzenohren und -schwanz, Eisschwanz, Mech-Panzerung und Schulterkanone, Schädelmaske und Wirbelschwanz, Rindenpanzer und Geweih,
  neun Fuchsschwänze und Fuchsfeuer, Felsrücken und Widderhörner, dazu generierte Texturen (Rinde, Moos, Knochen, Fels).
- **Körper:** Mixamo-Charaktere (Abschnitt 2) als Basis unter der eigenen Ausrüstung.
- **Boss Leviathan:** prozeduraler Seedrache aus `scripts/boss_models.gd` statt des Tripo-Drachen.

### D. Arbër, der Bohrmeister (2026-10-02)
Eigene Figur: Mixamo-Körper (brute_titan, Axt ausgeblendet) mit im Code gebauter Ausrüstung (`hero_gear.gd`):
Qeleshe, bestickte Xhamadan-Weste (prozedurale Textur), Schärpe, Werkzeuggürtel, zwei Akku-Bohrer mit Spiralbohrern und der
schwarze Doppelkopfadler (Shqiponja) als Flugtier. Bohrsound selbst synthetisiert.

---

## 2. 3D-Werkzeuge & Basis-Meshes
- **Blender 4.5.5 LTS**: GNU General Public License (GPL). Zur Modellierung, Rigging und GLTF-Export.
- **Human Base Meshes Bundle (Blender Studio)**: Creative Commons CC0 Public Domain. Alle abgeleiteten Rigs und Basistopologien sind frei modifizierbar.
- **Mixamo (Adobe)**: Charaktere und Animationen aus `godot/assets/models/mixamo/` – laut Adobe-Bedingungen
  lizenzfrei für persönliche, kommerzielle und gemeinnützige Projekte einschließlich Spielen; nicht als
  eigenständige Asset-Dateien weiterverteilen.
- **Tripo-Scans: entfernt (2026-10-02).** Die früheren Community-Modelle von Tripo (fremde Urheber) liegen in
  `_quarantine_ip/tripo/` (gitignored, nicht im Build). Siehe Abschnitt 1C.
- **Schriften** (`godot/assets/fonts/`): Russo One (Jovanny Lemonad) und Teko (The Teko Project Authors), beide
  SIL Open Font License 1.1 (`OFL_russoone.txt`, `OFL_teko.txt`), aus github.com/google/fonts. Logo und Menü des Startbildschirms
  sind damit im Spiel gesetzt (`shaders/title_logo.gdshader`), kein gemaltes Bild.
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

# Kämpfer-Bestandsliste (Stand 2026-09-30)

Erzeugt mit `godot --headless --path godot -s tests/dump_inventory.gd` (liest `main.gd` mk_presets,
`prompt_interpreter.gd`, `signatures.gd`, `combat.gd` finisher_for und lädt jedes Modell).
Nummern = Reihenfolge in `tests/render_roster_numbered.gd` / `roster_nummeriert.png`.
`CHARACTER_MATRIX.md` ist veraltet (13 Kämpfer) und wird durch diese Liste ersetzt.

## Systemweite Schwächen (betreffen alle 49)

| Bereich | Ist-Zustand | Datei |
|---|---|---|
| Bewegung | Sprungkraft (8,5), Schwerkraft (20), Luftdash, Fallgeschwindigkeit **global gleich**. Pro Kämpfer nur Laufgeschwindigkeit + Gewicht. | `combat.gd` `GRAVITY`, `JUMP_FORCE` |
| Moveset | `build_moveset()` rechnet alle 17 Angriffe aus Standard- und Spezialangriff hoch: gleiche Namen („Fußfeger“, „Wuchtschlag“ …), gleiche Hitbox-Formen, gleiche Winkel. Nur Schaden und Reichweite skalieren. | `combat.gd` ~1219 |
| Up-/Down-Special | Für alle gleich: „· Aufwind“ (Sprung-Hieb) und „· Beben“ (Schockwelle). | `combat.gd` |
| Signatur | 14 Mechaniken auf 49 Kämpfer; viele Dubletten (s. u.). Nur Zahlen/Farbe unterscheiden sich. | `signatures.gd` |
| Finisher | 5 Finisher nach Element-Schlüsselwort, keine Varianten pro Kämpfer. Einige Zuordnungen passen nicht. | `combat.gd` `finisher_for` |

**Doppelte Signatur-Mechaniken:** dash ×5 (Jubei, Amethya, Zip, Reaper Hound, Kommandant) ·
eruption ×5 (Magmor, Brunhild, Treant Golem, Warrok, Nekra) · beam ×5 (Templar, Kairo, Albion, Frostwyrm, Cyborg Mech) ·
whirl ×4 (Oryn, Hikaru, Flayer, Kettenwart) · projectile ×16 · teleport ×2 · counter ×2 · rage ×2 · barrage ×2 · mine ×2.

## Bestand

Werte: G = Gewicht, T = Lauftempo, LP = Lebenspunkte, Stats = Vit/Pow/Def/Spd/Tech.
Rig „–“ = Modell ohne Skelett (keine Posen/Animation möglich). Tex = Materialien mit Textur / alle.

| # | ID | Name | Element | G | T | LP | Stats | Standard / Spezial | Signatur | Finisher | Modell | Rig | Tex | Archetyp (Vorschlag) | Schwächen |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | ninja | VOLT NINJA | electric | 0.92 | 4.18 | 118 | 18/18/14/29/21 | Standard Strike / Raijin Dash | teleport | Himmelszorn | ninja_master | Mixamo 65 | 1/1 | Rushdown | generischer Angriffsname; Teleport = Specter |
| 2 | golem | MAGMOR | fire | 1.32 | 2.95 | 133 | 27/23/27/10/13 | Standard Strike / Magma Quake | eruption | Einäschern | pumpkin_abomination | Mixamo 66 | 1/1 | Schwergewicht | Kürbismonster statt Lavagolem; Name generisch; Eruption ×5 |
| 3 | valkyrie | BOLTAR | holy | 1.05 | 3.73 | 115 | 16/24/16/22/22 | Standard Strike / Radiant Pierce | projectile | Eissarg | paladin_armed | Mixamo 69 | 4/4 | Allrounder (Speer) | Holy→Eissarg passt nicht; Name generisch |
| 4 | dragon | TEMPLAR | fire | 1.20 | 3.54 | 125 | 22/24/22/19/13 | Standard Strike / Wyrm Flame | beam | Einäschern | castle_guard | Mixamo 43 | 1/1 | Schwertkämpfer | Name generisch; Rig ohne Finger; Beam ×5 |
| 5 | goku | KAIRO | wind | 1.05 | 3.40 | 123 | 21/26/13/17/23 | Standard Strike / Solar-Kanone | beam | Himmelszorn | gladiator_heraklios | Mixamo 65 | 2/2 | Allrounder | Beam ×5 |
| 6 | vegeta | VARAKH | ki_gold | 1.06 | 3.73 | 120 | 19/27/16/22/16 | Prinzenschlag / Nova-Strahl | projectile | Einäschern | exo_red | Mixamo 112 | 8/8 | Druck + Zoner | Ki→Einäschern fragwürdig |
| 7 | frieza | XYLAR | ki_purple | 1.02 | 3.73 | 125 | 22/26/16/22/14 | Schweifpeitsche / Nadelstrahl | projectile | Leerensog | demon_warlord | Mixamo 79 | 8/8 | Zoner | – |
| 8 | subzero | GLACIEM | ice | 1.05 | 3.92 | 114 | 15/28/17/25/15 | Standard Strike / Eissplitter | projectile | Eissarg | exo_gray | Mixamo 112 | 8/8 | Kontrolle (Einfrieren) | Name generisch |
| 9 | pain | ORYN | gravity | 1.05 | 3.60 | 122 | 20/28/17/20/15 | Standard Strike / Abstoßungswelle | whirl | Leerensog | paladin_nord | Mixamo 67 | 2/2 | Kontrolle (Abstoßen) | Name generisch; Whirl ×4 |
| 10 | luffy | TOBI | rubber | 0.95 | 4.05 | 125 | 22/25/12/27/14 | Standard Strike / Schleuderfaust | barrage | Kopfjäger | brute_titan | Mixamo 72 | 9/10 | Reichweite | Koloss-Körper für flinken Gummikämpfer |
| 11 | zoro | JUBEI | wind_slash | 1.12 | 3.40 | 126 | 23/28/18/17/14 | Dreiklingenhieb / Tigerschnitt | dash | Himmelszorn | elven_archer | Mixamo 70 | 6/6 | Schwertkämpfer | Bogenschützen-Körper; Dash ×5 |
| 12 | naruto | REN | wind_rasen | 0.98 | 3.86 | 126 | 23/25/16/24/12 | Wirbelkombo / Spiralkern | clone | Himmelszorn | kachujin_dragon | Mixamo 75 | 2/2 | Trickser (Klone) | – |
| 13 | sasuke | AMETHYA | electric_chidori | 0.98 | 4.25 | 117 | 17/24/14/30/15 | Donnerschnitt / Tausend Funken | dash | Himmelszorn | assassin_night | Mixamo 68 | 1/1 | Rushdown | Dash ×5 |
| 14 | saitama | BRUNO | serious_force | 1.05 | 3.40 | 123 | 21/34/18/17/10 | Normal Punch / Ernstfall-Schlag | power | Kopfjäger | martial_yaku | Mixamo 65 | 2/2 | Punisher (langsam, tödlich) | – |
| 15 | tanjiro | HIKARU | sun_flame | 1.02 | 3.67 | 120 | 19/29/14/21/17 | Morgenklinge / Morgenrotschnitt | whirl | Einäschern | monk_ganfaul | Mixamo 99 | 1/1 | Schwertkämpfer (Combo) | Whirl ×4 |
| 16 | sonic | ZIP | wind | 0.88 | 4.64 | 120 | 19/20/14/36/11 | Standard Strike / Turbo-Rolle | dash | Himmelszorn | crypto_cyber | Mixamo 65 | 1/1 | Rushdown (Tempo) | Name generisch; Dash ×5 |
| 17 | akaza | RAIGA | blood_demon | 1.02 | 3.73 | 130 | 25/28/13/22/12 | Kompassfaust / Kompassnova | counter | Einäschern | maw_alien | Mixamo 64 | 1/1 | Konter | Counter = Cardinal |
| 18 | blue_eyes | ALBION | holy_light | 1.28 | 3.47 | 126 | 23/29/17/18/13 | Silberklaue / Sturmstrahl | beam | Eissarg | maria_prop | Mixamo 65 | 2/2 | Schwergewicht-Zoner | Drache auf Menschenkörper; Holy→Eissarg |
| 19 | charizard | GRAVOK | fire | 1.15 | 3.54 | 120 | 19/31/17/19/14 | Glutklaue / Glutsturm | projectile | Einäschern | parasite_beast | Mixamo 69 | 2/2 | Luftkämpfer (schwer) | Wyvern ohne Flügel |
| 20 | anubis | AURUM | shadow_gold | 1.08 | 3.60 | 118 | 18/29/18/20/15 | Standard Strike / Anubis Wrath | projectile | Einäschern | cyber_xbot | Mixamo 65 | **0/2** | Grappler (Haken) | **untexturierter X-Bot**; Name generisch |
| 21 | specter | RAVENNA | void | 0.98 | 3.73 | 114 | 15/24/19/22/20 | Standard Strike / Void Lance | teleport | Leerensog | arissa_fighter | Mixamo 73 | 4/4 | Trickser | Name generisch; Teleport = Ninja |
| 22 | phoenix | SCARLET | fire | 0.98 | 3.54 | 118 | 18/25/15/19/23 | Standard Strike / Phoenix Flare | projectile | Einäschern | eve_warrior | Mixamo 65 | 1/1 | Luftkämpfer | Name generisch |
| 23 | golden_golem | BRUNHILD | metal_gold | 1.35 | 3.01 | 131 | 26/27/21/11/15 | Midas Strike / Midas Quake | eruption | Einäschern | golden_golem (Tripo) | **–** | 1/1 | Schwergewicht | **kein Skelett**; Eruption ×5 |
| 24 | tripo_fran_statue | LEPORA | wind_arrow | 0.95 | 3.99 | 117 | 17/24/14/26/19 | Viera Kick / Mist Arrow | projectile | Himmelszorn | Tripo | **–** | 1/1 | Zoner (Bogen) | **kein Skelett** |
| 25 | tripo_fantasy_female | THORN WITCH | nature_thorn | 0.98 | 3.73 | 123 | 21/24/18/22/15 | Bramble Whip / Thorn Burst | mine | Kopfjäger | Tripo | **–** | 1/1 | Fallenstellerin | **kein Skelett**; Mine = Grimbolt |
| 26 | tripo_nyx_harvester | NYX HARVESTER | soul_dark | 1.10 | 3.60 | 123 | 21/29/18/20/12 | Reaper Slash / Soul Reaping | projectile | Leerensog | Tripo | **–** | 1/1 | Zoner (Bumerang-Sense) | **kein Skelett** |
| 27 | tripo_cat_girl | SHIRA | claw_strike | 0.92 | 4.05 | 123 | 21/26/15/27/11 | Feral Scratch / Cat Rush Strike | barrage | Himmelszorn | Tripo | **–** | 1/1 | Rushdown | **kein Skelett**; Barrage = Tobi |
| 28 | tripo_dragon_blue | FROSTWYRM | ice | 1.35 | 3.27 | 131 | 26/29/22/15/8 | Wyrm Tail / Glacial Breath | beam | Eissarg | Tripo | eigen 86 | 1/1 | Schwergewicht-Zoner | Beam ×5 |
| 29 | tripo_white_sci | CYBORG MECH | plasma_pulse | 1.20 | 3.40 | 123 | 21/25/24/17/13 | Mech Strike / Plasma Burst | beam | Himmelszorn | Tripo | **–** | 1/1 | Zoner (Laser) | **kein Skelett**; Beam ×5 |
| 30 | tripo_skeleton_dog | REAPER HOUND | death_bite | 0.90 | 4.05 | 122 | 20/28/12/27/13 | Shadow Bite / Grave Maw | dash | Leerensog | Tripo | eigen 87 | 1/1 | Rushdown (Vierbeiner) | Dash ×5 |
| 31 | tripo_wooden_forest | TREANT GOLEM | wood_root | 1.35 | 2.95 | 134 | 28/24/26/10/12 | Branch Slam / Verdant Root Crush | eruption | Kopfjäger | Tripo | **–** | 1/1 | Schwergewicht | **kein Skelett**; Eruption ×5 |
| 32 | tripo_nine_tailed | CELESTIAL FOX | nine_fire | 1.05 | 3.92 | 122 | 20/29/14/25/12 | Tail Whip / Celestial Foxfire | projectile | Einäschern | Tripo | eigen 75 | 1/1 | Zoner (Zielsuche) | – |
| 33 | tripo_quadruped_tree | MOSSBACK | wood_beast | 1.30 | 3.21 | 130 | 25/27/22/14/12 | Sylvan Charge / Forest Stomp | rage | Kopfjäger | Tripo | eigen 78 | 1/1 | Berserker | Rage = Mutant |
| 34 | steel_knight | CARDINAL | ice | 1.15 | 3.14 | 128 | 24/25/24/13/14 | Ritterschlag / Schildstoß | counter | Eissarg | steel_knight | Mixamo 66 | 3/3 | Verteidiger (Konter) | Ritter → Eis-Element? Counter = Raiga |
| 35 | vanguard_soldier | VANGUARD | plasma | 1.10 | 3.47 | 133 | 27/23/21/18/11 | Vanguard-Hieb / Photonen-Salve | projectile | Himmelszorn | vanguard_soldier | Mixamo 65 | 2/2 | Artillerie-Zoner | „Photonen-Salve“ wirft Granate |
| 36 | sorceress_medea | SORCERESS | dark_magic | 0.90 | 3.47 | 110 | 13/31/10/18/28 | Arkaner Impuls / Astral-Explosion | projectile | Leerensog | sorceress_medea | Mixamo 69 | 2/2 | Zoner (Glaskanone) | – |
| 37 | skeleton_reaper | FLAYER | shadow_bone | 0.90 | 3.79 | 117 | 17/27/14/23/19 | Knochenklinge / Seelenernte | whirl | Leerensog | skeleton_reaper | Mixamo 73 | 2/2 | Grappler (Sog) | Whirl ×4 |
| 38 | mutant_titan | MUTANT | acid | 1.35 | 2.88 | 136 | 29/28/25/9/9 | Mutantenfaust / Gift-Schockwelle | rage | Kopfjäger | mutant_titan | Mixamo 37 | 1/1 | Grappler-Schwergewicht | Rage = Mossback; Rig grob |
| 39 | swat_specops | SWAT AGENT | electric | 1.04 | 3.54 | 125 | 22/22/19/19/18 | Taktischer Schlag / Schock-Granate | projectile | Himmelszorn | swat_specops | Mixamo 69 | 3/3 | Zoner (Feuerstöße) | „Schock-Granate“ feuert Kugeln |
| 40 | samurai_dreyar | KOMMANDANT | ice | 1.05 | 3.60 | 123 | 21/29/18/20/12 | Klingenwirbel / Drachenschneide | dash | Eissarg | samurai_dreyar | Mixamo 67 | 1/1 | Punisher (Iaido) | Wind-Samurai → Eis-Finisher; Dash ×5 |
| 41 | pirate_captain | SERAPHINE | wind | 1.08 | 3.54 | 122 | 20/28/18/19/15 | Entermesser-Hieb / Breitseiten-Schuss | projectile | Himmelszorn | pirate_captain | Mixamo 76 | 1/1 | Mix (Nahschrot) | – |
| 42 | vampire_lord | VLAD | blood_demon | 1.02 | 3.60 | 120 | 19/30/13/20/18 | Blutkrallen / Karmesin-Nebel | projectile | Einäschern | vampire_lord | Mixamo 99 | 2/2 | Trickser (Lebensraub) | Blut→Einäschern fragwürdig |
| 43 | wizard_sorcerer | PYRUS | fire | 0.92 | 3.47 | 114 | 15/30/12/18/25 | Flammenfunke / Meteor-Schauer | meteor | Einäschern | wizard_sorcerer | eigen 67 | 10/10 | Zoner (Flächen) | – |
| 44 | warrok_brute | WARROK | fire | 1.35 | 2.82 | 138 | 30/28/25/8/9 | Magmaschlag / Vulkan-Eruption | eruption | Einäschern | warrok_brute | Mixamo 81 | 1/1 | Schwergewicht | Eruption ×5 |
| 45 | nekra | NEKRA | soul_dark | 0.90 | 3.79 | 120 | 19/26/10/23/22 | Knochenpeitsche / Knochengarten | eruption | Leerensog | zombie_girl | Mixamo 63 | 7/7 | Zonerin (Boden) | Eruption ×5 |
| 46 | grimbolt | GRIMBOLT | fire | 0.85 | 4.18 | 114 | 15/19/16/29/21 | Schraubenschlüssel / Zeitbombe | mine | Einäschern | goblin_warrior | Mixamo 69 | 2/2 | Fallensteller | Mine = Thorn Witch |
| 47 | echo | ECHO | plasma | 0.90 | 4.12 | 114 | 15/23/16/28/18 | Glitch-Hieb / Phasentausch | projectile | Himmelszorn | cyber_ybot | Mixamo 65 | **0/2** | Trickser (Tausch) | **untexturierter Y-Bot** |
| 48 | kettenwart | KETTENWART | ice | 1.35 | 2.88 | 136 | 29/25/24/9/13 | Kettenschwung / Seelenketten | whirl | Eissarg | war_zombie | Mixamo 72 | 1/1 | Grappler | Ketten → Eis-Finisher? Whirl ×4 |
| 49 | don_valente | DON VALENTE | ki_gold | 1.20 | 3.14 | 130 | 25/24/18/13/20 | Goldener Schlagring / Leibwächter-Geschütz | turret | Einäschern | boss_enforcer | Mixamo 68 | 11/11 | Beschwörer | Pate → Einäschern fragwürdig |

Alle 49 Modelldateien sind verschieden (kein Körper doppelt belegt).

## Paketaufteilung (7 × 7)

Stand 2026-09-30: **Paket 0 und Paket 1 erledigt** (siehe `docs/CHANGELOG.md` Schritt 8). Die Tabelle „Bestand“ oben zeigt noch den Zustand vor Paket 1.

Vor Paket 1 steht **Paket 0 (Technik)**: ein Kit-System, damit pro Kämpfer überhaupt eigene Werte möglich sind –
Bewegungswerte pro Kämpfer (Sprunghöhe, Doppelsprung, Schwerkraft, Fallgeschwindigkeit, Luftbeweglichkeit, Reichweite),
Moveset-Overrides pro Angriff (Name, Frames, Hitbox, Winkel, Knockback) mit dem heutigen `build_moveset` als Rückfallebene,
Finisher-Feld pro Kämpfer, Tests dafür. Ohne das lässt sich kein Kämpfer individuell machen.

| Paket | Thema | Kämpfer | Warum zusammen |
|---|---|---|---|
| 1 ✅ | Story-Besetzung | Volt Ninja, Boltar, Magmor, Seraphine, Cardinal, Kommandant, Warrok | Tragen den Storymodus; größte Sichtbarkeit; breite Archetyp-Spanne als Referenz |
| 2 | Ki-Kämpfer & Ninjas | Kairo, Varakh, Xylar, Ren, Amethya, Oryn, Bruno | Ähnliche Vorlagen – müssen sich besonders klar unterscheiden |
| 3 | Klingen & Tempo | Jubei, Hikaru, Tobi, Raiga, Glaciem, Zip, Templar | Nahkampf-Spezialisten; löst Dash-/Whirl-Dubletten |
| 4 | Bestien & Drachen | Albion, Gravok, Frostwyrm, Reaper Hound, Celestial Fox, Mossback, Mutant | Nicht-humanoide Silhouetten, Luft-/Bodenbestien; löst Beam-/Rage-Dubletten |
| 5 | Tripo ohne Skelett | Brunhild, Lepora, Thorn Witch, Nyx Harvester, Shira, Cyborg Mech, Treant Golem | Brauchen zuerst ein Rig (Blender-Auto-Rig oder Mixamo-Ersatzkörper) |
| 6 | Magie & Untote | Sorceress, Pyrus, Vlad, Flayer, Ravenna, Aurum, Scarlet | Zoner-/Trickser-Gruppe; Aurum braucht Textur |
| 7 | Originale & Technik | Nekra, Grimbolt, Echo, Kettenwart, Don Valente, SWAT Agent, Vanguard | Eigene Figuren + Schusswaffen; Echo braucht Textur |

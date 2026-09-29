# Changelog

Format: neueste Einträge oben. Jeder Schritt nennt Spieler-Wirkung und technischen Grund.

## [Unreleased]

### Schritt 7 – Profi-Assets und AAA-Beleuchtung (2026-09-29)

- **Poly Haven (CC0):** 8 HDRIs, 16 gescannte 2K-PBR-Materialsätze und 33 professionelle 3D-Modelle (`scripts/fetch_polyhaven_assets.py`, Lizenzen in `ASSET_LICENSES.md`).
- **Bildbasierte Beleuchtung:** Jede Arena wird von einem echten HDR beleuchtet (Umgebungslicht + Reflexionen, auch auf den Kämpfern); sichtbarer Himmel ist eine 6K-Fotokuppel mit Drehung, Tönung und Horizonthöhe pro Arena.
- **Arenen neu bestückt:** Bühnen mit Scan-Texturen (Schiefer, Vulkanfliesen, Marmor, Planken, Sandstein, Moos-Pflaster, Schnee, Riffelblech), Felsinseln aus gescannten Felsen, Kulissen aus Profi-Modellen (Kanonen, Fässer, Truhe, Steg, Eisentor, Schilde, Statuen, Büsten, Amphoren, Laternen, Feuerschalen mit Flammen, Köcherbäume, Moosfelsen, Farne, Straßenlaternen, Industrierohre). Echte Hintergründe: Kolosseum Rom, Hafen, Burg, Nebelwald, Alpen, Shanghai-Skyline.
- Blood Moon auf Mondnacht-HDRI mit Rottönung; Neon: Nachbar-Dachkante verdeckt die Straßenebene des Fotos.
- Performance: Ø 58,1 FPS im Rauchtest (Intel UHD); Import-LODs, keine Schatten von Fernkulissen.

Tests: 314/314.

### Schritt 6 – Kampfausbau, Finisher, Arenen, Waffen (2026-09-29)

**Kampf** (`combat.gd`): eigene Schildtaste (Q / I / LB) mit Schildenergie und Schildbruch, Rolle, Ausweichschritt, Luftausweichen und Flux-Dash, Kanten greifen (Klettern, Sprung, Angriff, Rolle, Loslassen; Anti-Planking, Kanten-Verdrängung), volles Moveset (Jab, 3 Tilts, 3 aufladbare Smashes, Dash-Angriff, 5 Luftangriffe inkl. Meteor-Dair, 3 Richtungs-Specials), Hitbox-Boxen pro Angriff, DI, Short Hop, Fast Fall, Landelag, Beschleunigung/Abbremsen am Boden. Specials brauchen kein Meter mehr.

**KI-Stufen 1–9** (Reaktionszeit, Schild, Rolle, Recovery, Kantenoptionen, Kill-Smashes). KI-Gedächtnis liegt außerhalb des Spielzustands (Replays bleiben exakt).

**Finisher** („MACH IHN FERTIG!“): Der letzte K.O. lässt den Verlierer benommen; 5 s für die Element-Tastenfolge (Einäschern, Eissarg, Himmelszorn, Leerensog, Kopfjäger). Option BLUTIG / OHNE BLUT / AUS. Blutig: Verkohlen, Zersplittern, Explodieren, Gliedmaßen abreißen, Enthauptung mit Blutfontäne, Blutlachen, Bildschirm-Blut; Blut auch bei harten Treffern.

**Eingabe:** Gamepads für bis zu 4 Spieler, Start = Pause; Optionen KI-Stufe, Stocks (1–5), Finisher im Menü.

**Arenen** (`arena_builder.gd`): alle Arenen neu im Code gebaut – schwebende Inseln/Sockel/Pier/Hochhaus, 8 neue PBR-Materialsätze (`scripts/generate_arena_textures.py`), Shader für Wasser, Lava und Hochhausfenster, Themenkulissen (Torii und Ahornbäume, Basaltsäulen im Lavasee, Kolosseum mit Publikum, Galeone und Leuchtturm, Festung mit Fallgitter, leuchtender Wald, …), Wetterpartikel, Akzentlichter. **Neu: FROZEN SUMMIT und NEON METROPOLIS.** Belichtung pro Arena.

**Waffen:** 5 Schwerter (HELDENKLINGE, RIESENBRECHER, PLASMASÄBEL, SEELENFROST, MONDSICHEL) und LASERBLASTER, STURMBUMERANG, KETTENMORGENSTERN. Spawnen zufällig, Aufheben mit Greifen, in der Hand geführt, Spezial = Waffenfähigkeit (Projektile, Frostnova, Beben), zerbrechen nach Einsätzen, werfbar. Projektilsystem im Kampfkern. Fix: zufällig gespawnte Items waren unsichtbar.

**Darstellung/Spaß/Performance:** Squash & Stretch, Vorlehnen beim Laufen, neue Posen (Ducken, Aufladen, Ausweichen, Kante, benommen), Combo-Anzeige, „ERSTES BLUT!“, „LETZTER STOCK!“, Einschlag-Blitz; SSAO aus; F3 zeigt FPS. Rauchtest: Ø 58,6 FPS auf Intel UHD.

Tests: 314/314 (game 42, mechanics 36, roster 133, story 41, combat_plus 62).

### Schritt 5 – Storymodus, Animation, Charaktere, Grafik (2026-09-29)

**Storymodus „Die letzte Zeile“** (`story_data.gd` Inhalt, `story_mode.gd` Player)
- 8 Kapitel mit eigener Handlung und eigenen Figuren (Volt, Aura, Korsar, Sir Kalden, Cinder Bastion, Dreyar, Warrok, Schatten-Volt, NULLA/NOVA).
- Cutscenes in der Spielgrafik: Kamerafahrten (Totale, Nah, Untersicht, Zweier), Letterbox, Titelkarten, Erzähltext, Dialogbox mit Porträt und Schreibmaschinentext, Posen, Laufwege, Tinte-/Blitz-/Beben-Effekte. ENTER weiter, ESC überspringt bis zum Kampf.
- Quicktime-Events: Drücken, Hämmern, Sequenz – mit Zeitring. Erfolg: Gegner starten mit 25 %; Misserfolg: Spieler startet mit 20 %.
- Storykämpfe auf der echten Simulation, inkl. 2-gegen-2 mit Verbündetem, Boss-Modifikatoren, Niederlage mit Wiederholen/Aufgeben, Speicherstand (`user://story.cfg`), Kapitelmenü, Abspann.
- Kampfkern: Teams (`set_teams`, keine Treffer im eigenen Team, letztes Team gewinnt), `power_mult`/`kb_taken_mult`.

**Animation:** Rig-unabhängiges Posen-System – Posen sind Gliedmaßen-Richtungen im Körperraum, jeder Knochen wird darauf ausgerichtet. Keine T-Posen mehr; Kampfhaltung, Laufzyklus, Sprung, Fall, Schlag, Spezial, Block, Treffer, Sieg, Niederlage, Tragen. Die Simulation setzt jetzt Move/Jump/Fall/Block/Carrying.

**Charaktere:** 18 Kämpfer mit klobigen Primitiv-Modellen oder doppelt genutzten Körpern bekommen eigene, texturierte Mixamo-Körper (`MIXAMO_BODIES`). Fix: Ninja/Golem/Valkyrie/Drache wurden schwarz gerendert (Texturen verworfen); ORM- und untexturierte Materialien werden korrekt übernommen; Größennormierung über den Kopfknochen. Porträts aus den echten 3D-Modellen gerendert (`assets/textures/characters/portraits/`, Werkzeug `tests/render_portraits.gd`).

**Grafik:** Neue prozedurale Himmel für alle 6 Arenen (`scripts/generate_arena_skies.py`), AgX-Tonemapping statt überstrahltem ACES, dezenter Glow, leichter Tiefendunst. Treffer-Funken als Partikel, Schockwellenringe, KO-Lichtsäule mit Bildblitz und Zeitlupe, großes „3 – 2 – 1 – GO!“ und „GAME!“.

Tests: 252/252 (game 42, mechanics 36, roster 133, story 41 neu). Visuelle Prüfung über `tests/render_*.gd`.

### Schritt 4 – Sichtbarkeit, Spielerpfeile, Luft-Dash (2026-09-29)

- **Kämpfer immer komplett im Bild:** Die Kamera rahmt Füße bis Kopf aller Kämpfer, berechnet den Abstand aus Sichtfeld und Bildformat, lässt die HUD-Leisten frei und zoomt beim Wegschleudern sofort heraus (vorher: Mittelpunkt ×0,72 versetzt, Zoom auf 14,8 begrenzt → Figuren liefen aus dem Bild).
- **Spielerpfeile:** „P1 ▼“ … „P4 ▼“ in Spielerfarbe über jedem Kämpfer, KI-Kämpfer mit „KI“-Zusatz. Immer sichtbar, gleiche Bildschirmgröße bei jedem Zoom, blinkt während der Respawn-Unverwundbarkeit.
- **Luft-Dash für alle Kämpfer:** Spezialtaste in der Luft = schneller Dash (gehaltene Richtung, sonst zur Bühnenmitte, wenn außerhalb; mit gehaltenem Block nach unten). Einmal pro Flugphase, aufgeladen bei Landung, Respawn und Treffer. Die KI nutzt ihn zur Rückkehr.
- **Determinismus:** Item-Spawns und KI nutzen eigene, aus den Prompts geseedete Zufallsgeneratoren statt des globalen Zufalls.
- **Fix:** Valkyrie-Karte wählte wegen „Paladin“ den Stahlritter.

Tests: 211/211 (game 42, mechanics 36 inkl. 5 neuer Dash-Tests, roster 133). Gerenderter Smoke-Lauf ohne Fehler.

### Schritt 3 – Flüssigkeit (2026-09-28)

- **Physics Interpolation aktiviert** (`project.godot`). Die Simulation bleibt bei festen 60 Ticks/s; Godot interpoliert die Darstellung, damit 120/144-Hz-Monitore flüssig aussehen. Die Kamera (bewegt in `_process`) ist davon ausgenommen und folgt den **interpolierten** Kämpferpositionen. Respawns und Neuaufbau setzen die Interpolation zurück (kein sichtbares „Durchfliegen" beim Teleport).
- **Kamera ignoriert ausgeschiedene Kämpfer.** Bisher blieb die Kamera im 4-Spieler-Modus auf ausgeschiedene Kämpfer an der Blast Zone gezoomt.
- **Hover über Auswahl-Karten wählt nicht mehr aus.** Hover änderte bisher Spieler 1 und lud alle Modelle neu (größter Menü-Ruckler). Jetzt zeigt Hover nur Infos, der Klick wählt.
- **Ansichten werden wiederverwendet:** `rebuild_fighters()` baut nur Kämpfer neu, deren Profil sich geändert hat.
- **Modell-Cache (LRU, 8 Modelle)** in `FighterView.load_model_scene()`: Zurückwechseln lädt keine großen GLBs mehr von der Platte.
- **HUD:** Porträts werden einmal pro Kämpfer-Familie aufgelöst statt jedes Frame per `load()`. Keine Theme-Overrides mehr pro Frame.
- **Fix:** Nach Nutzung der Fusionskammer ließ sich Spieler 1 nicht mehr umwählen. Fusions-Karten tragen jetzt ihr eigenes Profil.

Tests: 73/73. Gerenderter Smoke-Lauf ohne Fehler/Warnungen.

### Schritt 2 – Bugfixes aus dem Audit (2026-09-28)

| Bug | Spieler-Wirkung | Technik |
|---|---|---|
| Angriffe trafen **hinter** dem Angreifer | Nur noch Treffer, die man kommen sieht | `in_attack_reach()`: Hitbox nur vor dem Angreifer (+0,35 Toleranz für Körperüberlappung). Rundum-Specials (`radial`, `shockwave`, `ground_quake` …) treffen weiter beidseitig und stoßen **vom Angreifer weg** |
| Unverwundbare fielen **endlos** | Stern-Item macht nicht mehr „unsterblich im Abgrund" | Blast Zones gelten immer |
| Statusmeldungen **unsichtbar** | „Gegriffen!", „Power-up!" usw. bleiben 1,6 s lesbar | `show_status()` + Timer. `update_hud()` überschreibt nur noch ohne aktive Meldung |
| Zwangsdrehung zum Gegner, auch mitten im Angriff | Wegdrehen möglich, Angriffe drehen nicht mehr mit | Auf dem Boden bestimmt die gedrückte Richtung die Blickrichtung. Ohne Eingabe dreht der Kämpfer zum Gegner, im Angriff nie |
| Input-Puffer nur **1 Frame** | Eingaben während Hitstop/Erholung gehen nicht mehr verloren | Puffer 5 Frames (`INPUT_BUFFER_FRAMES`), wird verbraucht, sobald das passende Sim-Event kommt (`consume_input_buffer`) → kein Doppelauslösen |
| **Durchfallen (S+W) per Tastatur unmöglich** (zusätzlich gefunden) | Plattform-Drop funktioniert | „Springen" wurde bei gehaltenem Block verworfen |

Tests: 73/73 bestanden (neu: Hitbox-Richtung, Rundum-Specials, Blast Zone bei Unverwundbarkeit, Blickrichtung, Puffer-Lebensdauer, Puffer-Verbrauch, Block+Sprung). Smoke-Start des Spiels ohne Fehler.

### Schritt 1 – Tests als Sicherheitsnetz (2026-09-28)

**Tests**
- Neue Test-Basis `godot/tests/test_base.gd`: `check()` statt `assert()`. Ein fehlgeschlagenes `assert()` hielt Godot im Headless-Modus endlos im Debugger an.
- `tests/test_game.gd` auf die aktuellen Regeln (Prozent und Stocks) umgestellt, mehrere neue Regeltests.
- Neue Suite `tests/test_mechanics.gd` (Plattformen, Ring-out, Knockback-Skalierung, Gewicht, Greifen/Werfen, Items, Explosiv-Fass). Ersetzt die hängenden Skripte `scripts/test_smash_mechanics.gd`, `test_grab_and_items.gd` und `test_explosive_barrel.gd` (entfernt).
- `scripts/Test-Project.ps1`: führt alle Suites mit Zeitlimit pro Suite aus, meldet Hänger als Fehler, findet Godot automatisch.
- Ergebnis: **61/61 Tests bestanden** (vorher 27/36, zwei Suites hingen).

**Fixes in `combat.gd`, von den Tests aufgedeckt**
- *Neustart:* `restart()` übergab die Stockzahl an den Modus-Parameter und übernahm die **verbleibenden** Stocks von Spieler 1. Eine Revanche startet jetzt immer mit der eingestellten Stockzahl (`initial_lives`).
- *Zeitablauf:* Bei gleichen Stocks und gleichem Prozentwert gewann bisher automatisch Spieler 1. Jetzt ist es ein **Unentschieden**.
- *Kantenstopp:* Beim Gehen am Rand der Hauptbühne bleibt man stehen, statt versehentlich hinunterzulaufen. Die unsichtbare Wand in der Luft ist entfernt, damit Recovery und bewusstes Abspringen funktionieren.
- *Körperabstand:* Kämpfer auf dem Boden werden sanft auseinandergeschoben (`resolve_body_push`, deterministische Reihenfolge), statt durcheinander zu laufen.
- Neue Konstanten: `MATCH_TIME`, `BODY_SEPARATION`, `BODY_PUSH_RATE`.

# Audit: Prompt Fighter Ultimate

> Stand: 2026-09-28 · Phase 1 (Analyse, keine Codeänderungen am Spiel)
> Grundlage: `godot/project.godot`, `main.tscn`, `scripts/combat.gd`, `scripts/fighter_view.gd`,
> `scripts/main.gd`, `scripts/prompt_interpreter.gd`, Testläufe und ein Roster-Scan (`godot/tests/scan_roster.gd`).

## 1. Technischer Steckbrief

| Punkt | Befund |
|---|---|
| Engine | Godot **4.7.2** stable, GDScript |
| Dimension | **3D** (2,5D-Platform-Fighter, Bewegung auf der X/Y-Ebene) |
| Renderer | `forward_plus` (auch für Mobile!). Die Doku behauptet „Compatibility/OpenGL" – das stimmt nicht |
| Autoloads | keine |
| Input Map | leer in `project.godot`; wird zur Laufzeit in `main.gd:setup_inputs()` erzeugt. Nur **Tastatur**, 2 Spieler, kein Gamepad, kein Rebinding |
| Physik | 60 Ticks/s, **Physics Interpolation aus**. Keine Godot-Physik – eigene Kinematik in `combat.gd` |
| Szenen | Genau **eine** Szene (`main.tscn` = Node3D + `main.gd`). Alles andere (UI, Arena, Kämpfer, Items) wird per Code gebaut |
| Kampflogik | `combat.gd` (RefCounted, reine Daten in Dictionaries) – von der Darstellung getrennt |
| Darstellung | `fighter_view.gd` (Node3D pro Kämpfer, lädt GLB, baut Materialien) |
| Größe der Kernskripte | `main.gd` ~1 980 Zeilen, `fighter_view.gd` ~2 210, `combat.gd` ~1 150 |

## 2. Was bereits gut funktioniert

- **Simulation und Rendering sind getrennt.** `combat.gd` ist ein reines Datenobjekt mit einem zentralen `tick()`, das alle Kämpfer in fester Reihenfolge rechnet. Das ist genau die richtige Grundlage für Determinismus, Replays und Rollback – und selten in Hobbyprojekten.
- **Match-State ist serialisierbar.** Alles liegt in Dictionaries/Arrays → `save_state()`/`load_state()` ist mit `duplicate(true)` fast geschenkt.
- **Hitstop pro Kämpfer in Frames** (nicht über `Engine.time_scale`) – bereits richtig gelöst.
- **Prozent-Schadenssystem, Stocks, Blast Zones**, Plattformen mit Durchfallen, Doppelsprung.
- **3-Phasen-Angriffe** (Windup → Active → Recovery) mit Daten pro Angriff.
- Parry, Greifen/Werfen, Items (inkl. Explosionen), 2–4 Spieler, KI-Gegner, 6 Arenen.
- Die Simulation ist billig: **62 µs/Tick** im Schnitt (0,37 % des Frame-Budgets).
- Das Prompt-System (Kämpfer aus Text erzeugen) ist ein **echtes Alleinstellungsmerkmal**.

## 3. Kritische Probleme

### 3.1 Rechtlich (blockiert jeden Store-Release) — höchste Priorität

- **Geschützte Figuren von Rechteinhabern im Roster:** Goku, Vegeta, Frieza (Dragon Ball), Naruto, Sasuke, Pain (Naruto), Luffy, Zoro (One Piece), Tanjiro, Akaza (Demon Slayer), Saitama (One Punch Man), Sonic (SEGA), Glurak/Charizard (Pokémon), Blue-Eyes White Dragon (Yu-Gi-Oh!), Sub-Zero (Mortal Kombat).
- Betroffen sind nicht nur die Namen, sondern auch die **Attackennamen** (Kamehameha, Rasengan, Chidori, Gum-Gum, Final Flash …), **Modelle, Texturen, Porträts** und die Prompt-Schlüsselwörter.
- **UI-Texte und Kommentare** verweisen auf „Super Smash Bros" und „Mortal Kombat" (z. B. „MORTAL KOMBAT GRID", „SMASH RING-OUT"). In einem Produkt nicht zulässig.
- **Tripo-Modelle:** Die Lizenz hängt vom Tripo-Tarif ab, mit dem sie erzeugt wurden. Kostenlose Pläne erlauben teils keine oder nur eingeschränkte kommerzielle Nutzung. **Muss vor Release geklärt werden.**
- Mixamo-Modelle: Einbau in ein Spiel ist erlaubt; die rohen Dateien dürfen aber nicht separat weitergegeben werden. Unkritisch.
- **Hinweis zum Umbenennen:** Klangähnliche Namen („Gokuu") reichen nicht. Marken- und Urheberrecht schützen auch Aussehen und Wiedererkennbarkeit. Nötig sind eigenständige Namen **und** eigenständige Designs (Frisur, Farben, Outfit, Signature-Moves). Vorschlag siehe Abschnitt 7.

### 3.2 Tests (kein Sicherheitsnetz)

- `tests/test_game.gd`: **27 bestanden, 9 fehlgeschlagen**. Unter anderem „Sieg/Niederlage", „Neustart setzt Zustand zurück", „Unentschieden bei Doppel-KO", „Arena-Grenzen", „Kämpfer laufen nicht durcheinander hindurch".
- `test_smash_mechanics.gd` und `test_grab_and_items.gd` **hängen endlos**. Sie nutzen veraltete Bühnenmaße, ein `assert` schlägt fehl, und Godot wartet im Headless-Modus dann auf den Debugger.
- `docs/STATUS.md` meldet „alle bestanden" – das ist veraltet.

### 3.3 Determinismus (Voraussetzung für Replays und Rollback)

- `tick(commands, delta)` rechnet in **Sekunden-Floats** mit dem übergebenen `delta` statt in Frames.
- **Globaler Zufall** (`randf()`, `randi()`) in KI-Entscheidungen und beim Item-Spawn → gleiche Eingaben liefern nicht denselben Ablauf.
- Die Gameplay-Werte (Cooldowns, Stun, Timer) sind Sekunden statt Frames. Frame-Daten sind so schwer lesbar und balancierbar.

### 3.4 Flüssigkeit und Performance

- **Tripo-Modelle sind 15–78 MB groß, ohne Skelett. Laden: 2–7 s pro Kämpfer, synchron** → das Spiel friert ein.
- **Hover über eine Auswahl-Karte lädt alle Kämpfer komplett neu** (`_on_card_hovered → refresh_previews → rebuild_fighters`). Das ist der Hauptgrund für Ruckler im Menü.
- Kämpfer-Darstellung wird in `_physics_process` (60 Hz) aktualisiert, **ohne Interpolation** → auf 120/144-Hz-Monitoren ruckelig.
- `update_hud()` ruft pro Frame `ResourceLoader.exists()` und `load()` für Porträts auf und setzt Theme-Overrides jedes Frame neu.
- Pro Kämpfer entstehen **neue Materialien für jede Oberfläche**, zusätzlich Outline-`next_pass` (verdoppelt Draw Calls). SSAO, Glow und schattenwerfende Omni-Lichter auf Intel UHD.
- **Export-Filter „all_resources"**: Jeder Build enthält alle ~70 GLB-Modelle (> 1 GB), auch ungenutzte, dazu ~60 Test-Screenshots aus dem `godot/`-Ordner.

### 3.5 Animation

- **~30 von 44 Kämpfern haben keinerlei Animationsclips** (Mixamo-Rigs ohne Clips, Tripo ohne Skelett).
- Ersatzweise werden Knochen per Code verdreht (`update_procedural_skeleton`). Die Rotation wird im lokalen Knochenraum angewendet, der sich je Rig unterscheidet → **Arme und Beine zeigen je Modell in falsche Richtungen**.
- Die Simulation setzt **nie** die Posen „Move", „Jump" oder „Fall" → Figuren gleiten im Idle-Pose über die Bühne.
- Angriffs-Animation ist nicht an die Active-Frames gekoppelt (in der Recovery springt die Pose auf „Idle").

### 3.6 Gefundene Bugs (Gameplay)

1. **Angriffe treffen auch hinter dem Angreifer.** Die Treffer-Prüfung nutzt `abs(dx) <= range` statt einer Hitbox vor dem Kämpfer.
2. **Unverwundbare Kämpfer (Stern-Item) fallen endlos.** Der Blast-Zone-Check wird bei `invulnerable > 0` übersprungen, sie stürzen unbegrenzt weiter.
3. **Statusmeldungen sind unsichtbar.** Ereignistexte („X HAT Y GEGRIFFEN!") werden im selben Frame von `update_hud()` überschrieben.
4. **Blickrichtung wird beim Angreifen zwangsweise zum Gegner gedreht** → keine Rückwärts-Angriffe möglich, und Wegdrehen ist unmöglich.
5. Input-Buffer wird jeden Tick gelöscht → **effektiv 1 Frame Puffer**. Eingaben während Hitstop oder Recovery gehen verloren.
6. HP und Prozent laufen parallel (`hp` wird nach Respawn auf 100 gesetzt, obwohl `max_hp` abweicht) – zwei konkurrierende Schadensmodelle.
7. „DI" steht in der Doku, ist aber **nicht implementiert** (es gibt nur eine Luftsteuerungssperre).
8. In „Spieler vs. Spieler" mit 4 Kämpfern sind Spieler 3 und 4 immer KI. Es fehlt Gamepad-Support.
9. Fokusverlust pausiert nur den PvP-Modus, nicht den Solo-Modus gegen die KI.
10. Roster-Doppelungen durch Schlüsselwort-Kollisionen: „Reaper Hound" wird zum Ninja, „Skeleton Reaper" zu Nyx, „Sorceress Medea" zur Dornenhexe, „Sylvan Beast" zum Treant.

### 3.7 Architektur

- `main.gd` ist ein **God-Object** (Welt, UI, Input, Events, Kamera, Fusionskammer-Modal, Smoke-Tests).
- `fighter_view.gd` enthält ~900 Zeilen `if family == …`-Materialketten → jeder neue Kämpfer bedeutet Code-Änderung.
- `combat.gd:tick()` ist eine lange If-Else-Kette ohne echte State-Klassen.
- Moveset: **nur 2 Angriffe pro Kämpfer** (Standard + Spezial), alle aus dem Prompt abgeleitet. Keine Richtungsangriffe, keine Luftangriffe, keine Smash-Attacken.

## 4. Game-Feel-Schwächen (verglichen mit dem Genre-Standard)

| Bereich | Heute | Genre-Standard |
|---|---|---|
| Bewegung | Laufen, 1 Sprunghöhe, Doppelsprung | Walk/Dash/Run, Short Hop/Full Hop, Fast-Fall, Coyote Time, Air Dodge, Wavedash-artige Technik |
| Verteidigung | Block ohne Haltbarkeit, Parry | Schild mit Energie + Shield Break, Spot Dodge, Rolle, Air Dodge, Tech |
| Angriffe | 2 Moves, Hitbox = Abstandsprüfung | 15–20 Moves (Jab, Tilts, Smashes, Aerials, 4 Specials), Hitbox-Formen mit Prioritäten |
| Knockback | Impuls-Formel, Hitstun fest | Formel aus Prozent/Gewicht/Base/Growth, Hitstun aus Knockback, DI, Tumble/Helpless |
| Bühne | Plattformen, keine Kanten | Ledge Grab mit Anti-Planking |
| Treffer-Feedback | Sprite-Funken, Kameraruckeln per Zufall | Richtungsgebundener Shake, KO-Blast, Zoom/Zeitlupe beim letzten KO, gelayerte Sounds |
| Lesbarkeit | Pose passt nicht zum Timing | Klare Windup/Active/Recovery-Signale, Hitbox-Debug |
| Audio | 7 WAV-Dateien, keine Musik | Treffer-Layer nach Stärke, Ansager, Musik |
| Präsentation | Countdown nur als Statustext | „3-2-1-GO!", „GAME!", Ergebnisbildschirm mit Auszeichnungen |

## 5. Priorisierte Roadmap

### P0 – Fundament (vor allen neuen Features)
1. **Tests reparieren**, Zeitlimit statt Hängen; Determinismus-Test hinzufügen.
2. **Rechtliche Bereinigung:** Umbenennung (Namen, Moves, UI-Texte), Store-Build-Filter für Fan-Inhalte.
3. **Frame-basierter Tick:** `tick()` ohne `delta`, alle Zeiten in Frames, **geseedeter RNG** im Match-State.
4. **Flüssige Darstellung:** Physics Interpolation aktivieren bzw. Render-Interpolation, Kämpfer-Update in `_process`.
5. **Ladezeiten:** Tripo-Modelle in Blender reduzieren, asynchrones Laden, Modell-Cache, kein Neuaufbau beim Hover, Export-Filter säubern.
6. **Input-System:** Input-Struktur pro Frame, 4–5-Frame-Buffer, Gamepad (Device-ID pro Spieler), Deadzones, Rebinding.

### P1 – Kern-Kampfsystem
7. **State Machine** mit State-Klassen (`enter`/`tick`/`exit`).
8. **Custom Resources:** `MoveData`/`CharacterData` (`.tres`), vom Prompt-System befüllt.
9. **Hitbox/Hurtbox** frame-genau aus MoveData, eigene Überlappungsprüfung im Tick (keine Area3D-Signale → rollback-tauglich), Debug-Overlay per Taste.
10. **Moveset:** Jab, 3 Tilts, 3 Smashes (aufladbar), 5 Aerials, 4 Specials, Griff und Würfe.
11. **Knockback-Formel** aus Prozent/Gewicht/Base/Growth, Hitstun aus Knockback, **DI**, Tech, Tumble, Helpless.
12. **Bewegung:** Dash/Run, Short/Full Hop, Fast-Fall, Coyote Time, Air Dodge. **Verteidigung:** Schild mit Energie, Rolle, Spot Dodge.
13. **Ledges** mit Anti-Planking (begrenzte Ledge-Grabs pro Flugphase, Intangibility-Abbau).

### P2 – Animation
14. **Rig-unabhängiges Posen-System:** Posen als Gliedmaßen-Richtungen im Charakterraum statt als Knochen-Rotationen. Damit sieht jede Pose auf jedem humanoiden Rig gleich aus. Alle Bewegungen werden an die Move-Frames gekoppelt, dazu Squash & Stretch.
15. Nicht-humanoide oder unrigged Modelle: in Blender riggen, sonst Ganzkörper-Animation.

### P3 – Game Feel und FX
16. Hitstop nach Schaden skaliert (bereits vorhanden, feinjustieren), richtungsgebundener Screen Shake, Partikel-Pool, KO-Blast, Zeitlupe und Zoom beim entscheidenden KO, gelayerte Hit-Sounds, Musik.
17. Dynamische Kamera mit Blast-Zone-Indikatoren (Pfeil + Abstand, wenn ein Kämpfer außerhalb des Bildes ist).

### P4 – Features, die dem Vorbild fehlen
18. **Rollback-Vorbereitung:** `save_state()`/`load_state()` für den gesamten Match-State.
19. **Trainingsmodus:** Frame-Daten, Hitbox-Overlay, Zeitlupe, Frame-Advance, Save/Load-State.
20. **Replays** über Input-Aufzeichnung.
21. **Tutorial**, das jede Mechanik interaktiv abfragt.
22. **Balancing-Werkzeuge** (alle Werte in `.tres`, Patch-Changelog), Progression (XP, Erfolge) für Casual-Spieler.

## 6. Bewertungen, die du vor der Umsetzung kennen solltest

### Physics Interpolation vs. eigene Render-Interpolation
Godot 4.3+ interpoliert automatisch Node3D-Transformationen, die in `_physics_process` gesetzt werden (`physics/common/physics_interpolation = true`). Das passt zu unserem Aufbau und kostet fast nichts. Einschränkung: Teleports (Respawn) brauchen `reset_physics_interpolation()`, sonst „fliegt" die Figur sichtbar über die Bühne. **Empfehlung: Godot-Interpolation nutzen.**

### Fixed-Point vs. Float für Rollback
- **Float (double in GDScript) behalten:** gleiche Binary auf gleicher Plattform liefert deterministische Ergebnisse. Das genügt für Replays, Trainings-Save-States und Online-Rollback zwischen Windows-PCs.
- **Fixed-Point/Integer:** nötig nur für garantiertes Crossplay zwischen Architekturen (x86 ↔ ARM/Android/Konsole). Kostet Lesbarkeit und macht alle Formeln umständlicher.
- **Empfehlung:** Jetzt Float, aber in **Frames** zählen, Positionen beim Speichern auf feste Nachkommastellen quantisieren und einen Checksum-Test pro Frame einbauen. Fixed-Point erst, wenn Crossplay konkret geplant ist.

### Rollback-Addons
Bekannt sind **netfox** (Godot 4, mit Rollback-Modul) und **Godot Rollback Netcode** (snopek.games, Godot-4-Port). Beide sind auf Godots Node-/Physik-Modell ausgelegt. Unsere Simulation ist ein eigenes Datenobjekt mit einem zentralen Tick. Deshalb ist ein **schlankes eigenes Rollback** (Input-Queue + `save_state`/`load_state` + Resimulation) wahrscheinlich einfacher und sauberer. Die Kompatibilität beider Addons mit Godot 4.7 habe ich **noch nicht geprüft**. Das mache ich, bevor ich eines vorschlage.

### Area3D vs. eigene Überlappungsprüfung
Area3D-Signale feuern erst im nächsten Physik-Frame und sind nicht Teil unseres Match-States. Beim Rollback wären sie nicht zurücksetzbar. **Empfehlung: eigene Kapsel/Box-Prüfung im Tick** (bei 4 Kämpfern × wenigen Hitboxen trivial günstig).

### Projektstruktur
Die Zielstruktur (`core/`, `fighters/`, `data/`, `ui/`, `fx/`) ist sinnvoll. Ein Umzug verschiebt aber viele Dateien, und Godot muss die Referenzen (UIDs) mitziehen. **Vorschlag:** Neue Systeme direkt in der Zielstruktur anlegen und alte Skripte erst verschieben, wenn sie ersetzt werden. Kein Big-Bang-Umzug.

## 7. Originelle Kernmechanik (Vorschlag)

### „Prompt Surge" – dein Prompt ist deine Superkraft im Match
- Jeder Kämpfer hat eine **Surge-Leiste**. Sie füllt sich durch saubere Treffer, Parrys und riskante Aktionen (Angriffe in Gegnernähe), **nicht** durch eingesteckten Schaden. Das belohnt aktives Spiel statt Camping.
- Voll aufgeladen startet der Spieler einen **5-Sekunden-Surge**. Dessen Effekt kommt aus dem **Element des eigenen Prompts**:
  - Feuer: Treffer hinterlassen Brand (Zusatzprozent)
  - Eis: Gegner in der Nähe sind leicht verlangsamt
  - Blitz: Dash-Abbruch in jeden Angriff
  - Wind: dritter Luftsprung
  - Schatten: kurze Unsichtbarkeit beim Ausweichen
- **Konterplay:** Ein Parry während des gegnerischen Surge **klaut die halbe Leiste**. Surge ist sichtbar (Aura und Sound), also lesbar und fair.
- **Warum das Spieler begeistert:** Casual-Spieler erleben „mein Text wird zur Kraft". Competitive-Spieler bekommen eine Ressource mit Timing-Entscheidung und Risiko. Keine andere Platform-Fighter-Reihe verbindet Charaktererstellung so direkt mit einer Kernmechanik.

### „Flux-Dash" – fortgeschrittene Bewegungstechnik
Ein Air Dodge schräg in den Boden überträgt den Schwung in einen Slide (wavedash-artig). Frame-genau timbar, mit sichtbarer Spur. Hohes Skill Ceiling, für Einsteiger optional.

## 8. Vorschlag zur Umbenennung (eigenständig, nicht klangähnlich)

| Heute | Neuer Name | Signature-Move neu |
|---|---|---|
| Son Goku | **KAIRO** – Sturmmönch | Solar-Kanone |
| Vegeta | **VARAKH** – Sternenprinz | Novafeuer |
| Frieza | **XYLAR** – Leerenkaiser | Nadelstrahl |
| Naruto | **REN** – Wirbelfuchs | Spiralkern |
| Sasuke | **KAGE** – Donnerklinge | Tausend Funken |
| Pain | **ORYN** – Schwerkraftprophet | Abstoßungswelle |
| Luffy | **TOBI** – Gummikapitän | Schleuderfaust |
| Zoro | **JUBEI** – Dreiklingen-Wanderer | Tigerschnitt |
| Tanjiro | **HIKARU** – Sonnentänzer | Morgenrotschnitt |
| Akaza | **RAIGA** – Kompassdämon | Frostkompass |
| Saitama | **BARTHOLOMEW „BART"** – Einschlag-Held | Ernstfall-Schlag |
| Sonic | **ZIP** – Blitzigel | Turbo-Rolle |
| Glurak / Charizard | **PYRAX** – Glutwyvern | Feuersturm |
| Blue-Eyes White Dragon | **ALBION** – Frostwyrm | Weißer Sturmstrahl |
| Sub-Zero | **GLACIEM** – Frostassassine | Eissplitter |

Bei allen Figuren müssen auch **Farben, Frisur und Outfit** so geändert werden, dass sie nicht mehr an das Original erinnern. Das mache ich nach deinem OK in den Material-Einstellungen, bei Bedarf auch in Blender.

## 9. Empfohlene Reihenfolge der ersten Schritte (jeweils einzeln, mit Test)

1. Tests reparieren und Zeitlimit einbauen → Sicherheitsnetz.
2. Bugs 1–5 aus 3.6 beheben (kleine, isolierte Fixes).
3. Physics Interpolation aktivieren und Karten-Hover ohne Neuaufbau → sofort spürbar flüssiger.
4. Umbenennung laut Abschnitt 8.
5. Frame-basierter Tick und geseedeter RNG → Determinismus-Test.
6. Danach P1 (State Machine, MoveData-Resources, Moveset) – **das ist ein großes Refactoring, für das ich vorher dein OK einhole.**

# Changelog

Format: neueste Einträge oben. Jeder Schritt nennt Spieler-Wirkung und technischen Grund.

## [Unreleased]

### Schritt 11 – Eigene Kämpfer statt Tripo-Scans, Arbër, echter Startbildschirm, Arena-Ambience (2026-10-02)

**Lizenz-Bereinigung**: Die zehn Kämpfer auf Tripo-Community-Modellen fremder Urheber (Brunhild, Thorn Witch, Nyx, Shira, Frostwyrm, Cyborg Mech, Reaper Hound, Treant, Celestial Fox, Mossback) sind neu und eigenständig gebaut: Mixamo-Körper plus eigene Ausrüstung im Code (Flügelhelm und Bartaxt, Dornenkrone und Rankenpeitschen, Seelensense, Katzenohren, Eisschwanz, Mech-Panzerung mit Schulterkanone, Schädelhelm, Rindenpanzer mit Geweih, neun Fuchsschwänze mit Fuchsfeuer, Felsrücken mit Widderhörnern). Neue IDs ohne „tripo“, alte Spielstände werden umgeschrieben. Leviathan ist der prozedurale Seedrache. Alle Tripo-Dateien liegen in `_quarantine_ip/tripo/`.

**Neuer Kämpfer Arbër, der Bohrmeister**: albanischer Handwerker-Held mit zwei Akku-Bohrern (Mehrfachtreffer, eigener Bohrsound) in Qeleshe und bestickter Xhamadan-Weste. Signatur **Ruf der Shqiponja**: Der schwarze Doppelkopfadler trägt ihn 6,5 s durch die Luft (Springen/Hoch steigt, Runter sinkt, sonst Gleitflug), stößt jede Sekunde auf den nächsten Gegner herab. Finisher **FLUG DER SHQIPONJA** (↑ ← Spezial).

**Startbildschirm**: Logo aus echter Schrift (Russo One, Teko – OFL) mit Metallverlauf, Kontur, Leuchten und Glanzlicht statt des gemalten KI-Bildes; dahinter läuft die Arena des gewählten Hintergrunds live mit drei Kämpfern und langsamer Kamerafahrt; Menü aus echten Knöpfen.

**Abenteuer-Modus** (`scripts/adventure.gd`, Hauptmenü ABENTEUER): ein Kämpfer gegen endlos viele Gegner. Jede Welle härter (KI-Stufe, Schaden, Gewicht), jede 5. ein Boss (Himmel und Hölle im Wechsel), Schaden bleibt und heilt nur zu 35 %. Punkte für Wellen, Tempo, Restgesundheit, Combos und Bosse; Rekorde pro Kämpfer, bester Lauf und Bestenliste. Kurze Kinosequenzen vor Bossen, an Meilensteinen (alle 10 Wellen: Münzen und Truhe) und am Ende eines Laufs.

**Legenden** (`scripts/story_legends.gd`, Story → 📜 LEGENDEN): für alle 49 Kämpfer eine eigene Hintergrundgeschichte in vier Kapiteln (Herkunft, Rivale, Abgrund, Legende) mit Kamerafahrten, Dialogen und je einem Kampf; die Kapitel öffnen sich mit den Meisterschafts-Sternen des Kämpfers. Die vollendete Legende gibt sein Relikt: 400 Münzen, eine Glückstruhe, Goldrahmen und +15 % Heilung im Abenteuer.

**Spaß & Wiederkommen** (`scripts/fun_modes.gd`): 8 **Mutatoren** für Versus-Kämpfe, frei kombinierbar unter OPTIONEN (Mondsprung, Turbo, Glaskanonen, Schwergewichte, Riesen, Winzlinge, Sudden Death, Volle Kraft). **Tages-Herausforderung** unter EXTRAS: jeden Tag ein fester Kampf (Kämpfer, Gegner, Mutatoren, Ziel wie „in unter 60 s“, „makellos“, „allein gegen zwei“), Serie über Tage mit steigender Belohnung und Truhe am 7. Tag. **Wochen-Events** im Wechsel (Doppel-XP, Goldrausch, Mutatoren-Festival, Woche der Herausforderer, Legenden-Woche). **Herausforderer**: Nach gewonnenen Solokämpfen taucht manchmal ein Überraschungsgegner mit Mutator auf – Sieg gibt Münzen und vielleicht eine Truhe. **Willkommen zurück**: nach 3+ Tagen Pause ein Geschenk. Alles als Hinweis auf dem Startbildschirm.

**Arenen**: Nebelschichten, Lichtstrahlen, Vogel-/Fledermausschwärme, Oberflächendetail, Umgebungsgeräusche je Arena (JC Sounds, CC BY 4.0, in den Credits).

### Schritt 10 – Göttliche Prüfung, 19 Bosse, Startmenü, Shop, Arenen, Belohnungssysteme (2026-09-30)

**Storymodus „DIE GÖTTLICHE PRÜFUNG“** (`story_divina.gd`, frei nach Dante): 21 Kapitel – Prolog im dunklen Wald (Wölfin, Vergil), INFERNO durch neun Höllenkreise (10 Dämonenfürsten), Aufstieg durch den Erdmittelpunkt, PARADISO mit Beatrice durch neun Himmelssphären (9 Engelschöre), Epilog im Empyreum. Kampagnen-Reiter im Storymenü; Prolog, Hölle und Himmel sind jeweils direkt startbar, die Kapitel eines Reichs schalten nacheinander frei. Story-Kämpfe gegen Bosse mit Verbündetem (Vergil bzw. Beatrice).

**19 Bosse** (`bosses.gd`): Himmel – Angelus, Michael, Principatus, Potestas, Virtus, Dominatio, Ophaniel, Keruvim, Seraphael; Hölle – Ahriman, Lilith, Asmodeus, Beelzebub, Mammon, Baphomet, Belphegor, Bel Marduk, Leviathan, Luzifer. Datengetriebene Angriffsmuster (Hieb, Salven, Regen, Schwärme, Sturm/Sog, Sturzflug, Walze, Ringwelle, Strahl, Säulen, Nova, Trägheitsfeld). Humanoide Bosse auf modellierten, animierten Körpern mit Stil „lebende Statue“ (Marmor, Gold, Silber, Obsidian mit glühenden Adern, Bronze, Knochen, Frost), dekoriert mit Federflügeln/Fledermausflügeln, Heiligenschein, Hörnern, Krone; Ahriman = Marmorbüsten-Scan, Leviathan = Drachenmodell; Seraph/Ophan/Cherub/Fliege prozedural mit gemalten Federn, Irisfasern, geäderten Augen. 5 neue Boss-Arenen (Höllentor, Flammenkreis, Stadt Dis, Cocytus, Himmelssphären). Boss-Menü mit Himmels-/Höllen-Rush.

**Startmenü**: Startbildschirm „DRÜCKE START“, danach das Hauptmenü im gewählten Hintergrund – das ins Bild gemalte Menü (STORY · VERSUS · EXTRAS · OPTIONS · SHOP · CREDITS) ist klickbar und per Pad bedienbar.

**Shop** (`backgrounds.gd`, `rewards.gd`): 23 Startmenü-Hintergründe (aus den Vorlagen geschnitten, hochskaliert), jeder schaltet seine **spielbare Arena** frei (13 Motiv-Baukästen: Neon-Gasse, Tempel/Dschungel, Holo-Stadt, Lagerhalle/Eiswerk, Stadion, Orbitalring, Dächer/Sturm, Kolosseum, Polarlicht, Hangar, Kriegsgebiet/Ruinen, Dojo, Gießerei). **8 neue Waffen** (Schattenkatana, Frostaxt, Feuerpeitsche, Kristallbogen, Drachenlanze, Seelensense, Donnerhammer, Plasmakanone) – gekauft spawnen sie in allen Arenen, eine als Startwaffe. **14 Skins** (Gold, Chrom, Marmor, Smaragd, Frost, Obsidian, Neon, Schatten, Lava, Kristall, Geist, Galaxie + 2 Pfad-exklusive). Glückstruhe, XP-Booster.

**Belohnungssysteme**: Münzen für jeden Kampf (¼ der XP), Bosse, Story-Kapitel; Level-up-Münzen und alle 5 Level eine Truhe; Erfolge zahlen 100 Münzen; Siegesserie bis ×1,5; Kampfnote S–D als Münz-Multiplikator; erster Sieg des Tages; Kopfgeld-Kämpfer des Tages; Liga (Bronze → Champion) mit Aufstiegsbelohnungen; 7-Tage-Login-Kalender; Glücksrad (täglich gratis, Jackpot); Tages- und Wochenaufgaben; Ruhmespfad mit 30 Stufen; Meisterschafts-Sterne pro Kämpfer zahlen Münzen; 12 Titel; Sammlungsfortschritt; 7 neue Erfolge. Alles unter EXTRAS bzw. SHOP, Hinweise im Hauptmenü, ausführliche Belohnungsübersicht nach jedem Kampf.

**Controller**: Alle Menüs per Pad – Leuchtrahmen springt per Steuerkreuz zum nächsten Knopf, A drückt, B zurück; Kämpferauswahl: LB/RB Arena, ⧉ Modus, R3 Teams, X Bosse, B Hauptmenü; Storydialoge A weiter, B überspringen, Wiederholen/Aufgeben per A/B.

Tests: 10 Suiten (neu: divina, shop, rewards).

### Schritt 9 – Paket 2, Team-Modi, Engel-Bosse (2026-09-30)

**Paket 2 – Ki-Kämpfer & Ninjas** (Kits in `fighter_kits.gd`, Mechaniken in `combat.gd`, Finisher-Filme in `main.gd`):

| Kämpfer | Archetyp | Signatur (neue Mechanik) | Finisher |
|---|---|---|---|
| Kairo | Allrounder, ↓Spezial lädt Super | **Aufladbarer Strahl**: Spezial halten → länger/stärker, voll geladen bühnenweit | SOLARFLUT ← → Schlag |
| Varakh | Druck-Zoner | **Ki-Salve**: 6 gezielte Schüsse, der letzte explodiert · ↓Spezial Stolzexplosion (Rüstung) | STERNENFALL ↑ ↓ Schlag |
| Xylar | schwebender Zoner (3 Luftsprünge) | **Nova-Kugel**: wächst über dem Kopf, wird geworfen; größer = mehr Schaden/Explosion · →Smash Todesfinger-Schuss | SUPERNOVA ↑ ↑ Schlag |
| Ren | Trickser | **Schattendoppelgänger**: stürmt vor, bleibt stehen und kopiert 5 s lang Rens Angriffe · ↓Spezial Platztausch mit dem Klon | SCHATTENARMEE → ← Spezial |
| Amethya | Rushdown | **Donnerpfad**: Dash hinterlässt elektrische Funkenspur · ↓Spezial Donnerkäfig (lähmt) | DONNERSTURZ ↓ ← Spezial |
| Oryn | Kontrolle | **Singularität**: zieht Gegner an, explodiert · ↓Spezial Abstoßung (wirft Geschosse zurück) | PLANETENBANN ← ↑ Spezial |
| Bruno | Punisher | **Ernstfall-Schlag**: durchbricht Schild, Knockback wächst mit Prozent, ab 120 % sicherer K.O. | ERNSTER SCHLAG → ↓ Schlag |

**Team-Modi:** Knopf „Spieler“ schaltet 1 gegen 1 → 4er-FFA → **Team 2 gegen 2** → **Team 3 gegen 1** (Einzelkämpfer +50 % Kraft, −40 % Knockback). Kein Friendly Fire, Team-Kürzel [A]/[B] im HUD, „TEAM A GEWINNT!“.

**Bosskampf – biblisch korrekte Engel** (`bosses.gd` Daten, `boss_models.gd` prozedurale Körper, Boss-KI in `combat.gd`): Helden (Slots 1–2, bei 4 Spielern 1–3; KI-Verbündete oder Koop) gegen einen Engel mit Lebensleiste, keine Knockback-Wirkung, Phase 2 ab 50 %, 300 s Zeit. Jeder Angriff wird mit roten Gefahrenzonen/Ringen vorgewarnt.
- **KERUVIM · Wächter des Tores** (Himmelspforte): vier Gesichter, Flammenschwert – Schwerthieb, Feueratem in 8 Richtungen, Flügelsturm, Sturzflug mit Beben.
- **OPHANIEL · Der Räderthron** (Räderhimmel): drei Goldräder voller Augen – Augenlaser, Radwalze quer über die Bühne, Ringwelle, Augensturm.
- **SERAPHAEL · Das brennende Auge** (Empyreum): Riesenauge in sechs Flügeln – Richtstrahl, Federregen, Feuersäulen unter jedem Helden, Heilige Nova.
- Boss-Menü (👁 BOSSKAMPF, Pad: X) mit Einzelbossen und **Boss-Rush**; nach einem Sieg „NÄCHSTER BOSS ▶“. Drei eigene Boss-Arenen.
- Boss-Optik: gezeichnete Federn, Irisfasern, geäderte Augäpfel, gehämmertes Gold, Stofffalten (alles im Code erzeugt), runde Glutpartikel; Augen folgen der Kamera. 2× MSAA für glatte Kanten.

Tests: 569/569 (neu: `test_bosses.gd` 34, `test_kits.gd` 142).

### Schritt 8 – Kit-System, Paket 1 (Story-Besetzung), Xbox-Standardsteuerung (2026-09-30)

**Paket 0 – Kit-System** (`scripts/fighter_kits.gd`): pro Kämpfer Archetyp, Gewicht, Lauftempo, Angriffsnamen, Bewegungsphysik (Sprungkraft, Schwerkraft, Fast-Fall, Luftbeweglichkeit, Luftsprünge, Laufgeschwindigkeit, Schildgröße), eigenes Moveset (15 Angriffe mit Frame-Daten, Hitbox, Winkel, Knockback) und eigener Finisher. Kämpfer ohne Kit spielen unverändert. Neue Kampfbausteine in `combat.gd`: Rüstung auf Angriffen und als Buff, Schüsse aus normalen Angriffen, Ausweich-Blink, Selbst-Buffs (Wut, Rüstung, Konter), zweistufige Specials, Signatur-Mechaniken als Up/Down-Special. Luftdash-Auftrieb skaliert mit der Schwerkraft (gleiche Rückkehrhöhe für alle).

**Paket 1 – 7 Kämpfer mit eigener Identität** (Signaturen in `signatures.gd`, Finisher-Filme in `main.gd`):

| Kämpfer | Archetyp | Signatur (neue Mechanik) | Finisher |
|---|---|---|---|
| Volt Ninja | Rushdown: hoher Sprung, schneller Fall | **Raijin-Mal**: Kunai markiert, Spezial erneut = Blitzschlag hinter das Ziel · ↓Spezial Rauchtausch (Blink + unverwundbar) | RAIJIN-HINRICHTUNG ← → Spezial |
| Boltar | Allrounder, 3 Luftsprünge, schwebend | **Lichtspeer**: Speer steckt im Boden, Spezial erneut = Rückruf mit Treffern, Fangen = sofort wieder bereit | LICHTURTEIL ↑ ↑ Spezial |
| Magmor | Schwergewicht mit Rüstung | **Magmaklumpen** hinterlässt Lavapfütze; **Glut-Anzeige** füllt sich bei Treffern → KERNSCHMELZE · ↓Spezial Magmapanzer | VULKANGRAB ↓ ↓ Spezial |
| Seraphine | Mix: Säbel & Pistole (→Tilt schießt) | **Enterhaken**: zieht sie zum Gegner + Enterstiefel · ↓Spezial Kanonenschlag von hinten | BREITSEITE ← ← Schlag |
| Cardinal | Verteidiger, großer Schild | **Schildwall**: Treffer von vorn wirkungslos, Geschosse werden reflektiert, dann Schildstoß · ↓Spezial Konter | SCHILDRICHTER → → Schlag |
| Kommandant | Punisher, lange Klinge | **Iaido-Haltung**: wer in Reichweite tritt, wird im Vorbeiziehen niedergeschnitten · ↓Spezial Windklinge | TAUSEND SCHNITTE ← ↓ Spezial |
| Warrok | schwerstes Schwergewicht, Rüstung | **Titanensprung**: springt auf den Gegner, Landebeben trifft alle am Boden · ↓Spezial Kriegsschrei | ERDBRECHER ↓ ↑ Schlag |

Die KI nutzt die zweiten Stufen (Blitzschlag, Rückruf, Kernschmelze). Auswahlmenü zeigt Archetyp und Gewicht, HUD zeigt Magmors Glut.

**Xbox-Standardsteuerung** (Genre-Standard wie Smash/Brawlhalla): Stick/Steuerkreuz bewegen, Stick nach oben = Sprung (Tap-Jump), A Schlag, B Spezial, X/Y Sprung, **LB/RB Greifen**, **LT/RT Schild**, **rechter Stick = Smash-Angriffe** (in der Luft Luftangriffe), ☰ Pause. Menüs komplett per Pad: Cursor pro Controller, A wählen, Y Zufall, B zurück, ☰ Kampf starten; Pause: B weiter, ⧉ zur Auswahl; Ergebnis: A Revanche, B Auswahl.

Tests: 475/475 (neu: `test_kits.gd` 82). Visuelle Prüfung: `tests/render_kits.gd`.

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

# Prompt Fighter Ultimate — Projektstatus

> Letztes Update: 2026-10-08

## Aktueller Stand (2026-10-08, Qualitätsdurchgang 3: kein Glücksspiel, Kämpfer freischalten, Sudden Death & Clash)

- Details: `docs/CHANGELOG.md` Schritt 21.
- Glücksrad, Glückstruhe und Zufalls-Legendentruhe entfernt; alle Belohnungen fest (Münzen bzw. nächstes fehlendes Item).
- Release-Kader: 10 Startkämpfer, Rest durch Spielen (alle 3 Siege) oder Münzen (600/900/1200) freischaltbar (`scripts/roster_unlocks.gd`, Shop-Tab KÄMPFER).
- Kampf: Sudden Death im Versus, Clash bei gleichzeitigen Angriffen, Funkenschweif und Gefahren-Glut ab 120 %.
- Neue Android-APK: `builds/android/PromptFighterUltimate.apk` (alte Version gesichert als `PromptFighterUltimate_2026-10-07_alt.apk`).
- **Tests:** 18 Suiten / 1616 Checks grün.

## Früherer Stand (2026-10-08, Qualitätsdurchgänge 1+2: Stabilität, Desktop und Handy getrennt)

- Details: `docs/CHANGELOG.md` Schritt 19 und 20.
- Stabilität: Griff-/Respawn-Bug (doppelter Stock-Verlust), Respawn räumt Statuseffekte auf, Coyote-Time 0,1 s, Pause bei Fokusverlust auch gegen KI, keine Pause nach GAME!, R-Neustart nur aus Pause/Ergebnis, Zeitlupen- und Kamera-Shake-Überlagerung, Trefferfunken in richtiger Höhe, bildratenunabhängige Kamera.
- Handy: gerätegerechte Eingabehinweise (`scripts/input_glyphs.gd`), Touch-QTEs, Story-Niederlage per Touch lösbar, Handy-Intro `intro_mobile.ogv` ohne Tastaturtexte, Vibration, Tap-Sprung, nähere Kamera, weniger Partikel.
- Desktop/Steam: Pause-Menü, Pad-/Tastaturnamen in QTEs und Finisher-Codes, korrigierte Tastenhilfe, weiches Respawn-Pulsieren, Funken-Pool.
- **Tests:** 18 Suiten / 1605 Checks grün.

## Früherer Stand (2026-10-08, Offizielle AAA-Gameplay-Trailer für Steam & Google Play)

- **Offizielle Trailer-Suite (`trailer_output/`)**:
  - **Steam Gameplay-Trailer (`trailer_steam.mp4`)**: 70.0s, 1920x1080 @ 60 FPS, H.264 High Profile, ~20.5 Mbps, AAC Stereo 48 kHz (-14 LUFS). Unmittelbarer Gameplay-Start in den ersten 5s ohne Logos. Fehlerhafte Pferdeszene/Menübalken komplett entfernt und durch saubere Sonnenarena-Kampfaction mit Fallen/Waffen ersetzt. Alle gezeigten Features prominent mit leuchtenden Frosted-Obsidian-Bannern beschriftet (`/// FEATURE: ... ///`: Echtes 3D Gameplay, Combat Engine & Combos, 4-Spieler Multiplayer, Interaktive Arenen, Titanische Boss-Raids, Cinematic Finisher) plus 3D-Outro-Card (*„Wishlist Now on Steam · Coming 2026“*).
  - **Google Play Trailer (`trailer_playstore.mp4`)**: 40.0s, 1920x1080 @ 60 FPS, H.264 High Profile, AAC Stereo (-14 LUFS). Optimiert für mobile Betrachtung ohne Ton (große kontraststarke Typografie), Hook in Sekunde 0–5, 4-Spieler-Brawl, Roster-Übersicht, beschriftete Elementar-Specials & Bosses und Outro (*„Pre-Register & Play Free on Google Play“*).
  - **Begleitgrafiken**: `poster_steam.jpg` (1920x1080), `thumbnail_steam.jpg` (232x130) und `feature_graphic_play.png` (1024x500 RGB ohne Alpha, unter 1 MB, Play-Button-sicheres Zentrum).
  - **Lizenzen & Reproduzierbarkeit**: `LIZENZEN.md` mit vollständigen CC0/Projekt-Nachweisen sowie `trailer_output/scripts/` mit allen Capture- und Render-Skripten.
  - **QA-Audit**: `QA_REPORT.md` bestätigt alle technischen Parameter (`ffprobe 9.0.2`) und inhaltlichen Kriterien zu 100% bestanden.
- **Stabilität & Spielgefühl:** Alle 18 Suiten / 1616 Checks grün (100% Pass Rate).
- **Tests:** 18 Suiten / 1616 Checks grün (`scripts/Test-Project.ps1`).

## Früherer Stand (2026-10-07, Store Release & Mobile & Gameplay-Juice)

- **Spezialisierte Agenten-Suite (`.agents/`)**:
  - 4 Experten-Rollen etabliert: [pfu-gameplay-engineer](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/.agents/skills/pfu-gameplay-engineer/SKILL.md), [pfu-mobile-architect](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/.agents/skills/pfu-mobile-architect/SKILL.md), [pfu-audio-vfx-director](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/.agents/skills/pfu-audio-vfx-director/SKILL.md), [pfu-qa-balance-tester](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/.agents/skills/pfu-qa-balance-tester/SKILL.md).
- **Aktueller Android-Build (APK)**:
  - Vollständiger, signierter Release-Build in [builds/android/PromptFighterUltimate.apk](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/builds/android/PromptFighterUltimate.apk) (1.54 GB).
  - Schema v2/v3 Signatur verifiziert, 60-FPS-Intro, Touch-Steuerung und alle 58 Kämpfer enthalten. Automatisiertes Build-Skript: [scripts/Export-Android.ps1](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/scripts/Export-Android.ps1).
- **Store-Assets für Steam & Google Play**:
  - Texte: DE & EN Beschreibungen, Systemanforderungen, IARC & KI-Angaben ([store/texts/steam_de.txt](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/store/texts/steam_de.txt), [store/texts/steam_en.txt](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/store/texts/steam_en.txt), [store/texts/play_de.txt](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/store/texts/play_de.txt), [store/texts/play_en.txt](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/store/texts/play_en.txt)).
  - DSGVO-Datenschutzerklärung: [store/legal/datenschutz.html](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/store/legal/datenschutz.html) (zweisprachig DE/EN).
  - **AAA Store-Upload-Grafiken für Steam & Google Play**: Vollständiges, 100% spezifikationskonformes Bild-Bundle aus den High-Impact-Visuals erzeugt (Main Capsule 1232x706, Header 920x430, Small 462x174, Vertical 748x896, Library Capsule 600x900, Library Hero 3840x1240 textlos, transparentes 32-Bit Logo 1280x720, Feature Graphic 1024x500 ohne Alpha, 512x512 App-Icon, 8x 1080p Marketing-Screenshots mit Frosted-Glass-Badges sowie saubere Roh-Screenshots). Fertig gepackt in [store/upload_bundle/](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/store/upload_bundle) mit [UPLOAD_GUIDE.md](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/store/upload_bundle/UPLOAD_GUIDE.md). Skript: [scripts/build_store_page_assets.py](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/scripts/build_store_page_assets.py).
  - **Animierter AAA-Trailer (1080p60 Master, 42.0s, H.264/AAC & WebM VP9)**: Vollständig animierte 5-Akt-Inszenierung basierend auf den Kern-Artworks mit Subpixel-Kamerafahrten, Funken- & Glutpartikeln, Lens Flares, Announcer-Voice-Lines, Soundeffekten und High-Conversion Call-to-Action für Steam und Google Play ([store/trailer/prompt_fighters_trailer_1080p60.mp4](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/store/trailer/prompt_fighters_trailer_1080p60.mp4), [store/steam/trailer_1080p60.mp4](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/store/steam/trailer_1080p60.mp4), [store/play/trailer_1080p60.mp4](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/store/play/trailer_1080p60.mp4)).
- **Gameplay-Juice & Haptik**:
  - Gamepad-Vibration & Haptik (`Input.start_joy_vibration`) bei leichten Treffern, Smash-Hits, Schilden und K.O.s.
  - Dynamischer Combo-Counter mit federnder Skalierung und Announcer-Callouts (`combo.ogg` & `combo_breaker.ogg`).
  - Announcer-Stimmen eingebunden: `choose_your_character`, `player_1`, `player_2`, `arcade_mode`, `story_mode`.
- **Tests:** Alle Test-Suiten grün (100% Pass Rate).

## Früherer Stand (2026-10-07, Arena und Auswahl)

- **Neues Premium-Icon & Boot-Splash**:
  - Hochauflösendes AAA-App-Icon (512x512) mit metallischem Schild-Emblem, "PF"-Monogramm, kollidierenden Elektro-Cyan- und Feuer-Klingen im kosmischen Raum (`godot/icon.png` und `godot/icon_512.png`).
  - Boot-Splash in `project.godot` mit sanftem Filter und optimiertem Zentrierungsmodus (`boot_splash/use_filter=true`).
- **Photorealistisches 60-FPS AAA-Ladebildschirm- & Intro-Video (vollflächig ohne Ränder)**:
  - **Vollfensterfüllendes 16:9 Format**: Randlos auf 1280x720 skaliert (`boot_splash/fullsize=true` mit [godot/splash_1280x720.png](file:///c:/Users/schmidtdenis/Desktop/Ultimate%20Prompt%20Fighters/PromptFighterUltimate/godot/splash_1280x720.png)). Das Startbild und das Video füllen das gesamte Fenster ohne störende Kästen, Kreisränder oder Letterboxing aus.
  - **Butterweiche 60 FPS**: 330 gerenderte Frames für absolut flüssige Rotationen der holografischen Cyber-Ringe, Partikel-Embers, Ladebalken-Fortschritt und Lichtreflex-Sweeps über dem "PF"-Emblem.
  - **Nahtlose Emblem-Integration**: Reiner Alphamasken-Freisteller des metallischen Schildes mit lodernden Elementarklingen direkt im atmosphärischen Tiefenraum (Cyan-Aura links, Amber-Aura rechts, Bodenschimmer).
  - **Kino-Sounddesign**: Professionelle Stereo-Tonspur (Turbinen-Riser 40–140 Hz, Telemetrie-Pings, 34-Hz-Subbass, Titan-Amboss-Aufprall und D-Dur-Orchesterpad).
  - **Engine-Crossfade**: 0.35s weicher Dissolve-Übergang direkt in das 3D-Hauptmenü; jederzeit per Tastendruck/Gamepad überspringbar (in Headless-Tests mit 0ms Bypass).
- **Runderneuerter Startbildschirm & Hauptmenü**:
  - **Perfekte Symmetrie & Zentrierung**: Sowohl der Splash-Screen ("Drücke Start") als auch das Hauptmenü sind nun exakt horizontal zentriert.
  - **Kristallklare Lesbarkeit & Kontrast**: Dunkle Obsidian-Glashintergründe mit leuchtenden Akzenträndern vor der 3D-Arena.
  - **Neues Hauptmenü**: 7 gleichmäßig proportionierte Menükarten mit Icons (`⚔ VERSUS-KAMPF`, `📖 STORY-MODUS`, `🗺 ABENTEUER-TURM`, `🛒 KAMPF-SHOP`, `★ EXTRAS & BELOHNUNGEN`, `⚙ EINSTELLUNGEN`, `📜 CREDITS`) und aktivem Glow-Rahmen.
  - **Performance-Optimierung**: Beseitigung aller per-Frame Dictionary-Allokationen in `_title_camera(delta)` (State-Cache), automatische Pausierung der 3D-Hintergrundkamera bei geöffneten Modalfenstern und optimierte Schwebepartikel (22) für butterweiche 60+ FPS.
  - **Vollständige Säuberung**: Letzte Reste von "Glückstruhe" in Login- und Challenge-Screens restlos durch garantierte Münzen (+500 🪙) ersetzt.
- **Neue Spezial-Arena: Astral Obsidian Nexus (`astral_nexus`)**:
  - Konzentrisch rotierende Chrono-Ringe (`rotors`), schwebende Obsidian-Monolithen mit glühenden Runen-Adern (`bobbers`), violette Plasma-Braziers und kosmische Lichtstrahlen im Raumzeit-Vakuum.
  - Eigene interaktive Gefahrenzone: `quantum_rift` (Astral-Riss mit Partikelwirbel, 16 DMG, 0.75 Rückstoß).
  - Hochauflösende 384x216 Vorschau-Grafik und PBR-Materialien mit Lavastein-Emission.
- **Vollständige Entfernung aller Glücksspiel- / Lootbox-Truhen**:
  - Glücksspiel-Truhen (`🎁 GLÜCKSTRUHE`) restlos aus dem Shop, Quests und Belohnungsabläufen entfernt.
  - Store umgestellt auf ein transparentes Direktkauf-System (Hintergründe, Waffen, Skins gegen Münzen).
  - Tägliche Missionen, Herausforderer-Bonus und Abenteuer-Meilensteine vergeben nun garantierte, transparente Münz-Belohnungen (+250 / +500 🪙).
  - Bestehende gespeicherte Truhen werden beim Spielstart automatisch 1:1 zu je 250 Münzen umgewandelt.
  - Dekorative Schatzkisten in Arenen durch authentische nautische Frachtfässer ersetzt.
- **Kompletter Overhaul der Kämpfer- & Arena-Auswahl (Fighting Game Style)**:
  - Inspiriert von Street Fighter 6, Tekken 8 und Super Smash Bros:
  - **14x4 Roster-Grid**: Alle 56 Kämpfer klar gegliedert auf 84x44 Karten mit Porträts, Element-Tags und 1P/2P Badges.
  - **P1 & P2 Showcases**: Getrennte Profile mit glühenden Akzenten (Cyan P1 / Amber P2), Attributsbalken (HP, KRAFT, RÜSTUNG, TEMPO, TECHNIK), Spezialmove-Banner und Rangsternen.
  - **Arena-Vorschaupanel**: Zentrales Modul mit 16:9 Artwork-Vorschau, Karussell-Steuerung, dynamischer Fallen-Warnanzeige und Quick-Pick-Buttons inklusive Astral Nexus.
  - **Saubere Header- & Match-Optionen**: Direkte Regler für Kampfmodus, Spieleranzahl, Leben, KI-Stufe und Finisher.
- **Testabdeckung**: Alle Testsuiten grün, 0 Regressionen.

## Früherer Stand (2026-10-06)

- **Arena-Grafik & Shader-Upgrade**:
  - Dynamisches PBR-Material-Upgrade mit Rim-Lighting (0.35–0.38 Rim, 0.45 Tint) und Tiefen-Normal-Maps.
  - Monumentales arkanes Kampf-Mandala im Zentrum jeder Arena mit rotierendem Stern-Kern und sanft pulsierender Magie-Aura.
  - Strahlende Energie-Kanäle und doppelte Leucht-Kantenfasen (`trim`) entlang der Plattformgrenzen.
  - 4 monumentale Eck-Feuerschalen (Braziers) mit dynamischem Partikelfeuer und flackerndem Licht.
- **Interaktive Arena-Fallen (Hazards)**:
  - Dynamisch konfigurierte Fallen passend zum Arena-Motiv:
    - *Vulkan/Hölle*: Flammenwerfer & Magma-Geysire (`fire_vent`) mit Vorwarnung, Ausbruch und vertikalem Hochschleudern.
    - *Kolosseum/Bastion*: Mechanische Boden-Stachelfallen (`spikes`) mit Vorwarnungs-Rütteln und scharfem Schnappstoß.
    - *Neon Metropolis*: Hochspannungs-Tesla-Gitter (`tesla_shock`) mit Blitzentladung.
    - *Eisgipfel/Cocytus*: Eisstalaktiten-Geysire (`ice_stalactite`) mit Gefrierwirkung.
    - *Mystic Grove*: Giftige Dornenranken (`thorn_roots`).
- **Zerstörbare Arena-Objekte (Destructibles) & Trümmer-Physik**:
  - Auf den Arenen platzierte interaktive Objekte: Antike Runensäulen, mystische Kristallschreine und gepanzerte Vorratskisten.
  - Erleiden Schaden durch Schläge, Projektile und geworfene Gegenstände.
  - Bei Zerstörung: Gewaltige Explosion mit 3D-Physik-Trümmerstücken (Debris), Schockwelle, Kamera-Erschütterung und Sound.
  - Lassen wertvolle Power-Ups / Items fallen (Titan-Pilz, Stern der Unsterblichkeit, Heilherz, Turbostiefel, Smash-Hammer oder Explosivfässer).
  - Automatischer Wiederaufbau-Timer (Respawn).
- **VFX & Kampfeffekt-Upgrade**:
  - Multi-Tier Hitsparks mit Richtungs-Funkenregen, Schockwellen-Tori und Hitstop-Kameraerschütterung.
  - Impact-Frame Flash bei harten Treffern.
  - Staubwolken bei Sprints und Lande-Aufprallringe.
- **Testabdeckung**: 18 Suiten, 1421/1421 grün (inkl. neuer Suite `test_hazards_and_destructibles.gd`).

Die folgenden Abschnitte beschreiben den älteren Stand vom 2026-09-25.

## Projektübersicht

| Feld | Wert |
|------|------|
| **Engine** | Godot 4.7.2 (Compatibility Renderer, OpenGL 3.3) |
| **Plattform** | Windows (Entwicklung), Android (Produktionsziel) |
| **3D-Tool** | Blender 4.5.5 (portabel) |
| **Spielbare Charaktere** | 20 |
| **Spielmodi** | 3 (PvP, PvE, KI vs KI) |
| **Arenen** | 6 |

## Spielbare Charaktere (20)

| # | Familie | Name | Besondere Fähigkeit |
|---|---------|------|---------------------|
| 1 | ninja | VOLT SHADOW | Raijin Dash |
| 2 | golem | CINDER BASTION | Magma Quake |
| 3 | valkyrie | VALKYRIE AURA | Radiant Pierce |
| 4 | dragon | IGNIS DRAKE | Wyrm Flame |
| 5 | kairo | KAIRO (STURMMÖNCH) | Solar-Kanone |
| 6 | varakh | PRINZ VARAKH | Final Flash |
| 7 | glaciem | GLACIEM | Kori Ice Shard |
| 8 | oryn | ORYN | Shinra Tensei |
| 9 | tobi | TOBI (FEDERFAUST) | Gum-Gum Pistol |
| 10 | jubei | RORONOA JUBEI | Santoryu: Onigiri |
| 11 | ren | REN (KIRSCHKRIEGERIN) | Blütenwirbel |
| 12 | amethya | AMETHYA (DONNERHEXE) | Amethystblitz |
| 13 | bruno | BRUNO (ONE PUNCH) | Serious Punch |
| 14 | hikaru | HIKARU KAMADO | Hinokami Kagura |
| 15 | zip | ZIP (BLITZKURIER) | Super Spin Dash |
| 16 | raiga | RAIGA (DONNERFAUST) | Destructive Death: Sternschlag |
| 17 | albion | ALBION (SILBERWYRM) | Sturmstrahl |
| 18 | anubis | CYBER ANUBIS | Anubis Wrath |
| 19 | specter | VOID SPECTER | Void Lance |
| 20 | phoenix | PHOENIX EMPRESS | Phoenix Flare |

## Spielmodi

- **⚔ Spieler vs Spieler (PvP)** — Lokaler Versus mit geteilter Tastatur
- **🥊 Spieler vs Agent (PvE)** — Spieler 1 manuell, Spieler 2 KI-gesteuert
- **🤖 Agent vs Agent (KI vs KI)** — Beide Kämpfer vollautomatisch

## Kernsysteme

### Kampfsystem
- Super Smash Bros Platform Fighter
- 6 Plattformen auf 4 vertikalen Ebenen
- Blast Zones (Ring Out)
- 3-Stock Lives System
- Datengetriebene Knockback-Formel (HP-abhängig)
- 3-Phasen-Angriffspipeline: Windup → Active → Recovery
- Hit Interrupt (Angriffe werden durch Treffer unterbrochen)

### Greifen & Werfen
- Gegner greifen, halten und in 4 Richtungen werfen
- Blockende Gegner durchgreifen
- Befreiung bei Timeout

### Arena Items
- Leichte Kiste (zerbrechlich, 12 Schaden)
- Schwerer Stein (robust, 22 Schaden)
- Holzfass (mittel, 16 Schaden)
- Explosiv-Fass (Flächenschaden, 34 Schaden, 2.6 Radius)
- Aufheben, tragen, werfen
- Auto-Respawn nach Zerstörung

### Spezial-Mechaniken
- Super-Meter (passiv + bei Treffer)
- Combo-System mit Schadensmultiplikator
- Parry-System (perfektes Block-Timing)
- Hitstop bei Treffern
- DI (Directional Influence) in der Luft
- Drop-Through Plattformen (S+W)

### Character Remixer
- Modularer Charakter-Generator aus Prompt
- 11 Body-Module, 5 Elemente, 6 Abilities
- Stat-Budget: 100 Punkte (balanciert)
- UI im Auswahlscreen integriert

## Aufgabenstatus

| Aufgabe | Status |
|---------|--------|
| 14 spielbare Charaktere | ✅ Erledigt |
| PvE Modus | ✅ Erledigt |
| Auswahlscreen (10x2) | ✅ Erledigt (20 Kämpfer) |
| 6 Arenen mit PBR-Texturen | ✅ Erledigt |
| 6 Neue Anime-Legenden (Ren, Varakh, Jubei, Bruno, Hikaru, Amethya) | ✅ Erledigt mit 3D-Modellen & PBR-Skins |
| Character Remixer (Core & UI) | ✅ Erledigt |
| 3-Phasen Attack Pipeline | ✅ Erledigt |
| Hit Interrupt System | ✅ Erledigt |
| Knockback +25% | ✅ Erledigt |
| Raiga & Albion Pro Models | ✅ Erledigt |
| Animation Audit (State Machine) | ✅ Erledigt — 20/20 bestanden |
| Performance Baseline | ✅ Erledigt — 45.8µs avg (0.27% Budget) |
| Attack Data-Driven System | ✅ Erledigt (windup/active/recovery/cost/push/angle/hitstun) |
| GDScript Optimierung | 🟡 Offen |
| Android Export | 🟡 Offen |
| Rendering LOD | 🟡 Offen |

## Test-Ergebnisse

| Test | Ergebnis |
|------|----------|
| test_all_playable.gd | ✅ 20/20 BESTANDEN (Sim & View) |
| test_animation_audit.gd | ✅ 20/20 BESTANDEN (State Machine Transitions) |
| test_performance.gd | ✅ 45.8µs avg, 0.27% Budget |
| test_smash_mechanics.gd | ✅ ALLE BESTANDEN |
| test_remixer.gd | ✅ 5/5 BESTANDEN |
| test_match_all.gd | ✅ ALLE BESTANDEN |

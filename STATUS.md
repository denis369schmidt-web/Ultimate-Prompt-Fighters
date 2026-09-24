# Status: Prompt Fighter Ultimate

## 1. Übersicht & Zielsetzung
Ziel: Hochwertiger 2,5D-Arenakämpfer mit datengetriebenem Rückstoß (proportional zu fehlenden HP, Smash-Mechanik), Greif-/Wurfsystem, aufhebbaren/werfbaren Gegenständen inklusive explosiven Fässern, individuellen Spezialfähigkeiten, 13 spielbaren Charakteren im stilvollen Mortal-Kombat-Auswahlgitter und nahtloser Unterstützung von Spieler- vs. KI-Steuerung.

## 2. Aktueller Status

### Tatsächlich umgesetzt
- [x] **A. Bestandsaufnahme & Sicherung**: Git-Snapshot im Branch `feature/smash-mechanics-upgrade`.
- [x] **B. Datengetriebener Rückstoß (50% Rebalanced)**:
  - Exakte Formel implementiert: Missing HP Ratio skaliert Launch exponentiell.
  - Rückstoßkraft um 50% abgemildert für optimale Spielbarkeit und präzise Arena-Kontrolle.
  - Charaktergewicht dämpft den Rückstoß (Golem 1.32 vs Sonic 0.88).
  - Hitstop-Frames, Hitstun-Dauer und Air-Control / Directional Influence (DI) in der Luft.
  - Normaler Lebenspunkte-Modus (0 HP = K.O.) und 3-Stock-Ring-Out-Modus koexistieren nahtlos.
- [x] **C. Vollständiges Greif- und Wurfsystem**:
  - Eigene Aktionen `p1_grab` (Taste E) und `p2_grab` (Taste O / Numpad 4).
  - Zustandsautomat: `Ready`, `Attack`, `HitStun`, `Grab`, `Grabbed`, `Throw`, `Carrying`, `Defeated`.
  - Vorwärtswurf (Forward Throw), Rückwärtswurf (Back Throw), Aufwärtswurf (Up Throw).
  - Anti-Chain-Grab-Schutzzeit (Immunity 0.85s).
  - Automatisches Losreißen (Breakout) bei Zeitüberschreitung.
- [x] **D. Aufhebbare & werfbare Arenaobjekte + Explosivfässer**:
  - 4 Objekttypen: Leichte Kiste (Light Crate), Schwerer Stein (Heavy Rock), Holzfass (Barrel), Explosiv-Fass (TNT Barrel mit AoE-Detonation).
  - Explosivfässer explodieren bei Feindkontakt, Bodenaufprall nach Wurf oder bei gezieltem Angriff eines Kämpfers.
  - Eingabepriorität: Objekt aufheben hat Vorrang bei räumlicher Nähe, sonst Gegner-Greifen.
  - Physikalische Wurfsimulation auf der Kampfebene (Z=0) mit Trägheit, Flugbahn, Geschwindigkeitsdämpfung, Tunneling-Schutz und automatischem Plattform-Respawn.
  - 3D-Meshes und PBR-Materialien in `main.gd` mit prozeduraler Holzmaserung, Rissstein, Eisenreifen, Gefahrenstreifen und Zünder-Glow.
- [x] **E. Alle 13 Charaktere vollständig spielbar & visuell überarbeitet**:
  1. **Volt Ninja** (Cyber-Shinobi mit Dual-Ninjato)
  2. **Lava Golem** (Basalt-Monolith mit Magmafäusten)
  3. **Valkyrie** (Paladin-Kriegerin mit Moe-Ästhetik & Lichtrapier)
  4. **Ignis Drake** (Drachenritter mit Großschwert & Flammenodem)
  5. **Cyber Anubis** (Schakal-Gott mit Dual-Khopesh)
  6. **Void Specter** (Kristallphantom mit Void-Lanze)
  7. **Phoenix Empress** (Feuervogel-Herrscherin mit Phoenix-Glaive)
  8. **Son Goku** (Ultra Instinct / Super Saiyan mit Kamehameha)
  9. **Sub-Zero** (Lin Kuei Cryomancer mit Kori-Klinge & Eisscherben)
  10. **Pain / Nagato** (Akatsuki Deva Path mit Rinnegan & Shinra Tensei)
  11. **Monkey D. Ruffy** (Strohhut-Kapitän mit Gum-Gum-Pistole)
  12. **Sonic the Hedgehog** (Blue Blur mit Power Sneakers & Spin Dash)
  13. **Akaza / Hakuji** (Upper Rank Three mit Hakai Satsu Compass Needle)
- [x] **F. Neuer Kämpfer: Akaza (Demon Slayer)**:
  - 3D-Modell in Blender 4.5.5 LTS mit Soryu-Tattoos, ärmellosem Haori-Vest, Shimenawa-Kordelgürtel mit Gebetsperlen, Hakama-Hose, blauen Fußperlen und leuchtenden Dämonenaugen.
  - 12-strahlige, cyan-emittierende Kompassnadel-Bodenmandalas (`Akaza_CompassNeedle`), dynamisch aktiv bei Spezialangriff.
  - PBR-Texturen: Albedo, Normal, Emission für Haut, Haori, Hakama und Kompass.
  - UI-Porträts: `portrait_akaza.png` und `thumb_akaza.png`.
- [x] **G. Neuer Kämpfer: Sonic the Hedgehog**:
  - 3D-Modell mit 6 Stacheln, goldenen Schuhschnallen, Handschuhen und dynamischer Spin-Dash-Kugel.
  - PBR-Texturen für Fell, Haut, Schuhe und Schnallen.
- [x] **H. Mortal Kombat Charakterauswahl-Menü (13 Kämpfer)**:
  - 7x2 interaktives Auswahlgitter im klassischen Mortal-Kombat-Design.
  - Goldener Header „CHOOSE YOUR FIGHTER“.
  - Separate Spieler-Tabs (P1 / P2) mit visuellen Markierungs-Badges.
  - Linksklick setzt P1, Rechtsklick setzt P2.
  - Echtzeit-Statistiken, Element-Anzeige und dynamische Prompt-Bearbeitung.
- [x] **I. Arena-Überarbeitung & Vergrößerung**:
  - Spielfläche erweitert: Hauptbühne `STAGE_LEFT = -5.15`, `STAGE_RIGHT = 5.15`, Blast Zones `-9.5` bis `+9.5`.
  - Monumentale Kolosseum-Kolonnade mit 6 Säulen, Zinnen, Architrav und lodernden Feuerschalen/Fackeln.
  - 6 Arenen zur Auswahl: Blood Moon Terrace, Volcanic Dragon Sanctum, Imperial Colosseum, Pirate Galleon Dock, Gladiator Bastion, Bioluminescent Grove.
- [x] **J. Testsuite (100% bestanden)**:
  - `res://tests/test_game.gd`: 36/36 Tests grün.
  - `res://scripts/test_grab_and_items.gd`: Alle Tests bestanden.
  - `res://scripts/test_explosive_barrel.gd`: Wurf & Detonation bestanden.
  - `res://scripts/test_smash_mechanics.gd`: Alle Plattform & Stock-Tests bestanden.
  - `res://scripts/test_all_playable.gd`: Alle 13 Charaktere validiert und spielbar.

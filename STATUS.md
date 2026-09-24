# Status: Ultimate Prompt Fighters Upgrade

## 1. Übersicht & Zielsetzung
Ziel: Hochwertiger 2,5D-Arenakämpfer mit datengetriebenem Rückstoß (proportional zu fehlenden HP), Greif-/Wurfsystem, aufhebbaren/werfbaren Gegenständen, individuellen Spezialfähigkeiten, überarbeiteten Charaktermodellen/Arenen und nahtloser Unterstützung von Spieler- vs. KI-Steuerung.

## 2. Aktueller Status

### Tatsächlich umgesetzt
- [x] **A. Bestandsaufnahme & Sicherung**: Git-Snapshot im Branch `feature/smash-mechanics-upgrade`.
- [x] **B. Datengetriebener Rückstoß**:
  - Exakte Formel implementiert: Missing HP Ratio skaliert Launch exponentiell (3.97 m/s bei 100% HP bis 14.04 m/s bei 20% HP).
  - Charaktergewicht dämpft den Rückstoß (Golem 1.32 vs Ninja 0.92).
  - Hitstop-Frames, Hitstun-Dauer und Air-Control / Directional Influence (DI) in der Luft.
  - Normaler Lebenspunkte-Modus (0 HP = K.O.) und 3-Stock-Ring-Out-Modus koexistieren nahtlos.
- [x] **C. Vollständiges Greif- und Wurfsystem**:
  - Eigene Aktionen `p1_grab` (Taste E) und `p2_grab` (Taste O / Numpad 4).
  - Zustandsautomat: `Ready`, `Attack`, `HitStun`, `Grab`, `Grabbed`, `Throw`, `Carrying`, `Defeated`.
  - Vorwärtswurf (Forward Throw), Rückwärtswurf (Back Throw), Aufwärtswurf (Up Throw).
  - Anti-Chain-Grab-Schutzzeit (Immunity 0.85s).
  - Automatisches Losreißen (Breakout) bei Zeitüberschreitung.
- [x] **D. Aufhebbare & werfbare Arenaobjekte**:
  - 3 Objekttypen: Leichte Kiste (Light Crate, zerspringt bei Treffer), Schwerer Stein (Heavy Rock, hoher Schaden), Holzfass (Barrel, rollt/prallt ab).
  - Eingabepriorität: Objekt aufheben hat Vorrang bei räumlicher Nähe, sonst Gegner-Greifen.
  - Physikalische Wurfsimulation auf der Kampfebene (Z=0) mit Trägheit, Flugbahn, Geschwindigkeitsdämpfung, Tunneling-Schutz und automatischem Plattform-Respawn.
  - 3D-Meshes und PBR-Materialien in `main.gd` mit prozeduraler Holzmaserung, Rissstein, Eisenreifen und Flug-Rotationsanimation.
- [x] **E. Visuelle Charakter-Überarbeitung**:
  - PBR-Materialien mit Normalmaps, Albedo, Roughness und dynamischem Emissions-Glow für Golem, Ninja, Valkyrie, Dragon und Neuzugänge.
  - Animations-Aliasing in `fighter_view.gd` für `Attack`, `Throw`, `Grab`, `Carrying`, `Grabbed`.
- [x] **F. Individuelle Spezialfähigkeiten**:
  - Schattenninja: Raijin Dash (schneller elektrischer Klingenvorstoß)
  - Lavagolem: Magma Quake (schwerer Bodenschlag mit Schockwelle)
  - Eisninja: Kori Ice Shard (Eisprojektil mit Verlangsamungseffekt)
  - Pain: Shinra Tensei (radialer Abstoßungsimpuls)
  - Ruffy: Gum-Gum Pistol (Reichweiten-Faustschlag)
- [x] **G. Arena-Überarbeitung (Verfallene Zitadelle / Imperial Colosseum)**:
  - Räumliche Staffelung aus Hintergrund (Monumentale Kolosseum-Kolonnade bei Z=-5.5, verfallene Festungsmauer bei Z=-8.0), Spielfläche (Z=0 mit leuchtenden Battlefield-Plattformen) und Vordergrund-Rahmung (gebrochene Pfeilerstümpfe seitlich bei X=±6.8, Z=+1.5).
  - Kampffeld lesbar freigestellt mit Kontrast und Kantenlicht.
- [x] **H. Steuerung & Oberfläche**:
  - HUD mit 3 Leben (Stocks `● ● ●`), Lebenspunkten, Spezial-Status, dynamischen Ring-Out-Meldungen und interaktivem Controls-Panel.
- [x] **I. Umfassende Testsuite**:
  - `res://tests/test_game.gd`: 36 von 36 Tests bestanden (100% Pass Rate).
  - `res://scripts/test_grab_and_items.gd`: Alle Knockback-, Grab/Throw- und Item-Tests bestanden.
  - `res://scripts/test_smash_mechanics.gd`: Alle Plattform- und Stock-Tests bestanden.
  - `res://scripts/test_all_playable.gd`: Alle 11 Charaktere spielbar validiert.

### Nächster Arbeitsschritt
- Bereitstellung und Start des aktualisierten Spiels für den User.

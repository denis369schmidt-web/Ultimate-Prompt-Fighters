# Status: Ultimate Prompt Fighters Upgrade

## 1. Übersicht & Zielsetzung
Ziel: Hochwertiger 2,5D-Arenakämpfer mit datengetriebenem Rückstoß (proportional zu fehlenden HP), Greif-/Wurfsystem, aufhebbaren/werfbaren Gegenständen inklusive explosiven Fässern, individuellen Spezialfähigkeiten, überarbeiteten Charaktermodellen/Arenen und nahtloser Unterstützung von Spieler- vs. KI-Steuerung.

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
- [x] **D. Aufhebbare & werfbare Arenaobjekte + Explosivfässer**:
  - 4 Objekttypen: Leichte Kiste (Light Crate), Schwerer Stein (Heavy Rock), Holzfass (Barrel), Explosiv-Fass (TNT Barrel mit AoE-Detonation).
  - Explosivfässer explodieren bei Feindkontakt, Bodenaufprall nach Wurf oder bei gezieltem Angriff eines Kämpfers.
  - Eingabepriorität: Objekt aufheben hat Vorrang bei räumlicher Nähe, sonst Gegner-Greifen.
  - Physikalische Wurfsimulation auf der Kampfebene (Z=0) mit Trägheit, Flugbahn, Geschwindigkeitsdämpfung, Tunneling-Schutz und automatischem Plattform-Respawn.
  - 3D-Meshes und PBR-Materialien in `main.gd` mit prozeduraler Holzmaserung, Rissstein, Eisenreifen, Gefahrenstreifen und Zünder-Glow.
- [x] **E. PBR-Skins aller 11 Charaktere überarbeitet**:
  - Generierte & eingebundene Albedo-, Normal- und Emissions-Texturen für: Valkyrie, Ignis Drake, Cyber Anubis, Void Specter, Phoenix Empress, Son Goku, Sub-Zero, Pain, Monkey D. Ruffy, Ninja und Golem in `godot/scripts/fighter_view.gd`.
  - Animations-Aliasing in `fighter_view.gd` für `Attack`, `Throw`, `Grab`, `Carrying`, `Grabbed`.
- [x] **F. Individuelle Spezialfähigkeiten**:
  - Schattenninja: Raijin Dash (schneller elektrischer Klingenvorstoß)
  - Lavagolem: Magma Quake (schwerer Bodenschlag mit Schockwelle)
  - Eisninja / Sub-Zero: Kori Ice Shard (Eisprojektil mit Verlangsamungseffekt)
  - Pain: Shinra Tensei (radialer Abstoßungsimpuls)
  - Ruffy: Gum-Gum Pistol (Reichweiten-Faustschlag)
  - Son Goku: Ki Blast / Kaio-ken Burst
- [x] **G. Arena-Überarbeitung & Vergrößerung**:
  - Spielfläche erweitert: Hauptbühne `STAGE_LEFT = -5.15`, `STAGE_RIGHT = 5.15`, Blast Zones `-9.5` bis `+9.5`.
  - Monumentale Kolosseum-Kolonnade mit 6 Säulen, Zinnen, Architrav und lodernden Feuerschalen/Fackeln.
  - Kampffeld lesbar freigestellt mit Kontrast und Kantenlicht.
- [x] **H. Steuerung & Oberfläche**:
  - HUD mit 3 Leben (Stocks `● ● ●`), Lebenspunkten, Spezial-Status, dynamischen Ring-Out-Meldungen und interaktivem Controls-Panel.
- [x] **I. Umfassende Testsuite (100% grün)**:
  - `res://tests/test_game.gd`: 36 von 36 Tests bestanden.
  - `res://scripts/test_grab_and_items.gd`: Alle Knockback-, Grab/Throw- und Item-Tests bestanden.
  - `res://scripts/test_explosive_barrel.gd`: Wurf- & Detonations-Mechanik bestanden.
  - `res://scripts/test_smash_mechanics.gd`: Alle Plattform- und Stock-Tests bestanden.
  - `res://scripts/test_all_playable.gd`: Alle 11 Charaktere spielbar validiert.

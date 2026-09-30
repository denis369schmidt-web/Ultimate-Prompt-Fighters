# Character Matrix: Prompt Fighter Ultimate – eigene Helden

Alle Figuren sind eigene Erfindungen. Werte, Movesets und Finisher stehen in `godot/scripts/fighter_kits.gd`,
Signatur-Mechaniken in `godot/scripts/signatures.gd`, das Aussehen in `godot/scripts/hero_gear.gd`.
Das Gesamt-Roster (49 Karten) listet `docs/ROSTER_INVENTORY.md`.

## Die 16 Helden mit generiertem Aussehen

| ID | Name | Titel | Signatur-Mechanik | Aussehen (im Code erzeugt) |
|---|---|---|---|---|
| `kairo` | KAIRO | Sturmmönch | Solar-Kanone (Ladestrahl) | Sonnen-Heiligenschein mit Strahlen, leuchtende Handgelenkringe, Gebetskette, aufsteigende Aura |
| `varakh` | VARAKH | Scharlachfürst | Nova-Strahl (Salve) | Klingenkrone, Wappen-Schulterplatten, Scharlach-Umhang, Goldfunken |
| `xylar` | XYLAR | Leerenkaiser | Supernova (wachsende Kugel) | Kreisende Kristallsplitter, schwarze Hörner, Runen-Schwebescheibe, Nova-Kugel beim Laden |
| `glaciem` | GLACIEM | Frostassassine | Eissplitter (Einfrieren) | Eiskristall-Schultern, Kristall-Diadem, Frostnebel aus den Händen |
| `oryn` | ORYN | Schwerkraftprophet | Singularität / Abstoßung | Drei gegenläufige Runenringe, Schwerkraft-Orbs um die Hände, sinkende Aura |
| `tobi` | TOBI | Federfaust | Schleuderfaust (Trommelfeuer) | Kupfer-Federspulen an den Unterarmen, Stirnband mit Bändern |
| `jubei` | JUBEI | Windklinge | Sturmschnitt (Mehrfach-Dash) | Langer Windschal, zwei gekreuzte Klingen am Rücken, Windwirbel |
| `ren` | REN | Kirschkriegerin | Blütenwirbel (Doppelgänger) | Haarschleifen, treibende Blütenblätter, Blütenwirbel in der Hand |
| `amethya` | AMETHYA | Donnerhexe | Amethystblitz (Spur-Dash) | Knisternde Blitzbögen an den Armen, Amethyst-Diadem, schwebende Kristalle |
| `bruno` | BRUNO | Einschlag-Held | Meteorfaust (Ein-Schlag) | Schwere Einschlag-Gauntlets mit glühenden Knöcheln, Stirnband |
| `hikaru` | HIKARU | Glutklinge | Morgenrotschnitt (Wirbel) | Seilkragen mit Glutknoten, Umhang, Laterne, Klinge an der Hüfte, Glut |
| `zip` | ZIP | Blitzkurier | Turbo-Sprint (Dash) | Düsenstiefel mit Flammen, Visier, Kopfflossen, Blitz-Emblem, Tempospur |
| `raiga` | RAIGA | Donnerfaust | Sternschlag (Konter) | Ring aus Donnertrommeln, Faustringe, Stern-Siegel am Boden beim Kontern |
| `albion` | ALBION | Silberwyrm | Sturmstrahl (Strahl) | Silberne Membranflügel, Wyrm-Hörner, Atem-Glühen beim Laden |
| `pyrax` | PYRAX | Glutwyvern | Glutsturm (Feuerball) | Glutflügel mit Adern, Hörner, Schwanz mit Flammenspitze, Glut |
| `lepora` | LEPORA | Mondjägerin | Mondpfeil (durchbohrend) | Mond-Diadem, Köcher mit Leuchtpfeilen, Mondbogen, Glühwürmchen |

Alle Helden reagieren auf den Kampf: Glühen und Drehung steigen beim Aufladen, Jets und Tempospur beim Sprint,
kurzer Aufblitz-Effekt bei Treffern (Shader-Parameter `flash`/`charge`).

## Ausgewogenheit
- Werte je Figur: `values` in `prompt_interpreter.gd` (5 Werte, Summe ≈ 100), Physik und Moves in `fighter_kits.gd`.
- Balance-Tests: `tests/test_kits.gd`, `tests/test_combat_plus.gd`, `tests/test_roster.gd`.

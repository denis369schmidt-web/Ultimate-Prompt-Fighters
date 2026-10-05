# Testbericht – Godot-Migration

## Aktueller Lauf (2026-10-05)

Befehl je Suite: `godot --headless --path godot -s tests/test_<suite>.gd`, Ergebnis in `PFU_TEST_SUMMARY`.

| Suite | Bestanden | Fehlgeschlagen |
|---|---|---|
| adventure | 29 | 0 |
| bosses | 132 | 0 |
| combat_plus | 100 | 0 |
| divina | 55 | 0 |
| fun | 24 | 0 |
| game | 42 | 0 |
| kits | 374 | 0 |
| legends | 19 | 0 |
| mechanics | 36 | 0 |
| progression | 26 | 0 |
| rewards | 58 | 0 |
| roster | 266 | 0 |
| saga | 48 | 0 |
| shop | 36 | 0 |
| store | 27 | 0 |
| story | 41 | 0 |
| touch | 30 | 0 |
| **Summe** | **1343** | **0** |

Stand nach Schritt 13 (Kämpfer-Pakete 4–6). `test_kits` prüft jetzt 43 Kits: Profile, Physik, vollständige Movesets, exklusive Signaturen, eindeutige Finisher-Codes (auch vierstellige) und jede neue Mechanik auf dem echten Kampfkern – Feueratem (Mehrfachtreffer, Schweben), Wiedergeburt (Heilung, Abklingzeit), Seelenwaage (Schaden wächst mit Prozenten), Kriegshorn (Wurf, Rüstung), kreisendes Fuchsfeuer (Kontakt, Schleudern), Raketensalve (zielsuchend, Explosion), Schneesturm (folgt, Hagel, Einfrieren), Pfeilregen (7 Pfeile), Seelenernte (Sog, Lebensraub), Dornenhecke, Wurzelfessel (Vorwarnung, Festhalten), Stampede (Tempo, Rüstung), Astralfluch (+Schaden), Knochenkerker (Festhalten, Platzen), Giftwolke (folgt); KI trifft mit jedem Kit. Sichtprüfung: `tests/render_kits.gd` für alle 21 Kämpfer der Pakete 4–6.

## Früherer Lauf (2026-09-30)

Befehl je Suite: `godot --headless --path godot -s tests/test_<suite>.gd`, Ergebnis in `PFU_TEST_SUMMARY`.

| Suite | Bestanden | Fehlgeschlagen |
|---|---|---|
| game | 42 | 0 |
| mechanics | 36 | 0 |
| combat_plus | 100 | 0 |
| roster | 148 | 0 |
| story | 41 | 0 |
| progression | 26 | 0 |
| kits | 142 | 0 |
| bosses (neu) | 34 | 0 |
| **Summe** | **569** | **0** |

Stand nach Schritt 9. `test_bosses.gd`: kein Friendly Fire im 2 gegen 2, jeder Boss (Lebensleiste, mehr Helden = mehr Leben,
schwebt, kein Knockback, mindestens 3 Angriffsmuster mit Vorwarnung, verletzt Helden), Phase 2, Sieg der Helden,
Sieg des Bosses (alle Helden raus / Zeit), KI-Helden kämpfen gegen den Boss, Menüablauf (Team-Modus-Knopf,
3-gegen-1-Stärkung, Boss-Menü, Boss-Arena, Engelkörper, Boss-Rush weiter zu Ophaniel, zurück zur normalen Arena).

`test_kits.gd` prüft auf dem echten Kampfkern: Kit-Profile und Physik (Sprunghöhe Ninja > Warrok), vollständige eigene
Movesets, exklusive Signaturen und eindeutige Finisher-Codes, Eingabe jedes Finisher-Codes, Mal + Blitzschlag,
Speerwurf/Rückruf/Fangen, Lavapfütze + Glut + Kernschmelze, Enterhaken/Pistole/Kanone, Schildwall (Block, Reflexion,
Rücken offen), Iaido, Titanensprung (Boden ja, Luft nein), Rüstung, Down-Specials, KI trifft mit jedem Kit.
Angepasste Alt-Tests: Schildtest nutzt die Schildgröße des Kämpfers, Fast-Fall-Test startet über freier Fläche,
Kontertest wartet auf die aktive Haltung.

Gerenderte Prüfung: `tests/render_kits.gd` (Kampf + Finisher aller 7 Kit-Kämpfer) ohne Skriptfehler.

---

Datum: 2026-09-18. Engine: Godot 4.7.2 stable (ed1daf0bf). Aktiver Code in `godot/`; keine Python-Nachbildung als Nachweis für diesen Build.

## Automatisierte Engine-Tests

Befehl: `godot --headless --path godot --script res://tests/test_game.gd`.
Ergebnis: **32 bestanden, 0 fehlgeschlagen**, Exitcode 0. Maschinenlesbare Einzelprüfungen in `godot-tests.json`.

Geprüft wurden:

- Unabhängige Prompts, unterschiedliche Skelettfamilien, reproduzierbare Seeds über Spielerslots.
- 1.000 Eingabefälle einschließlich leer, null, Überlänge und übertriebener Stärkeangaben; exakt 100 Punkte, Grenzen und kompatible Module.
- Angriffsannahme, Cooldown-/Pending-Sperre, begrenzter Einzelschaden, keine unbeabsichtigten Folgetreffer, Fehlschlag außerhalb der Reichweite.
- Siege beider Spieler, Spezialangriff, simultaner Doppel-KO, Timeout nach normiertem Restleben und Neustart.
- Identische Befehlssequenzen ergeben in manuellem und autonomem Modus identische Zustände.
- 30 autonome Matches beendet, 691 Treffer. Ergebnis: Ninja 5, Golem 25, Remis 0.
- Arenagrenzen und gegenseitige Körperbegrenzung.
- Importierte GLBs: je 18 Bones und sieben Animationen (Idle, Move, LightAttack, SpecialAttack, HitReact, Defeat, Victory).
- Getrennte Bewegungsaktionen sowie F/G/K/L über die GDScript-Eingaberouten.
- Auswahl-, Agentenstart- und Neustartrouten der tatsächlichen Hauptszene.

Die 30 Matches sind eine kleine deterministische Stichprobe, kein statistischer Fairnessnachweis. Die Golem-Dominanz muss vor Ausbau der Variantenbibliothek untersucht werden.

## Windows-Export und echter Renderlauf

`scripts/Build-Windows.ps1` erfolgreich ausgeführt: Import, Tests, offizieller x86_64-Releaseexport und Lizenzhinweise.

Export: `builds/windows/PromptFighterUltimate.exe` mit `PromptFighterUltimate.pck`.
Echter Start dieses exportierten Builds auf Intel UHD Graphics mit OpenGL 3.3 Compatibility.

```
PFU_RENDER_ROUND_COMPLETE 1 hits=23
PFU_RENDER_ROUND_COMPLETE 1 hits=46
PFU_RENDER_SMOKE_OK {"hits":46,"restarts":1}
```

Zwei vollständige gerenderte Runden, ein echter Neustart. `1` ist der nullbasierte Gewinnerindex, also Spieler 2. Log: `godot-build-smoke.log`. Darin keine Fehler oder Warnungen. Im Test gibt es einen expliziten Timeout statt endloser Wiederholung.

## Visuelle Prüfung

Echte Viewport-Aufnahmen, direkt aus dem laufenden Godot-Spiel:

- `screenshots/godot-selection.png`: zwei getrennte Promptfelder und Modusauswahl.
- `screenshots/godot-fight.png`: aus dem exportierten Build; Arena, beide Figuren, HP-/Cooldown-HUD, Timer und Tastenhilfe.
- `screenshots/godot-result.png`: Rundenende mit Ergebnis und Neustartoption.

Geprüft: GLB-Maßstab, sichtbare Figuren/Arena, Materialfarben, Kameraausschnitt und UI-Lesbarkeit. Ein Überlauf des Fußbereichs und die Rundung der maximalen HP-Anzeige wurden korrigiert. Innenabstände der HP-Füllung wurden entfernt, damit kleine Restwerte nicht künstlich breiter erscheinen. Kamera und Ausrichtung wurden angepasst.

## Korrigierte technische Fehler

- Fehlende neutrale Knochenkanäle zwischen Blender-Actions: Export ergänzt sie, damit Posen nicht unbeabsichtigt übernommen werden.
- Erste Headless-Tests meldeten vier Audio-Objektleaks: Dummy-Audiowiedergabe entfällt bei Headless; Audioplayer werden beim Verlassen gestoppt. Wiederholung ohne Warnung/Fehler bestanden.
- Smoke-Test zählte den Neustart zunächst anhand der Zeit statt abgeschlossener Runden: jetzt nur über tatsächliche Finish-Ereignisse und zwei volle Runden.
- Tests schreiben keine gespeicherten Benutzerprompts mehr.

## Native Bedienung – offen

Computer-Use-Fensterliste erkannte das tatsächliche Spiel. Die Aktivierung schlug fehl; bei erneuter Zustandserfassung erschien der Windows-Sperrbildschirm. Daraufhin keine weiteren Windows-Eingaben.

Daher sind physische Maus-/Tastaturtests nicht bestanden oder behauptet. Die automatisierten Engine-Eingabetests ersetzen diese Abnahme nicht vollständig. Nach Entsperren testen: beide Prompts, A/D und Pfeile, F/G/K/L, Treffer, ESC, R und Auswahl.

## Weitere offene Qualitätsprüfungen

- Vollständige Animationsprüfung auf Bodenkontakt, Gelenk-/Ausrüstungsüberschneidungen und sichtbaren Angriffs-/Trefferzeitpunkt.
- Menschliche Hörprüfung, gemeinsame Tastatur mit möglichem Hardware-Ghosting.
- Größere Balancing-Stichprobe, gespiegelte Startseiten, Fähigkeitssynergien; Technik-Attribut ausarbeiten.
- Windows-Framerate/Frametimes auf realer Hardware quantitativ messen. Kein 60-FPS-Nachweis.
- Android-Build und Gerätetests, Touchsteuerung, LODs.
- Keine Unreal-Kompilierung behauptet. Historische Blender-/Unreal-Referenzprüfungen in `legacy-unreal/TEST_REPORT.md`.

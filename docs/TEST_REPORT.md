# Testbericht – Godot-Migration

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

# Prompt Fighters Ultimate – Hinweise für Claude Code

@AGENTS.md

## Projekt in Kürze
Smash-/Mortal-Kombat-artiges 3D-Kampfspiel in **Godot 4.7.2** (GDScript), Projekt in `godot/`.
49 Kämpfer, 19 Bosse, zwei Storykampagnen (Göttliche Prüfung, Saga „Der Riss zwischen den Welten“),
Shop mit 23 Arenen, bis zu 4 Spieler, Xbox-Pad und Touch.

## Befehle
- Godot: `%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe`
- Tests (aus `godot/`): `<godot> --headless --path . -s tests/test_<suite>.gd`, Ergebnis in der Zeile `PFU_TEST_SUMMARY`
  (`test_base.gd` ist keine Suite). Alle Suiten nacheinander laufen lassen, nicht parallel (Zeitlimits).
- Neue Assets: `<godot> --headless --path . --import`
- Sichtprüfung: `tests/render_heroes.gd`, `tests/render_portraits.gd`, `tests/render_title.gd`, `tests/render_arenas.gd`,
  `tests/render_kits.gd --only=<family>` (nicht headless, `-- --out=<ordner>`).

## Regeln
- `combat.gd`, `main.gd`, `hero_gear.gd`, `fighter_view.gd` haben CRLF-Zeilenenden: beim Patchen mit Python `newline=''` verwenden.
- Keine fremden Marken/Figuren (test_roster prüft). Keine Assets mit unklarer Lizenz: Herkunft und Lizenz in
  `ASSET_LICENSES.md` bzw. `docs/AUDIO_LICENSES.md` eintragen; CC-BY-Assets in die Credits (`main.gd _fill_credits`, `story_saga.gd CREDITS`).
- Fremdmaterial liegt in `_quarantine_ip/` (gitignored), nie wieder einbinden.
- Eigene Helden: Mixamo-Körper + Ausrüstung im Code (`scripts/hero_gear.gd`, Körper in `fighter_view.gd MIXAMO_BODIES`).
- Pro Kämpfer: Kit (`fighter_kits.gd`), Signatur (`signatures.gd` / `combat.gd _sig_activate`), Finisher (`main.gd _finisher_variant`), Tests in `tests/test_kits.gd`.
- Commit/Push nur auf ausdrücklichen Wunsch. Changelog: `docs/CHANGELOG.md`.

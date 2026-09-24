# Arbeitsregeln für Prompt Fighter Ultimate

## Prioritäten

1. Zuerst den lokalen Windows-Kampf vollständig spielbar machen.
2. Beide Spieler-Prompts immer unabhängig interpretieren; nie zusammenführen.
3. Manuelle und autonome Steuerung müssen dieselben Kampfdaten und Trefferregeln verwenden.
4. Nach wesentlichen Änderungen Tests ausführen und `docs/STATUS.md` sowie `docs/TEST_REPORT.md` aktualisieren.

## Technische Leitplanken

- Aktive Engine ist seit Nutzerfreigabe Godot (GDScript), Projekt in `godot/`. `game/` enthält den unkompilierten Unreal-Altstand und wird nicht mehr als aktives Produkt beworben.
- Engine-Tests müssen den tatsächlich verwendeten GDScript-Kampfkern prüfen, keine separate Python-Nachbildung.
- Datengetrennte Systeme für Definition, Module, Attribute, Fähigkeiten, Kampfzustand, Eingabe, KI, UI und Speicherung.
- Prompt-Text niemals ausführen. Keine Geheimnisse in Quellcode, Logs, Builds oder Git.
- Für Ninja und Golem dürfen getrennte Skelettfamilien verwendet werden.
- Animationen des ersten Meilensteins ohne unkontrollierte Root Motion.
- Mobile Zielplattform berücksichtigen: einfache Materialien, begrenzte Texturen/Partikel, LODs und einfache Kollision.
- Keine Online-, Monetarisierungs- oder Store-Arbeit vor Abschluss des lokalen Prototyps.

## Dateihygiene

- Keine Unreal-Verzeichnisse `Binaries/`, `DerivedDataCache/`, `Intermediate/`, `Saved/` oder `.vs/` versionieren.
- Große `.blend`, `.fbx`, `.uasset` und Builds nur mit bewusst eingerichteter LFS-/Artefaktstrategie versionieren.
- Bestehende Nutzeränderungen nicht überschreiben oder zurücksetzen.

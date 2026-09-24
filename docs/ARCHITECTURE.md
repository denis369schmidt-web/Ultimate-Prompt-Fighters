# Unreal-Architektur

- `PFUFighterDefinition` – datengetriebene Definition und Soft References
- `PFUPromptInterpreter` – lokale, deterministische Promptauswertung ohne API
- `PFUCharacterAssembler` – visuelle Modulzusammenstellung und Fallback-Geometrie
- `PFUFighterCharacter` – Kampfebene, Bewegung und Charakterzustand
- `PFUCombatComponent` – gemeinsame Schaden-, Reichweiten- und Abklingregeln
- `PFUAIController` – autonome Entscheidung; ruft dieselben Angriffe wie Spielerinput auf
- `PFUPlayerController` – zwei getrennte Tastaturbelegungen für zwei Kämpfer
- `PFUMatchGameMode` – Spawn, Timer, Sieg/Niederlage/Unentschieden und Neustart
- `PFUCombatCamera` – hält beide Kämpfer dynamisch im Bild
- `PFUMatchWidget` – zwei Promptfelder, Startmodi, Lebensanzeigen, Timer und Ergebnis

Die manuelle und autonome Variante unterscheiden sich nur in der Quelle der Befehle. Beide laufen durch `PFUFighterCharacter` und `PFUCombatComponent`.

Prompttext wird bereinigt, auf 512 Zeichen begrenzt und ausschließlich verglichen/gehasht. Er wird weder als Code noch als Befehl ausgeführt.


# Character Remixer — Dokumentation

## Übersicht

Der Character Remixer generiert aus einem Freitext-Prompt einen vollständig spielbaren, balancierten Kämpfer.
Er kombiniert modulare Komponenten (Body, Element, Ability) und normalisiert alle Attribute auf ein festes Budget.

## API

```gdscript
# Charakter generieren
var profile: Dictionary = CharacterRemixer.remix_character(prompt, player_slot, seed_val)

# Charakter validieren
var result: Dictionary = CharacterRemixer.validate(profile)
# result.valid: bool, result.errors: Array[String]
```

## Modulares System

### Body-Module (11)

| ID | Familie | Gewicht | Basis-HP | Schwerpunkt |
|----|---------|---------|----------|-------------|
| ninja | Shinobi Exosuit | 0.95 | 100 | Speed/Technik |
| golem | Magma Core Colossus | 1.35 | 130 | Vitalität/Power |
| valkyrie | Aether Paladin Plate | 1.05 | 110 | Ausgewogen |
| dragon | Draconic Scale Carapace | 1.20 | 120 | Power/Vitalität |
| goku | Martial Arts Gi | 1.00 | 115 | Power/Speed |
| subzero | Lin Kuei Cryo Tunic | 1.05 | 112 | Ausgewogen |
| pain | Akatsuki Shroud | 1.00 | 110 | Power/Technik |
| luffy | Straw Hat Brawler | 0.95 | 115 | Power/Speed |
| sonic | Blue Blur Quills | 0.85 | 95 | Speed dominant |
| akaza | Soryu Demon Physique | 1.02 | 118 | Power/Speed |
| blue_eyes | Platinum Dragon Wings | 1.30 | 125 | Power/Vitalität |

### Elemente (5)

| Element | Farbe | Bonus-Stat (+4) | Debuff-Stat (-2) | SFX |
|---------|-------|-----------------|------------------|-----|
| fire | 🔴 #ff5522 | Power | Speed | Lava |
| ice | 🔵 #4ae0ff | Defense | Power | Block |
| lightning | 🟡 #ffe838 | Speed | Vitalität | Electric |
| shadow | 🟣 #9944ee | Technik | Defense | Hit |
| holy | ⚪ #ffffff | Vitalität | Speed | Hit |

### Abilities (6)

| ID | Name | Typ | Schaden | Push | Reichweite | Cooldown | Kosten |
|----|------|-----|---------|------|------------|----------|--------|
| beam | Energy Beam | beam | 22 | 0.40 | 3.4 | 4.5s | 40 |
| dash | Supersonic Dash | electric_dash | 18 | 0.48 | 3.2 | 3.8s | 40 |
| blast | Gravity Blast | gravity_wave | 20 | 0.65 | 3.4 | 4.2s | 40 |
| slow | Cryo Freeze Surge | ice_slow | 16 | 0.32 | 3.3 | 4.0s | 40 |
| barrage | Rapid Martial Barrage | compass_needle | 24 | 0.38 | 3.0 | 4.6s | 40 |
| elastic | Elastic Cannon | gum_gum_pistol | 21 | 0.52 | 3.4 | 4.2s | 40 |

## Stat-Budget

- **Gesamtbudget**: 100 Punkte
- **Attribute**: Vitalität, Power, Defense, Speed, Technik
- Element-Bonus wird aufgerechnet (+4 auf Bonus-Stat, -2 auf Debuff-Stat)
- Nach Anwendung wird auf exakt 100 normalisiert
- Standard-Angriff kostet 20, Spezial kostet 40 → Gesamt 60 (≤ 60 erlaubt)

## Prompt-Analyse Pipeline

1. **Body-Erkennung**: Schlüsselwörter → Body-Modul (z.B. "drache" → dragon, "goku" → goku)
2. **Element-Erkennung**: Schlüsselwörter → Element (z.B. "eis" → ice, "blitz" → lightning)
3. **Ability-Erkennung**: Schlüsselwörter → Fähigkeit (z.B. "beam" → beam, "dash" → dash)
4. **Standard-Angriff**: Wird aus Body-Daten berechnet (Reichweite, Windup, Schaden)
5. **Stat-Normalisierung**: Budget-Balancierung auf exakt 100
6. **Profil-Zusammenbau**: Komplettes spielbares Profil-Dictionary

## Output-Format

```gdscript
{
    "name": "ICE NINJA",
    "family": "ninja",
    "element": "ice",
    "color": Color("4ae0ff"),
    "weight": 0.95,
    "health": 90.0,
    "speed": 4.56,
    "stats": {"vitality": 16, "power": 18, "defense": 18, "speed": 28, "technique": 20},
    "standard": { ... },  # Kompletter Angriff
    "special": { ... },   # Komplette Spezialattacke
    "modules": ["body_ninja", "mat_ice", "ability_beam"],
    "prompt": "Schneller Eis-Ninja mit Beam-Attacke",
    "slot": 0,
    "is_remix": true
}
```

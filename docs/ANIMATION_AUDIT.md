# Animation & State Machine Audit

## State Machine

### States

| State | Beschreibung | Kann angreifen | Kann sich bewegen | Kann blocken |
|-------|-------------|----------------|-------------------|--------------|
| Ready | Bereit, idle | ✓ | ✓ | ✓ |
| Attack | Angriff wird ausgeführt (3-Phasen) | ✗ | ✗ | ✗ |
| HitStun | Getroffen, betäubt | ✗ | Nur DI (65% Stun) | ✗ |
| Grab | Greif-Versuch aktiv | ✗ | ✗ | ✗ |
| Grabbed | Wird gehalten | ✗ | ✗ | ✗ |
| Carrying | Hält Gegner/Item | Wurf statt Angriff | ✓ | ✗ |
| Throw | Wirft Gegner | ✗ | ✗ | ✗ |
| Defeated | K.O. | ✗ | ✗ | ✗ |

### State-Übergänge

```
Ready ──→ Attack (Standard/Spezial)
       ──→ Grab (Greifen)
       ──→ Block (Block-Taste halten)
       ──→ HitStun (getroffen werden)

Attack ──→ Ready (3-Phasen-Pipeline abgeschlossen)
       ──→ HitStun (getroffen während Angriff → pending wird gelöscht)

HitStun ──→ Ready (Stun-Timer abgelaufen)

Grab ──→ Carrying (Griff erfolgreich)
     ──→ Ready + HitReact (Griff verfehlt, 0.25s Recovery)

Carrying ──→ Throw (Wurf ausgeführt)
         ──→ Ready (Breakout nach Timeout)

Grabbed ──→ Ready (Breakout oder Wurf beendet)

Throw ──→ Ready (pose_time abgelaufen)

Defeated ──→ (Spiel vorbei)
```

## 3-Phasen-Angriffspipeline

### Phase 1: Windup (Vorbereitungsanimation)
- Dauer: `ability.windup` Sekunden
- Keine Hitbox aktiv
- Angreifer ist verwundbar
- Kann durch HitStun unterbrochen werden → pending wird gelöscht

### Phase 2: Active (Hitbox aktiv)
- Dauer: `ability.active` Sekunden
- Hitbox-Prüfung (einmalig pro Active-Phase)
- Kontakt-Auflösung: Schaden, Knockback, Hitstop
- Explosive Items können getroffen werden

### Phase 3: Recovery (Erholungsphase)
- Dauer: `ability.recovery` Sekunden
- Keine Hitbox
- Angreifer verwundbar, kann nicht canceln
- Pose wechselt zu "Idle"
- Nach Ablauf: State → Ready, pending gelöscht

## Pose-System

| Pose | Trigger | Nutzung |
|------|---------|---------|
| Idle | Default / nach Aktion | Normalzustand |
| Attack | Standard-Angriff Windup+Active | Nahkampf-Animation |
| SpecialAttack | Spezial-Angriff Windup+Active | Spezial-Animation |
| Block | Block-Taste gehalten | Verteidigungshaltung |
| HitReact | Treffer erhalten | Getroffene Reaktion |
| Victory | Kampf gewonnen | Siegespose |
| Defeat | Kampf verloren | Niederlagenpose |

## Audit-Ergebnisse (2026-09-25)

Alle 14 Charaktere bestehen den automatisierten State Machine Audit:

| Charakter | Ready→Atk | Atk→Ready | Hit→Ready | Blk→Ready | No Stuck |
|-----------|-----------|-----------|-----------|-----------|----------|
| NINJA | ✓ | ✓ | ✓ | ✓ | ✓ |
| GOLEM | ✓ | ✓ | ✓ | ✓ | ✓ |
| VALKYRIE | ✓ | ✓ | ✓ | ✓ | ✓ |
| DRAGON | ✓ | ✓ | ✓ | ✓ | ✓ |
| GOKU | ✓ | ✓ | ✓ | ✓ | ✓ |
| SUBZERO | ✓ | ✓ | ✓ | ✓ | ✓ |
| PAIN | ✓ | ✓ | ✓ | ✓ | ✓ |
| LUFFY | ✓ | ✓ | ✓ | ✓ | ✓ |
| SONIC | ✓ | ✓ | ✓ | ✓ | ✓ |
| AKAZA | ✓ | ✓ | ✓ | ✓ | ✓ |
| BLUE_EYES | ✓ | ✓ | ✓ | ✓ | ✓ |
| ANUBIS | ✓ | ✓ | ✓ | ✓ | ✓ |
| SPECTER | ✓ | ✓ | ✓ | ✓ | ✓ |
| PHOENIX | ✓ | ✓ | ✓ | ✓ | ✓ |

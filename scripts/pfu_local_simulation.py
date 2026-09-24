"""Engine-independent deterministic reference simulation for PFU combat rules."""

from __future__ import annotations

from dataclasses import dataclass, field
import random
import re

ATTRIBUTE_MIN = 8
ATTRIBUTE_MAX = 36
ATTRIBUTE_BUDGET = 100
ABILITY_BUDGET = 60


@dataclass(frozen=True)
class Stats:
    vitality: int
    power: int
    defense: int
    speed: int
    technique: int

    @property
    def total(self) -> int:
        return self.vitality + self.power + self.defense + self.speed + self.technique


@dataclass(frozen=True)
class Ability:
    name: str
    damage: float
    range: float
    cooldown: float
    knockback: float
    budget: int


@dataclass(frozen=True)
class Profile:
    prompt: str
    player_index: int
    seed: int
    archetype: str
    element: str
    stats: Stats
    standard: Ability
    special: Ability


def sanitize(prompt: object) -> str:
    value = prompt if isinstance(prompt, str) else ""
    value = "".join(ch for ch in value[:512] if ch.isprintable()).strip()
    return value or "balanced unknown fighter"


def stable_seed(prompt: str, player_index: int) -> int:
    value = 2166136261
    for char in sanitize(prompt).lower():
        value ^= ord(char)
        value = (value * 16777619) & 0xFFFFFFFF
    value ^= ((player_index + 1) * 0x9E3779B9) & 0xFFFFFFFF
    return value & 0x7FFFFFFF


def _contains(text: str, words: tuple[str, ...]) -> bool:
    return any(word in text for word in words)


def interpret(prompt: object, player_index: int) -> Profile:
    clean = sanitize(prompt)
    lower = clean.lower()
    seed = stable_seed(clean, player_index)
    rng = random.Random(seed)
    if _contains(lower, ("ninja", "schnell", "fast", "assassin", "shadow")):
        archetype, values = "agile", [17, 19, 13, 31, 20]
    elif _contains(lower, ("golem", "panzer", "armor", "guardian", "tank")):
        archetype, values = "guardian", [28, 18, 30, 10, 14]
    elif _contains(lower, ("brutal", "faust", "fist", "berserk")):
        archetype, values = "bruiser", [24, 30, 22, 11, 13]
    else:
        archetype = ("agile", "guardian", "bruiser", "mystic")[rng.randrange(4)]
        values = {
            "agile": [17, 19, 13, 31, 20], "guardian": [28, 18, 30, 10, 14],
            "bruiser": [24, 30, 22, 11, 13], "mystic": [18, 18, 14, 18, 32],
        }[archetype]
    for _ in range(8):
        source, target = rng.randrange(5), rng.randrange(5)
        if source != target and values[source] > ATTRIBUTE_MIN and values[target] < ATTRIBUTE_MAX:
            values[source] -= 1
            values[target] += 1
    stats = Stats(*values)
    if _contains(lower, ("blitz", "electric", "storm")): element = "electric"
    elif _contains(lower, ("lava", "feuer", "fire", "burn")): element = "fire"
    elif _contains(lower, ("eis", "ice", "frost")): element = "ice"
    elif _contains(lower, ("stein", "stone", "earth")): element = "stone"
    elif _contains(lower, ("wind", "air")): element = "wind"
    else: element = "shadow"
    standard = Ability(
        "heavy_jab" if archetype == "guardian" else "quick_strike",
        min(15.0, max(5.0, 5.0 + stats.power * 0.24)),
        min(180.0, max(90.0, 105.0 + stats.technique * 1.8)),
        min(0.9, max(0.38, 0.95 - stats.speed * 0.014)),
        min(190.0, max(90.0, 80.0 + stats.power * 3.0)), 20)
    special = Ability(
        f"special_{element}_{archetype}",
        min(30.0, max(14.0, 12.0 + stats.power * 0.36 + stats.technique * 0.1)),
        min(300.0, max(140.0, 135.0 + stats.technique * 3.1)),
        min(6.0, max(2.3, 4.8 - stats.speed * 0.045)),
        min(330.0, max(180.0, 150.0 + stats.power * 5.0)), 40)
    return Profile(clean, player_index, seed, archetype, element, stats, standard, special)


def validate(profile: Profile) -> bool:
    values = tuple(profile.stats.__dict__.values())
    abilities = (profile.standard, profile.special)
    return (
        profile.stats.total == ATTRIBUTE_BUDGET
        and all(ATTRIBUTE_MIN <= value <= ATTRIBUTE_MAX for value in values)
        and sum(ability.budget for ability in abilities) <= ABILITY_BUDGET
        and all(3.0 <= ability.damage <= 30.0 for ability in abilities)
        and all(0.3 <= ability.cooldown <= 6.0 for ability in abilities)
        and all(90.0 <= ability.range <= 300.0 for ability in abilities)
    )


@dataclass
class Fighter:
    profile: Profile
    x: float
    health: float = field(init=False)
    cooldowns: dict[str, float] = field(default_factory=dict)
    received_attack_ids: set[int] = field(default_factory=set)

    def __post_init__(self):
        self.health = 85.0 + self.profile.stats.vitality * 2.0

    def receive(self, ability: Ability, attack_id: int) -> float:
        if attack_id in self.received_attack_ids or self.health <= 0:
            return 0.0
        self.received_attack_ids.add(attack_id)
        multiplier = min(0.9, max(0.55, 1.0 - self.profile.stats.defense * 0.012))
        damage = min(30.0, max(3.0, ability.damage)) * multiplier
        self.health = max(0.0, self.health - damage)
        return damage


class Match:
    def __init__(self, prompt_one: object, prompt_two: object, mode: str = "manual"):
        self.prompts = (prompt_one, prompt_two)
        self.mode = mode
        self.time = 0.0
        self.remaining = 90.0
        self.attack_serial = 0
        self.restart()

    def restart(self):
        self.fighters = [Fighter(interpret(self.prompts[0], 0), -260.0), Fighter(interpret(self.prompts[1], 1), 260.0)]
        self.time = 0.0
        self.remaining = 90.0
        self.result = "fighting"

    def attack(self, attacker_index: int, special: bool = False) -> float:
        attacker = self.fighters[attacker_index]
        target = self.fighters[1 - attacker_index]
        ability = attacker.profile.special if special else attacker.profile.standard
        ready = attacker.cooldowns.get(ability.name, 0.0)
        if self.time < ready or abs(target.x - attacker.x) > ability.range or self.result != "fighting":
            return 0.0
        attacker.cooldowns[ability.name] = self.time + ability.cooldown
        self.attack_serial += 1
        damage = target.receive(ability, self.attack_serial)
        if target.health <= 0:
            self.result = f"player_{attacker_index + 1}_wins"
        return damage

    def step(self, seconds: float):
        self.time += seconds
        self.remaining = max(0.0, 90.0 - self.time)
        if self.remaining <= 0 and self.result == "fighting":
            health = [fighter.health for fighter in self.fighters]
            self.result = "draw" if abs(health[0] - health[1]) <= 0.01 else f"player_{1 if health[0] > health[1] else 2}_wins"

    def run_agents(self, max_steps: int = 2000) -> str:
        rngs = [random.Random(fighter.profile.seed) for fighter in self.fighters]
        for step_index in range(max_steps):
            if self.result != "fighting": break
            distance = abs(self.fighters[1].x - self.fighters[0].x)
            desired = min(fighter.profile.standard.range for fighter in self.fighters) * 0.78
            if distance > desired:
                for index, fighter in enumerate(self.fighters):
                    direction = 1.0 if index == 0 else -1.0
                    speed = min(520.0, max(280.0, 230.0 + fighter.profile.stats.speed * 8.0))
                    fighter.x += direction * min(speed * 0.1, max(0.0, (distance - desired) * 0.5))
            for index, rng in enumerate(rngs):
                self.attack(index, special=rng.random() < 0.28)
            self.step(0.1)
        return self.result


def demo() -> None:
    match = Match("blitzschneller Schattenninja mit elektrischen Klingen", "gepanzerter Lavagolem mit brennenden Faeusten", "autonomous")
    result = match.run_agents()
    print(f"PFU_SIMULATION_OK result={result} time={match.time:.1f}s health={[round(f.health, 1) for f in match.fighters]}")


if __name__ == "__main__":
    demo()

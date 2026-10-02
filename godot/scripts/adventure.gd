extends RefCounted
## Adventure: one fighter, an endless line of opponents. Every wave is a little harder (smarter AI,
## harder hits, heavier opponents), every fifth wave is a boss. Damage carries over between waves and
## only part of it heals. Score: waves cleared, speed, health left, combos, bosses. Records per
## fighter and overall are kept in progression.gd (`adventure`, `adventure_best`).
## main.gd runs the fights; this class only decides who comes next and keeps the score.

const Bosses = preload("res://scripts/bosses.gd")

const BOSS_EVERY := 5
const HEAL_SHARE := 0.35        # share of the damage healed after a won wave
const WAVE_TIME := 120.0        # seconds per wave; running out counts as a loss
const MAX_AI := 9

var family := ""
var preset: Dictionary = {}     # the player's roster card ({id, name, prompt})
var pool: Array = []            # possible opponents (roster cards)
var wave := 1
var score := 0
var damage := 0.0               # damage percent carried into the next wave
var kills := 0
var bosses := 0
var best_combo := 0
var running := false
var relic := false               # the fighter's legend relic: heals RELIC_HEAL more after every wave
const RELIC_HEAL := 0.15
const MILESTONE := 10           # every tenth wave pays coins and a chest
var last_gain := 0              # score of the last cleared wave
var last_opponent: Dictionary = {}
var rng := RandomNumberGenerator.new()

func start(player_preset: Dictionary, roster: Array, seed_v: int = -1) -> void:
	preset = player_preset
	family = str(player_preset.get("id", ""))
	pool = roster.filter(func(p): return str(p.get("id", "")) != family and str(p.get("id", "")) != "fusionskammer")
	wave = 1
	score = 0
	damage = 0.0
	kills = 0
	bosses = 0
	best_combo = 0
	last_gain = 0
	running = true
	if seed_v >= 0: rng.seed = seed_v
	else: rng.randomize()

func is_boss_wave(w: int = wave) -> bool:
	return w % BOSS_EVERY == 0

## Boss of a boss wave: heaven and hell take turns, each realm in order.
func boss_for(w: int = wave) -> String:
	var n: int = w / BOSS_EVERY - 1
	var realm: Array = Bosses.HEAVEN if n % 2 == 0 else Bosses.HELL
	return realm[(n / 2) % realm.size()]

## Next regular opponent: never the same twice in a row.
func next_opponent() -> Dictionary:
	if pool.is_empty(): return {}
	var pick: Dictionary = pool[rng.randi() % pool.size()]
	var tries := 0
	while pool.size() > 1 and str(pick.get("id", "")) == str(last_opponent.get("id", "")) and tries < 8:
		pick = pool[rng.randi() % pool.size()]
		tries += 1
	last_opponent = pick
	return pick

func ai_level(w: int = wave) -> int:
	return clampi(2 + (w - 1) / 2, 1, MAX_AI)

## Opponent buffs: harder hits and less knockback, growing slowly.
func power_mult(w: int = wave) -> float:
	return 1.0 + 0.06 * float(w - 1)

func kb_taken_mult(w: int = wave) -> float:
	return maxf(0.55, 1.0 - 0.035 * float(w - 1))

## A won wave: score, partial healing, next wave. Returns the score gained.
func win_wave(time_left: float, damage_now: float, combo: int) -> int:
	best_combo = maxi(best_combo, combo)
	var gain: int = 100 * wave + int(time_left * 3.0) + int(maxf(0.0, 150.0 - damage_now)) + combo * 15
	if is_boss_wave():
		gain += 500 + 100 * wave
		bosses += 1
	kills += 1
	score += gain
	last_gain = gain
	damage = maxf(0.0, damage_now * (1.0 - HEAL_SHARE - (RELIC_HEAL if relic else 0.0)))
	wave += 1
	return gain

func is_milestone(cleared: int) -> bool:
	return cleared > 0 and cleared % MILESTONE == 0

## The run is over (lost, time up or abandoned): stores the records. Returns true for a new best.
func finish(prog) -> bool:
	running = false
	var cleared: int = wave - 1
	var mine: Dictionary = prog.adventure.get(family, {"wave": 0, "score": 0, "runs": 0})
	var new_best := score > int(mine.get("score", 0)) or cleared > int(mine.get("wave", 0))
	mine["runs"] = int(mine.get("runs", 0)) + 1
	if score > int(mine.get("score", 0)): mine["score"] = score
	if cleared > int(mine.get("wave", 0)): mine["wave"] = cleared
	mine["combo"] = maxi(int(mine.get("combo", 0)), best_combo)
	prog.adventure[family] = mine
	if score > int(prog.adventure_best.get("score", 0)):
		prog.adventure_best = {"score": score, "wave": cleared, "family": family, "day": Time.get_unix_time_from_system() / 86400.0}
	prog.save_progress()
	return new_best

static func record_of(prog, fam: String) -> Dictionary:
	return prog.adventure.get(fam, {"wave": 0, "score": 0, "runs": 0, "combo": 0})

## Top fighters by score, for the record board.
static func leaderboard(prog, count: int = 5) -> Array:
	var rows: Array = []
	for fam in prog.adventure:
		var r: Dictionary = prog.adventure[fam]
		rows.append({"family": fam, "score": int(r.get("score", 0)), "wave": int(r.get("wave", 0))})
	rows.sort_custom(func(a, b): return a.score > b.score)
	return rows.slice(0, count)

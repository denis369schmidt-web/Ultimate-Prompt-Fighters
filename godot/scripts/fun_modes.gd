extends RefCounted
## Fun and come-back systems:
##   Mutators       – party rules for any fight (low gravity, giants, glass cannons, bomb rain, swaps …),
##                    chosen in OPTIONEN. "rule" mutators switch on a rule in combat.gd (sim.rules).
##   Daily challenge – one hand-picked fight per day (same for everyone on that day): fighter, opponents,
##                    two mutators and a goal. A streak of days pays more and more; day 7 gives a chest.
##   Weekly event   – every week another bonus (double XP, gold rush, mutator festival …).
##   Challenger     – after a won solo fight a surprise challenger may appear ("EIN HERAUSFORDERER!").
##   Comeback gift  – after three or more days away: a welcome-back present.
## Pure rules and data; main.gd runs the fights, progression.gd stores the state.

const MUTATORS := {
	"low_gravity": {"name": "MONDSPRUNG", "icon": "🌙", "text": "Kaum Schwerkraft: riesige Sprünge, lange Flugbahnen.",
		"phys": {"gravity": 0.45, "fast_fall": 0.6, "jump": 0.85}},
	"turbo": {"name": "TURBO", "icon": "⚡", "text": "Alle rennen und fliegen anderthalbmal so schnell.",
		"phys": {"run": 1.5, "air": 1.35}},
	"glass": {"name": "GLASKANONEN", "icon": "💥", "text": "Jeder Treffer zählt doppelt – Kämpfe sind kurz und brutal.",
		"power": 2.0},
	"heavy": {"name": "SCHWERGEWICHTE", "icon": "🪨", "text": "Alle fliegen nur halb so weit. Lange Schlachten.",
		"kb": 0.55},
	"giants": {"name": "RIESEN", "icon": "🗿", "text": "Alle sind riesig: stärker, schwerer, langsamer zu werfen.",
		"scale": 1.45, "power": 1.25, "kb": 0.75},
	"tiny": {"name": "WINZLINGE", "icon": "🐜", "text": "Alle sind winzig und fliegen weit.",
		"scale": 0.6, "kb": 1.35},
	"sudden_death": {"name": "SUDDEN DEATH", "icon": "☠", "text": "Alle starten mit 150 % Schaden. Ein Treffer kann entscheiden.",
		"damage": 150.0},
	"super_start": {"name": "VOLLE KRAFT", "icon": "🔥", "text": "Alle starten mit voller Super-Leiste.",
		"super": true},
	"bomb_rain": {"name": "BOMBENHAGEL", "icon": "💣", "text": "Alle paar Sekunden schlägt eine Bombe ein – der rote Kreis warnt vorher.",
		"rule": "bomb_rain"},
	"vampire": {"name": "BLUTDURST", "icon": "🩸", "text": "Wer trifft, heilt 40 % des Schadens, den er austeilt.",
		"rule": "vampire"},
	"swap": {"name": "PLATZTAUSCH", "icon": "🔀", "text": "Alle 15 Sekunden tauschen die Kämpfer die Plätze.",
		"rule": "swap"},
	"escalation": {"name": "ESKALATION", "icon": "📈", "text": "Jede Sekunde trifft härter – nach einer Minute doppelt so hart.",
		"rule": "escalation"},
	"item_rain": {"name": "GESCHENKREGEN", "icon": "🎁", "text": "Waffen und Power-ups fallen alle paar Sekunden vom Himmel.",
		"rule": "item_rain"},
}

const EVENTS := [
	{"id": "double_xp", "name": "DOPPEL-XP-WOCHE", "icon": "✨", "text": "Alle Kämpfe geben doppelte Erfahrung.", "xp": 2.0, "coins": 1.0},
	{"id": "gold_rush", "name": "GOLDRAUSCH", "icon": "🪙", "text": "Alle Kämpfe geben 50 % mehr Münzen.", "xp": 1.0, "coins": 1.5},
	{"id": "festival", "name": "MUTATOREN-FESTIVAL", "icon": "🎪", "text": "Die Tages-Herausforderung hat drei Mutatoren – und zahlt doppelt.", "xp": 1.25, "coins": 1.0, "daily_mult": 2.0, "daily_mutators": 3},
	{"id": "challengers", "name": "WOCHE DER HERAUSFORDERER", "icon": "⚔", "text": "Herausforderer erscheinen doppelt so oft.", "xp": 1.0, "coins": 1.2, "challenger": 2.0},
	{"id": "legends", "name": "LEGENDEN-WOCHE", "icon": "📜", "text": "Meisterschaft wächst schneller: anderthalbfache Erfahrung.", "xp": 1.5, "coins": 1.0},
]

const DAILY_GOALS := [
	{"id": "win", "text": "Gewinne den Kampf."},
	{"id": "fast", "text": "Gewinne in unter 60 Sekunden.", "time": 60.0},
	{"id": "flawless", "text": "Gewinne, ohne ein Leben zu verlieren."},
	{"id": "outnumbered", "text": "Gewinne allein gegen zwei."},
]
## Coins for the daily challenge by streak day (day 7 also gives a chest, then it starts over).
const DAILY_REWARD := [120, 150, 180, 220, 260, 320, 500]
const CHALLENGER_CHANCE := 0.18
const COMEBACK_DAYS := 3

static func mutator_text(ids: Array) -> String:
	var parts: Array = []
	for id in ids:
		if MUTATORS.has(id): parts.append("%s %s" % [MUTATORS[id].icon, MUTATORS[id].name])
	return "  ·  ".join(parts)

## Applies mutators to a running match (after begin_match). views: the fighter views (scale), may be empty.
static func apply(sim, views: Array, ids: Array) -> void:
	for id in ids:
		if not MUTATORS.has(id): continue
		var m: Dictionary = MUTATORS[id]
		if m.has("rule"): sim.rules[str(m.rule)] = true
		for k in range(sim.fighters.size()):
			var f: Dictionary = sim.fighters[k]
			if f.get("is_boss", false): continue
			var ph: Dictionary = m.get("phys", {})
			for key in ph:
				if f.phys.has(key): f.phys[key] = float(f.phys[key]) * float(ph[key])
			if m.has("power"): f.power_mult = float(f.get("power_mult", 1.0)) * float(m.power)
			if m.has("kb"): f.kb_taken_mult = float(f.get("kb_taken_mult", 1.0)) * float(m.kb)
			if m.has("damage"): f.damage_percent = maxf(float(f.damage_percent), float(m.damage))
			if m.get("super", false): f.super = float(load("res://scripts/combat.gd").MAX_SUPER)
			if m.has("scale") and k < views.size() and is_instance_valid(views[k]):
				views[k].scale = Vector3.ONE * float(m.scale)

## The week's event (same for everyone in that week).
static func event_of(day: int) -> Dictionary:
	return EVENTS[posmod(day / 7, EVENTS.size())]

## Today's challenge: player fighter, opponents, mutators and goal, all from the day's seed.
static func daily_challenge(day: int, presets: Array) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("pfu-challenge-%d" % day)
	var pool: Array = presets.filter(func(p): return str(p.id) != "fusionskammer")
	var me: Dictionary = pool[rng.randi() % pool.size()]
	var goal: Dictionary = DAILY_GOALS[rng.randi() % DAILY_GOALS.size()]
	var foes: Array = []
	var count: int = 2 if goal.id == "outnumbered" else 1
	while foes.size() < count:
		var o: Dictionary = pool[rng.randi() % pool.size()]
		if str(o.id) != str(me.id) and not o in foes: foes.append(o)
	var keys: Array = MUTATORS.keys()
	var n: int = int(event_of(day).get("daily_mutators", 2))
	var muts: Array = []
	while muts.size() < n:
		var m: String = keys[rng.randi() % keys.size()]
		# Never giants and tiny together.
		if m in muts or (m == "giants" and "tiny" in muts) or (m == "tiny" and "giants" in muts): continue
		muts.append(m)
	return {"day": day, "fighter": me, "foes": foes, "mutators": muts, "goal": goal, "ai": 4 + rng.randi() % 4}

static func daily_done(prog, day: int) -> bool:
	return int(prog.challenge.get("done_day", -1)) == day

## Did the fight meet the goal? result: winner index, time_used: seconds, lost_stocks of the player.
static func goal_met(goal: Dictionary, result: int, time_used: float, lost_stocks: int) -> bool:
	if result != 0: return false
	match str(goal.id):
		"fast": return time_used <= float(goal.get("time", 60.0))
		"flawless": return lost_stocks == 0
	return true

## Pays today's challenge once and moves the streak. Returns {coins, chest, streak}.
static func claim_daily(prog, day: int) -> Dictionary:
	if daily_done(prog, day): return {}
	var last: int = int(prog.challenge.get("done_day", -1))
	var streak: int = int(prog.challenge.get("streak", 0))
	streak = streak + 1 if last == day - 1 else 1
	var idx: int = (streak - 1) % DAILY_REWARD.size()
	var coins: int = int(DAILY_REWARD[idx] * float(event_of(day).get("daily_mult", 1.0)))
	var chest: bool = idx == DAILY_REWARD.size() - 1
	prog.challenge["done_day"] = day
	prog.challenge["streak"] = streak
	prog.challenge["best_streak"] = maxi(int(prog.challenge.get("best_streak", 0)), streak)
	prog.challenge["total"] = int(prog.challenge.get("total", 0)) + 1
	prog.coins += coins
	if chest: prog.chests += 1
	prog.save_progress()
	return {"coins": coins, "chest": chest, "streak": streak}

static func challenger_chance(day: int) -> float:
	return CHALLENGER_CHANCE * float(event_of(day).get("challenger", 1.0))

## Welcome-back present after COMEBACK_DAYS or more days away. Returns {} if none (also records today's visit).
static func check_comeback(prog, day: int) -> Dictionary:
	var last: int = int(prog.last_seen)
	prog.last_seen = day
	if last < 0 or day - last < COMEBACK_DAYS:
		prog.save_progress()
		return {}
	var away: int = day - last
	var coins: int = 200 + 50 * mini(away, 10)
	prog.coins += coins
	prog.chests += 1
	prog.save_progress()
	return {"days": away, "coins": coins}

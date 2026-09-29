extends RefCounted
## Authoritative local simulation with data-driven percent knockback, state machine, grab/throw, arena items & 3-Stock rules.
## Supports 2, 3, or 4 simultaneous fighters (FFA or Team Brawl) on enlarged tournament arenas with dynamic special items.
const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Signatures = preload("res://scripts/signatures.gd")

## Body pose per move, bare-handed and with a melee weapon (the view animates each).
const MOVE_POSE := {"jab": "Attack", "ftilt": "Kick", "utilt": "Uppercut", "dtilt": "Sweep", "fsmash": "HeavyPunch",
	"usmash": "Uppercut", "dsmash": "Spin", "dash_attack": "Kick", "nair": "Spin", "fair": "Kick", "bair": "BackKick",
	"uair": "Uppercut", "dair": "Stomp", "uspecial": "Rise", "dspecial": "Slam", "nspecial": "SpecialAttack"}
const WEAPON_POSE := {"jab": "Slash", "ftilt": "Thrust", "utilt": "SlashUp", "dtilt": "SlashLow", "fsmash": "HeavySlash",
	"usmash": "SlashUp", "dsmash": "SlashSpin", "dash_attack": "Thrust", "nair": "SlashSpin", "fair": "Slash",
	"bair": "SlashBack", "uair": "SlashUp", "dair": "SlashDown", "uspecial": "SlashUp", "dspecial": "HeavySlash",
	"nspecial": "HeavySlash"}
const STEP := 1.0 / 60.0

const MATCH_TIME := 99.0
## Minimum horizontal distance grounded fighters keep from each other (soft body push).
const BODY_SEPARATION := 0.6
const BODY_PUSH_RATE := 0.9

var fighters: Array = []
var items: Array = []
## Flying attacks (sword beams, laser bolts, boomerangs …).
var projectiles: Array = []
var projectile_serial := 0

## Arena weapons. Picked up with grab, then attacks use the weapon (more reach, damage and
## knockback) and special fires the weapon ability. Each weapon breaks after `uses` attacks.
const WEAPONS := {
	"sword_hero": {"name": "HELDENKLINGE", "reach": 0.9, "dmg": 1.45, "kb": 1.25, "windup": 0.0, "uses": 14, "special": "beam", "color": Color("7dd3fc")},
	"sword_buster": {"name": "RIESENBRECHER", "reach": 1.25, "dmg": 1.9, "kb": 1.7, "windup": 0.08, "uses": 10, "special": "quake", "color": Color("cbd5e1")},
	"sword_plasma": {"name": "PLASMASÄBEL", "reach": 1.0, "dmg": 1.35, "kb": 1.15, "windup": -0.04, "uses": 16, "special": "saber", "color": Color("22d3ee")},
	"sword_frost": {"name": "SEELENFROST", "reach": 0.9, "dmg": 1.4, "kb": 1.2, "windup": 0.02, "uses": 12, "special": "frost_nova", "color": Color("93c5fd"), "freeze": 0.6},
	"sword_crescent": {"name": "MONDSICHEL", "reach": 1.0, "dmg": 1.5, "kb": 1.3, "windup": 0.03, "uses": 12, "special": "crescent", "color": Color("ef4444")},
	"blaster": {"name": "LASERBLASTER", "reach": 0.0, "dmg": 1.0, "kb": 1.0, "windup": -0.05, "uses": 18, "special": "laser", "shoot": "laser", "color": Color("f472b6")},
	"boomerang": {"name": "STURMBUMERANG", "reach": 0.0, "dmg": 1.0, "kb": 1.0, "windup": 0.0, "uses": 9, "special": "boomerang", "shoot": "boomerang", "color": Color("facc15")},
	"flail": {"name": "KETTENMORGENSTERN", "reach": 1.7, "dmg": 1.7, "kb": 1.8, "windup": 0.1, "uses": 10, "special": "quake", "color": Color("a8a29e")},
}
## Projectile kinds: speed m/s, lifetime s, hit size, damage, push, angle, pierce, return time.
const PROJECTILES := {
	"beam": {"speed": 15.0, "life": 0.7, "size": 0.55, "damage": 10.0, "push": 0.55, "angle": 30.0, "pierce": false, "turn": -1.0},
	"saber": {"speed": 12.0, "life": 1.6, "size": 0.6, "damage": 11.0, "push": 0.5, "angle": 40.0, "pierce": true, "turn": 0.45},
	"crescent": {"speed": 10.0, "life": 0.95, "size": 1.1, "damage": 15.0, "push": 0.8, "angle": 42.0, "pierce": true, "turn": -1.0},
	"laser": {"speed": 24.0, "life": 0.55, "size": 0.35, "damage": 4.5, "push": 0.18, "angle": 20.0, "pierce": false, "turn": -1.0},
	"boomerang": {"speed": 13.0, "life": 1.8, "size": 0.55, "damage": 10.0, "push": 0.5, "angle": 45.0, "pierce": true, "turn": 0.5},
}
var time_left := MATCH_TIME
var initial_lives := 3
var elapsed := 0.0
## "3 – 2 – 1 – GO!" before every match (0.8 s per number).
const COUNTDOWN_TIME := 2.4
var countdown := COUNTDOWN_TIME
var result := -2 # -2 ongoing, -1 draw, 0..3 winner
var mode := "manual"
var events: Array = []
var serial := 0
var profiles: Array = []
var item_spawn_timer := 8.0
## Match-owned random streams, seeded from the fighters' prompts: the same match with the
## same inputs always plays out identically (replays, tests). The AI has its own stream so
## computer decisions never shift item spawns.
var rng := RandomNumberGenerator.new()
var ai_rng := RandomNumberGenerator.new()

## ── Defense ──
const SHIELD_MAX := 50.0
const SHIELD_DRAIN := 11.0        # per second while held
const SHIELD_REGEN := 9.0         # per second while released
const SHIELD_DAMAGE_MULT := 1.3   # shield loss per point of blocked damage
const SHIELD_BREAK_STUN := 2.2
const ROLL_TIME := 0.34
const ROLL_SPEED := 7.2
const SPOT_DODGE_TIME := 0.28
const AIR_DODGE_TIME := 0.38
const AIR_DODGE_SPEED := 8.0
const DODGE_INTANGIBLE := 0.24
## ── Ledges (anti-planking: each regrab without landing gives less intangibility) ──
const LEDGE_HANG_Y := -1.0
const LEDGE_MAX_GRABS := 6
const LEDGE_INTANGIBLE := [1.0, 0.6, 0.35, 0.15, 0.0, 0.0]
const LEDGE_MAX_HANG := 5.0
const LEDGE_ACT_DELAY := 0.1
## ── Attacks ──
const SMASH_TAP_TIME := 0.1       # release within this = tilt, hold longer = charged smash
const SMASH_MAX_CHARGE := 1.0
const RUN_TIME := 0.3             # moving this long counts as running (dash attack, speed)
const RUN_SPEED_MULT := 1.35
const DI_MAX_DEG := 15.0
## Ground movement ramps up and down instead of starting/stopping instantly.
const GROUND_ACCEL := 55.0
const GROUND_DECEL := 42.0
const LANDING_LAG := 0.1
## ── Finisher ("MACH IHN FERTIG!") ──
const FINISH_TIME := 5.0
const FINISH_RANGE := 4.0
const FINISH_INPUT_WINDOW := 2.0

## Computer difficulty 1 (reacts slowly, rarely shields) … 9 (fast, shields, edge play).
var ai_level := 5
## Per-fighter AI memory (plan + think timer), kept outside the fighter state so AI
## decisions never change the simulated match data.
var ai_memory: Array = []
## Versus option: the last KO leaves the loser dazed for a finisher.
var finishers_enabled := false
var finish_phase := false
var finish_timer := 0.0
var finish_winner := -1
var finish_loser := -1

const GRAVITY := 20.0
const JUMP_FORCE := 8.5
const HITSTOP_FRAMES := 4
const PARRY_WINDOW := 0.12
const MAX_SUPER := 100.0
const INITIAL_LIVES := 3

# ── Enlarged Tournament Stage Geometry ──────────────────────────────────────────
const STAGE_LEFT := -9.5
const STAGE_RIGHT := 9.5
const BLAST_ZONE_LEFT := -16.0
const BLAST_ZONE_RIGHT := 16.0
const BLAST_ZONE_BOTTOM := -6.0
const BLAST_ZONE_TOP := 13.0

# 8 Floating pass-through platforms across 4 vertical tiers in expanded layout
const PLATFORMS: Array = [
	{"name": "plat_wing_left",   "x1": -8.5, "x2": -5.5, "y": 1.45, "width": 3.0},
	{"name": "plat_wing_right",  "x1":  5.5, "x2":  8.5, "y": 1.45, "width": 3.0},
	{"name": "plat_mid_left",   "x1": -4.2, "x2": -1.8, "y": 2.50, "width": 2.4},
	{"name": "plat_mid_right",  "x1":  1.8, "x2":  4.2, "y": 2.50, "width": 2.4},
	{"name": "plat_center",     "x1": -1.5, "x2":  1.5, "y": 3.65, "width": 3.0},
	{"name": "plat_apex",       "x1": -1.0, "x2":  1.0, "y": 5.20, "width": 2.0},
	{"name": "plat_perch_left",  "x1": -9.2, "x2": -7.2, "y": 3.40, "width": 2.0},
	{"name": "plat_perch_right", "x1":  7.2, "x2":  9.2, "y": 3.40, "width": 2.0},
]

# Combo multiplier: 1.0 → 1.08 → 1.18 → 1.30 → 1.45
const COMBO_MULT: Array = [1.0, 1.08, 1.18, 1.30, 1.45]

# Initial items templates
const DEFAULT_ITEMS: Array = [
	{
		"id": 0, "type": "light_crate", "name": "Leichte Kiste",
		"start_x": -6.5, "start_y": 1.55, "x": -6.5, "y": 1.55,
		"vx": 0.0, "vy": 0.0, "weight": 0.60,
		"state": "resting",
		"carrier": -1, "thrower": -1, "respawn": 0.0,
		"damage": 14.0, "push": 0.38, "angle": 32.0, "fragile": true,
		"explosive": false, "special_power": ""
	},
	{
		"id": 1, "type": "heavy_rock", "name": "Schwerer Stein",
		"start_x": -3.0, "start_y": 2.60, "x": -3.0, "y": 2.60,
		"vx": 0.0, "vy": 0.0, "weight": 1.40,
		"state": "resting",
		"carrier": -1, "thrower": -1, "respawn": 0.0,
		"damage": 24.0, "push": 0.58, "angle": 45.0, "fragile": false,
		"explosive": false, "special_power": ""
	},
	{
		"id": 2, "type": "barrel", "name": "Holzfass",
		"start_x": 6.5, "start_y": 1.55, "x": 6.5, "y": 1.55,
		"vx": 0.0, "vy": 0.0, "weight": 0.90,
		"state": "resting",
		"carrier": -1, "thrower": -1, "respawn": 0.0,
		"damage": 18.0, "push": 0.44, "angle": 36.0, "fragile": false,
		"explosive": false, "special_power": ""
	},
	{
		"id": 3, "type": "explosive_barrel", "name": "Explosiv-Fass",
		"start_x": 0.0, "start_y": 5.30, "x": 0.0, "y": 5.30,
		"vx": 0.0, "vy": 0.0, "weight": 0.88,
		"state": "resting",
		"carrier": -1, "thrower": -1, "respawn": 0.0,
		"damage": 36.0, "push": 0.75, "angle": 52.0, "fragile": true,
		"explosive": true, "explosion_radius": 3.0, "special_power": ""
	},
	{
		"id": 4, "type": "titan_mushroom", "name": "Titan-Pilz (2x Gr\u00f6\u00dfe & Kraft)",
		"start_x": 3.0, "start_y": 2.60, "x": 3.0, "y": 2.60,
		"vx": 0.0, "vy": 0.0, "weight": 0.5,
		"state": "resting",
		"carrier": -1, "thrower": -1, "respawn": 0.0,
		"damage": 0.0, "push": 0.0, "angle": 0.0, "fragile": false,
		"explosive": false, "special_power": "titan"
	},
	{
		"id": 5, "type": "invulnerable_star", "name": "Stern der Unsterblichkeit (10s)",
		"start_x": 0.0, "start_y": 3.75, "x": 0.0, "y": 3.75,
		"vx": 0.0, "vy": 0.0, "weight": 0.5,
		"state": "resting",
		"carrier": -1, "thrower": -1, "respawn": 0.0,
		"damage": 0.0, "push": 0.0, "angle": 0.0, "fragile": false,
		"explosive": false, "special_power": "invulnerable"
	}
]

func start(a, b = null, control: String = "manual", lives_count: int = 3) -> void:
	var prof_list: Array = []
	if a is Array:
		prof_list = a
		if b is String:
			control = b
	else:
		if a is Dictionary and Prompt.valid(a):
			prof_list.append(a.duplicate(true))
		if b is Dictionary and Prompt.valid(b):
			prof_list.append(b.duplicate(true))

	profiles = prof_list
	fighters.clear()
	var count: int = prof_list.size()

	# Spawn coordinates for up to 4 fighters across enlarged arena
	var spawn_x: Array = [-6.2, 6.2, -2.5, 2.5]
	var spawn_facing: Array = [1, -1, 1, -1]

	for i in range(count):
		var p: Dictionary = profiles[i]
		fighters.append({
			"profile": p,
			"hp": p.health,
			"max_hp": p.health,
			"damage_percent": 0.0,    # Percent damage (0% - 999%)
			"x": spawn_x[i % spawn_x.size()],
			"y": 0.0,
			"vy": 0.0,
			"vx": 0.0,
			"is_grounded": true,
			"blocking": false,
			"facing": spawn_facing[i % spawn_facing.size()],
			"cooldowns": [0.0, 0.0],
			"pending": {},
			"stun": 0.0,
			"pose": "Idle",
			"pose_time": 0.0,
			"moving": false,
			"super": 0.0,
			"combo": 0,
			"combo_timer": 0.0,
			"hitstop": 0,
			"parry_timer": 0.0,
			"parry_used": false,
			"lives": lives_count,
			"air_jumps": 2,
			"air_dash_used": false,
			"drop_through": 0.0,
			"invulnerable": 0.0,
			"titan_timer": 0.0,       # 15s 2x scale and 2x strength
			"speed_timer": 0.0,       # 12s 2.2x speed
			"hammer_timer": 0.0,      # 12s power hammer
			"freeze_timer": 0.0,      # Ice block frozen state
			"state": "Ready",
			"grab_timer": 0.0,
			"grabbed_by": -1,
			"grab_target": -1,
			"grab_immunity": 0.0,
			"carried_item": -1,
			"slow_timer": 0.0,
			"team": i,              # fighters on the same team never hit each other
			"power_mult": 1.0,      # story/boss modifiers: outgoing damage
			"kb_taken_mult": 1.0,   # and incoming knockback
			"air_control_lock": 0.0,
			"moves": build_moveset(p),
			"shield_hp": SHIELD_MAX,
			"intangible": 0.0,
			"dodge_timer": 0.0,
			"dodge_kind": "",
			"dodge_dir": 0.0,
			"air_dodge_used": false,
			"slide": 0.0,
			"ledge": 0,                 # -1 left ledge, +1 right ledge, 0 none
			"ledge_timer": 0.0,
			"ledge_grabs": 0,
			"ledge_cooldown": 0.0,
			"charge_key": "",
			"charge_time": 0.0,
			"run_time": 0.0,
			"walk_v": 0.0,
			"crouching": false,
			"in_x": 0.0,                # held direction, used for DI
			"in_y": 0.0,
			"_prev_in": {},
			"_tokens": [],              # finisher input history
			"weapon": {},               # wielded arena weapon (id, uses, item)
			"counter": 0.0,             # counter stance time left
			"rage_timer": 0.0,          # signature rage boost time left
			"anim_windup": 0.1,         # windup of the running move (animation timing)
		})

	projectiles.clear()
	projectile_serial = 0
	# Reset Items
	items.clear()
	for def in DEFAULT_ITEMS:
		items.append(def.duplicate(true))

	var match_seed: int = 7919
	for p in prof_list:
		match_seed = (match_seed * 31 + int(p.get("seed", 0))) & 0x7fffffff
	rng.seed = match_seed
	ai_rng.seed = match_seed ^ 0x5bd1e995

	ai_memory.clear()
	for k in range(count): ai_memory.append({})
	finish_phase = false
	finish_timer = 0.0
	finish_winner = -1
	finish_loser = -1

	initial_lives = lives_count
	time_left = MATCH_TIME
	elapsed = 0.0
	countdown = COUNTDOWN_TIME
	result = -2
	mode = control
	serial = 0
	item_spawn_timer = 8.0
	events.clear()

func restart() -> void:
	start(profiles, null, mode, initial_lives)

func queue_attack(i: int, is_special: bool) -> bool:
	if i >= fighters.size(): return false
	var f: Dictionary = fighters[i]
	if f.state != "Ready" and f.state != "Carrying": return false
	if f.freeze_timer > 0.0: return false
	if not f.pending.is_empty(): return false
	if f.state == "Carrying" and f.carried_item >= 0:
		throw_carried_item(i)
		return true

	var idx := 1 if is_special else 0
	if f.cooldowns[idx] > 0.0: return false
	var a: Dictionary = f.moves.get("nspecial" if is_special else "jab", f.profile.special if is_special else f.profile.standard)

	# Power hammer item overrides the standard attack
	if not is_special and f.hammer_timer > 0.0:
		a = {
			"name": "Wucht-Hammer Schlag",
			"damage": 42.0,
			"range": 1.6,
			"windup": 0.15,
			"active": 0.15,
			"recovery": 0.22,
			"push": 1.6,
			"angle": 42.0,
			"cooldown": 0.35,
			"hitstun": 0.45
		}

	f.cooldowns[idx] = a.cooldown
	_begin_pending(i, a, is_special, "nspecial" if is_special else "jab")
	return true

## Starts a move from the fighter's moveset (tilts, smashes, aerials, specials).
## charge > 1 scales a charged smash attack.
func start_move(i: int, key: String, charge: float = 1.0) -> bool:
	var f: Dictionary = fighters[i]
	if not f.moves.has(key): return false
	var a: Dictionary = f.moves[key].duplicate()
	var is_special: bool = bool(a.get("special", false))
	if is_special:
		if f.cooldowns[1] > 0.0: return false
		f.cooldowns[1] = float(a.get("cooldown", 1.0))
	if charge > 1.0:
		a.damage = float(a.damage) * charge
		a.push = float(a.push) * (1.0 + (charge - 1.0) * 0.8)
		a.name = "%s ×%.1f" % [a.name, charge]
	_begin_pending(i, a, is_special, key)
	return true

func _begin_pending(i: int, a: Dictionary, is_special: bool, key: String) -> void:
	var f: Dictionary = fighters[i]
	f.walk_v = 0.0
	if not f.weapon.is_empty() and not a.has("weapon"):
		a = weapon_ability(i, a, is_special)
	elif is_special and key == "nspecial" and not a.has("sig"):
		var sig: Dictionary = Signatures.for_family(str(f.profile.get("family", "")))
		if not sig.is_empty(): a = signature_ability(i, a, sig)
	var pose: String = MOVE_POSE.get(key, "SpecialAttack" if is_special else "Attack")
	if a.has("weapon"):
		pose = "Cast" if weapon_shoots(a) else WEAPON_POSE.get(key, "Slash")
	if a.has("sig"): pose = Signatures.MECH_POSE.get(a.sig.mech, "SpecialAttack")
	f.anim_windup = float(a.windup)
	f.state = "Attack"
	f.pending = {
		"ability": a,
		"special": is_special,
		"key": key,
		"remaining": a.windup,
		"active_time": a.get("active", 0.12),
		"recovery_time": a.get("recovery", 0.20),
		"hit_done": false,
		"hit_list": [],
		"stage": "windup",
		"pose": pose,
		"age": 0.0,
		"rehit_t": 0.0,
	}
	f.pose = pose
	f.pose_time = a.windup + a.get("active", 0.12) + a.get("recovery", 0.20)
	events.append({"type": "attack", "actor": i, "special": is_special, "key": key, "ability_name": a.get("name", "Attack")})

func initiate_grab(i: int) -> void:
	if i >= fighters.size(): return
	var f: Dictionary = fighters[i]
	if f.state != "Ready" or f.freeze_timer > 0.0: return

	# 1. Priority: Pick up nearby ground item if in reach
	var best_item := -1
	var best_dist := 1.55
	for item_idx in range(items.size()):
		var it: Dictionary = items[item_idx]
		if it.state == "resting" or it.state == "free":
			var d := Vector2(it.x - f.x, it.y - f.y).length()
			if d < best_dist:
				best_dist = d
				best_item = item_idx

	if best_item >= 0:
		var it: Dictionary = items[best_item]
		# Instant-use powerups (Star, Titan, Speed, Heart) activate on touch/grab
		if it.get("special_power", "") != "":
			apply_special_powerup(i, it)
			it.state = "destroyed"
			it.respawn = 18.0
			return

		if it.get("weapon", "") != "":
			equip_weapon(i, best_item)
			return
		it.state = "carried"
		it.carrier = i
		it.vx = 0.0
		it.vy = 0.0
		f.carried_item = best_item
		f.state = "Carrying"
		events.append({"type": "item_pickup", "actor": i, "item_id": best_item, "item_name": it.name})
		return

	# 2. Priority: Grab nearest opponent
	if f.grab_immunity > 0.0: return
	f.state = "Grab"
	f.grab_timer = 0.12
	f.pose = "Attack"
	f.pose_time = 0.35
	events.append({"type": "grab_attempt", "actor": i})

func apply_special_powerup(fighter_idx: int, it: Dictionary) -> void:
	var f: Dictionary = fighters[fighter_idx]
	var power: String = it.get("special_power", "")
	if power == "invulnerable":
		f.invulnerable = 10.0
		events.append({"type": "powerup_activated", "actor": fighter_idx, "power": "invulnerable", "name": it.name, "duration": 10.0})
	elif power == "titan":
		f.titan_timer = 15.0
		events.append({"type": "powerup_activated", "actor": fighter_idx, "power": "titan", "name": it.name, "duration": 15.0})
	elif power == "speed":
		f.speed_timer = 12.0
		events.append({"type": "powerup_activated", "actor": fighter_idx, "power": "speed", "name": it.name, "duration": 12.0})
	elif power == "hammer":
		f.hammer_timer = 12.0
		events.append({"type": "powerup_activated", "actor": fighter_idx, "power": "hammer", "name": it.name, "duration": 12.0})
	elif power == "heal":
		f.hp = minf(f.max_hp, f.hp + 60.0)
		events.append({"type": "powerup_activated", "actor": fighter_idx, "power": "heal", "name": it.name, "amount": 60.0})

func throw_carried_item(i: int) -> void:
	var f: Dictionary = fighters[i]
	if f.carried_item < 0: return
	var item_idx: int = f.carried_item
	var it: Dictionary = items[item_idx]
	it.state = "thrown"
	it.carrier = -1
	it.thrower = i
	it.x = f.x + f.facing * 0.75
	it.y = f.y + 0.8
	var speed: float = 14.0 / maxf(0.5, it.weight)
	it.vx = f.facing * speed
	it.vy = 4.5
	f.carried_item = -1
	f.state = "Ready"
	f.pose = "Attack"
	f.pose_time = 0.22
	events.append({"type": "item_throw", "actor": i, "item_id": item_idx, "item_name": it.name})

func explode_item(it_idx: int) -> void:
	if it_idx < 0 or it_idx >= items.size(): return
	var it: Dictionary = items[it_idx]
	if it.state == "destroyed": return
	it.state = "destroyed"
	it.respawn = 9.0
	var exp_x: float = it.x
	var exp_y: float = it.y
	var radius: float = float(it.get("explosion_radius", 3.0))
	var base_dmg: float = float(it.get("damage", 36.0))
	var base_push: float = float(it.get("push", 1.45))
	var thrower_id: int = it.thrower
	var is_freeze: bool = (it.get("special_power", "") == "freeze")

	events.append({
		"type": "item_explode",
		"item_id": it_idx,
		"item_name": it.name,
		"x": exp_x,
		"y": exp_y,
		"radius": radius,
		"thrower": thrower_id,
		"is_freeze": is_freeze
	})

	for fi in range(fighters.size()):
		var f: Dictionary = fighters[fi]
		if f.state == "Defeated" or f.invulnerable > 0: continue
		var f_center := Vector2(f.x, f.y + 0.75)
		var dist := Vector2(exp_x, exp_y).distance_to(f_center)
		if dist <= radius:
			if is_freeze:
				f.freeze_timer = 3.5
				f.stun = 3.5
				f.state = "HitStun"
				f.pose = "HitReact"
				f.pose_time = 3.5
				events.append({"type": "freeze_hit", "actor": thrower_id, "target": fi, "duration": 3.5})
				continue

			var falloff: float = clampf(1.0 - (dist / radius), 0.35, 1.0)
			var dmg: float = base_dmg * falloff * clampf(1.0 - f.profile.stats.defense * 0.01, 0.55, 0.90)
			f.damage_percent = clampf(f.damage_percent + dmg, 0.0, 999.0)
			f.hp = maxf(0.0, f.hp - dmg)

			var p_ratio: float = f.damage_percent
			var weight: float = clampf(float(f.profile.get("weight", 1.0)), 0.85, 1.35)
			# Halved knockback scaling (smoother control)
			var launch_scale: float = 1.0 + (p_ratio * 0.009) + (pow(p_ratio, 1.35) * 0.0017)
			var impulse: float = (base_push * 4.25 * falloff * launch_scale) / weight

			var diff: Vector2 = f_center - Vector2(exp_x, exp_y)
			var dir_x: float = sign(diff.x) if abs(diff.x) > 0.05 else (1.0 if fi % 2 == 0 else -1.0)
			f.vx = dir_x * impulse * 0.85
			f.vy = maxf(impulse * 0.50, 1.8)
			f.is_grounded = false
			f.drop_through = 0.15
			f.stun = clampf(0.30 + (p_ratio * 0.002), 0.18, 0.70)
			f.air_control_lock = f.stun * 0.60
			f.state = "HitStun"
			f.pose = "HitReact"
			f.pose_time = f.stun
			events.append({
				"type": "hit", "actor": thrower_id if thrower_id >= 0 else fi, "target": fi,
				"damage": dmg, "special": true, "super_hit": true,
				"launch_impulse": impulse, "damage_percent": f.damage_percent
			})

func execute_throw(attacker_idx: int, throw_type: String) -> void:
	var attacker: Dictionary = fighters[attacker_idx]
	var target_idx: int = attacker.grab_target
	if target_idx < 0 or target_idx >= fighters.size(): return
	var target: Dictionary = fighters[target_idx]

	var weight: float = clampf(float(target.profile.get("weight", 1.0)), 0.85, 1.35)
	var damage: float = 15.0 * (1.0 - target.profile.stats.defense * 0.006)
	if attacker.titan_timer > 0.0: damage *= 2.0
	target.damage_percent = clampf(target.damage_percent + damage, 0.0, 999.0)
	target.hp = maxf(0.0, target.hp - damage)

	var p_ratio: float = target.damage_percent
	# Halved throw impulse
	var launch_mult: float = 1.0 + (p_ratio * 0.008) + (pow(p_ratio, 1.38) * 0.0016)
	if attacker.titan_timer > 0.0: launch_mult *= 1.6

	if throw_type == "forward":
		var base_impulse := 2.9 * launch_mult / weight
		target.vx = attacker.facing * base_impulse
		target.vy = 2.0 * (1.0 + p_ratio * 0.002)
	elif throw_type == "back":
		var base_impulse := 3.2 * launch_mult / weight
		target.vx = -attacker.facing * base_impulse
		target.vy = 2.0 * (1.0 + p_ratio * 0.002)
	elif throw_type == "up":
		var base_impulse := 3.0 * launch_mult / weight
		target.vx = attacker.facing * 0.5
		target.vy = base_impulse
	else:
		target.vx = attacker.facing * 1.6 * launch_mult / weight
		target.vy = 1.4

	target.is_grounded = false
	target.drop_through = 0.15
	target.stun = clampf(0.32 + p_ratio * 0.003, 0.25, 0.85)
	target.air_control_lock = target.stun * 0.7
	target.state = "HitStun"
	target.pose = "HitReact"
	target.pose_time = target.stun
	target.grabbed_by = -1
	target.grab_immunity = 0.85

	attacker.state = "Throw"
	attacker.grab_target = -1
	attacker.grab_timer = 0.0
	attacker.pose = "Attack"
	attacker.pose_time = 0.28
	events.append({"type": "throw", "actor": attacker_idx, "target": target_idx, "throw_type": throw_type, "damage": damage})

# ── Arena weapons & projectiles ───────────────────────────────────────────────

## Places a weapon on a random platform (or the main stage).
func spawn_weapon(weapon_id: String, px: float = INF, py: float = INF) -> int:
	if px == INF:
		if rng.randf() < 0.35:
			px = rng.randf_range(STAGE_LEFT + 1.0, STAGE_RIGHT - 1.0)
			py = 0.15
		else:
			var plat: Dictionary = PLATFORMS[rng.randi() % PLATFORMS.size()]
			px = rng.randf_range(plat.x1 + 0.3, plat.x2 - 0.3)
			py = plat.y + 0.15
	var w: Dictionary = WEAPONS[weapon_id]
	var id: int = items.size()
	items.append({
		"id": id, "type": weapon_id, "name": w.name, "weapon": weapon_id,
		"start_x": px, "start_y": py, "x": px, "y": py, "vx": 0.0, "vy": 0.0, "weight": 0.7,
		"state": "resting", "carrier": -1, "thrower": -1, "respawn": 0.0,
		"damage": 12.0, "push": 0.5, "angle": 40.0, "fragile": false, "explosive": false,
		"special_power": "", "no_respawn": true,
	})
	events.append({"type": "item_spawned", "item_id": id, "item_name": w.name, "x": px, "y": py, "weapon": weapon_id})
	return id

func equip_weapon(i: int, item_idx: int) -> void:
	var f: Dictionary = fighters[i]
	var it: Dictionary = items[item_idx]
	var w: Dictionary = WEAPONS[it.weapon]
	it.state = "wielded"
	it.carrier = i
	f.weapon = {"id": it.weapon, "uses": int(w.uses), "item": item_idx}
	events.append({"type": "weapon_pickup", "actor": i, "item_id": item_idx, "weapon": it.weapon, "item_name": w.name})

## Removes the weapon from the fighter; the item is thrown, dropped or broken.
func drop_weapon(i: int, how: String) -> void:
	var f: Dictionary = fighters[i]
	if f.weapon.is_empty(): return
	var it: Dictionary = items[f.weapon.item]
	f.weapon = {}
	it.carrier = -1
	match how:
		"throw":
			it.state = "thrown"
			it.thrower = i
			it.x = f.x + f.facing * 0.7
			it.y = f.y + 1.0
			it.vx = f.facing * 15.0
			it.vy = 3.5
			it.damage = 16.0
		"break":
			it.state = "destroyed"
			it.respawn = 0.0
			events.append({"type": "weapon_break", "actor": i, "item_id": it.id, "item_name": it.name})
		_:
			it.state = "free"
			it.x = f.x
			it.y = f.y + 0.5
			it.vx = 0.0
			it.vy = 2.0

func throw_weapon(i: int) -> void:
	drop_weapon(i, "throw")
	var f: Dictionary = fighters[i]
	f.pose = "Attack"
	f.pose_time = 0.22
	events.append({"type": "item_throw", "actor": i})

## Turns a move into its weapon version; special becomes the weapon ability.
## True if a weapon move fires a projectile instead of swinging.
func weapon_shoots(a: Dictionary) -> bool:
	return a.has("spawn") and a.get("no_hit", false)

func weapon_ability(i: int, a: Dictionary, is_special: bool) -> Dictionary:
	var f: Dictionary = fighters[i]
	var w: Dictionary = WEAPONS[f.weapon.id]
	var b: Dictionary = a.duplicate()
	b["weapon"] = f.weapon.id
	if is_special:
		var kind: String = w.special
		b = {"name": "%s · %s" % [w.name, kind.capitalize()], "damage": 12.0, "range": 1.2, "windup": 0.12, "active": 0.12,
			"recovery": 0.3, "push": 0.9, "angle": 55.0, "hitstun": 0.3, "cooldown": 1.0, "special": true, "weapon": f.weapon.id}
		if PROJECTILES.has(kind):
			b["spawn"] = kind
			b["no_hit"] = true
		elif kind == "quake":
			b.merge({"all_around": true, "x_min": -2.6, "range": 2.6, "y_min": -0.3, "y_max": 1.4, "damage": 16.0, "angle": 70.0, "push": 1.3, "windup": 0.2}, true)
		elif kind == "frost_nova":
			b.merge({"all_around": true, "x_min": -2.4, "range": 2.4, "y_min": -0.5, "y_max": 2.4, "damage": 9.0, "angle": 50.0, "push": 0.6, "freeze": 1.2}, true)
	else:
		if w.has("shoot"):
			b["spawn"] = w.shoot
			b["no_hit"] = true
			b["windup"] = maxf(0.04, float(a.windup) + float(w.windup))
		else:
			b["range"] = float(a.range) + float(w.reach)
			b["damage"] = float(a.damage) * float(w.dmg)
			b["push"] = float(a.push) * float(w.kb)
			b["windup"] = maxf(0.03, float(a.windup) + float(w.windup))
			if w.has("freeze"): b["freeze"] = w.freeze
	f.weapon.uses -= 1
	if f.weapon.uses <= 0:
		# The weapon breaks after this attack.
		b["breaks_weapon"] = true
	return b

func spawn_projectile(owner: int, kind: String) -> void:
	var f: Dictionary = fighters[owner]
	var d: Dictionary = PROJECTILES[kind]
	spawn_projectile_spec(owner, d.merged({"kind": kind}), float(d.damage) * float(f.get("power_mult", 1.0)),
		f.x + f.facing * 0.7, f.y + 1.1, f.facing * float(d.speed), 0.0)

## Generic projectile. spec keys: speed, life, size, push, angle, pierce, turn, gravity,
## homing, wave, explode, fuse, pull, swap, lifesteal, freeze, emit, shape, color, kind.
func spawn_projectile_spec(owner: int, spec: Dictionary, damage: float, x: float, y: float, vx: float, vy: float) -> int:
	projectile_serial += 1
	var ab := {"name": str(spec.get("kind", "shot")), "damage": damage, "push": float(spec.get("push", 0.5)),
		"angle": float(spec.get("angle", 35.0)), "hitstun": 0.28, "range": 1.0}
	if spec.has("freeze"): ab["freeze"] = float(spec.freeze)
	projectiles.append({
		"id": projectile_serial, "kind": str(spec.get("kind", "shot")), "owner": owner, "spec": spec,
		"x": x, "y": y, "vx": vx, "vy": vy, "base_y": y,
		"life": float(spec.get("life", 1.0)), "age": 0.0, "returning": false, "hit": [], "emit_t": 0.0,
		"ability": ab,
	})
	events.append({"type": "projectile", "actor": owner, "kind": str(spec.get("kind", "shot")), "id": projectile_serial,
		"shape": str(spec.get("shape", "")), "color": spec.get("color", Color.WHITE)})
	return projectile_serial

func _explode_projectile(pr: Dictionary, contacts: Array) -> void:
	var radius: float = float(pr.spec.get("explode", 0.0))
	events.append({"type": "blast", "actor": pr.owner, "x": pr.x, "y": pr.y, "radius": radius, "color": pr.spec.get("color", Color.ORANGE)})
	for ti in range(fighters.size()):
		if ti == pr.owner or is_ally(pr.owner, ti): continue
		var t: Dictionary = fighters[ti]
		if t.state == "Defeated" or t.state == "Dazed": continue
		if Vector2(t.x - pr.x, t.y + 0.8 - pr.y).length() <= radius:
			contacts.append({"from": pr.owner, "to": ti, "attack": {"ability": pr.ability, "special": true}, "push_dir": signf(t.x - pr.x) if absf(t.x - pr.x) > 0.05 else 1.0})

## Moves projectiles and reports their hits as contacts.
func _update_projectiles(dt: float, contacts: Array) -> void:
	var keep: Array = []
	for pr in projectiles:
		var d: Dictionary = pr.spec
		pr.age += dt
		pr.life -= dt
		var speed: float = float(d.get("speed", 10.0))
		if float(d.get("turn", -1.0)) > 0.0 and pr.age >= float(d.turn):
			# Returning projectiles fly back to their owner.
			var o: Dictionary = fighters[pr.owner]
			var to := Vector2(o.x - pr.x, o.y + 1.1 - pr.y)
			if to.length() < 0.7 and pr.age > float(d.turn) + 0.1: continue
			var v := to.normalized() * speed
			pr.vx = v.x
			pr.vy = v.y
			pr.hit = [] if not pr.returning else pr.hit
			pr.returning = true
		if float(d.get("homing", 0.0)) > 0.0:
			var target_i: int = get_nearest_opponent(pr.owner)
			if target_i >= 0:
				var tg: Dictionary = fighters[target_i]
				var want := Vector2(tg.x - pr.x, tg.y + 1.0 - pr.y).normalized() * speed
				var cur := Vector2(pr.vx, pr.vy).move_toward(want, float(d.homing) * speed * dt)
				pr.vx = cur.x
				pr.vy = cur.y
		pr.vy -= float(d.get("gravity", 0.0)) * dt
		pr.x += pr.vx * dt
		pr.y += pr.vy * dt
		if float(d.get("wave", 0.0)) > 0.0:
			pr.y = pr.base_y + sin(pr.age * 9.0) * 0.5 * float(d.wave)
		if float(d.get("emit", 0.0)) > 0.0:
			# Turret: fires bolts at the nearest opponent.
			pr.emit_t += dt
			if pr.emit_t >= float(d.emit):
				pr.emit_t = 0.0
				var ti2: int = get_nearest_opponent(pr.owner)
				var dir: float = signf(fighters[ti2].x - pr.x) if ti2 >= 0 else 1.0
				spawn_projectile_spec(pr.owner, {"kind": "bolt", "shape": "bolt", "color": d.get("color", Color.YELLOW), "speed": 20.0,
					"life": 0.6, "size": 0.3, "push": 0.25, "angle": 20.0}, float(pr.ability.damage), pr.x + dir * 0.4, pr.y + 0.2, dir * 20.0, 0.0)
		# Landing: arcs explode on the floor, others just stop falling.
		var on_floor: bool = pr.y <= 0.15 and pr.x >= STAGE_LEFT and pr.x <= STAGE_RIGHT and float(d.get("gravity", 0.0)) > 0.0
		var gone := false
		if on_floor:
			pr.y = 0.15
			if float(d.get("explode", 0.0)) > 0.0:
				_explode_projectile(pr, contacts)
				gone = true
			else:
				pr.vy = 0.0
		var size: float = float(d.get("size", 0.5))
		for ti in range(fighters.size()):
			if gone: break
			if ti == pr.owner or is_ally(pr.owner, ti) or ti in pr.hit: continue
			var t: Dictionary = fighters[ti]
			if t.state == "Defeated" or t.state == "Dazed": continue
			if absf(t.x - pr.x) <= size and pr.y >= t.y - 0.3 - size * 0.5 and pr.y <= t.y + 1.8 + size * 0.5:
				pr.hit.append(ti)
				if float(d.get("explode", 0.0)) > 0.0:
					_explode_projectile(pr, contacts)
					gone = true
					break
				var c := {"from": pr.owner, "to": ti, "attack": {"ability": pr.ability, "special": false}, "push_dir": signf(pr.vx) if absf(pr.vx) > 0.1 else 1.0}
				if bool(d.get("pull", false)): c["pull"] = true
				if bool(d.get("swap", false)): c["swap"] = true
				if float(d.get("lifesteal", 0.0)) > 0.0: c["lifesteal"] = float(d.lifesteal)
				contacts.append(c)
				if not bool(d.get("pierce", false)): gone = true
		if not gone and pr.life <= 0.0 and float(d.get("fuse", 0.0)) > 0.0:
			_explode_projectile(pr, contacts)
			gone = true
		if pr.life <= 0.0 or gone or pr.x < BLAST_ZONE_LEFT or pr.x > BLAST_ZONE_RIGHT or pr.y < BLAST_ZONE_BOTTOM:
			events.append({"type": "projectile_end", "id": pr.id})
			continue
		keep.append(pr)
	projectiles = keep

# ── Signature specials ─────────────────────────────────────────────────────────

## Builds the fighter's signature special from the prompt special (damage, windup) and its
## signature data (signatures.gd).
func signature_ability(i: int, a: Dictionary, sig: Dictionary) -> Dictionary:
	var b: Dictionary = a.duplicate()
	var dmg: float = float(a.damage) * float(sig.get("dmg", 1.0))
	b["sig"] = sig
	b["damage"] = dmg
	b["name"] = str(a.get("name", "Spezial"))
	if sig.has("windup"): b["windup"] = float(sig.windup)
	b.erase("type") # the signature replaces the old all-around type
	match str(sig.mech):
		"projectile", "meteor", "mine", "turret", "clone", "eruption", "rage":
			b["no_hit"] = true
			b["active"] = 0.1
		"counter":
			b["no_hit"] = true
			b["active"] = 0.45
			b["recovery"] = 0.25
		"beam":
			b.merge({"x_min": 0.3, "range": float(sig.get("length", 6.0)), "y_min": 1.2 - float(sig.get("thick", 0.8)) * 0.5,
				"y_max": 1.2 + float(sig.get("thick", 0.8)) * 0.5, "angle": 30.0, "active": 0.28}, true)
			if sig.has("freeze"): b["freeze"] = float(sig.freeze)
		"dash":
			var multi: int = int(sig.get("multi", 1))
			b.merge({"x_min": -0.3, "range": 1.3, "y_min": -0.2, "y_max": 1.9, "active": 0.3, "motion_vx": float(sig.get("speed", 12.0)), "angle": 40.0}, true)
			if multi > 1:
				b["rehit"] = 0.3 / multi
				b["damage"] = dmg / multi * 1.4
		"teleport":
			b.merge({"x_min": -0.4, "range": 1.5, "y_min": -0.3, "y_max": 2.0, "active": 0.14, "angle": 45.0}, true)
		"whirl":
			var r: float = float(sig.get("radius", 2.5))
			b.merge({"x_min": -r, "range": r, "y_min": -0.4, "y_max": 2.4, "all_around": true, "active": float(sig.get("time", 0.5)),
				"rehit": 0.18, "angle": 50.0}, true)
			b["damage"] = dmg * 0.45
			b["push"] = float(a.push) * float(sig.get("push_mult", 1.0))
			if float(sig.get("pull", 0.0)) > 0.0: b["pull_force"] = float(sig.pull)
		"barrage":
			var hits: int = int(sig.get("hits", 5))
			b.merge({"x_min": -0.3, "range": float(sig.get("range", 2.0)), "y_min": -0.2, "y_max": 2.0, "active": 0.08 * hits,
				"rehit": 0.08, "angle": 30.0, "push": 0.15}, true)
			b["damage"] = dmg / hits * 1.5
		"power":
			b.merge({"x_min": -0.3, "range": 1.8, "y_min": -0.2, "y_max": 2.0, "active": 0.12, "recovery": 0.45, "angle": 38.0, "push": float(a.push) * 2.2}, true)
	return b

## Runs a signature at the start of its active frames.
func _sig_activate(i: int, ab: Dictionary) -> void:
	var f: Dictionary = fighters[i]
	var sig: Dictionary = ab.sig
	var dmg: float = float(ab.damage) * float(f.get("power_mult", 1.0))
	var col: Color = sig.get("color", Color.WHITE)
	var fx: float = float(f.facing)
	var spec: Dictionary = sig.duplicate()
	spec["kind"] = str(f.profile.get("family", "sig"))
	events.append({"type": "signature", "actor": i, "mech": sig.mech, "color": col, "name": ab.get("name", "")})
	match str(sig.mech):
		"projectile":
			var count: int = int(sig.get("count", 1))
			var spread: float = float(sig.get("spread", 0.18))
			for k in range(count):
				var ang: float = (k - (count - 1) * 0.5) * spread
				var speed: float = float(sig.get("speed", 12.0))
				var v := Vector2(fx * speed, float(sig.get("rise", 0.0))).rotated(ang * fx)
				spawn_projectile_spec(i, spec, dmg / maxf(1.0, count * 0.7), f.x + fx * 0.7, f.y + 1.15, v.x, v.y)
		"clone":
			spec.merge({"shape": "clone", "life": 0.65, "size": 0.7, "pierce": true, "push": 0.7, "angle": 40.0}, true)
			spawn_projectile_spec(i, spec, dmg, f.x + fx * 0.5, f.y + 0.9, fx * float(sig.get("speed", 10.0)), 0.0)
		"eruption":
			spec.merge({"shape": sig.get("shape", "pillar"), "life": 0.2 + 0.18 * int(sig.get("count", 3)), "size": 0.65, "pierce": true,
				"push": 0.8, "angle": 80.0}, true)
			spawn_projectile_spec(i, spec, dmg, f.x + fx * 0.9, f.y + 0.4, fx * float(sig.get("speed", 8.0)), 0.0)
		"meteor":
			var tx: float = f.x + fx * 3.0
			var opp: int = get_nearest_opponent(i)
			if opp >= 0 and absf(fighters[opp].x - f.x) < 7.0: tx = fighters[opp].x
			spec.merge({"shape": "meteor", "life": 2.0, "gravity": 14.0, "size": float(sig.get("size", 0.8))}, true)
			spawn_projectile_spec(i, spec, dmg, tx - fx * 2.0, f.y + 9.0, fx * 2.5, -6.0)
		"mine":
			spec.merge({"shape": sig.get("shape", "mine"), "life": float(sig.get("fuse", 9.0)), "size": 0.6,
				"explode": float(sig.get("explode", 2.0)), "push": 0.9, "angle": 70.0}, true)
			spawn_projectile_spec(i, spec, dmg, f.x + fx * 1.0, f.y + 0.2, 0.0, 0.0)
		"turret":
			spec.merge({"shape": "turret", "life": 3.6, "size": 0.0, "emit": 0.45, "pierce": true}, true)
			spawn_projectile_spec(i, spec, dmg, f.x + fx * 1.0, f.y + 0.6, 0.0, 0.0)
		"teleport":
			var opp2: int = get_nearest_opponent(i)
			if opp2 >= 0 and absf(fighters[opp2].x - f.x) < 9.0:
				var o: Dictionary = fighters[opp2]
				# Appear on the far side of the opponent, facing them.
				var side: float = signf(o.x - f.x) if absf(o.x - f.x) > 0.05 else fx
				events.append({"type": "teleport", "actor": i, "from_x": f.x, "from_y": f.y})
				f.x = o.x + side * 0.9
				f.y = o.y
				f.facing = -int(side)
				f.is_grounded = o.is_grounded
		"counter":
			f.counter = 0.45
		"rage":
			f.rage_timer = float(sig.get("time", 6.0))

## Air dash speeds (m/s). Every fighter has it: special in the air, once per airtime.
const AIR_DASH_SPEED := 11.5
const AIR_DASH_RISE := 6.8
const AIR_DASH_DIVE := -9.0

## Universal recovery dash. Direction: held left/right; without input towards the stage
## centre when off stage, otherwise forward. Holding down (block) dives instead of rising.
## Resets on landing, respawn and when hit.
func air_dash(i: int, axis: float, dive: bool = false, rise: bool = false) -> bool:
	var f: Dictionary = fighters[i]
	if f.is_grounded or f.air_dash_used or f.state != "Ready": return false
	var dir: float = float(f.facing)
	if absf(axis) > 0.25:
		dir = signf(axis)
	elif f.x < STAGE_LEFT or f.x > STAGE_RIGHT:
		dir = -signf(f.x)
	f.facing = 1 if dir > 0.0 else -1
	f.vx = dir * AIR_DASH_SPEED * (1.25 if f.speed_timer > 0.0 else 1.0)
	f.vy = AIR_DASH_DIVE if dive else maxf(f.vy, AIR_DASH_RISE)
	if rise:
		# Up + special: a steep climb for recovering from below the stage.
		f.vx = axis * AIR_DASH_SPEED * 0.4
		f.vy = AIR_DASH_SPEED * 0.95
	f.air_dash_used = true
	f.air_control_lock = 0.0
	f.pose = "SpecialAttack"
	f.pose_time = 0.22
	events.append({"type": "air_dash", "actor": i, "dir": dir, "dive": dive})
	return true

func release_grab_breakout(attacker_idx: int) -> void:
	var attacker: Dictionary = fighters[attacker_idx]
	var target_idx: int = attacker.grab_target
	if target_idx >= 0 and target_idx < fighters.size():
		var target: Dictionary = fighters[target_idx]
		target.state = "Ready"
		target.grabbed_by = -1
		target.grab_immunity = 0.65
		target.vx = -attacker.facing * 4.5
		target.vy = 2.0
	attacker.state = "Ready"
	attacker.grab_target = -1
	attacker.grab_timer = 0.0
	attacker.vx = attacker.facing * -2.5
	events.append({"type": "grab_breakout", "actor": attacker_idx, "target": target_idx})

## True if two different fighters are on the same team (team battles, story allies).
func is_ally(a: int, b: int) -> bool:
	return a != b and fighters[a].team == fighters[b].team

## Puts fighters into teams, e.g. [0, 1, 0, 1] for 2v2. Default: everyone for themselves.
func set_teams(teams: Array) -> void:
	for k in range(mini(teams.size(), fighters.size())):
		fighters[k].team = int(teams[k])

func get_nearest_opponent(fighter_idx: int) -> int:
	var f: Dictionary = fighters[fighter_idx]
	var best_idx := -1
	var min_dist := 99999.0
	for j in range(fighters.size()):
		if j == fighter_idx or is_ally(fighter_idx, j): continue
		var other: Dictionary = fighters[j]
		if other.state == "Defeated": continue
		var d: float = abs(float(other.x) - float(f.x)) + abs(float(other.y) - float(f.y))
		if d < min_dist:
			min_dist = d
			best_idx = j
	return best_idx

## Computer players. Each fighter "thinks" every few frames (fewer at higher levels) and
## holds its movement/shield in between – that is its reaction time. Button presses
## only happen on think frames. Memory lives in ai_memory, never in the match state.
func agent_commands() -> Array:
	var commands: Array = []
	while ai_memory.size() < fighters.size(): ai_memory.append({})
	for i in range(fighters.size()):
		commands.append(_ai_command(i))
	return commands

static func _idle_cmd() -> Dictionary:
	return {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false,
		"up": false, "down": false, "jump_held": true, "standard_held": false, "smash": false}

func _ai_command(i: int) -> Dictionary:
	var f: Dictionary = fighters[i]
	var c := _idle_cmd()
	if f.state == "Defeated" or f.state == "Dazed": return c
	var mem: Dictionary = ai_memory[i]
	if finish_phase:
		if i == finish_winner: return _ai_finisher(i, c, mem)
		return c
	var lvl: int = clampi(ai_level, 1, 9)
	var urgent: bool = f.state == "Ledge" or f.x < STAGE_LEFT or f.x > STAGE_RIGHT or (f.y < -0.3 and not f.is_grounded)
	var t: int = int(mem.get("t", 0)) - 1
	var plan: Dictionary = mem.get("plan", {})
	if t > 0 and not urgent:
		mem.t = t
		for held in ["move", "block", "up", "down"]:
			if plan.has(held): c[held] = plan[held]
		return c
	mem.t = (22 - lvl * 2) + ai_rng.randi_range(0, 3)
	plan = _ai_think(i, lvl)
	mem.plan = plan
	c.merge(plan, true)
	return c

func _ai_think(i: int, lvl: int) -> Dictionary:
	var f: Dictionary = fighters[i]
	var p := {}
	if f.state == "Ledge":
		if f.ledge_timer < 0.2 + (9 - lvl) * 0.08: return p
		var toward: float = -float(f.ledge)
		var r := ai_rng.randf()
		if r < 0.45: p.move = toward
		elif r < 0.7: p.jump = true
		elif r < 0.85: p.block = true
		else: p.standard = true
		return p
	var edge: float = STAGE_LEFT if f.x < 0.0 else STAGE_RIGHT
	var offstage: bool = f.x < STAGE_LEFT or f.x > STAGE_RIGHT
	if offstage or (f.y < -0.3 and not f.is_grounded):
		# Recovery: jump, then climbing dash, then air dodge towards the ledge.
		p.move = -signf(f.x)
		if f.vy < 1.5:
			if f.air_jumps > 0 and f.y < 0.8:
				p.jump = true
			elif not f.air_dash_used:
				p.special = true
				p.up = f.y < -0.6
			elif lvl >= 4 and not f.air_dodge_used and absf(f.x - edge) < 3.0 and f.y < 0.5:
				p.block = true
				p.up = f.y < -0.5
		return p
	var opp_idx: int = get_nearest_opponent(i)
	if opp_idx < 0: return p
	var o: Dictionary = fighters[opp_idx]
	var dx: float = o.x - f.x
	var adx: float = absf(dx)
	var dy: float = o.y - f.y
	var dir: float = signf(dx) if adx > 0.05 else float(f.facing)
	var reach: float = float(f.profile.standard.range)

	# Items: pick up close ones, throw carried ones at an aligned opponent.
	if f.state == "Carrying" and f.carried_item >= 0:
		if adx < 6.5 and absf(dy) < 1.6: p.grab = true
		else: p.move = dir
		return p
	for it in items:
		if (it.state == "resting" or it.state == "free") and absf(it.x - f.x) < 1.3 and absf(it.y - f.y) < 0.9 and f.is_grounded:
			p.grab = true
			return p

	# Defense: shield or roll away when an attack is coming.
	if f.is_grounded and not o.pending.is_empty() and adx < float(o.profile.standard.range) + 0.9 and absf(dy) < 1.6:
		var r := ai_rng.randf()
		if r < lvl * 0.07 and f.shield_hp > 15.0:
			p.block = true
			return p
		if lvl >= 5 and r < lvl * 0.09:
			p.block = true
			p.move = -dir
			return p
	# A shielding opponent gets grabbed.
	if o.blocking and adx < 1.3 and ai_rng.randf() < 0.2 + lvl * 0.07:
		p.grab = true
		return p

	if not f.is_grounded:
		if adx < reach + 0.4 and absf(dy) < 2.4:
			p.standard = true
			if dy > 0.9: p.up = true
			elif dy < -0.9: p.down = true
			else: p.move = dir
		else:
			p.move = dir
		return p

	# Grounded.
	if dy > 1.2 and adx < 1.4:
		p.standard = true
		p.up = true
		if o.damage_percent > 95.0 and lvl >= 4: p.smash = true
		return p
	if dy > 1.2:
		p.move = dir
		p.jump = adx < 3.0 and ai_rng.randf() < 0.55
		return p
	if dy < -1.0 and f.y > 0.3:
		p.down = true
		return p
	if adx <= reach * 0.95 and absf(dy) < 1.3:
		var r := ai_rng.randf()
		var kill_percent: float = 120.0 - lvl * 4.0
		if o.damage_percent > kill_percent and r < 0.3 + lvl * 0.05:
			p.smash = true
			p.standard = true
			p.move = dir
		elif r < 0.28:
			p.standard = true
		elif r < 0.5:
			p.standard = true
			p.move = dir
		elif r < 0.64:
			p.standard = true
			p.down = true
		elif r < 0.8 and f.cooldowns[1] <= 0.0:
			p.special = true
			p.move = dir
		else:
			p.grab = true
		return p
	if adx <= float(f.profile.special.range) and absf(dy) < 1.4 and f.cooldowns[1] <= 0.0 and ai_rng.randf() < 0.22:
		p.special = true
		p.move = dir
		return p
	p.move = dir
	if adx > 1.6 and adx < 3.5 and ai_rng.randf() < 0.1 + lvl * 0.02:
		p.jump = true
	# Edge guarding: do not follow an opponent off stage, wait at the edge instead.
	if (o.x < STAGE_LEFT or o.x > STAGE_RIGHT) and lvl >= 6 and absf(f.x - signf(o.x) * STAGE_RIGHT) < 1.2:
		p.move = 0.0
	return p

## The computer enters its finisher code when it wins (chance grows with the level).
func _ai_finisher(i: int, c: Dictionary, mem: Dictionary) -> Dictionary:
	var f: Dictionary = fighters[i]
	var loser: Dictionary = fighters[finish_loser]
	var toward: float = 1.0 if loser.x >= f.x else -1.0
	if not mem.has("fin_do"):
		mem.fin_do = ai_rng.randf() < 0.35 + ai_level * 0.07
		mem.fin_step = 0
		mem.fin_frame = 0
	if not mem.fin_do: return c
	if absf(loser.x - f.x) > 2.6:
		c.move = toward
		return c
	mem.fin_frame += 1
	if mem.fin_frame % 8 != 0: return c
	var code: Array = finisher_for(f.profile).code
	if mem.fin_step >= code.size(): return c
	match code[mem.fin_step]:
		"F": c.move = toward
		"B": c.move = -toward * 0.7
		"U": c.jump = true
		"D": c.down = true
		"A": c.standard = true
		"S": c.special = true
	mem.fin_step += 1
	return c

func spawn_random_item() -> void:
	var special_types := ["titan_mushroom", "invulnerable_star", "speed_boots", "smash_hammer", "health_heart", "freeze_orb"]
	if rng.randf() < 0.6:
		spawn_weapon(WEAPONS.keys()[rng.randi() % WEAPONS.size()])
		return
	var chosen_type: String = special_types[rng.randi() % special_types.size()]
	var target_plat: Dictionary = PLATFORMS[rng.randi() % PLATFORMS.size()]
	var px: float = rng.randf_range(target_plat.x1 + 0.3, target_plat.x2 - 0.3)
	var py: float = target_plat.y + 0.20

	var new_id: int = items.size()
	var it_dict := {
		"id": new_id,
		"type": chosen_type,
		"name": chosen_type.replace("_", " ").capitalize(),
		"start_x": px, "start_y": py, "x": px, "y": py,
		"vx": 0.0, "vy": 0.0, "weight": 0.5,
		"state": "resting",
		"carrier": -1, "thrower": -1, "respawn": 0.0,
		"damage": 25.0 if chosen_type == "freeze_orb" else 0.0,
		"push": 0.5, "angle": 35.0, "fragile": true if chosen_type == "freeze_orb" else false,
		"explosive": true if chosen_type == "freeze_orb" else false,
		"explosion_radius": 3.2,
		"special_power": chosen_type.replace("_boots", "").replace("_hammer", "").replace("_mushroom", "").replace("_heart", "").replace("_star", "").replace("_orb", "")
	}
	if chosen_type == "titan_mushroom": it_dict.special_power = "titan"; it_dict.name = "Titan-Pilz (Doppelte Gr\u00f6\u00dfe & St\u00e4rke)"
	elif chosen_type == "invulnerable_star": it_dict.special_power = "invulnerable"; it_dict.name = "Unsterblichkeits-Stern (10s)"
	elif chosen_type == "speed_boots": it_dict.special_power = "speed"; it_dict.name = "Hermes Blitz-Schuhe (Tempo +120%)"
	elif chosen_type == "smash_hammer": it_dict.special_power = "hammer"; it_dict.name = "Wucht-Kriegshammer"
	elif chosen_type == "health_heart": it_dict.special_power = "heal"; it_dict.name = "Herz-Container (+60 LP)"
	elif chosen_type == "freeze_orb": it_dict.special_power = "freeze"; it_dict.name = "Kryo-Frostbombe"

	items.append(it_dict)
	events.append({"type": "item_spawned", "item_id": new_id, "item_name": it_dict.name, "x": px, "y": py})

## ── Moveset ────────────────────────────────────────────────────────────────────
## Every fighter gets a full moveset derived from its prompt's two base attacks, so
## prompt balance carries over: jab, 3 tilts, 3 charged smashes, dash attack,
## 5 aerials and 3 directional specials. Hitboxes are boxes relative to the attacker
## (x forward, y up from the feet); moves without y_min use the classic reach check.
static func build_moveset(p: Dictionary) -> Dictionary:
	var std: Dictionary = p.standard
	var sp: Dictionary = p.special
	var d: float = float(std.damage)
	var r: float = float(std.range)
	var w: float = float(std.windup)
	var push: float = float(std.push)
	var m := {}
	m["jab"] = std.duplicate()
	m["ftilt"] = _mv(std.name + " · Vorstoß", d * 1.15, w + 0.03, 0.10, 0.20, -0.35, r * 1.08, -0.2, 1.8, 36.0, push * 1.35)
	m["utilt"] = _mv("Aufwärtshaken", d * 1.0, w + 0.02, 0.12, 0.20, -0.7, 0.95, 0.6, 2.8, 86.0, push * 1.4, true)
	m["dtilt"] = _mv("Fußfeger", d * 0.75, maxf(0.05, w * 0.7), 0.08, 0.16, -0.3, r * 0.95, -0.25, 0.7, 18.0, push * 1.05)
	m["fsmash"] = _mv("Wuchtschlag", d * 1.7, 0.16, 0.10, 0.34, -0.35, r * 1.15, -0.2, 1.9, 40.0, push * 2.3)
	m["usmash"] = _mv("Himmelsstoß", d * 1.55, 0.14, 0.14, 0.34, -0.9, 1.0, 0.5, 3.1, 88.0, push * 2.2, true)
	m["dsmash"] = _mv("Bodenwirbel", d * 1.45, 0.12, 0.12, 0.36, -r * 0.9, r * 0.9, -0.25, 0.9, 25.0, push * 2.0)
	m["dsmash"]["all_around"] = true
	m["dash_attack"] = _mv("Sturmlauf", d * 1.1, 0.08, 0.16, 0.26, -0.3, r * 1.0, -0.2, 1.8, 48.0, push * 1.6)
	m["dash_attack"]["motion_vx"] = 5.5
	m["nair"] = _mv("Luftwirbel", d * 0.9, 0.05, 0.16, 0.14, -1.0, 1.0, -0.4, 2.0, 42.0, push * 1.2)
	m["nair"]["all_around"] = true
	m["fair"] = _mv("Luftschlag", d * 1.15, 0.08, 0.10, 0.18, -0.3, r * 0.95, -0.3, 1.9, 40.0, push * 1.45)
	m["bair"] = _mv("Rückenkick", d * 1.3, 0.08, 0.10, 0.20, -r * 0.95, 0.3, -0.3, 1.9, 36.0, push * 1.7)
	m["bair"]["back"] = true
	m["uair"] = _mv("Luftsichel", d * 1.0, 0.06, 0.12, 0.16, -0.8, 0.8, 1.0, 3.0, 86.0, push * 1.35, true)
	m["dair"] = _mv("Meteorstoß", d * 1.2, 0.10, 0.12, 0.22, -0.7, 0.7, -1.4, 0.6, -70.0, push * 1.4, true)
	for key in ["nair", "fair", "bair", "uair", "dair"]:
		m[key]["aerial"] = true
	var ns: Dictionary = sp.duplicate()
	ns["special"] = true
	m["nspecial"] = ns
	var us := _mv(sp.name + " · Aufwind", float(sp.damage) * 0.6, 0.08, 0.20, 0.26, -0.6, 1.1, 0.0, 3.0, 82.0, float(sp.push) * 1.2, true)
	us["special"] = true
	us["cooldown"] = 1.2
	us["motion_vy"] = 8.5
	m["uspecial"] = us
	var ds := _mv(sp.name + " · Beben", float(sp.damage) * 0.55, 0.14, 0.14, 0.30, -2.2, 2.2, -0.25, 1.0, 58.0, float(sp.push) * 1.1)
	ds["special"] = true
	ds["cooldown"] = 1.6
	ds["all_around"] = true
	ds["type"] = "shockwave"
	m["dspecial"] = ds
	return m

static func _mv(name: String, damage: float, windup: float, active: float, recovery: float,
		x_min: float, x_max: float, y_min: float, y_max: float, angle: float, push: float, free_angle: bool = false) -> Dictionary:
	return {"name": name, "damage": damage, "windup": windup, "active": active, "recovery": recovery,
		"range": x_max, "x_min": x_min, "y_min": y_min, "y_max": y_max, "angle": angle,
		"push": push, "hitstun": 0.24, "cooldown": 0.0, "free_angle": free_angle}

const SMASH_OF := {"ftilt": "fsmash", "utilt": "usmash", "dtilt": "dsmash", "jab": "fsmash", "dash_attack": "fsmash"}

## Body box overlap for moves with explicit hitboxes; target body spans 0 … 1.6 above its feet.
static func move_box_hit(attacker: Dictionary, tx: float, ty: float, a: Dictionary, scale: float) -> bool:
	if not a.has("y_min"): return false
	var forward: float = (tx - float(attacker.x)) * float(attacker.facing)
	var x_min: float = float(a.x_min) * scale
	var x_max: float = float(a.range) * scale
	if bool(a.get("all_around", false)):
		if absf(forward) > maxf(absf(x_min), x_max): return false
	elif forward < x_min or forward > x_max:
		return false
	var box_lo: float = float(attacker.y) + float(a.y_min) * scale
	var box_hi: float = float(attacker.y) + float(a.y_max) * scale
	return ty <= box_hi and ty + 1.6 >= box_lo

## Reads one command, remembers held buttons and derives presses (edges).
static func read_input(f: Dictionary, cmd: Dictionary) -> Dictionary:
	var prev: Dictionary = f.get("_prev_in", {})
	var axis: float = clampf(float(cmd.get("move", 0.0)), -1.0, 1.0)
	var up: bool = bool(cmd.get("up", false))
	var down: bool = bool(cmd.get("down", false))
	var shield: bool = bool(cmd.get("block", false))
	var prev_axis: float = float(prev.get("axis", 0.0))
	var side := 0
	if absf(axis) > 0.6 and absf(prev_axis) <= 0.6: side = 1 if axis > 0.0 else -1
	var inp := {
		"axis": axis, "up": up, "down": down, "shield": shield,
		"jump": bool(cmd.get("jump", false)), "standard": bool(cmd.get("standard", false)),
		"special": bool(cmd.get("special", false)), "grab": bool(cmd.get("grab", false)),
		"standard_held": bool(cmd.get("standard_held", false)), "smash": bool(cmd.get("smash", false)),
		"jump_held": bool(cmd.get("jump_held", true)), "drop": bool(cmd.get("drop", false)),
		"shield_pressed": shield and not bool(prev.get("shield", false)),
		"down_pressed": down and not bool(prev.get("down", false)),
		"side_pressed": side,
	}
	f["_prev_in"] = {"shield": shield, "down": down, "axis": axis}
	f.in_x = axis
	f.in_y = (1.0 if up else 0.0) - (1.0 if down else 0.0)
	return inp

## Standard button: jab, tilts (or a charged smash when held), dash attack, aerials.
func _choose_standard(i: int, inp: Dictionary) -> void:
	var f: Dictionary = fighters[i]
	if f.carried_item >= 0:
		throw_carried_item(i)
		return
	# Standing on a weapon: attack picks it up (grab works too).
	if f.is_grounded and f.weapon.is_empty() and not inp.up and not inp.down:
		for k in range(items.size()):
			var it: Dictionary = items[k]
			if it.get("weapon", "") != "" and (it.state == "resting" or it.state == "free") and absf(it.x - f.x) < 0.9 and absf(it.y - f.y) < 0.8:
				equip_weapon(i, k)
				return
	var axis: float = inp.axis
	if not f.is_grounded:
		var key := "nair"
		if inp.up: key = "uair"
		elif inp.down: key = "dair"
		elif axis * f.facing > 0.3: key = "fair"
		elif axis * f.facing < -0.3: key = "bair"
		start_move(i, key)
		return
	if absf(axis) > 0.3: f.facing = 1 if axis > 0.0 else -1
	var key := "jab"
	if inp.up: key = "utilt"
	elif inp.down: key = "dtilt"
	elif absf(axis) > 0.3: key = "dash_attack" if f.run_time > RUN_TIME else "ftilt"
	if key == "jab" and f.hammer_timer > 0.0:
		queue_attack(i, false)
		return
	if inp.smash:
		start_move(i, SMASH_OF.get(key, "fsmash"), 1.3)
	elif inp.standard_held and key in ["ftilt", "utilt", "dtilt"]:
		f.state = "Charge"
		f.charge_key = key
		f.charge_time = 0.0
		f.pose = "Charge"
		events.append({"type": "charge", "actor": i})
	elif key == "jab":
		queue_attack(i, false)
	else:
		start_move(i, key)

func start_dodge(i: int, kind: String, dir: float, dir_y: float = 0.0) -> void:
	var f: Dictionary = fighters[i]
	f.state = "Dodge"
	f.walk_v = 0.0
	f.dodge_kind = kind
	f.dodge_dir = dir
	f.blocking = false
	f.pose = "Dodge"
	f.pose_time = 0.0
	match kind:
		"roll":
			f.dodge_timer = ROLL_TIME
			f.intangible = DODGE_INTANGIBLE
		"spot":
			f.dodge_timer = SPOT_DODGE_TIME
			f.intangible = SPOT_DODGE_TIME * 0.8
		"air":
			f.dodge_timer = AIR_DODGE_TIME
			f.intangible = DODGE_INTANGIBLE + 0.04
			f.air_dodge_used = true
			var v := Vector2(dir, dir_y)
			if v.length() > 0.2:
				v = v.normalized() * AIR_DODGE_SPEED
				f.vx = v.x
				f.vy = v.y
			else:
				f.vx *= 0.3
				f.vy = maxf(f.vy, 0.0) * 0.3
	events.append({"type": "dodge", "actor": i, "kind": kind})

func shield_break(i: int) -> void:
	var f: Dictionary = fighters[i]
	f.blocking = false
	f.shield_hp = 0.0
	f.state = "ShieldBreak"
	f.stun = SHIELD_BREAK_STUN
	f.pose = "Dazed"
	f.pose_time = 0.0
	f.pending = {}
	f.vy = 6.0
	f.is_grounded = false
	events.append({"type": "shield_break", "actor": i})

## Grabs a stage ledge when falling past it. Only one fighter per ledge: a newcomer
## pushes the current holder off ("trump").
func try_ledge_grab(i: int) -> bool:
	var f: Dictionary = fighters[i]
	for side in [-1, 1]:
		var edge: float = STAGE_LEFT if side == -1 else STAGE_RIGHT
		var out: float = (f.x - edge) * side
		if out < -0.2 or out > 1.1 or f.y > 0.05 or f.y < -1.9: continue
		for j in range(fighters.size()):
			if j != i and fighters[j].state == "Ledge" and fighters[j].ledge == side:
				var o: Dictionary = fighters[j]
				o.state = "Ready"
				o.ledge = 0
				o.intangible = 0.0
				o.vx = side * 2.5
				o.vy = 3.0
				o.ledge_cooldown = 0.6
				events.append({"type": "ledge_trump", "actor": i, "target": j})
		f.state = "Ledge"
		f.ledge = side
		f.ledge_timer = 0.0
		f.x = edge + side * 0.3
		f.y = LEDGE_HANG_Y
		f.vx = 0.0
		f.vy = 0.0
		f.facing = -side
		f.air_jumps = 2
		f.air_dash_used = false
		f.air_dodge_used = false
		f.intangible = LEDGE_INTANGIBLE[mini(f.ledge_grabs, LEDGE_INTANGIBLE.size() - 1)]
		f.ledge_grabs += 1
		f.pose = "Ledge"
		f.pose_time = 0.0
		f.pending = {}
		events.append({"type": "ledge_grab", "actor": i, "side": side, "grabs": f.ledge_grabs})
		return true
	return false

## Ledge options: climb (towards stage / up), jump, attack, roll (shield), drop (down / away).
func update_ledge(i: int, inp: Dictionary, dt: float) -> void:
	var f: Dictionary = fighters[i]
	f.ledge_timer += dt
	f.pose = "Ledge"
	var side: int = f.ledge
	var edge: float = STAGE_LEFT if side == -1 else STAGE_RIGHT
	var toward: float = -float(side)
	if f.ledge_timer < LEDGE_ACT_DELAY: return
	var action := ""
	if f.ledge_timer >= LEDGE_MAX_HANG: action = "drop"
	elif inp.jump: action = "jump"
	elif inp.standard or inp.special: action = "attack"
	elif inp.shield_pressed: action = "roll"
	elif inp.up or inp.axis * toward > 0.5: action = "climb"
	elif inp.down or inp.axis * toward < -0.5: action = "drop"
	if action.is_empty(): return
	f.ledge = 0
	f.state = "Ready"
	match action:
		"drop":
			f.ledge_cooldown = 0.45
			f.intangible = 0.0
		"jump":
			f.vy = JUMP_FORCE * 1.05
			f.vx = toward * 1.5
			f.ledge_cooldown = 0.3
			events.append({"type": "jump", "actor": i})
		"climb", "attack", "roll":
			f.x = edge + toward * 0.45
			f.y = 0.0
			f.vy = 0.0
			f.is_grounded = true
			f.intangible = 0.25
			f.facing = int(toward)
			if action == "attack":
				start_move(i, "dtilt")
			elif action == "roll":
				start_dodge(i, "roll", toward)
			events.append({"type": "ledge_climb", "actor": i, "action": action})

## Finisher code per element group. Tokens: F/B (forward/back towards the loser),
## U (jump), D (down), A (attack), S (special).
static func finisher_for(p: Dictionary) -> Dictionary:
	var e: String = str(p.get("element", "")).to_lower()
	if e.contains("fire") or e.contains("flame") or e.contains("lava") or e.contains("sun") or e.contains("blood") or e.contains("gold"):
		return {"kind": "inferno", "name": "EINÄSCHERN", "code": ["F", "F", "S"]}
	if e.contains("ice") or e.contains("frost") or e.contains("water") or e.contains("holy"):
		return {"kind": "frost", "name": "EISSARG", "code": ["D", "F", "S"]}
	if e.contains("electric") or e.contains("wind") or e.contains("plasma") or e.contains("storm") or e.contains("claw") or e.contains("arrow"):
		return {"kind": "storm", "name": "HIMMELSZORN", "code": ["U", "D", "S"]}
	if e.contains("void") or e.contains("shadow") or e.contains("dark") or e.contains("gravity") or e.contains("soul") or e.contains("death") or e.contains("ki_purple"):
		return {"kind": "void", "name": "LEERENSOG", "code": ["B", "B", "S"]}
	return {"kind": "titan", "name": "KOPFJÄGER", "code": ["D", "D", "A"]}

static func code_text(code: Array) -> String:
	var names := {"F": "→", "B": "←", "U": "↑", "D": "↓", "A": "SCHLAG", "S": "SPEZIAL"}
	var parts: Array = []
	for t in code: parts.append(names.get(t, t))
	return " ".join(parts)

func _record_finish_tokens(i: int, inp: Dictionary) -> void:
	var f: Dictionary = fighters[i]
	var loser: Dictionary = fighters[finish_loser]
	var toward: int = 1 if loser.x >= f.x else -1
	var toks: Array = []
	if inp.side_pressed != 0: toks.append("F" if inp.side_pressed == toward else "B")
	if inp.jump: toks.append("U")
	if inp.down_pressed: toks.append("D")
	if inp.standard: toks.append("A")
	if inp.special: toks.append("S")
	for t in toks:
		f._tokens.append([t, elapsed])
	while f._tokens.size() > 8: f._tokens.pop_front()

func _finish_code_entered(i: int) -> bool:
	var f: Dictionary = fighters[i]
	var code: Array = finisher_for(f.profile).code
	if f._tokens.size() < code.size(): return false
	var tail: Array = f._tokens.slice(f._tokens.size() - code.size())
	if elapsed - float(tail[0][1]) > FINISH_INPUT_WINDOW: return false
	for k in range(code.size()):
		if tail[k][0] != code[k]: return false
	return true

func _start_finish_phase(winner: int, loser: int) -> void:
	finish_phase = true
	finish_timer = FINISH_TIME
	finish_winner = winner
	finish_loser = loser
	var w: Dictionary = fighters[winner]
	var l: Dictionary = fighters[loser]
	l.state = "Dazed"
	l.pose = "Dazed"
	l.x = clampf(w.x + w.facing * 2.2, STAGE_LEFT + 1.0, STAGE_RIGHT - 1.0)
	l.y = 0.0
	l.vx = 0.0
	l.vy = 0.0
	l.is_grounded = true
	l.facing = -1 if w.x > l.x else 1
	l.intangible = FINISH_TIME + 1.0
	w._tokens.clear()
	var fin: Dictionary = finisher_for(w.profile)
	events.append({"type": "finish_him", "actor": winner, "target": loser, "code": fin.code, "name": fin.name})

func _end_finish_phase(executed: bool) -> void:
	finish_phase = false
	var w: Dictionary = fighters[finish_winner]
	var l: Dictionary = fighters[finish_loser]
	result = finish_winner
	l.state = "Defeated"
	l.pose = "Defeat"
	w.state = "Ready"
	w.pose = "Victory"
	w.pending = {}
	if executed:
		var fin: Dictionary = finisher_for(w.profile)
		events.append({"type": "finisher", "actor": finish_winner, "target": finish_loser, "kind": fin.kind, "name": fin.name})
	events.append({"type": "finish", "winner": result, "finisher": executed})

## Picks the body pose while no move is running, so fighters visibly run, jump, fall,
## block and carry instead of gliding around in their idle pose.
static func update_locomotion_pose(f: Dictionary) -> void:
	if not (f.state == "Ready" or f.state == "Carrying") or f.pose_time > 0.0 or not f.pending.is_empty():
		return
	if f.state == "Carrying":
		f.pose = "Carrying"
	elif f.blocking:
		f.pose = "Block"
	elif not f.is_grounded:
		f.pose = "Jump" if f.vy > 0.5 else "Fall"
	elif f.moving:
		f.pose = "Move"
	elif f.get("crouching", false):
		f.pose = "Crouch"
	else:
		f.pose = "Idle"

## Soft body push: grounded fighters standing inside each other are eased apart
## (like the genre standard) instead of passing through. Pairs are processed in
## index order so the result is deterministic.
func resolve_body_push() -> void:
	for i in range(fighters.size()):
		var a: Dictionary = fighters[i]
		if not _can_body_push(a): continue
		for j in range(i + 1, fighters.size()):
			var b: Dictionary = fighters[j]
			if not _can_body_push(b): continue
			if absf(float(a.y) - float(b.y)) > 0.5: continue
			var dx: float = float(b.x) - float(a.x)
			var overlap: float = BODY_SEPARATION - absf(dx)
			if overlap <= 0.0: continue
			var dir: float = signf(dx) if absf(dx) > 0.0001 else 1.0
			var shift: float = overlap * 0.5 * BODY_PUSH_RATE
			a.x -= dir * shift
			b.x += dir * shift
			for f in [a, b]:
				if absf(f.y) < 0.01:
					f.x = clampf(f.x, STAGE_LEFT, STAGE_RIGHT)

## How far behind the attacker's origin a hitbox still reaches (bodies overlap).
const HITBOX_BACK_REACH := 0.35
## Special types that hit on both sides of the attacker.
const ALL_AROUND_TYPES := ["radial", "radial_blast", "shockwave", "ground_quake"]

static func is_all_around(ability: Dictionary) -> bool:
	return str(ability.get("type", "")) in ALL_AROUND_TYPES or float(ability.get("angle", 0.0)) >= 360.0

## True if a point lies inside the attacker's reach. Directional attacks only hit
## in front of the attacker; all-around attacks hit both sides.
static func in_attack_reach(attacker: Dictionary, tx: float, ty: float, reach: float, height: float, all_around: bool) -> bool:
	if absf(ty - float(attacker.y)) > height: return false
	var forward: float = (tx - float(attacker.x)) * float(attacker.facing)
	if all_around: return absf(forward) <= reach
	return forward >= -HITBOX_BACK_REACH and forward <= reach

## Landing resets air options; aerials end with landing lag; a downward air dodge slides.
func _on_land(i: int) -> void:
	var f: Dictionary = fighters[i]
	f.walk_v = 0.0
	f.air_dodge_used = false
	f.ledge_grabs = 0
	f.erase("_hop_frames")
	if not f.pending.is_empty() and bool(f.pending.ability.get("aerial", false)):
		f.pending = {}
		f.state = "Attack"
		f.pose = "Crouch"
		f.pose_time = LANDING_LAG
	if f.state == "Dodge" and f.dodge_kind == "air":
		f.state = "Ready"
		f.pose = "Idle"
		if absf(f.vx) > 2.0:
			f.slide = 0.25
			events.append({"type": "flux_dash", "actor": i})

func _can_body_push(f: Dictionary) -> bool:
	return f.state != "Defeated" and f.state != "Grabbed" and f.state != "Dazed" and f.state != "Dodge" and f.grab_target < 0 and f.is_grounded

func tick(commands: Array, dt: float = STEP) -> void:
	events.clear()
	if result != -2 or fighters.is_empty(): return
	if countdown > 0:
		countdown = maxf(0.0, countdown - dt)
		return
	elapsed += dt
	if not finish_phase: time_left = maxf(0.0, time_left - dt)
	var eliminated_now := -1
	if finish_phase:
		finish_timer -= dt

	# Dynamic Item Spawning
	item_spawn_timer -= dt
	if item_spawn_timer <= 0.0:
		item_spawn_timer = rng.randf_range(13.0, 18.0)
		var active_items_count := 0
		for it in items:
			if it.state != "destroyed": active_items_count += 1
		if active_items_count < 6:
			spawn_random_item()

	# ── Fighter Updates ────────────────────────────────────────────────────────
	for i in range(fighters.size()):
		var f: Dictionary = fighters[i]
		if f.state == "Defeated" or f.state == "Dazed": continue
		var inp: Dictionary = read_input(f, commands[i] if i < commands.size() else {})
		if finish_phase and i == finish_winner:
			_record_finish_tokens(i, inp)
			# During the finisher window only movement and the code count, no attacks.
			var fl: Dictionary = fighters[finish_loser]
			if _finish_code_entered(i) and absf(fl.x - f.x) <= FINISH_RANGE and absf(fl.y - f.y) < 3.0:
				_end_finish_phase(true)
				return
			inp.standard = false
			inp.special = false
			inp.grab = false
			inp.smash = false

		# Hitstop freeze
		if f.hitstop > 0:
			f.hitstop -= 1
			continue

		# Cooldowns & Timers
		f.cooldowns[0] = maxf(0.0, f.cooldowns[0] - dt)
		f.cooldowns[1] = maxf(0.0, f.cooldowns[1] - dt)
		if f.stun > 0:
			f.stun = maxf(0.0, f.stun - dt)
			if f.stun <= 0.0 and (f.state == "HitStun" or f.state == "ShieldBreak"):
				f.state = "Ready"
				f.pose = "Idle"
		if f.intangible > 0: f.intangible = maxf(0.0, f.intangible - dt)
		if f.counter > 0: f.counter = maxf(0.0, f.counter - dt)
		if f.rage_timer > 0: f.rage_timer = maxf(0.0, f.rage_timer - dt)
		if f.ledge_cooldown > 0: f.ledge_cooldown = maxf(0.0, f.ledge_cooldown - dt)
		if f.slide > 0: f.slide = maxf(0.0, f.slide - dt)
		if f.blocking:
			f.shield_hp = maxf(0.0, f.shield_hp - SHIELD_DRAIN * dt)
			if f.shield_hp <= 0.0: shield_break(i)
		else:
			f.shield_hp = minf(SHIELD_MAX, f.shield_hp + SHIELD_REGEN * dt)

		if f.pose_time > 0:
			f.pose_time = maxf(0.0, f.pose_time - dt)
			if f.pose_time <= 0:
				if f.state in ["Throw", "Attack"]:
					f.state = "Ready"
				f.pose = "Idle"

		if f.drop_through > 0: f.drop_through = maxf(0.0, f.drop_through - dt)
		if f.invulnerable > 0: f.invulnerable = maxf(0.0, f.invulnerable - dt)
		if f.grab_immunity > 0: f.grab_immunity = maxf(0.0, f.grab_immunity - dt)
		if f.slow_timer > 0: f.slow_timer = maxf(0.0, f.slow_timer - dt)
		if f.air_control_lock > 0: f.air_control_lock = maxf(0.0, f.air_control_lock - dt)

		# Special Item Timers
		if f.titan_timer > 0: f.titan_timer = maxf(0.0, f.titan_timer - dt)
		if f.speed_timer > 0: f.speed_timer = maxf(0.0, f.speed_timer - dt)
		if f.hammer_timer > 0: f.hammer_timer = maxf(0.0, f.hammer_timer - dt)
		if f.freeze_timer > 0:
			f.freeze_timer = maxf(0.0, f.freeze_timer - dt)
			if f.freeze_timer <= 0.0 and f.state == "HitStun":
				f.state = "Ready"
				f.pose = "Idle"

		# Combo timer decay
		if f.combo_timer > 0:
			f.combo_timer -= dt
			if f.combo_timer <= 0:
				if f.combo > 1:
					events.append({"type": "combo_end", "actor": i, "count": f.combo})
				f.combo = 0

		if f.parry_timer > 0: f.parry_timer -= dt
		f.super = minf(MAX_SUPER, f.super + dt * 2.2)

		# Auto-touch instant items on ground (Star, Titan, Speed, Heart)
		for it_idx in range(items.size()):
			var it_obj: Dictionary = items[it_idx]
			if it_obj.state == "resting" or it_obj.state == "free":
				if it_obj.get("special_power", "") in ["titan", "invulnerable", "speed", "hammer", "heal"]:
					if abs(it_obj.x - f.x) < 1.15 and abs(it_obj.y - f.y) < 1.0:
						apply_special_powerup(i, it_obj)
						it_obj.state = "destroyed"
						it_obj.respawn = 18.0

		if f.state == "Ledge":
			update_ledge(i, inp, dt)
			if f.state == "Ledge": continue

		if f.state == "Dodge":
			f.dodge_timer -= dt
			if f.dodge_kind == "roll":
				f.x = clampf(f.x + f.dodge_dir * ROLL_SPEED * dt, STAGE_LEFT, STAGE_RIGHT) if absf(f.y) < 0.01 else f.x + f.dodge_dir * ROLL_SPEED * dt
			if f.dodge_timer <= 0.0:
				f.state = "Ready"
				f.pose = "Idle"

		if f.state == "Charge":
			f.charge_time += dt
			f.pose = "Charge"
			if not inp.standard_held or f.charge_time >= SMASH_MAX_CHARGE or not f.is_grounded:
				f.state = "Ready"
				var ckey: String = f.charge_key
				if f.charge_time < SMASH_TAP_TIME:
					start_move(i, ckey)
				else:
					start_move(i, SMASH_OF.get(ckey, "fsmash"), 1.0 + 0.5 * minf(f.charge_time / SMASH_MAX_CHARGE, 1.0))

		# Facing: while grounded and able to act, held direction decides; with no input the
		# fighter turns towards the nearest opponent. Attacks never turn the fighter mid-move.
		if f.state == "Ready" or (f.state == "Carrying" and f.carried_item >= 0):
			var face_axis: float = float(commands[i].get("move", 0.0)) if i < commands.size() else 0.0
			if f.is_grounded and absf(face_axis) > 0.25:
				f.facing = 1 if face_axis > 0.0 else -1
			elif absf(face_axis) <= 0.25:
				var opp_idx: int = get_nearest_opponent(i)
				if opp_idx >= 0 and absf(float(fighters[opp_idx].x) - float(f.x)) > 0.05:
					f.facing = 1 if fighters[opp_idx].x > f.x else -1

		# Horizontal physics & speed multiplier
		var speed_scale: float = 1.0
		if f.slow_timer > 0.0: speed_scale *= 0.50
		if f.speed_timer > 0.0: speed_scale *= 2.20
		if f.rage_timer > 0.0: speed_scale *= 1.25
		if f.carried_item >= 0: speed_scale *= 0.85
		if f.freeze_timer > 0.0: speed_scale = 0.0

		var friction: float = (8.0 if f.slide > 0.0 else 26.0) if f.is_grounded else 6.5
		if abs(f.vx) > 0.05:
			f.x += f.vx * dt
			f.vx = move_toward(f.vx, 0.0, friction * dt)

		# Grab execution
		if f.state == "Grab" and f.freeze_timer <= 0.0:
			f.grab_timer -= dt
			if f.grab_timer <= 0.0:
				var grabbed_target := -1
				for ti in range(fighters.size()):
					if ti == i or is_ally(i, ti): continue
					var target_f: Dictionary = fighters[ti]
					if target_f.state == "Defeated" or target_f.invulnerable > 0 or target_f.grab_immunity > 0: continue
					if abs(target_f.x - f.x) <= 1.35 and abs(target_f.y - f.y) <= 1.05:
						grabbed_target = ti
						break

				if grabbed_target >= 0:
					var target_f: Dictionary = fighters[grabbed_target]
					f.state = "Carrying"
					f.grab_target = grabbed_target
					f.grab_timer = 1.3
					target_f.state = "Grabbed"
					target_f.grabbed_by = i
					target_f.stun = 1.3
					target_f.is_grounded = f.is_grounded
					target_f.vx = 0.0
					target_f.vy = 0.0
					target_f.pose = "HitReact"
					target_f.pose_time = 1.3
					events.append({"type": "grab_success", "actor": i, "target": grabbed_target})
				else:
					f.state = "Ready"
					f.stun = 0.25
					f.pose = "HitReact"
					f.pose_time = 0.25
					events.append({"type": "grab_miss", "actor": i})

		elif f.state == "Carrying" and f.grab_target >= 0:
			var target_f: Dictionary = fighters[f.grab_target]
			target_f.x = f.x + f.facing * 0.75
			target_f.y = f.y
			f.grab_timer -= dt
			if f.grab_timer <= 0.0:
				release_grab_breakout(i)
			elif i < commands.size():
				var cmd: Dictionary = commands[i]
				var axis := clampf(float(cmd.get("move", 0)), -1.0, 1.0)
				var want_jump: bool = bool(cmd.get("jump", false))
				if want_jump or cmd.get("special", false):
					execute_throw(i, "up")
				elif abs(axis) > 0.25:
					if sign(axis) == f.facing: execute_throw(i, "forward")
					else: execute_throw(i, "back")
				elif cmd.get("standard", false) or cmd.get("grab", false):
					execute_throw(i, "forward")

		# Commands input processing
		if i < commands.size() and (f.state == "Ready" or (f.state == "Carrying" and f.carried_item >= 0)) and f.pending.is_empty() and f.freeze_timer <= 0.0:
			f.moving = false
			f.crouching = false
			var axis: float = inp.axis
			var want_drop_down: bool = (inp.shield and inp.jump) or inp.drop or (inp.down_pressed and not inp.shield)
			if want_drop_down and f.y > 0.2 and f.is_grounded:
				f.is_grounded = false
				f.y -= 0.14
				f.vy = -3.2
				f.drop_through = 0.40
				f.blocking = false
				events.append({"type": "drop_through", "actor": i})
			elif f.is_grounded and inp.shield and f.carried_item < 0 and not inp.jump:
				# Shield, parry (fresh press), roll (shield + side), spot dodge (shield + down), shield grab.
				if inp.side_pressed != 0 or (inp.shield_pressed and absf(axis) > 0.6):
					start_dodge(i, "roll", float(inp.side_pressed) if inp.side_pressed != 0 else signf(axis))
				elif inp.down_pressed or (inp.shield_pressed and inp.down):
					start_dodge(i, "spot", 0.0)
				elif inp.grab:
					f.blocking = false
					initiate_grab(i)
				elif f.shield_hp > 0.0:
					f.blocking = true
					if f.pose_time <= 0: f.pose = "Block"
					if inp.shield_pressed:
						f.parry_timer = PARRY_WINDOW
						f.parry_used = false
			elif not f.is_grounded and inp.shield_pressed and not f.air_dodge_used and f.carried_item < 0:
				start_dodge(i, "air", axis, (1.0 if inp.up else 0.0) - (1.0 if inp.down else 0.0))
			else:
				f.blocking = false
				# Up + attack on the ground is an up attack, not a jump.
				var up_attack: bool = f.is_grounded and inp.up and (inp.standard or inp.special)
				if inp.jump and not up_attack:
					if f.is_grounded:
						f.vy = JUMP_FORCE * (1.15 if f.speed_timer > 0 else 1.0)
						f.y += 0.05
						f.is_grounded = false
						f.air_jumps = 2
						f.air_dash_used = false
						f["_hop_frames"] = 0
						f.walk_v = 0.0
						events.append({"type": "jump", "actor": i})
					elif f.air_jumps > 0 and f.vy < 4.5:
						f.air_jumps -= 1
						f.vy = JUMP_FORCE * 0.95
						if f.x < STAGE_LEFT: f.vx = maxf(f.vx, 3.8)
						elif f.x > STAGE_RIGHT: f.vx = minf(f.vx, -3.8)
						events.append({"type": "double_jump", "actor": i})

				if absf(axis) > 0.05:
					if f.is_grounded:
						f.run_time += dt
						var run: float = RUN_SPEED_MULT if f.run_time > RUN_TIME else 1.0
						var target_v: float = axis * f.profile.speed * speed_scale * run
						f.walk_v = move_toward(f.walk_v, target_v, GROUND_ACCEL * dt)
						f.x += f.walk_v * dt
						f.moving = true
					elif f.air_control_lock <= 0.0:
						f.x += axis * f.profile.speed * speed_scale * 0.90 * dt
						f.moving = true

					# Walking stops at the main stage edge (no accidental self-destructs);
					# leaving the stage requires a jump or being launched.
					if f.is_grounded and absf(f.y) < 0.01:
						f.x = clampf(f.x, STAGE_LEFT, STAGE_RIGHT)
				else:
					f.run_time = 0.0
					f.crouching = f.is_grounded and inp.down
					if f.is_grounded and absf(f.walk_v) > 0.01:
						# Short slide to a stop.
						f.walk_v = move_toward(f.walk_v, 0.0, GROUND_DECEL * dt)
						f.x += f.walk_v * dt
						if absf(f.y) < 0.01: f.x = clampf(f.x, STAGE_LEFT, STAGE_RIGHT)

				if inp.grab:
					if f.carried_item >= 0:
						throw_carried_item(i)
					elif not f.weapon.is_empty():
						throw_weapon(i)
					else:
						initiate_grab(i)
				elif inp.special and not f.is_grounded and f.carried_item < 0:
					# In the air the special button is a universal recovery dash (once per airtime);
					# up + special climbs steeply, down + special (or shield) dives.
					air_dash(i, axis, inp.down or inp.shield, inp.up)
				elif inp.special and f.carried_item < 0:
					if absf(axis) > 0.25: f.facing = 1 if axis > 0.0 else -1
					if inp.up: start_move(i, "uspecial")
					elif inp.down: start_move(i, "dspecial")
					else: queue_attack(i, true)
				elif inp.standard or inp.smash:
					_choose_standard(i, inp)

		# Short hop: releasing jump early cuts the rise.
		if not f.is_grounded and f.has("_hop_frames"):
			f._hop_frames += 1
			if not inp.jump_held and f._hop_frames <= 5 and f.vy > 0.0:
				f.vy *= 0.6
				f.erase("_hop_frames")
			elif f._hop_frames > 5:
				f.erase("_hop_frames")
		# Fast fall: tap down while falling.
		if not f.is_grounded and inp.down_pressed and f.vy < 2.0 and f.state == "Ready":
			f.vy = minf(f.vy, -13.0)
			events.append({"type": "fast_fall", "actor": i})

		# Vertical physics & Landing
		var prev_y: float = f.y
		if not f.is_grounded and f.state != "Grabbed":
			f.vy -= GRAVITY * dt
			var next_y: float = f.y + f.vy * dt
			var landed := false

			if f.vy <= 0.0:
				if f.drop_through <= 0.0:
					for plat in PLATFORMS:
						if f.x >= plat.x1 - 0.20 and f.x <= plat.x2 + 0.20:
							if prev_y >= plat.y - 0.15 and next_y <= plat.y + 0.25:
								f.y = plat.y
								f.vy = 0.0
								f.is_grounded = true
								f.air_jumps = 2
								f.air_dash_used = false
								landed = true
								_on_land(i)
								break
				if not landed and f.x >= STAGE_LEFT - 0.25 and f.x <= STAGE_RIGHT + 0.25:
					if prev_y >= -0.15 and next_y <= 0.25:
						f.y = 0.0
						f.vy = 0.0
						f.is_grounded = true
						f.air_jumps = 2
						f.air_dash_used = false
						landed = true
						_on_land(i)

			if not landed:
				f.y = next_y
		elif f.is_grounded:
			var on_ground := false
			var target_plat_y := 0.0
			if f.drop_through <= 0.0:
				for plat in PLATFORMS:
					if f.x >= plat.x1 - 0.20 and f.x <= plat.x2 + 0.20 and abs(f.y - plat.y) < 0.35:
						on_ground = true
						target_plat_y = plat.y
						break
			if not on_ground and f.x >= STAGE_LEFT - 0.25 and f.x <= STAGE_RIGHT + 0.25 and abs(f.y) < 0.35:
				on_ground = true
				target_plat_y = 0.0

			if on_ground:
				f.y = target_plat_y
				f.vy = 0.0
			else:
				f.is_grounded = false

		# Nobody hangs inside the stage body: a fighter below floor level is pushed out sideways.
		if f.y < -0.05 and f.y > -4.5 and f.x > STAGE_LEFT and f.x < STAGE_RIGHT:
			f.x = STAGE_LEFT - 0.01 if f.x - STAGE_LEFT < STAGE_RIGHT - f.x else STAGE_RIGHT + 0.01
			f.vx = 0.0
		if not f.is_grounded and f.state == "Ready" and f.pending.is_empty() and f.vy <= 0.5 \
				and f.ledge_cooldown <= 0.0 and f.ledge_grabs < LEDGE_MAX_GRABS and f.carried_item < 0:
			try_ledge_grab(i)

		update_locomotion_pose(f)

		# Blast zones & ring-out: out of bounds costs one stock
		var out_of_bounds: bool = (
			f.x < BLAST_ZONE_LEFT or
			f.x > BLAST_ZONE_RIGHT or
			f.y < BLAST_ZONE_BOTTOM or
			f.y > BLAST_ZONE_TOP
		)

		# Blast zones always apply: invulnerability protects from hits, not from the stage bounds
		# (previously an invulnerable fighter could fall forever).
		if out_of_bounds:
			var ko_x: float = f.x
			var ko_y: float = f.y
			if not f.weapon.is_empty(): drop_weapon(i, "break")
			f.lives -= 1
			if f.carried_item >= 0:
				var it: Dictionary = items[f.carried_item]
				it.state = "free"
				it.carrier = -1
				it.vx = 0.0
				it.vy = 1.0
				f.carried_item = -1

			if f.grab_target >= 0:
				fighters[f.grab_target].state = "Ready"
				fighters[f.grab_target].grabbed_by = -1
				f.grab_target = -1

			if f.lives > 0:
				f.damage_percent = 0.0
				f.hp = 100.0
				var respawn_points := [-5.0, 5.0, -1.8, 1.8]
				f.x = respawn_points[i % respawn_points.size()]
				f.y = 4.20
				f.vx = 0.0
				f.vy = 0.0
				f.is_grounded = false
				f.air_jumps = 2
				f.air_dash_used = false
				f.invulnerable = 2.5
				f.stun = 0.0
				f.state = "Ready"
				f.pose = "Idle"
				events.append({"type": "ring_out", "actor": i, "lives": f.lives, "damage_percent": 0.0, "x": ko_x, "y": ko_y})
				events.append({"type": "respawn", "actor": i})
			else:
				f.damage_percent = 0.0
				f.hp = 0.0
				f.state = "Defeated"
				f.pose = "Defeat"
				f.ledge = 0
				eliminated_now = i
				events.append({"type": "ring_out", "actor": i, "lives": 0, "damage_percent": 0.0, "x": ko_x, "y": ko_y})
				events.append({"type": "fighter_eliminated", "actor": i})

	resolve_body_push()

	# ── Contact resolution (Attacks against all enemies) ────────────────────────
	var contacts: Array = []
	for i in range(fighters.size()):
		var f: Dictionary = fighters[i]
		if f.pending.is_empty(): continue
		f.pending.remaining -= dt

		if f.pending.stage == "windup" and f.pending.remaining <= 0:
			f.pending.stage = "active"
			f.pending.remaining = f.pending.active_time
			f.pose = f.pending.get("pose", "SpecialAttack" if f.pending.special else "Attack")
			var ab: Dictionary = f.pending.ability
			if ab.has("sig"): _sig_activate(i, ab)
			if ab.has("spawn"): spawn_projectile(i, str(ab.spawn))
			if bool(ab.get("breaks_weapon", false)): drop_weapon(i, "break")
			if ab.has("motion_vx"): f.vx = f.facing * float(ab.motion_vx)
			if ab.has("motion_vy"):
				f.vy = float(ab.motion_vy)
				f.is_grounded = false

		if f.pending.stage == "active":
			# Hitboxes stay live for the whole active window; each target is hit once per move
			# (multi-hit moves clear the list every `rehit` seconds).
			var attack: Dictionary = f.pending
			if attack.ability.has("rehit"):
				attack.rehit_t += dt
				if attack.rehit_t >= float(attack.ability.rehit):
					attack.rehit_t = 0.0
					attack.hit_list = []
			if attack.ability.has("pull_force"):
				for ti in range(fighters.size()):
					if ti == i or is_ally(i, ti): continue
					var pt: Dictionary = fighters[ti]
					if pt.state in ["Defeated", "Dazed", "Ledge"] or pt.intangible > 0.0: continue
					var dxp: float = f.x - pt.x
					if absf(dxp) < float(attack.ability.range) + 1.0 and absf(pt.y - f.y) < 2.5:
						pt.x += signf(dxp) * float(attack.ability.pull_force) * dt * (1.0 if absf(dxp) > 0.5 else 0.0)
			var size_mult: float = 1.5 if f.titan_timer > 0 else 1.0
			var attack_range: float = attack.ability.range * size_mult
			var all_around: bool = is_all_around(attack.ability) or bool(attack.ability.get("all_around", false))
			var hit_list: Array = attack.get("hit_list", [])
			for ti in range(fighters.size()):
				if bool(attack.ability.get("no_hit", false)): break
				if ti == i or is_ally(i, ti) or ti in hit_list: continue
				var target_f: Dictionary = fighters[ti]
				if target_f.state == "Defeated" or target_f.state == "Dazed": continue
				var touches: bool = move_box_hit(f, target_f.x, target_f.y, attack.ability, size_mult) if attack.ability.has("y_min") \
					else in_attack_reach(f, target_f.x, target_f.y, attack_range, 1.5, all_around)
				if touches:
					hit_list.append(ti)
					contacts.append({"from": i, "to": ti, "attack": attack})
			attack["hit_list"] = hit_list
			if not f.pending.hit_done:
				f.pending.hit_done = true
				for it_k in range(items.size()):
					var it_obj: Dictionary = items[it_k]
					if it_obj.state != "destroyed" and it_obj.get("explosive", false):
						if in_attack_reach(f, it_obj.x, it_obj.y, attack.ability.range + 0.4, 1.4, all_around):
							explode_item(it_k)

			if f.pending.remaining <= 0:
				f.pending.stage = "recovery"
				f.pending.remaining = f.pending.recovery_time

		if f.pending.stage == "recovery" and f.pending.remaining <= 0:
			f.pending = {}
			if f.state == "Attack": f.state = "Ready"
			f.pose = "Idle"
			f.pose_time = 0.0

	_update_projectiles(dt, contacts)
	var ci := 0
	while ci < contacts.size():
		var contact: Dictionary = contacts[ci]
		ci += 1
		var attacker: Dictionary = fighters[contact.from]
		var target: Dictionary = fighters[contact.to]
		var a: Dictionary = contact.attack.ability
		var is_special: bool = contact.attack.special
		# Launch away from the attacker: facing for directional hits, relative side for all-around hits.
		var push_dir: float = float(contact.get("push_dir", attacker.facing))
		if bool(a.get("back", false)): push_dir = -push_dir
		if (is_all_around(a) or bool(a.get("all_around", false))) and absf(float(target.x) - float(attacker.x)) > 0.01:
			push_dir = signf(float(target.x) - float(attacker.x))

		if target.invulnerable > 0 or target.intangible > 0: continue
		if float(target.get("counter", 0.0)) > 0.0 and not bool(contact.get("is_counter", false)):
			# Counter stance: the attack is answered with a stronger strike.
			target.counter = 0.0
			var reply := {"name": "Konter", "damage": float(a.damage) * 1.3 + 4.0, "push": float(a.get("push", 0.5)) * 1.4 + 0.3,
				"angle": 40.0, "hitstun": 0.35, "range": 1.5}
			if target.pending.has("ability") and target.pending.ability.has("sig"):
				reply.damage = float(reply.damage) * float(target.pending.ability.sig.get("dmg", 1.0))
			events.append({"type": "counter", "actor": contact.to, "target": contact.from})
			contacts.append({"from": contact.to, "to": contact.from, "attack": {"ability": reply, "special": true}, "is_counter": true,
				"push_dir": signf(attacker.x - target.x) if absf(attacker.x - target.x) > 0.01 else float(target.facing)})
			continue

		var is_parry: bool = (
			target.get("blocking", false) and
			target.parry_timer > 0 and
			not target.parry_used and
			target.is_grounded and
			target.stun <= 0
		)
		var is_blocked: bool = (not is_parry) and target.get("blocking", false) and target.is_grounded and target.stun <= 0
		var combo_idx: int = mini(attacker.combo, COMBO_MULT.size() - 1)
		var combo_mult: float = COMBO_MULT[combo_idx]

		if is_parry:
			target.parry_used = true
			attacker.stun = 0.55
			attacker.state = "HitStun"
			attacker.pose = "HitReact"
			attacker.pose_time = 0.55
			target.super = minf(MAX_SUPER, target.super + 25.0)
			attacker.hitstop = HITSTOP_FRAMES * 2
			target.hitstop = HITSTOP_FRAMES
			events.append({"type": "parry", "actor": contact.to, "target": contact.from})
		elif is_blocked:
			target.shield_hp -= float(a.damage) * SHIELD_DAMAGE_MULT
			if target.shield_hp <= 0.0:
				shield_break(contact.to)
				attacker.hitstop = HITSTOP_FRAMES
				continue
			var damage: float = a.damage * clampf(1.0 - target.profile.stats.defense * 0.01, 0.55, 0.90) * 0.18
			if attacker.titan_timer > 0.0: damage *= 2.0
			target.damage_percent = clampf(target.damage_percent + damage, 0.0, 999.0)
			target.vx = push_dir * a.push * 4.0
			target.stun = 0.08
			target.pose = "Block"
			target.pose_time = 0.18
			attacker.super = minf(MAX_SUPER, attacker.super + 5.0)
			target.super = minf(MAX_SUPER, target.super + 3.0)
			attacker.hitstop = HITSTOP_FRAMES
			target.hitstop = HITSTOP_FRAMES
			events.append({"type": "block", "target": contact.to, "damage": damage, "actor": contact.from, "damage_percent": target.damage_percent})
		else:
			var base_dmg: float = a.damage * clampf(1.0 - target.profile.stats.defense * 0.01, 0.55, 0.90)
			var super_bonus: float = 1.0
			if is_special and attacker.super >= 100.0:
				super_bonus = 1.70
				attacker.super = 0.0
				events.append({"type": "super_used", "actor": contact.from})

			var titan_mult: float = 2.0 if attacker.titan_timer > 0.0 else 1.0
			var rage: float = 1.35 if float(attacker.get("rage_timer", 0.0)) > 0.0 else 1.0
			var damage: float = base_dmg * combo_mult * super_bonus * titan_mult * rage * float(attacker.get("power_mult", 1.0))
			target.damage_percent = clampf(target.damage_percent + damage, 0.0, 999.0)

			if target.state == "Grabbed":
				target.grabbed_by = -1
				attacker.grab_target = -1

			var spec_type: String = a.get("type", "")
			if is_special:
				if spec_type == "ice_slow": target.slow_timer = 2.5
				elif spec_type == "electric_dash": attacker.x += attacker.facing * 1.8

			# Percent-based knockback scaling
			var p_ratio: float = target.damage_percent
			var weight: float = clampf(float(target.profile.get("weight", 1.0)), 0.82, 1.45)
			var smash_growth: float = (p_ratio * 0.024) + (p_ratio * damage * 0.0016)
			var angle_deg: float = float(a.get("angle", 35.0))
			if bool(a.get("free_angle", false)):
				angle_deg = clampf(angle_deg, -85.0, 89.0)
				if angle_deg < 0.0 and target.is_grounded: angle_deg = 30.0 # meteor on the ground pops up
			else:
				angle_deg = clampf(angle_deg, 15.0, 75.0)
			var angle_rad: float = deg_to_rad(angle_deg)

			var base_push: float = float(a.get("push", 0.32))
			var total_impulse: float = ((base_push * 4.0 + smash_growth * 3.75) * (1.35 if super_bonus > 1.0 else (1.15 if is_special else 1.0))) / weight
			if attacker.titan_timer > 0.0: total_impulse *= 1.6
			total_impulse = clampf(total_impulse * float(target.get("kb_taken_mult", 1.0)), 0.9, 19.0)

			# Directional influence: holding a direction bends the launch by up to DI_MAX_DEG.
			var launch := Vector2(push_dir * cos(angle_rad), sin(angle_rad))
			var di := Vector2(float(target.get("in_x", 0.0)), float(target.get("in_y", 0.0)))
			if di.length() > 0.3 and total_impulse > 3.0:
				var perp := Vector2(-launch.y, launch.x)
				launch = launch.rotated(clampf(di.normalized().dot(perp), -1.0, 1.0) * deg_to_rad(DI_MAX_DEG))
			target.vx = launch.x * total_impulse
			target.vy = launch.y * total_impulse
			target.is_grounded = false
			target.air_dash_used = false # getting hit restores the recovery dash
			target.drop_through = 0.12

			var stun_dur: float = clampf(float(a.get("hitstun", 0.22)) * (0.85 + (p_ratio * 0.005)), 0.15, 0.85)
			target.stun = stun_dur
			target.air_control_lock = stun_dur * 0.65
			target.state = "HitStun"
			target.pose = "HitReact"
			target.pose_time = stun_dur
			if not target.pending.is_empty(): target.pending = {}
			target.blocking = false
			target.walk_v = 0.0
			target.ledge = 0
			target.air_dodge_used = false
			if contact.has("pull"):
				var toward: float = signf(attacker.x - target.x) if absf(attacker.x - target.x) > 0.05 else float(attacker.facing)
				target.vx = toward * 9.0
				target.vy = 3.5
			if contact.has("swap"):
				var sx: float = attacker.x
				var sy: float = attacker.y
				attacker.x = target.x
				attacker.y = target.y
				target.x = sx
				target.y = sy
				events.append({"type": "swap", "actor": contact.from, "target": contact.to})
			if contact.has("lifesteal"):
				attacker.damage_percent = maxf(0.0, attacker.damage_percent - damage * float(contact.lifesteal))
			if a.has("freeze"):
				target.freeze_timer = float(a.freeze)
				events.append({"type": "freeze_hit", "actor": contact.from, "target": contact.to, "duration": float(a.freeze)})

			attacker.combo += 1
			attacker.combo_timer = 2.0
			attacker.super = minf(MAX_SUPER, attacker.super + (12.0 if is_special else 6.0))
			target.super = minf(MAX_SUPER, target.super + (8.0 if is_special else 4.0))

			var hitstop_count: int = int(round(clampf(damage * 0.4 + (4 if is_special else 2), 3, 10)))
			attacker.hitstop = hitstop_count
			target.hitstop = hitstop_count

			events.append({
				"type": "hit", "actor": contact.from, "target": contact.to,
				"damage": damage, "special": is_special, "super_hit": super_bonus > 1.0,
				"launch_impulse": total_impulse, "damage_percent": target.damage_percent
			})

	# ── Item Simulation ────────────────────────────────────────────────────────
	for it_idx in range(items.size()):
		var it: Dictionary = items[it_idx]
		if it.state == "wielded":
			if it.carrier >= 0 and it.carrier < fighters.size():
				it.x = fighters[it.carrier].x
				it.y = fighters[it.carrier].y + 1.0
			continue
		if it.state == "destroyed":
			if it.get("no_respawn", false): continue
			it.respawn -= dt
			if it.respawn <= 0.0:
				it.state = "resting"
				it.x = it.start_x
				it.y = it.start_y
				it.vx = 0.0
				it.vy = 0.0
				it.carrier = -1
				it.thrower = -1
				events.append({"type": "item_respawn", "item_id": it_idx, "item_name": it.name})
			continue

		if it.state == "carried":
			if it.carrier >= 0 and it.carrier < fighters.size():
				var carrier: Dictionary = fighters[it.carrier]
				it.x = carrier.x + carrier.facing * 0.65
				it.y = carrier.y + 0.8
				it.vx = 0.0
				it.vy = 0.0
			continue

		if it.state == "thrown" or it.state == "free":
			it.vy -= GRAVITY * dt * 0.85
			it.x += it.vx * dt
			it.y += it.vy * dt

			var item_landed := false
			if it.vy <= 0.0:
				for plat in PLATFORMS:
					if it.x >= plat.x1 and it.x <= plat.x2 and it.y <= plat.y + 0.1 and it.y >= plat.y - 0.2:
						it.y = plat.y + 0.1
						it.vy = 0.0
						it.vx = move_toward(it.vx, 0.0, 18.0 * dt)
						it.state = "resting"
						item_landed = true
						break
				if not item_landed and it.x >= STAGE_LEFT and it.x <= STAGE_RIGHT and it.y <= 0.1:
					it.y = 0.1
					it.vy = 0.0
					it.vx = move_toward(it.vx, 0.0, 18.0 * dt)
					it.state = "resting"
					item_landed = true

			if item_landed and it.get("explosive", false) and (it.state == "thrown" or abs(it.vx) > 2.0):
				explode_item(it_idx)
				continue

			if it.state == "thrown":
				for fi in range(fighters.size()):
					if fi == it.thrower or (it.thrower >= 0 and is_ally(it.thrower, fi)): continue
					var f_target: Dictionary = fighters[fi]
					if f_target.state == "Defeated" or f_target.invulnerable > 0: continue
					var target_center_y: float = f_target.y + 0.75
					var dx: float = abs(it.x - f_target.x)
					var dy: float = abs(it.y - target_center_y)
					if dx < 1.25 and dy < 1.35:
						if it.get("explosive", false):
							explode_item(it_idx)
							break

						var dmg: float = it.damage * clampf(1.0 - f_target.profile.stats.defense * 0.01, 0.6, 0.92)
						f_target.damage_percent = clampf(f_target.damage_percent + dmg, 0.0, 999.0)
						f_target.hp = maxf(0.0, f_target.hp - dmg)

						var p_ratio: float = f_target.damage_percent
						var weight: float = clampf(float(f_target.profile.get("weight", 1.0)), 0.85, 1.35)
						var smash_growth: float = (p_ratio * 0.022) + (p_ratio * dmg * 0.0015)
						var launch_scale: float = 1.0 + smash_growth
						var launch_impulse: float = (it.push * 5.0 * launch_scale) / weight

						var hit_dir: float = sign(it.vx) if abs(it.vx) > 0.1 else 1.0
						f_target.vx = hit_dir * launch_impulse * cos(deg_to_rad(it.angle))
						f_target.vy = launch_impulse * sin(deg_to_rad(it.angle))
						f_target.is_grounded = false
						f_target.drop_through = 0.15
						f_target.stun = clampf(0.32 + p_ratio * 0.003, 0.20, 0.85)
						f_target.state = "HitStun"
						f_target.pose = "HitReact"
						f_target.pose_time = f_target.stun

						events.append({
							"type": "item_hit", "item_id": it_idx, "item_name": it.name,
							"target": fi, "damage": dmg, "thrower": it.thrower,
							"damage_percent": f_target.damage_percent
						})

						if it.fragile:
							it.state = "destroyed"
							it.respawn = 7.0
						else:
							it.state = "resting"
							it.vx *= -0.3
							it.vy = 2.5
						break

			if it.y < BLAST_ZONE_BOTTOM or it.x < BLAST_ZONE_LEFT or it.x > BLAST_ZONE_RIGHT:
				it.state = "destroyed"
				it.respawn = 6.0

	# ── Check Active Players & Match Outcome ──────────────────────────────────
	var alive_indices: Array = []
	for k in range(fighters.size()):
		if fighters[k].state != "Defeated" and fighters[k].state != "Dazed" and fighters[k].lives > 0:
			alive_indices.append(k)

	if result == -2:
		var alive_teams := {}
		for k in alive_indices: alive_teams[fighters[k].team] = true
		if finish_phase:
			if finish_timer <= 0.0: _end_finish_phase(false)
		elif alive_teams.size() == 1 and fighters.size() > 1 and finishers_enabled and alive_indices.size() == 1 and eliminated_now >= 0:
			_start_finish_phase(alive_indices[0], eliminated_now)
		elif alive_teams.size() == 1 and fighters.size() > 1:
			result = alive_indices[0]
			for k in alive_indices:
				fighters[k].pose = "Victory"
			fighters[result].state = "Ready"
			fighters[result].pose = "Victory"
			events.append({"type": "finish", "winner": result})
		elif alive_indices.is_empty() and not finish_phase:
			result = -1
			events.append({"type": "finish", "winner": -1})
		elif time_left <= 0.0 and not finish_phase:
			var best_k := -1
			var best_score := -999999.0
			var tied := false
			for k in range(fighters.size()):
				# Most stocks wins, tiebreaker lowest damage percent; an exact tie is a draw.
				var score: float = float(fighters[k].lives) * 1000.0 - fighters[k].damage_percent
				if score > best_score:
					best_score = score
					best_k = k
					tied = false
				elif is_equal_approx(score, best_score):
					tied = true
			result = -1 if tied else best_k
			for k in range(fighters.size()):
				fighters[k].pose = "Victory" if result == k else ("Defeat" if result >= 0 else "Idle")
			events.append({"type": "finish", "winner": result})

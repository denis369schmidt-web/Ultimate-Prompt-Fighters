extends RefCounted
## Authoritative local simulation with data-driven smash knockback, state machine, grab/throw, arena items & 3-Stock rules.
const Prompt = preload("res://scripts/prompt_interpreter.gd")
const STEP := 1.0 / 60.0

var fighters: Array = []
var items: Array = []
var time_left := 99.0
var elapsed := 0.0
var countdown := 1.5
var result := -2 # -2 ongoing, -1 draw, 0/1 winner
var mode := "manual"
var events: Array = []
var serial := 0
var profiles: Array = []

const GRAVITY := 20.0
const JUMP_FORCE := 8.2
const HITSTOP_FRAMES := 4
const PARRY_WINDOW := 0.12
const MAX_SUPER := 100.0
const INITIAL_LIVES := 3

# ── Platform Fighter Stage Geometry ──────────────────────────────────────────
const STAGE_LEFT := -4.75
const STAGE_RIGHT := 4.75
const BLAST_ZONE_LEFT := -8.5
const BLAST_ZONE_RIGHT := 8.5
const BLAST_ZONE_BOTTOM := -3.8
const BLAST_ZONE_TOP := 8.5

# 3 Floating pass-through platforms in Battlefield layout
const PLATFORMS: Array = [
	{"name": "plat_left",  "x1": -3.4, "x2": -1.2, "y": 1.45, "width": 2.2},
	{"name": "plat_right", "x1":  1.2, "x2":  3.4, "y": 1.45, "width": 2.2},
	{"name": "plat_top",   "x1": -1.1, "x2":  1.1, "y": 2.65, "width": 2.2},
]

# Combo multiplier: 1.0 → 1.08 → 1.18 → 1.30 → 1.45
const COMBO_MULT: Array = [1.0, 1.08, 1.18, 1.30, 1.45]

# Initial items templates
const DEFAULT_ITEMS: Array = [
	{
		"id": 0, "type": "light_crate", "name": "Leichte Kiste",
		"start_x": -2.3, "start_y": 1.55, "x": -2.3, "y": 1.55,
		"vx": 0.0, "vy": 0.0, "weight": 0.60,
		"state": "resting", # resting, carried, thrown, destroyed
		"carrier": -1, "thrower": -1, "respawn": 0.0,
		"damage": 12.0, "push": 0.65, "angle": 32.0, "fragile": true
	},
	{
		"id": 1, "type": "heavy_rock", "name": "Schwerer Stein",
		"start_x": 0.0, "start_y": 2.75, "x": 0.0, "y": 2.75,
		"vx": 0.0, "vy": 0.0, "weight": 1.40,
		"state": "resting",
		"carrier": -1, "thrower": -1, "respawn": 0.0,
		"damage": 22.0, "push": 1.10, "angle": 45.0, "fragile": false
	},
	{
		"id": 2, "type": "barrel", "name": "Holzfass",
		"start_x": 2.3, "start_y": 1.55, "x": 2.3, "y": 1.55,
		"vx": 0.0, "vy": 0.0, "weight": 0.90,
		"state": "resting",
		"carrier": -1, "thrower": -1, "respawn": 0.0,
		"damage": 16.0, "push": 0.85, "angle": 36.0, "fragile": false
	}
]

func start(a: Dictionary, b: Dictionary, control: String = "manual", lives_count: int = 3) -> void:
	assert(Prompt.valid(a) and Prompt.valid(b))
	profiles = [a.duplicate(true), b.duplicate(true)]
	fighters.clear()
	for i in range(2):
		var p: Dictionary = profiles[i]
		fighters.append({
			"profile": p,
			"hp": p.health,
			"max_hp": p.health,
			"x": -2.3 if i == 0 else 2.3,
			"y": 0.0,
			"vy": 0.0,
			"vx": 0.0,
			"is_grounded": true,
			"blocking": false,
			"facing": 1 if i == 0 else -1,
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
			"air_jumps": 1,
			"drop_through": 0.0,
			"invulnerable": 0.0,
			# State Machine: "Ready", "Attack", "HitStun", "Grab", "Grabbed", "Throw", "Carrying", "Defeated"
			"state": "Ready",
			"grab_timer": 0.0,
			"grabbed_by": -1,
			"grab_target": -1,
			"grab_immunity": 0.0,
			"carried_item": -1,
			"slow_timer": 0.0,
			"air_control_lock": 0.0,
		})

	# Reset Items
	items.clear()
	for def in DEFAULT_ITEMS:
		items.append(def.duplicate(true))

	time_left = 90.0
	elapsed = 0.0
	countdown = 1.5
	result = -2
	mode = control
	serial = 0
	events.clear()

func restart() -> void:
	start(profiles[0], profiles[1], mode, fighters[0].lives if fighters.size() > 0 else 1)

func queue_attack(i: int, is_special: bool) -> bool:
	var f: Dictionary = fighters[i]
	if f.state != "Ready" and f.state != "Carrying": return false
	if not f.pending.is_empty(): return false
	if f.state == "Carrying" and f.carried_item >= 0:
		# If carrying item, attack key throws item
		throw_carried_item(i)
		return true
	var idx := 1 if is_special else 0
	if f.cooldowns[idx] > 0.0: return false
	var a: Dictionary = f.profile.special if is_special else f.profile.standard

	f.cooldowns[idx] = a.cooldown
	f.state = "Attack"
	f.pending = {
		"ability": a,
		"special": is_special,
		"remaining": a.windup,
		"active_time": a.get("active", 0.12),
		"recovery_time": a.get("recovery", 0.20),
		"hit_done": false,
		"stage": "windup"
	}
	f.pose = "SpecialAttack" if is_special else "Attack"
	f.pose_time = a.windup + a.get("active", 0.12) + a.get("recovery", 0.20)
	events.append({"type": "attack", "actor": i, "special": is_special, "ability_name": a.get("name", "Attack")})
	return true

func initiate_grab(i: int) -> void:
	var f: Dictionary = fighters[i]
	if f.state != "Ready": return

	# 1. Priority: Pick up nearby ground item if in reach
	var best_item := -1
	var best_dist := 1.35
	for item_idx in range(items.size()):
		var it: Dictionary = items[item_idx]
		if it.state == "resting" or it.state == "free":
			var d := Vector2(it.x - f.x, it.y - f.y).length()
			if d < best_dist:
				best_dist = d
				best_item = item_idx

	if best_item >= 0:
		var it: Dictionary = items[best_item]
		it.state = "carried"
		it.carrier = i
		it.vx = 0.0
		it.vy = 0.0
		f.carried_item = best_item
		f.state = "Carrying"
		events.append({"type": "item_pickup", "actor": i, "item_id": best_item, "item_name": it.name})
		return

	# 2. Priority: Grab opponent
	if f.grab_immunity > 0.0: return
	f.state = "Grab"
	f.grab_timer = 0.12 # Startup/windup before grab check
	f.pose = "Attack"
	f.pose_time = 0.35
	events.append({"type": "grab_attempt", "actor": i})

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
	var speed: float = 12.0 / it.weight
	it.vx = f.facing * speed
	it.vy = 4.2
	f.carried_item = -1
	f.state = "Ready"
	f.pose = "Attack"
	f.pose_time = 0.22
	events.append({"type": "item_throw", "actor": i, "item_id": item_idx, "item_name": it.name})

func execute_throw(attacker_idx: int, throw_type: String) -> void:
	var attacker: Dictionary = fighters[attacker_idx]
	var target_idx: int = attacker.grab_target
	if target_idx < 0: return
	var target: Dictionary = fighters[target_idx]

	var max_hp: float = maxf(1.0, target.profile.health)
	var missing_hp_ratio: float = clampf(1.0 - (target.hp / max_hp), 0.0, 1.0)
	var weight: float = clampf(float(target.profile.get("weight", 1.0)), 0.85, 1.35)

	var damage: float = 14.0 * (1.0 - target.profile.stats.defense * 0.006)
	target.hp = maxf(0.0, target.hp - damage)

	var launch_mult: float = 1.0 + (missing_hp_ratio * 2.2) + pow(missing_hp_ratio, 2.0) * 1.5

	if throw_type == "forward":
		var base_impulse := 17.5 * launch_mult / weight
		target.vx = attacker.facing * base_impulse
		target.vy = 6.0 * (1.0 + missing_hp_ratio * 0.7)
	elif throw_type == "back":
		var base_impulse := 19.5 * launch_mult / weight
		target.vx = -attacker.facing * base_impulse
		target.vy = 6.8 * (1.0 + missing_hp_ratio * 0.7)
	elif throw_type == "up":
		var base_impulse := 18.0 * launch_mult / weight
		target.vx = attacker.facing * 2.0
		target.vy = base_impulse
	else:
		# Down throw / Neutral slam
		target.vx = attacker.facing * 9.0 * launch_mult / weight
		target.vy = 4.0

	target.is_grounded = false
	target.drop_through = 0.15
	target.stun = clampf(0.32 + missing_hp_ratio * 0.35, 0.25, 0.65)
	target.air_control_lock = target.stun * 0.7
	target.state = "HitStun"
	target.pose = "HitReact"
	target.pose_time = target.stun
	target.grabbed_by = -1
	target.grab_immunity = 0.85 # Anti-chain grab protection

	attacker.state = "Throw"
	attacker.grab_target = -1
	attacker.grab_timer = 0.0
	attacker.pose = "Attack"
	attacker.pose_time = 0.28
	events.append({"type": "throw", "actor": attacker_idx, "target": target_idx, "throw_type": throw_type, "damage": damage})

func release_grab_breakout(attacker_idx: int) -> void:
	var attacker: Dictionary = fighters[attacker_idx]
	var target_idx: int = attacker.grab_target
	if target_idx >= 0:
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

func agent_commands() -> Array:
	var commands: Array = []
	for i in range(2):
		var f: Dictionary = fighters[i]
		var opp: Dictionary = fighters[1-i]
		var distance_x: float = abs(opp.x - f.x)
		var distance_y: float = opp.y - f.y
		var direction: float = sign(opp.x - f.x)

		# Recovery logic if off-stage
		var is_offstage: bool = f.x < STAGE_LEFT or f.x > STAGE_RIGHT or f.y < -0.1
		var move: float = 0.0
		var want_jump: bool = false
		var want_drop: bool = false
		var want_grab: bool = false

		if is_offstage:
			move = 1.0 if f.x < 0.0 else -1.0
			if f.vy < 1.0 and f.air_jumps > 0 and f.y < 1.0:
				want_jump = true
		else:
			# Check nearby items to pick up
			var nearby_item := false
			for it in items:
				if (it.state == "resting" or it.state == "free") and abs(it.x - f.x) < 1.2 and abs(it.y - f.y) < 0.8:
					nearby_item = true
					break

			if nearby_item and f.state == "Ready":
				want_grab = true
			elif f.state == "Carrying" and f.carried_item >= 0:
				# Throw item at opponent when in alignment
				if distance_x < 5.5 and abs(distance_y) < 1.4:
					want_grab = true
			elif f.state == "Carrying" and f.grab_target >= 0:
				# Decide throw direction
				if opp.x < STAGE_LEFT + 1.5 or opp.x > STAGE_RIGHT - 1.5:
					move = f.facing # Forward throw offstage!
				else:
					move = -f.facing if randf() < 0.5 else f.facing
			else:
				var desired: float = f.profile.standard.range * 0.85
				move = direction if distance_x > desired else 0.0
				if distance_y > 0.8 and distance_x < 2.0 and (f.is_grounded or f.air_jumps > 0):
					want_jump = randf() < 0.45
				elif distance_y < -0.8 and f.y > 0.5 and f.is_grounded:
					want_drop = randf() < 0.35
				elif distance_x < 1.2 and opp.get("blocking", false) and randf() < 0.65:
					want_grab = true # Grab through shields!

		var special_ready: bool = f.cooldowns[1] <= 0 and f.super >= 40.0 and distance_x <= f.profile.special.range and abs(distance_y) < 1.2
		var should_block: bool = not opp.pending.is_empty() and distance_x <= 1.5 and randf() < 0.30 and not is_offstage
		var use_super: bool = f.super >= 100.0 and distance_x <= f.profile.special.range * 1.2 and abs(distance_y) < 1.4

		commands.append({
			"move": move if not should_block else 0.0,
			"standard": distance_x <= f.profile.standard.range and abs(distance_y) < 1.1 and not special_ready and not should_block and not use_super and not want_grab,
			"special": (special_ready or use_super) and not should_block and not want_grab,
			"jump": want_jump and not should_block,
			"block": should_block or want_drop,
			"grab": want_grab
		})
	return commands

func tick(commands: Array, dt: float = STEP) -> void:
	events.clear()
	if result != -2 or fighters.size() != 2: return
	if countdown > 0:
		countdown = maxf(0.0, countdown - dt)
		return
	elapsed += dt
	time_left = maxf(0.0, time_left - dt)

	# ── Fighter Updates ────────────────────────────────────────────────────────
	for i in range(2):
		var f: Dictionary = fighters[i]

		# Hitstop freeze
		if f.hitstop > 0:
			f.hitstop -= 1
			continue

		# Cooldowns
		f.cooldowns[0] = maxf(0.0, f.cooldowns[0] - dt)
		f.cooldowns[1] = maxf(0.0, f.cooldowns[1] - dt)

		# State & Stun Timers
		if f.stun > 0:
			f.stun = maxf(0.0, f.stun - dt)
			if f.stun <= 0.0 and f.state == "HitStun":
				f.state = "Ready"
				f.pose = "Idle"

		if f.pose_time > 0:
			f.pose_time = maxf(0.0, f.pose_time - dt)
			if f.pose_time <= 0:
				if f.state == "Throw" or f.state == "Attack":
					f.state = "Ready"
				f.pose = "Idle"

		if f.drop_through > 0: f.drop_through = maxf(0.0, f.drop_through - dt)
		if f.invulnerable > 0: f.invulnerable = maxf(0.0, f.invulnerable - dt)
		if f.grab_immunity > 0: f.grab_immunity = maxf(0.0, f.grab_immunity - dt)
		if f.slow_timer > 0: f.slow_timer = maxf(0.0, f.slow_timer - dt)
		if f.air_control_lock > 0: f.air_control_lock = maxf(0.0, f.air_control_lock - dt)

		# Combo timer decay
		if f.combo_timer > 0:
			f.combo_timer -= dt
			if f.combo_timer <= 0:
				if f.combo > 1:
					events.append({"type": "combo_end", "actor": i, "count": f.combo})
				f.combo = 0

		if f.parry_timer > 0: f.parry_timer -= dt
		f.super = minf(MAX_SUPER, f.super + dt * 2.0)

		# Facing direction (turn towards opponent unless in hitstun/grabbed/carrying)
		if f.state == "Ready" or f.state == "Attack":
			f.facing = 1 if fighters[1-i].x > f.x else -1

		# Horizontal physics & Air drift
		var speed_scale: float = 0.50 if f.slow_timer > 0.0 else (0.85 if f.carried_item >= 0 else 1.0)
		var friction: float = 26.0 if f.is_grounded else 6.5
		if abs(f.vx) > 0.05:
			f.x += f.vx * dt
			f.vx = move_toward(f.vx, 0.0, friction * dt)

		# Grab processing
		if f.state == "Grab":
			f.grab_timer -= dt
			if f.grab_timer <= 0.0:
				# Active grab window check
				var target_f: Dictionary = fighters[1-i]
				var in_range: bool = abs(target_f.x - f.x) <= 1.25 and abs(target_f.y - f.y) <= 0.95
				var can_be_grabbed: bool = (
					target_f.invulnerable <= 0.0 and
					target_f.grab_immunity <= 0.0 and
					target_f.state != "Grabbed" and
					target_f.state != "Defeated"
				)
				if in_range and can_be_grabbed:
					# Successful Grab!
					f.state = "Carrying"
					f.grab_target = 1 - i
					f.grab_timer = 1.3 # Max hold duration
					target_f.state = "Grabbed"
					target_f.grabbed_by = i
					target_f.stun = 1.3
					target_f.is_grounded = f.is_grounded
					target_f.vx = 0.0
					target_f.vy = 0.0
					target_f.pose = "HitReact"
					target_f.pose_time = 1.3
					events.append({"type": "grab_success", "actor": i, "target": 1-i})
				else:
					# Grab missed - enter recovery lag
					f.state = "Ready"
					f.stun = 0.25
					f.pose = "HitReact"
					f.pose_time = 0.25
					events.append({"type": "grab_miss", "actor": i})

		elif f.state == "Carrying" and f.grab_target >= 0:
			# Holding opponent
			var target_f: Dictionary = fighters[f.grab_target]
			# Align opponent to hold point in front of attacker
			target_f.x = f.x + f.facing * 0.75
			target_f.y = f.y
			f.grab_timer -= dt
			if f.grab_timer <= 0.0:
				release_grab_breakout(i)
			else:
				var cmd: Dictionary = commands[i]
				var axis := clampf(float(cmd.get("move", 0)), -1.0, 1.0)
				var want_jump: bool = bool(cmd.get("jump", false))
				if want_jump or cmd.get("special", false):
					execute_throw(i, "up")
				elif abs(axis) > 0.25:
					if sign(axis) == f.facing:
						execute_throw(i, "forward")
					else:
						execute_throw(i, "back")
				elif cmd.get("standard", false) or cmd.get("grab", false):
					execute_throw(i, "forward")

		# User input processing
		if (f.state == "Ready" or (f.state == "Carrying" and f.carried_item >= 0)) and f.pending.is_empty():
			var cmd: Dictionary = commands[i]
			var want_block: bool = bool(cmd.get("block", false))
			var want_jump: bool = bool(cmd.get("jump", false))
			var want_grab: bool = bool(cmd.get("grab", false))
			var axis := clampf(float(cmd.get("move", 0)), -1.0, 1.0)

			# Drop through platform
			if want_block and f.y > 0.2 and f.is_grounded:
				f.is_grounded = false
				f.y -= 0.12
				f.vy = -3.0
				f.drop_through = 0.35
				events.append({"type": "drop_through", "actor": i})
			elif want_block and f.is_grounded and f.carried_item < 0:
				f.blocking = true
				f.moving = false
				if f.pose_time <= 0: f.pose = "Block"
				if not f.get("_was_blocking", false):
					f.parry_timer = PARRY_WINDOW
					f.parry_used = false
			else:
				f.blocking = false
				# Ground Jump or Mid-Air Double Jump
				if want_jump:
					if f.is_grounded:
						f.vy = JUMP_FORCE
						f.y += 0.05
						f.is_grounded = false
						f.air_jumps = 1
						events.append({"type": "jump", "actor": i})
					elif f.air_jumps > 0 and f.vy < 4.0:
						f.air_jumps -= 1
						f.vy = JUMP_FORCE * 0.95
						if f.x < STAGE_LEFT: f.vx = maxf(f.vx, 3.2)
						elif f.x > STAGE_RIGHT: f.vx = minf(f.vx, -3.2)
						events.append({"type": "double_jump", "actor": i})

				# Horizontal Movement & Air Control
				if abs(axis) > 0.05:
					if f.is_grounded:
						f.x += axis * f.profile.speed * speed_scale * dt
						f.moving = true
					elif f.air_control_lock <= 0.0:
						# Controlled directional influence in air
						f.x += axis * f.profile.speed * speed_scale * 0.85 * dt
						f.moving = true

					if abs(f.vx) < 0.2:
						f.x = clampf(f.x, -5.18, 5.18)

				# Actions
				if want_grab:
					if f.carried_item >= 0:
						throw_carried_item(i)
					else:
						initiate_grab(i)
				elif cmd.get("special", false) and f.super >= 40.0:
					queue_attack(i, true)
				elif cmd.get("standard", false):
					queue_attack(i, false)

			f["_was_blocking"] = want_block

		# Vertical physics & Landing
		var prev_y: float = f.y
		if not f.is_grounded and f.state != "Grabbed":
			f.vy -= GRAVITY * dt
			var next_y: float = f.y + f.vy * dt
			var landed := false

			if f.vy <= 0.0:
				if f.drop_through <= 0.0:
					for plat in PLATFORMS:
						if f.x >= plat.x1 and f.x <= plat.x2:
							if prev_y >= plat.y - 0.06 and next_y <= plat.y:
								f.y = plat.y
								f.vy = 0.0
								f.is_grounded = true
								f.air_jumps = 1
								landed = true
								break
				if not landed and f.x >= STAGE_LEFT and f.x <= STAGE_RIGHT:
					if prev_y >= -0.06 and next_y <= 0.0:
						f.y = 0.0
						f.vy = 0.0
						f.is_grounded = true
						f.air_jumps = 1
						landed = true

			if not landed:
				f.y = next_y
		elif f.is_grounded:
			var on_ground := false
			if f.drop_through <= 0.0:
				for plat in PLATFORMS:
					if f.x >= plat.x1 and f.x <= plat.x2 and abs(f.y - plat.y) < 0.08:
						on_ground = true
						break
			if not on_ground and f.x >= STAGE_LEFT and f.x <= STAGE_RIGHT and abs(f.y) < 0.08:
				on_ground = true

			if not on_ground:
				f.is_grounded = false

		# Blast Zones & Ring Out
		var out_of_bounds: bool = (
			f.x < BLAST_ZONE_LEFT or
			f.x > BLAST_ZONE_RIGHT or
			f.y < BLAST_ZONE_BOTTOM or
			f.y > BLAST_ZONE_TOP
		)

		if out_of_bounds and f.invulnerable <= 0.0:
			f.lives -= 1
			# Drop carried item if holding one
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
				f.hp = f.max_hp
				f.x = -2.3 if i == 0 else 2.3
				f.y = 1.45
				f.vx = 0.0
				f.vy = 0.0
				f.is_grounded = true
				f.air_jumps = 1
				f.invulnerable = 1.8
				f.stun = 0.0
				f.state = "Ready"
				f.pose = "Idle"
				events.append({"type": "ring_out", "actor": i, "lives": f.lives})
				events.append({"type": "respawn", "actor": i})
			else:
				f.hp = 0.0
				f.state = "Defeated"
				result = 1 - i
				fighters[result].state = "Ready"
				fighters[result].pose = "Victory"
				f.pose = "Defeat"
				events.append({"type": "finish", "winner": result})
				return
		elif f.hp <= 0.0 and f.invulnerable <= 0.0:
			f.hp = 0.0
			f.lives = 0
			f.state = "Defeated"
			result = 1 - i
			fighters[result].state = "Ready"
			fighters[result].pose = "Victory"
			f.pose = "Defeat"
			events.append({"type": "finish", "winner": result})
			return

	# Body collision on same elevation (unless one is grabbed)
	if abs(fighters[0].y - fighters[1].y) < 0.8 and fighters[0].grabbed_by < 0 and fighters[1].grabbed_by < 0:
		var dist_x: float = fighters[1].x - fighters[0].x
		if abs(dist_x) < 0.86:
			var push_apart: float = (0.86 - abs(dist_x)) * 0.5
			var dir: float = -1.0 if dist_x < 0 else 1.0
			fighters[0].x -= dir * push_apart
			fighters[1].x += dir * push_apart

	# ── Contact resolution (Attacks) ───────────────────────────────────────────
	var contacts: Array = []
	for i in range(2):
		var f: Dictionary = fighters[i]
		if f.pending.is_empty(): continue
		f.pending.remaining -= dt
		if f.pending.remaining <= 0 and not f.pending.hit_done:
			f.pending.hit_done = true
			var attack: Dictionary = f.pending
			var target_f: Dictionary = fighters[1-i]
			var dx: float = abs(target_f.x - f.x)
			var dy: float = abs(target_f.y - f.y)
			if dx <= attack.ability.range and dy <= 1.4:
				contacts.append({"from": i, "to": 1-i, "attack": attack})

	for contact in contacts:
		var attacker: Dictionary = fighters[contact.from]
		var target: Dictionary = fighters[contact.to]
		var a: Dictionary = contact.attack.ability
		var is_special: bool = contact.attack.special

		if target.invulnerable > 0: continue

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
			var damage: float = a.damage * clampf(1.0 - target.profile.stats.defense * 0.01, 0.55, 0.90) * 0.18
			target.hp = maxf(0, target.hp - damage)
			target.vx = attacker.facing * a.push * 4.0
			target.stun = 0.08
			target.pose = "Block"
			target.pose_time = 0.18
			attacker.super = minf(MAX_SUPER, attacker.super + 5.0)
			target.super = minf(MAX_SUPER, target.super + 3.0)
			attacker.hitstop = HITSTOP_FRAMES
			target.hitstop = HITSTOP_FRAMES
			events.append({"type": "block", "target": contact.to, "damage": damage, "actor": contact.from})
		else:
			var base_dmg: float = a.damage * clampf(1.0 - target.profile.stats.defense * 0.01, 0.55, 0.90)
			var super_bonus: float = 1.0
			if is_special and attacker.super >= 100.0:
				super_bonus = 1.70
				attacker.super = 0.0
				events.append({"type": "super_used", "actor": contact.from})
			elif is_special:
				attacker.super = maxf(0, attacker.super - 40.0)

			var damage: float = base_dmg * combo_mult * super_bonus
			target.hp = maxf(0, target.hp - damage)

			# Interrupt grabbed state if hit
			if target.state == "Grabbed":
				target.grabbed_by = -1
				attacker.grab_target = -1

			# Special ability unique combat effects
			var spec_type: String = a.get("type", "")
			if is_special:
				if spec_type == "ice_slow":
					target.slow_timer = 2.0 # Slow opponent down for 2 seconds
				elif spec_type == "electric_dash":
					attacker.x += attacker.facing * 1.5 # Dash forward

			# DATA-DRIVEN SUPER SMASH BROS KNOCKBACK FORMULA:
			var max_hp: float = maxf(1.0, target.profile.health)
			var missing_hp_ratio: float = clampf(1.0 - (target.hp / max_hp), 0.0, 1.0)
			var weight: float = clampf(float(target.profile.get("weight", 1.0)), 0.85, 1.35)

			# Launch multiplier scaling exponentially with missing HP
			var launch_scale: float = 1.0 + (missing_hp_ratio * 2.2) + pow(missing_hp_ratio, 2.0) * 1.5
			var angle_deg: float = float(a.get("angle", 30.0))
			var angle_rad: float = deg_to_rad(clampf(angle_deg, 15.0, 75.0))

			var base_push: float = float(a.get("push", 0.25))
			var total_impulse: float = (base_push * 26.0 * launch_scale * (1.35 if super_bonus > 1.0 else (1.15 if is_special else 1.0))) / weight
			total_impulse = clampf(total_impulse, 3.0, 36.0)

			target.vx = attacker.facing * cos(angle_rad) * total_impulse
			target.vy = sin(angle_rad) * total_impulse
			target.is_grounded = false
			target.drop_through = 0.12

			var stun_dur: float = clampf(float(a.get("hitstun", 0.22)) * (0.85 + missing_hp_ratio * 0.85), 0.15, 0.65)
			target.stun = stun_dur
			target.air_control_lock = stun_dur * 0.65
			target.state = "HitStun"
			target.pose = "HitReact"
			target.pose_time = stun_dur

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
				"launch_impulse": total_impulse, "missing_hp_ratio": missing_hp_ratio
			})

	# Check Fatal KO after resolving all simultaneous contacts
	if fighters[0].hp <= 0.0 and fighters[1].hp <= 0.0 and result == -2:
		result = -1
		for k in range(2):
			fighters[k].hp = 0.0
			fighters[k].state = "Defeated"
			fighters[k].pose = "Defeat"
		events.append({"type": "finish", "winner": -1})
		return
	elif fighters[0].hp <= 0.0 and result == -2:
		fighters[0].hp = 0.0
		fighters[0].state = "Defeated"
		fighters[0].pose = "Defeat"
		result = 1
		fighters[1].state = "Ready"
		fighters[1].pose = "Victory"
		events.append({"type": "finish", "winner": 1})
		return
	elif fighters[1].hp <= 0.0 and result == -2:
		fighters[1].hp = 0.0
		fighters[1].state = "Defeated"
		fighters[1].pose = "Defeat"
		result = 0
		fighters[0].state = "Ready"
		fighters[0].pose = "Victory"
		events.append({"type": "finish", "winner": 0})
		return

	# ── Item Simulation ────────────────────────────────────────────────────────
	for it_idx in range(items.size()):
		var it: Dictionary = items[it_idx]

		if it.state == "destroyed":
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

			# Ground / Platform Collision
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

			# Check hit against fighters while thrown
			if it.state == "thrown":
				for fi in range(2):
					if fi == it.thrower:
						# Do not hit the thrower with their own projectile
						continue
					var f_target: Dictionary = fighters[fi]
					if f_target.invulnerable > 0: continue
					var target_center_y: float = f_target.y + 0.75
					var dx: float = abs(it.x - f_target.x)
					var dy: float = abs(it.y - target_center_y)
					if dx < 1.15 and dy < 1.25:
						# Direct item hit!
						var dmg: float = it.damage * clampf(1.0 - f_target.profile.stats.defense * 0.01, 0.6, 0.92)
						f_target.hp = maxf(0.0, f_target.hp - dmg)

						var max_hp: float = maxf(1.0, f_target.profile.health)
						var missing_hp_ratio: float = clampf(1.0 - (f_target.hp / max_hp), 0.0, 1.0)
						var weight: float = clampf(float(f_target.profile.get("weight", 1.0)), 0.85, 1.35)
						var launch_scale: float = 1.0 + (missing_hp_ratio * 2.0)
						var launch_impulse: float = (it.push * 24.0 * launch_scale) / weight

						var hit_dir: float = sign(it.vx) if abs(it.vx) > 0.1 else 1.0
						f_target.vx = hit_dir * launch_impulse * cos(deg_to_rad(it.angle))
						f_target.vy = launch_impulse * sin(deg_to_rad(it.angle))
						f_target.is_grounded = false
						f_target.stun = 0.32 + missing_hp_ratio * 0.25
						f_target.state = "HitStun"
						f_target.pose = "HitReact"
						f_target.pose_time = f_target.stun

						events.append({
							"type": "item_hit", "item_id": it_idx, "item_name": it.name,
							"target": fi, "damage": dmg, "thrower": it.thrower
						})

						if it.fragile:
							it.state = "destroyed"
							it.respawn = 6.0
						else:
							it.state = "resting"
							it.vx *= -0.3
							it.vy = 2.5
						break

			# Item Blast Zone check
			if it.y < BLAST_ZONE_BOTTOM or it.x < BLAST_ZONE_LEFT or it.x > BLAST_ZONE_RIGHT:
				it.state = "destroyed"
				it.respawn = 5.0

	# Simultaneous double KO check
	if fighters[0].hp <= 0.0 and fighters[1].hp <= 0.0 and result == -2:
		result = -1
		for k in range(2): fighters[k].pose = "Defeat"
		events.append({"type": "finish", "winner": -1})
		return

	# Timeout check
	if time_left <= 0.0 and result == -2:
		var norm_hp0: float = fighters[0].hp / fighters[0].profile.health
		var norm_hp1: float = fighters[1].hp / fighters[1].profile.health
		if is_equal_approx(norm_hp0, norm_hp1):
			result = -1
		else:
			result = 0 if norm_hp0 > norm_hp1 else 1
		for k in range(2):
			fighters[k].pose = "Victory" if result == k else ("Defeat" if result >= 0 else "Idle")
		events.append({"type": "finish", "winner": result})

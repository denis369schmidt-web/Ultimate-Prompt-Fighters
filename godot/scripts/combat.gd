extends RefCounted
## The authoritative local simulation with Super Smash Bros style platforms, knockback & 3-Stock Ring Out.
const Prompt = preload("res://scripts/prompt_interpreter.gd")
const STEP := 1.0 / 60.0
var fighters: Array = []
var time_left := 99.0
var elapsed := 0.0
var countdown := 1.5
var result := -2 # -2 ongoing, -1 draw, 0/1 winner
var mode := "manual"
var events: Array = []
var serial := 0
var profiles: Array = []

const GRAVITY := 20.0
const JUMP_FORCE := 8.2       # Responsive jump height
const HITSTOP_FRAMES := 4      # Freeze frames on hit
const PARRY_WINDOW := 0.12     # Seconds of perfect-block parry window
const MAX_SUPER := 100.0       # Super meter max
const INITIAL_LIVES := 3       # 3 Lives / Stocks per match

# ── Platform Fighter Stage Geometry ──────────────────────────────────────────
const STAGE_LEFT := -4.75
const STAGE_RIGHT := 4.75
const BLAST_ZONE_LEFT := -8.5
const BLAST_ZONE_RIGHT := 8.5
const BLAST_ZONE_BOTTOM := -3.8
const BLAST_ZONE_TOP := 8.5

# 3 Floating pass-through platforms in classic Battlefield layout
const PLATFORMS: Array = [
	{"name": "plat_left",  "x1": -3.4, "x2": -1.2, "y": 1.45, "width": 2.2},
	{"name": "plat_right", "x1":  1.2, "x2":  3.4, "y": 1.45, "width": 2.2},
	{"name": "plat_top",   "x1": -1.1, "x2":  1.1, "y": 2.65, "width": 2.2},
]

# Combo multiplier: 1.0 → 1.08 → 1.18 → 1.30 → 1.45
const COMBO_MULT: Array = [1.0, 1.08, 1.18, 1.30, 1.45]

func start(a: Dictionary, b: Dictionary, control: String) -> void:
	assert(Prompt.valid(a) and Prompt.valid(b))
	profiles = [a.duplicate(true), b.duplicate(true)]
	fighters.clear()
	for i in range(2):
		var p: Dictionary = profiles[i]
		fighters.append({
			"profile": p,
			"hp": p.health,
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
			"lives": INITIAL_LIVES,
			"air_jumps": 1,
			"drop_through": 0.0,
			"invulnerable": 0.0,
		})
	time_left = 99.0
	elapsed = 0.0
	countdown = 1.5
	result = -2
	mode = control
	serial = 0
	events.clear()

func restart() -> void:
	start(profiles[0], profiles[1], mode)

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

		if is_offstage:
			# Move back toward center stage
			move = 1.0 if f.x < 0.0 else -1.0
			# Jump to recover if falling
			if f.vy < 1.0 and f.air_jumps > 0 and f.y < 1.0:
				want_jump = true
		else:
			var desired: float = f.profile.standard.range * 0.85
			move = direction if distance_x > desired else 0.0
			# Jump toward higher opponent or platform
			if distance_y > 0.8 and distance_x < 2.0 and (f.is_grounded or f.air_jumps > 0):
				want_jump = randf() < 0.45
			# Drop through platform if opponent is below
			elif distance_y < -0.8 and f.y > 0.5 and f.is_grounded:
				want_drop = randf() < 0.35

		var special_ready: bool = f.cooldowns[1] <= 0 and f.super >= 40.0 and distance_x <= f.profile.special.range and abs(distance_y) < 1.2
		var should_block: bool = not opp.pending.is_empty() and distance_x <= 1.5 and randf() < 0.25 and not is_offstage
		var use_super: bool = f.super >= 100.0 and distance_x <= f.profile.special.range * 1.2 and abs(distance_y) < 1.4

		commands.append({
			"move": move if not should_block else 0.0,
			"standard": distance_x <= f.profile.standard.range and abs(distance_y) < 1.1 and not special_ready and not should_block and not use_super,
			"special": (special_ready or use_super) and not should_block,
			"jump": want_jump and not should_block,
			"block": should_block or want_drop
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

	for i in range(2):
		var f: Dictionary = fighters[i]

		# Hitstop freeze
		if f.hitstop > 0:
			f.hitstop -= 1
			continue

		f.cooldowns[0] = maxf(0.0, f.cooldowns[0] - dt)
		f.cooldowns[1] = maxf(0.0, f.cooldowns[1] - dt)
		f.stun = maxf(0.0, f.stun - dt)
		f.pose_time = maxf(0.0, f.pose_time - dt)
		f.moving = false

		# Timers
		if f.drop_through > 0: f.drop_through = maxf(0.0, f.drop_through - dt)
		if f.invulnerable > 0: f.invulnerable = maxf(0.0, f.invulnerable - dt)

		# Combo timer decay
		if f.combo_timer > 0:
			f.combo_timer -= dt
			if f.combo_timer <= 0:
				if f.combo > 1:
					events.append({"type": "combo_end", "actor": i, "count": f.combo})
				f.combo = 0

		# Parry window tracking
		if f.parry_timer > 0: f.parry_timer -= dt

		# Super meter passive regeneration
		f.super = minf(MAX_SUPER, f.super + dt * 2.0)

		# Facing direction (turn towards opponent unless stunned)
		if f.stun <= 0:
			f.facing = 1 if fighters[1-i].x > f.x else -1

		# Horizontal knockback velocity damping
		if abs(f.vx) > 0.05:
			f.x += f.vx * dt
			f.vx = move_toward(f.vx, 0.0, 22.0 * dt)

		# User input processing
		if f.stun <= 0 and f.pending.is_empty():
			var cmd: Dictionary = commands[i]
			var want_block: bool = bool(cmd.get("block", false))
			var want_jump: bool = bool(cmd.get("jump", false))
			var axis := clampf(float(cmd.get("move", 0)), -1.0, 1.0)

			# Drop through platform if on a floating platform and pressing block/down
			if want_block and f.y > 0.2 and f.is_grounded:
				f.is_grounded = false
				f.y -= 0.12
				f.vy = -3.0
				f.drop_through = 0.35
				events.append({"type": "drop_through", "actor": i})
			elif want_block and f.is_grounded:
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
						# Air control boost towards stage if off-stage
						if f.x < STAGE_LEFT: f.vx = maxf(f.vx, 2.5)
						elif f.x > STAGE_RIGHT: f.vx = minf(f.vx, -2.5)
						events.append({"type": "double_jump", "actor": i})

				# Horizontal Movement
				if abs(axis) > 0.05:
					var speed_mod: float = 1.0 if f.is_grounded else 0.85
					f.x += axis * f.profile.speed * speed_mod * dt
					f.moving = true

				# Attacks
				if cmd.get("special", false) and f.super >= 40.0:
					queue_attack(i, true)
				elif cmd.get("standard", false):
					queue_attack(i, false)

			f["_was_blocking"] = want_block

		# Vertical physics & Landing Detection
		var prev_y: float = f.y
		if not f.is_grounded:
			f.vy -= GRAVITY * dt
			var next_y: float = f.y + f.vy * dt
			var landed := false

			# Check landings only when moving downwards
			if f.vy <= 0.0:
				# 1. Floating Platforms (only if not dropping through)
				if f.drop_through <= 0.0:
					for plat in PLATFORMS:
						if f.x >= plat.x1 and f.x <= plat.x2:
							# Crossed platform height from above
							if prev_y >= plat.y - 0.06 and next_y <= plat.y:
								f.y = plat.y
								f.vy = 0.0
								f.is_grounded = true
								f.air_jumps = 1
								landed = true
								events.append({"type": "land", "actor": i, "platform": plat.name})
								break

				# 2. Main Stage Floor (solid when within horizontal stage bounds)
				if not landed and f.x >= STAGE_LEFT and f.x <= STAGE_RIGHT:
					if prev_y >= -0.4 and next_y <= 0.0:
						f.y = 0.0
						f.vy = 0.0
						f.is_grounded = true
						f.air_jumps = 1
						landed = true
						events.append({"type": "land", "actor": i, "platform": "stage"})

			if not landed:
				f.y = next_y
		else:
			# Check if grounded fighter walked off edge
			var still_on_ground := false
			if abs(f.y) < 0.08:
				if f.x >= STAGE_LEFT and f.x <= STAGE_RIGHT:
					still_on_ground = true
			else:
				for plat in PLATFORMS:
					if abs(f.y - plat.y) < 0.10 and f.x >= plat.x1 and f.x <= plat.x2:
						still_on_ground = true
						break
			if not still_on_ground:
				f.is_grounded = false

		# Update animations
		if f.pose_time <= 0:
			if not f.is_grounded: f.pose = "Jump"
			elif f.blocking: f.pose = "Block"
			else: f.pose = "Move" if f.moving else "Idle"

		# Blast Zone / Ring Out Check (or HP KO)
		var is_ring_out: bool = (
			f.y < BLAST_ZONE_BOTTOM or
			f.x < BLAST_ZONE_LEFT or
			f.x > BLAST_ZONE_RIGHT or
			f.y > BLAST_ZONE_TOP
		)
		var is_hp_depleted: bool = (f.hp <= 0.0)

		if is_ring_out or is_hp_depleted:
			f.lives -= 1
			events.append({
				"type": "ring_out" if is_ring_out else "hp_ko",
				"actor": i,
				"lives": f.lives,
				"x": f.x,
				"y": f.y
			})

			if f.lives > 0:
				# Respawn back onto stage
				f.hp = f.profile.health
				f.x = -2.2 if i == 0 else 2.2
				f.y = 3.6
				f.vy = 0.0
				f.vx = 0.0
				f.is_grounded = false
				f.air_jumps = 1
				f.stun = 0.4
				f.invulnerable = 1.8
				f.super = 0.0
				f.combo = 0
				f.pose = "Idle"
				events.append({"type": "respawn", "actor": i, "lives": f.lives})
			else:
				# Elimination: Game over!
				f.hp = 0.0
				result = 1 - i
				for k in range(2):
					fighters[k].pose = "Victory" if result == k else "Defeat"
				events.append({"type": "finish", "winner": result})
				return

	# Body collision on same elevation
	if abs(fighters[0].y - fighters[1].y) < 0.8:
		var dist_x: float = fighters[1].x - fighters[0].x
		if abs(dist_x) < 0.75:
			var push_apart: float = (0.75 - abs(dist_x)) * 0.5
			var dir: float = -1.0 if dist_x < 0 else 1.0
			fighters[0].x -= dir * push_apart
			fighters[1].x += dir * push_apart

	# Contact resolution (Attacks)
	var contacts: Array = []
	for i in range(2):
		var f: Dictionary = fighters[i]
		if f.pending.is_empty(): continue
		f.pending.remaining -= dt
		if f.pending.remaining <= 0:
			var attack: Dictionary = f.pending
			f.pending = {}
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

		# Invulnerability check (e.g. after respawn)
		if target.invulnerable > 0:
			continue

		# Parry check
		var is_parry: bool = (
			target.get("blocking", false) and
			target.parry_timer > 0 and
			not target.parry_used and
			target.is_grounded and
			target.stun <= 0
		)
		var is_blocked: bool = (not is_parry) and target.get("blocking", false) and target.is_grounded and target.stun <= 0

		# Combo multiplier
		var combo_idx: int = mini(attacker.combo, COMBO_MULT.size() - 1)
		var combo_mult: float = COMBO_MULT[combo_idx]

		if is_parry:
			target.parry_used = true
			attacker.stun = 0.55
			attacker.pose = "HitReact"
			attacker.pose_time = 0.55
			target.super = minf(MAX_SUPER, target.super + 25.0)
			attacker.hitstop = HITSTOP_FRAMES * 2
			target.hitstop  = HITSTOP_FRAMES
			events.append({"type": "parry", "actor": contact.to, "target": contact.from})
		elif is_blocked:
			var damage: float = a.damage * clampf(1.0 - target.profile.stats.defense * 0.01, 0.6, 0.92) * 0.18
			target.hp = maxf(0, target.hp - damage)
			target.vx = attacker.facing * a.push * 4.0
			target.stun = 0.08
			target.pose = "Block"
			target.pose_time = 0.18
			attacker.super = minf(MAX_SUPER, attacker.super + 5.0)
			target.super   = minf(MAX_SUPER, target.super   + 3.0)
			attacker.hitstop = HITSTOP_FRAMES
			target.hitstop   = HITSTOP_FRAMES
			events.append({"type": "block", "target": contact.to, "damage": damage, "actor": contact.from})
		else:
			# Normal or Super hit
			var base_dmg: float = a.damage * clampf(1.0 - target.profile.stats.defense * 0.01, 0.6, 0.92)
			var super_bonus: float = 1.0
			if is_special and attacker.super >= 100.0:
				super_bonus = 1.70
				attacker.super = 0.0
				events.append({"type": "super_used", "actor": contact.from})
			elif is_special:
				attacker.super = maxf(0, attacker.super - 40.0)

			var damage: float = base_dmg * combo_mult * super_bonus
			target.hp = maxf(0, target.hp - damage)

			# Super Smash Bros Launch / Knockback Formula:
			# The more damage taken, the further the fighter is launched!
			var hp_loss_ratio: float = clampf(1.0 - (target.hp / target.profile.health), 0.0, 1.0)
			var launch_scale: float = 1.0 + hp_loss_ratio * 1.8

			# Horizontal Knockback Velocity
			var h_force: float = a.push * launch_scale * (2.8 if super_bonus > 1.0 else (1.9 if is_special else 1.2))
			target.vx = attacker.facing * h_force * 6.5

			# Vertical Pop-Up / Launch into air
			var v_launch: float = (5.5 if super_bonus > 1.0 else (4.2 if is_special else 2.5)) * (0.8 + hp_loss_ratio * 0.7)
			target.vy = v_launch
			target.is_grounded = false
			target.drop_through = 0.12

			target.stun = 0.28 if is_special else 0.20
			target.pose = "HitReact"
			target.pose_time = 0.32 if is_special else 0.22

			# Combo tracking
			attacker.combo = mini(attacker.combo + 1, COMBO_MULT.size() - 1)
			attacker.combo_timer = 1.25
			target.combo = 0

			attacker.super = minf(MAX_SUPER, attacker.super + (14.0 if is_special else 7.0))
			target.super   = minf(MAX_SUPER, target.super   + 9.0)

			var stop_frames: int = HITSTOP_FRAMES * 3 if super_bonus > 1.0 else (HITSTOP_FRAMES * 2 if is_special else HITSTOP_FRAMES)
			attacker.hitstop = stop_frames
			target.hitstop   = stop_frames
			events.append({"type": "hit", "target": contact.to, "damage": damage,
				"special": is_special, "combo": attacker.combo,
				"super_hit": super_bonus > 1.0, "actor": contact.from})

	# Time Out
	if time_left <= 0:
		if fighters[0].lives != fighters[1].lives:
			result = 0 if fighters[0].lives > fighters[1].lives else 1
		else:
			var a_pct: float = fighters[0].hp / fighters[0].profile.health
			var b_pct: float = fighters[1].hp / fighters[1].profile.health
			result = -1 if is_equal_approx(a_pct, b_pct) else (0 if a_pct > b_pct else 1)
		for i in range(2): fighters[i].pose = "Victory" if result == i else "Defeat"
		events.append({"type": "finish", "winner": result})

func queue_attack(index: int, special: bool) -> bool:
	var f: Dictionary = fighters[index]
	var slot := 1 if special else 0
	if result != -2 or countdown > 0 or f.hp <= 0 or f.stun > 0 or not f.pending.is_empty() or f.cooldowns[slot] > 0 or f.get("blocking", false):
		return false
	if special and f.super < 40.0: return false
	var ability: Dictionary = f.profile.special if special else f.profile.standard
	serial += 1
	f.pending = {"remaining": ability.windup, "ability": ability, "id": serial, "special": special}
	f.cooldowns[slot] = ability.cooldown
	f.pose = "SpecialAttack" if special else "LightAttack"
	f.pose_time = 0.6 if special else 0.35
	events.append({"type": "attack", "actor": index, "special": special})
	return true

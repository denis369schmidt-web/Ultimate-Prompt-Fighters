extends "res://tests/test_base.gd"
## Shield, dodges, ledges, the full moveset, charged smashes, DI, AI levels and the
## finisher phase – all on the real combat code.

func _initialize() -> void:
	call_deferred("run")

func place(f: Dictionary, x: float, y: float = 0.0, facing: int = 1) -> void:
	f.x = x
	f.y = y
	f.vx = 0.0
	f.vy = 0.0
	f.is_grounded = absf(y) < 0.01
	f.state = "Ready"
	f.pending = {}
	f.stun = 0.0
	f.hitstop = 0
	f.invulnerable = 0.0
	f.intangible = 0.0
	f.facing = facing
	f._prev_in = {}

## Ticks until the fighter's move is over (or max frames).
func until_idle(m, frames: int = 90) -> void:
	for n in range(frames):
		m.tick(idle_commands(m.fighters.size()))

func run() -> void:
	test_shield()
	test_dodges()
	test_ledge()
	test_moveset()
	test_smash_charge()
	test_di()
	test_short_hop_and_fast_fall()
	test_ai_levels()
	test_finisher()
	test_weapons()
	test_signatures()
	finish("combat_plus")

func test_shield() -> void:
	var m = match_ready()
	var a: Dictionary = m.fighters[0]
	var b: Dictionary = m.fighters[1]
	place(a, 0.0)
	place(b, 1.0, 0.0, -1)
	m.tick([cmd(), cmd({"block": true})])
	m.tick([cmd(), cmd({"block": true})])
	check(b.blocking and b.shield_hp < Combat.SHIELD_MAX, "holding shield raises it and drains it")
	for n in range(12): m.tick([cmd(), cmd({"block": true})]) # past the parry window
	var before: float = b.shield_hp
	m.queue_attack(0, false)
	for n in range(30): m.tick([cmd(), cmd({"block": true})])
	check(b.shield_hp < before - 5.0 and b.damage_percent < 3.0, "a blocked hit costs shield, barely any percent")
	b.shield_hp = 2.0
	m.fighters[0].cooldowns = [0.0, 0.0]
	place(a, 0.0)
	m.queue_attack(0, false)
	var broke := false
	for n in range(30):
		m.tick([cmd(), cmd({"block": true})])
		for ev in m.events:
			if ev.type == "shield_break": broke = true
	check(broke and b.state == "ShieldBreak", "an empty shield breaks and leaves the fighter stunned")
	for n in range(int(Combat.SHIELD_BREAK_STUN * 60) + 90): m.tick(idle_commands())
	check(b.state == "Ready", "shield break stun wears off")
	var hp_after: float = b.shield_hp
	for n in range(60): m.tick(idle_commands())
	check(b.shield_hp > hp_after, "the shield regenerates while released")

func test_dodges() -> void:
	var m = match_ready()
	var a: Dictionary = m.fighters[0]
	place(a, 0.0)
	place(m.fighters[1], 5.0, 0.0, -1)
	m.tick([cmd({"block": true, "move": 1.0}), cmd()])
	check(a.state == "Dodge" and a.dodge_kind == "roll" and a.intangible > 0.0, "shield + direction rolls with intangibility")
	until_idle(m, 40)
	check(a.state == "Ready" and a.x > 1.5, "the roll moves the fighter (x %.2f)" % a.x)
	place(a, 0.0)
	m.tick([cmd({"block": true, "down": true}), cmd()])
	check(a.state == "Dodge" and a.dodge_kind == "spot" and a.intangible > 0.0, "shield + down is a spot dodge")
	# Intangible fighters are not hit.
	place(a, 0.0)
	place(m.fighters[1], 1.0, 0.0, -1)
	a.intangible = 1.0
	m.fighters[1].cooldowns = [0.0, 0.0]
	m.queue_attack(1, false)
	until_idle(m, 30)
	check(a.damage_percent == 0.0, "an intangible fighter ignores hits")
	# Air dodge: once per airtime, directional.
	place(a, 0.0, 3.0)
	a.is_grounded = false
	a.intangible = 0.0
	m.tick([cmd({"block": true, "move": 1.0}), cmd()])
	check(a.state == "Dodge" and a.dodge_kind == "air" and a.vx > 5.0, "air dodge moves in the held direction")
	until_idle(m, 30)
	m.tick([cmd({"block": true}), cmd()])
	check(a.state != "Dodge" or a.is_grounded, "no second air dodge before landing")

func test_ledge() -> void:
	var m = match_ready()
	var f: Dictionary = m.fighters[0]
	place(f, Combat.STAGE_RIGHT + 0.5, -0.4)
	f.is_grounded = false
	f.vy = -1.0
	m.tick(idle_commands())
	check(f.state == "Ledge" and f.ledge == 1 and f.intangible > 0.5, "falling past the edge grabs the ledge with intangibility")
	for n in range(10): m.tick(idle_commands())
	m.tick([cmd({"move": -1.0}), cmd()])
	check(f.state == "Ready" and f.is_grounded and f.x < Combat.STAGE_RIGHT, "holding towards the stage climbs up")
	# Anti-planking: regrabs give less intangibility.
	var times: Array = []
	for g in range(3):
		place(f, Combat.STAGE_RIGHT + 0.5, -0.4)
		f.is_grounded = false
		f.vy = -1.0
		f.ledge_cooldown = 0.0
		m.tick(idle_commands())
		times.append(f.intangible)
		for n in range(8): m.tick(idle_commands())
		m.tick([cmd({"move": 1.0}), cmd()]) # drop away
		for n in range(3): m.tick(idle_commands())
	check(times[0] > times[1] and times[1] > times[2], "each regrab gives less intangibility %s" % str(times))
	# Trump: a second fighter takes the ledge.
	var m2 = match_ready()
	var a: Dictionary = m2.fighters[0]
	var b: Dictionary = m2.fighters[1]
	place(a, Combat.STAGE_LEFT - 0.5, -0.4)
	a.is_grounded = false
	a.vy = -1.0
	m2.tick(idle_commands())
	place(b, Combat.STAGE_LEFT - 0.6, -0.3)
	b.is_grounded = false
	b.vy = -1.0
	m2.tick(idle_commands())
	check(b.state == "Ledge" and a.state != "Ledge", "grabbing an occupied ledge pushes the holder off")
	# Nobody stands inside the stage body.
	place(a, 0.0, -2.0)
	a.is_grounded = false
	m2.tick(idle_commands())
	check(a.x <= Combat.STAGE_LEFT or a.x >= Combat.STAGE_RIGHT, "a fighter below the floor is pushed out of the stage body")

func test_moveset() -> void:
	var m = match_ready()
	var a: Dictionary = m.fighters[0]
	var b: Dictionary = m.fighters[1]
	for key in ["jab", "ftilt", "utilt", "dtilt", "fsmash", "usmash", "dsmash", "dash_attack", "nair", "fair", "bair", "uair", "dair", "nspecial", "uspecial", "dspecial"]:
		check(a.moves.has(key), "moveset contains %s" % key)
	# Up tilt hits an opponent standing on a platform above.
	place(a, 0.0)
	place(b, 0.3, 1.4, -1)
	b.is_grounded = false
	m.tick([cmd({"standard": true, "up": true}), cmd()])
	check(a.pending.get("key", "") == "utilt", "up + attack on the ground is an up tilt")
	var hit := false
	var launch_vy := 0.0
	for n in range(20):
		if not hit:
			b.y = 1.4
			b.vy = 0.0
		m.tick(idle_commands())
		if b.damage_percent > 0.0 and not hit:
			hit = true
			launch_vy = b.vy
	check(hit and launch_vy > 0.0, "up tilt hits above and launches upwards (vy %.1f)" % launch_vy)
	# Back air hits behind.
	m = match_ready()
	a = m.fighters[0]
	b = m.fighters[1]
	place(a, 0.0, 2.0)
	a.is_grounded = false
	place(b, -1.0, 2.0)
	b.is_grounded = false
	m.tick([cmd({"standard": true, "move": -1.0}), cmd()])
	check(a.pending.get("key", "") == "bair", "attack away from facing in the air is a back air")
	var min_vx := 0.0
	for n in range(20):
		b.y = 2.0
		m.tick(idle_commands())
		min_vx = minf(min_vx, b.vx)
	check(b.damage_percent > 0.0 and min_vx < 0.0, "back air hits behind and launches backwards")
	# Down air spikes an airborne opponent downwards.
	m = match_ready()
	a = m.fighters[0]
	b = m.fighters[1]
	place(a, 0.0, 4.0)
	a.is_grounded = false
	place(b, 0.0, 3.0)
	b.is_grounded = false
	b.damage_percent = 60.0
	m.tick([cmd({"standard": true, "down": true}), cmd()])
	var min_vy := 0.0
	for n in range(20):
		a.y = 4.0
		a.vy = 0.0
		m.tick(idle_commands())
		min_vy = minf(min_vy, b.vy)
	check(min_vy < -3.0, "down air is a meteor spike (vy %.1f)" % min_vy)
	# Aerials end on landing with landing lag.
	m = match_ready()
	a = m.fighters[0]
	place(a, 0.0, 0.3)
	a.is_grounded = false
	a.vy = -3.0
	m.tick([cmd({"standard": true}), cmd()])
	for n in range(8): m.tick(idle_commands())
	check(a.is_grounded and a.pending.is_empty(), "landing cancels an aerial")
	# Special no longer needs meter; up special climbs.
	m = match_ready()
	a = m.fighters[0]
	a.super = 0.0
	m.tick([cmd({"special": true, "up": true}), cmd()])
	var max_y := 0.0
	for n in range(40):
		m.tick(idle_commands())
		max_y = maxf(max_y, a.y)
	check(max_y > 1.0, "up special on the ground rises (%.2f m) without meter" % max_y)

func test_smash_charge() -> void:
	var dealt := []
	for hold in [0, 40]:
		var m = match_ready()
		var a: Dictionary = m.fighters[0]
		var b: Dictionary = m.fighters[1]
		place(a, 0.0)
		place(b, 1.2, 0.0, -1)
		m.tick([cmd({"standard": true, "standard_held": true, "move": 1.0}), cmd()])
		check(a.state == "Charge" or hold == 0, "holding attack with a direction charges a smash")
		for n in range(hold):
			m.tick([cmd({"standard_held": true}), cmd()])
		for n in range(50):
			m.tick(idle_commands())
		dealt.append(b.damage_percent)
	check(dealt[1] > dealt[0] * 1.5, "a charged smash hits much harder than a tap tilt (%.1f vs %.1f)" % [dealt[1], dealt[0]])

func test_di() -> void:
	var angles := []
	for di_y in [0.0, 1.0]:
		var m = match_ready()
		var a: Dictionary = m.fighters[0]
		var b: Dictionary = m.fighters[1]
		place(a, 0.0)
		place(b, 1.0, 0.0, -1)
		b.damage_percent = 100.0
		m.queue_attack(0, false)
		var launch := Vector2.ZERO
		for n in range(30):
			m.tick([cmd(), cmd({"up": di_y > 0.0})])
			if launch == Vector2.ZERO and b.state == "HitStun": launch = Vector2(b.vx, b.vy)
		angles.append(rad_to_deg(atan2(launch.y, absf(launch.x))))
	check(angles[1] > angles[0] + 5.0, "holding up (DI) bends the launch upwards (%.1f° -> %.1f°)" % [angles[0], angles[1]])

func test_short_hop_and_fast_fall() -> void:
	var heights := []
	for held in [true, false]:
		var m = match_ready()
		var a: Dictionary = m.fighters[0]
		place(a, -3.0)
		m.tick([cmd({"jump": true, "jump_held": true}), cmd()])
		var top := 0.0
		for n in range(60):
			m.tick([cmd({"jump_held": held}), cmd()])
			top = maxf(top, a.y)
		heights.append(top)
	check(heights[1] < heights[0] * 0.8, "releasing jump early is a short hop (%.2f vs %.2f m)" % [heights[1], heights[0]])
	var m = match_ready()
	var f: Dictionary = m.fighters[0]
	place(f, -3.0, 3.0)
	f.is_grounded = false
	f.vy = 0.5
	m.tick([cmd({"down": true}), cmd()])
	check(f.vy <= -12.0, "tapping down while falling fast-falls")

func test_ai_levels() -> void:
	var hits := [0, 0]
	var ended := true
	for lvl_idx in range(2):
		var m = match_ready("electric ninja", "lava golem")
		m.ai_level = [1, 9][lvl_idx]
		m.fighters[0].x = -3.0
		m.fighters[1].x = 3.0
		for n in range(6500):
			m.tick(m.agent_commands())
			for ev in m.events:
				if ev.type == "hit": hits[lvl_idx] += 1
			if m.result != -2: break
		ended = ended and m.result != -2
	check(ended and hits[0] > 0 and hits[1] > 0, "AI matches at level 1 and 9 end with hits (%s)" % str(hits))

	var agents = match_ready()
	agents.ai_level = 7
	var manual = match_ready()
	for n in range(400):
		var c: Array = agents.agent_commands()
		agents.tick(c)
		manual.tick(c)
	check(agents.fighters == manual.fighters, "AI memory does not leak into the match state (replays stay exact)")

func test_finisher() -> void:
	var m = match_ready("electric ninja", "lava golem", 1)
	m.finishers_enabled = true
	var w: Dictionary = m.fighters[0]
	var l: Dictionary = m.fighters[1]
	place(w, 0.0)
	l.x = Combat.BLAST_ZONE_RIGHT + 1.0
	l.is_grounded = false
	m.tick(idle_commands())
	check(m.finish_phase and m.result == -2 and l.state == "Dazed", "last KO starts the finisher phase instead of ending the match")
	var fin: Dictionary = Combat.finisher_for(w.profile)
	check(fin.code.size() == 3 and fin.kind == "storm", "electric fighter's finisher is %s (%s)" % [fin.name, Combat.code_text(fin.code)])
	# Enter the code: U, D, S (with neutral frames in between).
	var executed := false
	var toward: float = 1.0 if l.x > w.x else -1.0
	for token in fin.code:
		var c := {}
		match token:
			"U": c = {"jump": true}
			"D": c = {"down": true}
			"S": c = {"special": true}
			"A": c = {"standard": true}
			"F": c = {"move": toward}
			"B": c = {"move": -toward}
		m.tick([cmd(c), cmd()])
		for ev in m.events:
			if ev.type == "finisher": executed = true
		m.tick(idle_commands())
		for ev in m.events:
			if ev.type == "finisher": executed = true
		for n in range(12): m.tick(idle_commands())
	check(executed and m.result == 0 and l.state == "Defeated", "entering the code executes the finisher and wins")

	m = match_ready("electric ninja", "lava golem", 1)
	m.finishers_enabled = true
	m.fighters[1].x = Combat.BLAST_ZONE_RIGHT + 1.0
	m.fighters[1].is_grounded = false
	m.tick(idle_commands())
	var got_finish := false
	for n in range(int(Combat.FINISH_TIME * 60) + 5):
		m.tick(idle_commands())
		for ev in m.events:
			if ev.type == "finish" and not ev.finisher: got_finish = true
	check(got_finish and m.result == 0, "without the code the match ends normally after the window")

	m = match_ready("electric ninja", "lava golem", 1)
	m.finishers_enabled = true
	m.ai_level = 9
	m.fighters[0].x = 0.0
	m.fighters[1].x = Combat.BLAST_ZONE_RIGHT + 1.0
	m.fighters[1].is_grounded = false
	m.tick(m.agent_commands())
	var ai_fin := false
	for n in range(int(Combat.FINISH_TIME * 60)):
		m.tick(m.agent_commands())
		for ev in m.events:
			if ev.type == "finisher": ai_fin = true
		if m.result != -2: break
	check(m.result == 0, "the computer winner finishes the phase (finisher performed: %s)" % str(ai_fin))

	var off = match_ready("electric ninja", "lava golem", 1)
	off.fighters[1].x = Combat.BLAST_ZONE_RIGHT + 1.0
	off.fighters[1].is_grounded = false
	off.tick(idle_commands())
	check(off.result == 0 and not off.finish_phase, "with finishers disabled the last KO ends the match at once")

func test_weapons() -> void:
	check(Combat.WEAPONS.size() == 8, "8 arena weapons exist (5 swords + 3 others)")
	# Pick up a sword with grab and hit harder than bare-handed.
	var dealt := []
	for armed in [false, true]:
		var m = match_ready()
		var a: Dictionary = m.fighters[0]
		var b: Dictionary = m.fighters[1]
		place(a, 0.0)
		place(b, 1.3, 0.0, -1)
		if armed:
			var idx: int = m.spawn_weapon("sword_hero", 0.2, 0.15)
			m.tick([cmd({"grab": true}), cmd()])
			check(a.weapon.get("id", "") == "sword_hero" and m.items[idx].state == "wielded", "grab picks up and wields the sword")
			place(a, 0.0)
		m.queue_attack(0, false)
		for n in range(40): m.tick(idle_commands())
		dealt.append(b.damage_percent)
	check(dealt[1] > dealt[0] * 1.3, "a sword hits much harder (%.1f vs %.1f)" % [dealt[1], dealt[0]])

	# Weapon special fires a projectile that hits at range.
	var m = match_ready()
	var a: Dictionary = m.fighters[0]
	var b: Dictionary = m.fighters[1]
	place(a, -3.0)
	place(b, 2.0, 0.0, -1)
	m.spawn_weapon("sword_crescent", -2.9, 0.15)
	m.tick([cmd({"grab": true}), cmd()])
	place(a, -3.0)
	m.queue_attack(0, true)
	var fired := false
	for n in range(60):
		m.tick(idle_commands())
		if not m.projectiles.is_empty(): fired = true
	check(fired and b.damage_percent > 0.0, "the crescent wave flies across the stage and hits (%.1f%%)" % b.damage_percent)

	# Returning boomerang, laser blaster, frost freeze.
	m = match_ready()
	a = m.fighters[0]
	b = m.fighters[1]
	place(a, -2.0)
	place(b, 6.0, 0.0, -1)
	m.spawn_weapon("boomerang", -1.9, 0.15)
	m.tick([cmd({"grab": true}), cmd()])
	place(a, -2.0)
	m.queue_attack(0, false)
	var max_x := -99.0
	var came_back := false
	for n in range(150):
		m.tick(idle_commands())
		for pr in m.projectiles:
			max_x = maxf(max_x, pr.x)
			if pr.returning and pr.x < -1.0: came_back = true
	check(max_x > 1.0 and came_back, "the boomerang flies out and returns (max x %.1f)" % max_x)

	m = match_ready()
	a = m.fighters[0]
	b = m.fighters[1]
	place(a, 0.0)
	place(b, 1.2, 0.0, -1)
	m.spawn_weapon("sword_frost", 0.1, 0.15)
	m.tick([cmd({"grab": true}), cmd()])
	place(a, 0.0)
	m.queue_attack(0, false)
	var froze := false
	for n in range(40):
		m.tick(idle_commands())
		if b.freeze_timer > 0.0: froze = true
	check(froze, "the frost sword freezes on hit")

	# Weapons break after their uses; grab throws the weapon.
	m = match_ready()
	a = m.fighters[0]
	place(a, 0.0)
	place(m.fighters[1], 6.0, 0.0, -1)
	m.spawn_weapon("sword_buster", 0.1, 0.15)
	m.tick([cmd({"grab": true}), cmd()])
	var broke := false
	for k in range(Combat.WEAPONS["sword_buster"].uses + 1):
		a.cooldowns = [0.0, 0.0]
		m.queue_attack(0, false)
		for n in range(50):
			m.tick(idle_commands())
			for ev in m.events:
				if ev.type == "weapon_break": broke = true
	check(broke and a.weapon.is_empty(), "a weapon breaks after its uses")
	m = match_ready()
	a = m.fighters[0]
	place(a, 0.0)
	var idx2: int = m.spawn_weapon("flail", 0.1, 0.15)
	m.tick([cmd({"grab": true}), cmd()])
	m.tick([cmd(), cmd()])
	m.tick([cmd({"grab": true}), cmd()])
	var thrown := false
	for ev in m.events:
		if ev.type == "item_throw": thrown = true
	check(thrown and a.weapon.is_empty() and m.items[idx2].state != "wielded", "grab while armed throws the weapon")

	# Random spawns include weapons.
	m = match_ready()
	var spawned := 0
	for n in range(30):
		m.spawn_random_item()
	for it in m.items:
		if it.get("weapon", "") != "": spawned += 1
	check(spawned >= 10, "random item spawns bring weapons into the arena (%d of 30)" % spawned)

const Signatures = preload("res://scripts/signatures.gd")

func sig_match(prompt: String):
	var m = match_ready(prompt, "electric ninja")
	place(m.fighters[0], -1.5)
	place(m.fighters[1], 1.5, 0.0, -1)
	return m

func test_signatures() -> void:
	# Every roster card has its own signature special, and every one runs and does something.
	var app_presets: Array = []
	var families := {}
	var mechs := {}
	for fam in Signatures.SIGS:
		mechs[Signatures.SIGS[fam].mech] = true
	check(mechs.size() >= 14, "at least 14 different special mechanics (%d)" % mechs.size())
	var prompts := {
		"ninja": "Blitzschneller Schattenninja mit elektrischen Klingen", "golem": "Gepanzerter Lavagolem mit brennenden Fäusten",
		"goku": "Kairo der Sturmmönch mit Solar-Kanone", "luffy": "Tobi der Gummikapitän mit Schleuderfaust",
		"akaza": "Raiga der Kompassdämon mit Kompassnova", "tripo_quadruped_tree": "Sylvan Beast Treant quadruped creature Tripo",
		"wizard_sorcerer": "Erzmagier Pyrus Feuerzauberer mit Meteorschlag und Flammenstab", "nekra": "Nekra die Seelenhirtin mit Knochengarten",
		"grimbolt": "Grimbolt der Goblin-Tüftler mit Zeitbombe", "echo": "Echo das Hologramm mit Phasentausch",
		"kettenwart": "Kettenwart der Kerkermeister mit Seelenketten", "don_valente": "Don Valente der Unterweltpate mit Leibwächter-Geschütz",
		"naruto": "Ren der Wirbelfuchs mit Spiralkern", "sasuke": "Kage der Donnerklinge mit Tausend Funken",
		"pain": "Oryn der Schwerkraftprophet mit Abstoßungswelle", "anubis": "Jackal God Anubis wielding dual Khopesh",
	}
	for fam in prompts:
		var m = sig_match(prompts[fam])
		var a: Dictionary = m.fighters[0]
		var b: Dictionary = m.fighters[1]
		check(a.profile.family == fam, "prompt picks %s" % fam)
		var sig: Dictionary = Signatures.for_family(fam)
		m.queue_attack(0, true)
		var fired := false
		var effect := false
		for n in range(200):
			m.tick(idle_commands())
			for ev in m.events:
				if ev.type == "signature": fired = true
			if b.damage_percent > 0.0 or a.rage_timer > 0.0 or a.counter > 0.0: effect = true
		check(fired and effect, "%s signature (%s) runs and has an effect" % [fam, sig.get("mech", "?")])

	# Teleport ends behind the opponent.
	var m = sig_match("Blitzschneller Schattenninja mit elektrischen Klingen")
	m.queue_attack(0, true)
	for n in range(30): m.tick(idle_commands())
	check(m.fighters[0].x > m.fighters[1].x - 0.01 or m.fighters[1].damage_percent > 0.0, "teleport strike appears on the far side")
	# Swap exchanges positions.
	m = sig_match("Echo das Hologramm mit Phasentausch")
	var ax: float = m.fighters[0].x
	m.queue_attack(0, true)
	var swapped := false
	for n in range(60):
		m.tick(idle_commands())
		for ev in m.events:
			if ev.type == "swap": swapped = true
	check(swapped and m.fighters[0].x > ax + 1.0, "phase swap exchanges positions")
	# Counter answers an attack.
	m = sig_match("Raiga der Kompassdämon mit Kompassnova")
	place(m.fighters[1], -0.5, 0.0, 1)
	m.queue_attack(0, true)
	for n in range(10): m.tick(idle_commands())
	m.fighters[1].cooldowns = [0.0, 0.0]
	m.queue_attack(1, false)
	var countered := false
	for n in range(40):
		m.tick(idle_commands())
		for ev in m.events:
			if ev.type == "counter": countered = true
	check(countered and m.fighters[1].damage_percent > 0.0 and m.fighters[0].damage_percent == 0.0, "counter stance answers the attack")
	# Chains pull opponents in.
	m = sig_match("Kettenwart der Kerkermeister mit Seelenketten")
	place(m.fighters[1], 2.8, 0.0, -1)
	var start_gap: float = absf(m.fighters[1].x - m.fighters[0].x)
	m.queue_attack(0, true)
	var min_gap := start_gap
	for n in range(40):
		m.tick(idle_commands())
		min_gap = minf(min_gap, absf(m.fighters[1].x - m.fighters[0].x))
	check(min_gap < start_gap - 0.3, "soul chains pull the opponent in (%.2f -> %.2f)" % [start_gap, min_gap])
	# Time bomb explodes on its own.
	m = sig_match("Grimbolt der Goblin-Tüftler mit Zeitbombe")
	place(m.fighters[1], 6.0, 0.0, -1)
	m.queue_attack(0, true)
	var blast := false
	for n in range(160):
		m.tick(idle_commands())
		for ev in m.events:
			if ev.type == "blast": blast = true
	check(blast, "time bomb explodes after its fuse")

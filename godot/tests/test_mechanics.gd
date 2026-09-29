extends "res://tests/test_base.gd"
## Platform, knockback, grab/throw and item mechanics on the real combat code.
## Replaces the former scripts/test_smash_mechanics.gd, test_grab_and_items.gd and
## test_explosive_barrel.gd, which hung headless on stale stage coordinates.

func _initialize() -> void:
	call_deferred("run")

## Resets a fighter to a neutral grounded state at x.
func place(f: Dictionary, x: float, y: float = 0.0) -> void:
	f.x = x
	f.y = y
	f.vx = 0.0
	f.vy = 0.0
	f.is_grounded = true
	f.state = "Ready"
	f.pending = {}
	f.stun = 0.0
	f.hitstop = 0
	f.invulnerable = 0.0
	f.grab_immunity = 0.0
	f.carried_item = -1
	f.grab_target = -1
	f.grabbed_by = -1

func run() -> void:
	test_platforms()
	test_ring_out()
	test_knockback_scaling()
	test_weight()
	test_grab_and_throw()
	test_item_throw()
	test_explosive_barrel()
	test_hitbox_direction()
	test_invulnerable_ring_out()
	test_facing()
	test_air_dash()
	finish("mechanics")

func test_hitbox_direction() -> void:
	var m = match_ready()
	var a: Dictionary = m.fighters[0]
	var b: Dictionary = m.fighters[1]
	place(a, 0.0)
	place(b, -1.0)
	a.facing = 1
	m.queue_attack(0, false)
	run_ticks(m, 30)
	check(b.damage_percent == 0.0, "directional attack does not hit an opponent behind the attacker")

	m = match_ready()
	a = m.fighters[0]
	b = m.fighters[1]
	place(a, 0.0)
	place(b, 1.0)
	a.facing = 1
	m.queue_attack(0, false)
	run_ticks(m, 30)
	check(b.damage_percent > 0.0, "directional attack hits an opponent in front")

	# All-around special (the sun dancer's whirl) hits behind and launches away from the attacker.
	check(Combat.is_all_around(Prompt.interpret("lava golem", 0).special), "golem prompt special is an all-around type")
	m = match_ready("Hikaru der Sonnentänzer mit Morgenrotschnitt", "electric ninja")
	a = m.fighters[0]
	b = m.fighters[1]
	place(a, 0.0)
	place(b, -1.0)
	a.facing = 1
	m.queue_attack(0, true)
	var min_vx := 0.0
	for n in range(40):
		m.tick(idle_commands())
		min_vx = minf(min_vx, b.vx)
	check(b.damage_percent > 0.0 and min_vx < 0.0, "all-around special hits behind and pushes away from the attacker")

func test_invulnerable_ring_out() -> void:
	var m = match_ready()
	var f: Dictionary = m.fighters[1]
	f.invulnerable = 10.0
	f.x = Combat.BLAST_ZONE_RIGHT + 1.0
	f.is_grounded = false
	m.tick(idle_commands())
	check(f.lives == 2, "an invulnerable fighter still loses a stock at the blast zone")

func test_facing() -> void:
	var m = match_ready()
	var a: Dictionary = m.fighters[0]
	place(a, -2.0)
	place(m.fighters[1], 2.0)
	m.tick([cmd({"move": -1.0}), cmd()])
	check(a.facing == -1, "held direction turns a grounded fighter away from the opponent")
	m.tick(idle_commands())
	check(a.facing == 1, "without input the fighter turns back towards the opponent")
	m.queue_attack(0, false)
	a.facing = -1
	m.tick(idle_commands())
	check(a.facing == -1, "an attack in progress does not auto-turn the fighter")

func test_platforms() -> void:
	var m = match_ready()
	var plat: Dictionary = Combat.PLATFORMS[0]
	var px: float = (plat.x1 + plat.x2) * 0.5
	var f: Dictionary = m.fighters[0]
	f.x = px
	f.y = plat.y + 0.6
	f.vy = -2.0
	f.is_grounded = false
	run_ticks(m, 40)
	check(f.is_grounded and absf(f.y - plat.y) < 0.01, "fighter lands on platform %s" % plat.name)

	m.tick([cmd({"block": true}), cmd()])
	check(f.is_grounded, "blocking on a platform keeps the fighter on it")

	m.tick([cmd({"block": true, "jump": true}), cmd()])
	check(not f.is_grounded, "block+jump drops through the platform")

	run_ticks(m, 90)
	check(f.is_grounded and absf(f.y) < 0.01, "dropped fighter lands on the main stage")

func test_ring_out() -> void:
	var m = match_ready()
	var f: Dictionary = m.fighters[1]
	f.x = Combat.STAGE_RIGHT + 2.0
	f.y = 0.0
	f.is_grounded = false
	var ring_out := false
	for n in range(180):
		m.tick(idle_commands())
		for ev in m.events:
			if ev.type == "ring_out": ring_out = true
		if ring_out: break
	check(ring_out, "falling past the bottom blast zone triggers a ring-out")
	check(f.lives == 2 and f.y > 1.0, "ring-out costs one stock and respawns above the stage")

func test_knockback_scaling() -> void:
	var launch := []
	for percent in [0.0, 120.0]:
		var m = match_ready()
		place(m.fighters[0], 0.0)
		place(m.fighters[1], 1.0)
		m.fighters[1].damage_percent = percent
		m.queue_attack(0, false)
		var speed := 0.0
		for n in range(30):
			m.tick(idle_commands())
			speed = maxf(speed, Vector2(m.fighters[1].vx, m.fighters[1].vy).length())
		launch.append(speed)
	check(launch[1] > launch[0] * 1.5, "knockback grows with damage percent (%.2f -> %.2f)" % [launch[0], launch[1]])

func test_weight() -> void:
	var ninja: Dictionary = Prompt.interpret("Volt Shadow Ninja electric speed", 0)
	var golem: Dictionary = Prompt.interpret("Cinder Bastion Golem basalt tank", 1)
	check(golem.weight > ninja.weight, "golem is heavier than ninja (%.2f > %.2f)" % [golem.weight, ninja.weight])

func test_grab_and_throw() -> void:
	var m = match_ready()
	var a: Dictionary = m.fighters[0]
	var b: Dictionary = m.fighters[1]
	# Keep both away from items so grab targets the opponent.
	place(a, 0.0)
	place(b, 0.8)
	a.facing = 1
	m.tick([cmd({"grab": true}), cmd()])
	check(a.state == "Grab", "grab input enters the Grab state")
	run_ticks(m, 10)
	check(a.state == "Carrying" and a.grab_target == 1, "attacker holds the opponent")
	check(b.state == "Grabbed" and b.grabbed_by == 0, "opponent is in the Grabbed state")

	var before: float = b.damage_percent
	m.tick([cmd({"move": 1.0}), cmd()])
	check(a.state == "Throw" and b.state == "HitStun", "forward throw launches the opponent")
	check(b.vx > 1.5, "forward throw sends the opponent forward (vx %.2f)" % b.vx)
	check(b.damage_percent > before, "throw deals damage")
	check(b.grab_immunity > 0.5, "thrown fighter gets anti-chain-grab immunity")

func test_item_throw() -> void:
	var m = match_ready()
	var a: Dictionary = m.fighters[0]
	var b: Dictionary = m.fighters[1]
	var crate: Dictionary = m.items[0]
	place(a, crate.x, crate.y - 0.1)
	place(b, crate.x + 5.0)
	m.tick([cmd({"grab": true}), cmd()])
	check(a.state == "Carrying" and a.carried_item == 0 and crate.state == "carried", "fighter picks up %s" % crate.name)

	place(a, -1.5)
	a.state = "Carrying"
	a.carried_item = 0
	a.facing = 1
	place(b, 2.5)
	m.tick([cmd({"grab": true}), cmd()])
	check(crate.state == "thrown" and crate.vx > 5.0, "carried item is thrown forward")

	var hit := false
	for n in range(40):
		m.tick(idle_commands())
		for ev in m.events:
			if ev.type == "item_hit": hit = true
		if hit: break
	check(hit and b.damage_percent > 0.0, "thrown item hits and damages the opponent")

func test_explosive_barrel() -> void:
	var m = match_ready()
	var idx := -1
	for k in range(m.items.size()):
		if m.items[k].type == "explosive_barrel": idx = k
	check(idx >= 0 and m.items[idx].explosive, "explosive barrel exists")
	if idx < 0: return
	var barrel: Dictionary = m.items[idx]
	var a: Dictionary = m.fighters[0]
	var b: Dictionary = m.fighters[1]
	barrel.x = -1.0
	barrel.y = 0.15
	place(a, -1.0)
	place(b, 1.5)
	m.tick([cmd({"grab": true}), cmd()])
	check(a.carried_item == idx and barrel.state == "carried", "fighter picks up the explosive barrel")
	a.facing = 1
	m.tick([cmd({"grab": true}), cmd()])
	check(barrel.state == "thrown", "explosive barrel is thrown")
	var exploded := false
	for n in range(80):
		m.tick(idle_commands())
		for ev in m.events:
			if ev.type == "item_explode": exploded = true
		if exploded: break
	check(exploded, "explosive barrel detonates on impact")
	check(b.damage_percent > 0.0 and barrel.state == "destroyed", "explosion damages the opponent and destroys the barrel")

func test_air_dash() -> void:
	var m = match_ready()
	var f: Dictionary = m.fighters[0]
	place(f, Combat.STAGE_RIGHT + 3.0, -1.0)
	f.is_grounded = false
	f.air_jumps = 0
	f.vy = -3.0
	m.tick([cmd({"special": true}), cmd()])
	check(f.air_dash_used and f.vx < -5.0 and f.vy > 0.0, "air special dashes back towards the stage (vx %.1f, vy %.1f)" % [f.vx, f.vy])
	var vx_after: float = f.vx
	m.tick([cmd({"special": true}), cmd()])
	check(f.vx >= vx_after, "air dash works only once per airtime")
	var recovered := false
	for n in range(120):
		m.tick(idle_commands())
		if f.is_grounded and f.lives == 3: recovered = true; break
	check(recovered, "the dash alone brings a fighter from off stage back to the stage")
	check(not f.air_dash_used, "landing restores the air dash")
	m.tick([cmd({"special": true, "move": 1.0}), cmd()])
	check(not f.air_dash_used, "special on the ground is not a dash")

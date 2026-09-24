extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")

func _init() -> void:
	print("==================================================")
	print("TESTING SMASH KNOCKBACK, GRAB/THROW & ARENA ITEMS")
	print("==================================================")

	var p1: Dictionary = Prompt.interpret("Volt Shadow Ninja electric speed", 0)
	var p2: Dictionary = Prompt.interpret("Cinder Bastion Golem basalt tank", 1)

	assert(Prompt.valid(p1) and Prompt.valid(p2), "Profiles must be valid")

	var sim := Combat.new()
	sim.start(p1, p2, "manual")
	sim.countdown = 0.0

	# ─────────────────────────────────────────────────────────────────────────────
	# 1. TEST: Damage-dependent Knockback scaling
	# ─────────────────────────────────────────────────────────────────────────────
	print("\n--- 1. Testing Damage-Dependent Knockback Scaling ---")
	# Hit at 100% HP
	sim.fighters[1].hp = sim.fighters[1].max_hp
	var attack_data = {"ability": p1.standard, "special": false, "remaining": 0.0, "hit_done": false}
	sim.fighters[0].pending = attack_data
	sim.fighters[0].x = 0.0
	sim.fighters[1].x = 1.0
	sim.fighters[1].y = 0.0
	sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false},
			  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}], 0.016)

	var impulse_high_hp: float = abs(sim.fighters[1].vx)
	print("Launch speed at 100% HP: ", impulse_high_hp)

	# Now hit at 20% HP
	sim.fighters[1].hp = sim.fighters[1].max_hp * 0.20
	sim.fighters[1].invulnerable = 0.0
	sim.fighters[0].pending = {"ability": p1.standard, "special": false, "remaining": 0.0, "hit_done": false}
	sim.fighters[0].x = 0.0
	sim.fighters[1].x = 1.0
	sim.fighters[1].y = 0.0
	sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false},
			  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}], 0.016)

	var impulse_low_hp: float = abs(sim.fighters[1].vx)
	print("Launch speed at 20% HP: ", impulse_low_hp)
	assert(impulse_low_hp > impulse_high_hp * 1.5, "Lower HP must result in significantly higher launch!")
	print("✓ Damage-dependent knockback verified! (%.2f vs %.2f)" % [impulse_low_hp, impulse_high_hp])

	# ─────────────────────────────────────────────────────────────────────────────
	# 2. TEST: Weight mitigation (Heavy Golem vs Light Ninja)
	# ─────────────────────────────────────────────────────────────────────────────
	print("\n--- 2. Testing Weight Mitigation ---")
	print("Golem weight: ", p2.weight, " | Ninja weight: ", p1.weight)
	assert(p2.weight > p1.weight, "Golem must be heavier than ninja")
	print("✓ Weight differential verified")

	# ─────────────────────────────────────────────────────────────────────────────
	# 3. TEST: Grab and Forward Throw
	# ─────────────────────────────────────────────────────────────────────────────
	print("\n--- 3. Testing Grab and Throw ---")
	sim.fighters[0].state = "Ready"
	sim.fighters[0].pending = {}
	sim.fighters[0].hitstop = 0
	sim.fighters[0].stun = 0.0
	sim.fighters[0].grab_immunity = 0.0
	sim.fighters[0].vx = 0.0
	sim.fighters[0].vy = 0.0
	sim.fighters[0].x = 0.0
	sim.fighters[0].y = 0.0
	sim.fighters[0].is_grounded = true

	sim.fighters[1].state = "Ready"
	sim.fighters[1].pending = {}
	sim.fighters[1].hitstop = 0
	sim.fighters[1].stun = 0.0
	sim.fighters[1].vx = 0.0
	sim.fighters[1].vy = 0.0
	sim.fighters[1].x = 0.8
	sim.fighters[1].y = 0.0
	sim.fighters[1].is_grounded = true
	sim.fighters[1].invulnerable = 0.0
	sim.fighters[1].grab_immunity = 0.0

	# P1 presses grab
	sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": true},
			  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}], 0.016)
	assert(sim.fighters[0].state == "Grab", "P1 should enter Grab state")

	# Wait for grab startup
	for step in range(10):
		sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false},
				  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}], 0.016)

	print("P1 state: ", sim.fighters[0].state, " | P2 state: ", sim.fighters[1].state, " | P1 target: ", sim.fighters[0].grab_target, " | grab_timer: ", sim.fighters[0].grab_timer)
	assert(sim.fighters[0].state == "Carrying" and sim.fighters[0].grab_target == 1, "P1 should be holding P2")
	assert(sim.fighters[1].state == "Grabbed" and sim.fighters[1].grabbed_by == 0, "P2 should be Grabbed")
	print("✓ Opponent grabbed successfully!")

	# Now P1 performs Forward Throw (move = 1.0 in facing direction)
	var hp_before_throw: float = sim.fighters[1].hp
	sim.tick([{"move": 1.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false},
			  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}], 0.016)

	assert(sim.fighters[0].state == "Throw", "P1 should be in Throw state")
	assert(sim.fighters[1].state == "HitStun", "P2 should be launched in HitStun")
	assert(sim.fighters[1].vx > 5.0, "P2 must have strong forward launch velocity")
	assert(sim.fighters[1].hp < hp_before_throw, "P2 must take throw damage")
	assert(sim.fighters[1].grab_immunity > 0.5, "P2 must have anti-chain-grab immunity")
	print("✓ Forward Throw executed with launch velocity: %.2f and damage!" % sim.fighters[1].vx)

	# ─────────────────────────────────────────────────────────────────────────────
	# 4. TEST: Arena Items (Pickup, Throw, Hit)
	# ─────────────────────────────────────────────────────────────────────────────
	print("\n--- 4. Testing Arena Items ---")
	sim.fighters[0].state = "Ready"
	sim.fighters[0].carried_item = -1
	sim.fighters[0].x = sim.items[0].x
	sim.fighters[0].y = sim.items[0].y
	sim.fighters[0].vx = 0.0
	sim.fighters[0].vy = 0.0
	sim.items[0].state = "resting"

	sim.fighters[1].state = "Ready"
	sim.fighters[1].vx = 0.0
	sim.fighters[1].vy = 0.0
	sim.fighters[1].x = 0.8
	sim.fighters[1].y = 0.0
	sim.fighters[1].is_grounded = true
	sim.fighters[1].invulnerable = 0.0
	sim.fighters[1].stun = 0.0

	# P1 presses grab near item -> picks it up
	sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": true},
			  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}], 0.016)

	assert(sim.fighters[0].state == "Carrying", "P1 should be Carrying item")
	assert(sim.fighters[0].carried_item == 0, "P1 should carry item 0 (Leichte Kiste)")
	assert(sim.items[0].state == "carried", "Item state should be carried")
	print("✓ Item picked up successfully: ", sim.items[0].name)

	# Now P1 throws the item towards P2 on the main stage
	sim.fighters[0].x = -1.5
	sim.fighters[0].y = 0.0
	sim.fighters[0].is_grounded = true
	sim.fighters[0].facing = 1

	sim.fighters[1].state = "Ready"
	sim.fighters[1].x = 0.8
	sim.fighters[1].y = 0.0
	sim.fighters[1].is_grounded = true
	sim.fighters[1].invulnerable = 0.0
	var p2_hp_before_item: float = sim.fighters[1].hp

	sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": true},
			  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}], 0.016)

	assert(sim.items[0].state == "thrown", "Item should now be thrown")
	assert(sim.items[0].vx > 5.0, "Item should have forward throw velocity")
	print("✓ Item thrown with velocity: ", sim.items[0].vx)

	# Simulate frames until item hits P2
	var item_hit := false
	for frame in range(40):
		sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false},
				  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}], 0.016)
		print("Frame %d: item(%.2f, %.2f) state=%s vs P2(%.2f, %.2f)" % [frame, sim.items[0].x, sim.items[0].y, sim.items[0].state, sim.fighters[1].x, sim.fighters[1].y])
		for ev in sim.events:
			if ev.type == "item_hit":
				item_hit = true
				break
		if item_hit: break

	assert(item_hit, "Item should hit P2")
	assert(sim.fighters[1].hp < p2_hp_before_item, "P2 should take item damage")
	print("✓ Item hit opponent successfully! HP decreased from %.1f to %.1f" % [p2_hp_before_item, sim.fighters[1].hp])

	print("\n==================================================")
	print("ALL SMASH KNOCKBACK, GRAB/THROW & ITEM TESTS PASSED!")
	print("==================================================")
	quit()

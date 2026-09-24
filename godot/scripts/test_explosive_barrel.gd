extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")

func _init() -> void:
	print("==================================================")
	print("TESTING EXPLOSIVE BARREL MECHANICS")
	print("==================================================")

	var p1: Dictionary = Prompt.interpret("Cyber Volt Ninja swift blade", 0)
	var p2: Dictionary = Prompt.interpret("Magma Titan Golem heavy stone", 1)
	assert(Prompt.valid(p1) and Prompt.valid(p2))

	var sim := Combat.new()
	sim.start(p1, p2, "manual")
	sim.countdown = 0.0

	# Verify explosive barrel exists in items
	var barrel_idx := -1
	for idx in range(sim.items.size()):
		if sim.items[idx].type == "explosive_barrel":
			barrel_idx = idx
			break
	assert(barrel_idx >= 0, "Explosive barrel must exist in items")
	var barrel: Dictionary = sim.items[barrel_idx]
	assert(barrel.explosive == true, "Barrel must be flagged as explosive")
	print("[OK] Explosive barrel found: ", barrel.name, " at (", barrel.x, ", ", barrel.y, ")")

	# Position fighter 0 and barrel on main battle plane for direct throw test
	barrel.x = -1.0
	barrel.y = 0.15
	sim.fighters[0].x = -1.0
	sim.fighters[0].y = 0.0
	sim.fighters[0].is_grounded = true
	sim.fighters[0].state = "Ready"
	sim.fighters[0].carried_item = -1

	# P1 grabs barrel
	sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": true},
			  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}], 0.016)

	assert(sim.fighters[0].state == "Carrying" and sim.fighters[0].carried_item == barrel_idx, "P1 should be carrying explosive barrel")
	assert(sim.items[barrel_idx].state == "carried", "Barrel state should be carried")
	print("[OK] Explosive barrel picked up successfully")

	# P1 throws barrel towards P2 at x = 1.5
	sim.fighters[0].facing = 1
	sim.fighters[1].x = 1.5
	sim.fighters[1].y = 0.0
	sim.fighters[1].is_grounded = true
	sim.fighters[1].invulnerable = 0.0
	var p2_hp_before: float = sim.fighters[1].hp

	sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": true},
			  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}], 0.016)

	assert(sim.items[barrel_idx].state == "thrown", "Barrel should now be thrown")
	print("[OK] Explosive barrel thrown with vx: ", sim.items[barrel_idx].vx)

	# Simulate until explosion (allow up to 80 frames for flight from top platform)
	var exploded := false
	for frame in range(80):
		sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false},
				  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}], 0.016)
		if frame % 5 == 0:
			print("Frame %d: barrel(%.2f, %.2f) state=%s vy=%.2f vs P2(%.2f, %.2f)" % [frame, sim.items[barrel_idx].x, sim.items[barrel_idx].y, sim.items[barrel_idx].state, sim.items[barrel_idx].vy, sim.fighters[1].x, sim.fighters[1].y])
		for ev in sim.events:
			if ev.type == "item_explode":
				exploded = true
				print("[OK] Explosion event captured at (%.2f, %.2f) with radius %.2f" % [ev.x, ev.y, ev.radius])
				break
		if exploded: break

	assert(exploded, "Explosive barrel must detonate on impact")
	assert(sim.fighters[1].hp < p2_hp_before, "P2 must take damage from barrel explosion")
	print("[OK] P2 took explosion damage: %.1f -> %.1f" % [p2_hp_before, sim.fighters[1].hp])
	assert(sim.items[barrel_idx].state == "destroyed", "Barrel should be destroyed after detonation")

	print("\n==================================================")
	print("ALL EXPLOSIVE BARREL TESTS PASSED!")
	print("==================================================")
	quit()

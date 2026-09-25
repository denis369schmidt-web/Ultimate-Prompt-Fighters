extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")

func _initialize():
	print("==================================================")
	print("TESTING SUPER SMASH BROS MECHANICS (PLATFORMS & LIVES)")
	print("==================================================")

	var p1 = Prompt.interpret("Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara", 0)
	var p2 = Prompt.interpret("Son Goku Super Saiyan Kamehameha Dragon Ball Z", 1)

	var sim = Combat.new()
	sim.start(p1, p2, "manual")
	sim.countdown = 0.0

	print("1. Initial state:")
	print("  P1 Lives: ", sim.fighters[0].lives, " | P2 Lives: ", sim.fighters[1].lives)
	assert(sim.fighters[0].lives == 3 and sim.fighters[1].lives == 3, "Both fighters should start with 3 lives")

	# Test 2: Platform Landing
	print("2. Testing Platform landing:")
	# Position P1 right above the left platform (x = -2.3, y = 2.0)
	sim.fighters[0].x = -2.3
	sim.fighters[0].y = 2.0
	sim.fighters[0].vy = -2.0
	sim.fighters[0].is_grounded = false

	for tick in range(30):
		sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false},
				  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false}], 0.016)

	print("  P1 landed on platform at y=%.2f, grounded=%s" % [sim.fighters[0].y, str(sim.fighters[0].is_grounded)])
	assert(sim.fighters[0].is_grounded and abs(sim.fighters[0].y - 1.35) < 0.1, "Fighter should land on left platform at y=1.35")

	# Test 3: Safe Blocking on Platform & Drop-Through Mechanic
	print("3. Testing Platform Blocking (Safe) & Drop-Through:")
	sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": true},
			  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false}], 0.016)
	print("  P1 blocking on platform: y=%.2f, grounded=%s" % [sim.fighters[0].y, str(sim.fighters[0].is_grounded)])
	assert(sim.fighters[0].is_grounded, "Fighter should stay safely on platform while blocking")

	# Now perform explicit drop command (S+W or cmd.drop)
	sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": true, "block": true},
			  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false}], 0.016)
	print("  P1 after S+W drop command: y=%.2f, grounded=%s" % [sim.fighters[0].y, str(sim.fighters[0].is_grounded)])
	assert(not sim.fighters[0].is_grounded, "Fighter should drop through platform on explicit S+W drop")

	# Let P1 land on main stage (y=0.0)
	for tick in range(60):
		sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false},
				  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false}], 0.016)
	print("  P1 landed on stage at y=%.2f, grounded=%s" % [sim.fighters[0].y, str(sim.fighters[0].is_grounded)])
	assert(sim.fighters[0].is_grounded and abs(sim.fighters[0].y) < 0.05, "Fighter should be grounded on main stage at y=0.0")

	# Test 4: Ring Out and Lives deduction
	print("4. Testing Ring Out off stage edge:")
	# Throw P2 off the edge (x = 6.0, outside stage bounds)
	sim.fighters[1].x = 6.0
	sim.fighters[1].y = 0.0
	sim.fighters[1].is_grounded = false

	var ring_out_detected := false
	for tick in range(120): # 2 seconds of falling into abyss
		sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false},
				  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false}], 0.016)
		for ev in sim.events:
			if ev.type == "ring_out":
				ring_out_detected = true
				print("  Ring Out Event triggered! Actor: ", ev.actor, " Lives left: ", ev.lives)

	assert(ring_out_detected, "Ring Out event should have fired")
	print("  P2 Lives after Ring Out: ", sim.fighters[1].lives)
	assert(sim.fighters[1].lives == 2, "P2 should now have 2 lives")
	print("  P2 respawned at y=%.2f, HP=%.1f" % [sim.fighters[1].y, sim.fighters[1].hp])
	assert(sim.fighters[1].y > 1.0, "P2 should have respawned above stage")

	print("==================================================")
	print("ALL SMASH BROS MECHANICS (PLATFORMS & 3 LIVES) PASSED!")
	print("==================================================")
	quit(0)

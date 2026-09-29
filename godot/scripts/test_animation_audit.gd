extends SceneTree
const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")

func _init() -> void:
	print("\n" + "=".repeat(60))
	print("ANIMATION & STATE MACHINE AUDIT")
	print("=".repeat(60))

	var presets := [
		["ninja", "Blitzschneller Schattenninja mit elektrischen Klingen"],
		["golem", "Gepanzerter Lavagolem mit brennenden Fäusten"],
		["valkyrie", "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier"],
		["dragon", "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert"],
		["goku", "Son Goku Super Saiyan Kamehameha Dragon Ball Z"],
		["vegeta", "Prinz Vegeta Saiyajin Royal Armor Final Flash Galick Gun"],
		["subzero", "Sub-Zero Lin Kuei Cryomancer ice ninja kori blade"],
		["pain", "Pain Nagato Akatsuki Rinnegan Shinra Tensei"],
		["luffy", "Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara"],
		["zoro", "Roronoa Zoro Santoryu Drei Schwerter Wado Ichimonji Onigiri"],
		["naruto", "Naruto Uzumaki Rasengan Konoha Stirnband Kyuubi Sage Mode"],
		["sasuke", "Sasuke Uchiha Chidori Sharingan Kusanagi Shimenawa Blitz"],
		["saitama", "Saitama One Punch Man Serious Punch Caped Baldy Hero"],
		["tanjiro", "Tanjiro Kamado Hinokami Kagura Nichirin Hanafuda Checkered Haori"],
		["sonic", "Sonic the Hedgehog Blue Blur Super Spin Dash Sega"],
		["akaza", "Akaza Upper Rank 3 Hakai Satsu Compass Needle Kimetsu"],
		["blue_eyes", "Weißer Drache mit eiskaltem Blick Burst Stream Yu-Gi-Oh"],
		["anubis", "Jackal God Anubis wielding dual Khopesh"],
		["specter", "Void Specter crystal phantom warrior with void lance"],
		["phoenix", "Phoenix Empress with feather armor and phoenix glaive"],
		["frieza", "Frieza Final Form Emperor Death Beam Supernova Dragon Ball Z"],
		["charizard", "Glurak Flammen-Drache Drachenschwingen Feuersturm Pokemon"]
	]

	var all_pass := true
	var results := []

	for preset in presets:
		var family: String = preset[0]
		var prompt_text: String = preset[1]
		var p1 := Prompt.interpret(prompt_text, 0)
		var p2 := Prompt.interpret("Gepanzerter Lavagolem mit brennenden Fäusten", 1)
		var sim := Combat.new()

		var ready_to_attack := false
		var attack_to_ready := false
		var hitstun_to_ready := false
		var block_to_ready := false
		var no_stuck := true
		var idle_cmd := {"move": 0, "standard": false, "special": false, "jump": false, "block": false, "grab": false}
		var attack_cmd := {"move": 0, "standard": true, "special": false, "jump": false, "block": false, "grab": false}
		var block_cmd := {"move": 0, "standard": false, "special": false, "jump": false, "block": true, "grab": false}

		# TEST 1: Ready → Attack → Ready (via 3-phase pipeline)
		sim.start(p1, p2, "manual")
		sim.countdown = 0.0  # Skip countdown for testing
		assert(sim.fighters[0].state == "Ready", "Initial state should be Ready")
		# Force an attack
		sim.tick([attack_cmd, idle_cmd])
		if sim.fighters[0].state == "Attack":
			ready_to_attack = true
		# Tick until attack finishes (max 120 ticks = 2 seconds)
		for t in range(120):
			sim.tick([idle_cmd, idle_cmd])
			if sim.fighters[0].state == "Ready" and ready_to_attack:
				attack_to_ready = true
				break

		# TEST 2: HitStun → Ready (simulate getting hit)
		sim.start(p1, p2, "manual")
		sim.countdown = 0.0
		# Move fighters close together
		sim.fighters[0].x = 0.0
		sim.fighters[1].x = 1.0
		# P2 attacks P1
		sim.tick([idle_cmd,
				  {"move": 0, "standard": true, "special": false, "jump": false, "block": false, "grab": false}])
		# Tick for hit to connect
		for t in range(30):
			sim.tick([idle_cmd, idle_cmd])
			if sim.fighters[0].state == "HitStun":
				# Now wait for recovery
				for t2 in range(120):
					sim.tick([idle_cmd, idle_cmd])
					if sim.fighters[0].state == "Ready":
						hitstun_to_ready = true
						break
				break

		# TEST 3: Block → Ready
		sim.start(p1, p2, "manual")
		sim.countdown = 0.0
		sim.tick([block_cmd, idle_cmd])
		var was_blocking: bool = sim.fighters[0].blocking
		sim.tick([idle_cmd, idle_cmd])
		if was_blocking and sim.fighters[0].state == "Ready":
			block_to_ready = true

		# TEST 4: No stuck states after 200 autonomous ticks
		sim.start(p1, p2, "autonomous")
		sim.countdown = 0.0
		for t in range(200):
			var cmds := sim.agent_commands()
			sim.tick(cmds)
		if sim.fighters[0].state in ["Ready", "Attack", "HitStun", "Carrying", "Defeated"]:
			no_stuck = true
		else:
			no_stuck = false

		var row_pass := ready_to_attack and attack_to_ready and hitstun_to_ready and block_to_ready and no_stuck
		if not row_pass: all_pass = false
		results.append({
			"family": family,
			"r2a": ready_to_attack, "a2r": attack_to_ready,
			"h2r": hitstun_to_ready, "b2r": block_to_ready,
			"stuck": no_stuck, "pass": row_pass
		})

	# Print Matrix
	print("\n%-12s | Ready→Atk | Atk→Ready | Hit→Ready | Blk→Ready | No Stuck | STATUS" % "CHARAKTER")
	print("-".repeat(88))
	for r in results:
		print("%-12s |     %s     |     %s     |     %s     |     %s     |    %s    |  %s" % [
			r.family.to_upper(),
			"✓" if r.r2a else "✗",
			"✓" if r.a2r else "✗",
			"✓" if r.h2r else "✗",
			"✓" if r.b2r else "✗",
			"✓" if r.stuck else "✗",
			"PASS" if r.pass else "FAIL"
		])

	print("-".repeat(88))
	if all_pass:
		print("✓ ALLE %d CHARAKTERE BESTEHEN DEN ANIMATION AUDIT" % results.size())
	else:
		var failed := results.filter(func(r): return not r.pass)
		print("✗ %d/%d CHARAKTERE FEHLGESCHLAGEN" % [failed.size(), results.size()])

	print("=".repeat(60))
	quit(0 if all_pass else 1)

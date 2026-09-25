extends SceneTree
const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")

func _init() -> void:
	print("\n" + "=".repeat(60))
	print("PERFORMANCE BASELINE — TICK-PROFILING")
	print("=".repeat(60))

	var families := [
		["ninja", "Blitzschneller Schattenninja mit elektrischen Klingen"],
		["golem", "Gepanzerter Lavagolem mit brennenden Fäusten"],
		["goku", "Son Goku Super Saiyan Kamehameha Dragon Ball Z"],
		["subzero", "Sub-Zero Lin Kuei Cryomancer ice ninja kori blade"],
		["pain", "Pain Nagato Akatsuki Rinnegan Shinra Tensei"],
		["luffy", "Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara"],
		["sonic", "Sonic the Hedgehog Blue Blur Super Spin Dash Sega"],
		["akaza", "Akaza Upper Rank 3 Hakai Satsu Compass Needle Kimetsu"],
		["blue_eyes", "Weißer Drache mit eiskaltem Blick Burst Stream Yu-Gi-Oh"],
		["valkyrie", "Strahlende Moe Valkyrie Paladin Kriegerin"],
		["dragon", "Mächtiger Cyber Drachenritter mit Drachen-Großschwert"],
		["anubis", "Jackal God Anubis wielding dual Khopesh"],
		["specter", "Void Specter crystal phantom warrior with void lance"],
		["phoenix", "Phoenix Empress with feather armor and phoenix glaive"]
	]

	var total_ticks := 0
	var total_time_us := 0.0
	var max_tick_us := 0.0
	var pair_count := 0
	var ticks_per_pair := 300

	# Test representative pairs (first vs each other)
	var test_pairs := []
	for i in range(families.size()):
		for j in range(i + 1, mini(i + 3, families.size())):
			test_pairs.append([i, j])
	# Also test mirror matches for first 5
	for i in range(mini(5, families.size())):
		test_pairs.append([i, i])

	for pair in test_pairs:
		var fi: int = pair[0]
		var fj: int = pair[1]
		var p1 := Prompt.interpret(families[fi][1], 0)
		var p2 := Prompt.interpret(families[fj][1], 1)
		var sim := Combat.new()
		sim.start(p1, p2, "autonomous")

		# Warm up
		var warm_cmds := sim.agent_commands()
		sim.tick(warm_cmds)

		var pair_total_us := 0.0
		var pair_max_us := 0.0
		for t in range(ticks_per_pair):
			var cmds := sim.agent_commands()
			var start := Time.get_ticks_usec()
			sim.tick(cmds)
			var elapsed := Time.get_ticks_usec() - start
			pair_total_us += elapsed
			pair_max_us = maxf(pair_max_us, elapsed)
			total_ticks += 1

		var pair_avg := pair_total_us / ticks_per_pair
		total_time_us += pair_total_us
		max_tick_us = maxf(max_tick_us, pair_max_us)
		pair_count += 1

	var avg_tick_us := total_time_us / total_ticks if total_ticks > 0 else 0.0

	print("\n── ERGEBNISSE ──────────────────────────────────────────────")
	print("  Getestete Paare:    %d" % pair_count)
	print("  Gesamte Ticks:      %d" % total_ticks)
	print("  Avg Tick:           %.1f µs" % avg_tick_us)
	print("  Max Tick:           %.1f µs" % max_tick_us)
	print("  Budget pro Tick:    16667 µs (60 FPS)")
	print("  Budget-Auslastung:  %.2f%%" % (avg_tick_us / 16667.0 * 100.0))

	if avg_tick_us > 500:
		print("\n  ⚠ WARNUNG: Durchschnittliche Tick-Zeit > 500µs!")
	elif avg_tick_us > 200:
		print("\n  ℹ HINWEIS: Tick-Zeit moderat (>200µs)")
	else:
		print("\n  ✓ PERFORMANCE EXCELLENT (<200µs avg)")

	if max_tick_us > 2000:
		print("  ⚠ WARNUNG: Maximale Tick-Zeit > 2000µs (Spike!)")
	else:
		print("  ✓ Keine kritischen Spikes")

	print("=".repeat(60))
	print("PERFORMANCE BASELINE COMPLETE")
	print("=".repeat(60))
	quit()

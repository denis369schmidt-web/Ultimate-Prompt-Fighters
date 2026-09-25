extends SceneTree

const Remixer = preload("res://scripts/character_remixer.gd")
const Combat = preload("res://scripts/combat.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	print("==================================================")
	print("TESTING CHARACTER REMIXER PIPELINE")
	print("==================================================")

	var test_cases = [
		{"prompt": "Schneller frostiger Schattenkämpfer mit Kristallklingen und Maske", "slot": 0},
		{"prompt": "Gepanzerter Magmakoloss mit brennenden Fäusten und Erdbeben", "slot": 1},
		{"prompt": "Legendärer Weißer Drache mit eiskaltem Blick Burst Stream Laser", "slot": 0},
		{"prompt": "Akaza Upper Rank 3 Dämon mit Zerstörungs-Kompassnadel", "slot": 1},
		{"prompt": "Son Goku Super Saiyajin mit göttlichem Kamehameha", "slot": 0}
	]

	var all_ok := true
	for tc in test_cases:
		var char_def: Dictionary = Remixer.remix_character(tc.prompt, tc.slot)
		var val: Dictionary = Remixer.validate(char_def)
		print("[REMIX] '%s' -> Name: '%s', Family: %s, Element: %s, Valid: %s" % [
			tc.prompt.left(30), char_def.name, char_def.family, char_def.element, str(val.valid)
		])
		if not val.valid:
			print("  ERRORS: ", val.errors)
			all_ok = false
			continue

		# Verify simulation works with remixed characters
		var sim = Combat.new()
		var p2 = Remixer.remix_character("Ninja Cyber", 1)
		sim.start(char_def, p2, "manual")
		sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false},
				  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false}], 0.016)

		# Verify FighterView works with remixed character
		var sc = Node3D.new()
		root.add_child(sc)
		var view = FighterView.new()
		sc.add_child(view)
		view.setup(char_def)
		view.update_state({"x": 0.0, "y": 0.0, "facing": 1.0, "pose": "Idle", "blocking": false}, 0.016)
		sc.queue_free()
		print("  -> SIMULATION & VIEW SETUP OK")

	print("==================================================")
	if all_ok:
		print("ALL CHARACTER REMIXER TESTS PASSED!")
	else:
		print("CHARACTER REMIXER TESTS FAILED!")
	print("==================================================")
	quit(0 if all_ok else 1)

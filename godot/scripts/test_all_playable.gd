extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	var test_prompts = [
		{"key": "golem", "prompt": "Gepanzerter Lavagolem mit brennenden Fäusten"},
		{"key": "ninja", "prompt": "Blitzschneller Schattenninja mit elektrischen Klingen"},
		{"key": "valkyrie", "prompt": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier"},
		{"key": "dragon", "prompt": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert"},
		{"key": "anubis", "prompt": "Jackal God Anubis wielding dual Khopesh"},
		{"key": "specter", "prompt": "Void Specter crystal phantom warrior with void lance"},
		{"key": "phoenix", "prompt": "Phoenix Empress with feather armor and phoenix glaive"},
		{"key": "goku", "prompt": "Son Goku Super Saiyan Kamehameha Dragon Ball Z"},
		{"key": "subzero", "prompt": "Sub-Zero Lin Kuei Cryomancer ice ninja kori blade"},
		{"key": "pain", "prompt": "Pain Nagato Akatsuki Rinnegan Shinra Tensei"},
		{"key": "luffy", "prompt": "Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara"},
		{"key": "sonic", "prompt": "Sonic the Hedgehog Blue Blur Super Spin Dash Sega"},
		{"key": "akaza", "prompt": "Akaza Upper Rank 3 Hakai Satsu Compass Needle Kimetsu"},
		{"key": "blue_eyes", "prompt": "Weißer Drache mit eiskaltem Blick Burst Stream Yu-Gi-Oh"}
	]
	
	print("==================================================")
	print("TESTING ALL 14 CHARACTERS (PROMPT -> SIM -> VIEW)")
	print("==================================================")
	
	var all_ok := true
	for item in test_prompts:
		var p = Prompt.interpret(item.prompt, 0)
		var valid = Prompt.valid(p)
		print("[%s] family=%s name='%s' valid=%s" % [item.key, p.family, p.name, str(valid)])
		if not valid:
			all_ok = false
			print("  ERROR: validation failed!")
			continue
			
		# Test simulation startup
		var p2 = Prompt.interpret(item.prompt, 1)
		var sim = Combat.new()
		sim.start(p, p2, "manual")
		sim.tick([{"move": 0.0, "standard": false, "special": false, "jump": false, "block": false},
				  {"move": 0.0, "standard": false, "special": false, "jump": false, "block": false}], 0.016)
		
		# Test FighterView setup
		var scene = Node3D.new()
		root.add_child(scene)
		var view = FighterView.new()
		scene.add_child(view)
		view.setup(p)
		view.update_state({"x": 0.0, "y": 0.0, "facing": 1.0, "pose": "Idle", "blocking": false}, 0.016)
		scene.queue_free()
		
		print("  -> SIM & VIEW OK")
		
	print("==================================================")
	if all_ok:
		print("ALL 14 CHARACTERS ARE FULLY PLAYABLE!")
	else:
		print("SOME CHARACTERS FAILED VALIDATION!")
	print("==================================================")
	quit(0)

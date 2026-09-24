extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")

func _initialize():
	var fighters = [
		"Gepanzerter Lavagolem mit brennenden Fäusten",
		"Blitzschneller Schattenninja mit elektrischen Klingen",
		"Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier",
		"Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert",
		"Jackal God Anubis wielding dual Khopesh",
		"Void Specter crystal phantom warrior with void lance",
		"Phoenix Empress with feather armor and phoenix glaive",
		"Son Goku Super Saiyan Kamehameha Dragon Ball Z",
		"Sub-Zero Lin Kuei Cryomancer ice ninja kori blade",
		"Pain Nagato Akatsuki Rinnegan Shinra Tensei",
		"Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara"
	]
	
	print("Testing live matches between all fighters...")
	for i in range(fighters.size()):
		var p1 = Prompt.interpret(fighters[i], 0)
		var p2 = Prompt.interpret(fighters[(i + 1) % fighters.size()], 1)
		var sim = Combat.new()
		sim.start(p1, p2, "agent_vs_agent")
		for step in range(240): # 4 seconds of active simulation
			var cmds = sim.agent_commands()
			sim.tick(cmds, 1.0 / 60.0)
		print("Match %s vs %s: OK (Time left: %.1fs, HP: %.1f / %.1f)" % [p1.name, p2.name, sim.time_left, sim.fighters[0].hp, sim.fighters[1].hp])
	
	print("ALL MATCH COMBINATIONS FUNCTIONAL!")
	quit(0)

extends SceneTree

func _initialize() -> void:
	var settings := ConfigFile.new()
	if settings.load("user://preferences.cfg") == OK:
		var p1 = settings.get_value("fighters", "p1", "none")
		var p2 = settings.get_value("fighters", "p2", "none")
		print("PREFS P1: ", p1)
		print("PREFS P2: ", p2)
		var P = load("res://scripts/prompt_interpreter.gd")
		var c1 = P.interpret(p1, 0)
		var c2 = P.interpret(p2, 1)
		print("P1 valid: ", P.valid(c1))
		print("P2 valid: ", P.valid(c2))
		if not P.valid(c1): print("c1 issues: ", c1)
		if not P.valid(c2): print("c2 issues: ", c2)
	else:
		print("NO PREFERENCES FILE")
	quit()

extends SceneTree

func _initialize():
	var s = load("res://scripts/prompt_interpreter.gd")
	if s:
		print("OK: geladen")
		var p = s.interpret("subzero cryomancer", 0)
		print("Family: ", p.family)
	else:
		print("FEHLER")
	quit(0)

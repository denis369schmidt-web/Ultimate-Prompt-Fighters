extends SceneTree

func _initialize() -> void:
	check_model("res://assets/models/mixamo/vanguard_soldier.glb", "Vanguard Soldier")
	check_model("res://assets/models/mixamo/samurai_dreyar.glb", "Samurai Dreyar")
	check_model("res://assets/models/mixamo/vampire_lord.glb", "Vampire Lord")
	check_model("res://assets/models/mixamo/mutant_titan.glb", "Mutant Titan")
	quit(0)

func check_model(path: String, title: String) -> void:
	print("\n=== ", title, " (", path, ") ===")
	var scene = load(path)
	if not scene:
		print("FAILED TO LOAD ", path)
		return
	var inst = scene.instantiate()
	var anims = inst.find_children("*", "AnimationPlayer", true, false)
	for a in anims:
		print("AnimationPlayer found: ", a.name, " with clips: ", a.get_animation_list())
	var skels = inst.find_children("*", "Skeleton3D", true, false)
	for s in skels:
		print("Skeleton3D found: ", s.name, " bone count: ", s.get_bone_count())
		var bones = []
		for b in range(s.get_bone_count()):
			bones.append(s.get_bone_name(b))
		print("Bones: ", ", ".join(bones.slice(0, mini(30, bones.size()))))

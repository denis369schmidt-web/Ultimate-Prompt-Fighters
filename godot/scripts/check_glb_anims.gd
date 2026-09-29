extends SceneTree

func _init() -> void:
	print("--- SCANNE MODELLE & SKELETTE ---")
	var paths := [
		"res://assets/models/mixamo/ninja_master.glb",
		"res://assets/models/mixamo/paladin_armed.glb",
		"res://assets/models/mixamo/samurai_dreyar.glb",
		"res://assets/models/mixamo/vanguard_soldier.glb",
		"res://assets/models/mixamo/warrok_brute.glb",
		"res://assets/models/mixamo/vampire_lord.glb",
		"res://assets/models/subzero.glb",
		"res://assets/models/pain.glb",
		"res://assets/models/goku.glb"
	]
	for p in paths:
		if not ResourceLoader.exists(p):
			print("FEHLT: ", p)
			continue
		var inst: Node = load(p).instantiate()
		var skels = inst.find_children("*", "Skeleton3D", true, false)
		var anims = inst.find_children("*", "AnimationPlayer", true, false)
		var anim_list := []
		if anims.size() > 0:
			anim_list = anims[0].get_animation_list()
		var bone_count := 0
		var sample_bones := []
		if skels.size() > 0:
			bone_count = skels[0].get_bone_count()
			for b in range(mini(bone_count, 6)):
				sample_bones.append(skels[0].get_bone_name(b))
		print("MODEL: ", p.get_file(), " | Skel: ", (skels.size() > 0), " (", bone_count, " bones: ", sample_bones, ") | Anims: ", anim_list)
		inst.queue_free()
	quit(0)

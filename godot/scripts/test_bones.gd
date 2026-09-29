extends SceneTree

func _initialize() -> void:
	var s = load("res://assets/models/mixamo/steel_knight.glb").instantiate()
	var skels = s.find_children("*", "Skeleton3D", true, false)
	if skels.size() > 0:
		var skel: Skeleton3D = skels[0]
		print("Bone count: ", skel.get_bone_count())
		for i in range(mini(20, skel.get_bone_count())):
			print("Bone ", i, ": ", skel.get_bone_name(i))
	else:
		print("NO SKELETON FOUND")
	quit()

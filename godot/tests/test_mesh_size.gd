extends SceneTree

func _initialize():
	var models = [
		"subzero", "goku", "golden_golem", "tripo_dragon_blue",
		"tripo_cat_girl", "tripo_fran_statue", "tripo_nyx_harvester",
		"tripo_white_sci", "tripo_skeleton_dog", "tripo_wooden_forest",
		"tripo_nine_tailed", "tripo_quadruped_tree"
	]
	for m in models:
		var scn = load("res://assets/models/%s.glb" % m)
		if scn:
			var inst = scn.instantiate()
			var aabb = AABB()
			for mesh in inst.find_children("*", "MeshInstance3D", true, false):
				aabb = aabb.merge(mesh.get_aabb())
			print("%s -> AABB size: %s (height: %.2f)" % [m, aabb.size, aabb.size.y])
	quit()

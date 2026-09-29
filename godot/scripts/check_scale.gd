extends SceneTree

func _init() -> void:
	var f_out = FileAccess.open("res://model_scales.txt", FileAccess.WRITE)
	var dir = DirAccess.open("res://assets/models/mixamo")
	if dir:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while not fname.is_empty():
			if fname.ends_with(".glb"):
				var node = load("res://assets/models/mixamo/" + fname).instantiate()
				var max_y = 0.0
				for m in node.find_children("*", "MeshInstance3D"):
					if m.mesh:
						max_y = maxf(max_y, m.mesh.get_aabb().size.y)
				f_out.store_line(fname + ": " + str(snappedf(max_y, 0.01)))
			fname = dir.get_next()
	f_out.close()
	quit()

extends SceneTree

func _initialize() -> void:
	var dir = DirAccess.open("res://assets/models/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".glb"):
				var p = "res://assets/models/".path_join(file_name)
				var s = load(p).instantiate()
				var anims = s.find_children("*", "AnimationPlayer", true, false)
				if anims.size() > 0:
					print(file_name, " HAS ANIM: ", anims[0].get_animation_list())
				s.queue_free()
			file_name = dir.get_next()
	quit()

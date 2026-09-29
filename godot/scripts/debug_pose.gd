extends SceneTree

func _init() -> void:
	var interp = load("res://scripts/prompt_interpreter.gd").new()
	var fview_script = load("res://scripts/fighter_view.gd")
	var prof = interp.interpret("Erzmagier Pyrus Feuerzauberer mit Meteorschlag und Flammenstab", 0)

	var view = Node3D.new()
	view.set_script(fview_script)
	root.add_child(view)
	view.setup(prof)

	print("MODEL ROTATION BEFORE: ", view.model.rotation_degrees)
	print("SKELETON BONE COUNT: ", view.skeleton.get_bone_count() if view.skeleton else 0)
	if view.skeleton:
		for b_key in view.bone_map:
			var b_idx = view.bone_map[b_key]
			print("REST POSE ", b_key, " (", view.skeleton.get_bone_name(b_idx), "): ", view.skeleton.get_bone_rest(b_idx).basis.get_euler())

	view.update_state({"x": -1.6, "y": 0.0, "facing": 1.0, "pose": "Idle", "blocking": false}, 0.1)
	print("MODEL ROTATION AFTER: ", view.model.rotation_degrees)
	if view.skeleton:
		for b_key in view.bone_map:
			var b_idx = view.bone_map[b_key]
			print("POSE ROT ", b_key, ": ", view.skeleton.get_bone_pose_rotation(b_idx).get_euler())
	quit()

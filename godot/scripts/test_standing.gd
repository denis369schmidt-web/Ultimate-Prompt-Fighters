extends SceneTree

func _init() -> void:
	var interp = load("res://scripts/prompt_interpreter.gd").new()
	var fview_script = load("res://scripts/fighter_view.gd")
	var prof = interp.interpret("Erzmagier Pyrus Feuerzauberer mit Meteorschlag und Flammenstab", 0)

	var view = Node3D.new()
	view.set_script(fview_script)
	root.add_child(view)
	view.setup(prof)

	# Before fix: Hips was forced to Quaternion.IDENTITY
	# After fix: Hips must keep its rest pose rotation!
	var hips_idx = view.bone_map.get("hips", -1)
	if hips_idx != -1:
		print("Rest Hips Quat: ", view.skeleton.get_bone_rest(hips_idx).basis.get_rotation_quaternion())

	view.update_state({"x": 0.0, "y": 0.0, "facing": 1.0, "pose": "Idle", "blocking": false}, 0.1)

	# Cam & Light
	var cam = Camera3D.new()
	cam.position = Vector3(0, 1.2, 2.5)
	cam.look_at(Vector3(0, 1.0, 0))
	root.add_child(cam)

	var light = DirectionalLight3D.new()
	root.add_child(light)

	quit()

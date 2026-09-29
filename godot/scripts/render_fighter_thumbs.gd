extends SceneTree

const FIGHTERS = [
	{"id": "mutant_titan", "path": "res://assets/models/mixamo/mutant_titan.glb", "cam_y": 1.7, "cam_z": 1.4},
	{"id": "vanguard_soldier", "path": "res://assets/models/mixamo/vanguard_soldier.glb", "cam_y": 1.6, "cam_z": 1.1},
	{"id": "samurai_dreyar", "path": "res://assets/models/mixamo/samurai_dreyar.glb", "cam_y": 1.55, "cam_z": 1.1},
	{"id": "vampire_lord", "path": "res://assets/models/mixamo/vampire_lord.glb", "cam_y": 1.65, "cam_z": 1.2},
	{"id": "steel_knight", "path": "res://assets/models/mixamo/steel_knight.glb", "cam_y": 1.55, "cam_z": 1.1},
	{"id": "sorceress_medea", "path": "res://assets/models/mixamo/sorceress_medea.glb", "cam_y": 1.45, "cam_z": 1.0},
	{"id": "skeleton_reaper", "path": "res://assets/models/mixamo/skeleton_reaper.glb", "cam_y": 1.60, "cam_z": 1.1},
	{"id": "swat_specops", "path": "res://assets/models/mixamo/swat_specops.glb", "cam_y": 1.55, "cam_z": 1.1},
	{"id": "pirate_captain", "path": "res://assets/models/mixamo/pirate_captain.glb", "cam_y": 1.55, "cam_z": 1.1},
	{"id": "wizard_sorcerer", "path": "res://assets/models/mixamo/wizard_sorcerer.glb", "cam_y": 1.55, "cam_z": 1.1},
	{"id": "warrok_brute", "path": "res://assets/models/mixamo/warrok_brute.glb", "cam_y": 1.65, "cam_z": 1.3},
	{"id": "martial_yaku", "path": "res://assets/models/mixamo/martial_yaku.glb", "cam_y": 1.55, "cam_z": 1.1},
	{"id": "monk_ganfaul", "path": "res://assets/models/mixamo/monk_ganfaul.glb", "cam_y": 1.55, "cam_z": 1.1},
]

func _initialize() -> void:
	render_all()

func render_all() -> void:
	var root_3d := Node3D.new()
	root.add_child(root_3d)

	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("0d111a")
	root_3d.add_child(env)

	var light := DirectionalLight3D.new()
	light.position = Vector3(1.2, 2.5, 2.0)
	light.light_energy = 2.2
	root_3d.add_child(light)

	var fill := DirectionalLight3D.new()
	fill.position = Vector3(-1.2, 1.5, 2.0)
	fill.light_color = Color("60a5fa")
	fill.light_energy = 1.0
	root_3d.add_child(fill)

	var cam := Camera3D.new()
	cam.fov = 40
	root_3d.add_child(cam)

	for item in FIGHTERS:
		if not ResourceLoader.exists(item.path):
			continue
		var model: Node3D = load(item.path).instantiate()
		root_3d.add_child(model)

		# Scale model to 1.8m standard height
		var max_h: float = 0.0
		for m in model.find_children("*", "MeshInstance3D", true, false):
			if m.mesh:
				var aabb = m.mesh.get_aabb()
				if aabb.size.y > max_h:
					max_h = aabb.size.y
		if max_h > 0.05:
			model.scale = Vector3.ONE * (1.80 / max_h)
		else:
			model.scale = Vector3.ONE

		# Lower arms slightly if skeleton exists
		var skels = model.find_children("*", "Skeleton3D", true, false)
		if skels.size() > 0:
			var skel: Skeleton3D = skels[0]
			for bn in ["mixamorig_LeftArm", "LeftArm"]:
				var idx = skel.find_bone(bn)
				if idx != -1:
					skel.set_bone_pose_rotation(idx, skel.get_bone_rest(idx).basis.get_rotation_quaternion() * Quaternion(Vector3(0, 0, 1), deg_to_rad(-65.0)))
			for bn in ["mixamorig_RightArm", "RightArm"]:
				var idx = skel.find_bone(bn)
				if idx != -1:
					skel.set_bone_pose_rotation(idx, skel.get_bone_rest(idx).basis.get_rotation_quaternion() * Quaternion(Vector3(0, 0, 1), deg_to_rad(65.0)))

		# Aim camera at chest/head
		cam.look_at_from_position(Vector3(0.0, item.cam_y, item.cam_z), Vector3(0.0, item.cam_y - 0.1, 0.0))

		for f in range(6):
			await process_frame

		var img = root.get_viewport().get_texture().get_image()
		if img:
			# Crop center square and resize to 128x128
			var w = img.get_width()
			var h = img.get_height()
			var side = mini(w, h)
			var crop_rect = Rect2i((w - side) / 2, (h - side) / 2, side, side)
			var cropped = img.get_region(crop_rect)
			cropped.resize(128, 128, Image.INTERPOLATE_LANCZOS)
			var out_path = "res://assets/textures/characters/thumbs/thumb_%s.png" % item.id
			cropped.save_png(out_path)
			print("SAVED HEADSHOT PORTRAIT: ", out_path)

		model.queue_free()
		for f in range(2):
			await process_frame

	quit(0)

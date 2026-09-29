extends SceneTree

func _initialize():
	render_check()

func render_check() -> void:
	var fview_script = load("res://scripts/fighter_view.gd")
	var interp = load("res://scripts/prompt_interpreter.gd").new()
	var prof = interp.interpret("Blitzschneller Schattenninja mit elektrischen Klingen", 0)

	var view = Node3D.new()
	view.set_script(fview_script)
	root.add_child(view)
	view.setup(prof)

	# Setup Camera & Light
	var cam = Camera3D.new()
	cam.position = Vector3(0, 1.1, 2.4)
	cam.look_at(Vector3(0, 1.0, 0))
	root.add_child(cam)

	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("1a202c")
	root.add_child(env)

	var light = DirectionalLight3D.new()
	light.position = Vector3(1, 2, 3)
	light.light_energy = 2.0
	root.add_child(light)

	for f in range(10): await process_frame

	var skel: Skeleton3D = view.skeleton
	var l_arm = view.bone_map["left_arm"]
	var r_arm = view.bone_map["right_arm"]
	var l_fa = view.bone_map["left_forearm"]
	var r_fa = view.bone_map["right_forearm"]

	# Test lowering arms from T-pose into natural guard
	var q_l_arm = Quaternion(Vector3(0, 0, 1), deg_to_rad(-68.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(20.0))
	var q_r_arm = Quaternion(Vector3(0, 0, 1), deg_to_rad(68.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(-20.0))
	var q_l_fa = Quaternion(Vector3(0, 0, 1), deg_to_rad(-35.0)) * Quaternion(Vector3(1, 0, 0), deg_to_rad(30.0))
	var q_r_fa = Quaternion(Vector3(0, 0, 1), deg_to_rad(35.0)) * Quaternion(Vector3(1, 0, 0), deg_to_rad(30.0))

	skel.set_bone_pose_rotation(l_arm, skel.get_bone_rest(l_arm).basis.get_rotation_quaternion() * q_l_arm)
	skel.set_bone_pose_rotation(r_arm, skel.get_bone_rest(r_arm).basis.get_rotation_quaternion() * q_r_arm)
	skel.set_bone_pose_rotation(l_fa, skel.get_bone_rest(l_fa).basis.get_rotation_quaternion() * q_l_fa)
	skel.set_bone_pose_rotation(r_fa, skel.get_bone_rest(r_fa).basis.get_rotation_quaternion() * q_r_fa)

	for f in range(10): await process_frame

	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://screenshot_test_arm_pose.png")
		print("SAVED: screenshot_test_arm_pose.png")
	quit(0)

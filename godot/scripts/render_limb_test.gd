extends SceneTree

func _initialize() -> void:
	var root_node = Node3D.new()
	root.add_child(root_node)

	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("202530")
	root_node.add_child(env)

	var light = DirectionalLight3D.new()
	light.position = Vector3(1, 3, 4)
	light.light_energy = 2.5
	root_node.add_child(light)

	var cam = Camera3D.new()
	cam.look_at_from_position(Vector3(0, 1.2, 2.8), Vector3(0, 1.1, 0))
	root_node.add_child(cam)

	var scene = load("res://assets/models/mixamo/vanguard_soldier.glb").instantiate()
	scene.scale = Vector3.ONE
	root_node.add_child(scene)

	var skel: Skeleton3D = scene.find_children("*", "Skeleton3D", true, false)[0]
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var r_arm = skel.find_bone("mixamorig_RightArm")

	var rest_l = skel.get_bone_rest(l_arm).basis.get_rotation_quaternion()
	var rest_r = skel.get_bone_rest(r_arm).basis.get_rotation_quaternion()

	# In Mixamo: Arm bone local coordinate system:
	# Let's test rotating around local Z vs local Y vs local X
	# Left arm:
	skel.set_bone_pose_rotation(l_arm, rest_l * Quaternion(Vector3(0, 0, 1), deg_to_rad(-65.0)))
	# Right arm:
	skel.set_bone_pose_rotation(r_arm, rest_r * Quaternion(Vector3(0, 0, 1), deg_to_rad(65.0)))

	for f in range(15):
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://screenshot_test_arm_direction.png")
		print("SAVED: screenshot_test_arm_direction.png")
	quit(0)

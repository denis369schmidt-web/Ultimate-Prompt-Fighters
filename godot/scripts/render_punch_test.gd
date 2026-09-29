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
	# Side/three-quarter view of the punch
	cam.look_at_from_position(Vector3(1.8, 1.3, 1.8), Vector3(0, 1.1, 0))
	root_node.add_child(cam)

	var scene = load("res://assets/models/mixamo/vanguard_soldier.glb").instantiate()
	scene.scale = Vector3.ONE
	root_node.add_child(scene)

	var skel: Skeleton3D = scene.find_children("*", "Skeleton3D", true, false)[0]
	var r_arm = skel.find_bone("mixamorig_RightArm")
	var r_fa = skel.find_bone("mixamorig_RightForeArm")
	var spine = skel.find_bone("mixamorig_Spine1")

	var rest_r = skel.get_bone_rest(r_arm).basis.get_rotation_quaternion()
	var rest_fa = skel.get_bone_rest(r_fa).basis.get_rotation_quaternion()
	var rest_sp = skel.get_bone_rest(spine).basis.get_rotation_quaternion()

	# Test Punch: Right arm swings forward horizontally:
	# In Mixamo rest, RightArm points in -X.
	# To swing it forward (+Z): rotate around Y axis by 80 degrees!
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var l_fa = skel.find_bone("mixamorig_LeftForeArm")
	var rest_l = skel.get_bone_rest(l_arm).basis.get_rotation_quaternion()
	var rest_l_fa = skel.get_bone_rest(l_fa).basis.get_rotation_quaternion()

	var q_punch_arm = Quaternion(Vector3(0, 1, 0), deg_to_rad(80.0)) * Quaternion(Vector3(0, 0, 1), deg_to_rad(25.0))
	var q_fa_punch = Quaternion(Vector3(0, 0, 1), deg_to_rad(35.0))
	var q_spine_twist = Quaternion(Vector3(0, 1, 0), deg_to_rad(-25.0))

	# Left arm guarded at side/chest
	var q_guard_l = Quaternion(Vector3(0, 0, 1), deg_to_rad(-65.0)) * Quaternion(Vector3(0, 1, 0), deg_to_rad(-30.0))
	var q_guard_l_fa = Quaternion(Vector3(0, 0, 1), deg_to_rad(-45.0))

	skel.set_bone_pose_rotation(r_arm, rest_r * q_punch_arm)
	skel.set_bone_pose_rotation(r_fa, rest_fa * q_fa_punch)
	skel.set_bone_pose_rotation(l_arm, rest_l * q_guard_l)
	skel.set_bone_pose_rotation(l_fa, rest_l_fa * q_guard_l_fa)
	skel.set_bone_pose_rotation(spine, rest_sp * q_spine_twist)

	for f in range(15):
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://screenshot_test_punch_pose.png")
		print("SAVED: screenshot_test_punch_pose.png")
	quit(0)

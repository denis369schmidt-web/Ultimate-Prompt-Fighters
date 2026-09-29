extends SceneTree

func _initialize() -> void:
	var scene = load("res://assets/models/mixamo/vanguard_soldier.glb").instantiate()
	root.add_child(scene)
	var skel: Skeleton3D = scene.find_children("*", "Skeleton3D", true, false)[0]
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var l_hand = skel.find_bone("mixamorig_LeftHand")
	var rest_q = skel.get_bone_rest(l_arm).basis.get_rotation_quaternion()

	skel.force_update_all_bone_transforms()
	print("REST Hand pos:  ", skel.get_bone_global_pose(l_hand).origin)

	for angle in [-45, -70, 45, 70]:
		var q_local = Quaternion(Vector3(0, 0, 1), deg_to_rad(angle))
		skel.set_bone_pose_rotation(l_arm, rest_q * q_local)
		skel.force_update_all_bone_transforms()
		print("Angle ", angle, " deg (rest * q_local): Hand pos: ", skel.get_bone_global_pose(l_hand).origin)

	for angle in [-45, -70, 45, 70]:
		var q_local = Quaternion(Vector3(0, 0, 1), deg_to_rad(angle))
		skel.set_bone_pose_rotation(l_arm, q_local * rest_q)
		skel.force_update_all_bone_transforms()
		print("Angle ", angle, " deg (q_local * rest): Hand pos: ", skel.get_bone_global_pose(l_hand).origin)

	quit(0)

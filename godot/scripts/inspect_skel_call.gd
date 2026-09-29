extends SceneTree

func _initialize() -> void:
	var scene = load("res://assets/models/mixamo/vanguard_soldier.glb").instantiate()
	root.add_child(scene)
	var skel: Skeleton3D = scene.find_children("*", "Skeleton3D", true, false)[0]
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	print("l_arm bone index: ", l_arm)
	print("Before: ", skel.get_bone_pose_rotation(l_arm))
	var q = Quaternion(Vector3(0, 0, 1), 1.0)
	skel.set_bone_pose_rotation(l_arm, q)
	print("After set_bone_pose_rotation: ", skel.get_bone_pose_rotation(l_arm))
	print("Parent of l_arm: ", skel.get_bone_parent(l_arm), " name: ", skel.get_bone_name(skel.get_bone_parent(l_arm)))
	print("get_bone_pose(l_arm): \n", skel.get_bone_pose(l_arm))
	quit(0)

extends SceneTree

func _initialize() -> void:
	var scene = load("res://assets/models/mixamo/vanguard_soldier.glb").instantiate()
	var skel: Skeleton3D = scene.find_children("*", "Skeleton3D", true, false)[0]
	var l_arm = skel.find_bone("mixamorig_LeftArm")

	print("REST transform basis: \n", skel.get_bone_rest(l_arm).basis)
	print("Initial POSE rotation: ", skel.get_bone_pose_rotation(l_arm))
	print("Initial POSE basis: \n", Basis(skel.get_bone_pose_rotation(l_arm)))

	# Now set pose rotation to IDENTITY
	skel.set_bone_pose_rotation(l_arm, Quaternion.IDENTITY)
	print("\nAfter set IDENTITY: ")
	print("POSE rotation: ", skel.get_bone_pose_rotation(l_arm))
	print("Bone pose transform: \n", skel.get_bone_pose(l_arm))

	# Now set pose rotation to rest_q
	var rest_q = skel.get_bone_rest(l_arm).basis.get_rotation_quaternion()
	skel.set_bone_pose_rotation(l_arm, rest_q)
	print("\nAfter set REST_Q: ")
	print("POSE rotation: ", skel.get_bone_pose_rotation(l_arm))
	print("Bone pose transform: \n", skel.get_bone_pose(l_arm))

	quit(0)

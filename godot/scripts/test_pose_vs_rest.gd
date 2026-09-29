extends SceneTree

func _initialize() -> void:
	var scene = load("res://assets/models/mixamo/vanguard_soldier.glb").instantiate()
	var skel: Skeleton3D = scene.find_children("*", "Skeleton3D", true, false)[0]
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	print("Initial pose rotation: ", skel.get_bone_pose_rotation(l_arm))
	print("Rest rotation: ", skel.get_bone_rest(l_arm).basis.get_rotation_quaternion())
	quit(0)

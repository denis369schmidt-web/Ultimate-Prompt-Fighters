extends SceneTree

func _init() -> void:
	var node = load("res://assets/models/mixamo/vanguard_soldier.glb").instantiate()
	var skel: Skeleton3D = node.find_children("*", "Skeleton3D")[0]
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var r_arm = skel.find_bone("mixamorig_RightArm")
	print("VANGUARD L_ARM: ", l_arm, " REST: ", skel.get_bone_rest(l_arm).basis)
	print("VANGUARD R_ARM: ", r_arm, " REST: ", skel.get_bone_rest(r_arm).basis)
	quit()

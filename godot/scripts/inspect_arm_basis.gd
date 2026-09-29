extends SceneTree

func _initialize() -> void:
	var scene = load("res://assets/models/mixamo/vanguard_soldier.glb").instantiate()
	var skel: Skeleton3D = scene.find_children("*", "Skeleton3D", true, false)[0]
	var l_arm = skel.find_bone("mixamorig_LeftArm")
	var r_arm = skel.find_bone("mixamorig_RightArm")
	var l_rest = skel.get_bone_rest(l_arm)
	var r_rest = skel.get_bone_rest(r_arm)
	print("L_ARM rest basis: \n  X: ", l_rest.basis.x, "\n  Y: ", l_rest.basis.y, "\n  Z: ", l_rest.basis.z)
	print("L_ARM rest rot euler deg: ", l_rest.basis.get_euler() * 180.0 / PI)
	print("R_ARM rest basis: \n  X: ", r_rest.basis.x, "\n  Y: ", r_rest.basis.y, "\n  Z: ", r_rest.basis.z)
	print("R_ARM rest rot euler deg: ", r_rest.basis.get_euler() * 180.0 / PI)
	quit(0)

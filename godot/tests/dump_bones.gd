extends SceneTree
## Dumps bone hierarchy + rest positions (model space) for representative rigs.

func _initialize() -> void:
	var paths := OS.get_cmdline_user_args()
	for p in paths:
		var inst: Node = load(p).instantiate()
		root.add_child(inst)
		var skels := inst.find_children("*", "Skeleton3D", true, false)
		if skels.is_empty():
			print("NOSKEL ", p)
			inst.free()
			continue
		var sk: Skeleton3D = skels[0]
		var xf: Transform3D = inst.global_transform.affine_inverse() * sk.global_transform
		print("=== ", p, " bones=", sk.get_bone_count(), " skel_xf_basis_scale=", xf.basis.get_scale(), " origin=", xf.origin)
		for b in range(sk.get_bone_count()):
			var g: Transform3D = xf * sk.get_bone_global_rest(b)
			print("  %d %s parent=%d pos=(%.2f, %.2f, %.2f)" % [b, sk.get_bone_name(b), sk.get_bone_parent(b), g.origin.x, g.origin.y, g.origin.z])
		var meshes := inst.find_children("*", "MeshInstance3D", true, false)
		var aabb := AABB()
		var first := true
		for m in meshes:
			var mx: Transform3D = inst.global_transform.affine_inverse() * m.global_transform
			var a: AABB = mx * m.get_aabb()
			aabb = a if first else aabb.merge(a)
			first = false
		print("  AABB ", aabb)
		inst.free()
	quit(0)

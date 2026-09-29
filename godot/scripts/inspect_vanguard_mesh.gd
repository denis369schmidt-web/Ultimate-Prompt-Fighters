extends SceneTree

func _initialize() -> void:
	var s = load("res://assets/models/mixamo/vanguard_soldier.glb").instantiate()
	for m in s.find_children("*", "MeshInstance3D", true, false):
		print("Mesh: ", m.name, " aabb: ", m.get_aabb(), " global_trans: ", m.global_transform.origin)
	quit(0)

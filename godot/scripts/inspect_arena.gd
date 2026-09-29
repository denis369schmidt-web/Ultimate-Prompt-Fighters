extends SceneTree

func _init() -> void:
	var s = load("res://assets/models/arena.glb").instantiate()
	var f = FileAccess.open("res://arena_nodes.txt", FileAccess.WRITE)
	for c in s.find_children("*"):
		if c is MeshInstance3D:
			f.store_line("MESH: " + c.name + " | pos: " + str(c.position))
	f.close()
	quit()

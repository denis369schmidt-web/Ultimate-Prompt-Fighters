extends SceneTree

func _initialize() -> void:
	var g = load("res://assets/models/goku.glb").instantiate()
	for c in g.find_children("*", "MeshInstance3D", true, false):
		print("GOKU MESH: ", c.name)
	quit()

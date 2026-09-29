extends SceneTree

func _initialize() -> void:
	var s = load("res://assets/models/mixamo/steel_knight.glb").instantiate()
	for m in s.find_children("*", "MeshInstance3D", true, false):
		print("Mesh: ", m.name, " surfaces: ", m.mesh.get_surface_count())
		for surf in range(m.mesh.get_surface_count()):
			var active_mat = m.get_active_material(surf)
			var surf_mat = m.mesh.surface_get_material(surf)
			var override_mat = m.get_surface_override_material(surf)
			print("  active: ", active_mat, " surf_mat: ", surf_mat, " override: ", override_mat)
			if surf_mat is StandardMaterial3D:
				print("  surf_mat tex: ", surf_mat.albedo_texture, " col: ", surf_mat.albedo_color)
	quit()

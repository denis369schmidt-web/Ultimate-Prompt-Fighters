extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	var sc = Node3D.new()
	root.add_child(sc)
	
	var cam = Camera3D.new()
	cam.position = Vector3(0, 1.2, 2.5)
	sc.add_child(cam)
	cam.look_at_from_position(cam.position, Vector3(0, 1.0, 0))
	cam.current = true
	
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	light.light_energy = 2.0
	sc.add_child(light)
	
	# Load raw model
	var prof = Prompt.interpret("subzero cryomancer", 0)
	var m = load("res://assets/models/subzero.glb").instantiate()
	m.scale = Vector3.ONE * 1.05
	sc.add_child(m)
	
	# Now apply the EXACT material logic from fighter_view.gd on mesh 0
	var meshes = m.find_children("*", "MeshInstance3D", true, false)
	print("Meshes count: ", meshes.size())
	for mesh in meshes:
		for surface in range(mesh.mesh.get_surface_count()):
			var original = mesh.get_active_material(surface)
			print("Mesh: ", mesh.name, " Orig Mat: ", original.get_class() if original else "null")
			if original is StandardMaterial3D:
				var mat: StandardMaterial3D = original.duplicate()
				mat.cull_mode = BaseMaterial3D.CULL_DISABLED
				mat.uv1_scale = Vector3(0.02, 0.02, 0.02)
				mat.uv1_triplanar = true
				mesh.set_surface_override_material(surface, mat)
				
	for f in range(10):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("res://test_override_check.png")
	print("TEST_OVERRIDE_CHECK_SAVED")
	quit(0)

extends SceneTree

func _initialize():
	var sc = Node3D.new()
	root.add_child(sc)
	
	var cam = Camera3D.new()
	cam.position = Vector3(0, 1.2, 2.5)
	sc.add_child(cam)
	cam.look_at_from_position(cam.position, Vector3(0, 1.0, 0))
	cam.current = true
	
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_CLEAR_COLOR
	sc.add_child(env)
	
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	light.light_energy = 2.0
	sc.add_child(light)
	
	# Test 1: Simple red box
	var box = MeshInstance3D.new()
	var bmesh = BoxMesh.new()
	bmesh.size = Vector3(0.5, 0.5, 0.5)
	box.mesh = bmesh
	box.position = Vector3(-0.6, 1.0, 0)
	var bmat = StandardMaterial3D.new()
	bmat.albedo_color = Color.RED
	box.material_override = bmat
	sc.add_child(box)
	
	# Test 2: Raw GLB model (Sub-Zero)
	var m = load("res://assets/models/subzero.glb").instantiate()
	m.position = Vector3(0.6, 0, 0)
	m.scale = Vector3.ONE * 1.0
	sc.add_child(m)
	
	print("Subzero meshes found in test: ", m.find_children("*", "MeshInstance3D", true, false).size())
	
	for f in range(20):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://test_simple_result.png")
		print("TEST_SIMPLE_RESULT_SAVED")
	
	quit(0)

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
	
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_CLEAR_COLOR
	sc.add_child(env)
	
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, -30, 0)
	light.light_energy = 2.0
	sc.add_child(light)
	
	var prof = Prompt.interpret("subzero cryomancer", 0)
	var v = FighterView.new()
	sc.add_child(v)
	v.setup(prof)
	v.position = Vector3(0, 0, 0)
	
	print("V scale: ", v.scale, " Model scale: ", v.model.scale if v.model else "NO_MODEL")
	
	for f in range(15):
		await process_frame
		
	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://test_fighter_view_direct.png")
		print("TEST_FIGHTER_VIEW_SAVED")
	
	quit(0)

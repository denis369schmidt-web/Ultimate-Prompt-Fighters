extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	render_lineup()

func render_lineup() -> void:
	var lineup = [
		{"prompt": "Gepanzerter Lavagolem mit brennenden Fäusten", "x": -5.2, "slot": 0, "facing": 0.45, "name": "Golem"},
		{"prompt": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert", "x": -4.15, "slot": 0, "facing": 0.35, "name": "Dragon"},
		{"prompt": "Sub-Zero Lin Kuei Cryomancer ice ninja kori blade", "x": -3.1, "slot": 0, "facing": 0.25, "name": "Sub-Zero"},
		{"prompt": "Son Goku Super Saiyan Kamehameha Dragon Ball Z", "x": -2.05, "slot": 0, "facing": 0.15, "name": "Goku"},
		{"prompt": "Void Specter crystal phantom warrior with void lance", "x": -1.0, "slot": 0, "facing": 0.08, "name": "Specter"},
		{"prompt": "Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara", "x": 0.0, "slot": 0, "facing": 0.0, "name": "Luffy"},
		{"prompt": "Pain Nagato Akatsuki Rinnegan Shinra Tensei", "x": 1.0, "slot": 1, "facing": -0.08, "name": "Pain"},
		{"prompt": "Phoenix Empress with feather armor and phoenix glaive", "x": 2.05, "slot": 1, "facing": -0.15, "name": "Phoenix"},
		{"prompt": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier", "x": 3.1, "slot": 1, "facing": -0.25, "name": "Valkyrie"},
		{"prompt": "Jackal God Anubis wielding dual Khopesh", "x": 4.15, "slot": 1, "facing": -0.35, "name": "Anubis"},
		{"prompt": "Blitzschneller Schattenninja mit elektrischen Klingen", "x": 5.2, "slot": 1, "facing": -0.45, "name": "Ninja"},
	]

	# --- 1. FULL 11-CHARACTER WIDE LINEUP ---
	var scene = Node3D.new()
	root.add_child(scene)

	var cam = Camera3D.new()
	cam.position = Vector3(0, 1.60, 8.6)
	cam.fov = 68
	scene.add_child(cam)
	cam.look_at_from_position(cam.position, Vector3(0, 1.10, 0))
	cam.current = true

	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_mat = PanoramaSkyMaterial.new()
	sky_mat.panorama = load("res://assets/textures/arenas/sky_blood_moon.png")
	sky.sky_material = sky_mat
	env.environment.sky = sky
	env.environment.sky_rotation = Vector3(0, deg_to_rad(90), 0)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("2a384c")
	env.environment.ambient_light_energy = 0.90
	env.environment.glow_enabled = true
	env.environment.glow_intensity = 0.65
	env.environment.glow_bloom = 0.20
	env.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	scene.add_child(env)

	# Arena Floor
	var floor_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(28, 28)
	floor_mesh.mesh = plane
	var f_mat = StandardMaterial3D.new()
	f_mat.albedo_texture = load("res://assets/textures/arenas/floor_stone_albedo.png")
	f_mat.normal_enabled = true
	f_mat.normal_texture = load("res://assets/textures/arenas/floor_stone_normal.png")
	f_mat.normal_scale = 1.4
	f_mat.uv1_scale = Vector3(5, 5, 5)
	f_mat.roughness = 0.85
	floor_mesh.material_override = f_mat
	scene.add_child(floor_mesh)

	# Direct Sun Key Light
	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35, -20, 0)
	light.light_color = Color("fff5eb")
	light.light_energy = 1.7
	light.shadow_enabled = true
	scene.add_child(light)

	# Soft Fill Light
	var fill = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(20, -145, 0)
	fill.light_color = Color("85a5cc")
	fill.light_energy = 0.85
	scene.add_child(fill)

	# Instantiate all 8 fighters
	var views = []
	for item in lineup:
		var p = Prompt.interpret(item.prompt, item.slot)
		var v = FighterView.new()
		scene.add_child(v)
		v.setup(p)
		v.position = Vector3(item.x, 0, 0)
		views.append({"view": v, "item": item})

	for f in range(30):
		for entry in views:
			entry.view.update_state({"x": entry.item.x, "y": 0, "facing": entry.item.facing, "pose": "Idle", "blocking": false}, 0.016)
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	if img:
		img.save_png("res://screenshot_all_characters_lineup.png")
		print("SAVED: screenshot_all_characters_lineup.png")

	scene.queue_free()
	await process_frame

	# --- 2. TRIO CLOSEUP: GOKU, SUB-ZERO, PAIN ---
	var scene2 = Node3D.new()
	root.add_child(scene2)

	var cam2 = Camera3D.new()
	cam2.position = Vector3(0, 1.35, 3.4)
	cam2.fov = 46
	scene2.add_child(cam2)
	cam2.look_at_from_position(cam2.position, Vector3(0, 1.10, 0))
	cam2.current = true

	var env2 = WorldEnvironment.new()
	env2.environment = Environment.new()
	env2.environment.background_mode = Environment.BG_SKY
	var sky2 = Sky.new()
	var sky_mat2 = PanoramaSkyMaterial.new()
	sky_mat2.panorama = load("res://assets/textures/arenas/sky_blood_moon.png")
	sky2.sky_material = sky_mat2
	env2.environment.sky = sky2
	env2.environment.sky_rotation = Vector3(0, deg_to_rad(90), 0)
	env2.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env2.environment.ambient_light_color = Color("2a384c")
	env2.environment.ambient_light_energy = 0.90
	env2.environment.glow_enabled = true
	env2.environment.glow_intensity = 0.65
	env2.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	scene2.add_child(env2)

	var floor2 = MeshInstance3D.new()
	floor2.mesh = plane
	floor2.material_override = f_mat
	scene2.add_child(floor2)

	var light2 = DirectionalLight3D.new()
	light2.rotation_degrees = Vector3(-32, -18, 0)
	light2.light_color = Color("fff5eb")
	light2.light_energy = 1.75
	light2.shadow_enabled = true
	scene2.add_child(light2)

	var fill2 = DirectionalLight3D.new()
	fill2.rotation_degrees = Vector3(20, -145, 0)
	fill2.light_color = Color("85a5cc")
	fill2.light_energy = 0.85
	scene2.add_child(fill2)

	var trio = [
		{"prompt": "Sub-Zero Lin Kuei Cryomancer ice ninja kori blade", "x": -1.15, "slot": 0, "facing": 0.20},
		{"prompt": "Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara", "x": 0.0, "slot": 0, "facing": 0.0},
		{"prompt": "Pain Nagato Rinnegan Akatsuki tendo deva path", "x": 1.15, "slot": 1, "facing": -0.20},
	]

	var trio_views = []
	for item in trio:
		var p = Prompt.interpret(item.prompt, item.slot)
		var v = FighterView.new()
		scene2.add_child(v)
		v.setup(p)
		v.position = Vector3(item.x, 0, 0)
		trio_views.append({"view": v, "item": item})

	for f in range(30):
		for entry in trio_views:
			entry.view.update_state({"x": entry.item.x, "y": 0, "facing": entry.item.facing, "pose": "Idle", "blocking": false}, 0.016)
		await process_frame

	var img2 = root.get_viewport().get_texture().get_image()
	if img2:
		img2.save_png("res://screenshot_trio_luffy_subzero_pain.png")
		print("SAVED: screenshot_trio_luffy_subzero_pain.png")

	print("ALL_LINEUPS_DONE")
	quit(0)

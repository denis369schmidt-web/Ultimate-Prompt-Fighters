extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	render_sonic_and_lineup()

func render_sonic_and_lineup() -> void:
	# -------------------------------------------------------------------------
	# 1. SONIC HERO SHOWCASE
	# -------------------------------------------------------------------------
	print(">>> RENDERING SONIC SHOWCASE...")
	var sc1 = Node3D.new()
	root.add_child(sc1)

	var cam1 = Camera3D.new()
	cam1.position = Vector3(0.28, 1.22, 2.15)
	sc1.add_child(cam1)
	cam1.look_at_from_position(cam1.position, Vector3(0, 1.05, 0))
	cam1.current = true

	var env1 = WorldEnvironment.new()
	env1.environment = Environment.new()
	env1.environment.background_mode = Environment.BG_SKY
	var sky1 = Sky.new()
	var sky_mat1 = PanoramaSkyMaterial.new()
	sky_mat1.panorama = load("res://assets/textures/arenas/sky_volcano_sanctum.png")
	sky1.sky_material = sky_mat1
	env1.environment.sky = sky1
	env1.environment.sky_rotation = Vector3(0, deg_to_rad(120), 0)
	env1.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env1.environment.ambient_light_color = Color("283548")
	env1.environment.ambient_light_energy = 1.15
	env1.environment.glow_enabled = true
	env1.environment.glow_intensity = 0.85
	env1.environment.glow_bloom = 0.25
	env1.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	sc1.add_child(env1)

	# Arena Floor (Large 60x60)
	var fl1 = MeshInstance3D.new()
	var pl1 = PlaneMesh.new()
	pl1.size = Vector2(60, 60)
	fl1.mesh = pl1
	fl1.position.y = -0.02
	var fm1 = StandardMaterial3D.new()
	fm1.albedo_texture = load("res://assets/textures/arenas/floor_stone_albedo.png")
	fm1.normal_enabled = true
	fm1.normal_texture = load("res://assets/textures/arenas/floor_stone_normal.png")
	fm1.normal_scale = 1.8
	fm1.uv1_scale = Vector3(12, 12, 12)
	fm1.roughness = 0.75
	fl1.material_override = fm1
	sc1.add_child(fl1)

	# Sun
	var sun1 = DirectionalLight3D.new()
	sun1.rotation_degrees = Vector3(-32, 28, 0)
	sun1.light_color = Color("fff5e0")
	sun1.light_energy = 2.4
	sun1.shadow_enabled = true
	sc1.add_child(sun1)

	# Rim Fill Light
	var rim1 = DirectionalLight3D.new()
	rim1.rotation_degrees = Vector3(20, -150, 0)
	rim1.light_color = Color("4088ff")
	rim1.light_energy = 1.6
	sc1.add_child(rim1)

	var p_sonic = Prompt.interpret("Sonic the Hedgehog Blue Blur Super Spin Dash Sega", 0)
	var v_sonic = FighterView.new()
	sc1.add_child(v_sonic)
	v_sonic.setup(p_sonic)
	v_sonic.position = Vector3(0, 0, 0)

	for f in range(40):
		v_sonic.update_state({"x": 0.0, "y": 0.0, "facing": -0.22, "pose": "Move", "blocking": false}, 0.016)
		await process_frame

	var img1 = root.get_viewport().get_texture().get_image()
	if img1:
		img1.save_png("res://screenshot_sonic_showcase.png")
		print("SAVED: screenshot_sonic_showcase.png")
	sc1.queue_free()
	await process_frame

	# -------------------------------------------------------------------------
	# 2. SONIC VS GOKU CLASH
	# -------------------------------------------------------------------------
	print(">>> RENDERING SONIC VS GOKU...")
	var sc2 = Node3D.new()
	root.add_child(sc2)

	var cam2 = Camera3D.new()
	cam2.position = Vector3(0, 1.30, 3.1)
	sc2.add_child(cam2)
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
	env2.environment.ambient_light_color = Color("282035")
	env2.environment.ambient_light_energy = 1.1
	env2.environment.glow_enabled = true
	env2.environment.glow_intensity = 0.95
	env2.environment.glow_bloom = 0.35
	env2.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	sc2.add_child(env2)

	var fl2 = MeshInstance3D.new()
	fl2.mesh = pl1
	fl2.position.y = -0.02
	fl2.material_override = fm1
	sc2.add_child(fl2)

	var sun2 = DirectionalLight3D.new()
	sun2.rotation_degrees = Vector3(-35, 20, 0)
	sun2.light_color = Color("ffe0cc")
	sun2.light_energy = 2.4
	sun2.shadow_enabled = true
	sc2.add_child(sun2)

	var v_sonic_vs = FighterView.new()
	sc2.add_child(v_sonic_vs)
	v_sonic_vs.setup(p_sonic)
	v_sonic_vs.position = Vector3(-1.0, 0, 0)

	var p_goku = Prompt.interpret("Son Goku Super Saiyan Kamehameha Dragon Ball Z", 1)
	var v_goku = FighterView.new()
	sc2.add_child(v_goku)
	v_goku.setup(p_goku)
	v_goku.position = Vector3(1.0, 0, 0)

	for f in range(40):
		v_sonic_vs.update_state({"x": -1.0, "y": 0.0, "facing": 1.0, "pose": "Move", "blocking": false}, 0.016)
		v_goku.update_state({"x": 1.0, "y": 0.0, "facing": -1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img2 = root.get_viewport().get_texture().get_image()
	if img2:
		img2.save_png("res://screenshot_sonic_vs_goku.png")
		print("SAVED: screenshot_sonic_vs_goku.png")
	sc2.queue_free()
	await process_frame

	# -------------------------------------------------------------------------
	# 3. ALL 12 PLAYABLE CHARACTERS MONUMENTAL LINEUP
	# -------------------------------------------------------------------------
	print(">>> RENDERING ALL 12 CHARACTERS LINEUP...")
	var sc3 = Node3D.new()
	root.add_child(sc3)

	var cam3 = Camera3D.new()
	cam3.position = Vector3(0, 1.80, 7.0)
	sc3.add_child(cam3)
	cam3.look_at_from_position(cam3.position, Vector3(0, 1.10, 0))
	cam3.current = true

	var env3 = WorldEnvironment.new()
	env3.environment = Environment.new()
	env3.environment.background_mode = Environment.BG_SKY
	var sky3 = Sky.new()
	var sky_mat3 = PanoramaSkyMaterial.new()
	sky_mat3.panorama = load("res://assets/textures/arenas/sky_imperial_colosseum.png")
	sky3.sky_material = sky_mat3
	env3.environment.sky = sky3
	env3.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env3.environment.ambient_light_color = Color("383844")
	env3.environment.ambient_light_energy = 1.15
	env3.environment.glow_enabled = true
	env3.environment.glow_intensity = 0.80
	env3.environment.glow_bloom = 0.20
	env3.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	sc3.add_child(env3)

	var fl3 = MeshInstance3D.new()
	fl3.mesh = pl1
	fl3.position.y = -0.02
	fl3.material_override = fm1
	sc3.add_child(fl3)

	var sun3 = DirectionalLight3D.new()
	sun3.rotation_degrees = Vector3(-40, 25, 0)
	sun3.light_color = Color("fff5e8")
	sun3.light_energy = 2.4
	sun3.shadow_enabled = true
	sc3.add_child(sun3)

	var fill3 = DirectionalLight3D.new()
	fill3.rotation_degrees = Vector3(30, -150, 0)
	fill3.light_color = Color("7095c0")
	fill3.light_energy = 1.3
	sc3.add_child(fill3)

	var roster = [
		{"prompt": "Blitzschneller Schattenninja mit elektrischen Klingen", "x": -4.4, "z": -0.4, "facing": 0.35},
		{"prompt": "Gepanzerter Lavagolem mit brennenden Fäusten", "x": -3.6, "z": -0.1, "facing": 0.28},
		{"prompt": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier", "x": -2.8, "z": 0.15, "facing": 0.20},
		{"prompt": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert", "x": -2.0, "z": -0.2, "facing": 0.15},
		{"prompt": "Son Goku Super Saiyan Kamehameha Dragon Ball Z", "x": -1.2, "z": 0.25, "facing": 0.10},
		{"prompt": "Sonic the Hedgehog Blue Blur Super Spin Dash Sega", "x": -0.40, "z": 0.40, "facing": 0.05},
		{"prompt": "Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara", "x": 0.40, "z": 0.40, "facing": -0.05},
		{"prompt": "Sub-Zero Lin Kuei Cryomancer ice ninja kori blade", "x": 1.2, "z": 0.25, "facing": -0.10},
		{"prompt": "Pain Nagato Akatsuki Rinnegan Shinra Tensei", "x": 2.0, "z": -0.2, "facing": -0.15},
		{"prompt": "Jackal God Anubis wielding dual Khopesh", "x": 2.8, "z": 0.15, "facing": -0.20},
		{"prompt": "Void Specter crystal phantom warrior with void lance", "x": 3.6, "z": -0.1, "facing": -0.28},
		{"prompt": "Phoenix Empress with feather armor and phoenix glaive", "x": 4.4, "z": -0.4, "facing": -0.35}
	]

	var views_list: Array = []
	for r in roster:
		var pr = Prompt.interpret(r.prompt, 0)
		var vr = FighterView.new()
		sc3.add_child(vr)
		vr.setup(pr)
		vr.position = Vector3(r.x, 0, r.z)
		views_list.append({"view": vr, "data": r})

	for f in range(40):
		for item in views_list:
			var d = item.data
			item.view.update_state({"x": d.x, "y": 0.0, "facing": d.facing, "pose": "Idle", "blocking": false}, 0.016)
		await process_frame

	var img3 = root.get_viewport().get_texture().get_image()
	if img3:
		img3.save_png("res://screenshot_all_12_characters_lineup.png")
		print("SAVED: screenshot_all_12_characters_lineup.png")
	sc3.queue_free()
	await process_frame

	print("ALL_SHOWCASES_COMPLETED_SUCCESSFULLY")
	quit(0)

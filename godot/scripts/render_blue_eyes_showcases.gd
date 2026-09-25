extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	render_showcases()

func render_showcases() -> void:
	var floor_tex = load("res://assets/textures/arenas/floor_stone_albedo.png")
	var floor_norm = load("res://assets/textures/arenas/floor_stone_normal.png")
	var sky_tex = "res://assets/textures/arenas/sky_blood_moon.png"

	# ─────────────────────────────────────────────────────────────────────────
	# 1. BLUE-EYES DRAGON SHOWCASE (Burst Stream of Destruction)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Blue-Eyes Dragon Showcase ---")
	var s1 = Node3D.new()
	root.add_child(s1)
	setup_environment(s1, sky_tex, Color("c0e8ff"), Vector3(-28, 20, 0), floor_tex, floor_norm)

	var cam1 = Camera3D.new()
	cam1.position = Vector3(0.35, 1.45, 2.95)
	s1.add_child(cam1)
	cam1.look_at_from_position(cam1.position, Vector3(0, 1.15, 0))
	cam1.current = true

	var p_blue_eyes = Prompt.interpret("Weißer Drache mit eiskaltem Blick Burst Stream Yu-Gi-Oh", 0)
	var v_blue_eyes = FighterView.new()
	s1.add_child(v_blue_eyes)
	v_blue_eyes.setup(p_blue_eyes)

	for f in range(40):
		v_blue_eyes.update_state({"x": 0.0, "y": 0.0, "facing": -0.22, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img1 = root.get_viewport().get_texture().get_image()
	if img1:
		img1.save_png("res://screenshot_blue_eyes_showcase.png")
		print("SAVED: screenshot_blue_eyes_showcase.png")
	s1.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 2. AKAZA HIGH-DETAIL SHOWCASE (Compass Needle Destructive Death)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Akaza High-Detail Showcase ---")
	var s_ak = Node3D.new()
	root.add_child(s_ak)
	setup_environment(s_ak, sky_tex, Color("ffe0f0"), Vector3(-28, 20, 0), floor_tex, floor_norm)

	var cam_ak = Camera3D.new()
	cam_ak.position = Vector3(0.25, 1.35, 2.65)
	s_ak.add_child(cam_ak)
	cam_ak.look_at_from_position(cam_ak.position, Vector3(0, 1.15, 0))
	cam_ak.current = true

	var p_akaza = Prompt.interpret("Akaza Upper Rank 3 Hakai Satsu Compass Needle Kimetsu", 0)
	var v_akaza = FighterView.new()
	s_ak.add_child(v_akaza)
	v_akaza.setup(p_akaza)

	for f in range(40):
		v_akaza.update_state({"x": 0.0, "y": 0.0, "facing": -0.22, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img_ak = root.get_viewport().get_texture().get_image()
	if img_ak:
		img_ak.save_png("res://screenshot_akaza_showcase.png")
		print("SAVED: screenshot_akaza_showcase.png")
	s_ak.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 3. BLUE-EYES VS GOKU (Legendary Dragon vs Super Saiyan Clash)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Blue-Eyes vs Goku ---")
	var s2 = Node3D.new()
	root.add_child(s2)
	setup_environment(s2, sky_tex, Color("d0e8ff"), Vector3(-25, 25, 0), floor_tex, floor_norm)

	var cam2 = Camera3D.new()
	cam2.position = Vector3(0, 1.55, 3.85)
	s2.add_child(cam2)
	cam2.look_at_from_position(cam2.position, Vector3(0, 1.20, 0))
	cam2.current = true

	var v_be2 = FighterView.new()
	s2.add_child(v_be2)
	v_be2.setup(p_blue_eyes)
	v_be2.position = Vector3(-1.15, 0, 0)

	var p_goku = Prompt.interpret("Son Goku Super Saiyan Kamehameha Dragon Ball Z", 1)
	var v_goku = FighterView.new()
	s2.add_child(v_goku)
	v_goku.setup(p_goku)
	v_goku.position = Vector3(1.15, 0, 0)

	for f in range(40):
		v_be2.update_state({"x": -1.15, "y": 0.0, "facing": 1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		v_goku.update_state({"x": 1.15, "y": 0.0, "facing": -1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img2 = root.get_viewport().get_texture().get_image()
	if img2:
		img2.save_png("res://screenshot_blue_eyes_vs_goku.png")
		print("SAVED: screenshot_blue_eyes_vs_goku.png")
	s2.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 4. AKAZA VS GOKU (Destructive Martial Clash)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Akaza vs Goku ---")
	var s_ag = Node3D.new()
	root.add_child(s_ag)
	setup_environment(s_ag, sky_tex, Color("ffeedd"), Vector3(-25, 25, 0), floor_tex, floor_norm)

	var cam_ag = Camera3D.new()
	cam_ag.position = Vector3(0, 1.45, 3.65)
	s_ag.add_child(cam_ag)
	cam_ag.look_at_from_position(cam_ag.position, Vector3(0, 1.15, 0))
	cam_ag.current = true

	var v_akaza2 = FighterView.new()
	s_ag.add_child(v_akaza2)
	v_akaza2.setup(p_akaza)
	v_akaza2.position = Vector3(-1.05, 0, 0)

	var v_goku2 = FighterView.new()
	s_ag.add_child(v_goku2)
	v_goku2.setup(p_goku)
	v_goku2.position = Vector3(1.05, 0, 0)

	for f in range(40):
		v_akaza2.update_state({"x": -1.05, "y": 0.0, "facing": 1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		v_goku2.update_state({"x": 1.05, "y": 0.0, "facing": -1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img_ag = root.get_viewport().get_texture().get_image()
	if img_ag:
		img_ag.save_png("res://screenshot_akaza_vs_goku.png")
		print("SAVED: screenshot_akaza_vs_goku.png")
	s_ag.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 5. ALL 14 FIGHTERS LINEUP (Panoramic Showcase)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering All 14 Fighters Lineup ---")
	var s3 = Node3D.new()
	root.add_child(s3)
	setup_environment(s3, sky_tex, Color("fff4eb"), Vector3(-30, 20, 0), floor_tex, floor_norm)

	var cam3 = Camera3D.new()
	cam3.position = Vector3(0, 1.70, 6.2)
	s3.add_child(cam3)
	cam3.look_at_from_position(cam3.position, Vector3(0, 1.15, 0))
	cam3.current = true

	var lineup = [
		{"prompt": "Blitzschneller Schattenninja mit elektrischen Klingen", "pose": "Idle", "facing": 0.38},
		{"prompt": "Gepanzerter Lavagolem mit brennenden Fäusten", "pose": "Idle", "facing": 0.32},
		{"prompt": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier", "pose": "Idle", "facing": 0.26},
		{"prompt": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert", "pose": "Idle", "facing": 0.20},
		{"prompt": "Jackal God Anubis wielding dual Khopesh", "pose": "Idle", "facing": 0.14},
		{"prompt": "Void Specter crystal phantom warrior with void lance", "pose": "Idle", "facing": 0.08},
		{"prompt": "Weißer Drache mit eiskaltem Blick Burst Stream Yu-Gi-Oh", "pose": "SpecialAttack", "facing": 0.0},
		{"prompt": "Akaza Upper Rank 3 Hakai Satsu Compass Needle Kimetsu", "pose": "SpecialAttack", "facing": -0.08},
		{"prompt": "Phoenix Empress with feather armor and phoenix glaive", "pose": "Idle", "facing": -0.14},
		{"prompt": "Son Goku Super Saiyan Kamehameha Dragon Ball Z", "pose": "Idle", "facing": -0.20},
		{"prompt": "Sub-Zero Lin Kuei Cryomancer ice ninja kori blade", "pose": "Idle", "facing": -0.26},
		{"prompt": "Pain Nagato Akatsuki Rinnegan Shinra Tensei", "pose": "Idle", "facing": -0.32},
		{"prompt": "Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara", "pose": "Idle", "facing": -0.36},
		{"prompt": "Sonic the Hedgehog Blue Blur Super Spin Dash Sega", "pose": "Idle", "facing": -0.40}
	]

	var total_w = 8.4
	var step_x = total_w / (lineup.size() - 1)
	var start_x = -total_w / 2.0
	var views_lineup = []

	for i in range(lineup.size()):
		var item = lineup[i]
		var px = start_x + i * step_x
		var p_char = Prompt.interpret(item.prompt, i % 2)
		var v_char = FighterView.new()
		s3.add_child(v_char)
		v_char.setup(p_char)
		v_char.position = Vector3(px, 0, -abs(px) * 0.18)
		views_lineup.append({"view": v_char, "x": px, "facing": item.facing, "pose": item.pose})

	for f in range(40):
		for vl in views_lineup:
			vl.view.update_state({"x": vl.x, "y": 0.0, "facing": vl.facing, "pose": vl.pose, "blocking": false}, 0.016)
		await process_frame

	var img3 = root.get_viewport().get_texture().get_image()
	if img3:
		img3.save_png("res://screenshot_all_14_characters_lineup.png")
		print("SAVED: screenshot_all_14_characters_lineup.png")
	s3.queue_free()
	await process_frame

	print("=== ALL PRO SHOWCASES COMPLETED SUCCESSFULLY! ===")
	quit(0)

func setup_environment(scene: Node3D, sky_path: String, sun_col: Color, sun_rot: Vector3, floor_tex: Texture2D, floor_norm: Texture2D) -> void:
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_mat = PanoramaSkyMaterial.new()
	sky_mat.panorama = load(sky_path)
	sky.sky_material = sky_mat
	env.environment.sky = sky
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("223348")
	env.environment.ambient_light_energy = 0.95
	env.environment.glow_enabled = true
	env.environment.glow_intensity = 0.90
	env.environment.glow_bloom = 0.30
	env.environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	env.environment.ssao_enabled = true
	env.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	scene.add_child(env)

	var floor_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(30, 30)
	floor_mesh.mesh = plane
	var f_mat = StandardMaterial3D.new()
	f_mat.albedo_texture = floor_tex
	f_mat.normal_enabled = true
	f_mat.normal_texture = floor_norm
	f_mat.normal_scale = 1.6
	f_mat.uv1_scale = Vector3(5, 5, 5)
	f_mat.roughness = 0.82
	floor_mesh.material_override = f_mat
	scene.add_child(floor_mesh)

	var light = DirectionalLight3D.new()
	light.rotation_degrees = sun_rot
	light.light_color = sun_col
	light.light_energy = 2.2
	light.shadow_enabled = true
	scene.add_child(light)

	var fill = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(25, -140, 0)
	fill.light_color = Color("85a5cc")
	fill.light_energy = 0.95
	scene.add_child(fill)

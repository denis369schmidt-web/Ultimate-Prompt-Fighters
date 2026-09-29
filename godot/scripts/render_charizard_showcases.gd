extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	render_showcases()

func render_showcases() -> void:
	var floor_tex = load("res://assets/textures/arenas/floor_stone_albedo.png")
	var floor_norm = load("res://assets/textures/arenas/floor_stone_normal.png")
	var sky_tex = "res://assets/textures/arenas/sky_volcano_sanctum.png"

	# ─────────────────────────────────────────────────────────────────────────
	# 1. CHARIZARD SOLO SHOWCASE
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Charizard Solo Showcase ---")
	var s1 = Node3D.new()
	root.add_child(s1)
	setup_environment(s1, sky_tex, Color("ffe0b0"), Vector3(-25, 25, 0), floor_tex, floor_norm)

	var cam1 = Camera3D.new()
	cam1.position = Vector3(0.40, 1.45, 2.75)
	s1.add_child(cam1)
	cam1.look_at_from_position(cam1.position, Vector3(0, 1.15, 0))
	cam1.current = true

	var p_charizard = Prompt.interpret("Glurak Flammen-Drache Drachenschwingen Feuersturm Pokemon", 0)
	var v_charizard = FighterView.new()
	s1.add_child(v_charizard)
	v_charizard.setup(p_charizard)

	for f in range(40):
		v_charizard.update_state({"x": 0.0, "y": 0.0, "facing": -0.22, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img1 = root.get_viewport().get_texture().get_image()
	if img1:
		img1.save_png("res://screenshot_charizard_showcase.png")
		print("SAVED: screenshot_charizard_showcase.png")
	s1.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 2. LEGENDARY DRAGON DUEL: CHARIZARD VS BLUE-EYES WHITE DRAGON
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Charizard vs Blue-Eyes Dragon Duel ---")
	var s2 = Node3D.new()
	root.add_child(s2)
	setup_environment(s2, "res://assets/textures/arenas/sky_blood_moon.png", Color("ffeedd"), Vector3(-20, 30, 0), floor_tex, floor_norm)

	var cam2 = Camera3D.new()
	cam2.position = Vector3(0.0, 1.45, 3.40)
	s2.add_child(cam2)
	cam2.look_at_from_position(cam2.position, Vector3(0.0, 1.10, 0.0))
	cam2.current = true

	var p_blue_eyes = Prompt.interpret("Weißer Drache mit eiskaltem Blick Burst Stream Yu-Gi-Oh", 0)
	var v_blue = FighterView.new()
	s2.add_child(v_blue)
	v_blue.setup(p_blue_eyes)
	v_blue.position = Vector3(-1.10, 0, 0)

	var v_char_duel = FighterView.new()
	s2.add_child(v_char_duel)
	v_char_duel.setup(p_charizard)
	v_char_duel.position = Vector3(1.10, 0, 0)

	for f in range(40):
		v_blue.update_state({"x": -1.10, "y": 0.0, "facing": 1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		v_char_duel.update_state({"x": 1.10, "y": 0.0, "facing": -1.0, "pose": "Attack", "blocking": false}, 0.016)
		await process_frame

	var img2 = root.get_viewport().get_texture().get_image()
	if img2:
		img2.save_png("res://screenshot_charizard_vs_blue_eyes.png")
		print("SAVED: screenshot_charizard_vs_blue_eyes.png")
	s2.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 3. RE-RENDER FRIEZA SHOWCASE (WITH FIXED SHADERS)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Frieza Solo Showcase (Fixed Shaders) ---")
	var s_fr = Node3D.new()
	root.add_child(s_fr)
	setup_environment(s_fr, "res://assets/textures/arenas/sky_blood_moon.png", Color("d0b0ff"), Vector3(-25, 20, 0), floor_tex, floor_norm)

	var cam_fr = Camera3D.new()
	cam_fr.position = Vector3(0.25, 1.35, 2.50)
	s_fr.add_child(cam_fr)
	cam_fr.look_at_from_position(cam_fr.position, Vector3(0, 1.10, 0))
	cam_fr.current = true

	var p_frieza = Prompt.interpret("Frieza Final Form Emperor Death Beam Supernova Dragon Ball Z", 0)
	var v_frieza = FighterView.new()
	s_fr.add_child(v_frieza)
	v_frieza.setup(p_frieza)

	for f in range(40):
		v_frieza.update_state({"x": 0.0, "y": 0.0, "facing": -0.25, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img_fr = root.get_viewport().get_texture().get_image()
	if img_fr:
		img_fr.save_png("res://screenshot_frieza_showcase.png")
		print("SAVED: screenshot_frieza_showcase.png")
	s_fr.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 4. MORTAL KOMBAT 22 SELECT GRID
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Mortal Kombat 22 Select Grid ---")
	var main_scene = load("res://main.tscn").instantiate()
	root.add_child(main_scene)
	await process_frame
	await process_frame

	main_scene.show_selection()

	for f in range(30):
		await process_frame

	var img_mk = root.get_viewport().get_texture().get_image()
	if img_mk:
		img_mk.save_png("res://screenshot_mortal_kombat_22_select.png")
		print("SAVED: screenshot_mortal_kombat_22_select.png")
	main_scene.queue_free()
	await process_frame

	print("=== ALL CHARIZARD SHOWCASES COMPLETED SUCCESSFULLY! ===")
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

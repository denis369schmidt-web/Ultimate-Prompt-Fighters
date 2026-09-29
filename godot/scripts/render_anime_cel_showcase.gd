extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	render_anime_showcases()

func render_anime_showcases() -> void:
	var floor_tex = load("res://assets/textures/arenas/floor_stone_albedo.png")
	var floor_norm = load("res://assets/textures/arenas/floor_stone_normal.png")
	var sky_tex = "res://assets/textures/arenas/sky_blood_moon.png"

	# ─────────────────────────────────────────────────────────────────────────
	# 1. GOKU VS VEGETA (Anime Cel-Shading & Inverted Hull Black Outline)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Anime Cel: Goku vs Vegeta ---")
	var s1 = Node3D.new()
	root.add_child(s1)
	setup_anime_scene(s1, sky_tex, Color("fff2e0"), Vector3(-25, 30, 0), floor_tex, floor_norm)

	var cam1 = Camera3D.new()
	cam1.position = Vector3(0.0, 1.35, 3.10)
	s1.add_child(cam1)
	cam1.look_at_from_position(cam1.position, Vector3(0.0, 1.05, 0.0))
	cam1.current = true

	var p_goku = Prompt.interpret("Son Goku Super Saiyan Kamehameha Dragon Ball Z", 0)
	var v_goku = FighterView.new()
	s1.add_child(v_goku)
	v_goku.setup(p_goku)
	v_goku.position = Vector3(-0.95, 0, 0)
	v_goku.rotation_degrees = Vector3(0, 75, 0)

	var p_vegeta = Prompt.interpret("Prinz Vegeta Saiyajin Royal Armor Final Flash Galick Gun", 0)
	var v_vegeta = FighterView.new()
	s1.add_child(v_vegeta)
	v_vegeta.setup(p_vegeta)
	v_vegeta.position = Vector3(0.95, 0, 0)
	v_vegeta.rotation_degrees = Vector3(0, -75, 0)

	for f in range(40):
		v_goku.update_state({"x": -0.95, "y": 0.0, "facing": 1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		v_vegeta.update_state({"x": 0.95, "y": 0.0, "facing": -1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img1 = root.get_viewport().get_texture().get_image()
	if img1:
		img1.save_png("res://screenshot_anime_cel_goku_vs_vegeta.png")
		print("SAVED: screenshot_anime_cel_goku_vs_vegeta.png")
	s1.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 2. SUB-ZERO VS PAIN (Anime Cel-Shading & Outlines)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Anime Cel: Sub-Zero vs Pain ---")
	var s2 = Node3D.new()
	root.add_child(s2)
	setup_anime_scene(s2, sky_tex, Color("d0e8ff"), Vector3(-20, 25, 0), floor_tex, floor_norm)

	var cam2 = Camera3D.new()
	cam2.position = Vector3(0.0, 1.35, 3.10)
	s2.add_child(cam2)
	cam2.look_at_from_position(cam2.position, Vector3(0.0, 1.05, 0.0))
	cam2.current = true

	var p_subzero = Prompt.interpret("Sub-Zero Lin Kuei Cryomancer ice ninja kori blade", 0)
	var v_subzero = FighterView.new()
	s2.add_child(v_subzero)
	v_subzero.setup(p_subzero)
	v_subzero.position = Vector3(-0.95, 0, 0)
	v_subzero.rotation_degrees = Vector3(0, 75, 0)

	var p_pain = Prompt.interpret("Pain Nagato Akatsuki Rinnegan Shinra Tensei", 0)
	var v_pain = FighterView.new()
	s2.add_child(v_pain)
	v_pain.setup(p_pain)
	v_pain.position = Vector3(0.95, 0, 0)
	v_pain.rotation_degrees = Vector3(0, -75, 0)

	for f in range(40):
		v_subzero.update_state({"x": -0.95, "y": 0.0, "facing": 1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		v_pain.update_state({"x": 0.95, "y": 0.0, "facing": -1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img2 = root.get_viewport().get_texture().get_image()
	if img2:
		img2.save_png("res://screenshot_anime_cel_subzero_vs_pain.png")
		print("SAVED: screenshot_anime_cel_subzero_vs_pain.png")
	s2.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 3. GOLDEN GOLEM VS BLUE WYRM (Tripo Models Cel-Shaded at True Scale)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Anime Cel: Golden Golem vs Blue Wyrm ---")
	var s3 = Node3D.new()
	root.add_child(s3)
	setup_anime_scene(s3, sky_tex, Color("ffe8a0"), Vector3(-25, 25, 0), floor_tex, floor_norm)

	var cam3 = Camera3D.new()
	cam3.position = Vector3(0.0, 1.40, 3.40)
	s3.add_child(cam3)
	cam3.look_at_from_position(cam3.position, Vector3(0.0, 1.10, 0.0))
	cam3.current = true

	var p_golem = Prompt.interpret("Golden Armored Golem ancient guardian titan Tripo", 0)
	var v_golem = FighterView.new()
	s3.add_child(v_golem)
	v_golem.setup(p_golem)
	v_golem.position = Vector3(-1.10, 0, 0)
	v_golem.rotation_degrees = Vector3(0, 65, 0)

	var p_wyrm = Prompt.interpret("Blue Wyrm Frost Dragon beast Tripo", 0)
	var v_wyrm = FighterView.new()
	s3.add_child(v_wyrm)
	v_wyrm.setup(p_wyrm)
	v_wyrm.position = Vector3(1.10, 0, 0)
	v_wyrm.rotation_degrees = Vector3(0, -65, 0)

	for f in range(40):
		v_golem.update_state({"x": -1.10, "y": 0.0, "facing": 1.0, "pose": "Attack", "blocking": false}, 0.016)
		v_wyrm.update_state({"x": 1.10, "y": 0.0, "facing": -1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img3 = root.get_viewport().get_texture().get_image()
	if img3:
		img3.save_png("res://screenshot_anime_cel_golem_vs_wyrm.png")
		print("SAVED: screenshot_anime_cel_golem_vs_wyrm.png")
	s3.queue_free()
	await process_frame

	print("--- All Anime Cel Showcases Successfully Rendered! ---")
	quit()

func setup_anime_scene(scene: Node3D, sky_path: String, sun_color: Color, sun_rot: Vector3, floor_albedo: Texture2D, floor_normal: Texture2D) -> void:
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_mat = PanoramaSkyMaterial.new()
	sky_mat.panorama = load(sky_path)
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 1.45
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.38
	env.glow_enabled = true
	env.glow_intensity = 0.50
	env.glow_bloom = 0.15
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	env.ssao_enabled = true
	env.ssao_radius = 1.0
	env.ssao_intensity = 1.5
	env.ssr_enabled = false

	var we = WorldEnvironment.new()
	we.environment = env
	scene.add_child(we)

	# Key Light (Layers 1 & 2)
	var sun = DirectionalLight3D.new()
	sun.light_color = sun_color
	sun.light_energy = 2.40
	sun.shadow_enabled = true
	sun.light_cull_mask = 1 | 2
	sun.rotation_degrees = sun_rot
	scene.add_child(sun)

	# Front Fill Light: brightens character faces and eliminates gloomy darkness
	var fill = DirectionalLight3D.new()
	fill.light_color = Color("fff5ea")
	fill.light_energy = 1.20
	fill.shadow_enabled = false
	fill.light_cull_mask = 1 | 2
	fill.rotation_degrees = Vector3(30, 20, 0)
	scene.add_child(fill)

	# Dedicated Grazing Rim Light (Visual Layer 2)
	var rim_light = DirectionalLight3D.new()
	rim_light.light_color = Color("cce6ff")
	rim_light.light_energy = 2.6
	rim_light.shadow_enabled = false
	rim_light.light_cull_mask = 2
	rim_light.rotation_degrees = Vector3(15, -165, 0)
	scene.add_child(rim_light)

	# Arena Floor Platform
	var floor_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(16, 16)
	floor_mesh.mesh = plane
	var fmat = StandardMaterial3D.new()
	fmat.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	fmat.albedo_texture = floor_albedo
	fmat.normal_enabled = true
	fmat.normal_texture = floor_normal
	fmat.normal_scale = 2.4
	fmat.roughness = 0.35
	fmat.uv1_scale = Vector3(4, 4, 1)
	floor_mesh.set_surface_override_material(0, fmat)
	scene.add_child(floor_mesh)

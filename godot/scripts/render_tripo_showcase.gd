extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
	render_all()

func render_all() -> void:
	var floor_tex = load("res://assets/textures/arenas/floor_stone_albedo.png")
	var floor_norm = load("res://assets/textures/arenas/floor_stone_normal.png")
	var sky_tex = "res://assets/textures/arenas/sky_blood_moon.png"

	# ─────────────────────────────────────────────────────────────────────────
	# 1. GOLDEN GOLEM SHOWCASE (Tripo URL Model)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Golden Golem Showcase ---")
	var s1 = Node3D.new()
	root.add_child(s1)
	setup_environment(s1, sky_tex, Color("ffe8a0"), Vector3(-25, 25, 0), floor_tex, floor_norm)

	var cam1 = Camera3D.new()
	cam1.position = Vector3(0.28, 1.45, 2.60)
	s1.add_child(cam1)
	cam1.look_at_from_position(cam1.position, Vector3(0, 1.15, 0))
	cam1.current = true

	var p_golem = Prompt.interpret("Golden Armored Golem ancient guardian titan Tripo", 0)
	var v_golem = FighterView.new()
	s1.add_child(v_golem)
	v_golem.setup(p_golem)

	for f in range(40):
		v_golem.update_state({"x": 0.0, "y": 0.0, "facing": -0.22, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img1 = root.get_viewport().get_texture().get_image()
	if img1:
		img1.save_png("res://screenshot_golden_golem_showcase.png")
		print("SAVED: screenshot_golden_golem_showcase.png")
	s1.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 2. GOLDEN GOLEM VS BLUE WYRM (Tripo vs Tripo)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Golden Golem vs Blue Wyrm Duel ---")
	var s2 = Node3D.new()
	root.add_child(s2)
	setup_environment(s2, sky_tex, Color("ffffff"), Vector3(-20, 30, 0), floor_tex, floor_norm)

	var cam2 = Camera3D.new()
	cam2.position = Vector3(0.0, 1.40, 3.40)
	s2.add_child(cam2)
	cam2.look_at_from_position(cam2.position, Vector3(0.0, 1.10, 0.0))
	cam2.current = true

	var v_golem_duel = FighterView.new()
	s2.add_child(v_golem_duel)
	v_golem_duel.setup(p_golem)
	v_golem_duel.position = Vector3(-1.10, 0, 0)

	var p_wyrm = Prompt.interpret("Blue Wyrm Frost Dragon beast Tripo", 0)
	var v_wyrm = FighterView.new()
	s2.add_child(v_wyrm)
	v_wyrm.setup(p_wyrm)
	v_wyrm.position = Vector3(1.10, 0, 0)

	for f in range(40):
		v_golem_duel.update_state({"x": -1.10, "y": 0.0, "facing": 1.0, "pose": "Attack", "blocking": false}, 0.016)
		v_wyrm.update_state({"x": 1.10, "y": 0.0, "facing": -1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		await process_frame

	var img2 = root.get_viewport().get_texture().get_image()
	if img2:
		img2.save_png("res://screenshot_golem_vs_bluewyrm.png")
		print("SAVED: screenshot_golem_vs_bluewyrm.png")
	s2.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 3. KITSUNE WARRIOR VS NYX HARVESTER (Tripo Clash)
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Kitsune vs Nyx Harvester Duel ---")
	var s3 = Node3D.new()
	root.add_child(s3)
	setup_environment(s3, sky_tex, Color("ffe4cc"), Vector3(-25, 15, 0), floor_tex, floor_norm)

	var cam3 = Camera3D.new()
	cam3.position = Vector3(0.0, 1.35, 3.20)
	s3.add_child(cam3)
	cam3.look_at_from_position(cam3.position, Vector3(0.0, 1.05, 0.0))
	cam3.current = true

	var p_kitsune = Prompt.interpret("Cat Girl Kitsune Warrior blade Tripo", 0)
	var v_kitsune = FighterView.new()
	s3.add_child(v_kitsune)
	v_kitsune.setup(p_kitsune)
	v_kitsune.position = Vector3(-0.95, 0, 0)

	var p_nyx = Prompt.interpret("Nyx Harvester of Souls demon scythe reaper Tripo", 0)
	var v_nyx = FighterView.new()
	s3.add_child(v_nyx)
	v_nyx.setup(p_nyx)
	v_nyx.position = Vector3(0.95, 0, 0)

	for f in range(40):
		v_kitsune.update_state({"x": -0.95, "y": 0.0, "facing": 1.0, "pose": "SpecialAttack", "blocking": false}, 0.016)
		v_nyx.update_state({"x": 0.95, "y": 0.0, "facing": -1.0, "pose": "Attack", "blocking": false}, 0.016)
		await process_frame

	var img3 = root.get_viewport().get_texture().get_image()
	if img3:
		img3.save_png("res://screenshot_kitsune_vs_nyx.png")
		print("SAVED: screenshot_kitsune_vs_nyx.png")
	s3.queue_free()
	await process_frame

	# ─────────────────────────────────────────────────────────────────────────
	# 4. MORTAL KOMBAT 33 ROSTER SELECT GRID
	# ─────────────────────────────────────────────────────────────────────────
	print("--- Rendering Mortal Kombat 33 Select Grid ---")
	var main_scene = load("res://main.tscn").instantiate()
	root.add_child(main_scene)

	for f in range(15):
		await process_frame

	main_scene.show_selection()

	for f in range(25):
		await process_frame

	var img_mk = root.get_viewport().get_texture().get_image()
	if img_mk:
		img_mk.save_png("res://screenshot_mortal_kombat_33_select.png")
		print("SAVED: screenshot_mortal_kombat_33_select.png")

	print("--- All Tripo Showcases Rendered Successfully! ---")
	quit()

func setup_environment(scene: Node3D, sky_path: String, sun_color: Color, sun_rot: Vector3, floor_albedo: Texture2D, floor_normal: Texture2D) -> void:
	var env = Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky = Sky.new()
	var sky_mat = PanoramaSkyMaterial.new()
	sky_mat.panorama = load(sky_path)
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = true
	env.glow_intensity = 0.45
	env.glow_bloom = 0.15
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	env.ssao_enabled = true
	env.ssao_radius = 1.6
	env.ssao_intensity = 2.4
	env.ssr_enabled = true
	env.ssr_max_steps = 64

	var we = WorldEnvironment.new()
	we.environment = env
	scene.add_child(we)

	# Key Light (Layers 1 & 2)
	var sun = DirectionalLight3D.new()
	sun.light_color = sun_color
	sun.light_energy = 1.35
	sun.shadow_enabled = true
	sun.light_cull_mask = 1 | 2
	sun.rotation_degrees = sun_rot
	scene.add_child(sun)

	# Dedicated Grazing Rim / Kicker Light (Isolated to Visual Layer 2)
	var rim_light = DirectionalLight3D.new()
	rim_light.light_color = Color("cce6ff")
	rim_light.light_energy = 2.6
	rim_light.shadow_enabled = false
	rim_light.light_cull_mask = 2
	rim_light.rotation_degrees = Vector3(20, -160, 0)
	scene.add_child(rim_light)

	# Arena Floor Platform
	var floor_mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(16, 16)
	floor_mesh.mesh = plane
	var fmat = StandardMaterial3D.new()
	fmat.albedo_texture = floor_albedo
	fmat.normal_enabled = true
	fmat.normal_texture = floor_normal
	fmat.normal_scale = 2.4
	fmat.roughness = 0.35
	fmat.uv1_scale = Vector3(4, 4, 1)
	floor_mesh.set_surface_override_material(0, fmat)
	scene.add_child(floor_mesh)

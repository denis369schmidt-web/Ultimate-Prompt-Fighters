extends SceneTree
## Raw artwork for the Steam and Google Play store pages, rendered from the real game:
##   keyart_wide.png  3840x2160 – arena and line-up, no UI
##   keyart_tall.png  2160x2700 – three fighters closer, for the vertical capsules
##   icon_face.png    1024x1024 – close-up for the app icon
##   logo.png         2400x1350 – the title logo on a transparent background
##   shot_XX.png      1920x1080 – real fights (signatures, four players, finisher), no HUD
## scripts/store_art.py cuts the store formats from these files.
## Usage: godot --path godot --script res://tests/render_store_art.gd -- --out=<dir> [--bg=moon_temple]

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

## Line-up for the key art, left to right, with the pose each one strikes.
const LINEUP := [["phoenix", "SpecialAttack"], ["nyx", "Charge"], ["dragon", "Victory"], ["arber", "LightAttack"], ["brunhild", "Roar"]]
const TALL := [["phoenix", "SpecialAttack"], ["dragon", "Victory"], ["arber", "LightAttack"]]
## Fight screenshots: fighter, opponent, arena background id.
## Arenas picked from a render of all 23 (the strongest backdrops; see docs/STORE_RELEASE.md).
const FIGHTS := [["dragon", "kairo", "moon_temple"], ["arber", "nyx", "jungle_ruins"], ["phoenix", "frostwyrm", "colosseum_dusk"],
	["celestial_fox", "skeleton_reaper", "orbital_ring"], ["vanguard_soldier", "pyrax", "arena_sun"], ["vampire_lord", "brunhild", "space_hangar"]]
## Store screenshots sit closer than the in-game camera (which leaves room for the HUD): 0 = game camera, 0.3 = 30 % closer.
const SHOT_ZOOM := 0.4

var out_dir := "user://"
var bg_id := "moon_temple"
var app
var prompts := {}

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
		if arg.begins_with("--bg="): bg_id = arg.trim_prefix("--bg=")
	call_deferred("run")

func frames(n: int) -> void:
	for k in range(n): await process_frame

## A viewport that shares the game's 3D world but has its own camera and size (no UI on top).
func world_viewport(size: Vector2i) -> SubViewport:
	var vp := SubViewport.new()
	vp.size = size
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	vp.msaa_3d = Viewport.MSAA_4X
	vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	root.add_child(vp)
	var cam := Camera3D.new()
	cam.current = true
	vp.add_child(cam)
	return vp

func save(vp: Viewport, name: String) -> void:
	await RenderingServer.frame_post_draw
	vp.get_texture().get_image().save_png(out_dir.path_join(name))
	print("CAPTURED ", name)

func use_bg(id: String) -> void:
	app.progression.unlocked[id] = true
	app.progression.menu_bg = id

## The coloured "which player am I" ring at the feet is HUD; key art does not need it.
func hide_ground_rings(views: Array) -> void:
	for v in views:
		for c in v.get_children():
			if c is MeshInstance3D and c.mesh is TorusMesh and (c.mesh as TorusMesh).rings == 24:
				c.visible = false

func lineup(list: Array, spacing: float) -> Array:
	var views: Array = []
	for k in range(list.size()):
		var v = FighterView.new()
		app.add_child(v)
		v.setup(Prompt.interpret(prompts[list[k][0]], k))
		views.append(v)
	hide_ground_rings(views)
	return views

func pose(views: Array, list: Array, spacing: float, delta: float) -> void:
	var n: int = views.size()
	for k in range(n):
		var mid: float = (n - 1) * 0.5
		views[k].update_state({"x": (k - mid) * spacing, "y": 0.0, "facing": 1 if k < mid else (-1 if k > mid else 1),
			"pose": list[k][1], "state": "Attack", "blocking": false}, delta)
		views[k].position.z = -0.7 * absf(k - mid)

const LOGO_FONT := preload("res://assets/fonts/RussoOne-Regular.ttf")

## Key art only (marketing art, not a screenshot): hides the centre mandala, traps, breakables and items
## so the fighters carry the picture. Screenshots keep everything as it is in the game.
func hide_set_dressing() -> void:
	for n in app.hazard_nodes + app.destructible_nodes + app.item_nodes:
		if is_instance_valid(n): n.visible = false
	var stack: Array = [app]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		stack.append_array(n.get_children())
		if n is MeshInstance3D and n.mesh is CylinderMesh and n.is_inside_tree():
			var r: float = (n.mesh as CylinderMesh).top_radius
			if (is_equal_approx(r, 2.5) or is_equal_approx(r, 1.55)) and absf(n.global_position.y) < 0.05:
				n.visible = false

## Game camera moved SHOT_ZOOM of the way towards what it looks at.
func follow_game_camera(cam: Camera3D) -> void:
	cam.fov = app.camera.fov
	cam.global_transform = app.camera.global_transform
	var to_target: Vector3 = app.camera_look - app.camera.global_position
	cam.global_position += to_target * SHOT_ZOOM

## Removes the "P1 KI" arrows: they are HUD, not part of the scene.
func drop_markers() -> void:
	for mk in app.player_markers: mk.queue_free()
	app.player_markers.clear()

func render_icon() -> void:
	var ivp := SubViewport.new()
	ivp.size = Vector2i(1024, 1024)
	ivp.disable_3d = true
	ivp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(ivp)
	var bg := TextureRect.new()
	var gt := GradientTexture2D.new()
	gt.width = 1024
	gt.height = 1024
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.fill_from = Vector2(0.5, 0.58)
	gt.fill_to = Vector2(1.08, 1.12)
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.38, 1.0])
	g.colors = PackedColorArray([Color("8a2a0c"), Color("2b0f0b"), Color("07080c")])
	gt.gradient = g
	bg.texture = gt
	bg.size = Vector2(1024, 1024)
	ivp.add_child(bg)
	var chrome := [Color("ffffff"), Color("c9d3e2"), Color("3b4455")]
	var fire := [Color("fff4c2"), Color("ffb020"), Color("9a1c0c")]
	var p: Label = app._logo_line("P", LOGO_FONT, 560, chrome, Color("7dd3fc"), 0.0)
	var f: Label = app._logo_line("F", LOGO_FONT, 560, fire, Color("ff6a1a"), 0.35)
	ivp.add_child(p)
	ivp.add_child(f)
	await frames(3)
	p.size = p.get_combined_minimum_size()
	f.size = f.get_combined_minimum_size()
	p.position = Vector2(512 - p.size.x * 0.86, 512 - p.size.y * 0.62)
	f.position = Vector2(512 - f.size.x * 0.16, 512 - f.size.y * 0.40)
	await frames(5)
	await save(ivp, "icon_face.png")
	ivp.queue_free()

func run() -> void:
	app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await frames(5)
	for p in app.mk_presets: prompts[p.id] = p.prompt
	# Arena from the title screen, without the title line-up.
	use_bg(bg_id)
	app.show_title("splash")
	await frames(20)
	app._title_clear_showcase()
	await frames(2)
	hide_set_dressing()

	# ── Key art, wide ──
	var views: Array = lineup(LINEUP, 1.7)
	var vp := world_viewport(Vector2i(3840, 2160))
	var cam: Camera3D = vp.get_child(0)
	cam.fov = 38.0
	for n in range(70):
		pose(views, LINEUP, 1.7, 1.0 / 60.0)
		cam.position = Vector3(0.0, 1.55, 7.4)
		cam.look_at(Vector3(0.0, 0.45, 0.0))  # fighters in the upper part, floor below for the logo
		if n == 50:
			for k in range(3):
				app.spark_burst(Vector3(-1.7 + k * 1.7, 1.4, 0.4), [Color("ff8a1f"), Color("ff5a1f"), Color("e41e20")][k], 40, 4.0, 0.08)
		await process_frame
	await save(vp, "keyart_wide.png")
	vp.queue_free()
	for v in views: v.queue_free()

	# ── Key art, tall ──
	views = lineup(TALL, 1.25)
	vp = world_viewport(Vector2i(2160, 2700))
	cam = vp.get_child(0)
	cam.fov = 42.0
	for n in range(70):
		pose(views, TALL, 1.25, 1.0 / 60.0)
		cam.position = Vector3(0.0, 1.5, 5.6)
		cam.look_at(Vector3(0.0, 0.7, 0.0))
		await process_frame
	await save(vp, "keyart_tall.png")
	vp.queue_free()
	for v in views: v.queue_free()

	# ── App icon: the logo's own lettering as a "PF" monogram on an ember glow ──
	# (a character close-up does not read at 48 px; the monogram does, and matches the logo)
	await render_icon()

	# ── Logo on a transparent background ──
	var lvp := SubViewport.new()
	lvp.size = Vector2i(2400, 1350)
	lvp.transparent_bg = true
	lvp.disable_3d = true
	lvp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(lvp)
	var logo: Control = app._make_logo()
	# Store capsules carry the game name only: drop the tagline badge (last row of the logo).
	logo.get_child(logo.get_child_count() - 1).visible = false
	lvp.add_child(logo)
	await frames(3)
	logo.size = logo.get_combined_minimum_size()
	logo.scale = Vector2.ONE * minf(2200.0 / logo.size.x, 1250.0 / logo.size.y)
	logo.position = (Vector2(lvp.size) - logo.size * logo.scale) * 0.5
	await frames(5)
	await save(lvp, "logo.png")
	lvp.queue_free()

	# ── Fight screenshots, no HUD ──
	app.hide_title()
	vp = world_viewport(Vector2i(1920, 1080))
	cam = vp.get_child(0)
	for k in range(FIGHTS.size()):
		var fight: Array = FIGHTS[k]
		var arena: String = "bg_" + str(fight[2])
		app.begin_match([Prompt.interpret(prompts[fight[0]], 0), Prompt.interpret(prompts[fight[1]], 1)], "autonomous", 3)
		drop_markers()
		if app.ARENAS.has(arena): app.apply_arena(arena)
		app.sim.countdown = 0.0
		app.sim.fighters[0].x = -1.6
		app.sim.fighters[1].x = 1.6
		await frames(150)
		app.sim.fighters[0].cooldowns = [0.0, 0.0]
		app.sim.queue_attack(0, true)
		for n in range(16):
			follow_game_camera(cam)
			await process_frame
		await save(vp, "shot_%02d.png" % (k + 1))
	# Four-player brawl.
	app.begin_match([Prompt.interpret(prompts["kairo"], 0), Prompt.interpret(prompts["shira"], 1),
		Prompt.interpret(prompts["mutant_titan"], 2), Prompt.interpret(prompts["lepora"], 3)], "autonomous", 3)
	drop_markers()
	if app.ARENAS.has("bg_arena_sun"): app.apply_arena("bg_arena_sun")
	app.sim.countdown = 0.0
	for n in range(260):
		follow_game_camera(cam)
		await process_frame
	await save(vp, "shot_%02d.png" % (FIGHTS.size() + 1))
	# Finisher: Arbër's eagle flight.
	app.begin_match([Prompt.interpret(prompts["arber"], 0), Prompt.interpret(prompts["vampire_lord"], 1)], "autonomous", 3)
	drop_markers()
	if app.ARENAS.has("bg_jungle_ruins"): app.apply_arena("bg_jungle_ruins")
	app.sim.countdown = 0.0
	await frames(20)
	var fin: Dictionary = Combat.finisher_for(app.sim.fighters[0].profile)
	var w: Dictionary = app.sim.fighters[0]
	var l: Dictionary = app.sim.fighters[1]
	app.sim.projectiles.clear()
	w.x = -1.2
	w.facing = 1
	w.pending = {}
	w.state = "Ready"
	l.x = 1.0
	l.state = "Dazed"
	l.pose = "Dazed"
	app.sim.result = 0
	await frames(10)
	app.play_finisher(0, 1, fin.kind, fin.name, fin.variant)
	for n in range(80):
		follow_game_camera(cam)
		await process_frame
	await save(vp, "shot_%02d.png" % (FIGHTS.size() + 2))
	quit()

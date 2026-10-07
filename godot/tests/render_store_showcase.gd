extends SceneTree
## Renders the complete, updated 8-screenshot set for Steam and Google Play.
## Usage: godot --path godot --script res://tests/render_store_showcase.gd -- --out=<dir>

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")
const Bosses = preload("res://scripts/bosses.gd")

var out_dir := "store/raw"
var app: Node = null
var prompts := {}

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
	call_deferred("run")

func frames(n: int) -> void:
	for k in range(n): await process_frame

func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = root.get_viewport().get_texture().get_image()
	img.save_png(out_dir.path_join(name))
	print("STORE_CAPTURED ", name, " (", img.get_width(), "x", img.get_height(), ")")

func drop_markers() -> void:
	if app == null: return
	for mk in app.player_markers:
		if is_instance_valid(mk): mk.queue_free()
	app.player_markers.clear()

func run() -> void:
	app = load("res://main.tscn").instantiate()
	app.capture_selection = true
	root.add_child(app)
	await frames(10)
	for p in app.mk_presets: prompts[p.id] = p.prompt

	# ── Shot 01: The 15x4 Character Selection Roster (58 Fighters) ──
	app.show_selection()
	await frames(45)
	await capture("shot_01.png")

	# ── Shot 07: Fusion Chamber Modal (Prompt + Modular Custom Fighter) ──
	app.open_fusionskammer()
	await frames(35)
	await capture("shot_07.png")
	app.close_fusionskammer()
	await frames(15)

	# ── Shot 02: Astral Obsidian Nexus Clash (Konrad vs Bogdan) ──
	app.hide_title()
	var p_konrad: Dictionary = Prompt.interpret(prompts.get("konrad", "Deutscher Ritter mit Bundesflagge"), 0)
	var p_bogdan: Dictionary = Prompt.interpret(prompts.get("bogdan", "Russischer Koloss mit Trikolore"), 1)
	app.begin_match([p_konrad, p_bogdan], "autonomous", 3)
	drop_markers()
	if app.ARENAS.has("astral_nexus"): app.apply_arena("astral_nexus")
	app.sim.countdown = 0.0
	app.sim.fighters[0].x = -1.8
	app.sim.fighters[1].x = 1.8
	for n in range(120):
		drop_markers()
		await process_frame
	app.sim.queue_attack(0, true)
	await frames(18)
	await capture("shot_02.png")

	# ── Shot 03: Concept-Art-Trio Clash (Kalyx vs Vorruk) on Blood Moon ──
	var p_kalyx: Dictionary = Prompt.interpret(prompts.get("kalyx", "Kristallkronen Wächterin Frost und Glut"), 0)
	var p_vorruk: Dictionary = Prompt.interpret(prompts.get("vorruk", "Sternenkoloss Vorruk"), 1)
	app.begin_match([p_kalyx, p_vorruk], "autonomous", 3)
	drop_markers()
	if app.ARENAS.has("bg_blood_moon"): app.apply_arena("bg_blood_moon")
	elif app.ARENAS.has("blood_moon"): app.apply_arena("blood_moon")
	app.sim.countdown = 0.0
	app.sim.fighters[0].x = -1.6
	app.sim.fighters[1].x = 1.6
	for n in range(110):
		drop_markers()
		await process_frame
	app.sim.queue_attack(1, true)
	await frames(20)
	await capture("shot_03.png")

	# ── Shot 04: 4-Player Chaos Brawl on Sun Arena ──
	var b_f1: Dictionary = Prompt.interpret(prompts.get("kairo", "Sturmmönch"), 0)
	var b_f2: Dictionary = Prompt.interpret(prompts.get("shira", "Schattenassassine"), 1)
	var b_f3: Dictionary = Prompt.interpret(prompts.get("mutant_titan", "Mutant"), 2)
	var b_f4: Dictionary = Prompt.interpret(prompts.get("lepora", "Klingenläufer"), 3)
	app.begin_match([b_f1, b_f2, b_f3, b_f4], "autonomous", 3)
	drop_markers()
	if app.ARENAS.has("bg_arena_sun"): app.apply_arena("bg_arena_sun")
	app.sim.countdown = 0.0
	for n in range(200):
		drop_markers()
		await process_frame
	await capture("shot_04.png")

	# ── Shot 05: Cinematic Finisher (Arbër Shqiponja Adlerflug) ──
	var f_arber: Dictionary = Prompt.interpret(prompts.get("arber", "Adlerkrieger"), 0)
	var f_victim: Dictionary = Prompt.interpret(prompts.get("vampire_lord", "Vampir"), 1)
	app.begin_match([f_arber, f_victim], "autonomous", 3)
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
	for n in range(75):
		drop_markers()
		await process_frame
	await capture("shot_05.png")

	# ── Shot 06: Dante Underworld Boss Battle ──
	if Bosses.ORDER.size() > 0:
		var boss_id: String = str(Bosses.ORDER[mini(2, Bosses.ORDER.size() - 1)])
		app.start_boss(boss_id, false)
		app.sim.mode = "autonomous"
		for n in range(160):
			drop_markers()
			await process_frame
		await capture("shot_06.png")

	# ── Shot 08: 60 FPS AAA Shield Clash Splash ──
	var splash_path := "res://splash_1280x720.png"
	if ResourceLoader.exists(splash_path):
		var sp_img: Image = (load(splash_path) as Texture2D).get_image()
		sp_img.resize(1920, 1080, Image.INTERPOLATE_LANCZOS)
		sp_img.save_png(out_dir.path_join("shot_08.png"))
		print("STORE_CAPTURED shot_08.png (1920x1080)")

	print("ALL_STORE_SHOTS_RENDERED_SUCCESSFULLY")
	quit()

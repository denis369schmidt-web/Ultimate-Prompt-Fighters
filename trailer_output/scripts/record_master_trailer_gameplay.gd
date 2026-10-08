extends SceneTree
## Master Gameplay Capture Script for Steam & Google Play AAA Trailers.
## Records authentic, uncompressed 60 FPS raw gameplay with stereo audio.
## Total duration: ~50 seconds (~3000 frames) covering:
##   1. Instant Hook: High-impact 1v1 Smash on Astral Nexus (0-6s)
##   2. Dynamic Combos & Parries: Ninja vs Golem (6-16s)
##   3. 4-Player Chaos Brawl on Sun Arena (16-26s)
##   4. 15x4 Roster & Character Selection Screen (26-32s)
##   5. The Fusion Chamber modular builder (32-37s)
##   6. Colossal Boss Fight: Dante Infernus (37-45s)
##   7. Cinematic Finisher Execution & K.O. (45-50s)

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")
const Bosses = preload("res://scripts/bosses.gd")

var app: Node = null
var presets := {}

func _initialize() -> void:
	call_deferred("run")

func frames(n: int) -> void:
	for k in range(n):
		if app != null and not app.player_markers.is_empty():
			drop_markers()
		await process_frame

func drop_markers() -> void:
	if app == null: return
	for mk in app.player_markers:
		if is_instance_valid(mk): mk.queue_free()
	app.player_markers.clear()

func run() -> void:
	print("MASTER_CAPTURE: Initializing engine...")
	app = load("res://main.tscn").instantiate()
	app.capture_selection = true
	root.add_child(app)
	await frames(15)
	
	for p in app.mk_presets:
		presets[p.id] = p.prompt
		
	# ── SCENE 1: INSTANT HOOK - ASTRAL NEXUS 1v1 (360 frames = 6.0s) ──
	print("MASTER_CAPTURE: Scene 1 - Instant Hook Astral Nexus")
	var p_konrad: Dictionary = Prompt.interpret(presets.get("konrad", "Deutscher Ritter mit Bundesflagge"), 0)
	var p_bogdan: Dictionary = Prompt.interpret(presets.get("bogdan", "Russischer Koloss mit Trikolore"), 1)
	app.begin_match([p_konrad, p_bogdan], "autonomous", 3)
	drop_markers()
	if app.ARENAS.has("astral_nexus"): app.apply_arena("astral_nexus")
	app.sim.countdown = 0.0
	app.sim.fighters[0].x = -1.5
	app.sim.fighters[1].x = 1.5
	for n in range(360):
		drop_markers()
		if n == 20: app.sim.queue_attack(0, false)
		if n == 60: app.sim.queue_attack(1, true)
		if n == 120: app.sim.queue_attack(0, true)
		if n == 200: app.sim.queue_attack(1, false)
		if n == 280: app.sim.queue_attack(0, true)
		await process_frame

	# ── SCENE 2: NINJA VS GOLEM - COMBOS & SPECIALS (600 frames = 10.0s) ──
	print("MASTER_CAPTURE: Scene 2 - Ninja vs Golem Volcano Battle")
	var p_ninja: Dictionary = Prompt.interpret("Cyber Lightning Ninja", 0)
	var p_golem: Dictionary = Prompt.interpret("Molten Magma Golem", 1)
	app.begin_match([p_ninja, p_golem], "autonomous", 3)
	drop_markers()
	if app.ARENAS.has("volcano"): app.apply_arena("volcano")
	elif app.ARENAS.has("blood_moon"): app.apply_arena("blood_moon")
	app.sim.countdown = 0.0
	for n in range(600):
		drop_markers()
		if n % 45 == 0:
			app.sim.queue_attack(n % 2, (n % 90 == 0))
		await process_frame

	# ── SCENE 3: 4-PLAYER CHAOS BRAWL (600 frames = 10.0s) ──
	print("MASTER_CAPTURE: Scene 3 - 4-Player Chaos Brawl")
	var b_f1: Dictionary = Prompt.interpret(presets.get("kalyx", "Kristallkronen Wächterin"), 0)
	var b_f2: Dictionary = Prompt.interpret(presets.get("vorruk", "Sternenkoloss"), 1)
	var b_f3: Dictionary = Prompt.interpret(presets.get("neris", "Kettenhand"), 2)
	var b_f4: Dictionary = Prompt.interpret(presets.get("tobi", "Brawler"), 3)
	app.begin_match([b_f1, b_f2, b_f3, b_f4], "autonomous", 3)
	drop_markers()
	if app.ARENAS.has("bg_arena_sun"): app.apply_arena("bg_arena_sun")
	elif app.ARENAS.has("sun_arena"): app.apply_arena("sun_arena")
	app.sim.countdown = 0.0
	for n in range(600):
		drop_markers()
		if n % 40 == 0:
			app.sim.queue_attack(n % 4, (n % 80 == 0))
		await process_frame

	# ── SCENE 4: 15x4 ROSTER & FIGHTER SELECT (360 frames = 6.0s) ──
	print("MASTER_CAPTURE: Scene 4 - Character Selection Screen")
	# Despawn previous match combatants to prevent floating models/ragdolls behind UI:
	for view in app.fighter_views:
		if is_instance_valid(view): view.queue_free()
	app.fighter_views.clear()
	app.sim.fighters.clear()
	if app.ARENAS.has("astral_nexus"): app.apply_arena("astral_nexus")
	app.show_selection()
	await frames(60)
	if app.has_method("on_mk_fighter_selected"):
		app._on_card_hovered(2)
		await frames(40)
		app.on_mk_fighter_selected(0, 2)
		await frames(40)
		app._on_card_hovered(14)
		await frames(40)
		app.on_mk_fighter_selected(1, 14)
		await frames(180)

	# ── SCENE 5: FUSION CHAMBER CREATOR (300 frames = 5.0s) ──
	print("MASTER_CAPTURE: Scene 5 - Fusion Chamber Creator")
	app.open_fusionskammer()
	await frames(300)
	app.close_fusionskammer()
	await frames(20)

	# ── SCENE 6: MYTHIC BOSS BATTLE: DANTE INFERNUS (480 frames = 8.0s) ──
	print("MASTER_CAPTURE: Scene 6 - Boss Dante Infernus")
	app.start_boss("dante", false)
	drop_markers()
	app.sim.countdown = 0.0
	for n in range(480):
		drop_markers()
		if n % 50 == 0:
			app.sim.queue_attack(0, true)
		await process_frame

	# ── SCENE 7: CINEMATIC FINISHER & K.O. (300 frames = 5.0s) ──
	print("MASTER_CAPTURE: Scene 7 - Arbër Shqiponja Finisher")
	var p_arber: Dictionary = Prompt.interpret(presets.get("arber", "Albanischer Adlerkrieger Arbër"), 0)
	var p_dark: Dictionary = Prompt.interpret("dark armored knight", 1)
	app.begin_match([p_arber, p_dark], "manual", 1)
	drop_markers()
	if app.ARENAS.has("blood_moon"): app.apply_arena("blood_moon")
	app.sim.countdown = 0.0
	await frames(30)
	app.play_finisher(0, 1, "arber", "ADLERFLUG")
	await frames(270)

	print("MASTER_CAPTURE: Full 3000 frames captured successfully!")
	quit(0)

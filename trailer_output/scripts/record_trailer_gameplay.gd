extends SceneTree
## Records a continuous 60 FPS master gameplay showcase for the official trailer.
## Captures:
##   1. 3D Title Screen with Astral Nexus Orbit & Glowing UI
##   2. Character Selection Screen (15x4 Roster Grid, Card Hovers & P1/P2 Picks)
##   3. Fusion Chamber (Modular Custom Fighter Creator)
##   4. Astral Obsidian Nexus 1v1 Battle (Konrad vs Bogdan with Flag Banners & Combos)
##   5. 4-Player Chaos Brawl on Sun Arena
##   6. Mythic Boss Battle vs Dante Infernus (Underworld Lava Arena)
##   7. Cinematic Finisher Climax (Arbër Shqiponja Eagle Execution & K.O.)

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
	print("TRAILER_DIRECTOR: Initializing main engine...")
	app = load("res://main.tscn").instantiate()
	app.capture_selection = true
	root.add_child(app)
	await frames(15)
	
	for p in app.mk_presets:
		presets[p.id] = p.prompt
		
	# ── 1. TITLE SCREEN & 3D ARENA ORBIT (150 frames = 2.5s) ──
	print("TRAILER_DIRECTOR: Scene 1 - 3D Title Screen")
	if app.ARENAS.has("astral_nexus"): app.apply_arena("astral_nexus")
	app.show_title()
	await frames(150)
	
	# ── 2. ROSTER & CHARACTER SELECTION (240 frames = 4.0s) ──
	print("TRAILER_DIRECTOR: Scene 2 - 15x4 Character Selection")
	app.hide_title()
	app.show_selection()
	await frames(45)
	# Simulate cursor hovering and picking Konrad (P1)
	if app.has_method("on_mk_fighter_selected"):
		var k_idx := 0
		for i in range(app.mk_presets.size()):
			if app.mk_presets[i].id == "konrad":
				k_idx = i
				break
		app._on_card_hovered(k_idx)
		await frames(35)
		app.on_mk_fighter_selected(0, k_idx)
		await frames(40)
		# Pick Bogdan (P2)
		var b_idx := 1
		for i in range(app.mk_presets.size()):
			if app.mk_presets[i].id == "bogdan":
				b_idx = i
				break
		app._on_card_hovered(b_idx)
		await frames(35)
		app.on_mk_fighter_selected(1, b_idx)
		await frames(85)
		
	# ── 3. FUSION CHAMBER CREATOR (150 frames = 2.5s) ──
	print("TRAILER_DIRECTOR: Scene 3 - Fusion Chamber")
	app.open_fusionskammer()
	await frames(150)
	app.close_fusionskammer()
	await frames(20)
	
	# ── 4. ASTRAL OBSIDIAN NEXUS 1v1 BATTLE (300 frames = 5.0s) ──
	print("TRAILER_DIRECTOR: Scene 4 - Astral Nexus 1v1 Battle")
	var p_konrad: Dictionary = Prompt.interpret(presets.get("konrad", "Deutscher Ritter mit Bundesflagge"), 0)
	var p_bogdan: Dictionary = Prompt.interpret(presets.get("bogdan", "Russischer Koloss mit Trikolore"), 1)
	app.begin_match([p_konrad, p_bogdan], "autonomous", 3)
	drop_markers()
	if app.ARENAS.has("astral_nexus"): app.apply_arena("astral_nexus")
	app.sim.countdown = 0.0
	app.sim.fighters[0].x = -1.8
	app.sim.fighters[1].x = 1.8
	for n in range(300):
		drop_markers()
		if n == 60: app.sim.queue_attack(0, false)
		if n == 90: app.sim.queue_attack(1, true)
		if n == 150: app.sim.queue_attack(0, true)
		await process_frame
		
	# ── 5. 4-PLAYER CHAOS BRAWL ON SUN ARENA (300 frames = 5.0s) ──
	print("TRAILER_DIRECTOR: Scene 5 - 4-Player Chaos Brawl")
	var b_f1: Dictionary = Prompt.interpret(presets.get("kalyx", "Kristallkronen Wächterin"), 0)
	var b_f2: Dictionary = Prompt.interpret(presets.get("vorruk", "Sternenkoloss"), 1)
	var b_f3: Dictionary = Prompt.interpret(presets.get("neris", "Kettenhand"), 2)
	var b_f4: Dictionary = Prompt.interpret(presets.get("ninja", "Ninja"), 3)
	app.begin_match([b_f1, b_f2, b_f3, b_f4], "autonomous", 3)
	drop_markers()
	if app.ARENAS.has("bg_arena_sun"): app.apply_arena("bg_arena_sun")
	elif app.ARENAS.has("sun_arena"): app.apply_arena("sun_arena")
	app.sim.countdown = 0.0
	for n in range(300):
		drop_markers()
		if n % 45 == 0:
			app.sim.queue_attack(n % 4, (n % 90 == 0))
		await process_frame
		
	# ── 6. MYTHIC BOSS BATTLE: DANTE INFERNUS (300 frames = 5.0s) ──
	print("TRAILER_DIRECTOR: Scene 6 - Boss Dante Infernus")
	app.start_boss("dante", false)
	drop_markers()
	app.sim.countdown = 0.0
	for n in range(300):
		drop_markers()
		if n % 50 == 0:
			app.sim.queue_attack(0, true)
		await process_frame
		
	# ── 7. CINEMATIC FINISHER & K.O. (210 frames = 3.5s) ──
	print("TRAILER_DIRECTOR: Scene 7 - Cinematic Finisher")
	var p_arber: Dictionary = Prompt.interpret(presets.get("arber", "Albanischer Adlerkrieger Arbër"), 0)
	var p_dark: Dictionary = Prompt.interpret("dark armored knight", 1)
	app.begin_match([p_arber, p_dark], "manual", 1)
	drop_markers()
	if app.ARENAS.has("blood_moon"): app.apply_arena("blood_moon")
	app.sim.countdown = 0.0
	await frames(25)
	# Trigger Arbër's iconic Adlerflug finisher
	app.play_finisher(0, 1, "arber", "ADLERFLUG")
	await frames(185)
	
	print("TRAILER_DIRECTOR: All gameplay scenes captured successfully!")
	quit(0)

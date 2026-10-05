extends SceneTree
## Visual check of the fighter kits: for every kit fighter a short AI fight (signature in use)
## and its own finisher cinematic, captured as screenshots.
## Usage: godot --path godot --script res://tests/render_kits.gd -- --out=<dir> [--only=<family>[,<family>…]]

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")
const FighterKits = preload("res://scripts/fighter_kits.gd")

var out_dir := "user://"
var only := ""

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
		if arg.begins_with("--only="): only = arg.trim_prefix("--only=")
	call_deferred("run")

func frames(n: int) -> void:
	for k in range(n): await process_frame

func shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_viewport().get_texture().get_image().save_png(out_dir.path_join(name))
	print("CAPTURED ", name)

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await frames(5)
	app.hide_title() # the live title screen would cover the fight
	var prompts := {}
	for preset in app.mk_presets: prompts[preset.id] = preset.prompt
	for fam in FighterKits.KITS:
		if only != "" and not (fam in only.split(",")): continue
		var p_list := [Prompt.interpret(prompts[fam], 0), Prompt.interpret(prompts["kairo"], 1)]
		app.begin_match(p_list, "autonomous", 3)
		app.sim.countdown = 0.0
		app.sim.fighters[0].x = -2.5
		app.sim.fighters[1].x = 2.5
		await frames(20)
		# Signature right away, then let the AI fight.
		app.sim.queue_attack(0, true)
		await frames(14)
		await shot("kit_%s_1_signature.png" % fam)
		await frames(240)
		await shot("kit_%s_2_fight.png" % fam)
		# Own finisher.
		var fin: Dictionary = Combat.finisher_for(app.sim.fighters[0].profile)
		var w: Dictionary = app.sim.fighters[0]
		var l: Dictionary = app.sim.fighters[1]
		app.sim.projectiles.clear()
		w.x = -1.2
		w.y = 0.0
		w.facing = 1
		w.pending = {}
		w.state = "Ready"
		l.x = 1.0
		l.y = 0.0
		l.state = "Dazed"
		l.pose = "Dazed"
		app.sim.result = 0
		await frames(20)
		app.play_finisher(0, 1, fin.kind, fin.name, fin.variant)
		await frames(75)
		await shot("kit_%s_3_finisher.png" % fam)
		await frames(45)
		await shot("kit_%s_4_finisher.png" % fam)
		var guard := 0
		while app.finisher_running and guard < 900:
			await process_frame
			guard += 1
		print("FINISHER_DONE ", fam, " ", fin.variant, " frames=", guard)
	quit()

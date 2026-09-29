extends "res://tests/test_base.gd"
## Core rule tests on the real GDScript combat code (percent damage + stock rules).

func _initialize() -> void:
	call_deferred("run")

## Moves a fighter past the right blast zone so the next tick costs a stock.
func knock_out(m, index: int) -> void:
	m.fighters[index].x = Combat.BLAST_ZONE_RIGHT + 1.0
	m.fighters[index].is_grounded = false

func press_key(app, keycode: Key) -> void:
	var key := InputEventKey.new()
	key.physical_keycode = keycode
	key.keycode = keycode
	key.pressed = true
	app._unhandled_key_input(key)

func run() -> void:
	# ── Prompt profiles ───────────────────────────────────────────────────────
	var p1: Dictionary = Prompt.interpret("electric ninja", 0)
	var p2: Dictionary = Prompt.interpret("armored lava golem", 1)
	check(p1.family == "ninja" and p2.family == "golem" and p1.prompt != p2.prompt, "independent prompts and skeleton families")
	check(p1 == Prompt.interpret("electric ninja", 0), "deterministic profile")
	check(p1.seed == Prompt.interpret("electric ninja", 1).seed, "same prompt reproducible across player slots")
	var valid := true
	for n in range(1000):
		var prompt: Variant = [null, "", "unbesiegbar unendlich Schaden", "lava golem", "electric ninja", "frost armor", "x".repeat(800)][n % 7]
		var profile := Prompt.interpret(prompt, n % 2)
		valid = valid and Prompt.valid(profile) and profile.prompt.length() <= 512
	check(valid, "1000 profiles: budget, bounds, invalid inputs and module compatibility")

	# ── Attacks ───────────────────────────────────────────────────────────────
	var m = match_ready()
	check(m.queue_attack(0, false), "standard attack accepted")
	check(not m.queue_attack(0, false), "duplicate attack blocked by pending/cooldown")
	run_ticks(m, 40)
	var dealt: float = m.fighters[1].damage_percent
	check(dealt > 0.0 and dealt < 30.0, "single standard hit applied within damage budget (%.1f%%)" % dealt)
	run_ticks(m, 20)
	check(is_equal_approx(m.fighters[1].damage_percent, dealt), "no repeated damage after completed hit")

	m = match_ready()
	m.fighters[1].x = 12.0 # beyond the ninja's teleport reach (9 m)
	m.queue_attack(0, true)
	run_ticks(m, 30)
	check(m.fighters[1].damage_percent == 0.0, "special misses outside range")

	# ── Stocks, win conditions, restart ───────────────────────────────────────
	m = match_ready("electric ninja", "lava golem", 1)
	knock_out(m, 1)
	m.tick(idle_commands())
	check(m.result == 0, "player 1 wins when player 2 loses the last stock")

	m.restart()
	var clean: bool = m.result == -2 and is_equal_approx(m.time_left, Combat.MATCH_TIME)
	for f in m.fighters:
		clean = clean and f.damage_percent == 0.0 and f.lives == 1 and f.pending.is_empty()
	check(clean, "restart resets all combat state and keeps the configured stock count")

	m = match_ready("electric ninja", "lava golem", 3)
	knock_out(m, 0)
	m.tick(idle_commands())
	check(m.fighters[0].lives == 2 and m.result == -2 and m.fighters[0].y > 1.0, "ring-out costs one stock and respawns above the stage")

	m = match_ready("electric ninja", "lava golem", 3)
	knock_out(m, 1)
	m.tick(idle_commands())
	m.restart()
	check(m.fighters[0].lives == 3 and m.fighters[1].lives == 3, "restart after a lost stock restores the full stock count")

	m = match_ready("ninja", "ninja", 1)
	knock_out(m, 0)
	knock_out(m, 1)
	m.tick(idle_commands())
	check(m.result == -1, "simultaneous last-stock KO is a draw")

	m = match_ready()
	m.time_left = Combat.STEP
	m.tick(idle_commands())
	check(m.result == -1, "timeout with equal stocks and percent is a draw")

	m = match_ready()
	m.time_left = Combat.STEP
	m.fighters[1].damage_percent = 50.0
	m.tick(idle_commands())
	check(m.result == 0, "timeout winner has the lower percent")

	m = match_ready()
	m.time_left = Combat.STEP
	m.fighters[0].lives = 2
	m.fighters[1].damage_percent = 80.0
	m.tick(idle_commands())
	check(m.result == 1, "timeout: more stocks beats lower percent")

	# ── Manual and agent control share the same rules ─────────────────────────
	seed(1234)
	var manual = match_ready()
	var agents = match_ready()
	agents.mode = "autonomous"
	for n in range(600):
		var commands: Array = agents.agent_commands()
		manual.tick(commands)
		agents.tick(commands)
	check(manual.fighters == agents.fighters and manual.result == agents.result, "identical commands yield identical rules in both modes")

	# ── Autonomous matches terminate (time limit 99 s = 5 940 ticks + countdown) ─
	var wins := [0, 0, 0]
	var total_hits := 0
	for n in range(30):
		m = match_ready("electric ninja %d" % n, "lava golem %d" % n)
		m.fighters[0].x = -2.4
		m.fighters[1].x = 2.4
		for frame in range(6500):
			m.tick(m.agent_commands())
			for event in m.events:
				if event.type == "hit": total_hits += 1
			if m.result != -2: break
		if m.result >= 0: wins[m.result] += 1
		elif m.result == -1: wins[2] += 1
	check(wins[0] + wins[1] + wins[2] == 30 and total_hits > 0, "30 autonomous matches terminate with real hits")
	print("BALANCE_SAMPLE ", wins, " hits=", total_hits)

	# ── Stage rules ───────────────────────────────────────────────────────────
	m = match_ready()
	run_ticks(m, 300, [cmd({"move": -1.0}), cmd({"move": 1.0})])
	var on_stage: bool = m.fighters[0].x >= Combat.STAGE_LEFT and m.fighters[1].x <= Combat.STAGE_RIGHT
	check(on_stage and m.fighters[0].is_grounded and m.fighters[1].is_grounded and m.fighters[0].lives == 3,
		"walking stops at the stage edge instead of falling off")

	m = match_ready()
	run_ticks(m, 120, [cmd({"move": 1.0}), cmd({"move": -1.0})])
	var gap: float = m.fighters[1].x - m.fighters[0].x
	check(gap >= Combat.BODY_SEPARATION * 0.8, "grounded fighters do not walk through each other (gap %.2f)" % gap)

	# ── Imported models of the original four skeleton families ────────────────
	for family in ["ninja", "golem", "valkyrie", "dragon"]:
		var scene = load("res://assets/models/%s.glb" % family).instantiate()
		root.add_child(scene)
		var rigs: Array = scene.find_children("*", "Skeleton3D", true, false)
		var players: Array = scene.find_children("*", "AnimationPlayer", true, false)
		check(rigs.size() == 1 and rigs[0].get_bone_count() == 18, family + " imported 18-bone skeleton")
		var clips: Array = []
		if not players.is_empty(): clips.assign(players[0].get_animation_list())
		check(clips.size() >= 7, family + " imported animation clips " + str(clips))
		scene.queue_free()

	# ── Real main scene: input routing and UI routes ──────────────────────────
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.start_round("manual")
	app.sim.countdown = 0
	Input.action_press("p1_right")
	var routed: Array = app.manual_commands()
	check(routed[0].move == 1 and routed[1].move == 0, "P1 movement input is isolated")
	Input.action_release("p1_right")
	Input.action_press("p2_left")
	routed = app.manual_commands()
	check(routed[0].move == 0 and routed[1].move == -1, "P2 movement input is isolated")
	Input.action_release("p2_left")
	for spec in [[KEY_F, 0, "standard"], [KEY_G, 0, "special"], [KEY_K, 1, "standard"], [KEY_L, 1, "special"]]:
		app.clear_input_buffer()
		press_key(app, spec[0])
		routed = app.manual_commands()
		check(routed[spec[1]][spec[2]] and not routed[1 - spec[1]][spec[2]], "attack key isolated: " + OS.get_keycode_string(spec[0]))

	# Input buffer: a press survives a few ticks until executed, then is consumed exactly once.
	app.clear_input_buffer()
	press_key(app, KEY_F)
	var still_buffered := true
	for n in range(app.INPUT_BUFFER_FRAMES):
		still_buffered = still_buffered and app.manual_commands()[0].standard
	check(still_buffered, "press stays buffered for %d ticks" % app.INPUT_BUFFER_FRAMES)
	check(not app.manual_commands()[0].standard, "buffered press expires afterwards")
	app.clear_input_buffer()
	press_key(app, KEY_F)
	app.manual_commands()
	app.consume_input_buffer([{"type": "attack", "actor": 0, "special": false}])
	check(not app.manual_commands()[0].standard, "executed press is consumed and does not repeat")
	app.clear_input_buffer()
	Input.action_press("p1_block")
	press_key(app, KEY_W)
	routed = app.manual_commands()
	Input.action_release("p1_block")
	check(routed[0].block and routed[0].jump, "block+jump reaches the simulation (platform drop-through)")
	app.clear_input_buffer()
	app.show_selection()
	check(not app.active and app.selection.visible, "return to prompt selection")
	app.start_round("autonomous")
	check(app.active and not app.selection.visible and app.sim.mode == "autonomous", "agent start button route")
	app.restart_round()
	check(app.sim.elapsed == 0 and app.sim.countdown > 0, "UI restart route")
	app.queue_free()
	await process_frame

	var report := {"engine": Engine.get_version_info().string, "passed": passed, "failed": failed,
		"balance_sample": wins, "sample_hits": total_hits, "tests": results}
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--report="):
			var file := FileAccess.open(arg.trim_prefix("--report="), FileAccess.WRITE)
			if file: file.store_string(JSON.stringify(report, "  "))
	finish("game")

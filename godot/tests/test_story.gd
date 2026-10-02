extends "res://tests/test_base.gd"
## Story mode: content integrity, quick-time event rules, a full playthrough of every
## chapter on the real main scene, and team fights on the real combat code.

const StoryData = preload("res://scripts/story_data.gd")
const StoryMode = preload("res://scripts/story_mode.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var story = app.story
	story.persist = false
	story.completed = 0
	story.flags = {}
	story.set_campaign("zeile")

	test_data(app)
	test_qte(story)
	test_teams()
	await test_team_fight(app)
	await test_playthrough(app, story)
	await test_defeat_screen(app, story)

	app.queue_free()
	await process_frame
	finish("story")

func walk_steps(steps: Array, out: Array) -> void:
	for s in steps:
		out.append(s)
		walk_steps(s.get("success", []), out)
		walk_steps(s.get("fail", []), out)

func test_data(app) -> void:
	for id in StoryData.CAST:
		var c: Dictionary = StoryData.CAST[id]
		if c.prompt.is_empty(): continue
		var p: Dictionary = StoryMode.cast_profile(id, 0)
		check(Prompt.valid(p) and p.name == c.name, "story fighter %s is a valid fighter (%s)" % [id, p.family])
	check(StoryMode.cast_profile("volt", 0).family == "ninja" and StoryMode.cast_profile("nulla", 1).family == "specter"
		and StoryMode.cast_profile("aura", 1).family == "valkyrie" and StoryMode.cast_profile("korsar", 1).family == "pirate_captain",
		"story prompts resolve to the intended fighter models")
	check(StoryData.chapter_count() == 8, "story has 8 chapters")
	var ok := true
	var fights := 0
	var qtes := 0
	for ch in StoryData.CHAPTERS:
		ok = ok and app.ARENAS.has(ch.arena)
		var all: Array = []
		walk_steps(ch.steps, all)
		var stage_size := 0
		for s in all:
			match s.t:
				"stage":
					stage_size = s.cast.size()
					for c in s.cast: ok = ok and StoryData.CAST.has(c.id)
				"say":
					ok = ok and StoryData.CAST.has(s.who)
				"move", "pose", "vanish", "appear":
					ok = ok and int(s.who) < stage_size
				"qte":
					qtes += 1
					for k in s["keys"]: ok = ok and k in StoryMode.QTE_ACTIONS
				"fight":
					fights += 1
					for id in s.cast: ok = ok and StoryData.CAST.has(id)
					ok = ok and s.get("lives", []).size() in [0, s.cast.size()]
					ok = ok and s.get("teams", []).size() in [0, s.cast.size()]
		if not ok: print("  invalid chapter: ", ch.id)
	check(ok, "every chapter references existing arenas, cast members, stage slots and QTE keys")
	check(fights >= 8 and qtes >= 6, "story has %d fights and %d quick-time events" % [fights, qtes])

func test_qte(story) -> void:
	var result := [null]
	var cb := func(s: bool): result[0] = s
	story.qte_finished.connect(cb)

	story.begin_qte({"kind": "press", "keys": ["jump"], "time": 1.0})
	story.qte_press("jump")
	check(result[0] == true and not story.qte_active, "press QTE: correct key succeeds")

	result[0] = null
	story.begin_qte({"kind": "press", "keys": ["jump"], "time": 1.0})
	story.qte_press("grab")
	check(result[0] == false, "press QTE: wrong key fails")

	result[0] = null
	story.begin_qte({"kind": "press", "keys": ["jump"], "time": 0.5})
	for n in range(40): story.qte_tick(1.0 / 60.0)
	check(result[0] == false, "press QTE: running out of time fails")

	result[0] = null
	story.begin_qte({"kind": "mash", "keys": ["standard"], "count": 5, "time": 2.0})
	story.qte_press("grab") # wrong keys do not fail a mash, they just don't count
	for n in range(4): story.qte_press("standard")
	check(result[0] == null and story.qte_active, "mash QTE: not done before the count is reached")
	story.qte_press("standard")
	check(result[0] == true, "mash QTE: reaching the count succeeds")

	result[0] = null
	story.begin_qte({"kind": "sequence", "keys": ["standard", "special", "grab"], "time": 1.0})
	story.qte_press("standard")
	for n in range(40): story.qte_tick(1.0 / 60.0) # each key gets its own window
	story.qte_press("special")
	story.qte_press("grab")
	check(result[0] == true, "sequence QTE: keys in order succeed, each with its own time window")

	result[0] = null
	story.begin_qte({"kind": "sequence", "keys": ["standard", "special"], "time": 1.0})
	story.qte_press("special")
	check(result[0] == false, "sequence QTE: wrong order fails")
	story.qte_finished.disconnect(cb)

func test_teams() -> void:
	var m = Combat.new()
	m.start([Prompt.interpret("electric ninja", 0), Prompt.interpret("lava golem", 1), Prompt.interpret("Steel Knight Ritter", 2)], "manual")
	m.countdown = 0.0
	m.set_teams([0, 0, 1])
	for k in range(3):
		m.fighters[k].y = 0.0
		m.fighters[k].is_grounded = true
	m.fighters[0].x = 0.0
	m.fighters[0].facing = 1
	m.fighters[1].x = 1.0
	m.fighters[2].x = -6.0
	m.queue_attack(0, false)
	for n in range(30): m.tick(idle_commands(3))
	check(m.fighters[1].damage_percent == 0.0, "attacks never hit a teammate")
	check(m.get_nearest_opponent(0) == 2, "fighters target only the other team")
	m.fighters[2].lives = 1
	m.fighters[2].x = Combat.BLAST_ZONE_LEFT - 1.0
	m.fighters[2].is_grounded = false
	m.tick(idle_commands(3))
	check(m.result >= 0 and m.fighters[m.result].team == 0, "the last team standing wins")

func test_team_fight(app) -> void:
	# Chapter 5's 2v2 on the real simulation, played out by the agents.
	var step: Dictionary = {}
	for s in StoryData.CHAPTERS[4].steps:
		if s.t == "fight": step = s
	app.story.chapter_index = 4
	app.story._start_fight(step)
	app.story.in_fight = false
	var sim = app.sim
	check(sim.fighters.size() == 4 and sim.fighters[0].team == sim.fighters[2].team and sim.fighters[1].team == sim.fighters[3].team,
		"story 2v2 fight sets up both teams")
	check(sim.fighters[3].lives == 1 and sim.fighters[1].lives == 2, "story fight applies per-fighter stocks")
	sim.countdown = 0.0
	for n in range(7000):
		sim.tick(sim.agent_commands())
		if sim.result != -2: break
	check(sim.result != -2, "a 2v2 story fight between agents ends (result %d)" % sim.result)
	app.active = false

func test_playthrough(app, story) -> void:
	story.auto_advance = true
	story.auto_qte_success = true
	for k in range(StoryData.chapter_count()):
		story.start_chapter(k)
		var frames := 0
		var fights := 0
		while story.running and frames < 3000:
			await process_frame
			frames += 1
			if story.in_fight:
				fights += 1
				story.on_fight_finished(0) # player 1 (team 0) wins
		check(not story.running and story.completed >= k + 1 and fights > 0,
			"chapter %d plays through (%d fights, %d frames)" % [k + 1, fights, frames])
	check(story.completed == StoryData.chapter_count() and not app.cinematic and app.selection.visible,
		"after the finale the game returns to the selection screen")
	check(story.flags.get("ch1_lance", false) == true, "QTE results are stored as story flags")

func test_defeat_screen(app, story) -> void:
	story.auto_advance = false
	story.start_chapter(0)
	story.skipping = true # fast-forward the cutscene to the first fight
	var frames := 0
	while not story.in_fight and frames < 600:
		await process_frame
		frames += 1
		if not story.in_fight: story.skipping = true
	check(story.in_fight and app.active and app.sim.fighters.size() == 2, "skipping a cutscene jumps to the fight")
	check(app.sim.fighters[1].lives == 2, "chapter 1 enemy has 2 stocks")
	story.on_fight_finished(1)
	await process_frame
	await process_frame
	check(story.result_box.visible and story.result_title.text == "NIEDERLAGE", "losing shows the defeat screen with retry")
	story._retry_choice = 1
	await process_frame
	await process_frame
	check(story.in_fight and app.sim.result == -2, "retry restarts the same fight")
	story.abort()
	await process_frame
	check(not story.running and app.selection.visible, "aborting returns to the selection screen")

extends "res://tests/test_base.gd"
## Adventure mode: waves, difficulty, bosses, healing, score, records – rules and the main scene.

const Adventure = preload("res://scripts/adventure.gd")
const Progression = preload("res://scripts/progression.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	test_rules()
	await test_main()
	finish("adventure")

func roster() -> Array:
	return [{"id": "arber", "name": "ARBËR", "prompt": "Arbër der Bohrmeister"}, {"id": "zip", "name": "ZIP", "prompt": "Zip der Blitzkurier mit Turbo-Sprint"},
		{"id": "kairo", "name": "KAIRO", "prompt": "Kairo der Sturmmönch mit Solar-Kanone"}, {"id": "fusionskammer", "name": "F", "prompt": "x"}]

func test_rules() -> void:
	var a := Adventure.new()
	a.start(roster()[0], roster(), 3)
	check(a.running and a.wave == 1 and a.score == 0, "a run starts at wave 1 with no score")
	var ids: Array = a.pool.map(func(p): return p.id)
	check(not "arber" in ids and not "fusionskammer" in ids, "you never fight yourself (or the fusion card)")
	var last := ""
	var repeat := false
	for n in range(20):
		var o: Dictionary = a.next_opponent()
		if o.id == last: repeat = true
		last = o.id
	check(not repeat, "the same opponent never comes twice in a row")
	check(a.ai_level(1) < a.ai_level(9) and a.ai_level(60) == Adventure.MAX_AI, "the AI gets smarter every other wave, up to the top level")
	check(a.power_mult(10) > a.power_mult(1) and a.kb_taken_mult(10) < a.kb_taken_mult(1) and a.kb_taken_mult(99) >= 0.55, "opponents hit harder and fly less, within limits")
	check(not a.is_boss_wave(4) and a.is_boss_wave(5) and a.is_boss_wave(10), "every fifth wave is a boss")
	check(a.boss_for(5) == "angelus" and a.boss_for(10) == "ahriman" and a.boss_for(15) == "michael", "bosses alternate heaven and hell, in order")
	var g1: int = a.win_wave(60.0, 80.0, 4)
	check(a.wave == 2 and a.score == g1 and g1 > 100, "a won wave scores and moves on (+%d)" % g1)
	check(absf(a.damage - 80.0 * (1.0 - Adventure.HEAL_SHARE)) < 0.01, "only part of the damage heals (%.0f %% left)" % a.damage)
	a.wave = 5
	var gb: int = a.win_wave(30.0, 50.0, 0)
	check(gb >= 1000 and a.bosses == 1, "a boss wave is worth a lot more (+%d)" % gb)
	var prog := Progression.new()
	prog.persist = false
	var best: bool = a.finish(prog)
	check(best and not a.running, "the first run is a record")
	var rec: Dictionary = Adventure.record_of(prog, "arber")
	check(int(rec.wave) == 5 and int(rec.score) == a.score and int(rec.runs) == 1, "the record keeps waves, score and runs (%s)" % rec)
	check(int(prog.adventure_best.score) == a.score and prog.adventure_best.family == "arber", "the overall best run is kept")
	var b := Adventure.new()
	b.start(roster()[0], roster(), 4)
	b.win_wave(10.0, 0.0, 0)
	check(not b.finish(prog) and int(Adventure.record_of(prog, "arber").runs) == 2, "a worse run is no record but counts as a run")
	check(Adventure.leaderboard(prog).size() == 1 and Adventure.leaderboard(prog)[0].family == "arber", "the leaderboard lists fighters by score")

func test_main() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.progression.persist = false
	app.show_title("menu")
	check(app.Backgrounds.MENU_ITEMS.has("adventure"), "ABENTEUER is in the main menu")
	app._title_activate(app.Backgrounds.MENU_ITEMS.find("adventure"))
	check(app.title_panel_kind == "adventure", "ABENTEUER opens the fighter choice with the records")
	var preset: Dictionary = {}
	for p in app.mk_presets: if p.id == "arber": preset = p
	app.start_adventure(preset)
	check(app.adventure != null and app.active and not app.title_screen.visible, "picking a fighter starts wave 1")
	check(app.sim.fighters.size() == 2 and app.sim.fighters[0].profile.family == "arber" and app.sim.mode == "pve", "you fight one computer opponent with your fighter")
	check(app.sim.ai_level == app.adventure.ai_level(1), "wave 1 uses the easy AI")
	# Win wave 1 by knocking the opponent out.
	app.sim.countdown = 0.0
	app.sim.fighters[1].lives = 0
	app.sim.fighters[1].state = "Defeated"
	app.sim.result = 0
	app._adventure_finished()
	check(app.adventure.wave == 2 and app.adventure.score > 0 and app.result_label.text.contains("WELLE 1 GESCHAFFT"), "a won wave shows the score and leads on")
	app.sim.fighters[0].damage_percent = 0.0
	app._adventure_continue()
	check(app.adventure.wave == 2 and app.sim.ai_level == app.adventure.ai_level(2) and float(app.sim.fighters[1].power_mult) > 1.0, "wave 2 is a little harder")
	check(app.status.text.contains("WELLE 2"), "the status line shows the wave")
	app.restart_round()
	check(app.adventure.wave == 2, "no retries inside a run")
	# Jump to a boss wave.
	app.adventure.wave = 5
	app._adventure_wave()
	var has_boss := false
	for f in app.sim.fighters: if f.is_boss: has_boss = true
	check(has_boss and app.boss_active, "wave 5 is a boss fight")
	# Lose: the run ends and the record is kept.
	app.sim.result = 1
	app._adventure_finished()
	check(not app.adventure.running and app.result_label.text.contains("ABENTEUER VORBEI"), "a lost wave ends the run")
	check(int(app.Adventure.record_of(app.progression, "arber").wave) == 4, "the record keeps the waves cleared")
	app._adventure_continue()
	check(app.adventure.running and app.adventure.wave == 1 and not app.boss_active, "NEUER LAUF starts over at wave 1")
	app._adventure_quit()
	check(app.adventure == null and app.title_screen.visible, "leaving returns to the main menu")
	app.queue_free()
	await process_frame

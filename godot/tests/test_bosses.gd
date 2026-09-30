extends "res://tests/test_base.gd"
## Team modes (2 vs 2, 3 vs 1) and the angel bosses – combat core and the main scene flow.

const Bosses = preload("res://scripts/bosses.gd")
const HERO_A := "Blitzschneller Schattenninja mit elektrischen Klingen"
const HERO_B := "Gepanzerter Lavagolem mit brennenden Fäusten"
const HERO_C := "Kairo der Sturmmönch mit Solar-Kanone"
const HERO_D := "Albion der Silberwyrm mit Sturmstrahl"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	test_team_friendly_fire()
	for bid in Bosses.ORDER:
		test_boss_core(bid)
	test_boss_phase_and_defeat()
	test_boss_wins()
	test_ai_heroes_fight_boss()
	await test_main_flow()
	finish("bosses")

func boss_match(bid: String, heroes: Array = [HERO_A, HERO_B]):
	var list: Array = []
	for k in range(heroes.size()): list.append(Prompt.interpret(heroes[k], k))
	list.append(Bosses.profile(bid, heroes.size()))
	var m = Combat.new()
	m.start(list, null, "manual", 3)
	var teams: Array = []
	for f in m.fighters: teams.append(9 if f.is_boss else 0)
	m.set_teams(teams)
	m.countdown = 0.0
	m.time_left = 300.0
	return m

func test_team_friendly_fire() -> void:
	var m = Combat.new()
	m.start([Prompt.interpret(HERO_A, 0), Prompt.interpret(HERO_B, 1), Prompt.interpret(HERO_C, 2), Prompt.interpret(HERO_D, 3)], null, "manual", 3)
	m.set_teams([0, 0, 1, 1])
	m.countdown = 0.0
	for k in range(4):
		m.fighters[k].x = [-1.0, 0.0, 6.0, 8.0][k]
		m.fighters[k].facing = 1
	m.queue_attack(0, false)
	run_ticks(m, 30, [cmd(), cmd(), cmd(), cmd()])
	check(m.fighters[1].damage_percent == 0.0, "2 vs 2: teammates do not hurt each other")
	m.fighters[2].x = 0.2
	m.fighters[1].x = 5.0
	m.fighters[0].cooldowns = [0.0, 0.0]
	m.fighters[0].facing = 1
	m.queue_attack(0, false)
	run_ticks(m, 30, [cmd(), cmd(), cmd(), cmd()])
	check(m.fighters[2].damage_percent > 0.0, "2 vs 2: opponents are hit")

func test_boss_core(bid: String) -> void:
	var m = boss_match(bid)
	var boss: Dictionary = m.fighters[2]
	check(boss.is_boss and boss.boss_hp > 0.0 and boss.body_h >= 2.9, "%s is a boss with a health bar" % bid)
	var more = boss_match(bid, [HERO_A, HERO_B, HERO_C])
	check(more.fighters[3].boss_max > boss.boss_max, "%s: more heroes → more boss health" % bid)
	run_ticks(m, 30, [cmd(), cmd(), cmd()])
	check(boss.y >= float(Bosses.data(bid).hover) - 0.3, "%s floats at its height" % bid)
	# Heroes hit the boss: health drops, the boss is not launched.
	var h: Dictionary = m.fighters[0]
	h.x = boss.x - 1.6
	h.y = 0.0
	h.facing = 1
	var hp0: float = boss.boss_hp
	var bx: float = boss.x
	m.queue_attack(0, false)
	run_ticks(m, 20, [cmd(), cmd(), cmd()])
	check(boss.boss_hp < hp0 and boss.damage_percent == 0.0 and absf(boss.x - bx) < 1.0, "%s takes health damage, no knockback (%.0f → %.0f)" % [bid, hp0, boss.boss_hp])
	# Its attack patterns come with warnings and hurt the heroes.
	var patterns := {}
	var warnings := 0
	for n in range(60 * 40):
		m.tick([cmd(), cmd(), cmd()])
		for e in m.events:
			if e.type == "boss_attack": patterns[e.pattern] = true
			if e.type == "boss_telegraph": warnings += 1
		if m.result != -2: break
	var hurt: float = m.fighters[0].damage_percent + m.fighters[1].damage_percent + (3 - m.fighters[0].lives) * 100.0 + (3 - m.fighters[1].lives) * 100.0
	check(patterns.size() >= 3 and warnings >= 3, "%s uses its attack patterns with warnings %s" % [bid, patterns.keys()])
	check(hurt > 30.0, "%s hurts idle heroes (%.0f)" % [bid, hurt])

func test_boss_phase_and_defeat() -> void:
	var m = boss_match("seraph")
	var boss: Dictionary = m.fighters[2]
	var ev: Array = []
	m._hit_boss(0, 2, {"damage": boss.boss_max * 0.7}, false)
	ev.append_array(m.events)
	check(boss.boss_phase == 2, "half health starts phase 2")
	m.tick([cmd(), cmd(), cmd()])
	m._hit_boss(0, 2, {"damage": boss.boss_max}, false)
	var defeated := false
	for e in m.events: if e.type == "boss_defeated": defeated = true
	m.tick([cmd(), cmd(), cmd()])
	check(defeated and m.result >= 0 and not m.fighters[m.result].is_boss, "defeating the boss wins the fight for the heroes")

func test_boss_wins() -> void:
	var m = boss_match("cherub")
	for k in range(2):
		m.fighters[k].lives = 1
		m.fighters[k].x = Combat.BLAST_ZONE_RIGHT + 2.0
		m.fighters[k].is_grounded = false
	run_ticks(m, 3, [cmd(), cmd(), cmd()])
	check(m.result == 2, "the boss wins when every hero is out")
	m = boss_match("ophan")
	m.time_left = 0.01
	run_ticks(m, 3, [cmd(), cmd(), cmd()])
	check(m.result == 2, "the boss wins on time")

func test_ai_heroes_fight_boss() -> void:
	var m = boss_match("cherub", [HERO_C, HERO_A])
	m.ai_level = 8
	var boss: Dictionary = m.fighters[2]
	var hp0: float = boss.boss_hp
	for n in range(60 * 45):
		m.tick(m.agent_commands())
		if m.result != -2: break
	check(boss.boss_hp < hp0 - 50.0, "computer heroes fight the boss (%.0f → %.0f)" % [hp0, boss.boss_hp])

func test_main_flow() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	# Team modes cycle through the versus button.
	var seen: Array = []
	for n in range(4):
		app._toggle_player_count()
		seen.append(app.team_mode)
	check(seen == ["ffa", "2v2", "3v1", "1v1"], "the player button cycles 1v1 → FFA → 2v2 → 3v1 (%s)" % [seen])
	app.team_mode = "3v1"
	app.player_count = 4
	app.start_round("autonomous")
	var teams: Array = app.sim.fighters.map(func(f): return f.team)
	check(teams == [0, 0, 0, 1] and app.sim.fighters[3].power_mult > 1.0, "3 vs 1: teams set, the lone fighter is stronger")
	app.team_mode = "2v2"
	app.start_round("autonomous")
	check(app.sim.fighters.map(func(f): return f.team) == [0, 0, 1, 1], "2 vs 2: teams set")

	app.show_selection()
	# Boss mode.
	app.team_mode = "1v1"
	app.player_count = 2
	app.open_boss_menu()
	check(app._boss_menu_open() and app.boss_menu_buttons.size() == Bosses.ORDER.size() + 3, "boss menu offers all 19 bosses, two rushes and back (%d)" % app.boss_menu_buttons.size())
	app._pick_boss("ophan", true)
	await process_frame
	check(app.boss_active and app.current_arena == "wheel_heaven" and app.sim.fighters.size() == 3 and app.sim.fighters[2].is_boss,
		"boss fight starts in its own level (%s)" % app.current_arena)
	check(app.views[2].get_meta("model_path", "") == "boss:ophan", "the boss has its angel body")
	app.sim.countdown = 0.0
	app.sim._hit_boss(0, 2, {"damage": 99999.0}, false)
	app.sim.tick([cmd(), cmd(), cmd()])
	check(app.winner_text() == "BOSS BEZWUNGEN!" and app._next_boss_available(), "after a boss rush win the next boss is offered")
	app.next_boss()
	await process_frame
	check(app.boss_id == "cherub" and app.current_arena == "heaven_gate", "heaven rush: after Ophaniel comes Keruvim at the gate")
	app._pick_boss("lucifer", true)
	await process_frame
	check(app.current_arena == "cocytus" and app.views[2].has_meta("boss_body"), "Lucifer waits in the ice of Cocytus, with a sculpted body")
	app.sim.countdown = 0.0
	app.sim._hit_boss(0, 2, {"damage": 99999.0}, false)
	app.sim.tick([cmd(), cmd(), cmd()])
	check(not app._next_boss_available(), "Lucifer is the last boss of the hell rush")
	app.show_selection()
	check(not app.boss_active and not app.ARENAS[app.current_arena].get("boss", false), "back in the menu the normal arena returns")
	app.queue_free()

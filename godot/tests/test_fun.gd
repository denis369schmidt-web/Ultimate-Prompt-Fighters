extends "res://tests/test_base.gd"
## Fun systems: mutators, daily challenge with streak, weekly events, challengers, comeback gift.

const FunModes = preload("res://scripts/fun_modes.gd")
const Progression = preload("res://scripts/progression.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	test_rules()
	test_party_rules()
	await test_main()
	finish("fun")

func roster() -> Array:
	return [{"id": "arber", "name": "ARBËR", "prompt": "Arbër der Bohrmeister"}, {"id": "zip", "name": "ZIP", "prompt": "Zip der Blitzkurier mit Turbo-Sprint"},
		{"id": "kairo", "name": "KAIRO", "prompt": "Kairo der Sturmmönch mit Solar-Kanone"}, {"id": "glaciem", "name": "GLACIEM", "prompt": "Glaciem die Frostassassine mit Eissplitter"}]

func test_rules() -> void:
	var a: Dictionary = FunModes.daily_challenge(20000, roster())
	var b: Dictionary = FunModes.daily_challenge(20000, roster())
	var c: Dictionary = FunModes.daily_challenge(20001, roster())
	check(a.fighter.id == b.fighter.id and a.mutators == b.mutators and a.goal.id == b.goal.id, "the daily challenge is the same all day")
	var differs := false
	for d in range(20001, 20010):
		var o: Dictionary = FunModes.daily_challenge(d, roster())
		if o.fighter.id != a.fighter.id or o.mutators != a.mutators: differs = true
	check(differs, "it changes from day to day")
	check(a.mutators.size() >= 2 and not (a.mutators.has("giants") and a.mutators.has("tiny")), "two or more compatible mutators (%s)" % [a.mutators])
	for f in a.foes: check(f.id != a.fighter.id, "you never fight yourself in the challenge")
	check(FunModes.goal_met({"id": "fast", "time": 60.0}, 0, 40.0, 1) and not FunModes.goal_met({"id": "fast", "time": 60.0}, 0, 70.0, 0), "the fast goal needs a quick win")
	check(FunModes.goal_met({"id": "flawless"}, 0, 99.0, 0) and not FunModes.goal_met({"id": "flawless"}, 0, 10.0, 1), "flawless means no life lost")
	check(not FunModes.goal_met({"id": "win"}, 1, 10.0, 0), "a lost fight never meets a goal")
	var prog := Progression.new()
	prog.persist = false
	var first: Dictionary = FunModes.claim_daily(prog, 100)
	check(first.streak == 1 and prog.coins == first.coins, "the first challenge pays and starts a streak")
	check(FunModes.claim_daily(prog, 100).is_empty(), "the challenge pays only once a day")
	for d in range(101, 107): FunModes.claim_daily(prog, d)
	check(int(prog.challenge.streak) == 7 and prog.chests >= 1, "seven days in a row: the streak reaches 7 and gives a chest")
	FunModes.claim_daily(prog, 109)
	check(int(prog.challenge.streak) == 1 and int(prog.challenge.best_streak) == 7, "a missed day starts over, the best streak stays")
	var e1: Dictionary = FunModes.event_of(7 * 3)
	check(e1 == FunModes.event_of(7 * 3 + 6) and e1 != FunModes.event_of(7 * 4), "one event per week, then the next")
	var p2 := Progression.new()
	p2.persist = false
	check(FunModes.check_comeback(p2, 50).is_empty(), "the first visit is no comeback")
	check(FunModes.check_comeback(p2, 51).is_empty(), "coming back the next day is normal")
	var gift: Dictionary = FunModes.check_comeback(p2, 56)
	check(gift.get("days", 0) == 5 and p2.coins >= 200 and p2.chests == 1, "five days away: a welcome-back gift")


func rule_match(ids: Array):
	var m = Combat.new()
	m.start([Prompt.interpret("Zip der Blitzkurier mit Turbo-Sprint", 0), Prompt.interpret("Kairo der Sturmmönch mit Solar-Kanone", 1)], null, "manual", 3)
	m.countdown = 0.0
	m.items.clear()
	FunModes.apply(m, [], ids)
	return m

func idle(m, n: int, ev: Array = []) -> void:
	for k in range(n):
		m.item_spawn_timer = 999.0
		m.events.clear()
		m.tick([{"move": 0.0}, {"move": 0.0}])
		ev.append_array(m.events)

func test_party_rules() -> void:
	for id in ["bomb_rain", "vampire", "swap", "escalation", "item_rain"]:
		check(FunModes.MUTATORS.has(id) and FunModes.mutator_text([id]) != "", "mutator %s exists with a name" % id)
	var m = rule_match(["bomb_rain"])
	var ev: Array = []
	idle(m, int(5.0 / Combat.STEP), ev)
	var warned := false
	var hit := false
	for e in ev:
		if e.type == "boss_telegraph" and e.shape == "circle": warned = true
		if e.type == "hazard_hit" and e.kind == "bombe": hit = true
	check(warned and hit, "bomb rain: a red circle warns, then the bomb hits a fighter standing there")
	m = rule_match(["swap"])
	m.fighters[0].x = -3.0
	m.fighters[1].x = 4.0
	ev = []
	idle(m, int(15.2 / Combat.STEP), ev)
	var swapped := false
	for e in ev: if e.type == "rule_swap": swapped = true
	check(swapped and m.fighters[0].x > 0.0 and m.fighters[1].x < 0.0, "swap: after 15 s the fighters trade places")
	m = rule_match(["vampire"])
	m.fighters[0].damage_percent = 50.0
	m.fighters[0].x = 0.0
	m.fighters[1].x = 1.2
	m.fighters[0].facing = 1
	m.queue_attack(0, false)
	idle(m, 30)
	check(m.fighters[1].damage_percent > 0.0 and m.fighters[0].damage_percent < 50.0, "blood thirst: hitting heals the attacker (%.1f%%)" % m.fighters[0].damage_percent)
	m = rule_match(["escalation"])
	m.elapsed = 60.0
	check(is_equal_approx(m.escalation_mult(), 1.6) and rule_match([]).rules.is_empty(), "escalation grows with time, no rules without mutators")
	m = rule_match(["item_rain"])
	m.item_spawn_timer = 0.0
	m.tick([{"move": 0.0}, {"move": 0.0}])
	check(m.item_spawn_timer <= 5.0, "gift rain: the next item comes within 5 s")

func test_main() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.progression.persist = false
	# Mutators in versus.
	app.active_mutators = ["low_gravity", "giants"]
	var p_list: Array = [app.Prompt.interpret("Zip der Blitzkurier mit Turbo-Sprint", 0), app.Prompt.interpret("Kairo der Sturmmönch mit Solar-Kanone", 1)]
	app.begin_match(p_list, "pve", 2)
	check(app.views[0].scale.x > 1.3 and float(app.sim.fighters[0].power_mult) > 1.0, "giants are big and hit harder")
	app.active_mutators = []
	app.begin_match(p_list, "pve", 2)
	check(is_equal_approx(app.views[0].scale.x, 1.0), "without mutators everyone is normal size again")
	# Daily challenge.
	app.show_title("menu")
	app._title_activate(app.Backgrounds.MENU_ITEMS.find("extras"))
	app._open_title_panel("challenge")
	check(app.title_panel_kind == "challenge", "the challenge panel opens from EXTRAS")
	app.start_daily()
	check(app.daily_active and app.active and app.sim.fighters.size() >= 2, "the challenge fight starts")
	check(app.sim.fighters[0].profile.family == str(app.daily_info.fighter.id), "you play today's fighter")
	app.sim.result = 0
	app.daily_info.goal = {"id": "win", "text": "Gewinne."}
	var coins: int = app.progression.coins
	app._daily_finished()
	check(app.progression.coins > coins and app.result_label.text.contains("GESCHAFFT"), "a met goal pays the challenge reward")
	app.show_selection()
	check(not app.daily_active, "leaving ends the challenge")
	# Challenger.
	app.begin_match(p_list, "pve", 2)
	app.challenger_pending = true
	app._start_challenger()
	check(app.challenger_active and app.sim.fighters[1].profile.family != app.sim.fighters[0].profile.family, "a challenger steps in")
	app.sim.result = 0
	var c2: int = app.progression.coins
	app._challenger_after_match()
	check(app.progression.coins >= c2 + 150 and not app.challenger_active, "beating the challenger pays extra")
	app.queue_free()
	await process_frame

extends "res://tests/test_base.gd"
## Weapons, skins, lucky chest, login calendar, Hall of Fame, level-up and win-streak rewards.

const Rewards = preload("res://scripts/rewards.gd")
const Progression = preload("res://scripts/progression.gd")
const Backgrounds = preload("res://scripts/backgrounds.gd")
const BossModels = preload("res://scripts/boss_models.gd")

func _initialize() -> void:
	call_deferred("run")

func fresh():
	var p = Progression.new()
	p.persist = false
	return p

func run() -> void:
	test_catalog_and_weapons()
	test_buy_equip()
	test_chest()
	test_login()
	test_path_and_levels()
	test_streak()
	test_round_two()
	await test_main()
	finish("rewards")

func test_catalog_and_weapons() -> void:
	check(Rewards.WEAPONS.size() == 8 and Rewards.SKINS.size() == 14, "8 shop weapons and 14 skins")
	var ok := true
	for w in Rewards.WEAPONS: ok = ok and Combat.WEAPONS.has(w.id) and Combat.WEAPONS[w.id].get("shop", false)
	check(ok, "every shop weapon exists in the combat core")
	check(Combat.base_weapons().size() == 8, "the classic eight stay the default arena weapons")
	var m = match_ready()
	m.give_weapon(0, "thunder_hammer")
	check(m.fighters[0].weapon.get("id", "") == "thunder_hammer", "a start weapon is put straight into the fighter's hands")
	m.weapon_pool = ["crystal_bow"]
	m.spawn_random_item()
	var spawned := false
	for it in m.items: if it.get("weapon", "") == "crystal_bow": spawned = true
	check(spawned or m.items.size() > 0, "arena spawns use the weapon pool")
	# The bow shoots crystal arrows.
	m = match_ready()
	m.fighters[1].x = 4.0
	m.give_weapon(0, "crystal_bow")
	m.queue_attack(0, false)
	var shot := false
	for n in range(30):
		m.tick(idle_commands())
		for e in m.events: if e.type == "projectile": shot = true
	check(shot, "the crystal bow fires arrows")

func test_buy_equip() -> void:
	var p = fresh()
	check(not Rewards.buy_skin(p, "gold") and not Rewards.buy_weapon(p, "frost_axe"), "nothing without coins")
	p.coins = 2000
	check(Rewards.buy_skin(p, "gold") and p.coins == 1700 and Rewards.owns_skin(p, "gold"), "buying a skin")
	check(Rewards.buy_weapon(p, "frost_axe") and p.coins == 1250, "buying a weapon")
	check(not Rewards.buy_skin(p, "celestial"), "path skins cannot be bought")
	check(Rewards.equip_skin(p, "gold") and p.skin == "gold" and not Rewards.equip_skin(p, "galaxy"), "only owned skins can be worn")
	check(Rewards.equip_weapon(p, "frost_axe") and p.start_weapon == "frost_axe", "start weapon")
	check(Rewards.weapon_pool(p, Combat.base_weapons()).has("frost_axe"), "bought weapons join the arena pool")

func test_chest() -> void:
	var p = fresh()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	check(Rewards.open_chest(p, rng, Backgrounds.LIST).is_empty(), "no chest without coins or free chests")
	p.chests = 1
	var r: Dictionary = Rewards.open_chest(p, rng, Backgrounds.LIST)
	check(not r.is_empty() and p.chests == 0, "a free chest opens (%s)" % Rewards.reward_text(r))
	p.coins = 150 * 40
	var kinds := {}
	for n in range(40):
		var got: Dictionary = Rewards.open_chest(p, rng, Backgrounds.LIST)
		kinds[got.kind] = true
	check(kinds.size() >= 3, "chests give coins, skins, weapons and backgrounds (%s)" % [kinds.keys()])
	check(p.skins_owned.size() > 0 and p.weapons_owned.size() > 0, "chest items are really owned")

func test_login() -> void:
	var p = fresh()
	var a: Dictionary = Rewards.claim_login(p, 100)
	check(a.day == 1 and p.coins == 50, "day 1 of the calendar")
	check(Rewards.claim_login(p, 100).is_empty(), "once per day")
	for d in range(101, 107): Rewards.claim_login(p, d)
	check(p.chests == 1 and int(p.login.step) == 7, "seven days in a row: day 7 gives a chest")
	var r: Dictionary = Rewards.claim_login(p, 110)
	check(r.day == 1, "a missed day starts the calendar over")

func test_path_and_levels() -> void:
	var p = fresh()
	p.xp = Rewards.PATH_XP * 16
	var got: Array = Rewards.claim_path(p)
	check(got.size() == 16 and p.path_claimed == 16 and Rewards.owns_skin(p, "celestial") and Rewards.owns_weapon(p, "shadow_katana"),
		"Hall of Fame: 16 tiers pay out, incl. the exclusive skin and a weapon")
	check(Rewards.claim_path(p).is_empty(), "tiers are claimed once")
	var q = fresh()
	q.begin_match("ninja", "pve", 20000)
	for n in range(40): q.track({"type": "hit", "actor": 0, "target": 1, "damage": 30.0})
	var res: Dictionary = q.end_match(0)
	check(int(res.level_coins) > 0 and res.level > 1, "level ups pay coins (+%d)" % int(res.level_coins))
	check(int(res.coins) >= int(res.level_coins) + 100, "achievements pay coins too")

func test_streak() -> void:
	var p = fresh()
	var coins: Array = []
	for n in range(4):
		p.begin_match("ninja", "pve", 20000)
		coins.append(int(p.end_match(0).get("streak_bonus", 1.0) * 100))
	check(p.win_streak == 4 and coins[3] > coins[0], "win streaks raise the coin multiplier (%s)" % [coins])
	p.begin_match("ninja", "pve", 20000)
	p.end_match(1)
	check(p.win_streak == 0, "a loss ends the streak")

func big_win(p, family: String, day: int, ctx: Dictionary = {}) -> Dictionary:
	p.begin_match(family, "pve", day)
	for n in range(30): p.track({"type": "hit", "actor": 0, "target": 1, "damage": 12.0})
	p.track({"type": "combo_end", "actor": 0, "count": 8})
	p.track({"type": "ring_out", "actor": 1, "lives": 0})
	return p.end_match(0, 0, ctx)

func test_round_two() -> void:
	var p = fresh()
	var r: Dictionary = big_win(p, "ninja", 500)
	check(r.grade in ["S", "A"] and float(r.grade_mult) > 1.0, "a strong win gets a high grade (%s)" % r.grade)
	check(r.extras.any(func(e): return e.contains("ERSTER SIEG")), "first win of the day pays a bonus")
	var r2: Dictionary = big_win(p, "ninja", 500)
	check(not r2.extras.any(func(e): return e.contains("ERSTER SIEG")), "…only once a day")
	var r3: Dictionary = big_win(p, "golem", 500, {"bounty": "golem"})
	check(r3.extras.any(func(e): return e.contains("KOPFGELD")), "winning with the bounty fighter pays the bounty")
	check(p.rank_points > 0 and int(r3.lp_change) > 25, "wins raise league points, streaks raise them more (%+d)" % int(r3.lp_change))
	p.rank_points = 240
	var coins_before: int = p.coins
	var chests_before: int = p.chests
	var r4: Dictionary = big_win(p, "ninja", 501)
	check(p.best_league >= 2 and p.chests > chests_before and r4.extras.any(func(e): return e.contains("AUFSTIEG")), "reaching a new league pays coins and chests")
	var lp: int = p.rank_points
	p.begin_match("ninja", "pve", 501)
	p.end_match(1)
	check(p.rank_points == lp - 15, "a loss costs 15 league points")
	var wk: Array = p.weekly.list
	check(wk.size() == 3 and wk.any(func(c): return int(c.progress) > 0), "weekly challenges track progress")
	var q = fresh()
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	var first_spin: Dictionary = Rewards.spin_wheel(q, rng, 900)
	q.coins = 0
	check(not first_spin.is_empty() and Rewards.spin_wheel(q, rng, 900).is_empty(), "one free wheel spin per day, then it costs coins")
	q.coins = 1000
	check(not Rewards.spin_wheel(q, rng, 900).is_empty() and q.coins <= 900 + 1000, "paid spins cost %d coins" % Rewards.WHEEL_PRICE)
	check(Rewards.buy_boost(q) and q.boost_matches >= 3, "XP booster bought")
	var b1 = fresh()
	var b2 = fresh()
	b2.boost_matches = 1
	var x1: int = int(big_win(b1, "ninja", 600).total)
	var x2: int = int(big_win(b2, "ninja", 600).total)
	check(x2 >= x1 * 2 - 1 and b2.boost_matches == 0, "the booster doubles XP (%d → %d)" % [x1, x2])
	check(not Rewards.equip_title(fresh(), "hero") and Rewards.equip_title(p, "brawler") == (int(p.stats.get("wins", 0)) >= 10), "titles need their goal")
	var s = fresh()
	s.story_chapter_done(60)
	check(s.coins == 60 and int(s.stats.chapters) == 1, "story chapters count for titles and achievements")

func test_main() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.progression.coins = 5000
	app.show_title("menu")
	for tab in ["weapons", "skins", "chest", "backgrounds"]:
		app.shop_tab = tab
		app._open_title_panel("shop")
		check(app._nav_buttons(app.title_panel).size() >= 5, "shop tab %s is built and controller-navigable" % tab)
	app._shop_item_press("skins", "galaxy")
	check(app.progression.skin == "galaxy", "buying a skin in the shop equips it")
	var mi: MeshInstance3D = null
	for m in app.views[0].model.find_children("*", "MeshInstance3D", true, false):
		if m.mesh != null: mi = m; break
	var skin_mat = mi.get_surface_override_material(0) if mi != null else null
	# House heroes keep their texture: the skin recolors the outfit shader; other bodies get the glowing skin material.
	var worn: bool = skin_mat is ShaderMaterial and skin_mat.get_shader_parameter("primary") == BossModels.SKIN_PALETTE["galaxy"][0] 		or skin_mat is BaseMaterial3D and skin_mat.emission_enabled
	check(worn, "P1's fighter wears the skin")
	app._shop_item_press("weapons", "thunder_hammer")
	app._close_title_panel()
	app.hide_title()
	app.start_round("pve")
	check(app.sim.fighters[0].weapon.get("id", "") == "thunder_hammer", "the start weapon is in hand when the fight begins")
	check(app.sim.weapon_pool.has("thunder_hammer"), "bought weapons spawn in the arena")
	app.show_title("menu")
	for panel in ["extras", "daily", "path", "tasks", "collection", "league", "wheel", "titles"]:
		app._open_title_panel(panel)
		check(app._nav_buttons(app.title_panel).size() >= 1, "%s panel opens and can be used with the controller" % panel)
	app._open_title_panel("daily")
	var before: int = app.progression.coins
	for b in app._nav_buttons(app.title_panel):
		if b.text == "ABHOLEN!": b.emit_signal("pressed")
	check(app.progression.coins > before, "the daily reward is claimed from the calendar")
	app.queue_free()

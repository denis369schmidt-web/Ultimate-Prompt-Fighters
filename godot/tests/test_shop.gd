extends "res://tests/test_base.gd"
## Coins, shop, start screen backgrounds and their arenas – data, rules and the main scene.

const Backgrounds = preload("res://scripts/backgrounds.gd")
const Progression = preload("res://scripts/progression.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	test_catalog()
	test_rules()
	await test_main()
	finish("shop")

func test_catalog() -> void:
	check(Backgrounds.LIST.size() == 23, "23 start screen backgrounds (%d)" % Backgrounds.LIST.size())
	var ids := {}
	var ok := true
	for bg in Backgrounds.LIST:
		ids[bg.id] = true
		ok = ok and ResourceLoader.exists(Backgrounds.image_path(bg))
		var m: Array = bg.menu
		ok = ok and float(m[0]) >= 0.0 and float(m[2]) <= 1.0 and float(m[0]) < float(m[2]) and float(m[1]) < float(m[3]) and float(m[3]) <= 1.0
		ok = ok and Backgrounds.MOTIF_STAGE.has(bg.motif)
	check(ok, "every background has its picture, a menu area inside it and an arena motif")
	check(ids.size() == Backgrounds.LIST.size(), "background ids are unique")
	check(int(Backgrounds.LIST[0].price) == 0, "the first background is free")

func test_rules() -> void:
	var p = Progression.new()
	p.persist = false
	check(Backgrounds.is_unlocked(p, "neon_alley") and not Backgrounds.is_unlocked(p, "dojo"), "only the free background is owned at the start")
	check(not Backgrounds.arena_unlocked(p, "bg_dojo") and Backgrounds.arena_unlocked(p, "blood_moon"), "shop arenas are locked, classic arenas are open")
	check(not Backgrounds.buy(p, "dojo"), "buying without coins fails")
	p.begin_match("ninja", "pve", 20000)
	var r: Dictionary = p.end_match(0, 100)
	check(int(r.coins) >= 100 and p.coins == int(r.coins), "a won fight pays coins (+%d)" % int(r.coins))
	p.begin_match("ninja", "autonomous", 20000)
	check(p.end_match(0).is_empty(), "AI-vs-AI fights pay nothing")
	p.coins = 1000
	check(Backgrounds.buy(p, "dojo") and p.coins == 550 and Backgrounds.arena_unlocked(p, "bg_dojo"), "buying unlocks background and arena and costs its price")
	check(not Backgrounds.buy(p, "dojo"), "a background is bought only once")
	check(Backgrounds.select(p, "dojo") and p.menu_bg == "dojo" and not Backgrounds.select(p, "foundry"), "only owned backgrounds can be selected")
	p.add_coins(60)
	check(p.coins == 610, "story chapters add coins")

func test_main() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	check(not app.progression.persist, "headless runs never touch the save file")
	var shop_arenas := 0
	for id in app.ARENAS: if str(id).begins_with("bg_"): shop_arenas += 1
	check(shop_arenas == 23, "all 23 shop arenas are registered (%d)" % shop_arenas)
	# Every shop arena builds.
	var built := 0
	for bg in Backgrounds.LIST:
		app.apply_arena(Backgrounds.arena_id(bg))
		await process_frame
		if app.current_arena == Backgrounds.arena_id(bg) and app.arena_builder.get_child_count() > 20: built += 1
	check(built == 23, "every shop arena builds its scene (%d)" % built)
	# Start screen: press start, then the main menu.
	app.show_title("splash")
	await process_frame
	await process_frame
	check(app.title_stage == "splash" and app.splash_label.visible and not app.title_hotspots[0].visible, "launch shows the press-start screen")
	app._pad_menu_button(0, JOY_BUTTON_A)
	await process_frame
	check(app.title_stage == "menu" and app.title_hotspots[0].visible, "A / Start opens the main menu")
	app._pad_menu_button(0, JOY_BUTTON_DPAD_DOWN)
	check(app.title_index == 1, "the d-pad moves through the main menu")
	app._pad_menu_button(0, JOY_BUTTON_DPAD_DOWN)
	app._pad_menu_button(0, JOY_BUTTON_DPAD_DOWN)
	app._pad_menu_button(0, JOY_BUTTON_DPAD_DOWN) # ABENTEUER sits between STORY and VERSUS
	app._pad_menu_button(0, JOY_BUTTON_A)
	check(app.title_panel_kind == "options", "A on OPTIONS opens the options")
	var ai_before: int = app.ai_level
	# The mutator buttons come first; walk down to KI-STUFE.
	await process_frame
	await process_frame
	for i in 16:
		app._pad_menu_button(0, JOY_BUTTON_DPAD_DOWN)
		if app.nav_focus != null and app.nav_focus.text == "KI-STUFE": break
	app._pad_menu_button(0, JOY_BUTTON_A)
	check(app.ai_level != ai_before, "options are changed with the controller (AI level %d → %d)" % [ai_before, app.ai_level])
	app._pad_menu_button(0, JOY_BUTTON_B)
	check(app.title_panel == null or not is_instance_valid(app.title_panel), "B closes the options")
	check(app.title_screen.visible and app.title_hotspots.size() == Backgrounds.MENU_ITEMS.size(), "the start screen shows all menu entries")
	var inside := true
	var r: Rect2 = Rect2(Vector2.ZERO, app.title_screen.size)
	for h in app.title_hotspots: inside = inside and r.encloses(Rect2(h.position, h.size))
	check(inside, "the menu buttons sit inside the screen")
	app._title_activate(Backgrounds.MENU_ITEMS.find("shop"))
	check(app.title_panel_kind == "shop" and app.shop_buttons.size() == 23, "SHOP opens the shop with all backgrounds")
	app.progression.coins = 5000
	app._shop_press("orbital_ring")
	check(app.progression.unlocked.has("orbital_ring") and app.progression.menu_bg == "orbital_ring", "buying in the shop unlocks and selects the background")
	check(app.title_arena == "bg_" + str(app.Backgrounds.LIST[5].id), "the start screen switches to the bought background's arena")
	# Buying with the controller: move to a card, press A.
	app.progression.coins = 5000
	await process_frame # the rebuilt shop needs one layout pass before the controller can navigate it
	var focused: Button = null
	for n in range(12):
		app._nav_pad(JOY_BUTTON_DPAD_DOWN if n < 2 else JOY_BUTTON_DPAD_RIGHT, app.title_panel)
		if app.nav_focus != null and app.nav_focus.text.contains("KAUFEN"):
			focused = app.nav_focus
			break
	app._nav_pad(JOY_BUTTON_A, app.title_panel)
	check(focused != null and app.progression.unlocked.size() >= 2, "shop cards are bought with d-pad and A (%d owned)" % app.progression.unlocked.size())
	app._close_title_panel()
	app._title_activate(Backgrounds.MENU_ITEMS.find("story"))
	check(app.story.menu_panel.visible and not app.title_screen.visible, "STORY opens the story menu")
	app._pad_menu_button(0, JOY_BUTTON_DPAD_DOWN)
	check(app.nav_focus != null and app.story.menu_panel.is_ancestor_of(app.nav_focus), "the controller focus moves inside the story menu")
	app._pad_menu_button(0, JOY_BUTTON_B)
	check(not app.story.menu_panel.visible and app.title_screen.visible, "B leaves the story menu back to the main menu")
	app._title_activate(Backgrounds.MENU_ITEMS.find("versus"))
	check(not app.title_screen.visible, "VERSUS goes to the fighter selection")
	var arena_before: String = app.current_arena
	app._pad_menu_button(0, JOY_BUTTON_RIGHT_SHOULDER)
	check(app.current_arena != arena_before, "RB changes the arena in the fighter selection")
	var mode_before: String = app.current_combat_mode
	app._pad_menu_button(0, JOY_BUTTON_BACK)
	check(app.current_combat_mode != mode_before, "View changes the game mode")
	app._pad_menu_button(0, JOY_BUTTON_B)
	check(app.title_screen.visible and app.title_stage == "menu", "B in the fighter selection returns to the main menu")
	app._title_activate(Backgrounds.MENU_ITEMS.find("versus"))
	# Match rewards.
	app.team_mode = "1v1"
	app.player_count = 2
	app.start_round("pve")
	var coins_before: int = app.progression.coins
	app.sim.countdown = 0.0
	app.sim.fighters[1].lives = 1
	app.sim.fighters[1].x = 30.0
	app.sim.fighters[1].is_grounded = false
	app.finishers_on = false
	app.sim.finishers_enabled = false
	for n in range(5): app._physics_process(1.0 / 60.0)
	check(app.progression.coins > coins_before and app.last_reward_text.contains("🪙"), "winning a match pays coins and shows them (%s)" % app.last_reward_text.strip_edges())
	app.queue_free()

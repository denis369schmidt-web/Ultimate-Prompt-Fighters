extends "res://tests/test_base.gd"
## Real-money store layer (store.gd, products.gd) wired into the game: premium tab, purchases
## grant their exact contents once, restore, and the Google Play free tier (Vollversion gate).

const Products = preload("res://scripts/products.gd")
const Bosses = preload("res://scripts/bosses.gd")
const Rewards = preload("res://scripts/rewards.gd")

func _initialize() -> void:
	call_deferred("run")

func frames(n: int = 2) -> void:
	for k in range(n): await process_frame

func count_buttons(node: Node, text_part: String) -> int:
	var n := 0
	for b in node.find_children("*", "Button", true, false):
		if text_part in (b as Button).text: n += 1
	return n

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await frames()
	var store = app.store
	check(store != null and store.backend == "local", "the store runs in local test mode without Steam / Play")
	check(not store.persist, "headless runs never write purchases to disk")
	check(app.premium_visible(), "debug builds show the premium tab (test mode)")
	check(not app.full_game_locked(), "desktop and Steam never lock content")

	# Catalog: fixed prices, readable contents, no random paid rewards.
	var fair := true
	for p in Products.PRODUCTS:
		fair = fair and float(p.price_eur) > 0.0 and str(p.desc).length() > 20 and not "zufall" in str(p.desc).to_lower()
	check(fair, "every product has a fixed price and a clear description")
	check(store.price_text("pack_neon") == "2,99 €", "prices are shown in euro (%s)" % store.price_text("pack_neon"))

	# Premium tab
	app.show_title("menu")
	app.shop_tab = "premium"
	app._open_title_panel("shop")
	await frames()
	check(count_buttons(app.title_panel, "€") >= 5, "the premium tab lists the products with prices")
	check(count_buttons(app.title_panel, "WIEDERHERSTELLEN") == 1, "there is a restore purchases button")

	# Buying grants the exact contents.
	var coins_before: int = app.progression.coins
	app._buy_product("pack_neon")
	await frames()
	check(store.owns("pack_neon"), "a bought pack is owned")
	check(app.progression.skins_owned.has("neon") and app.progression.skins_owned.has("crystal"), "the pack's skins are unlocked")
	check(app.progression.unlocked.has("neon_skyline") and app.progression.unlocked.has("storm_roof"), "the pack's arenas are unlocked")
	check(count_buttons(app.title_panel, "GEKAUFT") >= 1, "the shop shows it as bought")
	app._buy_product("supporter")
	await frames()
	check(app.progression.coins == coins_before + 1000, "the supporter pack pays its coins (%d)" % (app.progression.coins - coins_before))
	store.restore()
	app._on_store_changed()
	await frames()
	check(app.progression.coins == coins_before + 1000, "restoring never pays the coins twice")
	check(Rewards.title_unlocked(app.progression, Rewards.TITLES[0]), "the supporter title is unlocked")
	app._buy_product("pack_weapons")
	await frames()
	var all_w := true
	for w in Rewards.WEAPONS: all_w = all_w and app.progression.weapons_owned.has(w.id)
	check(all_w, "the weapon pack unlocks every shop weapon")

	# ── Google Play free tier ──
	store.backend = "play"
	store.owned.erase("full_game")
	check(app.full_game_locked(), "on Google Play the Vollversion is needed")
	check(store.products().any(func(p): return p.id == "full_game"), "Play offers the Vollversion")
	var story = app.story
	story.set_campaign("divina")
	var list: Array = story.chapters()
	var free_ok := true
	var locked_ok := false
	for k in range(list.size()):
		var id := str(list[k].id)
		if id in ["d0", "h1", "p1"]: free_ok = free_ok and not story.needs_full_game(k)
		elif story.needs_full_game(k): locked_ok = true
	check(free_ok, "prolog and the first chapter of hell and heaven are free")
	check(locked_ok, "later chapters need the Vollversion")
	check(not app.boss_needs_full_game(Bosses.ORDER[0], false), "the first bosses are free")
	check(app.boss_needs_full_game(Bosses.ORDER[5], false) and app.boss_needs_full_game(Bosses.ORDER[0], true), "other bosses and the boss rush need the Vollversion")
	app.open_boss_menu()
	app._pick_boss(Bosses.ORDER[6], false)
	await frames()
	check(not app.active and app.title_panel != null and app.title_panel.visible and app.shop_tab == "premium", "a locked boss opens the Vollversion offer instead of a fight")
	var h2 := -1
	for k in range(list.size()):
		if str(list[k].id) == "h2": h2 = k
	story.start_chapter(h2)
	await frames()
	check(not story.running, "a locked chapter does not start")
	store._grant("full_game")
	check(not app.full_game_locked() and not story.needs_full_game(h2), "buying the Vollversion unlocks everything")

	# Steam: DLC only, the game itself is the purchase.
	store.backend = "steam"
	check(not store.products().any(func(p): return p.id == "full_game"), "Steam does not sell a Vollversion inside the game")
	check(app.premium_visible(), "Steam shows the DLC tab")
	store.backend = "local"

	app.queue_free()
	await frames()
	finish("store")

extends "res://tests/test_base.gd"
## Tests for arena traps (hazards), breakable objects (destructibles),
## debris physics, dynamic item drops, and enhanced combat VFX.

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	test_hazard_configurations()
	test_hazard_cycle_and_damage()
	test_destructibles_placement()
	test_destructible_damage_and_destruction()
	test_thrown_item_destructible_collision()
	await test_main_scene_hazard_and_destructible_nodes()
	finish("hazards_and_destructibles")

func test_hazard_configurations() -> void:
	var c = Combat.new()
	c.set_arena("volcano_sanctum")
	check(c.hazards.size() >= 2, "volcano arena has hazards")
	check(c.hazards[0].type == "fire_vent", "volcano arena hazard is fire_vent")

	c.set_arena("imperial_colosseum")
	check(c.hazards[0].type == "spikes", "colosseum arena hazard is spikes")

	c.set_arena("neon_metropolis")
	check(c.hazards[0].type == "tesla_shock", "neon arena hazard is tesla_shock")

	c.set_arena("frozen_summit")
	check(c.hazards[0].type == "ice_stalactite", "frozen summit hazard is ice_stalactite")

	c.set_arena("mystic_grove")
	check(c.hazards[0].type == "thorn_roots", "grove arena hazard is thorn_roots")

func test_hazard_cycle_and_damage() -> void:
	var c = Combat.new()
	var p1: Dictionary = Prompt.interpret("Volt Shadow Ninja", 0)
	var p2: Dictionary = Prompt.interpret("Basalt Lava Golem", 1)
	c.set_arena("imperial_colosseum")
	c.start(p1, p2, "manual")
	c.countdown = 0.0

	var h: Dictionary = c.hazards[0]
	check(h.state == "idle", "hazard starts in idle state")

	# Position fighter directly over hazard
	var f: Dictionary = c.fighters[0]
	f.x = h.x
	f.y = h.y
	f.is_grounded = true

	# Advance until warning
	h.timer = h.period - h.warning_time - 0.05
	c.tick([{"move": 0.0}, {"move": 0.0}], 0.1)
	check(h.state == "warning", "hazard advances to warning state")

	# Advance until active
	h.timer = h.period - 0.02
	var hp_before: float = f.hp
	c.tick([{"move": 0.0}, {"move": 0.0}], 0.05)
	check(h.state == "active", "hazard advances to active state")
	check(f.hp < hp_before and f.state == "HitStun", "active hazard damages fighter and triggers hitstun")
	check(f.vy > 2.0, "hazard launches fighter upward (vy %.2f)" % f.vy)

func test_destructibles_placement() -> void:
	var c = Combat.new()
	c.set_arena("volcano_sanctum")
	check(c.destructibles.size() >= 3, "arena has destructibles placed")
	check(c.destructibles[0].state == "intact", "destructible starts intact")
	check(c.destructibles[0].hp == c.destructibles[0].max_hp, "destructible starts with full HP")

func test_destructible_damage_and_destruction() -> void:
	var c = Combat.new()
	var p1: Dictionary = Prompt.interpret("Volt Shadow Ninja", 0)
	var p2: Dictionary = Prompt.interpret("Basalt Lava Golem", 1)
	c.set_arena("imperial_colosseum")
	c.start(p1, p2, "manual")
	c.countdown = 0.0

	var d: Dictionary = c.destructibles[0]
	var items_count_before: int = c.items.size()

	# Damage destructible directly
	c.damage_destructible(0, 15.0, 0)
	check(d.hp == d.max_hp - 15.0 and d.state == "intact", "destructible takes partial damage (hp %.1f)" % d.hp)

	# Destroy destructible
	c.damage_destructible(0, 50.0, 0)
	check(d.state == "destroyed", "destructible is destroyed when hp <= 0")
	check(d.respawn_timer > 0.0, "destroyed destructible has respawn timer")
	check(c.items.size() > items_count_before, "destroyed destructible spawns a dropped item")

func test_thrown_item_destructible_collision() -> void:
	var c = Combat.new()
	var p1: Dictionary = Prompt.interpret("Volt Shadow Ninja", 0)
	var p2: Dictionary = Prompt.interpret("Basalt Lava Golem", 1)
	c.set_arena("imperial_colosseum")
	c.start(p1, p2, "manual")
	c.countdown = 0.0

	var d: Dictionary = c.destructibles[0]
	var it: Dictionary = c.items[0]
	it.state = "thrown"
	it.x = d.x - 0.2
	it.y = d.y + 0.5
	it.vx = 8.0
	it.vy = 0.0

	var hp_before: float = d.hp
	c.tick([{"move": 0.0}, {"move": 0.0}], 0.05)
	check(d.hp < hp_before, "thrown item damages destructible on contact")

func test_main_scene_hazard_and_destructible_nodes() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame

	app.apply_arena("volcano_sanctum")
	await process_frame

	check(app.hazard_nodes.size() >= 2, "main scene creates 3D hazard nodes")
	check(app.destructible_nodes.size() >= 3, "main scene creates 3D destructible nodes")

	app.queue_free()
	await process_frame

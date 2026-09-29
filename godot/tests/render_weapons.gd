extends SceneTree
## Renders the arena weapons: all 8 lying on the stage, one wielded, one projectile.
## Usage: godot --path godot --script res://tests/render_weapons.gd -- --out=<dir>

const Combat = preload("res://scripts/combat.gd")
var out_dir := "user://"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
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
	app.apply_arena("volcano_sanctum")
	app.start_round("manual")
	app.sim.countdown = 0.0
	var sim = app.sim
	var ids: Array = Combat.WEAPONS.keys()
	for k in range(ids.size()):
		sim.spawn_weapon(ids[k], -6.3 + k * 1.8, 0.15)
	sim.fighters[0].x = -2.0
	sim.fighters[1].x = 3.0
	await frames(40)
	await shot("weapons_lineup.png")
	# Give P1 the hero sword and let it swing.
	var sw: int = sim.spawn_weapon("sword_hero", sim.fighters[0].x, 0.15)
	sim.equip_weapon(0, sw)
	sim.fighters[0].facing = 1
	await frames(20)
	await shot("weapons_wield_idle.png")
	sim.queue_attack(0, false)
	await frames(9)
	await shot("weapons_wield_attack.png")
	await frames(40)
	var cr: int = sim.spawn_weapon("sword_crescent", sim.fighters[0].x, 0.15)
	sim.drop_weapon(0, "break")
	sim.equip_weapon(0, cr)
	sim.fighters[0].cooldowns = [0.0, 0.0]
	sim.queue_attack(0, true)
	await frames(24)
	await shot("weapons_crescent.png")
	quit()

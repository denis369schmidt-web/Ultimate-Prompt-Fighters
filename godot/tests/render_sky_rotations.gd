extends SceneTree
## Renders each arena's sky dome at 4 rotations (0/90/180/270°) to pick the best view.
## Usage: godot --path godot --script res://tests/render_sky_rotations.gd -- --out=<dir>

var out_dir := "user://"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
	call_deferred("run")

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for n in range(5): await process_frame
	app.battle_hud_top.hide()
	app.selection.hide()
	for arena in app.ARENAS:
		app.apply_arena(arena)
		app.cinematic = true
		app.camera.position = Vector3(0, 2.5, 13)
		app.camera.look_at(Vector3(0, 2.0, 0))
		var dome: MeshInstance3D = null
		for c in app.arena_builder.get_children():
			if c is MeshInstance3D and c.mesh is SphereMesh and c.mesh.radius > 100.0: dome = c
		for rot in [0, 90, 180, 270]:
			if dome: dome.rotation_degrees.y = rot
			for n in range(3): await process_frame
			await RenderingServer.frame_post_draw
			root.get_viewport().get_texture().get_image().save_png(out_dir.path_join("sky_%s_%d.png" % [arena, rot]))
		print("CAPTURED ", arena)
	quit()

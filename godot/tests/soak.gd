extends SceneTree
## Soak test: every fighter in a full AI match, every arena, every boss, the team modes – with
## finishers and gore on. Engine errors land in the log; the run prints one line per match.
## Usage: godot [--headless] --path godot --script res://tests/soak.gd [-- --frames=600 --only=fighters|arenas|bosses|teams]

const Bosses = preload("res://scripts/bosses.gd")
var frames := 600
var only := ""

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--frames="): frames = int(arg.trim_prefix("--frames="))
		if arg.begins_with("--only="): only = arg.trim_prefix("--only=")
	call_deferred("run")

func play(app, label: String) -> void:
	var n := 0
	while n < frames and app.active and app.sim.result == -2:
		await physics_frame
		n += 1
	var res: int = app.sim.result
	var vram: float = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0
	var tex_mem: float = Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0
	print("SOAK %s frames=%d result=%d vram=%.0fMB tex=%.0fMB nodes=%d" % [label, n, res, vram, tex_mem, Performance.get_monitor(Performance.OBJECT_NODE_COUNT)])
	# Let finishers / result screens play out, then reset.
	for k in range(30): await process_frame
	app.show_selection()
	for k in range(3): await process_frame

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for k in range(5): await process_frame
	app.finishers_on = true
	app.gore_on = true
	var presets: Array = []
	for k in range(app.mk_presets.size()):
		if app.mk_presets[k].id != "fusionskammer": presets.append(k)
	var arenas: Array = []
	for aid in app.ARENAS:
		if not app.ARENAS[aid].get("boss", false): arenas.append(aid)

	if only == "" or only == "fighters":
		for k in range(presets.size()):
			app.on_mk_fighter_selected(0, presets[k])
			app.on_mk_fighter_selected(1, presets[(k + 7) % presets.size()])
			app.apply_arena(arenas[k % arenas.size()])
			app.start_round("autonomous")
			await play(app, "fighter %s vs %s @%s" % [app.mk_presets[presets[k]].id, app.mk_presets[presets[(k + 7) % presets.size()]].id, app.current_arena])

	if only == "" or only == "arenas":
		for k in range(arenas.size()):
			app.on_mk_fighter_selected(0, presets[(k * 3) % presets.size()])
			app.on_mk_fighter_selected(1, presets[(k * 5 + 1) % presets.size()])
			app.apply_arena(arenas[k])
			app.start_round("autonomous")
			await play(app, "arena %s" % arenas[k])

	if only == "" or only == "bosses":
		for bid in Bosses.ORDER:
			app.start_boss(bid, false)
			# Let the AI fight for the heroes too.
			app.sim.mode = "autonomous"
			await play(app, "boss %s" % bid)
			app.boss_active = false

	if only == "" or only == "teams":
		for tm in ["ffa", "2v2", "3v1"]:
			while app.team_mode != tm: app._toggle_player_count()
			app.start_round("autonomous")
			await play(app, "team %s" % tm)
		while app.team_mode != "1v1": app._toggle_player_count()
	print("SOAK_DONE")
	quit()

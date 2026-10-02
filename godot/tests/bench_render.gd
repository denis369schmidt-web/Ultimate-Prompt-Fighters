extends SceneTree
## Rendered performance benchmark: real fights (AI vs AI) in several arenas, VSync off,
## frame cap off. Prints average/percentile frame times and draw statistics per arena.
## Usage: godot --path godot --script res://tests/bench_render.gd [--resolution 1920x1080] -- [--frames=600]

var frames := 600
var tweaks: Array = []   # --tweak=ssao,msaa,shadow,scale,glow,fog,sdfgi: switches one cost off to measure it
const SETUPS := [["kairo", "zip", "blood_moon"], ["dragon", "glaciem", "volcano_sanctum"], ["raiga", "tobi", "imperial_colosseum"], ["hikaru", "jubei", "frozen_summit"]]

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--frames="): frames = int(arg.trim_prefix("--frames="))
		if arg.begins_with("--tweak="): tweaks = Array(arg.trim_prefix("--tweak=").split(","))
	call_deferred("run")

func preset_index(app, id: String) -> int:
	for k in range(app.mk_presets.size()):
		if app.mk_presets[k].id == id: return k
	return 0

func run() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	for k in range(10): await process_frame
	app.hide_title()
	Engine.max_fps = 0
	var env: Environment = app.world_env.environment
	if "ssao" in tweaks: env.ssao_enabled = false
	if "glow" in tweaks: env.glow_enabled = false
	if "fog" in tweaks: env.fog_enabled = false
	if "msaa" in tweaks: root.get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	if "scale" in tweaks: root.get_viewport().scaling_3d_scale = 0.75
	if "shadow" in tweaks:
		app.sunlight.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		RenderingServer.directional_shadow_atlas_set_size(2048, true)
	if "softshadow" in tweaks: RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
	if "scale50" in tweaks: root.get_viewport().scaling_3d_scale = 0.5
	if "fxaa" in tweaks: root.get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	if "ssaohalf" in tweaks: RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW, true, 0.5, 2, 50, 300)
	if "fsr85" in tweaks:
		root.get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
		root.get_viewport().scaling_3d_scale = 0.85
	if "balanced" in tweaks: app.apply_quality("balanced")
	if "high" in tweaks: app.apply_quality("high")
	print("PFU_BENCH_TWEAKS ", tweaks)
	var all: Array = []
	for s in SETUPS:
		app.on_mk_fighter_selected(0, preset_index(app, s[0]))
		app.on_mk_fighter_selected(1, preset_index(app, s[1]))
		if app.ARENAS.has(s[2]): app.apply_arena(s[2])
		app.start_round("autonomous")
		for k in range(90): await process_frame
		var times: Array = []
		var draws := 0.0
		var prims := 0.0
		var proc := 0.0
		var last: int = Time.get_ticks_usec()
		for k in range(frames):
			await process_frame
			var now: int = Time.get_ticks_usec()
			times.append(float(now - last) / 1000.0)
			last = now
			draws += Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
			prims += Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
			proc += Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
		times.sort()
		var avg := 0.0
		for t in times: avg += t
		avg /= times.size()
		all.append(avg)
		print("PFU_BENCH arena=%s avg_ms=%.2f fps=%.0f p95_ms=%.2f p99_ms=%.2f draws=%.0f prims=%.0f nodes=%d process_ms=%.2f" % [app.current_arena, avg, 1000.0 / avg,
			times[int(times.size() * 0.95)], times[int(times.size() * 0.99)], draws / frames, prims / frames, Performance.get_monitor(Performance.OBJECT_NODE_COUNT), proc / frames])
		app.show_selection()
		for k in range(5): await process_frame
	var total := 0.0
	for a in all: total += a
	print("PFU_BENCH_SUMMARY avg_ms=%.2f fps=%.0f" % [total / all.size(), 1000.0 / (total / all.size())])
	quit()

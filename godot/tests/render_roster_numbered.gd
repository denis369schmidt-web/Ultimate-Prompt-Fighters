extends SceneTree
## Renders every roster fighter full-body with its roster number above the head and its
## name below, and tiles them into one lineup image.
## Usage: godot --path godot --script res://tests/render_roster_numbered.gd -- --out=<file.png>

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")
const CELL_W := 300
const CELL_H := 460
const PER_ROW := 8

var out_file := "user://roster_numbered.png"

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_file = arg.trim_prefix("--out=")
	call_deferred("run")

## Top of the model in world space: the higher of head bone and mesh bounds (skinned
## Mixamo bounds stop at the hips).
func model_top(view) -> float:
	var top := -INF
	if view.skeleton != null and view.bone_map.has("head"):
		var t: Transform3D = view.skeleton.global_transform * view.skeleton.get_bone_global_pose(view.bone_map["head"])
		top = t.origin.y + 0.22 * maxf(0.5, t.origin.y) / 1.6
	for m in view.model.find_children("*", "MeshInstance3D", true, false):
		if m.mesh == null or not m.is_visible_in_tree(): continue
		var box: AABB = m.global_transform * m.mesh.get_aabb()
		top = maxf(top, box.end.y)
	return top if top > -INF else 1.8

## Horizontal extent of the model's meshes (half-width from the fighter's center).
func model_half_width(view) -> float:
	var w := 0.0
	for m in view.model.find_children("*", "MeshInstance3D", true, false):
		if m.mesh == null or not m.is_visible_in_tree(): continue
		var box: AABB = m.global_transform * m.mesh.get_aabb()
		w = maxf(w, maxf(absf(box.position.x), absf(box.end.x)))
	return w

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var presets: Array = app.mk_presets.duplicate(true)
	app.queue_free()
	await process_frame

	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_energy = 0.7
	env.environment.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.environment.glow_enabled = true
	env.environment.glow_intensity = 0.3
	world.add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-25, 35, 0)
	key.light_energy = 1.7
	world.add_child(key)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-15, 160, 0)
	rim.light_energy = 2.6
	world.add_child(rim)
	var cam := Camera3D.new()
	cam.fov = 30
	world.add_child(cam)
	cam.current = true

	var cells: Array = []
	var number := 0
	for preset in presets:
		if preset.id == "fusionskammer": continue
		number += 1
		var profile: Dictionary = Prompt.interpret(preset.prompt, 0)
		var col: Color = profile.get("color", Color("49def4"))
		env.environment.background_color = col.darkened(0.85)
		env.environment.ambient_light_color = col.lerp(Color.WHITE, 0.6)
		rim.light_color = col.lightened(0.2)
		var view = FighterView.new()
		world.add_child(view)
		view.setup(profile)
		for n in range(24):
			view.update_state({"x": 0.0, "y": 0.0, "facing": 1, "pose": "Idle", "blocking": false}, 1.0 / 60.0)
			view.model.rotation.y = 0.35
			await process_frame
		var top: float = clampf(model_top(view), 0.6, 4.5)
		var num := Label3D.new()
		num.text = str(number)
		num.font_size = 128
		num.outline_size = 28
		num.modulate = col.lightened(0.35)
		num.outline_modulate = Color.BLACK
		num.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		num.no_depth_test = true
		num.pixel_size = 0.0035 * top / 1.8
		num.position = Vector3(0, top + 0.28 * top / 1.8, 0)
		world.add_child(num)
		var name_l := Label3D.new()
		name_l.text = str(preset.get("name", profile.get("name", profile.family)))
		name_l.font_size = 64
		name_l.outline_size = 16
		name_l.outline_modulate = Color.BLACK
		name_l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		name_l.no_depth_test = true
		name_l.pixel_size = 0.0028 * top / 1.8
		name_l.position = Vector3(0, -0.2 * top / 1.8, 0)
		world.add_child(name_l)
		# Frame the whole body plus number and name.
		var span: float = maxf(top * 1.55, model_half_width(view) * 2.1 * CELL_H / CELL_W)
		var mid: float = top * 0.52
		cam.position = Vector3(0, mid, span / (2.0 * tan(deg_to_rad(cam.fov * 0.5))) + 0.6)
		cam.look_at(Vector3(0, mid, 0))
		await process_frame
		await RenderingServer.frame_post_draw
		var img: Image = root.get_viewport().get_texture().get_image()
		var h: int = img.get_height()
		var w: int = int(h * float(CELL_W) / CELL_H)
		img = img.get_region(Rect2i((img.get_width() - w) / 2, 0, w, h))
		img.resize(CELL_W, CELL_H, Image.INTERPOLATE_LANCZOS)
		cells.append(img)
		print("FIGHTER %d %s" % [number, name_l.text])
		view.queue_free()
		num.queue_free()
		name_l.queue_free()
		await process_frame

	var rows: int = ceili(cells.size() / float(PER_ROW))
	var sheet := Image.create(CELL_W * PER_ROW, CELL_H * rows, false, cells[0].get_format())
	sheet.fill(Color("0d1017"))
	for k in range(cells.size()):
		sheet.blit_rect(cells[k], Rect2i(0, 0, CELL_W, CELL_H), Vector2i((k % PER_ROW) * CELL_W, (k / PER_ROW) * CELL_H))
	sheet.save_png(out_file)
	print("SHEET ", out_file, " ", cells.size(), " fighters")
	quit()

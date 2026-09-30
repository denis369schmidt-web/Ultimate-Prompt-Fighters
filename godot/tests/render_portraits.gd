extends SceneTree
## Renders a head-and-shoulders portrait for every roster fighter from its real 3D model
## (element-colored backdrop and rim light) into assets/textures/characters/portraits/.
## Usage: godot --path godot --script res://tests/render_portraits.gd [-- --only=ninja,golem]

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")
const OUT := "res://assets/textures/characters/portraits"
const SIZE := 256

var only: Array = []

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--only="): only = Array(arg.trim_prefix("--only=").split(","))
	call_deferred("run")

## Top of the head in world space: head bone if rigged, else from the mesh bounds.
func head_point(view) -> Vector3:
	if view.skeleton != null and view.bone_map.has("head"):
		var t: Transform3D = view.skeleton.global_transform * view.skeleton.get_bone_global_pose(view.bone_map["head"])
		return t.origin + Vector3(0, 0.06, 0)
	var top := -INF
	for m in view.model.find_children("*", "MeshInstance3D", true, false):
		if m.mesh == null: continue
		var box: AABB = m.global_transform * m.mesh.get_aabb()
		top = maxf(top, box.end.y)
	return Vector3(view.global_position.x, (top if top > -INF else 1.7) - 0.18, 0)

func run() -> void:
	var app = load("res://main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var presets: Array = app.mk_presets.duplicate(true)
	app.queue_free()
	await process_frame

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_energy = 0.7
	env.environment.tonemap_mode = Environment.TONE_MAPPER_AGX
	env.environment.glow_enabled = true
	env.environment.glow_intensity = 0.4
	world.add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-25, 35, 0)
	key.light_energy = 1.7
	world.add_child(key)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-15, 160, 0)
	rim.light_energy = 3.0
	world.add_child(rim)
	var cam := Camera3D.new()
	cam.fov = 28
	world.add_child(cam)
	cam.current = true

	for preset in presets:
		if preset.id == "fusionskammer": continue
		var profile: Dictionary = Prompt.interpret(preset.prompt, 0)
		if not only.is_empty() and not profile.family in only: continue
		var col: Color = profile.get("color", Color("49def4"))
		env.environment.background_color = col.darkened(0.82)
		env.environment.ambient_light_color = col.lerp(Color.WHITE, 0.6)
		rim.light_color = col.lightened(0.2)
		var view = FighterView.new()
		world.add_child(view)
		view.setup(profile)
		for n in range(24):
			view.update_state({"x": 0.0, "y": 0.0, "facing": 1, "pose": "Idle", "blocking": false}, 1.0 / 60.0)
			view.model.rotation.y = 0.35
			await process_frame
		var box: AABB = view._model_bounds()
		if not (view.bone_map.has("left_arm") and view.bone_map.has("right_arm")) and box.size.x > box.size.y * 0.9:
			# Creatures (quadrupeds, wide scans): frame the upper two thirds of the whole body.
			var target := Vector3(box.get_center().x, box.position.y + box.size.y * 0.62, 0)
			var span: float = maxf(box.size.y * 0.8, box.size.x * 0.75)
			cam.position = target + Vector3(0.1, 0.1, span * 0.5 / tan(deg_to_rad(cam.fov * 0.5)) + box.size.z * 0.5)
			cam.look_at(target)
		else:
			var head: Vector3 = head_point(view)
			var height: float = maxf(0.8, head.y)
			var target := head + Vector3(0, -0.2 * height / 1.8, 0)
			cam.position = target + Vector3(0.12, 0.04, 1.55 * height / 1.8)
			cam.look_at(target)
		await process_frame
		await RenderingServer.frame_post_draw
		var img: Image = root.get_viewport().get_texture().get_image()
		var side: int = mini(img.get_width(), img.get_height())
		img = img.get_region(Rect2i((img.get_width() - side) / 2, (img.get_height() - side) / 2, side, side))
		img.resize(SIZE, SIZE, Image.INTERPOLATE_LANCZOS)
		img.save_png(ProjectSettings.globalize_path(OUT.path_join("portrait_%s.png" % profile.family)))
		print("PORTRAIT ", profile.family)
		view.queue_free()
		await process_frame
	quit()

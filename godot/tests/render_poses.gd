extends SceneTree
## Renders a lineup of fighters in every procedural pose (one PNG per pose) to review the
## rig-independent animation system. Usage:
## godot --path godot --script res://tests/render_poses.gd -- --out=<dir> [--poses=Idle,Move]

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

var PROMPTS := [
	"Blitzschneller Schattenninja mit elektrischen Klingen",
	"Steel Knight Ritter in Vollplatte mit eisernem Schild",
	"Korsar Corsair Piratenkapitän mit Entermesser und Donnerbüchse",
	"Strahlende Moe Valkyrie Kriegerin mit Lichtflügeln und Rapier",
	"Samurai Dreyar Meister mit Wind-Klingen und Sturm-Schritten",
	"Void Specter crystal phantom warrior with void lance",
]
var out_dir := "user://"
var prefix := ""
var poses := ["Idle", "Move", "Jump", "Fall", "Attack", "SpecialAttack", "Block", "HitReact", "Victory", "Defeat"]

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): out_dir = arg.trim_prefix("--out=")
		if arg.begins_with("--prefix="): prefix = arg.trim_prefix("--prefix=")
		if arg.begins_with("--poses="): poses = arg.trim_prefix("--poses=").split(",")
		if arg.begins_with("--prompts="): PROMPTS = Array(arg.trim_prefix("--prompts=").split("|"))
	call_deferred("run")

func run() -> void:
	var world := Node3D.new()
	root.add_child(world)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("1b2230")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("8090a8")
	env.environment.ambient_light_energy = 0.8
	world.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-35, -30, 0)
	sun.light_energy = 1.6
	world.add_child(sun)
	var cam := Camera3D.new()
	cam.position = Vector3(0, 1.1, 8.2)
	cam.fov = 45
	world.add_child(cam)
	cam.look_at(Vector3(0, 1.0, 0))
	cam.current = true

	var views: Array = []
	for k in range(PROMPTS.size()):
		var v = FighterView.new()
		world.add_child(v)
		v.setup(Prompt.interpret(PROMPTS[k], k % 2))
		views.append(v)
	for pose in poses:
		for f in range(40):
			for k in range(views.size()):
				var spacing: float = minf(2.0, 12.0 / maxf(1.0, views.size()))
				var x: float = -spacing * (views.size() - 1) * 0.5 + k * spacing
				views[k].update_state({"x": x, "y": 0.0, "facing": 1, "pose": pose, "blocking": false}, 1.0 / 60.0)
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_viewport().get_texture().get_image().save_png(out_dir.path_join("%spose_%s.png" % [prefix, pose]))
		print("CAPTURED ", pose)
	quit()

extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
    var scene = Node3D.new()
    root.add_child(scene)

    var cam = Camera3D.new()
    cam.position = Vector3(0, 1.25, 2.7)
    scene.add_child(cam)
    cam.look_at_from_position(cam.position, Vector3(0, 1.05, 0))
    cam.current = true

    var env = WorldEnvironment.new()
    env.environment = Environment.new()
    env.environment.background_mode = Environment.BG_CLEAR_COLOR
    scene.add_child(env)

    var light = DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-35, -25, 0)
    light.light_energy = 1.8
    scene.add_child(light)

    var prof1 = Prompt.interpret("lava golem", 0)
    var prof2 = Prompt.interpret("electric ninja", 1)

    var v1 = FighterView.new()
    scene.add_child(v1)
    v1.setup(prof1)
    v1.position.x = -0.95
    v1.update_state({"x": -0.95, "y": 0.0, "facing": 1.0, "pose": "Idle"}, 1.0)

    var v2 = FighterView.new()
    scene.add_child(v2)
    v2.setup(prof2)
    v2.position.x = 0.95
    v2.update_state({"x": 0.95, "y": 0.0, "facing": -1.0, "pose": "Idle"}, 1.0)

    for f in range(20):
        await process_frame

    var img = root.get_viewport().get_texture().get_image()
    if img:
        img.save_png("res://test_new_models.png")
        print("SAVED_TEST_RENDER")

    quit(0)

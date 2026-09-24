extends SceneTree

func _initialize():
    var cam = Camera3D.new()
    cam.position = Vector3(0, 1.35, 3.2)
    root.add_child(cam)
    cam.look_at_from_position(cam.position, Vector3(0, 1.1, 0))
    cam.current = true

    var env = WorldEnvironment.new()
    env.environment = Environment.new()
    env.environment.background_mode = Environment.BG_COLOR
    env.environment.background_color = Color("0d1117")
    env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.environment.ambient_light_color = Color("2a3240")
    env.environment.ambient_light_energy = 0.9
    env.environment.glow_enabled = true
    env.environment.glow_intensity = 0.8
    env.environment.glow_bloom = 0.25
    root.add_child(env)

    var light = DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-35, -30, 0)
    light.light_color = Color("ffe8d6")
    light.light_energy = 1.8
    root.add_child(light)

    var fill_light = DirectionalLight3D.new()
    fill_light.rotation_degrees = Vector3(25, 140, 0)
    fill_light.light_color = Color("507090")
    fill_light.light_energy = 0.8
    root.add_child(fill_light)

    var Prompt = load("res://scripts/prompt_interpreter.gd")
    var FighterView = load("res://scripts/fighter_view.gd")

    # Player 1: Glacial Frost Titan
    var v1 = FighterView.new()
    root.add_child(v1)
    v1.setup(Prompt.interpret("frost titan golem", 0))
    v1.position.x = -1.1

    # Player 2: Fire Shinobi
    var v2 = FighterView.new()
    root.add_child(v2)
    v2.setup(Prompt.interpret("fire flame ninja", 1))
    v2.position.x = 1.1

    for i in range(12):
        await process_frame

    var img = root.get_viewport().get_texture().get_image()
    if img:
        img.save_png("res://test_frost_fire_render.png")
        print("FROST_FIRE_SAVED: ", img.get_size())
    else:
        print("NO_IMG")
    quit(0)

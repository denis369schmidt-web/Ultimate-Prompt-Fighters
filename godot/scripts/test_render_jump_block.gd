extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
    var scene = Node3D.new()
    root.add_child(scene)

    var cam = Camera3D.new()
    cam.position = Vector3(0, 1.45, 3.2)
    scene.add_child(cam)
    cam.look_at_from_position(cam.position, Vector3(0, 1.15, 0))
    cam.current = true

    var env = WorldEnvironment.new()
    env.environment = Environment.new()
    env.environment.background_mode = Environment.BG_SKY
    var sky = Sky.new()
    var sky_mat = PanoramaSkyMaterial.new()
    sky_mat.panorama = load("res://assets/textures/arenas/sky_blood_moon.png")
    sky.sky_material = sky_mat
    env.environment.sky = sky
    env.environment.sky_rotation = Vector3(0, deg_to_rad(90), 0)
    env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.environment.ambient_light_energy = 0.65
    env.environment.glow_enabled = true
    env.environment.glow_intensity = 0.85
    env.environment.glow_bloom = 0.32
    env.environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
    env.environment.ssao_enabled = true
    env.environment.adjustment_enabled = true
    env.environment.adjustment_contrast = 1.10
    env.environment.adjustment_saturation = 1.14
    env.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
    scene.add_child(env)

    # Arena floor with shadows
    var floor_mesh = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(24, 24)
    floor_mesh.mesh = plane
    var f_mat = StandardMaterial3D.new()
    f_mat.albedo_texture = load("res://assets/textures/arenas/floor_stone_albedo.png")
    f_mat.normal_enabled = true
    f_mat.normal_texture = load("res://assets/textures/arenas/floor_stone_normal.png")
    f_mat.normal_scale = 1.6
    f_mat.uv1_scale = Vector3(4, 4, 4)
    f_mat.roughness = 0.82
    floor_mesh.material_override = f_mat
    scene.add_child(floor_mesh)

    var light = DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-35, -25, 0)
    light.light_color = Color("fff0e2")
    light.light_energy = 1.65
    light.shadow_enabled = true
    light.shadow_blur = 1.4
    scene.add_child(light)

    var fill = DirectionalLight3D.new()
    fill.rotation_degrees = Vector3(20, 150, 0)
    fill.light_color = Color("6895bd")
    fill.light_energy = 0.65
    scene.add_child(fill)

    var prof1 = Prompt.interpret("lava golem", 0)
    var prof2 = Prompt.interpret("electric ninja", 1)

    # Golem is mid-air leaping in jump!
    var v1 = FighterView.new()
    scene.add_child(v1)
    v1.setup(prof1)
    v1.update_state({"x": -0.85, "y": 0.85, "facing": 1.0, "pose": "Jump", "blocking": false}, 1.0)

    # Ninja is on ground holding block with hexagonal energy shield active!
    var v2 = FighterView.new()
    scene.add_child(v2)
    v2.setup(prof2)
    v2.update_state({"x": 0.85, "y": 0.0, "facing": -1.0, "pose": "Block", "blocking": true}, 1.0)

    for f in range(25):
        await process_frame

    var img = root.get_viewport().get_texture().get_image()
    if img:
        img.save_png("res://test_jump_block_render.png")
        print("SAVED_JUMP_BLOCK_RENDER")

    quit(0)

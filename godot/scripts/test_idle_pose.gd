extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func adjust_idle_animation(anim: Animation, family: String) -> void:
    for t in range(anim.get_track_count()):
        var path = str(anim.track_get_path(t))
        if anim.track_get_type(t) == Animation.TYPE_ROTATION_3D:
            if "upperarm_l" in path:
                # Rotate left arm down and slightly forward
                var q_down = Quaternion.from_euler(Vector3(deg_to_rad(-15), deg_to_rad(10), deg_to_rad(45 if family == "golem" else 42)))
                for k in range(anim.track_get_key_count(t)):
                    var orig: Quaternion = anim.track_get_key_value(t, k)
                    anim.track_set_key_value(t, k, orig * q_down)
            elif "upperarm_r" in path:
                # Rotate right arm down and slightly forward
                var q_down = Quaternion.from_euler(Vector3(deg_to_rad(-15), deg_to_rad(-10), deg_to_rad(-45 if family == "golem" else -42)))
                for k in range(anim.track_get_key_count(t)):
                    var orig: Quaternion = anim.track_get_key_value(t, k)
                    anim.track_set_key_value(t, k, orig * q_down)
            elif "lowerarm_l" in path:
                var q_in = Quaternion.from_euler(Vector3(deg_to_rad(20), deg_to_rad(-15), deg_to_rad(25)))
                for k in range(anim.track_get_key_count(t)):
                    var orig: Quaternion = anim.track_get_key_value(t, k)
                    anim.track_set_key_value(t, k, orig * q_in)
            elif "lowerarm_r" in path:
                var q_in = Quaternion.from_euler(Vector3(deg_to_rad(20), deg_to_rad(15), deg_to_rad(-25)))
                for k in range(anim.track_get_key_count(t)):
                    var orig: Quaternion = anim.track_get_key_value(t, k)
                    anim.track_set_key_value(t, k, orig * q_in)

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
    env.environment.background_mode = Environment.BG_SKY
    var sky = Sky.new()
    var sky_mat = PanoramaSkyMaterial.new()
    sky_mat.panorama = load("res://assets/textures/arenas/sky_blood_moon.png")
    sky.sky_material = sky_mat
    env.environment.sky = sky
    env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.environment.ambient_light_energy = 0.85
    env.environment.glow_enabled = true
    env.environment.glow_intensity = 0.75
    env.environment.glow_bloom = 0.22
    env.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
    scene.add_child(env)

    var floor_mesh = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(24, 24)
    floor_mesh.mesh = plane
    var f_mat = StandardMaterial3D.new()
    f_mat.albedo_texture = load("res://assets/textures/arenas/floor_stone_albedo.png")
    f_mat.normal_enabled = true
    f_mat.normal_texture = load("res://assets/textures/arenas/floor_stone_normal.png")
    f_mat.normal_scale = 1.4
    f_mat.uv1_scale = Vector3(6, 6, 6)
    f_mat.roughness = 0.82
    floor_mesh.material_override = f_mat
    scene.add_child(floor_mesh)

    var light = DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-38, -32, 0)
    light.light_color = Color("ff7a50")
    light.light_energy = 1.75
    light.shadow_enabled = true
    scene.add_child(light)

    var v1 = FighterView.new()
    scene.add_child(v1)
    v1.setup(Prompt.interpret("armored lava golem", 0))
    adjust_idle_animation(v1.animation.get_animation(v1.clip_map["Idle"]), "golem")
    v1.position.x = -0.95
    v1.update_state({"x": -0.95, "facing": 1.0, "pose": "Idle"}, 1.0)

    var v2 = FighterView.new()
    scene.add_child(v2)
    v2.setup(Prompt.interpret("electric volt ninja", 1))
    adjust_idle_animation(v2.animation.get_animation(v2.clip_map["Idle"]), "ninja")
    v2.position.x = 0.95
    v2.update_state({"x": 0.95, "facing": -1.0, "pose": "Idle"}, 1.0)

    for f in range(24):
        v1.update_state({"x": -0.95, "facing": 1.0, "pose": "Idle"}, 0.016)
        v2.update_state({"x": 0.95, "facing": -1.0, "pose": "Idle"}, 0.016)
        await process_frame

    var img = root.get_viewport().get_texture().get_image()
    if img:
        img.save_png("res://test_improved_idle.png")
        print("IMPROVED_IDLE_SAVED")
    quit(0)

extends SceneTree

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const FighterView = preload("res://scripts/fighter_view.gd")

func _initialize():
    var pairs = [
        {"name": "showcase_lava_volt", "p1": "armored lava golem", "p2": "electric volt ninja", "sky": "res://assets/textures/arenas/sky_blood_moon.png", "sun_col": Color("ff7a50")},
        {"name": "showcase_frost_fire", "p1": "glacial frost titan golem", "p2": "fire flame shinobi ninja", "sky": "res://assets/textures/arenas/sky_pirate_galleon.png", "sun_col": Color("9df0ff")},
        {"name": "showcase_toxic_arctic", "p1": "toxic spore biohazard golem", "p2": "arctic ghost stealth ninja", "sky": "res://assets/textures/arenas/sky_mystic_grove.png", "sun_col": Color("64ffda")},
        {"name": "showcase_storm_crimson", "p1": "storm heavy thunder golem", "p2": "crimson blood ronin ninja", "sky": "res://assets/textures/arenas/sky_volcano_sanctum.png", "sun_col": Color("ffa040")}
    ]

    var floor_tex = load("res://assets/textures/arenas/floor_stone_albedo.png")
    var floor_norm = load("res://assets/textures/arenas/floor_stone_normal.png")

    for item in pairs:
        print("Rendering pair: ", item.name)
        var scene = Node3D.new()
        root.add_child(scene)

        var cam = Camera3D.new()
        cam.position = Vector3(0, 1.35, 3.1)
        scene.add_child(cam)
        cam.look_at_from_position(cam.position, Vector3(0, 1.12, 0))
        cam.current = true

        var env = WorldEnvironment.new()
        env.environment = Environment.new()
        env.environment.background_mode = Environment.BG_SKY
        var sky = Sky.new()
        var sky_mat = PanoramaSkyMaterial.new()
        sky_mat.panorama = load(item.sky)
        sky.sky_material = sky_mat
        env.environment.sky = sky
        env.environment.sky_rotation = Vector3(0, deg_to_rad(90), 0)
        env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
        env.environment.ambient_light_energy = 0.58
        env.environment.glow_enabled = true
        env.environment.glow_intensity = 0.75
        env.environment.glow_bloom = 0.25
        env.environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
        env.environment.ssao_enabled = true
        env.environment.ssao_radius = 1.6
        env.environment.ssao_intensity = 2.4
        env.environment.adjustment_enabled = true
        env.environment.adjustment_contrast = 1.10
        env.environment.adjustment_saturation = 1.12
        env.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
        env.environment.tonemap_exposure = 1.0
        scene.add_child(env)

        # Arena floor with shadows
        var floor_mesh = MeshInstance3D.new()
        var plane = PlaneMesh.new()
        plane.size = Vector2(24, 24)
        floor_mesh.mesh = plane
        var f_mat = StandardMaterial3D.new()
        f_mat.albedo_texture = floor_tex
        f_mat.normal_enabled = true
        f_mat.normal_texture = floor_norm
        f_mat.normal_scale = 1.6
        f_mat.uv1_scale = Vector3(4, 4, 4)
        f_mat.roughness = 0.82
        floor_mesh.material_override = f_mat
        scene.add_child(floor_mesh)

        # Main key light with soft directional shadows
        var light = DirectionalLight3D.new()
        light.rotation_degrees = Vector3(-38, -32, 0)
        light.light_color = item.sun_col
        light.light_energy = 1.25
        light.shadow_enabled = true
        light.shadow_blur = 1.2
        scene.add_child(light)

        # Back / Rim fill light
        var fill = DirectionalLight3D.new()
        fill.rotation_degrees = Vector3(20, 145, 0)
        fill.light_color = Color("85b2d9")
        fill.light_energy = 0.55
        scene.add_child(fill)

        var prof1 = Prompt.interpret(item.p1, 0)
        var prof2 = Prompt.interpret(item.p2, 1)

        var v1 = FighterView.new()
        scene.add_child(v1)
        v1.setup(prof1)
        v1.position.x = -0.95
        v1.update_state({"x": -0.95, "facing": 1.0, "pose": "Idle"}, 1.0)

        var v2 = FighterView.new()
        scene.add_child(v2)
        v2.setup(prof2)
        v2.position.x = 0.95
        v2.update_state({"x": 0.95, "facing": -1.0, "pose": "Idle"}, 1.0)

        for f in range(24):
            v1.update_state({"x": -0.95, "facing": 1.0, "pose": "Idle"}, 0.016)
            v2.update_state({"x": 0.95, "facing": -1.0, "pose": "Idle"}, 0.016)
            await process_frame

        var img = root.get_viewport().get_texture().get_image()
        if img:
            var path = "res://%s.png" % item.name
            img.save_png(path)
            print("Saved: ", path)

        scene.queue_free()
        await process_frame

    quit(0)

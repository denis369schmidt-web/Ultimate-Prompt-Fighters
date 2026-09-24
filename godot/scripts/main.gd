extends Node3D

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")
const FighterView = preload("res://scripts/fighter_view.gd")
const CYAN := Color("49def4")
const ORANGE := Color("ff925b")

const PORTRAITS = {
    "golem": preload("res://assets/textures/ui/portrait_golem.png"),
    "ninja": preload("res://assets/textures/ui/portrait_ninja.png"),
    "valkyrie": preload("res://assets/textures/ui/portrait_valkyrie.png"),
    "dragon": preload("res://assets/textures/ui/portrait_dragon.png"),
    "frost": preload("res://assets/textures/ui/portrait_frost.png"),
    "storm": preload("res://assets/textures/ui/portrait_storm.png"),
    "toxic": preload("res://assets/textures/ui/portrait_toxic.png"),
    "cyber": preload("res://assets/textures/ui/portrait_cyber.png"),
}

const HIT_SPARK = preload("res://assets/textures/vfx/hit_spark.png")
const LAVA_EMBER = preload("res://assets/textures/vfx/lava_ember.png")
const ELECTRIC_SPARK = preload("res://assets/textures/vfx/electric_spark.png")

const ARENAS = {
    "blood_moon": {
        "name": "BLOOD MOON TERRACE",
        "sky": preload("res://assets/textures/arenas/sky_blood_moon.png"),
        "thumb": preload("res://assets/textures/ui/thumb_blood_moon.png"),
        "floor": preload("res://assets/textures/arenas/floor_lava_albedo.png"),
        "floor_em": preload("res://assets/textures/arenas/floor_lava_emission.png"),
        "floor_norm": preload("res://assets/textures/arenas/floor_lava_normal.png"),
        "sun_color": Color("fff0e2"),
        "sun_rot": Vector3(-35, -25, 0),
        "ambient_color": Color("1c2b3d"),
        "fire_color": Color("ff6d2b")
    },
    "volcano_sanctum": {
        "name": "VOLCANIC DRAGON SANCTUM",
        "sky": preload("res://assets/textures/arenas/sky_volcano_sanctum.png"),
        "thumb": preload("res://assets/textures/ui/thumb_volcano_sanctum.png"),
        "floor": preload("res://assets/textures/arenas/floor_lava_albedo.png"),
        "floor_em": preload("res://assets/textures/arenas/floor_lava_emission.png"),
        "floor_norm": preload("res://assets/textures/arenas/floor_lava_normal.png"),
        "sun_color": Color("ffa040"),
        "sun_rot": Vector3(-50, -40, 0),
        "ambient_color": Color("66260d"),
        "fire_color": Color("ff8b26")
    },
    "imperial_colosseum": {
        "name": "IMPERIAL COLOSSEUM",
        "sky": preload("res://assets/textures/arenas/sky_imperial_colosseum.png"),
        "thumb": preload("res://assets/textures/ui/thumb_imperial_colosseum.png"),
        "floor": preload("res://assets/textures/arenas/floor_stone_albedo.png"),
        "floor_em": null,
        "floor_norm": preload("res://assets/textures/arenas/floor_stone_normal.png"),
        "sun_color": Color("ffecb5"),
        "sun_rot": Vector3(-45, -30, 0),
        "ambient_color": Color("4d596e"),
        "fire_color": Color("ffa44b")
    },
    "pirate_galleon": {
        "name": "PIRATE GALLEON DOCK",
        "sky": preload("res://assets/textures/arenas/sky_pirate_galleon.png"),
        "thumb": preload("res://assets/textures/ui/thumb_pirate_galleon.png"),
        "floor": preload("res://assets/textures/arenas/floor_stone_albedo.png"),
        "floor_em": null,
        "floor_norm": preload("res://assets/textures/arenas/floor_stone_normal.png"),
        "sun_color": Color("b5f5ff"),
        "sun_rot": Vector3(-40, 30, 0),
        "ambient_color": Color("244d5e"),
        "fire_color": Color("47e5ff")
    },
    "gladiator_fortress": {
        "name": "GLADIATOR BASTION",
        "sky": preload("res://assets/textures/arenas/sky_gladiator_fortress.png"),
        "thumb": preload("res://assets/textures/ui/thumb_gladiator_fortress.png"),
        "floor": preload("res://assets/textures/arenas/floor_stone_albedo.png"),
        "floor_em": null,
        "floor_norm": preload("res://assets/textures/arenas/floor_stone_normal.png"),
        "sun_color": Color("ffe8c2"),
        "sun_rot": Vector3(-55, -20, 0),
        "ambient_color": Color("4e4c43"),
        "fire_color": Color("ff9245")
    },
    "mystic_grove": {
        "name": "BIOLUMINESCENT GROVE",
        "sky": preload("res://assets/textures/arenas/sky_mystic_grove.png"),
        "thumb": preload("res://assets/textures/ui/thumb_mystic_grove.png"),
        "floor": preload("res://assets/textures/arenas/floor_stone_albedo.png"),
        "floor_em": null,
        "floor_norm": preload("res://assets/textures/arenas/floor_stone_normal.png"),
        "sun_color": Color("64ffda"),
        "sun_rot": Vector3(-45, -15, 0),
        "ambient_color": Color("143b34"),
        "fire_color": Color("3bfac8")
    }
}

var sim = Combat.new()
var views: Array = []
var camera: Camera3D
var selection: PanelContainer
var result_panel: PanelContainer
var result_label: Label
var status: Label
var timer: Label
var prompts: Array = []
var health_bars: Array = []
var health_text: Array = []
var names: Array = []
var special_text: Array = []
var profile_text: Array = []
var portrait_rects: Array = []
var audio: Dictionary = {}
var active := false
var paused := false
var accumulator := 0.0
var input_buffer: Array = [{"standard": false, "special": false}, {"standard": false, "special": false}]
var previous_manual := [{}, {}]
var preview_time := 0.0
var smoke := false
var capture_dir := ""
var smoke_ticks := 0
var smoke_rounds := 0
var smoke_report := {"hits": 0, "restarts": 0}
var root_ui: Control
var capture_selection := false

var current_arena := "blood_moon"
var world_env: WorldEnvironment
var sunlight: DirectionalLight3D
var fire_lights: Array = []
var arena_model: Node3D
var camera_shake := 0.0
var camera_punch := Vector2.ZERO   # directional punch for hits
var embers: CPUParticles3D

# Upgrade: super meter bars, delay health bars, combo labels
var super_bars: Array = []
var delay_hp: Array = [0.0, 0.0]      # tracks the "delayed" red bar
var delay_hp_bars: Array = []
var combo_labels: Array = []
var hitstop_freeze := 0               # global rendering freeze frames
var lives_labels: Array = []
var platform_nodes: Array = []
var platform_trims: Array = []
var item_nodes: Array = []

func _ready() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg == "--smoke": smoke = true
        if arg == "--capture-selection": capture_selection = true
        if arg.begins_with("--capture-dir="): capture_dir = arg.trim_prefix("--capture-dir=")
    setup_inputs()
    setup_world()
    setup_ui()
    setup_audio()
    restore_prompts()
    refresh_previews()
    get_window().focus_exited.connect(func():
        if active and sim.mode == "manual" and not smoke: paused = true)
    if smoke: start_round("autonomous")
    elif capture_selection and not capture_dir.is_empty():
        await get_tree().create_timer(0.5).timeout
        await capture("godot-selection.png")
        get_tree().quit()

func setup_inputs() -> void:
    var mapping := {
        "p1_left": KEY_A, "p1_right": KEY_D, "p1_jump": KEY_W, "p1_block": KEY_S, "p1_standard": KEY_F, "p1_special": KEY_G, "p1_grab": KEY_E,
        "p2_left": KEY_LEFT, "p2_right": KEY_RIGHT, "p2_jump": KEY_UP, "p2_block": KEY_DOWN, "p2_standard": KEY_K, "p2_special": KEY_L, "p2_grab": KEY_O
    }
    for action in mapping:
        if not InputMap.has_action(action): InputMap.add_action(action)
        var event := InputEventKey.new()
        event.physical_keycode = mapping[action]
        InputMap.action_add_event(action, event)

func setup_world() -> void:
    world_env = WorldEnvironment.new()
    world_env.environment = Environment.new()
    world_env.environment.background_mode = Environment.BG_SKY
    world_env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    world_env.environment.ambient_light_energy = 0.95
    world_env.environment.tonemap_mode = Environment.TONE_MAPPER_ACES
    world_env.environment.tonemap_exposure = 1.15
    world_env.environment.glow_enabled = true
    world_env.environment.glow_bloom = 0.35
    world_env.environment.glow_intensity = 0.85
    world_env.environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
    world_env.environment.glow_hdr_threshold = 0.85
    world_env.environment.fog_enabled = true
    world_env.environment.fog_light_color = Color(0.12, 0.08, 0.22)
    world_env.environment.fog_density = 0.008
    world_env.environment.fog_sky_affect = 0.15
    world_env.environment.ssao_enabled = true
    world_env.environment.ssao_radius = 2.2
    world_env.environment.ssao_intensity = 3.2
    world_env.environment.ssao_power = 2.0
    world_env.environment.ssr_enabled = true
    world_env.environment.ssr_max_steps = 64
    world_env.environment.ssr_fade_in = 0.15
    world_env.environment.ssr_fade_out = 2.0
    world_env.environment.ssr_depth_tolerance = 0.2
    world_env.environment.adjustment_enabled = true
    world_env.environment.adjustment_contrast = 1.15
    world_env.environment.adjustment_saturation = 1.22
    add_child(world_env)

    arena_model = load("res://assets/models/arena.glb").instantiate()
    arena_model.scale = Vector3.ONE * 0.016
    add_child(arena_model)
    for mesh in arena_model.find_children("*", "MeshInstance3D", true, false):
        mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

    sunlight = DirectionalLight3D.new()
    sunlight.shadow_enabled = true
    sunlight.shadow_bias = 0.02
    sunlight.shadow_blur = 1.8
    sunlight.light_energy = 2.2
    sunlight.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
    add_child(sunlight)

    fire_lights.clear()
    for side in [-1, 1]:
        var fire := OmniLight3D.new()
        fire.position = Vector3(side * 5.5, 1.2, 0.8)
        fire.light_energy = 2.8
        fire.omni_range = 5.5
        fire.shadow_enabled = true
        add_child(fire)
        fire_lights.append(fire)

    # Ambient particles (floating embers)
    embers = CPUParticles3D.new()
    embers.amount = 55
    embers.lifetime = 5.0
    embers.preprocess = 2.0
    embers.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
    embers.emission_box_extents = Vector3(10.0, 0.2, 3.0)
    embers.direction = Vector3(0.05, 1.0, 0.0)
    embers.spread = 15.0
    embers.gravity = Vector3(0, 0.1, 0)
    embers.initial_velocity_min = 0.5
    embers.initial_velocity_max = 1.3
    var p_mat := StandardMaterial3D.new()
    p_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    p_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    p_mat.albedo_texture = LAVA_EMBER
    p_mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
    var quad := QuadMesh.new()
    quad.size = Vector2(0.12, 0.12)
    quad.material = p_mat
    embers.mesh = quad
    add_child(embers)

    camera = Camera3D.new()
    camera.position = Vector3(0, 1.55, 5.2)
    camera.fov = 52
    camera.far = 180
    add_child(camera)
    camera.look_at(Vector3(0, 1.15, 0.0))
    camera.current = true

    setup_platforms()
    setup_items()
    apply_arena(current_arena)

func setup_items() -> void:
    for node in item_nodes: node.queue_free()
    item_nodes.clear()

    var stone_tex: Texture2D = preload("res://assets/textures/characters/golem_rock_albedo.png")
    var stone_norm: Texture2D = preload("res://assets/textures/characters/golem_rock_normal.png")

    for i in range(sim.items.size()):
        var it_data: Dictionary = sim.items[i]
        var root_item := Node3D.new()
        root_item.position = Vector3(it_data.x, it_data.y, 0.0)
        add_child(root_item)
        item_nodes.append(root_item)

        var mesh_inst := MeshInstance3D.new()
        mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

        if it_data.type == "light_crate":
            var box := BoxMesh.new()
            box.size = Vector3(0.50, 0.50, 0.50)
            mesh_inst.mesh = box
            var mat := StandardMaterial3D.new()
            mat.albedo_color = Color("8c5828")
            mat.roughness = 0.72
            mat.metallic = 0.15
            mesh_inst.material_override = mat

            var trim := MeshInstance3D.new()
            var trim_box := BoxMesh.new()
            trim_box.size = Vector3(0.52, 0.52, 0.52)
            trim.mesh = trim_box
            var trim_mat := StandardMaterial3D.new()
            trim_mat.albedo_color = Color("382e25")
            trim_mat.metallic = 0.65
            trim_mat.roughness = 0.35
            trim.material_override = trim_mat
            root_item.add_child(trim)

        elif it_data.type == "heavy_rock":
            var sphere := SphereMesh.new()
            sphere.radius = 0.32
            sphere.height = 0.64
            mesh_inst.mesh = sphere
            var mat := StandardMaterial3D.new()
            mat.albedo_texture = stone_tex
            mat.normal_enabled = true
            mat.normal_texture = stone_norm
            mat.roughness = 0.60
            mat.metallic = 0.20
            mat.emission_enabled = true
            mat.emission = Color("ff5500")
            mat.emission_energy_multiplier = 2.0
            mesh_inst.material_override = mat

        elif it_data.type == "barrel":
            var cyl := CylinderMesh.new()
            cyl.top_radius = 0.26
            cyl.bottom_radius = 0.26
            cyl.height = 0.60
            mesh_inst.mesh = cyl
            var mat := StandardMaterial3D.new()
            mat.albedo_color = Color("5c3a21")
            mat.roughness = 0.65
            mat.metallic = 0.10
            mesh_inst.material_override = mat

            for y_off in [-0.18, 0.18]:
                var hoop := MeshInstance3D.new()
                var hoop_cyl := CylinderMesh.new()
                hoop_cyl.top_radius = 0.27
                hoop_cyl.bottom_radius = 0.27
                hoop_cyl.height = 0.04
                hoop.mesh = hoop_cyl
                hoop.position.y = y_off
                var hoop_mat := StandardMaterial3D.new()
                hoop_mat.albedo_color = Color("222428")
                hoop_mat.metallic = 0.85
                hoop_mat.roughness = 0.25
                hoop.material_override = hoop_mat
                root_item.add_child(hoop)

        root_item.add_child(mesh_inst)

func setup_platforms() -> void:
    for node in platform_nodes: node.queue_free()
    platform_nodes.clear()
    platform_trims.clear()

    var stone_tex: Texture2D = preload("res://assets/textures/characters/golem_rock_albedo.png")
    var stone_norm: Texture2D = preload("res://assets/textures/characters/golem_rock_normal.png")

    var plats: Array = [
        {"pos": Vector3(-2.3, 1.45, 0.0), "size": Vector3(2.2, 0.14, 1.1)},
        {"pos": Vector3( 2.3, 1.45, 0.0), "size": Vector3(2.2, 0.14, 1.1)},
        {"pos": Vector3( 0.0, 2.65, 0.0), "size": Vector3(2.2, 0.14, 1.1)},
    ]

    for p in plats:
        var root_plat := Node3D.new()
        root_plat.position = p.pos
        add_child(root_plat)
        platform_nodes.append(root_plat)

        # Platform slab
        var slab := MeshInstance3D.new()
        var box := BoxMesh.new()
        box.size = p.size
        slab.mesh = box

        var mat := StandardMaterial3D.new()
        mat.albedo_texture = stone_tex
        mat.normal_enabled = true
        mat.normal_texture = stone_norm
        mat.normal_scale = 1.8
        mat.roughness = 0.55
        mat.metallic = 0.25
        mat.uv1_scale = Vector3(2, 1, 2)
        slab.material_override = mat
        root_plat.add_child(slab)

        # Glowing runic trim / edge border
        var trim := MeshInstance3D.new()
        var trim_mesh := BoxMesh.new()
        trim_mesh.size = Vector3(p.size.x + 0.08, 0.035, p.size.z + 0.08)
        trim.mesh = trim_mesh
        trim.position.y = p.size.y * 0.5 - 0.015

        var trim_mat := StandardMaterial3D.new()
        trim_mat.albedo_color = Color("1a2030")
        trim_mat.emission_enabled = true
        trim_mat.emission = CYAN
        trim_mat.emission_energy_multiplier = 3.2
        trim.material_override = trim_mat
        root_plat.add_child(trim)
        platform_trims.append(trim_mat)

        # Floating Energy Crystal underneath
        var crystal := MeshInstance3D.new()
        var prism := PrismMesh.new()
        prism.size = Vector3(0.42, 0.38, 0.42)
        crystal.mesh = prism
        crystal.rotation_degrees = Vector3(180, 0, 0)
        crystal.position.y = -p.size.y * 0.5 - 0.16

        var c_mat := StandardMaterial3D.new()
        c_mat.albedo_color = Color(1.5, 1.5, 2.0)
        c_mat.emission_enabled = true
        c_mat.emission = Color("ff6d2b")
        c_mat.emission_energy_multiplier = 4.5
        crystal.material_override = c_mat
        root_plat.add_child(crystal)

func apply_arena(id: String) -> void:
    if not ARENAS.has(id): id = "blood_moon"
    current_arena = id
    var a: Dictionary = ARENAS[id]

    var sky := Sky.new()
    var sky_mat := PanoramaSkyMaterial.new()
    sky_mat.panorama = a.sky
    sky.sky_material = sky_mat
    world_env.environment.sky = sky
    world_env.environment.sky_rotation = Vector3(0, deg_to_rad(90), 0)
    world_env.environment.ambient_light_color = a.ambient_color
    world_env.environment.ambient_light_energy = 0.88

    sunlight.rotation_degrees = a.sun_rot
    sunlight.light_color = a.sun_color
    sunlight.light_energy = 1.85
    for fire in fire_lights:
        fire.light_color = a.fire_color

    for trim in platform_trims:
        trim.emission = a.get("fire_color", CYAN)

    if arena_model:
        var stone_tex: Texture2D = preload("res://assets/textures/characters/golem_rock_albedo.png")
        var stone_norm: Texture2D = preload("res://assets/textures/characters/golem_rock_normal.png")
        for mesh in arena_model.find_children("*", "MeshInstance3D", true, false):
            if "Floor" in mesh.name:
                var floor_mat := StandardMaterial3D.new()
                floor_mat.albedo_texture = a.floor
                floor_mat.uv1_scale = Vector3(2.5, 2.5, 2.5)
                floor_mat.uv1_triplanar = true
                if a.floor_norm:
                    floor_mat.normal_enabled = true
                    floor_mat.normal_texture = a.floor_norm
                    floor_mat.normal_scale = 1.6
                if a.floor_em:
                    floor_mat.emission_enabled = true
                    floor_mat.emission_texture = a.floor_em
                    floor_mat.emission = Color(1.0, 0.45, 0.1)
                    floor_mat.emission_energy_multiplier = 1.3
                floor_mat.roughness = 0.72
                mesh.material_override = floor_mat
            elif "Column" in mesh.name or "Arch" in mesh.name or "RearWall" in mesh.name:
                var s_mat := StandardMaterial3D.new()
                s_mat.albedo_texture = stone_tex
                s_mat.normal_enabled = true
                s_mat.normal_texture = stone_norm
                s_mat.normal_scale = 1.4
                s_mat.uv1_scale = Vector3(1.5, 1.5, 1.5)
                s_mat.uv1_triplanar = true
                s_mat.roughness = 0.86
                mesh.material_override = s_mat

    setup_citadel_scenery(id == "imperial_colosseum" or id == "gladiator_fortress")

    if status:
        status.text = "%s  /  %s" % [a.name, ("AGENTENKAMPF" if sim.mode == "autonomous" else "LOKALER VERSUS")]

var citadel_scenery_node: Node3D

func setup_citadel_scenery(enable: bool) -> void:
    if citadel_scenery_node:
        citadel_scenery_node.queue_free()
        citadel_scenery_node = null
    if not enable: return

    citadel_scenery_node = Node3D.new()
    add_child(citadel_scenery_node)

    var stone_tex: Texture2D = preload("res://assets/textures/characters/golem_rock_albedo.png")
    var stone_norm: Texture2D = preload("res://assets/textures/characters/golem_rock_normal.png")
    var mat := StandardMaterial3D.new()
    mat.albedo_texture = stone_tex
    mat.normal_enabled = true
    mat.normal_texture = stone_norm
    mat.normal_scale = 1.5
    mat.roughness = 0.82
    mat.uv1_scale = Vector3(2, 2, 2)
    mat.uv1_triplanar = true

    # 1. Background: Monumental Colosseum Colonnade (Z = -5.5)
    for col_x in [-5.8, -3.2, 3.2, 5.8]:
        var col := MeshInstance3D.new()
        var cyl := CylinderMesh.new()
        cyl.top_radius = 0.42
        cyl.bottom_radius = 0.48
        cyl.height = 6.2
        col.mesh = cyl
        col.position = Vector3(col_x, 2.6, -5.5)
        col.material_override = mat
        col.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
        citadel_scenery_node.add_child(col)

        # Capital on top
        var cap := MeshInstance3D.new()
        var box := BoxMesh.new()
        box.size = Vector3(1.1, 0.35, 1.1)
        cap.mesh = box
        cap.position = Vector3(col_x, 5.7, -5.5)
        cap.material_override = mat
        citadel_scenery_node.add_child(cap)

    # Architrave / Beam across pillars
    var architrave := MeshInstance3D.new()
    var beam_mesh := BoxMesh.new()
    beam_mesh.size = Vector3(14.0, 0.55, 1.2)
    architrave.mesh = beam_mesh
    architrave.position = Vector3(0, 6.0, -5.5)
    architrave.material_override = mat
    citadel_scenery_node.add_child(architrave)

    # 2. Distant Ruined Wall with Archways (Z = -8.0)
    var rear_wall := MeshInstance3D.new()
    var wall_box := BoxMesh.new()
    wall_box.size = Vector3(22.0, 9.0, 0.8)
    rear_wall.mesh = wall_box
    rear_wall.position = Vector3(0, 4.0, -8.0)
    var wall_mat := StandardMaterial3D.new()
    wall_mat.albedo_color = Color("2d2b33")
    wall_mat.roughness = 0.95
    rear_wall.material_override = wall_mat
    citadel_scenery_node.add_child(rear_wall)

    # 3. Foreground Framing (Sides only, Z = +1.5, X = ±6.8, never obstructing fighters)
    for side in [-1, 1]:
        var stump := MeshInstance3D.new()
        var s_cyl := CylinderMesh.new()
        s_cyl.top_radius = 0.38
        s_cyl.bottom_radius = 0.45
        s_cyl.height = 1.4
        stump.mesh = s_cyl
        stump.position = Vector3(side * 6.8, 0.7, 1.5)
        stump.material_override = mat
        citadel_scenery_node.add_child(stump)

func panel_style(color: Color, border: Color = Color("34445b")) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = color
    s.border_color = border
    s.set_border_width_all(1)
    s.set_corner_radius_all(12)
    s.content_margin_left = 22
    s.content_margin_right = 22
    s.content_margin_top = 16
    s.content_margin_bottom = 16
    return s

func label(text: String, size: int = 18, color: Color = Color("dce7f5")) -> Label:
    var l := Label.new()
    l.text = text
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", color)
    return l

func button(text: String, color: Color, callback: Callable) -> Button:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size = Vector2(0, 46)
    b.add_theme_font_size_override("font_size", 17)
    b.add_theme_color_override("font_color", Color("ecf4ff"))
    b.add_theme_stylebox_override("normal", panel_style(Color("162b40"), color.darkened(0.3)))
    b.add_theme_stylebox_override("hover", panel_style(Color("29445a"), color))
    b.add_theme_stylebox_override("pressed", panel_style(Color("34566d"), color))
    b.focus_mode = Control.FOCUS_NONE
    b.pressed.connect(callback)
    return b

func setup_ui() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    root_ui = Control.new()
    root_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(root_ui)
    var top := PanelContainer.new()
    root_ui.add_child(top)
    top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
    top.offset_left = 24
    top.offset_right = -24
    top.offset_top = 18
    top.add_theme_stylebox_override("panel", panel_style(Color(0.025,0.042,0.075,0.94)))
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 28)
    top.add_child(row)
    portrait_rects.clear()
    for i in range(3):
        if i == 1:
            var middle := VBoxContainer.new()
            middle.custom_minimum_size.x = 140
            row.add_child(middle)
            var brand := label("PROMPT FIGHTER", 15, CYAN)
            brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            middle.add_child(brand)
            timer = label("90", 36)
            timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
            middle.add_child(timer)
            continue
        var player := 0 if i == 0 else 1
        var player_h := HBoxContainer.new()
        player_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        player_h.add_theme_constant_override("separation", 14)
        row.add_child(player_h)

        var port := TextureRect.new()
        port.custom_minimum_size = Vector2(56, 56)
        port.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        port.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        port.texture = PORTRAITS["ninja"] if player == 0 else PORTRAITS["golem"]
        portrait_rects.append(port)
        if player == 0:
            player_h.add_child(port)

        var box := VBoxContainer.new()
        box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        player_h.add_child(box)

        var title_h := HBoxContainer.new()
        title_h.add_theme_constant_override("separation", 10)
        box.add_child(title_h)
        var title := label("SPIELER %d" % (player+1), 18, CYAN if player == 0 else ORANGE)
        title_h.add_child(title)
        names.append(title)

        var lives_lbl := label("● ● ●  3 LEBEN", 14, Color("ff3b5c"))
        title_h.add_child(lives_lbl)
        lives_labels.append(lives_lbl)

        var bar := ProgressBar.new()
        bar.custom_minimum_size.y = 16
        bar.show_percentage = false
        for part in ["background", "fill"]:
            var bar_style := panel_style(Color("263044") if part == "background" else (CYAN if player == 0 else ORANGE))
            bar_style.content_margin_left = 0
            bar_style.content_margin_right = 0
            bar_style.content_margin_top = 0
            bar_style.content_margin_bottom = 0
            bar_style.set_corner_radius_all(5)
            bar.add_theme_stylebox_override(part, bar_style)
        box.add_child(bar)
        health_bars.append(bar)
        var small := label("", 14, Color("b0c0d5"))
        box.add_child(small)
        health_text.append(small)
        var cd := label("Spezial bereit", 13, Color("9ab2cf"))
        box.add_child(cd)
        special_text.append(cd)

        if player == 1:
            player_h.add_child(port)

    var bottom := PanelContainer.new()
    root_ui.add_child(bottom)
    bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    bottom.offset_left = 24
    bottom.offset_right = -24
    bottom.offset_top = -106
    bottom.offset_bottom = -18
    bottom.add_theme_stylebox_override("panel", panel_style(Color(0.025,0.042,0.075,0.94)))
    var footer := HBoxContainer.new()
    bottom.add_child(footer)
    var keys := label("P1  A/D Laufen · W Sprung (x2) · S Block/Plattform runter · F Schlag · G Spezial   |   P2  ←/→ · ↑ Sprung (x2) · ↓ Block/Plattform runter · K Schlag · L Spezial", 13)
    keys.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    footer.add_child(keys)
    footer.add_child(button("↻  R", CYAN, restart_round))
    footer.add_child(button("Auswahl", ORANGE, show_selection))
    status = label("BLOOD MOON TERRACE  /  LOKALER VERSUS", 15, Color("bfcee1"))
    root_ui.add_child(status)
    status.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
    status.position = Vector2(390, 159)

    selection = PanelContainer.new()
    root_ui.add_child(selection)
    selection.position = Vector2(170, 16)
    selection.custom_minimum_size = Vector2(940, 0)
    selection.add_theme_stylebox_override("panel", panel_style(Color(0.025,0.045,0.078,0.97), Color("36546e")))
    var select_box := VBoxContainer.new()
    select_box.add_theme_constant_override("separation", 5)
    selection.add_child(select_box)
    select_box.add_child(label("DEIN PROMPT. DEIN KÄMPFER.", 20))
    select_box.add_child(label("Wähle deinen Kämpfer aus allen 11 Charakteren oder gib einen eigenen Prompt ein (100 Punkte)", 12, Color("93aec9")))

    var presets = [
        {"id": "golem", "name": "Golem", "prompt": "Gepanzerter Lavagolem mit brennenden Fäusten"},
        {"id": "ninja", "name": "Ninja", "prompt": "Blitzschneller Schattenninja mit elektrischen Klingen"},
        {"id": "valkyrie", "name": "Valkyrie", "prompt": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier"},
        {"id": "dragon", "name": "Drache", "prompt": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert"},
        {"id": "anubis", "name": "Anubis", "prompt": "Jackal God Anubis wielding dual Khopesh"},
        {"id": "specter", "name": "Specter", "prompt": "Void Specter crystal phantom warrior with void lance"},
        {"id": "phoenix", "name": "Phoenix", "prompt": "Phoenix Empress with feather armor and phoenix glaive"},
        {"id": "goku", "name": "Goku", "prompt": "Son Goku Super Saiyan Kamehameha Dragon Ball Z"},
        {"id": "subzero", "name": "Sub-Zero", "prompt": "Sub-Zero Lin Kuei Cryomancer ice ninja kori blade"},
        {"id": "pain", "name": "Pain", "prompt": "Pain Nagato Akatsuki Rinnegan Shinra Tensei"},
        {"id": "luffy", "name": "Ruffy", "prompt": "Monkey D. Luffy Strohhut Gum-Gum One Piece Mugiwara"}
    ]

    for i in range(2):
        select_box.add_child(label("SPIELER %d" % (i+1), 12, CYAN if i == 0 else ORANGE))
        var edit := LineEdit.new()
        edit.name = "PromptPlayer%d" % (i+1)
        edit.max_length = 512
        edit.custom_minimum_size.y = 28
        edit.text = "Blitzschneller Schattenninja mit elektrischen Klingen" if i == 0 else "Gepanzerter Lavagolem mit brennenden Fäusten"
        edit.add_theme_font_size_override("font_size", 13)
        select_box.add_child(edit)
        prompts.append(edit)

        # Visual character selection cards row
        var preset_row := HBoxContainer.new()
        preset_row.add_theme_constant_override("separation", 6)
        select_box.add_child(preset_row)
        for preset in presets:
            var pbtn := Button.new()
            pbtn.text = preset.name
            var thumb_path: String = "res://assets/textures/characters/thumbs/thumb_%s.png" % preset.id
            if ResourceLoader.exists(thumb_path):
                pbtn.icon = load(thumb_path)
            pbtn.expand_icon = true
            pbtn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
            pbtn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
            pbtn.custom_minimum_size = Vector2(76, 60)
            pbtn.add_theme_font_size_override("font_size", 9)
            pbtn.add_theme_stylebox_override("normal", panel_style(Color("162436"), Color("2a445d")))
            pbtn.add_theme_stylebox_override("hover", panel_style(Color("26415e"), CYAN if i == 0 else ORANGE))
            pbtn.focus_mode = Control.FOCUS_NONE
            var p_text: String = preset.prompt
            var edit_ref: LineEdit = edit
            pbtn.pressed.connect(func():
                edit_ref.text = p_text
                refresh_profile_text()
                refresh_previews()
            )
            preset_row.add_child(pbtn)

        var info := label("", 11, Color("93aec9"))
        select_box.add_child(info)
        profile_text.append(info)
        edit.text_changed.connect(func(_s): refresh_profile_text())

    # Arena Selector Row with Thumbnails
    select_box.add_child(label("ARENA WÄHLEN", 14, Color("ffc857")))
    var arena_row := HBoxContainer.new()
    arena_row.add_theme_constant_override("separation", 8)
    select_box.add_child(arena_row)
    for aid in ARENAS:
        var adata: Dictionary = ARENAS[aid]
        var abtn := Button.new()
        abtn.text = adata.name.left(13)
        abtn.icon = adata.thumb
        abtn.expand_icon = true
        abtn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
        abtn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
        abtn.custom_minimum_size = Vector2(126, 68)
        abtn.add_theme_font_size_override("font_size", 10)
        abtn.add_theme_stylebox_override("normal", panel_style(Color("162b40"), Color("34445b")))
        abtn.add_theme_stylebox_override("hover", panel_style(Color("29445a"), CYAN))
        abtn.focus_mode = Control.FOCUS_NONE
        var target_aid: String = aid
        abtn.pressed.connect(func():
            apply_arena(target_aid)
        )
        arena_row.add_child(abtn)

    var actions := HBoxContainer.new()
    actions.add_theme_constant_override("separation", 12)
    select_box.add_child(actions)
    for spec in [["LOKALER VERSUS", "manual", CYAN], ["AGENTENKAMPF", "autonomous", ORANGE]]:
        var start_btn := button(spec[0], spec[2], start_round.bind(spec[1]))
        start_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        actions.add_child(start_btn)

    var controls_panel := PanelContainer.new()
    controls_panel.add_theme_stylebox_override("panel", panel_style(Color(0.015, 0.025, 0.045, 0.85), Color("22354c")))
    select_box.add_child(controls_panel)
    var controls_box := VBoxContainer.new()
    controls_panel.add_child(controls_box)
    controls_box.add_child(label("KAMPF-STEUERUNG (SUPER SMASH & ARENA-OBJEKTE)", 12, Color("76a8d6")))
    controls_box.add_child(label("P1:  A/D Laufen  ·  W Sprung (Doppel)  ·  S Block/Plattform Drop  ·  F Schlag  ·  G Spezial  ·  E Greifen/Werfen/Aufheben", 11, CYAN))
    controls_box.add_child(label("P2:  ←/→ Laufen  ·  ↑ Sprung (Doppel)  ·  ↓ Block/Plattform Drop  ·  K Schlag  ·  L Spezial  ·  O Greifen/Werfen/Aufheben", 11, ORANGE))
    controls_box.add_child(label("Features: 3 Stocks, dynamischer Smash-Rückstoß je weniger HP, Gegner Greifen & Werfen (Richtungstaste), Kisten/Fässer werfen!", 11, Color("ffc857")))

    result_panel = PanelContainer.new()
    root_ui.add_child(result_panel)
    result_panel.position = Vector2(435, 285)
    result_panel.custom_minimum_size.x = 410
    result_panel.add_theme_stylebox_override("panel", panel_style(Color(0.025,0.045,0.078,0.97), CYAN))
    var result_box := VBoxContainer.new()
    result_panel.add_child(result_box)
    result_box.add_child(label("RUNDE BEENDET", 14, CYAN))
    result_label = label("", 26)
    result_box.add_child(result_label)
    result_box.add_child(button("REVANCHE  ·  R", CYAN, restart_round))
    result_box.add_child(button("Neue Prompts", ORANGE, show_selection))
    result_panel.hide()

func refresh_profile_text() -> void:
    for i in range(2):
        var p: Dictionary = Prompt.interpret(prompts[i].text, i)
        profile_text[i].text = "%s · %s    HP %d  Kraft %d  Rüstung %d  Tempo %d  Technik %d" % [p.family.to_upper(), p.element, p.stats.vitality, p.stats.power, p.stats.defense, p.stats.speed, p.stats.technique]

func refresh_previews() -> void:
    refresh_profile_text()
    sim.start(Prompt.interpret(prompts[0].text, 0), Prompt.interpret(prompts[1].text, 1), "manual")
    rebuild_fighters()
    update_hud()

func rebuild_fighters() -> void:
    for view in views: view.queue_free()
    views.clear()
    for i in range(2):
        var view = FighterView.new()
        add_child(view)
        view.setup(sim.fighters[i].profile)
        view.update_state(sim.fighters[i], 1.0)
        views.append(view)

func start_round(mode: String) -> void:
    get_viewport().gui_release_focus()
    save_prompts()
    sim.start(Prompt.interpret(prompts[0].text, 0), Prompt.interpret(prompts[1].text, 1), mode)
    rebuild_fighters()
    setup_items()
    input_buffer = [{"standard": false, "special": false, "jump": false, "grab": false}, {"standard": false, "special": false, "jump": false, "grab": false}]
    accumulator = 0
    active = true
    paused = false
    selection.hide()
    result_panel.hide()
    sound("start")

func restart_round() -> void:
    if active or not result_panel.visible and not selection.visible:
        start_round(sim.mode)
    elif result_panel.visible:
        start_round(sim.mode)

func show_selection() -> void:
    active = false
    paused = false
    result_panel.hide()
    selection.show()
    refresh_previews()

func _unhandled_key_input(event: InputEvent) -> void:
    if not event.is_pressed() or event.is_echo(): return
    if event is InputEventKey:
        if event.keycode == KEY_ESCAPE:
            if active: paused = not paused
            return
        if event.keycode == KEY_R and not selection.visible:
            restart_round()
            return
    if not active or paused or sim.mode != "manual": return
    for i in range(2):
        for action_type in ["standard", "special", "jump", "grab"]:
            if event.is_action_pressed("p%d_%s" % [i+1, action_type]): input_buffer[i][action_type] = true

func manual_commands() -> Array:
    var commands: Array = []
    for i in range(2):
        var is_blocking: bool = Input.is_action_pressed("p%d_block" % (i+1))
        var is_jumping: bool = input_buffer[i].get("jump", false) or Input.is_action_just_pressed("p%d_jump" % (i+1))
        var is_grabbing: bool = input_buffer[i].get("grab", false) or Input.is_action_just_pressed("p%d_grab" % (i+1))
        var move_axis: float = 0.0 if is_blocking else Input.get_axis("p%d_left" % (i+1), "p%d_right" % (i+1))
        commands.append({
            "move": move_axis,
            "standard": input_buffer[i].standard and not is_blocking,
            "special": input_buffer[i].special and not is_blocking,
            "jump": is_jumping and not is_blocking,
            "block": is_blocking,
            "grab": is_grabbing
        })
        input_buffer[i] = {"standard": false, "special": false, "jump": false, "grab": false}
    return commands

func _physics_process(delta: float) -> void:
    if active and not paused and sim.result == -2:
        var commands: Array = sim.agent_commands() if sim.mode == "autonomous" else manual_commands()
        sim.tick(commands, delta)
        for event in sim.events:
            if event.type == "hit":
                if smoke: smoke_report.hits += 1
                views[event.target].flash()
                hit_effect(event.target, event.special, event.get("super_hit", false))
                sound("hit")
            elif event.type == "block":
                if event.target < views.size():
                    views[event.target].shield_flash()
                    block_effect(event.target)
                sound("block")
            elif event.type == "jump" or event.type == "double_jump":
                sound("jump")
            elif event.type == "drop_through":
                sound("jump")
            elif event.type == "attack" and event.special:
                sound("lava" if sim.fighters[event.actor].profile.family == "golem" else "electric")
            elif event.type == "grab_success":
                views[event.target].shield_flash()
                sound("block")
                status.text = "%s HAT %s GEGRIFFEN!" % [sim.fighters[event.actor].profile.name, sim.fighters[event.target].profile.name]
            elif event.type == "throw":
                views[event.target].flash()
                hit_effect(event.target, true, false)
                sound("hit")
            elif event.type == "grab_breakout":
                sound("block")
                status.text = "BEFREIUNG!"
            elif event.type == "item_pickup":
                sound("jump")
                status.text = "%s HEBT %s AUF!" % [sim.fighters[event.actor].profile.name, event.item_name]
            elif event.type == "item_throw":
                sound("jump")
            elif event.type == "item_hit":
                views[event.target].flash()
                hit_effect(event.target, true, false)
                sound("hit")
                status.text = "%s WURDE GETROFFEN VON %s!" % [sim.fighters[event.target].profile.name, event.item_name]
            elif event.type == "ring_out":
                camera_shake = 0.95
                hit_effect(event.actor, true, true)
                sound("victory")
                var act_name: String = sim.fighters[event.actor].profile.name
                status.text = "RING OUT! %s VERLIERT 1 LEBEN (%d ÜBRIG)!" % [act_name, event.lives]
            elif event.type == "hp_ko":
                camera_shake = 0.70
                hit_effect(event.actor, true, false)
                sound("hit")
                var act_name: String = sim.fighters[event.actor].profile.name
                status.text = "K.O.! %s VERLIERT 1 LEBEN (%d ÜBRIG)!" % [act_name, event.lives]
            elif event.type == "respawn":
                sound("jump")
            elif event.type == "finish":
                result_label.text = "UNENTSCHIEDEN" if sim.result == -1 else "SPIELER %d GEWINNT!" % (sim.result + 1)
                result_panel.show()
                sound("victory")
                if smoke: finish_smoke_round()

        # Update 3D item nodes position & rotation
        for it_i in range(mini(item_nodes.size(), sim.items.size())):
            var it_data: Dictionary = sim.items[it_i]
            var it_node: Node3D = item_nodes[it_i]
            it_node.visible = (it_data.state != "destroyed")
            it_node.position = Vector3(it_data.x, it_data.y, 0.0)
            if it_data.state == "thrown":
                it_node.rotate_z(-it_data.vx * delta * 3.5)
            elif it_data.state == "carried":
                it_node.rotation_degrees = Vector3.ZERO
    for i in range(views.size()): views[i].update_state(sim.fighters[i], delta)
    update_hud()
    if smoke: run_smoke_step()

func _process(delta: float) -> void:
    if sim.fighters.size() < 2: return
    var mid: float = (sim.fighters[0].x + sim.fighters[1].x) * 0.5
    var separation: float = abs(sim.fighters[0].x - sim.fighters[1].x)
    var highest_y: float = maxf(sim.fighters[0].y, sim.fighters[1].y)
    var cam_y: float = 1.55 + clampf(highest_y * 0.45, 0.0, 1.8)
    var target_cam_z: float = clampf(5.2 + separation * 0.72 + highest_y * 0.35, 4.8, 9.2)
    var target_pos := Vector3(mid * 0.70, cam_y, target_cam_z)
    if camera_shake > 0.0:
        camera_shake = maxf(0.0, camera_shake - delta * 3.5)
        target_pos += Vector3(randf_range(-camera_shake, camera_shake) * 0.35, randf_range(-camera_shake, camera_shake) * 0.35, 0)
    camera.position = camera.position.lerp(target_pos, minf(1.0, delta * 5.0))
    camera.look_at(Vector3(mid * 0.70, 1.15 + (cam_y - 1.55) * 0.5, 0.0))

func get_portrait_for_fighter(f: Dictionary) -> Texture2D:
    var family: String = f.profile.get("family", "")
    var thumb_path: String = "res://assets/textures/characters/thumbs/thumb_%s.png" % family
    if ResourceLoader.exists(thumb_path):
        return load(thumb_path)
    var ptext: String = f.profile.prompt.to_lower()
    if family == "dragon" or "dragon" in ptext or "drache" in ptext or "drake" in ptext or "wyrm" in ptext or "slayer" in ptext:
        return PORTRAITS.get("dragon", null)
    if family == "valkyrie" or "valkyrie" in ptext or "moe" in ptext or "anime" in ptext:
        return PORTRAITS.get("valkyrie", null)
    if "frost" in ptext or "eis" in ptext:
        return PORTRAITS.get("frost", null)
    if "sturm" in ptext or "donner" in ptext or "blitz" in ptext or "storm" in ptext:
        return PORTRAITS.get("storm", null)
    if "spore" in ptext or "gift" in ptext or "toxic" in ptext:
        return PORTRAITS.get("toxic", null)
    if "cyber" in ptext or "mech" in ptext or "apex" in ptext:
        return PORTRAITS.get("cyber", null)
    if f.profile.family == "golem":
        return PORTRAITS.get("golem", null)
    return PORTRAITS.get("ninja", null)

func update_hud() -> void:
    if not timer or sim.fighters.size() < 2: return
    timer.text = "%02d" % int(ceil(sim.time_left))
    for i in range(2):
        var f: Dictionary = sim.fighters[i]
        names[i].text = "P%d  /  %s" % [i+1, f.profile.name]
        health_bars[i].value = f.hp / f.profile.health * 100
        health_text[i].text = "%d / %d  LP   ·   %s" % [int(ceil(f.hp)), int(ceil(f.profile.health)), f.profile.element.to_upper()]
        var super_val: float = f.get("super", 0.0)
        var combo_val: int = f.get("combo", 0)
        var super_str: String = "SUPER!" if super_val >= 100.0 else "SUPER %d%%" % int(super_val)
        var combo_str: String = "  ·  %d HITS" % combo_val if combo_val > 1 else ""
        special_text[i].text = super_str + combo_str + ("  ·  SPEZIAL!" if f.cooldowns[1] <= 0 and super_val >= 40 else "")
        if lives_labels.size() > i and lives_labels[i]:
            var lives_cnt: int = f.get("lives", 3)
            var stocks: String = ""
            for k in range(3):
                stocks += "● " if k < lives_cnt else "○ "
            lives_labels[i].text = "%s (%d LEBEN)" % [stocks, lives_cnt]
            lives_labels[i].add_theme_color_override("font_color", Color("ff4770") if lives_cnt > 1 else Color("ff2233"))
        if portrait_rects.size() > i and portrait_rects[i]:
            portrait_rects[i].texture = get_portrait_for_fighter(f)
    if paused: status.text = "PAUSE  ·  ESC zum Fortsetzen"
    elif active and sim.countdown > 0: status.text = "BEREIT?  %d" % int(ceil(sim.countdown))
    else:
        var aname: String = ARENAS[current_arena].name if ARENAS.has(current_arena) else "BLOOD MOON TERRACE"
        status.text = "%s  /  %s" % [aname, ("AGENTENKAMPF" if sim.mode == "autonomous" else "LOKALER VERSUS")]

func hit_effect(index: int, special: bool, is_super_hit: bool = false) -> void:
    camera_shake = 0.70 if is_super_hit else (0.42 if special else 0.16)
    var spark := Sprite3D.new()
    spark.texture = ELECTRIC_SPARK if (special or is_super_hit) else HIT_SPARK
    spark.pixel_size = 0.022 if is_super_hit else (0.016 if special else 0.009)
    spark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    spark.modulate = Color("ff3300") if is_super_hit else (ORANGE if special else CYAN)
    add_child(spark)
    var hit_pos := Vector3(sim.fighters[index].x, 1.18 + randf_range(-0.1, 0.2), 0.5)
    spark.position = hit_pos
    var tween := create_tween()
    tween.tween_property(spark, "scale", Vector3.ONE * (4.5 if is_super_hit else 2.2), 0.04)
    tween.parallel().tween_property(spark, "modulate:a", 0.0, 0.28 if is_super_hit else 0.22)
    tween.tween_callback(spark.queue_free)
    if is_super_hit:
        for k in range(5):
            var s2 := Sprite3D.new()
            s2.texture = HIT_SPARK
            s2.pixel_size = 0.010
            s2.billboard = BaseMaterial3D.BILLBOARD_ENABLED
            s2.modulate = Color(1.0, randf_range(0.2, 0.6), 0.0)
            add_child(s2)
            s2.position = hit_pos + Vector3(randf_range(-0.3, 0.3), randf_range(-0.2, 0.35), 0)
            var t2 := create_tween()
            t2.tween_property(s2, "scale", Vector3.ONE * randf_range(1.5, 3.0), 0.08)
            t2.parallel().tween_property(s2, "modulate:a", 0.0, 0.35)
            t2.tween_callback(s2.queue_free)

func block_effect(index: int) -> void:
    camera_shake = maxf(camera_shake, 0.14)
    var spark := Sprite3D.new()
    spark.texture = HIT_SPARK
    spark.pixel_size = 0.016
    spark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    spark.modulate = Color("ffd700")
    add_child(spark)
    if index < sim.fighters.size():
        spark.position = Vector3(sim.fighters[index].x + sim.fighters[index].facing * 0.35, 1.22, 0.4)
    var tween := create_tween()
    tween.tween_property(spark, "scale", Vector3.ONE * 2.6, 0.04)
    tween.parallel().tween_property(spark, "modulate:a", 0.0, 0.22)
    tween.tween_callback(spark.queue_free)

func parry_effect(index: int) -> void:
    if index >= sim.fighters.size(): return
    var pos := Vector3(sim.fighters[index].x, 1.2, 0.5)
    for ring in range(3):
        var s := Sprite3D.new()
        s.texture = HIT_SPARK
        s.pixel_size = 0.022
        s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        s.modulate = Color("ffd700")
        s.scale = Vector3.ONE * 0.4
        add_child(s)
        s.position = pos
        var t := create_tween()
        t.tween_interval(ring * 0.06)
        t.tween_property(s, "scale", Vector3.ONE * (2.5 + ring * 0.8), 0.18)
        t.parallel().tween_property(s, "modulate:a", 0.0, 0.28)
        t.tween_callback(s.queue_free)

func super_effect(index: int) -> void:
    if index >= sim.fighters.size(): return
    var pos := Vector3(sim.fighters[index].x, 1.3, 0.5)
    for k in range(8):
        var s := Sprite3D.new()
        s.texture = ELECTRIC_SPARK
        s.pixel_size = 0.018
        s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        s.modulate = Color(0.6, 0.2, 1.0)
        add_child(s)
        s.position = pos + Vector3(randf_range(-0.5, 0.5), randf_range(-0.1, 0.5), 0)
        var t := create_tween()
        t.tween_property(s, "scale", Vector3.ONE * randf_range(2.0, 4.0), 0.12)
        t.parallel().tween_property(s, "modulate:a", 0.0, 0.45)
        t.tween_callback(s.queue_free)

func show_combo(index: int, count: int) -> void:
    pass

func setup_audio() -> void:
    var files := {
        "hit": "Hit", "electric": "ElectricSpecial", "lava": "LavaSpecial",
        "start": "RoundStart", "victory": "Victory", "block": "Block", "jump": "Jump"
    }
    for key in files:
        var player := AudioStreamPlayer.new()
        var p := "res://assets/audio/PFU_%s.wav" % files[key]
        if ResourceLoader.exists(p):
            player.stream = load(p)
            player.volume_db = -16
            player.max_polyphony = 3
            add_child(player)
            audio[key] = player

func sound(key: String) -> void:
    if DisplayServer.get_name() != "headless" and audio.has(key): audio[key].play()

func _exit_tree() -> void:
    for player in audio.values(): player.stop()

func save_prompts() -> void:
    if smoke or DisplayServer.get_name() == "headless": return
    var settings := ConfigFile.new()
    settings.set_value("fighters", "p1", prompts[0].text)
    settings.set_value("fighters", "p2", prompts[1].text)
    settings.save("user://preferences.cfg")

func restore_prompts() -> void:
    var settings := ConfigFile.new()
    if settings.load("user://preferences.cfg") == OK:
        for i in range(2): prompts[i].text = str(settings.get_value("fighters", "p%d" % (i+1), prompts[i].text)).left(512)

func run_smoke_step() -> void:
    smoke_ticks += 1
    if smoke_ticks == 150 and not capture_dir.is_empty(): capture("godot-fight.png")
    if smoke_ticks > 12000:
        push_error("Smoke test timeout")
        get_tree().quit(1)

func finish_smoke_round() -> void:
    smoke_rounds += 1
    print("PFU_RENDER_ROUND_COMPLETE ", sim.result, " hits=", smoke_report.hits)
    if not capture_dir.is_empty(): await capture("godot-result.png")
    await get_tree().create_timer(1.0).timeout
    if smoke_rounds == 1:
        smoke_report.restarts += 1
        start_round("autonomous")
    else:
        print("PFU_RENDER_SMOKE_OK ", JSON.stringify(smoke_report))
        get_tree().quit()

func capture(filename: String) -> void:
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    image.save_png(capture_dir.path_join(filename))

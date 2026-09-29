extends Node3D

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")
const FighterView = preload("res://scripts/fighter_view.gd")
const Remixer = preload("res://scripts/character_remixer.gd")
const StoryModeScript = preload("res://scripts/story_mode.gd")
const ArenaBuilder = preload("res://scripts/arena_builder.gd")
const WeaponModels = preload("res://scripts/weapon_models.gd")
const CYAN := Color("49def4")
const ORANGE := Color("ff925b")
const PLAYER_COLORS := [Color("49def4"), Color("ff925b"), Color("4ade80"), Color("c084fc")]

## Battle camera framing: body height that must stay visible (incl. marker arrow) and margins.
const FIGHTER_FRAME_HEIGHT := 2.9
const CAMERA_MARGIN_X := 1.6
const CAMERA_MARGIN_Y := 0.9
const CAMERA_MIN_DIST := 6.0
const CAMERA_MAX_DIST := 34.0
const CAMERA_HEIGHT_OFFSET := 0.6
## Share of the screen height not covered by the top and bottom HUD bars.
const HUD_FREE_FRACTION := 0.68
## Height of the player marker arrow above the fighter's feet.
const MARKER_HEIGHT := 2.35

const PORTRAITS = {
    "golem": preload("res://assets/textures/ui/portrait_golem.png"),
    "ninja": preload("res://assets/textures/ui/portrait_ninja.png"),
    "valkyrie": preload("res://assets/textures/ui/portrait_valkyrie.png"),
    "dragon": preload("res://assets/textures/ui/portrait_dragon.png"),
    "frost": preload("res://assets/textures/ui/portrait_frost.png"),
    "storm": preload("res://assets/textures/ui/portrait_storm.png"),
    "toxic": preload("res://assets/textures/ui/portrait_toxic.png"),
    "cyber": preload("res://assets/textures/ui/portrait_cyber.png"),
    "sonic": preload("res://assets/textures/ui/portrait_sonic.png"),
    "akaza": preload("res://assets/textures/ui/portrait_akaza.png"),
    "blue_eyes": preload("res://assets/textures/ui/portrait_blue_eyes.png"),
    "naruto": preload("res://assets/textures/ui/portrait_naruto.png"),
    "vegeta": preload("res://assets/textures/ui/portrait_vegeta.png"),
    "zoro": preload("res://assets/textures/ui/portrait_zoro.png"),
    "saitama": preload("res://assets/textures/ui/portrait_saitama.png"),
    "tanjiro": preload("res://assets/textures/ui/portrait_tanjiro.png"),
    "sasuke": preload("res://assets/textures/ui/portrait_sasuke.png"),
    "frieza": preload("res://assets/textures/ui/portrait_frieza.png"),
    "charizard": preload("res://assets/textures/ui/portrait_charizard.png"),
    "goku": preload("res://assets/textures/characters/thumbs/thumb_goku.png"),
    "subzero": preload("res://assets/textures/characters/thumbs/thumb_subzero.png"),
    "pain": preload("res://assets/textures/characters/thumbs/thumb_pain.png"),
    "luffy": preload("res://assets/textures/characters/thumbs/thumb_luffy.png"),
    "anubis": preload("res://assets/textures/characters/thumbs/thumb_anubis.png"),
    "specter": preload("res://assets/textures/characters/thumbs/thumb_specter.png"),
    "phoenix": preload("res://assets/textures/characters/thumbs/thumb_phoenix.png"),
    "golden_golem": preload("res://assets/textures/characters/thumbs/thumb_golden_golem.png"),
    "tripo_fran_statue": preload("res://assets/textures/characters/thumbs/thumb_tripo_fran_statue.png"),
    "tripo_fantasy_female": preload("res://assets/textures/characters/thumbs/thumb_tripo_fantasy_female.png"),
    "tripo_nyx_harvester": preload("res://assets/textures/characters/thumbs/thumb_tripo_nyx_harvester.png"),
    "tripo_cat_girl": preload("res://assets/textures/characters/thumbs/thumb_tripo_cat_girl.png"),
    "tripo_dragon_blue": preload("res://assets/textures/characters/thumbs/thumb_tripo_dragon_blue.png"),
    "tripo_white_sci": preload("res://assets/textures/characters/thumbs/thumb_tripo_white_sci.png"),
    "tripo_skeleton_dog": preload("res://assets/textures/characters/thumbs/thumb_tripo_skeleton_dog.png"),
    "tripo_wooden_forest": preload("res://assets/textures/characters/thumbs/thumb_tripo_wooden_forest.png"),
    "tripo_nine_tailed": preload("res://assets/textures/characters/thumbs/thumb_tripo_nine_tailed.png"),
    "tripo_quadruped_tree": preload("res://assets/textures/characters/thumbs/thumb_tripo_quadruped_tree.png"),
    "steel_knight": preload("res://assets/textures/characters/thumbs/thumb_steel_knight.png"),
    "vanguard_soldier": preload("res://assets/textures/characters/thumbs/thumb_vanguard_soldier.png"),
    "sorceress_medea": preload("res://assets/textures/characters/thumbs/thumb_sorceress_medea.png"),
    "skeleton_reaper": preload("res://assets/textures/characters/thumbs/thumb_skeleton_reaper.png"),
    "mutant_titan": preload("res://assets/textures/characters/thumbs/thumb_mutant_titan.png"),
    "swat_specops": preload("res://assets/textures/characters/thumbs/thumb_swat_specops.png"),
    "samurai_dreyar": preload("res://assets/textures/characters/thumbs/thumb_samurai_dreyar.png"),
    "pirate_captain": preload("res://assets/textures/characters/thumbs/thumb_pirate_captain.png"),
    "vampire_lord": preload("res://assets/textures/characters/thumbs/thumb_vampire_lord.png"),
    "wizard_sorcerer": preload("res://assets/textures/characters/thumbs/thumb_wizard_sorcerer.png"),
    "warrok_brute": preload("res://assets/textures/characters/thumbs/thumb_warrok_brute.png"),
    "martial_yaku": preload("res://assets/textures/characters/thumbs/thumb_martial_yaku.png"),
    "monk_ganfaul": preload("res://assets/textures/characters/thumbs/thumb_monk_ganfaul.png"),
    "fusionskammer": preload("res://assets/textures/characters/thumbs/thumb_fusionskammer.png"),
}

const HIT_SPARK = preload("res://assets/textures/vfx/hit_spark.png")
const ELECTRIC_SPARK = preload("res://assets/textures/vfx/electric_spark.png")

const ARENAS = {
    "blood_moon": {
        "name": "BLOOD MOON TERRACE",
        "sky": preload("res://assets/textures/arenas/sky2_blood_moon.png"),
        "thumb": preload("res://assets/textures/ui/thumb_blood_moon.png"),
        "floor": preload("res://assets/textures/arenas/floor_stone_albedo.png"),
        "floor_em": null,
        "floor_norm": preload("res://assets/textures/arenas/floor_stone_normal.png"),
        "sun_color": Color("fff0e2"),
        "sun_rot": Vector3(-35, -25, 0),
        "ambient_color": Color("425575"),
        "fire_color": Color("ff6d2b")
    },
    "volcano_sanctum": {
        "name": "VOLCANIC DRAGON SANCTUM",
        "sky": preload("res://assets/textures/arenas/sky2_volcano_sanctum.png"),
        "thumb": preload("res://assets/textures/ui/thumb_volcano_sanctum.png"),
        "floor": preload("res://assets/textures/arenas/floor_lava_albedo.png"),
        "floor_em": preload("res://assets/textures/arenas/floor_lava_emission.png"),
        "floor_norm": preload("res://assets/textures/arenas/floor_lava_normal.png"),
        "sun_color": Color("ffa040"),
        "sun_rot": Vector3(-50, -40, 0),
        "ambient_color": Color("85482e"),
        "fire_color": Color("ff8b26")
    },
    "imperial_colosseum": {
        "name": "IMPERIAL COLOSSEUM",
        "sky": preload("res://assets/textures/arenas/sky2_imperial_colosseum.png"),
        "thumb": preload("res://assets/textures/ui/thumb_imperial_colosseum.png"),
        "floor": preload("res://assets/textures/arenas/floor_stone_albedo.png"),
        "floor_em": null,
        "floor_norm": preload("res://assets/textures/arenas/floor_stone_normal.png"),
        "sun_color": Color("ffecb5"),
        "sun_rot": Vector3(-45, -30, 0),
        "ambient_color": Color("586882"),
        "fire_color": Color("ffa44b")
    },
    "pirate_galleon": {
        "name": "PIRATE GALLEON DOCK",
        "sky": preload("res://assets/textures/arenas/sky2_pirate_galleon.png"),
        "thumb": preload("res://assets/textures/ui/thumb_pirate_galleon.png"),
        "floor": preload("res://assets/textures/arenas/floor_stone_albedo.png"),
        "floor_em": null,
        "floor_norm": preload("res://assets/textures/arenas/floor_stone_normal.png"),
        "sun_color": Color("b5f5ff"),
        "sun_rot": Vector3(-40, 30, 0),
        "ambient_color": Color("427288"),
        "fire_color": Color("47e5ff")
    },
    "gladiator_fortress": {
        "name": "GLADIATOR BASTION",
        "sky": preload("res://assets/textures/arenas/sky2_gladiator_fortress.png"),
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
        "sky": preload("res://assets/textures/arenas/sky2_mystic_grove.png"),
        "thumb": preload("res://assets/textures/ui/thumb_mystic_grove.png"),
        "floor": preload("res://assets/textures/arenas/floor_stone_albedo.png"),
        "floor_em": null,
        "floor_norm": preload("res://assets/textures/arenas/floor_stone_normal.png"),
        "sun_color": Color("64ffda"),
        "sun_rot": Vector3(-45, -15, 0),
        "ambient_color": Color("143b34"),
        "fire_color": Color("3bfac8")
    },
    "frozen_summit": {
        "name": "FROZEN SUMMIT",
        "sky": preload("res://assets/textures/arenas/sky2_frozen_summit.png"),
        "thumb": null, "floor": null, "floor_em": null, "floor_norm": null,
        "sun_color": Color("e0f2fe"),
        "sun_rot": Vector3(-40, 25, 0),
        "ambient_color": Color("3b5b7a"),
        "fire_color": Color("9be7ff")
    },
    "neon_metropolis": {
        "name": "NEON METROPOLIS",
        "sky": preload("res://assets/textures/arenas/sky2_neon_metropolis.png"),
        "thumb": null, "floor": null, "floor_em": null, "floor_norm": null,
        "sun_color": Color("ffb3e6"),
        "sun_rot": Vector3(-50, -30, 0),
        "ambient_color": Color("3a1d5c"),
        "fire_color": Color("ff3db4")
    }
}

var sim = Combat.new()
var views: Array = []
var camera: Camera3D
var selection: Control
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
## HUD portrait per fighter family, resolved once instead of every frame.
var portrait_cache: Dictionary = {}
var audio: Dictionary = {}
var active := false
var paused := false
var accumulator := 0.0
## Frames a button press stays valid until the simulation can execute it.
const INPUT_BUFFER_FRAMES := 5
const BUFFERED_ACTIONS := ["standard", "special", "jump", "grab"]
## Simulation events that prove a buffered action was executed (the buffer is then cleared).
const BUFFER_CONSUMERS := {
    "attack": ["standard", "special"],
    "charge": ["standard"],
    "air_dash": ["special"],
    "dodge": ["jump"],
    "item_throw": ["standard", "grab"],
    "throw": ["standard", "special", "grab", "jump"],
    "jump": ["jump"], "double_jump": ["jump"], "drop_through": ["jump"],
    "grab_attempt": ["grab"], "item_pickup": ["grab"], "powerup_activated": ["grab"],
}
## Per player: action -> frames left in the buffer.
var input_buffer: Array = [new_buffer(), new_buffer(), new_buffer(), new_buffer()]
## Event text shown in the status line for a short time before the default text returns.
const STATUS_MESSAGE_SECONDS := 1.6
var status_message := ""
var status_message_time := 0.0
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
## Builds the stage, platforms, scenery, weather and accent lights of every arena.
var arena_builder: Node3D
var camera_shake := 0.0
var camera_look := Vector3(0, 1.15, 0)
## Big center announcer text ("3", "2", "1", "GO!", "GAME!") and full-screen flash.
var big_label: Label
var screen_flash: ColorRect
var last_countdown_step := -1
var first_hit_done := false
## F3 toggles a frame-rate display (performance check).
var fps_label: Label
var fps_samples: Array = []

## True while a story cutscene owns the camera and the fighters.
var cinematic := false
var story: Node = null
## One colored "P1 ▼" marker per fighter, following its interpolated position.
var player_markers: Array = []
var camera_punch := Vector2.ZERO   # directional punch for hits

# Upgrade: super meter bars, delay health bars, combo labels
var super_bars: Array = []
var delay_hp: Array = [0.0, 0.0]      # tracks the "delayed" red bar
var delay_hp_bars: Array = []
var combo_labels: Array = []
var hitstop_freeze := 0               # global rendering freeze frames
var lives_labels: Array = []
var item_nodes: Array = []
## Projectile visuals by projectile id.
var projectile_nodes: Dictionary = {}
var battle_hud_top: PanelContainer
var battle_hud_bottom: PanelContainer
var player_count: int = 2
var player_slot_boxes: Array = []

var active_picker := 0
var mk_card_buttons: Array = []
var mk_toggle_buttons: Array = []
var mk_presets: Array = []
var current_combat_mode: String = "pve"
## Match options from the selection screen.
var ai_level := 5
var stock_count := 3
var finishers_on := true
## Blood on hits and gory finishers (can be switched off in the menu).
var gore_on := true
## Pools, gibs and other finisher remains; cleared at the next match.
var gore_nodes: Array = []
var blood_drop_tex: Texture2D
var blood_pool_tex: Texture2D
var screen_blood_tex: Texture2D
var screen_blood_rect: TextureRect
var mk_p1_name_label: Label
var mk_p1_sub_label: Label
var mk_p1_stats_label: Label
var mk_p2_name_label: Label
var mk_p2_sub_label: Label
var mk_p2_stats_label: Label

var fusionskammer_modal: PanelContainer
var fusionskammer_prompt_edit: LineEdit
var fusionskammer_body_option: OptionButton
var fusionskammer_weapon_option: OptionButton
var fusionskammer_elem_option: OptionButton
var fusionskammer_stats_label: Label
var fusionskammer_status_label: Label

# Character Remixer UI state
var remix_prompts: Array = []       # LineEdit references
var remix_info: Array = []          # Label references for remix results
var remix_profiles: Array = [{}, {}] # Cached remix character profiles

func _ready() -> void:
    for arg in OS.get_cmdline_user_args():
        if arg == "--smoke": smoke = true
        if arg == "--capture-selection": capture_selection = true
        if arg.begins_with("--capture-dir="): capture_dir = arg.trim_prefix("--capture-dir=")
    setup_inputs()
    setup_world()
    setup_player_markers()
    setup_ui()
    setup_audio()
    restore_prompts()
    refresh_previews()
    update_mk_grid_visuals()
    get_window().focus_exited.connect(func():
        if active and sim.mode == "manual" and not smoke: paused = true)
    story = StoryModeScript.new()
    story.name = "StoryMode"
    add_child(story)
    story.setup(self)
    if smoke: start_round("autonomous")
    elif capture_selection and not capture_dir.is_empty():
        await get_tree().create_timer(0.5).timeout
        await capture("godot-selection.png")
        get_tree().quit()

## Keyboard: P1 left side, P2 right side. Gamepads: device k controls player k+1
## (A attack, B special, X/Y jump, RB grab, LB/triggers shield, stick/d-pad move).
const KEYBOARD_MAP := {
    "p1_left": [KEY_A], "p1_right": [KEY_D], "p1_jump": [KEY_W], "p1_up": [KEY_W], "p1_down": [KEY_S],
    "p1_block": [KEY_Q], "p1_standard": [KEY_F], "p1_special": [KEY_G], "p1_grab": [KEY_E],
    "p2_left": [KEY_LEFT], "p2_right": [KEY_RIGHT], "p2_jump": [KEY_UP], "p2_up": [KEY_UP], "p2_down": [KEY_DOWN],
    "p2_block": [KEY_I, KEY_KP_0], "p2_standard": [KEY_K, KEY_KP_1], "p2_special": [KEY_L, KEY_KP_2], "p2_grab": [KEY_O, KEY_KP_3],
}
const PLAYER_ACTIONS := ["left", "right", "jump", "up", "down", "block", "standard", "special", "grab"]
const MAX_PLAYERS := 4

func setup_inputs() -> void:
    for pi in range(MAX_PLAYERS):
        for suffix in PLAYER_ACTIONS:
            var action := "p%d_%s" % [pi + 1, suffix]
            if not InputMap.has_action(action): InputMap.add_action(action, 0.35)
            InputMap.action_erase_events(action)
    for action in KEYBOARD_MAP:
        for key in KEYBOARD_MAP[action]:
            var event := InputEventKey.new()
            event.physical_keycode = key
            InputMap.action_add_event(action, event)
    for pi in range(MAX_PLAYERS):
        var pre := "p%d_" % (pi + 1)
        _pad_axis(pre + "left", pi, JOY_AXIS_LEFT_X, -1.0)
        _pad_axis(pre + "right", pi, JOY_AXIS_LEFT_X, 1.0)
        _pad_axis(pre + "up", pi, JOY_AXIS_LEFT_Y, -1.0)
        _pad_axis(pre + "down", pi, JOY_AXIS_LEFT_Y, 1.0)
        _pad_axis(pre + "block", pi, JOY_AXIS_TRIGGER_LEFT, 1.0)
        _pad_axis(pre + "block", pi, JOY_AXIS_TRIGGER_RIGHT, 1.0)
        _pad_button(pre + "left", pi, JOY_BUTTON_DPAD_LEFT)
        _pad_button(pre + "right", pi, JOY_BUTTON_DPAD_RIGHT)
        _pad_button(pre + "up", pi, JOY_BUTTON_DPAD_UP)
        _pad_button(pre + "down", pi, JOY_BUTTON_DPAD_DOWN)
        _pad_button(pre + "standard", pi, JOY_BUTTON_A)
        _pad_button(pre + "special", pi, JOY_BUTTON_B)
        _pad_button(pre + "jump", pi, JOY_BUTTON_X)
        _pad_button(pre + "jump", pi, JOY_BUTTON_Y)
        _pad_button(pre + "grab", pi, JOY_BUTTON_RIGHT_SHOULDER)
        _pad_button(pre + "block", pi, JOY_BUTTON_LEFT_SHOULDER)

func _pad_button(action: String, device: int, button: JoyButton) -> void:
    var ev := InputEventJoypadButton.new()
    ev.device = device
    ev.button_index = button
    InputMap.action_add_event(action, ev)

func _pad_axis(action: String, device: int, axis: JoyAxis, value: float) -> void:
    var ev := InputEventJoypadMotion.new()
    ev.device = device
    ev.axis = axis
    ev.axis_value = value
    InputMap.action_add_event(action, ev)

## Players 1 and 2 always have keyboard controls; players 3 and 4 need a gamepad.
func human_count() -> int:
    if sim.mode == "autonomous": return 0
    if sim.mode == "pve": return 1
    return clampi(maxi(2, Input.get_connected_joypads().size()), 2, mini(MAX_PLAYERS, sim.fighters.size()))

func setup_world() -> void:
    world_env = WorldEnvironment.new()
    world_env.environment = Environment.new()
    world_env.environment.background_mode = Environment.BG_SKY
    world_env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    world_env.environment.ambient_light_energy = 1.45
    # AgX keeps bright costumes and emissive effects from clipping to flat white.
    world_env.environment.tonemap_mode = Environment.TONE_MAPPER_AGX
    world_env.environment.tonemap_exposure = 1.05
    world_env.environment.tonemap_white = 6.0

    # AAA Glow: high threshold to avoid milky washed-out textures, crisp blooming on auras & specials
    world_env.environment.glow_enabled = true
    world_env.environment.glow_normalized = true
    world_env.environment.glow_bloom = 0.15
    world_env.environment.glow_intensity = 0.55
    world_env.environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
    world_env.environment.glow_hdr_threshold = 1.25
    world_env.environment.glow_hdr_scale = 1.6

    # Performance: Volumetric fog & SSR disabled on integrated/desktop graphics to prevent frame drops
    world_env.environment.volumetric_fog_enabled = false
    world_env.environment.ssr_enabled = false

    # Fast Lightweight SSAO
    world_env.environment.ssao_enabled = false
    world_env.environment.ssao_radius = 1.1
    world_env.environment.ssao_intensity = 1.6
    world_env.environment.ssao_power = 1.4
    world_env.environment.ssao_detail = 0.2

    world_env.environment.adjustment_enabled = true
    world_env.environment.adjustment_contrast = 1.06
    world_env.environment.adjustment_saturation = 1.12
    # Depth haze: separates the fighters (z = 0) from the scenery behind them.
    world_env.environment.fog_enabled = true
    world_env.environment.fog_density = 0.0045
    world_env.environment.fog_sky_affect = 0.0
    world_env.environment.fog_aerial_perspective = 0.12
    add_child(world_env)

    arena_builder = ArenaBuilder.new()
    arena_builder.name = "ArenaBuilder"
    add_child(arena_builder)

    sunlight = DirectionalLight3D.new()
    sunlight.light_cull_mask = 1 | 2
    sunlight.shadow_enabled = true
    sunlight.shadow_bias = 0.012
    sunlight.shadow_normal_bias = 1.0
    sunlight.shadow_blur = 1.2
    sunlight.light_energy = 2.4
    sunlight.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
    sunlight.directional_shadow_max_distance = 45.0
    add_child(sunlight)

    # 3-Point Character Rig: Dedicated Rim/Kicker Light (Isolated to Layer 2: Fighters only, zero floor sheen!)
    var rim_light := DirectionalLight3D.new()
    rim_light.name = "FighterRimLight"
    rim_light.light_cull_mask = 2
    rim_light.light_energy = 2.6
    rim_light.light_color = Color("cde8ff")
    rim_light.rotation_degrees = Vector3(148, 20, 0)
    rim_light.shadow_enabled = false
    add_child(rim_light)

    # Ambient Fill light from front angle: brightens shadows so game is not dark
    var fill_light := DirectionalLight3D.new()
    fill_light.name = "FighterFillLight"
    fill_light.light_cull_mask = 1 | 2
    fill_light.light_energy = 1.15
    fill_light.light_color = Color("fff5ea")
    fill_light.rotation_degrees = Vector3(35, 15, 0)
    fill_light.shadow_enabled = false
    add_child(fill_light)

    camera = Camera3D.new()
    # The camera is moved in _process (every rendered frame), so it must not be physics-interpolated.
    camera.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
    camera.position = Vector3(0, 1.55, 5.2)
    camera.fov = 52
    camera.far = 400
    add_child(camera)
    camera.look_at(Vector3(0, 1.15, 0.0))
    camera.current = true

    setup_items()
    apply_arena(current_arena)

## Items spawned during the match (weapons, power-ups) get their visuals here.
func ensure_item_nodes() -> void:
    while item_nodes.size() < sim.items.size():
        var it_data: Dictionary = sim.items[item_nodes.size()]
        var root_item := Node3D.new()
        root_item.position = Vector3(it_data.x, it_data.y, 0.0)
        add_child(root_item)
        item_nodes.append(root_item)
        if it_data.get("weapon", "") != "":
            var model: Node3D = WeaponModels.build(it_data.weapon)
            model.name = "Model"
            root_item.add_child(model)
            var ring := MeshInstance3D.new()
            var torus := TorusMesh.new()
            torus.inner_radius = 0.42
            torus.outer_radius = 0.5
            ring.mesh = torus
            ring.name = "PickupRing"
            var col: Color = Combat.WEAPONS[it_data.weapon].color
            var rmat := StandardMaterial3D.new()
            rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
            rmat.albedo_color = Color(col.r * 1.6, col.g * 1.6, col.b * 1.6)
            ring.material_override = rmat
            ring.position.y = -0.1
            root_item.add_child(ring)
        else:
            var spec_models := {
                "titan_mushroom": "res://assets/models/items/item_titan_mushroom.glb",
                "invulnerable_star": "res://assets/models/items/item_invulnerable_star.glb",
                "speed_boots": "res://assets/models/items/item_speed_boots.glb",
                "smash_hammer": "res://assets/models/items/item_smash_hammer.glb",
                "health_heart": "res://assets/models/items/item_health_heart.glb",
                "freeze_orb": "res://assets/models/items/item_freeze_orb.glb"
            }
            if spec_models.has(it_data.type) and ResourceLoader.exists(spec_models[it_data.type]):
                var smod: Node3D = load(spec_models[it_data.type]).instantiate()
                smod.scale = Vector3.ONE * 0.85
                root_item.add_child(smod)

## Weapons: resting ones hover and spin, wielded ones sit in the fighter's hand.
func update_item_node(it_i: int, it_data: Dictionary, node: Node3D, delta: float) -> void:
    if it_data.get("weapon", "") == "": return
    var model: Node3D = node.get_node_or_null("Model")
    var ring: Node3D = node.get_node_or_null("PickupRing")
    if ring: ring.visible = it_data.state == "resting" or it_data.state == "free"
    if model == null: return
    if it_data.state == "wielded" and it_data.carrier >= 0 and it_data.carrier < views.size():
        var f: Dictionary = sim.fighters[it_data.carrier]
        node.global_transform = views[it_data.carrier].weapon_grip(float(f.facing))
        model.transform = Transform3D.IDENTITY
    elif it_data.state == "thrown":
        node.rotation = Vector3.ZERO
        model.rotation.z -= delta * 14.0
    else:
        node.rotation = Vector3.ZERO
        model.rotation = Vector3(0, fmod(Time.get_ticks_msec() * 0.002, TAU), deg_to_rad(90))
        model.position.y = 0.35 + sin(Time.get_ticks_msec() * 0.004 + it_i) * 0.08

func update_projectiles() -> void:
    var alive := {}
    for pr in sim.projectiles:
        alive[pr.id] = true
        var node: Node3D = projectile_nodes.get(pr.id)
        var spec: Dictionary = pr.get("spec", {})
        var shape: String = str(spec.get("shape", pr.kind))
        var col: Color = spec.get("color", PLAYER_COLORS[int(pr.owner) % PLAYER_COLORS.size()])
        if node == null:
            node = WeaponModels.projectile(shape, col)
            node.set_meta("last_pillar_x", pr.x - 99.0)
            add_child(node)
            projectile_nodes[pr.id] = node
        node.position = Vector3(pr.x, pr.y, 0.3)
        if shape in ["saber", "boomerang", "scythe", "glitch"]:
            node.rotation.z -= 0.35
        elif shape in ["pillar", "bone"]:
            # Eruption: pillars burst out of the ground along the path.
            if absf(pr.x - float(node.get_meta("last_pillar_x"))) > 0.9:
                node.set_meta("last_pillar_x", pr.x)
                erupt_pillar(Vector3(pr.x, pr.y - 0.4, 0.2), col, shape == "bone")
        else:
            node.rotation = Vector3(0, 0 if pr.vx >= 0.0 else PI, atan2(pr.vy, absf(pr.vx)) * (1.0 if pr.vx >= 0.0 else -1.0))
    for id in projectile_nodes.keys():
        if not alive.has(id):
            projectile_nodes[id].queue_free()
            projectile_nodes.erase(id)

func setup_items() -> void:
    for node in item_nodes: node.queue_free()
    item_nodes.clear()
    for id in projectile_nodes.keys(): projectile_nodes[id].queue_free()
    projectile_nodes.clear()

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

        elif it_data.type == "explosive_barrel":
            var cyl := CylinderMesh.new()
            cyl.top_radius = 0.28
            cyl.bottom_radius = 0.28
            cyl.height = 0.64
            mesh_inst.mesh = cyl
            var mat := StandardMaterial3D.new()
            mat.albedo_color = Color("c62828") # High-hazard Danger Red
            mat.roughness = 0.45
            mat.metallic = 0.35
            mat.rim_enabled = true
            mat.rim = 0.85
            mat.rim_tint = 0.60
            mesh_inst.material_override = mat

            for y_off in [-0.20, 0.0, 0.20]:
                var hoop := MeshInstance3D.new()
                var hoop_cyl := CylinderMesh.new()
                hoop_cyl.top_radius = 0.29
                hoop_cyl.bottom_radius = 0.29
                hoop_cyl.height = 0.05
                hoop.mesh = hoop_cyl
                hoop.position.y = y_off
                var hoop_mat := StandardMaterial3D.new()
                hoop_mat.albedo_color = Color("1a1c20") if y_off != 0.0 else Color("ffd600")
                hoop_mat.metallic = 0.90
                hoop_mat.roughness = 0.20
                if y_off == 0.0:
                    hoop_mat.emission_enabled = true
                    hoop_mat.emission = Color("ffaa00")
                    hoop_mat.emission_energy_multiplier = 1.8
                hoop.material_override = hoop_mat
                root_item.add_child(hoop)

            var cap := MeshInstance3D.new()
            var cap_sph := SphereMesh.new()
            cap_sph.radius = 0.12
            cap_sph.height = 0.18
            cap.mesh = cap_sph
            cap.position.y = 0.34
            var cap_mat := StandardMaterial3D.new()
            cap_mat.albedo_color = Color(2.5, 0.8, 0.2)
            cap_mat.emission_enabled = true
            cap_mat.emission = Color("ff3d00")
            cap_mat.emission_energy_multiplier = 4.2
            cap.material_override = cap_mat
            root_item.add_child(cap)

        else:
            # Special Item 3D Models
            var spec_models := {
                "titan_mushroom": "res://assets/models/items/item_titan_mushroom.glb",
                "invulnerable_star": "res://assets/models/items/item_invulnerable_star.glb",
                "speed_boots": "res://assets/models/items/item_speed_boots.glb",
                "smash_hammer": "res://assets/models/items/item_smash_hammer.glb",
                "health_heart": "res://assets/models/items/item_health_heart.glb",
                "freeze_orb": "res://assets/models/items/item_freeze_orb.glb"
            }
            if spec_models.has(it_data.type) and ResourceLoader.exists(spec_models[it_data.type]):
                var smod: Node3D = load(spec_models[it_data.type]).instantiate()
                smod.scale = Vector3.ONE * 0.85
                root_item.add_child(smod)

        root_item.add_child(mesh_inst)

func apply_arena(id: String) -> void:
    if not ARENAS.has(id): id = "blood_moon"
    current_arena = id
    var a: Dictionary = ARENAS[id]

    var sky := Sky.new()
    var sky_mat := PanoramaSkyMaterial.new()
    # Photographed HDR (Poly Haven) for real light and reflections; the sharp tonemapped
    # panorama is shown by the arena's sky dome. Falls back to the painted sky.
    var theme: Dictionary = ArenaBuilder.THEMES.get(id, {})
    var hdr_path := "res://assets/polyhaven/hdri/%s_2k.hdr" % theme.get("sky", "")
    sky_mat.panorama = load(hdr_path) if ResourceLoader.exists(hdr_path) else a.sky
    sky.radiance_size = Sky.RADIANCE_SIZE_256
    sky_mat.energy_multiplier = float(theme.get("sky_energy", 1.0))
    sky.sky_material = sky_mat
    world_env.environment.sky = sky
    world_env.environment.sky_rotation = Vector3(0, deg_to_rad(float(theme.get("sky_rot", 90.0))), 0)
    world_env.environment.ambient_light_color = a.ambient_color
    world_env.environment.ambient_light_energy = 0.75
    world_env.environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
    world_env.environment.fog_light_color = a.ambient_color.lerp(a.fire_color, 0.25).lightened(0.15)

    # Match atmospheric volumetric fog to current arena mood
    world_env.environment.volumetric_fog_albedo = a.ambient_color.lerp(Color(0.8, 0.9, 1.0), 0.20)
    world_env.environment.volumetric_fog_emission = a.ambient_color * 0.35

    var rim_light_node := find_child("FighterRimLight", false, false) as DirectionalLight3D
    if rim_light_node:
        rim_light_node.light_color = a.sun_color.lerp(Color.WHITE, 0.4)

    # Bright daylight / snow arenas need less exposure than night arenas.
    world_env.environment.tonemap_exposure = {"imperial_colosseum": 0.8, "frozen_summit": 0.78, "gladiator_fortress": 0.9,
        "volcano_sanctum": 0.9, "pirate_galleon": 0.95}.get(id, 1.05)
    sunlight.rotation_degrees = a.sun_rot
    sunlight.light_color = a.sun_color
    sunlight.light_energy = 1.35
    arena_builder.build(id)

    if status:
        status.text = "%s  /  %s" % [a.name, ("AGENTENKAMPF" if sim.mode == "autonomous" else "LOKALER VERSUS")]

func panel_style(color: Color, border: Color = Color("34445b"), width: int = 1, radius: int = 12) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = color
    s.border_color = border
    s.set_border_width_all(width)
    s.set_corner_radius_all(radius)
    s.content_margin_left = 18
    s.content_margin_right = 18
    s.content_margin_top = 12
    s.content_margin_bottom = 12
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
    battle_hud_top = top
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 20)
    top.add_child(row)
    portrait_rects.clear()
    health_bars.clear()
    health_text.clear()
    names.clear()
    special_text.clear()
    lives_labels.clear()
    player_slot_boxes.clear()

    var col_left := VBoxContainer.new()
    col_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    col_left.add_theme_constant_override("separation", 6)
    row.add_child(col_left)

    var middle := VBoxContainer.new()
    middle.custom_minimum_size.x = 130
    row.add_child(middle)
    var brand := label("PROMPT FIGHTER", 15, CYAN)
    brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    middle.add_child(brand)
    timer = label("99", 34)
    timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    middle.add_child(timer)

    var col_right := VBoxContainer.new()
    col_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    col_right.add_theme_constant_override("separation", 6)
    row.add_child(col_right)

    var player_colors: Array = [CYAN, ORANGE, Color("4ade80"), Color("c084fc")]

    for p_i in range(4):
        var parent_col: VBoxContainer = col_left if (p_i == 0 or p_i == 2) else col_right
        var player_h := HBoxContainer.new()
        player_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        player_h.add_theme_constant_override("separation", 10)
        parent_col.add_child(player_h)
        player_slot_boxes.append(player_h)

        # Character icon box with colored glowing border
        var port_panel := PanelContainer.new()
        port_panel.custom_minimum_size = Vector2(58, 58)
        port_panel.add_theme_stylebox_override("panel", panel_style(Color("101622"), player_colors[p_i], 2, 8))

        var port := TextureRect.new()
        port.custom_minimum_size = Vector2(52, 52)
        port.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        port.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        port.texture = PORTRAITS["ninja"]
        port_panel.add_child(port)
        portrait_rects.append(port)
        if p_i == 0 or p_i == 2: player_h.add_child(port_panel)

        var box := VBoxContainer.new()
        box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        box.add_theme_constant_override("separation", 1)
        player_h.add_child(box)

        var title_h := HBoxContainer.new()
        title_h.add_theme_constant_override("separation", 8)
        box.add_child(title_h)
        var title := label("P%d" % (p_i + 1), 12, player_colors[p_i])
        title_h.add_child(title)
        names.append(title)

        var cd := label("⚡ SPEZIAL BEREIT", 10, Color("9ab2cf"))
        title_h.add_child(cd)
        special_text.append(cd)

        # Large damage percent display
        var dmg_lbl := label("0 %", 28, Color("ffffff"))
        box.add_child(dmg_lbl)
        health_text.append(dmg_lbl)

        var lives_lbl := label("● ● ●", 11, Color("ff3b5c"))
        box.add_child(lives_lbl)
        lives_labels.append(lives_lbl)

        var dummy_bar := ProgressBar.new()
        dummy_bar.visible = false
        box.add_child(dummy_bar)
        health_bars.append(dummy_bar)

        if p_i == 1 or p_i == 3: player_h.add_child(port_panel)

    var bottom := PanelContainer.new()
    battle_hud_bottom = bottom
    root_ui.add_child(bottom)
    bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
    bottom.offset_left = 24
    bottom.offset_right = -24
    bottom.offset_top = -106
    bottom.offset_bottom = -18
    bottom.add_theme_stylebox_override("panel", panel_style(Color(0.025,0.042,0.075,0.94)))
    var footer := HBoxContainer.new()
    bottom.add_child(footer)
    var keys := label("P1  A/D · W Sprung/↑ · S ↓ · Q Schild · F Schlag (halten = Smash · auf Waffe = aufheben) · G Spezial (Luft: DASH) · E Greifen/Werfen   |   P2  Pfeile · I Schild · K · L · O   |   🎮 Gamepads: A Schlag · B Spezial · X/Y Sprung · LB Schild · RB Greifen", 11)
    keys.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    footer.add_child(keys)
    footer.add_child(button("↻  R", CYAN, restart_round))
    footer.add_child(button("Auswahl", ORANGE, show_selection))
    status = label("BLOOD MOON TERRACE  /  LOKALER VERSUS", 15, Color("bfcee1"))
    root_ui.add_child(status)
    status.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
    status.position = Vector2(390, 159)

    # Hide battle HUD initially while in character selection
    battle_hud_top.hide()
    battle_hud_bottom.hide()
    status.hide()

    selection = Control.new()
    selection.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    selection.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root_ui.add_child(selection)

    # Hidden prompt holders to maintain full compatibility with sim
    prompts.clear()
    profile_text.clear()
    var default_prompts := [
        "Blitzschneller Schattenninja mit elektrischen Klingen",
        "Gepanzerter Lavagolem mit brennenden Fäusten",
        "Samurai Dreyar Meister mit Wind-Klingen und Sturm-Schritten",
        "Vampirfuerst Vlad Gothic Lord mit Blut-Magie und Fledermaus-Schwarm"
    ]
    for pi in range(4):
        var h_edit := LineEdit.new()
        h_edit.visible = false
        h_edit.text = default_prompts[pi]
        selection.add_child(h_edit)
        prompts.append(h_edit)
        var h_info := Label.new()
        h_info.visible = false
        selection.add_child(h_info)
        profile_text.append(h_info)

    # 1. TOP HEADER BAR
    var top_bar := PanelContainer.new()
    top_bar.position = Vector2(24, 12)
    top_bar.custom_minimum_size = Vector2(1232, 44)
    top_bar.add_theme_stylebox_override("panel", panel_style(Color(0.02, 0.03, 0.06, 0.82), Color(0.18, 0.24, 0.35, 0.6), 1, 8))
    selection.add_child(top_bar)

    var top_h := HBoxContainer.new()
    top_h.add_theme_constant_override("separation", 7)
    top_bar.add_child(top_h)

    var btn_random := button("🎲 ZUFALL [J]", Color("f7c844"), _on_random_select_pressed)
    btn_random.custom_minimum_size = Vector2(120, 34)
    btn_random.add_theme_font_size_override("font_size", 12)
    top_h.add_child(btn_random)

    var btn_story := button("📖 STORYMODUS", Color("f472b6"), func(): story.open_menu())
    btn_story.custom_minimum_size = Vector2(130, 34)
    btn_story.add_theme_font_size_override("font_size", 12)
    top_h.add_child(btn_story)

    var btn_players := button("👥 2 SPIELER (1v1)", Color("38bdf8"), _toggle_player_count)
    btn_players.name = "BtnPlayerCount"
    btn_players.custom_minimum_size = Vector2(150, 34)
    btn_players.add_theme_font_size_override("font_size", 12)
    top_h.add_child(btn_players)

    var title_spacer1 := Control.new()
    title_spacer1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top_h.add_child(title_spacer1)

    var mk_title := label("WÄHLE DEINEN KÄMPFER", 16, Color("f7c844"))
    mk_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    top_h.add_child(mk_title)

    var title_spacer2 := Control.new()
    title_spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    top_h.add_child(title_spacer2)

    for spec in [["BtnAiLevel", _cycle_ai_level, Color("94a3b8")], ["BtnStocks", _cycle_stocks, Color("f87171")], ["BtnFinisher", _toggle_finishers, Color("ef4444")]]:
        var ob := button("", spec[2], spec[1])
        ob.name = spec[0]
        ob.custom_minimum_size = Vector2(100, 34)
        ob.add_theme_font_size_override("font_size", 11)
        top_h.add_child(ob)

    var btn_mode := button("⚔ SPIELER vs KI", Color("4ae371"), _cycle_combat_mode)
    btn_mode.name = "BtnCombatMode"
    btn_mode.custom_minimum_size = Vector2(160, 34)
    btn_mode.add_theme_font_size_override("font_size", 12)
    top_h.add_child(btn_mode)

    # 2. P1 FIGHTER DISPLAY (LOWER LEFT ABOVE CARDS)
    var p1_box := VBoxContainer.new()
    p1_box.position = Vector2(30, 440)
    p1_box.custom_minimum_size = Vector2(460, 95)
    p1_box.add_theme_constant_override("separation", 2)
    selection.add_child(p1_box)

    mk_p1_name_label = label("VOLT NINJA", 32, Color("ffffff"))
    p1_box.add_child(mk_p1_name_label)

    mk_p1_sub_label = label("⚡ BLITZ · SCHATTEN-ASSASSINE", 13, CYAN)
    p1_box.add_child(mk_p1_sub_label)

    mk_p1_stats_label = label("HP 100 · KRAFT 20 · RÜSTUNG 14 · TEMPO 28 · TECHNIK 22", 11, Color("bfcee1"))
    p1_box.add_child(mk_p1_stats_label)

    # 3. P2 FIGHTER DISPLAY (LOWER RIGHT ABOVE CARDS)
    var p2_box := VBoxContainer.new()
    p2_box.position = Vector2(790, 440)
    p2_box.custom_minimum_size = Vector2(460, 95)
    p2_box.add_theme_constant_override("separation", 2)
    selection.add_child(p2_box)

    mk_p2_name_label = label("LAVA GOLEM", 32, Color("ffffff"))
    mk_p2_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    p2_box.add_child(mk_p2_name_label)

    mk_p2_sub_label = label("🔥 FEUER · MAGMA-KOLOSS", 13, ORANGE)
    mk_p2_sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    p2_box.add_child(mk_p2_sub_label)

    mk_p2_stats_label = label("HP 135 · KRAFT 28 · RÜSTUNG 26 · TEMPO 8 · TECHNIK 8", 11, Color("bfcee1"))
    mk_p2_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    p2_box.add_child(mk_p2_stats_label)

    var p2_join := label("[RECHTSKLICK]: P2 WÄHLEN  ·  [A] BEITRETEN", 10, Color("55dd88"))
    p2_join.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    p2_box.add_child(p2_join)

    # 4. CENTER START MATCH BUTTON & ARENA SELECTOR
    var center_box := VBoxContainer.new()
    center_box.position = Vector2(500, 418)
    center_box.custom_minimum_size = Vector2(280, 85)
    center_box.alignment = BoxContainer.ALIGNMENT_CENTER
    selection.add_child(center_box)

    var btn_start_match := button("⚔ KAMPF STARTEN [ENTER]", Color("ff5500"), func(): start_round(current_combat_mode))
    btn_start_match.custom_minimum_size = Vector2(280, 44)
    btn_start_match.add_theme_font_size_override("font_size", 16)
    center_box.add_child(btn_start_match)

    var arena_row := GridContainer.new()
    arena_row.columns = 4
    arena_row.add_theme_constant_override("h_separation", 4)
    arena_row.add_theme_constant_override("v_separation", 3)
    center_box.add_child(arena_row)
    for aid in ARENAS:
        var abtn := Button.new()
        abtn.text = ARENAS[aid].name.left(10)
        abtn.custom_minimum_size = Vector2(68, 20)
        abtn.add_theme_font_size_override("font_size", 8)
        abtn.add_theme_stylebox_override("normal", panel_style(Color("162b40"), Color("34445b"), 1, 4))
        abtn.focus_mode = Control.FOCUS_NONE
        var target_aid: String = aid
        abtn.pressed.connect(func(): apply_arena(target_aid))
        arena_row.add_child(abtn)

    _refresh_option_buttons.call_deferred()

    # 5. 40-FIGHTER PRESETS (2 ROWS OF 20 CARDS)
    mk_presets = [
        {"id": "ninja", "name": "VOLT NINJA", "prompt": "Blitzschneller Schattenninja mit elektrischen Klingen"},
        {"id": "golem", "name": "LAVA GOLEM", "prompt": "Gepanzerter Lavagolem mit brennenden Fäusten"},
        {"id": "valkyrie", "name": "VALKYRIE", "prompt": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier"},
        {"id": "dragon", "name": "IGNIS DRAKE", "prompt": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert"},
        {"id": "goku", "name": "KAIRO", "prompt": "Kairo der Sturmmönch mit Solar-Kanone"},
        {"id": "vegeta", "name": "VARAKH", "prompt": "Varakh der Sternenprinz mit Nova-Strahl"},
        {"id": "frieza", "name": "XYLAR", "prompt": "Xylar der Leerenkaiser mit Nadelstrahl"},
        {"id": "subzero", "name": "GLACIEM", "prompt": "Glaciem die Frostassassine mit Eissplitter"},
        {"id": "pain", "name": "ORYN", "prompt": "Oryn der Schwerkraftprophet mit Abstoßungswelle"},
        {"id": "luffy", "name": "TOBI", "prompt": "Tobi der Gummikapitän mit Schleuderfaust"},
        {"id": "zoro", "name": "JUBEI", "prompt": "Jubei der Dreiklingen-Wanderer mit Tigerschnitt"},
        {"id": "naruto", "name": "REN", "prompt": "Ren der Wirbelfuchs mit Spiralkern"},
        {"id": "sasuke", "name": "KAGE", "prompt": "Kage der Donnerklinge mit Tausend Funken"},
        {"id": "saitama", "name": "BRUNO", "prompt": "Bruno der Einschlag-Held mit Ernstfall-Schlag"},
        {"id": "tanjiro", "name": "HIKARU", "prompt": "Hikaru der Sonnentänzer mit Morgenrotschnitt"},
        {"id": "sonic", "name": "ZIP", "prompt": "Zip der Tempoigel mit Turbo-Rolle"},
        {"id": "akaza", "name": "RAIGA", "prompt": "Raiga der Kompassdämon mit Kompassnova"},
        {"id": "blue_eyes", "name": "ALBION", "prompt": "Albion der Silberwyrm mit Sturmstrahl"},
        {"id": "charizard", "name": "PYRAX", "prompt": "Pyrax die Glutwyvern mit Glutsturm"},
        {"id": "anubis", "name": "ANUBIS", "prompt": "Jackal God Anubis wielding dual Khopesh"},
        {"id": "specter", "name": "SPECTER", "prompt": "Void Specter crystal phantom warrior with void lance"},
        {"id": "phoenix", "name": "PHOENIX", "prompt": "Phoenix Empress with feather armor and phoenix glaive"},
        {"id": "golden_golem", "name": "GOLD GOLEM", "prompt": "Golden Armored Golem ancient guardian titan Tripo"},
        {"id": "tripo_fran_statue", "name": "FRAN VIERA", "prompt": "Fran rabbit warrior huntress bow Tripo"},
        {"id": "tripo_fantasy_female", "name": "THORN WITCH", "prompt": "Thorn Sorceress dark magic Tripo"},
        {"id": "tripo_nyx_harvester", "name": "NYX HARVESTER", "prompt": "Nyx Harvester of Souls demon scythe reaper Tripo"},
        {"id": "tripo_cat_girl", "name": "KITSUNE", "prompt": "Cat Girl Kitsune Warrior blade Tripo"},
        {"id": "tripo_dragon_blue", "name": "BLUE WYRM", "prompt": "Blue Wyrm Frost Dragon beast Tripo"},
        {"id": "tripo_white_sci", "name": "CYBORG MECH", "prompt": "White Cyborg Android Mech warrior Tripo"},
        {"id": "tripo_skeleton_dog", "name": "REAPER HOUND", "prompt": "Reaper Skeleton Hound nether beast"},
        {"id": "tripo_wooden_forest", "name": "TREANT GOLEM", "prompt": "Ancient Treant Wood Golem nature Tripo"},
        {"id": "tripo_nine_tailed", "name": "CELESTIAL FOX", "prompt": "Celestial Nine Tailed Fox Kyuubi spirit Tripo"},
        {"id": "tripo_quadruped_tree", "name": "SYLVAN BEAST", "prompt": "Sylvan Beast Treant quadruped creature Tripo"},
        {"id": "steel_knight", "name": "STEEL KNIGHT", "prompt": "Steel Knight Ritter in Vollplatte mit eisernem Schild"},
        {"id": "vanguard_soldier", "name": "VANGUARD", "prompt": "Vanguard Soldat mit Cyber-Rüstung und Photonenkanone"},
        {"id": "sorceress_medea", "name": "SORCERESS", "prompt": "Sorceress Medea Erzmagierin mit astraler Dunkelmagie"},
        {"id": "skeleton_reaper", "name": "REAPER", "prompt": "Skeleton Reaper Untoter Seelenernter mit Knochensense"},
        {"id": "mutant_titan", "name": "MUTANT", "prompt": "Mutant Titan kolossaler Koloss mit Giftschlag"},
        {"id": "swat_specops", "name": "SWAT AGENT", "prompt": "SWAT SpecOps Taktischer Agent mit Schockgranaten"},
        {"id": "samurai_dreyar", "name": "SAMURAI", "prompt": "Samurai Dreyar Meister mit Wind-Klingen und Sturm-Schritten"},
        {"id": "pirate_captain", "name": "KORSAR", "prompt": "Korsar Corsair Piratenkapitän mit Entermesser und Donnerbüchse"},
        {"id": "vampire_lord", "name": "VLAD", "prompt": "Vampirfürst Vlad Gothic Lord mit Blut-Magie und Fledermaus-Schwarm"},
        {"id": "wizard_sorcerer", "name": "PYRUS", "prompt": "Erzmagier Pyrus Feuerzauberer mit Meteorschlag und Flammenstab"},
        {"id": "warrok_brute", "name": "WARROK", "prompt": "Warrok Koloss Urzeitlicher Berserker mit Knochenkeule und Erdbeben"},
        {"id": "nekra", "name": "NEKRA", "prompt": "Nekra die Seelenhirtin mit Knochengarten"},
        {"id": "grimbolt", "name": "GRIMBOLT", "prompt": "Grimbolt der Goblin-Tüftler mit Zeitbombe"},
        {"id": "echo", "name": "ECHO", "prompt": "Echo das Hologramm mit Phasentausch"},
        {"id": "kettenwart", "name": "KETTENWART", "prompt": "Kettenwart der Kerkermeister mit Seelenketten"},
        {"id": "don_valente", "name": "DON VALENTE", "prompt": "Don Valente der Unterweltpate mit Leibwächter-Geschütz"},
        {"id": "fusionskammer", "name": "FUSION", "prompt": "Fusionskammer: Eigenen Wunsch-Kämpfer erschaffen"}
    ]

    # 6. BOTTOM FIGHTER GRID CONTAINER
    var grid_panel := PanelContainer.new()
    grid_panel.position = Vector2(20, 555)
    grid_panel.custom_minimum_size = Vector2(1240, 150)
    grid_panel.add_theme_stylebox_override("panel", panel_style(Color(0.015, 0.025, 0.04, 0.88), Color("1e2a3a"), 1, 8))
    selection.add_child(grid_panel)

    var mk_grid := GridContainer.new()
    mk_grid.columns = 17
    mk_grid.add_theme_constant_override("h_separation", 4)
    mk_grid.add_theme_constant_override("v_separation", 4)
    grid_panel.add_child(mk_grid)

    mk_card_buttons.clear()
    for idx in range(mk_presets.size()):
        var preset: Dictionary = mk_presets[idx]
        var card := Button.new()
        card.custom_minimum_size = Vector2(68, 44)
        card.focus_mode = Control.FOCUS_NONE

        var card_v := VBoxContainer.new()
        card_v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        card_v.alignment = BoxContainer.ALIGNMENT_CENTER
        card_v.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card.add_child(card_v)

        var port_tex: Texture2D = null
        var rendered_port := "res://assets/textures/characters/portraits/portrait_%s.png" % preset.id
        if ResourceLoader.exists(rendered_port):
            port_tex = load(rendered_port)
        elif PORTRAITS.has(preset.id):
            port_tex = PORTRAITS[preset.id]
        elif ResourceLoader.exists("res://assets/textures/characters/thumbs/thumb_%s.png" % preset.id):
            port_tex = load("res://assets/textures/characters/thumbs/thumb_%s.png" % preset.id)

        var img := TextureRect.new()
        img.custom_minimum_size = Vector2(36, 36)
        img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        img.texture = port_tex
        img.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card_v.add_child(img)

        var n_lbl := Label.new()
        n_lbl.text = preset.name
        n_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        n_lbl.add_theme_font_size_override("font_size", 7)
        n_lbl.add_theme_color_override("font_color", Color("dce7f5"))
        n_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
        card_v.add_child(n_lbl)

        var badge_p1 := Label.new()
        badge_p1.text = "P1"
        badge_p1.add_theme_font_size_override("font_size", 9)
        badge_p1.add_theme_color_override("font_color", Color("ff9900"))
        badge_p1.position = Vector2(3, 2)
        badge_p1.visible = false
        card.add_child(badge_p1)

        var badge_p2 := Label.new()
        badge_p2.text = "P2"
        badge_p2.add_theme_font_size_override("font_size", 9)
        badge_p2.add_theme_color_override("font_color", CYAN)
        badge_p2.position = Vector2(40, 2)
        badge_p2.visible = false
        card.add_child(badge_p2)

        var p_idx := idx
        card.mouse_entered.connect(func():
            _on_card_hovered(p_idx)
        )
        card.pressed.connect(func():
            if preset.id == "fusionskammer":
                open_fusionskammer()
            else:
                on_mk_fighter_selected(0, p_idx)
        )
        card.gui_input.connect(func(ev: InputEvent):
            if ev is InputEventMouseButton and ev.is_pressed() and ev.button_index == MOUSE_BUTTON_RIGHT:
                if preset.id != "fusionskammer":
                    on_mk_fighter_selected(1, p_idx)
        )

        mk_grid.add_child(card)
        mk_card_buttons.append({"button": card, "badge_p1": badge_p1, "badge_p2": badge_p2})

    # 7. FUSIONSKAMMER MODAL STUDIO
    _setup_fusionskammer_modal()

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

    screen_flash = ColorRect.new()
    screen_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    screen_flash.color = Color(1, 1, 1, 0)
    screen_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root_ui.add_child(screen_flash)
    big_label = label("", 120, Color("f7c844"))
    big_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
    big_label.add_theme_constant_override("outline_size", 22)
    big_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    big_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    big_label.size = Vector2(1280, 200)
    big_label.position = Vector2(0, 240)
    big_label.pivot_offset = Vector2(640, 100)
    big_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    big_label.modulate.a = 0.0
    root_ui.add_child(big_label)

    fps_label = label("", 14, Color("a3e635"))
    fps_label.position = Vector2(1180, 124)
    fps_label.visible = false
    root_ui.add_child(fps_label)

    for pair in [["blood_drop_tex", "blood_drop"], ["blood_pool_tex", "blood_pool"], ["screen_blood_tex", "screen_blood"]]:
        var path := "res://assets/textures/vfx/%s.png" % pair[1]
        if ResourceLoader.exists(path): set(pair[0], load(path))
    screen_blood_rect = TextureRect.new()
    screen_blood_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    screen_blood_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    screen_blood_rect.stretch_mode = TextureRect.STRETCH_SCALE
    screen_blood_rect.texture = screen_blood_tex
    screen_blood_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    screen_blood_rect.modulate.a = 0.0
    root_ui.add_child(screen_blood_rect)

func _show_result_panel_if_finished() -> void:
    if active and sim.result != -2: result_panel.show()

## Pops a big announcer text in the middle of the screen.
func announce(text: String, color: Color = Color("f7c844"), hold: float = 0.45) -> void:
    if big_label == null: return
    big_label.text = text
    big_label.add_theme_color_override("font_color", color)
    big_label.scale = Vector2.ONE * 1.8
    big_label.modulate.a = 1.0
    var tw := create_tween().set_ignore_time_scale(true)
    tw.tween_property(big_label, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tw.tween_interval(hold)
    tw.tween_property(big_label, "modulate:a", 0.0, 0.25)

func flash_screen(color: Color, strength: float = 0.55) -> void:
    if screen_flash == null: return
    screen_flash.color = Color(color.r, color.g, color.b, strength)
    create_tween().set_ignore_time_scale(true).tween_property(screen_flash, "color:a", 0.0, 0.35)

## Short slow motion for dramatic moments (KOs, match end). Always restores real time.
func slow_motion(scale: float, real_seconds: float) -> void:
    if smoke or DisplayServer.get_name() == "headless": return
    Engine.time_scale = scale
    get_tree().create_timer(real_seconds, true, false, true).timeout.connect(func(): Engine.time_scale = 1.0)

## One-shot spark burst (CPU particles, auto-freed).
func spark_burst(pos: Vector3, color: Color, amount: int, speed: float, size: float = 0.07) -> void:
    var p := CPUParticles3D.new()
    p.one_shot = true
    p.amount = amount
    p.lifetime = 0.45
    p.explosiveness = 1.0
    p.direction = Vector3(0, 1, 0)
    p.spread = 180.0
    p.gravity = Vector3(0, -9.0, 0)
    p.initial_velocity_min = speed * 0.4
    p.initial_velocity_max = speed
    p.scale_amount_min = 0.5
    p.scale_amount_max = 1.3
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
    mat.vertex_color_use_as_albedo = true
    mat.albedo_texture = HIT_SPARK
    var quad := QuadMesh.new()
    quad.size = Vector2(size, size)
    quad.material = mat
    p.mesh = quad
    var grad := Gradient.new()
    grad.set_color(0, Color(1.6, 1.5, 1.3, 1.0))
    grad.set_color(1, Color(color.r, color.g, color.b, 0.0))
    p.color_ramp = grad
    add_child(p)
    p.position = pos
    p.emitting = true
    get_tree().create_timer(1.0).timeout.connect(p.queue_free)

## Expanding shockwave ring on the fighting plane.
func shock_ring(pos: Vector3, color: Color, radius: float) -> void:
    var ring := MeshInstance3D.new()
    var torus := TorusMesh.new()
    torus.inner_radius = 0.42
    torus.outer_radius = 0.5
    ring.mesh = torus
    ring.rotation_degrees = Vector3(90, 0, 0)
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.albedo_color = Color(color.r * 1.6, color.g * 1.6, color.b * 1.6, 0.9)
    ring.material_override = mat
    add_child(ring)
    ring.position = pos
    ring.scale = Vector3.ONE * 0.3
    var tw := create_tween().set_parallel(true)
    tw.tween_property(ring, "scale", Vector3.ONE * radius, 0.25).set_ease(Tween.EASE_OUT)
    tw.tween_property(mat, "albedo_color:a", 0.0, 0.28)
    tw.chain().tween_callback(ring.queue_free)

## A glowing blade arc that appears when a weapon swing becomes active.
func sword_trail(index: int) -> void:
    var f: Dictionary = sim.fighters[index]
    var pose: String = str(f.pending.get("pose", "Slash"))
    var wid: String = str(f.weapon.get("id", ""))
    var col: Color = Combat.WEAPONS[wid].color if Combat.WEAPONS.has(wid) else Color.WHITE
    var delay: float = float(f.pending.ability.get("windup", 0.1))
    await get_tree().create_timer(delay).timeout
    if index >= sim.fighters.size(): return
    f = sim.fighters[index]
    var arc := MeshInstance3D.new()
    var torus := TorusMesh.new()
    var reach: float = float(f.pending.get("ability", {}).get("range", 1.5)) if f.pending.has("ability") else 1.5
    torus.inner_radius = reach * 0.55
    torus.outer_radius = reach * 0.75
    torus.rings = 24
    arc.mesh = torus
    var m := StandardMaterial3D.new()
    m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
    m.albedo_color = Color(col.r * 1.8, col.g * 1.8, col.b * 1.8, 0.85)
    m.cull_mode = BaseMaterial3D.CULL_DISABLED
    arc.material_override = m
    add_child(arc)
    var fx: float = float(f.facing)
    arc.position = Vector3(f.x + fx * reach * 0.35, f.y + 1.15, 0.35)
    match pose:
        "Slash", "SlashBack", "SlashSpin":
            arc.rotation_degrees = Vector3(0, 0, 0)
            arc.scale = Vector3(1.0, 0.12, 1.0)
        "Thrust":
            arc.scale = Vector3(1.3, 0.1, 0.3)
        _:
            arc.rotation_degrees = Vector3(90, 0, 0)
            arc.scale = Vector3(1.0, 1.0, 0.12)
    var tw := create_tween().set_parallel(true)
    tw.tween_property(arc, "rotation:y", arc.rotation.y + fx * 1.2, 0.2)
    tw.tween_property(m, "albedo_color:a", 0.0, 0.22)
    tw.chain().tween_callback(arc.queue_free)

## Pillar bursting out of the ground (eruption signatures).
func erupt_pillar(pos: Vector3, color: Color, bone: bool) -> void:
    var spike := MeshInstance3D.new()
    var c := CylinderMesh.new()
    c.top_radius = 0.0
    c.bottom_radius = 0.28 if not bone else 0.16
    c.height = 1.8
    c.radial_segments = 6
    spike.mesh = c
    var m := StandardMaterial3D.new()
    m.albedo_color = color if bone else color.darkened(0.3)
    m.roughness = 0.5
    m.emission_enabled = not bone
    m.emission = color
    m.emission_energy_multiplier = 2.0
    spike.material_override = m
    add_child(spike)
    spike.position = pos + Vector3(0, -0.9, 0)
    spike.rotation_degrees.z = randf_range(-12, 12)
    var tw := create_tween()
    tw.tween_property(spike, "position:y", pos.y + 0.9, 0.08).set_ease(Tween.EASE_OUT)
    tw.tween_interval(0.35)
    tw.tween_property(spike, "position:y", pos.y - 1.0, 0.25)
    tw.tween_callback(spike.queue_free)
    spark_burst(pos + Vector3(0, 0.3, 0), color, 10, 4.0, 0.08)

## Visual signature per special mechanic.
func signature_effect(index: int, mech: String, color: Color) -> void:
    if index >= sim.fighters.size(): return
    var f: Dictionary = sim.fighters[index]
    var fx: float = float(f.facing)
    var center := Vector3(f.x, f.y + 1.1, 0.35)
    match mech:
        "beam":
            var beam_len: float = float(f.pending.get("ability", {}).get("range", 6.0)) if f.pending.has("ability") else 6.0
            var core := _beam(center + Vector3(fx * 0.5, 0, 0), center + Vector3(fx * (beam_len + 0.5), 0, 0), color, 0.45)
            _fade_free(core, 0.35)
            var halo := _beam(center + Vector3(fx * 0.5, 0, 0), center + Vector3(fx * (beam_len + 0.5), 0, 0), color.lightened(0.5), 0.18)
            _fade_free(halo, 0.3)
            camera_shake = 0.5
            sound("electric")
        "whirl":
            for k in range(3):
                shock_ring(center + Vector3(0, -0.4 + k * 0.4, 0), color, 3.0 + k)
            spark_burst(center, color, 40, 7.0, 0.1)
            sound("lava")
        "dash":
            for k in range(5):
                spark_burst(center - Vector3(fx * k * 0.4, 0, 0), color, 8, 3.0, 0.08)
            sound("electric")
        "barrage":
            spark_burst(center + Vector3(fx * 1.0, 0, 0), color, 40, 6.0, 0.08)
            sound("hit")
        "power":
            shock_ring(center + Vector3(fx * 1.2, 0, 0), color, 4.5)
            flash_screen(color, 0.25)
            camera_shake = 1.0
            sound("hit")
        "counter":
            shock_ring(center, color, 1.8)
        "rage":
            shock_ring(center, color, 5.0)
            spark_burst(center, color, 60, 8.0, 0.12)
            announce("WUT!", color, 0.4)
            sound("lava")
        "eruption", "meteor", "mine", "turret", "projectile", "clone":
            spark_burst(center + Vector3(fx * 0.6, 0, 0), color, 14, 4.0, 0.08)
        "teleport":
            pass

## Floating "5 HITS!" above the attacker.
func combo_popup(index: int, count: int) -> void:
    var f: Dictionary = sim.fighters[index]
    var l := Label3D.new()
    l.text = "%d HITS!" % count
    l.font_size = 64
    l.pixel_size = 0.006
    l.outline_size = 16
    l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    l.no_depth_test = true
    l.modulate = Color("ffd23f").lerp(Color("ff3b3b"), clampf((count - 3) / 6.0, 0.0, 1.0))
    l.outline_modulate = Color(0, 0, 0)
    add_child(l)
    l.position = Vector3(f.x, f.y + 2.9, 0.4)
    var tw := create_tween().set_parallel(true)
    tw.tween_property(l, "position:y", l.position.y + 0.8, 0.7)
    tw.tween_property(l, "modulate:a", 0.0, 0.7).set_delay(0.25)
    tw.chain().tween_callback(l.queue_free)

## Ghost trail when a fighter rolls, spot-dodges or air-dodges.
func dodge_effect(index: int) -> void:
    if index >= sim.fighters.size(): return
    var f: Dictionary = sim.fighters[index]
    var col: Color = PLAYER_COLORS[index % PLAYER_COLORS.size()]
    shock_ring(Vector3(f.x, f.y + 0.9, 0.3), col, 1.6)
    sound("jump")

# ── Finisher cinematic ──────────────────────────────────────────────────────────
var finisher_running := false

func _cam_to(pos: Vector3, look: Vector3, time: float) -> void:
    var from_pos: Vector3 = camera.position
    var from_look: Vector3 = camera_look
    var t := 0.0
    while t < time:
        await get_tree().process_frame
        t += get_process_delta_time()
        var k: float = smoothstep(0.0, 1.0, clampf(t / time, 0.0, 1.0))
        camera.position = from_pos.lerp(pos, k)
        camera_look = from_look.lerp(look, k)
        camera.look_at(camera_look)

func _wait(seconds: float) -> void:
    await get_tree().create_timer(seconds).timeout

## Emissive beam from a to b (lightning, fire column).
func _beam(a: Vector3, b: Vector3, color: Color, width: float) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(width, a.distance_to(b), width)
    m.mesh = box
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.albedo_color = Color(color.r * 2.2, color.g * 2.2, color.b * 2.2, 0.95)
    m.material_override = mat
    add_child(m)
    var dir: Vector3 = (b - a).normalized()
    var side: Vector3 = dir.cross(Vector3.BACK)
    if side.length() < 0.01: side = Vector3.RIGHT
    m.basis = Basis(side.normalized(), dir, side.normalized().cross(dir))
    m.position = (a + b) * 0.5
    return m

func _fade_free(node: GeometryInstance3D, time: float) -> void:
    var mat = node.material_override
    var tw := create_tween()
    if mat is StandardMaterial3D: tw.tween_property(mat, "albedo_color:a", 0.0, time)
    else: tw.tween_interval(time)
    tw.tween_callback(node.queue_free)

func clear_gore() -> void:
    for n in gore_nodes:
        if is_instance_valid(n): n.queue_free()
    gore_nodes.clear()
    if screen_blood_rect: screen_blood_rect.modulate.a = 0.0

func _blood_particles(pos: Vector3, dir: Vector3, amount: int, speed: float, one_shot: bool) -> CPUParticles3D:
    var p := CPUParticles3D.new()
    p.one_shot = one_shot
    p.amount = amount
    p.lifetime = 0.9
    p.explosiveness = 0.9 if one_shot else 0.0
    p.direction = dir.normalized() if dir.length() > 0.01 else Vector3.UP
    p.spread = 32.0
    p.gravity = Vector3(0, -14.0, 0)
    p.initial_velocity_min = speed * 0.5
    p.initial_velocity_max = speed
    p.scale_amount_min = 0.6
    p.scale_amount_max = 1.6
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
    mat.vertex_color_use_as_albedo = true
    mat.albedo_texture = blood_drop_tex
    var quad := QuadMesh.new()
    quad.size = Vector2(0.09, 0.09)
    quad.material = mat
    p.mesh = quad
    var grad := Gradient.new()
    grad.set_color(0, Color(0.75, 0.02, 0.03, 1.0))
    grad.set_color(1, Color(0.35, 0.0, 0.01, 0.0))
    p.color_ramp = grad
    add_child(p)
    p.position = pos
    p.emitting = true
    return p

## Short blood burst (hits, severed limbs).
func blood_spray(pos: Vector3, dir: Vector3, amount: int, speed: float) -> void:
    var p := _blood_particles(pos, dir, amount, speed, true)
    get_tree().create_timer(1.5).timeout.connect(p.queue_free)

## Continuous blood stream for a few seconds (neck, torn shoulders).
func blood_fountain(pos: Vector3, dir: Vector3, seconds: float) -> void:
    var p := _blood_particles(pos, dir, 70, 6.5, false)
    gore_nodes.append(p)
    get_tree().create_timer(seconds).timeout.connect(_stop_emitting.bind(p))

func _stop_emitting(p: CPUParticles3D) -> void:
    if is_instance_valid(p): p.emitting = false

## Blood pool decal spreading on the floor.
func blood_pool(x: float, y: float, size: float) -> void:
    if blood_pool_tex == null: return
    var m := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(1.0, 1.0)
    m.mesh = plane
    var mat := StandardMaterial3D.new()
    mat.albedo_texture = blood_pool_tex
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.roughness = 0.12
    mat.metallic_specular = 0.8
    m.material_override = mat
    m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(m)
    gore_nodes.append(m)
    m.position = Vector3(x, y + 0.012 + gore_nodes.size() * 0.0005, randf_range(-0.25, 0.25))
    m.rotation.y = randf() * TAU
    m.scale = Vector3.ONE * 0.1
    create_tween().tween_property(m, "scale", Vector3.ONE * size, 1.4).set_ease(Tween.EASE_OUT)

## A flying body chunk with a blood trail; lands and leaves a small pool.
func gib(pos: Vector3, vel: Vector3, color: Color, size: float, floor_y: float = 0.0) -> void:
    var m := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = size * 0.5
    mesh.height = size * randf_range(1.2, 2.2)
    m.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.35
    m.material_override = mat
    add_child(m)
    gore_nodes.append(m)
    m.position = pos
    var trail := _blood_particles(Vector3.ZERO, Vector3.UP, 16, 1.0, false)
    trail.reparent(m, false)
    trail.position = Vector3.ZERO
    _fly_gib(m, vel, floor_y, trail)

func _fly_gib(m: MeshInstance3D, vel: Vector3, floor_y: float, trail: CPUParticles3D) -> void:
    var spin := Vector3(randf_range(-9, 9), randf_range(-9, 9), randf_range(-9, 9))
    var t := 0.0
    while is_instance_valid(m) and t < 3.0:
        await get_tree().process_frame
        var dt: float = get_process_delta_time()
        t += dt
        vel.y -= 16.0 * dt
        m.position += vel * dt
        m.rotation += spin * dt
        if m.position.y <= floor_y + 0.08 and vel.y < 0.0:
            m.position.y = floor_y + 0.08
            if absf(vel.y) > 3.0:
                vel = Vector3(vel.x * 0.4, -vel.y * 0.25, 0.0)
                blood_pool(m.position.x, floor_y, randf_range(0.5, 0.9))
            else:
                break
    if is_instance_valid(trail): trail.emitting = false

func screen_blood(strength: float = 1.0) -> void:
    if screen_blood_rect == null or screen_blood_tex == null: return
    screen_blood_rect.modulate.a = strength
    var tw := create_tween()
    tw.tween_interval(1.4)
    tw.tween_property(screen_blood_rect, "modulate:a", 0.0, 1.6)

## Finishers. With blood on: burned to ash, frozen and shattered, exploded by
## lightning, limbs torn off by the void, decapitation. With blood off they stay clean.
func play_finisher(winner: int, loser: int, kind: String, fin_name: String) -> void:
    if finisher_running or loser >= views.size(): return
    finisher_running = true
    cinematic = true
    var lf: Dictionary = sim.fighters[loser]
    var lv = views[loser]
    var floor_y: float = lf.y
    var center := Vector3(lf.x, lf.y + 1.0, 0.0)
    var side: float = -1.0 if sim.fighters[winner].x > lf.x else 1.0
    var flesh := Color(0.45, 0.04, 0.05)
    lf.pose = "Dazed"
    screen_flash.color = Color(0, 0, 0, 0.0)
    create_tween().tween_property(screen_flash, "color:a", 0.35, 0.4)
    await _cam_to(center + Vector3(side * 1.4, 0.5, 4.2), center, 0.7)
    # The winner walks up and performs the finishing move.
    var wf: Dictionary = sim.fighters[winner]
    var stand_x: float = lf.x - side * 1.3
    wf.facing = int(side)
    wf.pose = "Move"
    var walk_t := 0.0
    var from_x: float = wf.x
    while walk_t < 0.45:
        await get_tree().process_frame
        walk_t += get_process_delta_time()
        wf.x = lerpf(from_x, stand_x, clampf(walk_t / 0.45, 0.0, 1.0))
    wf.anim_windup = 0.35
    wf.pose = {"inferno": "Beam", "frost": "Thrust", "storm": "Summon", "void": "Cast"}.get(kind, "HeavySlash" if not wf.weapon.is_empty() else "HeavyPunch")
    await _wait(0.4)
    announce(fin_name + "!", Color("ffb020"), 0.8)
    match kind:
        "inferno":
            sound("lava")
            lf.pose = "HitReact"
            for k in range(8):
                var col := _beam(Vector3(lf.x + randf_range(-0.3, 0.3), floor_y - 0.2, 0.2), Vector3(lf.x, floor_y + 3.2 + k * 0.3, 0.2), Color("ff5a1f").lerp(Color("ffd060"), k / 8.0), 0.4 - k * 0.04)
                _fade_free(col, 1.6)
                spark_burst(center, Color("ff7a2a"), 30, 7.0, 0.12)
                lv.char_body((k + 1) / 8.0)
                await _wait(0.16)
            lf.pose = "Defeat"
            camera_shake = 0.8
            await _wait(0.7)
            if gore_on:
                # The charred body crumbles to ash.
                lv.visible = false
                for k in range(10):
                    gib(center + Vector3(randf_range(-0.3, 0.3), randf_range(-0.6, 0.4), 0), Vector3(randf_range(-2, 2), randf_range(1, 4), 0), Color(0.06, 0.04, 0.03), randf_range(0.12, 0.25), floor_y)
                spark_burst(center, Color(0.2, 0.18, 0.16), 90, 3.5, 0.18)
        "frost":
            sound("electric")
            lf.freeze_timer = 10.0
            await _wait(0.9)
            flash_screen(Color("bff4ff"), 0.6)
            camera_shake = 1.2
            lf.freeze_timer = 0.0
            lv.visible = false
            spark_burst(center, Color("9ee7ff"), 90, 11.0, 0.18)
            shock_ring(center, Color("bff4ff"), 5.0)
            if gore_on:
                for k in range(12):
                    var ice: bool = k % 2 == 0
                    gib(center + Vector3(randf_range(-0.3, 0.3), randf_range(-0.5, 0.6), 0), Vector3(randf_range(-6, 6), randf_range(2, 8), 0),
                        Color(0.7, 0.85, 1.0) if ice else flesh, randf_range(0.14, 0.3), floor_y)
                blood_spray(center, Vector3(0, 1, 0), 80, 9.0)
                blood_pool(lf.x, floor_y, 2.2)
                screen_blood(0.8)
            sound("block")
        "storm":
            for k in range(3):
                var bolt := _beam(Vector3(lf.x + randf_range(-1.5, 1.5), 14.0, 0.3), Vector3(lf.x, floor_y + 0.2, 0.3), Color("9be7ff"), 0.22)
                _fade_free(bolt, 0.25)
                flash_screen(Color("dff7ff"), 0.55)
                camera_shake = 0.9
                spark_burst(center, Color("7dd3fc"), 40, 10.0, 0.1)
                lf.pose = "HitReact" if k % 2 == 0 else "Dazed"
                sound("electric")
                await _wait(0.3)
            lv.visible = false
            spark_burst(center, Color("e0f7ff"), 90, 12.0, 0.12)
            if gore_on:
                # Overloaded: the body bursts apart.
                for k in range(14):
                    gib(center + Vector3(randf_range(-0.2, 0.2), randf_range(-0.5, 0.6), 0), Vector3(randf_range(-8, 8), randf_range(3, 10), 0), flesh, randf_range(0.12, 0.3), floor_y)
                blood_spray(center, Vector3(0, 1, 0), 140, 11.0)
                blood_pool(lf.x, floor_y, 2.6)
                screen_blood(1.0)
                camera_shake = 1.4
        "void":
            sound("lava")
            var orb := MeshInstance3D.new()
            var sph := SphereMesh.new()
            sph.radius = 0.5
            sph.height = 1.0
            orb.mesh = sph
            var om := StandardMaterial3D.new()
            om.albedo_color = Color(0.02, 0.0, 0.05)
            om.emission_enabled = true
            om.emission = Color("9b30ff")
            om.emission_energy_multiplier = 0.6
            om.rim_enabled = true
            om.rim = 1.0
            orb.material_override = om
            add_child(orb)
            gore_nodes.append(orb)
            var orb_pos: Vector3 = center + Vector3(-side * 1.8, 1.2, -0.3)
            orb.position = orb_pos
            orb.scale = Vector3.ONE * 0.1
            create_tween().tween_property(orb, "scale", Vector3.ONE * 1.6, 0.5).set_ease(Tween.EASE_OUT)
            await _wait(0.5)
            if gore_on and lv.has_bone("left_arm"):
                # The void tears the limbs off one by one.
                for key in ["left_arm", "right_arm", "left_leg", "right_leg"]:
                    var at: Vector3 = lv.bone_world(key)
                    lv.gore_hide_bone(key)
                    blood_spray(at, (at - orb_pos).normalized(), 40, 6.0)
                    gib(at, (orb_pos - at).normalized() * 7.0 + Vector3(0, 3, 0), flesh, 0.22, floor_y)
                    camera_shake = 0.6
                    sound("hit")
                    lf.pose = "HitReact"
                    await _wait(0.32)
                blood_pool(lf.x, floor_y, 2.4)
                screen_blood(0.7)
            var tw2 := create_tween()
            tw2.tween_property(orb, "scale", Vector3.ONE * 3.4, 0.35).set_ease(Tween.EASE_OUT)
            await _wait(0.35)
            lv.visible = false
            var tw3 := create_tween()
            tw3.tween_property(orb, "scale", Vector3.ONE * 0.01, 0.3).set_ease(Tween.EASE_IN)
            await _wait(0.3)
            flash_screen(Color("9b30ff"), 0.5)
            shock_ring(center, Color("c084fc"), 6.0)
            camera_shake = 1.1
        _:
            sound("hit")
            if gore_on and lv.has_bone("head"):
                # Decapitation: the head flies, the neck bleeds out, the body sinks down.
                var head_pos: Vector3 = lv.bone_world("head")
                lv.gore_hide_bone("head")
                camera_shake = 1.2
                flash_screen(Color(0.6, 0.0, 0.0), 0.5)
                gib(head_pos, Vector3(side * 2.5, 9.0, 0.0), Color(0.55, 0.12, 0.1), 0.34, floor_y)
                blood_fountain(head_pos + Vector3(0, -0.05, 0), Vector3(side * 0.2, 1, 0), 2.2)
                blood_spray(head_pos, Vector3(side, 0.8, 0), 60, 8.0)
                screen_blood(0.9)
                slow_motion(0.35, 0.6)
                await _wait(0.9)
                lf.pose = "Defeat"
                blood_pool(lf.x, floor_y, 2.4)
                await _wait(0.8)
            else:
                shock_ring(center, Color("ffd27a"), 4.0)
                spark_burst(center, Color("ffd27a"), 50, 9.0, 0.12)
                camera_shake = 1.2
                lf.pose = "HitReact"
                _cam_to(center + Vector3(side * 1.0, 3.5, 8.0), center + Vector3(0, 6.0, 0), 0.9)
                var start_x: float = lf.x
                var t := 0.0
                while t < 1.0:
                    await get_tree().process_frame
                    t += get_process_delta_time()
                    lf.x = start_x + side * 3.0 * t
                    lf.y = 22.0 * t * t
                lv.visible = false
            sound("victory")
    await _wait(0.6)
    announce("VOLLSTRECKT!", Color("ff2d3a"), 1.4)
    sound("victory")
    if winner < sim.fighters.size(): sim.fighters[winner].pose = "Victory"
    await _cam_to(Vector3(sim.fighters[winner].x + 1.2, 1.7, 4.6), Vector3(sim.fighters[winner].x, 1.3, 0), 0.8)
    await _wait(1.4)
    create_tween().tween_property(screen_flash, "color:a", 0.0, 0.4)
    cinematic = false
    finisher_running = false
    if active and sim.result >= 0 and (story == null or not story.running):
        result_label.text = "SPIELER %d GEWINNT!\nFINISHER: %s" % [sim.result + 1, fin_name]
        result_panel.show()

## KO at the blast zone: light pillar pointing back into the stage, sparks, flash, slow-mo.
func ko_blast(index: int, x: float, y: float) -> void:
    var col: Color = PLAYER_COLORS[index % PLAYER_COLORS.size()]
    var px: float = clampf(x, Combat.BLAST_ZONE_LEFT + 1.0, Combat.BLAST_ZONE_RIGHT - 1.0)
    var py: float = clampf(y, Combat.BLAST_ZONE_BOTTOM + 1.0, Combat.BLAST_ZONE_TOP - 1.0)
    var dir := Vector3(-px, -py + 2.0, 0).normalized()
    var beam := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(0.6, 14.0, 0.2)
    beam.mesh = box
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.albedo_color = Color(col.r * 2.0, col.g * 2.0, col.b * 2.0, 0.85)
    beam.material_override = mat
    add_child(beam)
    # The box's long axis (local Y) points from the KO spot back towards the stage.
    beam.basis = Basis(dir.cross(Vector3.BACK).normalized(), dir, Vector3.BACK)
    beam.position = Vector3(px, py, 0) + dir * 7.0
    var tw := create_tween().set_parallel(true)
    tw.tween_property(beam, "scale", Vector3(2.5, 1.2, 1.0), 0.5)
    tw.tween_property(mat, "albedo_color:a", 0.0, 0.6)
    tw.chain().tween_callback(beam.queue_free)
    spark_burst(Vector3(px, py, 0.3), col, 60, 14.0, 0.14)
    shock_ring(Vector3(px, py, 0.3), col, 9.0)
    flash_screen(col, 0.45)
    camera_shake = 1.4
    slow_motion(0.35, 0.35)

func _cycle_ai_level() -> void:
    ai_level = ai_level % 9 + 1
    _refresh_option_buttons()
    sound("jump")

func _cycle_stocks() -> void:
    stock_count = stock_count % 5 + 1
    _refresh_option_buttons()
    sound("jump")

func _toggle_finishers() -> void:
    # BLUTIG -> OHNE BLUT -> AUS -> BLUTIG
    if finishers_on and gore_on: gore_on = false
    elif finishers_on: finishers_on = false
    else:
        finishers_on = true
        gore_on = true
    _refresh_option_buttons()
    sound("jump")

func _refresh_option_buttons() -> void:
    if selection == null: return
    var texts := {"BtnAiLevel": "🤖 KI-STUFE %d" % ai_level, "BtnStocks": "❤ STOCKS %d" % stock_count,
        "BtnFinisher": "☠ " + ("BLUTIG" if finishers_on and gore_on else ("OHNE BLUT" if finishers_on else "FINISHER AUS"))}
    for n in texts:
        var b = selection.find_child(n, true, false)
        if b is Button: b.text = texts[n]

func _toggle_player_count() -> void:
    player_count = 4 if player_count == 2 else 2
    var btn = selection.find_child("BtnPlayerCount", true, false)
    if btn is Button:
        if player_count == 4:
            btn.text = "👥 4 SPIELER (FFA)"
            btn.add_theme_color_override("font_color", Color("c084fc"))
        else:
            btn.text = "👥 2 SPIELER (1v1)"
            btn.add_theme_color_override("font_color", Color("38bdf8"))
    for pi in range(player_slot_boxes.size()):
        player_slot_boxes[pi].visible = (pi < player_count)
    refresh_previews()
    sound("jump")

func refresh_profile_text() -> void:
    for i in range(mini(prompts.size(), player_count)):
        var p: Dictionary = remix_profiles[i] if (i < remix_profiles.size() and not remix_profiles[i].is_empty()) else Prompt.interpret(prompts[i].text, i)
        var eq_str := ""
        if p.has("equipment") and p.equipment.size() > 0:
            var eq_names: Array = []
            for eq in p.equipment: eq_names.append(eq.name)
            eq_str = " · GEAR: [%s]" % ", ".join(eq_names)
        var fname: String = p.get("name", p.family.to_upper())
        if profile_text.size() > i and profile_text[i]:
            profile_text[i].text = "%s · %s%s    HP %d  Kraft %d  Rüstung %d  Tempo %d  Technik %d" % [fname, p.element.to_upper(), eq_str, p.stats.vitality, p.stats.power, p.stats.defense, p.stats.speed, p.stats.technique]

func refresh_previews() -> void:
    refresh_profile_text()
    var p_list: Array = []
    for pi in range(player_count):
        var p: Dictionary = remix_profiles[pi] if (pi < remix_profiles.size() and not remix_profiles[pi].is_empty()) else Prompt.interpret(prompts[pi].text, pi)
        p_list.append(p)
    sim.start(p_list, "manual")
    rebuild_fighters()
    update_hud()

## Creates fighter views for the current match. Views whose profile is unchanged are
## reused, so switching one fighter only rebuilds that one model.
func rebuild_fighters() -> void:
    var old_views: Array = views
    views = []
    for i in range(sim.fighters.size()):
        var profile: Dictionary = sim.fighters[i].profile
        var view = null
        if i < old_views.size() and is_instance_valid(old_views[i]) and old_views[i].profile == profile:
            view = old_views[i]
            old_views[i] = null
        else:
            view = FighterView.new()
            add_child(view)
            view.setup(profile)
        view.visible = true
        view.update_state(sim.fighters[i], 1.0)
        view.reset_physics_interpolation()
        views.append(view)
    for leftover in old_views:
        if leftover != null and is_instance_valid(leftover): leftover.queue_free()

func start_round(mode: String) -> void:
    get_viewport().gui_release_focus()
    save_prompts()
    var p_list: Array = []
    for pi in range(player_count):
        var p: Dictionary = remix_profiles[pi] if (pi < remix_profiles.size() and not remix_profiles[pi].is_empty()) else Prompt.interpret(prompts[pi].text, pi)
        p_list.append(p)
    begin_match(p_list, mode, stock_count)
    # Finishers in versus matches with exactly two fighters left at the end.
    sim.finishers_enabled = finishers_on and not smoke

## Starts a match with ready-made profiles (used by versus and the story mode).
func begin_match(p_list: Array, mode: String, lives: int = 3) -> void:
    first_hit_done = false
    cinematic = false
    finisher_running = false
    clear_gore()
    Engine.time_scale = 1.0
    last_countdown_step = -1
    player_count = p_list.size()
    sim.start(p_list, null, mode, lives)
    sim.ai_level = ai_level
    for v in views:
        if is_instance_valid(v): v.reset_gore()
    sim.finishers_enabled = false
    rebuild_fighters()
    for v in views: v.reset_gore()
    setup_items()
    clear_input_buffer()
    status_message_time = 0.0
    accumulator = 0
    active = true
    paused = false
    selection.hide()
    result_panel.hide()
    battle_hud_top.show()
    battle_hud_bottom.show()
    status.show()
    for pi in range(player_slot_boxes.size()):
        player_slot_boxes[pi].visible = (pi < player_count)

    var mode_title := "LOKALER VERSUS (1v1)" if player_count == 2 else "%d-SPIELER BRAWL" % player_count
    if mode == "pve": mode_title = "SOLO-KAMPF (SPIELER vs KI)"
    elif mode == "autonomous": mode_title = "AGENTENKAMPF (KI vs KI)"
    status.text = "%s  /  %s" % [ARENAS[current_arena].name, mode_title]
    sound("start")

func _on_remix_pressed(slot: int) -> void:
    if slot >= remix_prompts.size(): return
    var rtext: String = remix_prompts[slot].text.strip_edges()
    if rtext.is_empty():
        if remix_info.size() > slot:
            remix_info[slot].text = "⚠ Prompt eingeben!"
        return
    var profile: Dictionary = Remixer.remix_character(rtext, slot)
    var validation: Dictionary = Remixer.validate(profile)
    if validation.valid:
        remix_profiles[slot] = profile
        if prompts.size() > slot:
            prompts[slot].text = rtext
        if remix_info.size() > slot:
            remix_info[slot].text = "✓ %s · %s · %s · HP %d · SPD %.1f" % [profile.name, profile.element.to_upper(), profile.family.to_upper(), int(profile.health), profile.speed]
        refresh_previews()
        sound("jump")
    else:
        if remix_info.size() > slot:
            remix_info[slot].text = "✗ FEHLER: %s" % ", ".join(validation.errors)

func clear_remix(slot: int) -> void:
    remix_profiles[slot] = {}
    if remix_info.size() > slot:
        remix_info[slot].text = ""

func restart_round() -> void:
    if story != null and story.running:
        story.retry_fight()
        return
    if active or not result_panel.visible and not selection.visible:
        start_round(sim.mode)
    elif result_panel.visible:
        start_round(sim.mode)

func show_selection() -> void:
    active = false
    paused = false
    cinematic = false
    if player_count != 2 and player_count != 4: player_count = 2
    result_panel.hide()
    selection.show()
    battle_hud_top.hide()
    battle_hud_bottom.hide()
    status.hide()
    refresh_previews()
    update_mk_grid_visuals()

func on_mk_fighter_selected(player_slot: int, preset_idx: int) -> void:
    if preset_idx < 0 or preset_idx >= mk_presets.size(): return
    var preset: Dictionary = mk_presets[preset_idx]
    if prompts.size() > player_slot and prompts[player_slot]:
        prompts[player_slot].text = preset.prompt
    # Fusion cards carry their own profile; regular cards clear any earlier fusion override.
    if player_slot < remix_profiles.size():
        remix_profiles[player_slot] = preset.get("profile", {})
    refresh_profile_text()
    refresh_previews()
    update_mk_grid_visuals()
    sound("jump")

func _on_card_hovered(idx: int) -> void:
    if idx < 0 or idx >= mk_presets.size(): return
    var preset: Dictionary = mk_presets[idx]
    if preset.id == "fusionskammer":
        mk_p1_name_label.text = "FUSIONSKAMMER"
        mk_p1_sub_label.text = "⚡ KREATIV-STUDIO · MODULARE 3D-KÄMPFER FUSIONIEREN"
        mk_p1_stats_label.text = "KLICKE HIER, UM EIGENE KÄMPFER AUS PROMPTS & ASSETS ZU ERSCHAFFEN"
        return
    mk_p1_name_label.text = preset.name
    var p0 = Prompt.interpret(preset.prompt, 0)
    mk_p1_sub_label.text = "%s · %s" % [p0.element.to_upper(), preset.prompt.left(35)]
    mk_p1_stats_label.text = "HP %d · KRAFT %d · RÜSTUNG %d · TEMPO %d · TECHNIK %d" % [
        p0.stats.vitality, p0.stats.power, p0.stats.defense, p0.stats.speed, p0.stats.technique
    ]
    # Hover only previews the info text. Selection happens on click, so hovering no longer
    # changes P1's fighter or reloads 3D models (the main cause of menu stutter).

func _on_random_select_pressed() -> void:
    var valid_indices: Array = []
    for i in range(mk_presets.size()):
        if mk_presets[i].id != "fusionskammer":
            valid_indices.append(i)
    if valid_indices.is_empty(): return
    var pick: int = valid_indices[randi() % valid_indices.size()]
    on_mk_fighter_selected(0, pick)
    sound("jump")

func _cycle_combat_mode() -> void:
    if current_combat_mode == "pve":
        current_combat_mode = "manual"
    elif current_combat_mode == "manual":
        current_combat_mode = "autonomous"
    else:
        current_combat_mode = "pve"
    var btn = root_ui.find_child("BtnCombatMode", true, false)
    if btn is Button:
        if current_combat_mode == "pve":
            btn.text = "⚔ SPIELER vs KI"
            btn.add_theme_color_override("font_color", Color("4ae371"))
        elif current_combat_mode == "manual":
            btn.text = "⚔ SPIELER vs SPIELER"
            btn.add_theme_color_override("font_color", CYAN)
        else:
            btn.text = "🤖 KI vs KI"
            btn.add_theme_color_override("font_color", ORANGE)
    sound("jump")

## Big name / element / stats of the chosen fighters for P1 (left) and P2 (right).
func refresh_selected_labels() -> void:
    if mk_p1_name_label == null: return
    var sets := [[mk_p1_name_label, mk_p1_sub_label, mk_p1_stats_label], [mk_p2_name_label, mk_p2_sub_label, mk_p2_stats_label]]
    for slot in range(2):
        if slot >= prompts.size(): continue
        var p: Dictionary = remix_profiles[slot] if not remix_profiles[slot].is_empty() else Prompt.interpret(prompts[slot].text, slot)
        var shown: String = p.get("name", "")
        for preset in mk_presets:
            if preset.prompt == prompts[slot].text: shown = preset.name
        sets[slot][0].text = shown
        sets[slot][1].text = "%s · %s" % [str(p.element).to_upper(), p.special.name]
        sets[slot][2].text = "HP %d · KRAFT %d · RÜSTUNG %d · TEMPO %d · TECHNIK %d" % [p.stats.vitality, p.stats.power, p.stats.defense, p.stats.speed, p.stats.technique]

func update_mk_grid_visuals() -> void:
    refresh_selected_labels()
    for k in range(mini(mk_card_buttons.size(), mk_presets.size())):
        var item: Dictionary = mk_card_buttons[k]
        var btn: Button = item.button
        var b_p1: Label = item.badge_p1
        var b_p2: Label = item.badge_p2
        var is_p1: bool = (prompts.size() > 0 and prompts[0].text == mk_presets[k].prompt)
        var is_p2: bool = (prompts.size() > 1 and prompts[1].text == mk_presets[k].prompt)
        b_p1.visible = is_p1
        b_p2.visible = is_p2
        if mk_presets[k].id == "fusionskammer":
            btn.add_theme_stylebox_override("normal", panel_style(Color("1e0c2e"), Color("a855f7"), 2, 6))
            btn.add_theme_stylebox_override("hover", panel_style(Color("3b1858"), Color("d946ef"), 2, 6))
        elif is_p1 and is_p2:
            btn.add_theme_stylebox_override("normal", panel_style(Color("331a10"), Color("ff9900"), 2, 6))
        elif is_p1:
            btn.add_theme_stylebox_override("normal", panel_style(Color("381d06"), Color("ff9900"), 2, 6))
            btn.add_theme_stylebox_override("hover", panel_style(Color("4a2808"), Color("ffbb33"), 2, 6))
        elif is_p2:
            btn.add_theme_stylebox_override("normal", panel_style(Color("082030"), CYAN, 2, 6))
            btn.add_theme_stylebox_override("hover", panel_style(Color("0c3048"), CYAN, 2, 6))
        else:
            btn.add_theme_stylebox_override("normal", panel_style(Color("0d131c"), Color("1f2c3d"), 1, 6))
            btn.add_theme_stylebox_override("hover", panel_style(Color("1c2838"), Color("385070"), 1, 6))

func _setup_fusionskammer_modal() -> void:
    fusionskammer_modal = PanelContainer.new()
    fusionskammer_modal.position = Vector2(160, 45)
    fusionskammer_modal.custom_minimum_size = Vector2(960, 620)
    fusionskammer_modal.add_theme_stylebox_override("panel", panel_style(Color(0.02, 0.03, 0.07, 0.98), Color("8a2be2"), 2, 12))
    selection.add_child(fusionskammer_modal)
    fusionskammer_modal.hide()

    var m_vbox := VBoxContainer.new()
    m_vbox.add_theme_constant_override("separation", 10)
    fusionskammer_modal.add_child(m_vbox)

    # Header
    var h_row := HBoxContainer.new()
    m_vbox.add_child(h_row)
    var title := label("⚡ FUSIONSKAMMER — EIGENEN KÄMPFER ERSCHAFFEN", 20, Color("c084fc"))
    title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    h_row.add_child(title)
    var btn_close := button("✖", Color("ff4444"), close_fusionskammer)
    btn_close.custom_minimum_size = Vector2(36, 32)
    h_row.add_child(btn_close)

    var sub := label("Erstelle deinen Traumkämpfer aus über 40 3D-Archetypen, modularen Rüstungen, Waffen und Effekten.", 11, Color("9bb5cf"))
    m_vbox.add_child(sub)

    # Prompt Row
    var pr_box := VBoxContainer.new()
    pr_box.add_theme_constant_override("separation", 4)
    m_vbox.add_child(pr_box)
    pr_box.add_child(label("PROMPT-FUSION (BESCHREIBE DEINEN KÄMPFER):", 12, Color("f7c844")))

    var pr_row := HBoxContainer.new()
    pr_row.add_theme_constant_override("separation", 8)
    pr_box.add_child(pr_row)

    fusionskammer_prompt_edit = LineEdit.new()
    fusionskammer_prompt_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    fusionskammer_prompt_edit.custom_minimum_size.y = 34
    fusionskammer_prompt_edit.placeholder_text = "z.B. Cyber-Samurai mit Drachenflügeln und Flammenklinge..."
    fusionskammer_prompt_edit.text = "Cyber Drachen-Samurai mit Flammen-Katana und Schild"
    fusionskammer_prompt_edit.add_theme_font_size_override("font_size", 12)
    pr_row.add_child(fusionskammer_prompt_edit)

    var btn_rnd := button("🎲 ZUFALL", Color("38bdf8"), _on_fusion_random)
    btn_rnd.custom_minimum_size = Vector2(100, 34)
    btn_rnd.add_theme_font_size_override("font_size", 11)
    pr_row.add_child(btn_rnd)

    var btn_gen := button("⚡ FUSIONIEREN", Color("c084fc"), _on_fusion_apply)
    btn_gen.custom_minimum_size = Vector2(120, 34)
    btn_gen.add_theme_font_size_override("font_size", 11)
    pr_row.add_child(btn_gen)

    # Modular Pickers Grid
    var grid := GridContainer.new()
    grid.columns = 2
    grid.add_theme_constant_override("h_separation", 16)
    grid.add_theme_constant_override("v_separation", 8)
    m_vbox.add_child(grid)

    # 1. Base Body Archetype
    var b_box := VBoxContainer.new()
    b_box.add_child(label("BASIS-ARCHETYP (3D-KÖRPER):", 10, Color("9bb5cf")))
    fusionskammer_body_option = OptionButton.new()
    fusionskammer_body_option.custom_minimum_size = Vector2(440, 30)
    for b_key in Fusionskammer.BODY_MODULES:
        var b_data: Dictionary = Fusionskammer.BODY_MODULES[b_key]
        fusionskammer_body_option.add_item("%s (%s)" % [b_data.name, b_key.to_upper()])
    b_box.add_child(fusionskammer_body_option)
    grid.add_child(b_box)

    # 2. Main Weapon
    var w_box := VBoxContainer.new()
    w_box.add_child(label("HAUPTHAND-WAFFE:", 10, Color("9bb5cf")))
    fusionskammer_weapon_option = OptionButton.new()
    fusionskammer_weapon_option.custom_minimum_size = Vector2(440, 30)
    for w_key in ["flame_katana", "ice_rapier", "war_hammer", "plasma_blaster", "energy_scythe", "paladin_greatsword"]:
        if Fusionskammer.EQUIPMENT_MODULES.has(w_key):
            fusionskammer_weapon_option.add_item(Fusionskammer.EQUIPMENT_MODULES[w_key].name)
    w_box.add_child(fusionskammer_weapon_option)
    grid.add_child(w_box)

    # 3. Off-hand / Shield
    var o_box := VBoxContainer.new()
    o_box.add_child(label("NEBENHAND / SCHILD:", 10, Color("9bb5cf")))
    var opt_shield := OptionButton.new()
    opt_shield.custom_minimum_size = Vector2(440, 30)
    opt_shield.add_item("Kein Schild (Zweihand-Fokus)")
    opt_shield.add_item("Aegis-Bollwerkschild (+12 Rüstung)")
    opt_shield.add_item("Plasma-Buckler (+6 Technik, +6 Rüstung)")
    o_box.add_child(opt_shield)
    grid.add_child(o_box)

    # 4. Element & Aura
    var e_box := VBoxContainer.new()
    e_box.add_child(label("ELEMENTAR-AURA & EFFEKTE:", 10, Color("9bb5cf")))
    fusionskammer_elem_option = OptionButton.new()
    fusionskammer_elem_option.custom_minimum_size = Vector2(440, 30)
    for e_key in Fusionskammer.ELEMENT_VARIANTS:
        var e_data: Dictionary = Fusionskammer.ELEMENT_VARIANTS[e_key]
        fusionskammer_elem_option.add_item("%s (%s)" % [e_data.name, e_key.to_upper()])
    e_box.add_child(fusionskammer_elem_option)
    grid.add_child(e_box)

    # Status & Stat Balance
    fusionskammer_stats_label = label("HP 118 · KRAFT 26 · RÜSTUNG 18 · TEMPO 22 · TECHNIK 16", 13, Color("38bdf8"))
    fusionskammer_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    m_vbox.add_child(fusionskammer_stats_label)

    fusionskammer_status_label = label("Bereit zur Fusion. Klicke auf 'IN ROSTER SPEICHERN' um ihn spielbar zu machen.", 11, Color("4ade80"))
    fusionskammer_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    m_vbox.add_child(fusionskammer_status_label)

    # Action Row
    var act_row := HBoxContainer.new()
    act_row.alignment = BoxContainer.ALIGNMENT_CENTER
    act_row.add_theme_constant_override("separation", 16)
    m_vbox.add_child(act_row)

    var btn_save := button("💾 IN KÄMPFER-ROSTER SPEICHERN & WÄHLEN", Color("22c55e"), _on_fusion_save)
    btn_save.custom_minimum_size = Vector2(360, 42)
    btn_save.add_theme_font_size_override("font_size", 14)
    act_row.add_child(btn_save)

    var btn_cancel := button("ABBRECHEN", Color("ef4444"), close_fusionskammer)
    btn_cancel.custom_minimum_size = Vector2(160, 42)
    btn_cancel.add_theme_font_size_override("font_size", 13)
    act_row.add_child(btn_cancel)

func open_fusionskammer() -> void:
    fusionskammer_modal.show()
    sound("jump")

func close_fusionskammer() -> void:
    fusionskammer_modal.hide()

func _on_fusion_random() -> void:
    var prompts_list := [
        "Cyber Drachen-Samurai mit Flammen-Katana und Schild",
        "Erzmagierin Medea mit Seelen-Sense und Astralschwingen",
        "Magma Warrok Koloss mit Titanen-Kriegshammer und Stachelschultern",
        "Shinobi Schattenmeister mit Frost-Rapier und Cyber-Visier",
        "Heiliger Paladin mit Aether-Großschwert und Lichtflügeln",
        "Gothic Vampirfürst mit Plasmastrahl und Karmesinaura",
        "Mutierter Säure-Titan mit Schockwelle und Obsidian-Panzer"
    ]
    fusionskammer_prompt_edit.text = prompts_list[randi() % prompts_list.size()]
    _on_fusion_apply()

func _on_fusion_apply() -> void:
    var text: String = fusionskammer_prompt_edit.text.strip_edges()
    if text.is_empty(): text = "Krieger"
    var p_fused = Fusionskammer.remix_character(text, 0)
    fusionskammer_stats_label.text = "✓ %s · HP %d · KRAFT %d · RÜSTUNG %d · TEMPO %d · TECHNIK %d" % [
        p_fused.name, p_fused.stats.vitality, p_fused.stats.power, p_fused.stats.defense, p_fused.stats.speed, p_fused.stats.technique
    ]
    fusionskammer_status_label.text = "Fusion vorbereitet! Klicke 'IN ROSTER SPEICHERN' um ihn zu aktivieren."
    remix_profiles[0] = p_fused
    prompts[0].text = text
    refresh_profile_text()
    refresh_previews()
    sound("jump")

func _on_fusion_save() -> void:
    var text: String = fusionskammer_prompt_edit.text.strip_edges()
    if text.is_empty(): text = "Fusionierter Krieger"
    var p_fused = Fusionskammer.remix_character(text, 0)

    # Insert before the fusionskammer card
    var insert_pos := maxi(0, mk_presets.size() - 1)
    mk_presets.insert(insert_pos, {
        "id": p_fused.family,
        "name": p_fused.name.left(12),
        "prompt": text,
        "profile": p_fused
    })

    remix_profiles[0] = p_fused
    prompts[0].text = text
    close_fusionskammer()
    on_mk_fighter_selected(0, insert_pos)
    sound("start")

func _unhandled_key_input(event: InputEvent) -> void:
    if not event.is_pressed() or event.is_echo(): return
    if event is InputEventKey:
        if event.keycode == KEY_ESCAPE:
            if fusionskammer_modal != null and fusionskammer_modal.visible:
                close_fusionskammer()
                return
            if active: paused = not paused
            return
        if selection != null and selection.visible:
            if event.keycode == KEY_J:
                _on_random_select_pressed()
                return
            if event.keycode == KEY_C:
                open_fusionskammer()
                return
            if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
                if fusionskammer_modal == null or not fusionskammer_modal.visible:
                    start_round(current_combat_mode)
                    return
        if event.keycode == KEY_F3:
            fps_label.visible = not fps_label.visible
            return
        if event.keycode == KEY_R and not selection.visible:
            restart_round()
            return
    buffer_press(event)

## Gamepad buttons reach the same input buffer as keys.
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventJoypadButton and event.pressed:
        if event.button_index == JOY_BUTTON_START:
            if active: paused = not paused
            elif selection != null and selection.visible: start_round(current_combat_mode)
            return
        buffer_press(event)

func buffer_press(event: InputEvent) -> void:
    if not active or paused or (sim.mode != "manual" and sim.mode != "pve"): return
    for i in range(human_count()):
        for action_type in BUFFERED_ACTIONS:
            if event.is_action_pressed("p%d_%s" % [i+1, action_type]): input_buffer[i][action_type] = INPUT_BUFFER_FRAMES

static func new_buffer() -> Dictionary:
    var b := {}
    for action_type in BUFFERED_ACTIONS: b[action_type] = 0
    return b

func clear_input_buffer() -> void:
    input_buffer = [new_buffer(), new_buffer(), new_buffer(), new_buffer()]

## Samples both keyboard players for one simulation tick. Buffered presses stay
## true for up to INPUT_BUFFER_FRAMES ticks, or until consume_input_buffer() sees them executed.
func manual_commands() -> Array:
    var commands: Array = []
    for i in range(maxi(2, human_count())):
        var pre := "p%d_" % (i + 1)
        var buf: Dictionary = input_buffer[i]
        if Input.is_action_just_pressed(pre + "jump"): buf.jump = INPUT_BUFFER_FRAMES
        if Input.is_action_just_pressed(pre + "grab"): buf.grab = INPUT_BUFFER_FRAMES
        if Input.is_action_just_pressed(pre + "standard"): buf.standard = maxi(buf.standard, INPUT_BUFFER_FRAMES)
        if Input.is_action_just_pressed(pre + "special"): buf.special = maxi(buf.special, INPUT_BUFFER_FRAMES)
        commands.append({
            "move": Input.get_axis(pre + "left", pre + "right"),
            "up": Input.is_action_pressed(pre + "up"),
            "down": Input.is_action_pressed(pre + "down"),
            "standard": buf.standard > 0,
            "special": buf.special > 0,
            "jump": buf.jump > 0,
            "block": Input.is_action_pressed(pre + "block"),
            "grab": buf.grab > 0,
            "standard_held": Input.is_action_pressed(pre + "standard"),
            "jump_held": Input.is_action_pressed(pre + "jump"),
        })
        for action_type in BUFFERED_ACTIONS:
            buf[action_type] = maxi(0, buf[action_type] - 1)
    return commands

## Clears buffered presses that the last simulation tick actually executed,
## so one press never triggers the same action twice.
func consume_input_buffer(events: Array) -> void:
    for event in events:
        var actor: int = event.get("actor", -1)
        if actor < 0 or actor >= input_buffer.size(): continue
        for action_type in BUFFER_CONSUMERS.get(event.type, []):
            input_buffer[actor][action_type] = 0
        # Up attacks are pressed together with jump (W / ↑): that jump must not fire afterwards.
        if event.type == "attack" and str(event.get("key", "")).begins_with("u"):
            input_buffer[actor].jump = 0

func show_status(text: String, duration: float = STATUS_MESSAGE_SECONDS) -> void:
    status_message = text
    status_message_time = duration

func _physics_process(delta: float) -> void:
    if active and not paused and sim.result == -2:
        var commands: Array = []
        if sim.mode == "autonomous":
            commands = sim.agent_commands()
        else:
            # Human players first (keyboard / gamepads), the rest are computer players.
            var humans: int = human_count()
            var m_cmds := manual_commands()
            var ai_cmds := sim.agent_commands()
            for k in range(sim.fighters.size()):
                commands.append(m_cmds[k] if k < humans else ai_cmds[k])
        sim.tick(commands, Combat.STEP)
        consume_input_buffer(sim.events)
        for event in sim.events:
            if event.type == "hit":
                if smoke: smoke_report.hits += 1
                if not first_hit_done:
                    first_hit_done = true
                    announce("ERSTES BLUT!" if gore_on else "ERSTER TREFFER!", Color("ff4d4d"), 0.5)
                if event.actor < sim.fighters.size() and int(sim.fighters[event.actor].combo) >= 3:
                    combo_popup(event.actor, int(sim.fighters[event.actor].combo))
                if float(event.get("launch_impulse", 0.0)) > 12.0:
                    # Heavy hit: impact frame and a hint of slow motion.
                    flash_screen(Color.WHITE, 0.25)
                    slow_motion(0.25, 0.09)
                if gore_on and float(event.get("damage", 0.0)) > 7.0 and event.target < sim.fighters.size():
                    var tf: Dictionary = sim.fighters[event.target]
                    var away: float = signf(tf.x - sim.fighters[event.actor].x) if event.actor < sim.fighters.size() else 1.0
                    blood_spray(Vector3(tf.x, tf.y + 1.2, 0.3), Vector3(away, 0.6, 0.0), int(6 + float(event.damage)), 5.0)
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
            elif event.type == "air_dash":
                sound("electric")
                dash_effect(event.actor, event.dir)
            elif event.type == "attack" and event.actor < sim.fighters.size() and not sim.fighters[event.actor].weapon.is_empty() \
                    and sim.fighters[event.actor].pending.has("ability") and not sim.fighters[event.actor].pending.ability.get("no_hit", false):
                sword_trail(event.actor)
                if event.special: sound("electric")
            elif event.type == "attack" and event.special:
                sound("lava" if sim.fighters[event.actor].profile.family == "golem" else "electric")
            elif event.type == "grab_success":
                views[event.target].shield_flash()
                sound("block")
                show_status("%s HAT %s GEGRIFFEN!" % [sim.fighters[event.actor].profile.name, sim.fighters[event.target].profile.name])
            elif event.type == "throw":
                views[event.target].flash()
                hit_effect(event.target, true, false)
                sound("hit")
            elif event.type == "grab_breakout":
                sound("block")
                show_status("BEFREIUNG!")
            elif event.type == "powerup_activated":
                views[event.actor].flash()
                super_effect(event.actor)
                sound("electric")
                show_status("POWER-UP! %s AKTIVIERT %s!" % [sim.fighters[event.actor].profile.name, event.name])
            elif event.type == "freeze_hit":
                views[event.target].flash()
                hit_effect(event.target, true, true)
                sound("electric")
                show_status("SCHOCKGEFROREN! %s IST EINGEFROREN!" % [sim.fighters[event.target].profile.name])
            elif event.type == "item_pickup":
                sound("jump")
                show_status("%s HEBT %s AUF!" % [sim.fighters[event.actor].profile.name, event.item_name])
            elif event.type == "item_throw":
                sound("jump")
            elif event.type == "item_hit":
                views[event.target].flash()
                hit_effect(event.target, true, false)
                sound("hit")
                show_status("%s WURDE GETROFFEN VON %s!" % [sim.fighters[event.target].profile.name, event.item_name])
            elif event.type == "item_explode":
                camera_shake = 1.35
                for fi in range(views.size()):
                    var f_data: Dictionary = sim.fighters[fi]
                    var f_center := Vector2(f_data.x, f_data.y + 0.75)
                    var dist := Vector2(event.x, event.y).distance_to(f_center)
                    if dist <= float(event.radius) + 0.5:
                        views[fi].flash()
                        hit_effect(fi, true, true)
                sound("lava")
                sound("hit")
                show_status("EXPLOSION! %s DETONIERT MIT GEWALTIGEM FLÄCHENSCHADEN!" % [event.item_name])
            elif event.type == "ring_out":
                ko_blast(event.actor, float(event.get("x", sim.fighters[event.actor].x)), float(event.get("y", 0.0)))
                if int(event.lives) == 1:
                    announce("P%d · LETZTER STOCK!" % (event.actor + 1), Color("ffb020"), 0.7)
                sound("victory")
                var act_name: String = sim.fighters[event.actor].profile.name
                show_status("RING-OUT! %s VERLIERT 1 STOCK (%d ÜBRIG)!" % [act_name, event.lives])
            elif event.type == "hp_ko":
                camera_shake = 0.70
                hit_effect(event.actor, true, false)
                sound("hit")
                var act_name: String = sim.fighters[event.actor].profile.name
                show_status("K.O.! %s VERLIERT 1 LEBEN (%d ÜBRIG)!" % [act_name, event.lives])
            elif event.type == "respawn":
                sound("jump")
                # Respawn is a teleport: don't interpolate from the blast zone to the spawn point.
                if event.actor < views.size():
                    views[event.actor].update_state(sim.fighters[event.actor], delta)
                    views[event.actor].reset_physics_interpolation()
            elif event.type == "finish_him":
                announce("MACH IHN FERTIG!", Color("ff2d3a"), 1.4)
                flash_screen(Color(0.5, 0.0, 0.0), 0.35)
                sound("victory")
                var who: String = "P%d" % (event.actor + 1)
                show_status("%s FINISHER %s:  %s" % [who, event.name, Combat.code_text(event.code)], Combat.FINISH_TIME)
            elif event.type == "finisher":
                play_finisher(event.actor, event.target, str(event.kind), str(event.name))
            elif event.type == "finish" and event.get("finisher", false):
                pass # the finisher cinematic shows the result
            elif event.type == "weapon_pickup":
                sound("electric")
                shock_ring(Vector3(sim.fighters[event.actor].x, sim.fighters[event.actor].y + 1.0, 0.3), Combat.WEAPONS[event.weapon].color, 2.0)
                show_status("%s SCHNAPPT SICH %s!" % [sim.fighters[event.actor].profile.name, event.item_name])
            elif event.type == "weapon_break":
                sound("block")
                spark_burst(Vector3(sim.fighters[event.actor].x, sim.fighters[event.actor].y + 1.2, 0.4), Color("e5e7eb"), 30, 7.0, 0.1)
                show_status("%s ZERBRICHT!" % event.item_name)
            elif event.type == "projectile":
                sound("electric")
            elif event.type == "signature":
                signature_effect(event.actor, str(event.mech), event.color)
            elif event.type == "blast":
                spark_burst(Vector3(event.x, event.y, 0.4), event.color, 60, 10.0, 0.14)
                shock_ring(Vector3(event.x, event.y, 0.4), event.color, float(event.radius) * 2.2)
                flash_screen(event.color, 0.3)
                camera_shake = 0.9
                sound("lava")
            elif event.type == "teleport":
                spark_burst(Vector3(event.from_x, event.from_y + 1.0, 0.3), Color("c4b5fd"), 30, 6.0, 0.1)
                shock_ring(Vector3(sim.fighters[event.actor].x, sim.fighters[event.actor].y + 1.0, 0.3), Color("c4b5fd"), 2.0)
                sound("electric")
            elif event.type == "swap":
                for who in [event.actor, event.target]:
                    spark_burst(Vector3(sim.fighters[who].x, sim.fighters[who].y + 1.0, 0.3), Color("5eead4"), 25, 6.0, 0.1)
                show_status("PLATZTAUSCH!")
            elif event.type == "counter":
                announce("KONTER!", Color("7dd3fc"), 0.45)
                shock_ring(Vector3(sim.fighters[event.actor].x, sim.fighters[event.actor].y + 1.1, 0.3), Color("7dd3fc"), 2.6)
                slow_motion(0.3, 0.15)
            elif event.type == "item_spawned" and event.has("weapon"):
                show_status("⚔ %s ERSCHEINT IN DER ARENA!" % event.item_name)
            elif event.type == "dodge":
                dodge_effect(event.actor)
            elif event.type == "shield_break":
                announce("SCHILD ZERBROCHEN!", Color("7dd3fc"), 0.5)
                spark_burst(Vector3(sim.fighters[event.actor].x, sim.fighters[event.actor].y + 1.1, 0.4), Color("7dd3fc"), 40, 8.0, 0.1)
                sound("block")
            elif event.type == "ledge_grab":
                sound("block")
            elif event.type == "finish" and not smoke:
                announce("GAME!", Color("ffffff"), 0.9)
                flash_screen(Color.WHITE, 0.4)
                slow_motion(0.3, 0.9)
                sound("victory")
                if story != null and story.running:
                    story.on_fight_finished(sim.result)
                else:
                    result_label.text = "UNENTSCHIEDEN" if sim.result == -1 else "SPIELER %d GEWINNT!" % (sim.result + 1)
                    get_tree().create_timer(1.1, true, false, true).timeout.connect(_show_result_panel_if_finished)
            elif event.type == "finish" and story != null and story.running:
                sound("victory")
                story.on_fight_finished(sim.result)
            elif event.type == "finish":
                result_label.text = "UNENTSCHIEDEN" if sim.result == -1 else "SPIELER %d GEWINNT!" % (sim.result + 1)
                result_panel.show()
                sound("victory")
                if smoke: finish_smoke_round()

        ensure_item_nodes()
        update_projectiles()
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
            update_item_node(it_i, it_data, it_node, delta)
    if not active and selection != null and selection.visible:
        for vi in range(views.size()):
            if is_instance_valid(views[vi]):
                views[vi].visible = (vi < player_count)
                if player_count == 2:
                    var x_off = -1.6 if vi == 0 else 1.6
                    views[vi].position = Vector3(x_off, 0.0, 0.3)
                    views[vi].rotation_degrees = Vector3(0, 25 * (-1 if vi == 1 else 1), 0)
                    views[vi].update_state({"x": x_off, "y": 0.0, "facing": (1.0 if vi == 0 else -1.0), "pose": "Idle", "blocking": false}, delta)
                elif player_count == 4:
                    var x_positions = [-2.4, -0.8, 0.8, 2.4]
                    var x_off = x_positions[vi]
                    views[vi].position = Vector3(x_off, 0.0, 0.3)
                    views[vi].rotation_degrees = Vector3(0, (20 if vi < 2 else -20), 0)
                    views[vi].update_state({"x": x_off, "y": 0.0, "facing": (1.0 if vi < 2 else -1.0), "pose": "Idle", "blocking": false}, delta)
        return

    for i in range(views.size()): views[i].update_state(sim.fighters[i], delta)
    update_hud()
    if smoke: run_smoke_step()

func _process(delta: float) -> void:
    if fps_label and fps_label.visible:
        fps_label.text = "%d FPS" % Engine.get_frames_per_second()
    if smoke and active: fps_samples.append(Engine.get_frames_per_second())
    if not paused: status_message_time = maxf(0.0, status_message_time - delta)
    if active and not paused:
        var step: int = int(ceil(sim.countdown / 0.8)) if sim.countdown > 0.0 else 0
        if step != last_countdown_step:
            if step > 0:
                announce(str(step), Color("f7c844"), 0.35)
                sound("block")
            elif last_countdown_step > 0:
                announce("GO!", Color("4ade80"), 0.4)
                sound("start")
            last_countdown_step = step
    if cinematic:
        update_player_markers()
        return # the story mode drives the camera during cutscenes
    if not active and selection != null and selection.visible:
        var target_pos := Vector3(0.0, 1.40, 3.4) if player_count == 2 else Vector3(0.0, 1.45, 4.5)
        camera.position = camera.position.lerp(target_pos, minf(1.0, delta * 6.0))
        camera.look_at(Vector3(0.0, 1.15, 0.0))
        camera_look = Vector3(0.0, 1.15, 0.0)
        update_player_markers()
        return
    if sim.fighters.is_empty(): return

    # Dynamic bounding-box framing of all fighters still in the match. Uses the
    # interpolated render positions so the camera is as smooth as the fighters.
    # Frame the whole body (feet to head, plus the marker arrow) of every fighter still in the match.
    var min_x := INF
    var max_x := -INF
    var min_y := INF
    var max_y := -INF
    for fi in range(mini(views.size(), sim.fighters.size())):
        if sim.fighters[fi].state == "Defeated" or not is_instance_valid(views[fi]): continue
        var p: Vector3 = views[fi].get_global_transform_interpolated().origin
        var body_h: float = FIGHTER_FRAME_HEIGHT * (2.0 if sim.fighters[fi].get("titan_timer", 0.0) > 0.0 else 1.0)
        min_x = minf(min_x, p.x - 0.6)
        max_x = maxf(max_x, p.x + 0.6)
        min_y = minf(min_y, p.y)
        max_y = maxf(max_y, p.y + body_h)
    if min_x == INF: return

    var mid_x: float = (min_x + max_x) * 0.5
    var mid_y: float = (min_y + max_y) * 0.5
    var half_w: float = (max_x - min_x) * 0.5 + CAMERA_MARGIN_X
    var half_h: float = ((max_y - min_y) * 0.5 + CAMERA_MARGIN_Y) / HUD_FREE_FRACTION
    var tan_half_fov: float = tan(deg_to_rad(camera.fov) * 0.5)
    var vp_size: Vector2 = get_viewport().get_visible_rect().size
    var aspect: float = vp_size.x / maxf(1.0, vp_size.y)
    # Distance at which the box fits both vertically and horizontally (fighters sit on z = 0).
    var needed_dist: float = maxf(half_h / tan_half_fov, half_w / (tan_half_fov * aspect))
    var target_dist: float = clampf(needed_dist, CAMERA_MIN_DIST, CAMERA_MAX_DIST)
    var look_target := Vector3(mid_x, mid_y, 0.0)
    var target_pos := look_target + Vector3(0.0, CAMERA_HEIGHT_OFFSET, target_dist)

    if camera_shake > 0.0:
        camera_shake = maxf(0.0, camera_shake - delta * 3.5)
        target_pos += Vector3(randf_range(-camera_shake, camera_shake) * 0.35, randf_range(-camera_shake, camera_shake) * 0.35, 0)
    # Zoom out and pan fast (nobody leaves the picture), zoom back in gently.
    var zooming_out: bool = target_pos.z > camera.position.z
    var follow: float = minf(1.0, delta * (12.0 if zooming_out else 4.5))
    camera.position = camera.position.lerp(target_pos, follow)
    camera_look = camera_look.lerp(look_target, follow)
    camera.look_at(camera_look)
    update_player_markers()

## Sets up fighters on the stage for a story cutscene: no HUD, no items, story camera.
func prepare_cutscene_stage(p_list: Array, arena_id: String) -> void:
    active = false
    paused = false
    cinematic = true
    selection.hide()
    result_panel.hide()
    battle_hud_top.hide()
    battle_hud_bottom.hide()
    status.hide()
    if arena_id != current_arena: apply_arena(arena_id)
    player_count = p_list.size()
    sim.start(p_list, "manual")
    rebuild_fighters()
    for node in item_nodes: node.visible = false

## Portrait texture for a fighter family (story dialogue, HUD).
func portrait_for_family(family: String) -> Texture2D:
    if not portrait_cache.has(family):
        portrait_cache[family] = get_portrait_for_fighter({"profile": {"family": family, "prompt": family}})
    return portrait_cache[family]

func setup_player_markers() -> void:
    for m in player_markers: m.queue_free()
    player_markers.clear()
    for pi in range(4):
        var marker := Label3D.new()
        marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        marker.no_depth_test = true          # visible even behind scenery
        marker.render_priority = 10
        marker.font_size = 56
        marker.outline_size = 22
        marker.pixel_size = 0.004
        # Darkened: the scene's exposure and glow would otherwise wash the color out to white.
        marker.modulate = PLAYER_COLORS[pi].darkened(0.35)
        marker.outline_modulate = Color(0, 0, 0, 1)
        marker.line_spacing = -18
        marker.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
        # Top-level node: views are rebuilt on fighter changes, the markers stay.
        marker.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
        marker.visible = false
        add_child(marker)
        player_markers.append(marker)

## Human players are "P1".."P4", computer-controlled fighters carry a "KI" tag.
func marker_text(index: int) -> String:
    var is_ai: bool = index >= human_count()
    return "P%d%s\n▼" % [index + 1, " KI" if is_ai else ""]

## Moves each marker above its fighter's head with constant on-screen size; bobs gently.
func update_player_markers() -> void:
    var cam_dist: float = camera.position.z if camera else 8.0
    var bob: float = sin(Time.get_ticks_msec() * 0.006) * 0.06
    for pi in range(player_markers.size()):
        var marker: Label3D = player_markers[pi]
        var show: bool = active and pi < sim.fighters.size() and pi < views.size() \
            and is_instance_valid(views[pi]) and sim.fighters[pi].state != "Defeated"
        marker.visible = show
        if not show: continue
        var f: Dictionary = sim.fighters[pi]
        var titan: float = 2.0 if f.get("titan_timer", 0.0) > 0.0 else 1.0
        var p: Vector3 = views[pi].get_global_transform_interpolated().origin
        var s: float = clampf(cam_dist / 8.0, 0.8, 3.2)
        marker.position = Vector3(p.x, p.y + MARKER_HEIGHT * titan + bob * s, 0.35)
        marker.scale = Vector3.ONE * s
        marker.text = marker_text(pi)
        # Blink while respawn-invulnerable so players find themselves instantly.
        marker.modulate.a = 0.45 if (f.get("invulnerable", 0.0) > 0.0 and int(Time.get_ticks_msec() / 120) % 2 == 0) else 1.0

func get_portrait_for_fighter(f: Dictionary) -> Texture2D:
    var family: String = f.profile.get("family", "")
    # Portraits rendered from the fighter's actual 3D model win over older thumbnails.
    var rendered: String = "res://assets/textures/characters/portraits/portrait_%s.png" % family
    if ResourceLoader.exists(rendered):
        return load(rendered)
    var thumb_path: String = "res://assets/textures/characters/thumbs/thumb_%s.png" % family
    if ResourceLoader.exists(thumb_path):
        return load(thumb_path)
    if PORTRAITS.has(family) and PORTRAITS[family] != null:
        return PORTRAITS[family]
    var ptext: String = f.profile.prompt.to_lower()
    for cand in [
        "ninja", "golem", "valkyrie", "dragon", "goku", "vegeta", "frieza", "subzero", "pain",
        "luffy", "zoro", "naruto", "sasuke", "saitama", "tanjiro", "sonic", "akaza", "blue_eyes",
        "charizard", "anubis", "specter", "phoenix", "golden_golem", "steel_knight", "vanguard_soldier",
        "sorceress_medea", "skeleton_reaper", "mutant_titan", "swat_specops", "samurai_dreyar",
        "pirate_captain", "vampire_lord", "wizard_sorcerer", "warrok_brute", "martial_yaku", "monk_ganfaul"
    ]:
        if cand in ptext:
            var c_thumb := "res://assets/textures/characters/thumbs/thumb_%s.png" % cand
            if ResourceLoader.exists(c_thumb):
                return load(c_thumb)
    return load("res://assets/textures/characters/thumbs/thumb_ninja.png")

func update_hud() -> void:
    if not timer or sim.fighters.is_empty(): return
    timer.text = "%02d" % int(ceil(sim.time_left))
    var active_count: int = mini(health_bars.size(), sim.fighters.size())
    for i in range(active_count):
        var f: Dictionary = sim.fighters[i]
        names[i].text = "P%d  ·  %s" % [i+1, f.profile.name]
        var p_dmg: float = f.get("damage_percent", 0.0)

        # Damage percent coloring:
        # 0% - 49%: Clean White (#ffffff)
        # 50% - 99%: High-Voltage Yellow (#fde047)
        # 100% - 149%: High-Impact Orange (#fb923c)
        # 150%+: Danger Red (#ef4444)
        var dmg_col := Color("ffffff")
        if p_dmg >= 150.0: dmg_col = Color("ef4444")
        elif p_dmg >= 100.0: dmg_col = Color("fb923c")
        elif p_dmg >= 50.0: dmg_col = Color("fde047")

        health_text[i].text = "%d %%" % int(round(p_dmg))
        health_text[i].add_theme_color_override("font_color", dmg_col)

        var super_val: float = f.get("super", 0.0)
        var combo_val: int = f.get("combo", 0)
        var super_str: String = "⚡ SUPER!" if super_val >= 100.0 else "SUPER %d%%" % int(super_val)
        var combo_str: String = " · %d HITS" % combo_val if combo_val > 1 else ""
        special_text[i].text = super_str + combo_str + (" · SPEZIAL!" if f.cooldowns[1] <= 0 and super_val >= 40 else "")

        if lives_labels.size() > i and lives_labels[i]:
            var lives_cnt: int = f.get("lives", 3)
            var stocks: String = ""
            for k in range(maxi(sim.initial_lives, lives_cnt)):
                stocks += "● " if k < lives_cnt else "○ "
            lives_labels[i].text = "%s (%d STOCKS)" % [stocks, lives_cnt]
            lives_labels[i].add_theme_color_override("font_color", Color("ff4770") if lives_cnt > 1 else Color("ff2233"))
        if portrait_rects.size() > i and portrait_rects[i]:
            var fam_key: String = f.profile.get("family", "")
            if not portrait_cache.has(fam_key): portrait_cache[fam_key] = get_portrait_for_fighter(f)
            portrait_rects[i].texture = portrait_cache[fam_key]
    if paused: status.text = "PAUSE  ·  ESC zum Fortsetzen"
    elif active and sim.countdown > 0: status.text = "BEREIT?"
    elif status_message_time > 0.0: status.text = status_message
    else:
        var aname: String = ARENAS[current_arena].name if ARENAS.has(current_arena) else "BLOOD MOON TERRACE"
        var mode_name: String = {"autonomous": "AGENTENKAMPF", "pve": "SOLO GEGEN KI", "manual": "LOKALER VERSUS"}.get(sim.mode, "KAMPF")
        if story != null and story.running: mode_name = "STORY · " + story.chapter_title()
        status.text = "%s  /  %s" % [aname, mode_name]

func hit_effect(index: int, special: bool, is_super_hit: bool = false) -> void:
    camera_shake = 0.70 if is_super_hit else (0.42 if special else 0.16)
    if index < sim.fighters.size():
        var hp := Vector3(sim.fighters[index].x, sim.fighters[index].y + 1.15, 0.45)
        var hc: Color = Color("9d7bff") if is_super_hit else (Color("49def4") if special else Color("ffd27a"))
        spark_burst(hp, hc, 34 if is_super_hit else (22 if special else 12), 9.0 if special else 6.0)
        if special or is_super_hit: shock_ring(hp, hc, 3.5 if is_super_hit else 2.2)
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

## Short afterimage streak behind a fighter using the air dash.
func dash_effect(index: int, dir: float) -> void:
    if index >= sim.fighters.size(): return
    var col: Color = PLAYER_COLORS[index % PLAYER_COLORS.size()]
    for k in range(4):
        var s := Sprite3D.new()
        s.texture = ELECTRIC_SPARK
        s.pixel_size = 0.012
        s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        s.modulate = col
        add_child(s)
        s.position = Vector3(sim.fighters[index].x - dir * k * 0.35, sim.fighters[index].y + 1.0, 0.3)
        var t := create_tween()
        t.tween_property(s, "scale", Vector3.ONE * (2.4 - k * 0.4), 0.06)
        t.parallel().tween_property(s, "modulate:a", 0.0, 0.3 + k * 0.05)
        t.tween_callback(s.queue_free)

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
    smoke_ticks = 0
    print("PFU_RENDER_ROUND_COMPLETE ", sim.result, " hits=", smoke_report.hits)
    if not capture_dir.is_empty(): await capture("godot-result.png")
    await get_tree().create_timer(1.0).timeout
    if smoke_rounds == 1:
        smoke_report.restarts += 1
        start_round("autonomous")
    else:
        var total := 0.0
        for v in fps_samples: total += v
        smoke_report["fps_avg"] = snappedf(total / maxf(1.0, fps_samples.size()), 0.1)
        smoke_report["fps_min"] = fps_samples.min() if not fps_samples.is_empty() else 0
        print("PFU_RENDER_SMOKE_OK ", JSON.stringify(smoke_report))
        get_tree().quit()

func capture(filename: String) -> void:
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    image.save_png(capture_dir.path_join(filename))

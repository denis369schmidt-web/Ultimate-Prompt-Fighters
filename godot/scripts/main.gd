extends Node3D

const Prompt = preload("res://scripts/prompt_interpreter.gd")
const Combat = preload("res://scripts/combat.gd")
const FighterView = preload("res://scripts/fighter_view.gd")
const Remixer = preload("res://scripts/character_remixer.gd")
const StoryModeScript = preload("res://scripts/story_mode.gd")
const ArenaBuilder = preload("res://scripts/arena_builder.gd")
const Bosses = preload("res://scripts/bosses.gd")
const Backgrounds = preload("res://scripts/backgrounds.gd")
const Progression = preload("res://scripts/progression.gd")
const Rewards = preload("res://scripts/rewards.gd")
const BossModels = preload("res://scripts/boss_models.gd")
const WeaponModels = preload("res://scripts/weapon_models.gd")
const Adventure = preload("res://scripts/adventure.gd")
const FunModes = preload("res://scripts/fun_modes.gd")
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
    "anubis": preload("res://assets/textures/characters/thumbs/thumb_anubis.png"),
    "specter": preload("res://assets/textures/characters/thumbs/thumb_specter.png"),
    "phoenix": preload("res://assets/textures/characters/thumbs/thumb_phoenix.png"),
    "brunhild": preload("res://assets/textures/characters/thumbs/thumb_brunhild.png"),
    "thorn_witch": preload("res://assets/textures/characters/thumbs/thumb_thorn_witch.png"),
    "nyx": preload("res://assets/textures/characters/thumbs/thumb_nyx.png"),
    "shira": preload("res://assets/textures/characters/thumbs/thumb_shira.png"),
    "frostwyrm": preload("res://assets/textures/characters/thumbs/thumb_frostwyrm.png"),
    "cyborg_mech": preload("res://assets/textures/characters/thumbs/thumb_cyborg_mech.png"),
    "reaper_hound": preload("res://assets/textures/characters/thumbs/thumb_reaper_hound.png"),
    "treant": preload("res://assets/textures/characters/thumbs/thumb_treant.png"),
    "celestial_fox": preload("res://assets/textures/characters/thumbs/thumb_celestial_fox.png"),
    "mossback": preload("res://assets/textures/characters/thumbs/thumb_mossback.png"),
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

## Arena definitions. Shop arenas (backgrounds.gd) are added at start-up.
var ARENAS = {
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
    "hell_gate": {
        "name": "HÖLLENTOR · LIMBUS", "boss": true,
        "sky": preload("res://assets/textures/arenas/sky2_blood_moon.png"),
        "thumb": null, "floor": null, "floor_em": null, "floor_norm": null,
        "sun_color": Color("ff8a6a"), "sun_rot": Vector3(-35, 10, 0), "ambient_color": Color("3a1410"), "fire_color": Color("b91c1c")
    },
    "hell_flames": {
        "name": "KREIS DER FLAMMEN", "boss": true,
        "sky": preload("res://assets/textures/arenas/sky2_blood_moon.png"),
        "thumb": null, "floor": null, "floor_em": null, "floor_norm": null,
        "sun_color": Color("ffa070"), "sun_rot": Vector3(-35, 10, 0), "ambient_color": Color("4a1a0c"), "fire_color": Color("ff5a1f")
    },
    "hell_city": {
        "name": "STADT DIS", "boss": true,
        "sky": preload("res://assets/textures/arenas/sky2_blood_moon.png"),
        "thumb": null, "floor": null, "floor_em": null, "floor_norm": null,
        "sun_color": Color("ff9a6a"), "sun_rot": Vector3(-35, 10, 0), "ambient_color": Color("3a1810"), "fire_color": Color("f97316")
    },
    "cocytus": {
        "name": "COCYTUS · DER EISSEE", "boss": true,
        "sky": preload("res://assets/textures/arenas/sky2_blood_moon.png"),
        "thumb": null, "floor": null, "floor_em": null, "floor_norm": null,
        "sun_color": Color("c7e0ff"), "sun_rot": Vector3(-35, 10, 0), "ambient_color": Color("22324a"), "fire_color": Color("7dd3fc")
    },
    "heaven_spheres": {
        "name": "HIMMELSSPHÄREN", "boss": true,
        "sky": preload("res://assets/textures/arenas/sky2_blood_moon.png"),
        "thumb": null, "floor": null, "floor_em": null, "floor_norm": null,
        "sun_color": Color("e6ecff"), "sun_rot": Vector3(-35, 10, 0), "ambient_color": Color("3a4260"), "fire_color": Color("bfe3ff")
    },
    "heaven_gate": {
        "name": "HIMMELSPFORTE", "boss": true,
        "sky": preload("res://assets/textures/arenas/sky2_blood_moon.png"),
        "thumb": null, "floor": null, "floor_em": null, "floor_norm": null,
        "sun_color": Color("ffd6a0"), "sun_rot": Vector3(-35, -20, 0), "ambient_color": Color("6a5238"), "fire_color": Color("ffb13b")
    },
    "wheel_heaven": {
        "name": "RÄDERHIMMEL", "boss": true,
        "sky": preload("res://assets/textures/arenas/sky2_blood_moon.png"),
        "thumb": null, "floor": null, "floor_em": null, "floor_norm": null,
        "sun_color": Color("ffe6a8"), "sun_rot": Vector3(-45, 30, 0), "ambient_color": Color("4a4030"), "fire_color": Color("ffd24a")
    },
    "empyrean": {
        "name": "EMPYREUM", "boss": true,
        "sky": preload("res://assets/textures/arenas/sky2_blood_moon.png"),
        "thumb": null, "floor": null, "floor_em": null, "floor_norm": null,
        "sun_color": Color("ff9a7a"), "sun_rot": Vector3(-30, 10, 0), "ambient_color": Color("4a1810"), "fire_color": Color("ff3b1f")
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
var audio_director: Node = null   # scripts/audio_director.gd: music, sfx variants, announcer, voices
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
## Player progress: XP, level, coins, bought start screen backgrounds (progression.gd).
var progression = Progression.new()
var last_reward_text := ""
## Start screen (title) with the chosen background; its painted menu becomes real buttons.
var title_screen: Control
var title_logo: Control
var title_menu: VBoxContainer
var title_hint: Label
var title_showcase: Array = []
var title_time := 0.0
var title_arena := ""
var title_prev_arena := ""
var title_hid_selection := false
var title_hotspots: Array = []
var title_highlight: Panel
var title_index := 0
var title_info: Label
var title_panel: PanelContainer      # shop / options / credits overlay on the start screen
var title_panel_kind := ""
var shop_buttons: Array = []
var shop_index := 0
## Start screen stage: "splash" (press start) or "menu" (the painted main menu).
var title_stage := "splash"
var splash_cover: Panel
var splash_label: Label
var splash_tween: Tween
## Controller navigation for every menu panel: a glowing frame jumps between buttons.
var nav_layer: CanvasLayer
var nav_frame: Panel
var nav_focus: Button = null
var menu_return_title := false   # boss/story menu opened from the main menu: B goes back there
var shop_arena_index := -1
var shop_tab := "backgrounds"     # backgrounds | weapons | skins | chest
var chest_rng := RandomNumberGenerator.new()
var chest_result := ""
var wheel_cells: Array = []
var wheel_result := ""
var wheel_spinning := false
## Versus layout: "1v1", "ffa" (4 players each alone), "2v2", "3v1" (the lone fighter is stronger).
const TEAM_MODES := ["1v1", "ffa", "2v2", "3v1"]
var team_mode := "1v1"
## Boss mode: heroes (team 0) against an angel boss (bosses.gd).
var boss_active := false
var boss_rush := false
var boss_id := ""
var pre_boss_arena := ""
var boss_menu: PanelContainer
var boss_menu_buttons: Array = []
var boss_menu_index := 0
var boss_bar: Control
var boss_bar_fill: ColorRect
var boss_bar_label: Label
var next_boss_button: Button
## Adventure mode (adventure.gd): the running run, its result button, the best combo of the wave.
var adventure = null
var adventure_button: Button
var revanche_button: Button
var adventure_combo := 0
## Fun systems (fun_modes.gd): mutators for versus, today's challenge, surprise challengers, comeback gift.
var active_mutators: Array = []
var daily_active := false
var daily_info: Dictionary = {}
var daily_time0 := 0.0
var daily_lives0 := 2
var challenger_active := false
var challenger_pending := false
var comeback_gift: Dictionary = {}
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
    progression.persist = DisplayServer.get_name() != "headless" and not smoke
    progression.load_progress()
    progression.event = FunModes.event_of(Progression.today())
    if progression.persist: comeback_gift = FunModes.check_comeback(progression, Progression.today())
    chest_rng.randomize()
    _register_shop_arenas()
    setup_inputs()
    setup_world()
    setup_player_markers()
    setup_ui()
    setup_touch()
    setup_store()
    setup_audio()
    restore_prompts()
    refresh_previews()
    update_mk_grid_visuals()
    # Start screen at launch (not in smoke/capture runs and headless tests, which drive the game directly).
    if not smoke and not capture_selection and DisplayServer.get_name() != "headless": show_title("splash")
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

## Touch controls for player 1 on phones, tablets and (optionally) touch laptops.
const Platform = preload("res://scripts/platform.gd")
const TouchControlsScript = preload("res://scripts/touch_controls.gd")
var touch: Control = null
const StoreScript = preload("res://scripts/store.gd")
const Products = preload("res://scripts/products.gd")
var store: Node = null

## Real-money store (store.gd): Steam DLC, Google Play purchases, local test mode elsewhere.
func setup_store() -> void:
    store = StoreScript.new()
    store.name = "Store"
    store.persist = progression.persist
    add_child(store)
    store.setup()
    store.ownership_changed.connect(_on_store_changed)
    _on_store_changed()

## Gives the contents of every owned product (idempotent) and refreshes an open shop.
func _on_store_changed() -> void:
    for p in Products.PRODUCTS:
        if store.owns(str(p.id)): Products.apply(progression, str(p.id), Backgrounds.LIST, Rewards.WEAPONS)
    if title_panel != null and title_panel.visible and title_panel_kind == "shop": _open_title_panel("shop")

## Premium tab: real stores always; the local test store only in debug builds, so a free
## desktop download never hands out paid content.
func premium_visible() -> bool:
    return store != null and (store.backend != "local" or OS.is_debug_build())

## Google Play free tier: story beyond the first chapters and most bosses need the Vollversion.
func full_game_locked() -> bool:
    return store != null and not store.has_full_game()

const FREE_BOSSES := 3

func boss_needs_full_game(bid: String, rush: bool) -> bool:
    if not full_game_locked(): return false
    return rush or Bosses.ORDER.find(bid) >= FREE_BOSSES

func show_full_game_offer() -> void:
    show_status("💎 VOLLVERSION nötig – einmal kaufen, alles freischalten", 3.0)
    hide_selection_overlays()
    show_title("menu")
    shop_tab = "premium"
    _open_title_panel("shop")

func hide_selection_overlays() -> void:
    close_boss_menu()
    if story != null and story.menu_panel != null: story.menu_panel.hide()

func setup_touch(force: bool = false) -> void:
    if not (force or Platform.touch_enabled()) or touch != null: return
    var layer := CanvasLayer.new()
    layer.name = "TouchLayer"
    layer.layer = 50
    add_child(layer)
    touch = TouchControlsScript.new()
    touch.name = "TouchControls"
    layer.add_child(touch)
    touch.pause_pressed.connect(func():
        if active and (result_panel == null or not result_panel.visible): paused = not paused)
    touch.back_pressed.connect(go_back)
    touch.quit_pressed.connect(func():
        paused = false
        show_selection())

func _update_touch_mode() -> void:
    if touch == null: return
    var result_open: bool = result_panel != null and result_panel.visible
    # The keyboard / gamepad help bar would sit under the touch buttons.
    if battle_hud_bottom != null and active: battle_hud_bottom.visible = false
    if active and not result_open:
        touch.mode = "pause" if paused else "fight"
    elif title_screen != null and title_screen.visible and title_stage == "splash":
        touch.mode = "off"
    else:
        touch.mode = "menu"

## One "back" for every input: Android back button, the touch back button, B / View on a pad.
func go_back() -> void:
    if active and (result_panel == null or not result_panel.visible):
        paused = not paused
        return
    if title_screen != null and title_screen.visible and title_stage == "splash" and (title_panel == null or not title_panel.visible):
        if Platform.is_mobile(): get_tree().quit()
        return
    _pad_menu_button(0, JOY_BUTTON_B)

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_GO_BACK_REQUEST: go_back()
    elif what == NOTIFICATION_APPLICATION_PAUSED and active: paused = true

## Keyboard: P1 left side, P2 right side. Gamepads: device k controls player k+1, with the
## genre-standard Xbox layout: left stick / d-pad move (flick up = jump), A attack, B special,
## X / Y jump, LB / RB grab, LT / RT shield, right stick = smash attacks (aerials in the air),
## Menu (☰) pause, View (⧉) back. Menus: d-pad / stick move the cursor, A choose, B back,
## Y random fighter, Menu start.
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
        _pad_button(pre + "grab", pi, JOY_BUTTON_LEFT_SHOULDER)
        _pad_button(pre + "left", pi, JOY_BUTTON_DPAD_LEFT)
        _pad_button(pre + "right", pi, JOY_BUTTON_DPAD_RIGHT)
        _pad_button(pre + "up", pi, JOY_BUTTON_DPAD_UP)
        _pad_button(pre + "down", pi, JOY_BUTTON_DPAD_DOWN)
        _pad_button(pre + "standard", pi, JOY_BUTTON_A)
        _pad_button(pre + "special", pi, JOY_BUTTON_B)
        _pad_button(pre + "jump", pi, JOY_BUTTON_X)
        _pad_button(pre + "jump", pi, JOY_BUTTON_Y)
        _pad_button(pre + "grab", pi, JOY_BUTTON_RIGHT_SHOULDER)

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

    # Light SSAO on desktop (contact shadows under props and fighters); apply_graphics_profile turns it off on phones.
    world_env.environment.ssao_enabled = true
    world_env.environment.ssao_radius = 1.1
    world_env.environment.ssao_intensity = 1.0
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
    apply_graphics_profile()

## Phones (Platform.low_graphics): one shadow split at a shorter range, lighter glow and fog,
## 3D rendered at 75 % resolution and upscaled, 60 FPS cap to save battery.
func apply_graphics_profile() -> void:
    if not Platform.low_graphics():
        apply_quality(quality_setting())
        return
    var env: Environment = world_env.environment
    env.ssao_enabled = false
    env.glow_bloom = 0.0
    env.glow_intensity = 0.4
    env.fog_aerial_perspective = 0.0
    env.adjustment_enabled = false
    sunlight.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
    sunlight.directional_shadow_max_distance = 22.0
    sunlight.shadow_blur = 0.6
    get_viewport().scaling_3d_scale = 0.75
    Engine.max_fps = 60

## Desktop quality: "high" (all effects, MSAA, SSAO, native resolution) or "balanced"
## (FXAA instead of MSAA, no SSAO, FSR upscaling from 80 %). Measured with tests/bench_render.gd
## on Intel UHD at 1080p: 25 FPS high → about 60 FPS balanced. Integrated GPUs start balanced.
func quality_setting() -> String:
    var q: String = str(Platform.setting("quality", "auto"))
    if q == "auto":
        q = "balanced" if RenderingServer.get_video_adapter_type() == RenderingDevice.DEVICE_TYPE_INTEGRATED_GPU else "high"
    return q

func apply_quality(q: String) -> void:
    var vp := get_viewport()
    var env: Environment = world_env.environment
    var balanced: bool = q == "balanced"
    vp.msaa_3d = Viewport.MSAA_DISABLED if balanced else Viewport.MSAA_2X
    vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if balanced else Viewport.SCREEN_SPACE_AA_DISABLED
    vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if balanced else Viewport.SCALING_3D_MODE_BILINEAR
    vp.scaling_3d_scale = 0.8 if balanced else 1.0
    env.ssao_enabled = not balanced

func _cycle_quality() -> void:
    var order := ["auto", "high", "balanced"]
    var cur: String = str(Platform.setting("quality", "auto"))
    Platform.set_setting("quality", order[(order.find(cur) + 1) % order.size()])
    if not Platform.low_graphics(): apply_quality(quality_setting())

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
        if node == null and shape == "clone" and bool(spec.get("echo", false)) and int(pr.owner) < sim.fighters.size():
            node = FighterView.new()
            add_child(node)
            node.setup(sim.fighters[pr.owner].profile)
            for m in node.find_children("*", "MeshInstance3D", true, false):
                m.transparency = 0.45
            node.set_meta("last_pillar_x", pr.x - 99.0)
            projectile_nodes[pr.id] = node
        if node is FighterView:
            var owner_f: Dictionary = sim.fighters[pr.owner]
            var ghost_pose: String = "Dash" if not pr.get("echoing", false) else (str(owner_f.pose) if owner_f.state == "Attack" else "Idle")
            node.update_state({"x": pr.x, "y": pr.y - 0.9, "facing": sim._facing_from(int(pr.owner), float(pr.x)),
                "pose": ghost_pose, "blocking": false}, get_process_delta_time())
            continue
        if node == null:
            node = WeaponModels.projectile(shape, col)
            node.set_meta("last_pillar_x", pr.x - 99.0)
            add_child(node)
            projectile_nodes[pr.id] = node
        node.position = Vector3(pr.x, pr.y, 0.3)
        if pr.has("size_now"): node.scale = Vector3.ONE * float(pr.size_now) / float(spec.get("size", 0.3))
        if pr.get("stuck", false) or pr.get("pooled", false):
            pass # stuck in the floor / lying on it
        elif shape in ["saber", "boomerang", "scythe", "glitch"]:
            node.rotation.z -= 0.35
        elif shape == "star_seal":
            node.position.y = pr.y - 0.05
            node.rotation.y += get_process_delta_time() * 0.8
        elif shape == "flame_wall":
            node.scale = Vector3(1.0 + sin(Time.get_ticks_msec() * 0.02) * 0.06, 1.0 + sin(Time.get_ticks_msec() * 0.013) * 0.08, 1.0)
        elif shape == "strike_marker":
            # The orbital beam falls once the warning is over.
            var fired: bool = float(pr.get("age", 0.0)) >= float(spec.get("delay", 0.0))
            node.scale = Vector3(1.0 + sin(Time.get_ticks_msec() * 0.03) * 0.1, 1.0, 1.0)
            if fired and not node.has_meta("fired"):
                node.set_meta("fired", true)
                _fade_free(_beam(Vector3(pr.x, pr.y + 14.0, 0.3), Vector3(pr.x, pr.y, 0.3), col, 1.4), 0.5)
                shock_ring(Vector3(pr.x, pr.y + 0.05, 0.3), col, 4.0)
                spark_burst(Vector3(pr.x, pr.y + 0.4, 0.3), Color("fff7cc"), 60, 9.0, 0.12)
                flash_screen(Color("fff7cc"), 0.4)
                camera_shake = 1.0
                sound("lava")
        elif shape == "skeleton":
            node.rotation = Vector3(0, 0 if pr.vx >= 0.0 else PI, sin(Time.get_ticks_msec() * 0.012) * 0.12)
        elif shape == "roots":
            # Roots wait underground, then break out once.
            var sprung: bool = float(pr.get("age", 0.0)) >= float(spec.get("delay", 0.0))
            node.visible = sprung
            if sprung and not node.has_meta("sprung"):
                node.set_meta("sprung", true)
                erupt_pillar(Vector3(pr.x, pr.y - 0.5, 0.2), col, false)
                shock_ring(Vector3(pr.x, pr.y - 0.45, 0.3), col, 1.4)
            elif not sprung and randf() < 0.3:
                spark_burst(Vector3(pr.x + randf_range(-0.5, 0.5), pr.y - 0.45, 0.3), col.darkened(0.3), 2, 1.5, 0.05)
        elif shape == "bone_cage":
            node.scale = Vector3.ONE * clampf(float(pr.get("age", 0.0)) * 6.0, 0.2, 1.0)
        elif shape == "cloud":
            # Hail falls from the snow cloud.
            if randf() < 0.35:
                spark_burst(Vector3(pr.x + randf_range(-1.0, 1.0), pr.y - 0.5, 0.3), Color(0.85, 0.95, 1.0), 3, 2.5, 0.05)
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
    var theme: Dictionary = ArenaBuilder.theme_for(id)
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
        "volcano_sanctum": 0.9, "pirate_galleon": 0.95,
        "heaven_gate": 0.72, "wheel_heaven": 0.85, "empyrean": 0.95, "heaven_spheres": 0.85, "cocytus": 0.85}.get(id, float(a.get("exposure", 1.05)))
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
    var keys := label("🎮 MENÜ: Steuerkreuz Kämpfer · A wählen · Y Zufall · X Bosse · LB/RB Arena · ⧉ Modus · R3 Teams · ☰ KAMPF · B Hauptmenü   |   KAMPF: A Schlag · B Spezial · X/Y Sprung · LB/RB Greifen · LT/RT Schild · R-Stick Smash · ☰ Pause   |   ⌨ P1 A/D W S Q F G E · P2 Pfeile I K L O", 11)
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

    var btn_home := button("🏠 MENÜ", Color("fbbf24"), show_title)
    btn_home.custom_minimum_size = Vector2(90, 34)
    btn_home.add_theme_font_size_override("font_size", 12)
    top_h.add_child(btn_home)

    var btn_boss := button("👁 BOSSKAMPF", Color("ff5a1f"), open_boss_menu)
    btn_boss.name = "BtnBoss"
    btn_boss.custom_minimum_size = Vector2(130, 34)
    btn_boss.add_theme_font_size_override("font_size", 12)
    top_h.add_child(btn_boss)

    var btn_players := button("👥 1 GEGEN 1", Color("38bdf8"), _toggle_player_count)
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
        if ARENAS[aid].get("boss", false): continue # boss levels are reached through the boss mode
        var abtn := Button.new()
        abtn.text = ARENAS[aid].name.left(10)
        abtn.custom_minimum_size = Vector2(68, 20)
        abtn.add_theme_font_size_override("font_size", 8)
        abtn.add_theme_stylebox_override("normal", panel_style(Color("162b40"), Color("34445b"), 1, 4))
        abtn.focus_mode = Control.FOCUS_NONE
        var target_aid: String = aid
        abtn.pressed.connect(func(): apply_arena(target_aid))
        arena_row.add_child(abtn)
    var shop_btn := Button.new()
    shop_btn.text = "★ SHOP-ARENA"
    shop_btn.custom_minimum_size = Vector2(80, 20)
    shop_btn.add_theme_font_size_override("font_size", 8)
    shop_btn.add_theme_color_override("font_color", Color("fbbf24"))
    shop_btn.add_theme_stylebox_override("normal", panel_style(Color("2b1f08"), Color("fbbf24"), 1, 4))
    shop_btn.focus_mode = Control.FOCUS_NONE
    shop_btn.pressed.connect(_cycle_shop_arena)
    arena_row.add_child(shop_btn)

    _refresh_option_buttons.call_deferred()

    # 5. 40-FIGHTER PRESETS (2 ROWS OF 20 CARDS)
    mk_presets = [
        {"id": "ninja", "name": "VOLT NINJA", "prompt": "Blitzschneller Schattenninja mit elektrischen Klingen"},
        {"id": "golem", "name": "MAGMOR", "prompt": "Gepanzerter Lavagolem mit brennenden Fäusten"},
        {"id": "valkyrie", "name": "BOLTAR", "prompt": "Strahlende Moe Valkyrie Paladin Kriegerin mit Lichtflügeln und Rapier"},
        {"id": "dragon", "name": "TEMPLAR", "prompt": "Mächtiger Cyber Drachenritter mit flammendem Drachen-Großschwert"},
        {"id": "kairo", "name": "KAIRO", "prompt": "Kairo der Sturmmönch mit Solar-Kanone"},
        {"id": "varakh", "name": "VARAKH", "prompt": "Varakh der Scharlachfürst mit Nova-Strahl"},
        {"id": "xylar", "name": "XYLAR", "prompt": "Xylar der Leerenkaiser mit Nadelstrahl"},
        {"id": "glaciem", "name": "GLACIEM", "prompt": "Glaciem die Frostassassine mit Eissplitter"},
        {"id": "oryn", "name": "ORYN", "prompt": "Oryn der Schwerkraftprophet mit Abstoßungswelle"},
        {"id": "tobi", "name": "TOBI", "prompt": "Tobi der Federfaust-Raufbold mit Schleuderfaust"},
        {"id": "jubei", "name": "JUBEI", "prompt": "Jubei der Windklingen-Wanderer mit Sturmschnitt"},
        {"id": "ren", "name": "REN", "prompt": "Ren die Kirschkriegerin mit Blütenwirbel"},
        {"id": "amethya", "name": "AMETHYA", "prompt": "Amethya die Donnerhexe mit Amethystblitz"},
        {"id": "bruno", "name": "BRUNO", "prompt": "Bruno der Einschlag-Held mit Meteorfaust"},
        {"id": "hikaru", "name": "HIKARU", "prompt": "Hikaru der Glutklingen-Wanderer mit Morgenrotschnitt"},
        {"id": "zip", "name": "ZIP", "prompt": "Zip der Blitzkurier mit Turbo-Sprint"},
        {"id": "raiga", "name": "RAIGA", "prompt": "Raiga die Donnerfaust mit Sternschlag"},
        {"id": "albion", "name": "ALBION", "prompt": "Albion der Silberwyrm mit Sturmstrahl"},
        {"id": "pyrax", "name": "PYRAX", "prompt": "Pyrax die Glutwyvern mit Glutsturm"},
        {"id": "anubis", "name": "AURUM", "prompt": "Jackal God Anubis wielding dual Khopesh"},
        {"id": "specter", "name": "RAVENNA", "prompt": "Void Specter crystal phantom warrior with void lance"},
        {"id": "phoenix", "name": "SCARLET", "prompt": "Phoenix Empress with feather armor and phoenix glaive"},
        {"id": "arber", "name": "ARBËR", "prompt": "Arbër der Bohrmeister mit zwei Bohrmaschinen und dem Doppeladler"},
        {"id": "brunhild", "name": "BRUNHILD", "prompt": "Brunhild golden axe valkyrie giantess"},
        {"id": "lepora", "name": "LEPORA", "prompt": "Lepora die Mondjägerin mit Mondbogen"},
        {"id": "thorn_witch", "name": "THORN WITCH", "prompt": "Thorn Sorceress dark magic"},
        {"id": "nyx", "name": "NYX HARVESTER", "prompt": "Nyx Harvester of Souls demon scythe reaper"},
        {"id": "shira", "name": "SHIRA", "prompt": "Cat Girl Kitsune Warrior blade"},
        {"id": "frostwyrm", "name": "FROSTWYRM", "prompt": "Blue Wyrm Frost Dragon beast"},
        {"id": "cyborg_mech", "name": "CYBORG MECH", "prompt": "White Cyborg Android Mech warrior"},
        {"id": "reaper_hound", "name": "REAPER HOUND", "prompt": "Reaper Skeleton Hound nether beast"},
        {"id": "treant", "name": "TREANT GOLEM", "prompt": "Ancient Treant Wood Golem nature"},
        {"id": "celestial_fox", "name": "CELESTIAL FOX", "prompt": "Celestial Nine Tailed Fox Kyuubi spirit"},
        {"id": "mossback", "name": "MOSSBACK", "prompt": "Sylvan Beast Treant quadruped creature"},
        {"id": "steel_knight", "name": "CARDINAL", "prompt": "Steel Knight Ritter in Vollplatte mit eisernem Schild"},
        {"id": "vanguard_soldier", "name": "VANGUARD", "prompt": "Vanguard Soldat mit Cyber-Rüstung und Photonenkanone"},
        {"id": "sorceress_medea", "name": "SORCERESS", "prompt": "Sorceress Medea Erzmagierin mit astraler Dunkelmagie"},
        {"id": "skeleton_reaper", "name": "FLAYER", "prompt": "Skeleton Reaper Untoter Seelenernter mit Knochensense"},
        {"id": "mutant_titan", "name": "MUTANT", "prompt": "Mutant Titan kolossaler Koloss mit Giftschlag"},
        {"id": "swat_specops", "name": "SWAT AGENT", "prompt": "SWAT SpecOps Taktischer Agent mit Schockgranaten"},
        {"id": "samurai_dreyar", "name": "KOMMANDANT", "prompt": "Samurai Dreyar Meister mit Wind-Klingen und Sturm-Schritten"},
        {"id": "pirate_captain", "name": "SERAPHINE", "prompt": "Korsar Corsair Piratenkapitän mit Entermesser und Donnerbüchse"},
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

        var cursor_frame := Panel.new()
        cursor_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
        cursor_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
        cursor_frame.visible = false
        card.add_child(cursor_frame)

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
        mk_card_buttons.append({"button": card, "badge_p1": badge_p1, "badge_p2": badge_p2, "cursor": cursor_frame})

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
    revanche_button = button("REVANCHE  ·  R", CYAN, restart_round)
    result_box.add_child(revanche_button)
    adventure_button = button("WEITER ▶  (A)", Color("e41e20"), _adventure_continue)
    result_box.add_child(adventure_button)
    adventure_button.hide()
    next_boss_button = button("NÄCHSTER BOSS ▶  (A)", Color("ff5a1f"), next_boss)
    result_box.add_child(next_boss_button)
    next_boss_button.hide()
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
        "beam", "charge_beam":
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
        "dash", "trail_dash":
            for k in range(5):
                spark_burst(center - Vector3(fx * k * 0.4, 0, 0), color, 8, 3.0, 0.08)
            sound("electric")
        "barrage":
            spark_burst(center + Vector3(fx * 1.0, 0, 0), color, 40, 6.0, 0.08)
            sound("hit")
        "power", "one_punch":
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
        "eruption", "meteor", "mine", "turret", "projectile", "clone", "mark", "javelin", "magma", "board", "volley", "nova", "shadow_clone", "singularity":
            spark_burst(center + Vector3(fx * 0.6, 0, 0), color, 14, 4.0, 0.08)
        "mark_strike":
            flash_screen(color, 0.3)
            camera_shake = 0.6
            sound("electric")
        "recall":
            shock_ring(center, color, 1.4)
        "meltdown":
            for k in range(3):
                shock_ring(center + Vector3(0, -0.5 + k * 0.5, 0), color, 5.0 + k * 1.5)
            spark_burst(center, color, 90, 11.0, 0.14)
            flash_screen(color, 0.5)
            announce("KERNSCHMELZE!", color, 0.5)
            camera_shake = 1.4
            sound("lava")
        "cannon":
            announce("FEUER!", color, 0.35)
            sound("lava")
        "bulwark":
            shock_ring(center + Vector3(fx * 0.6, 0, 0), color, 1.6)
            sound("block")
        "iai":
            shock_ring(Vector3(f.x, f.y + 0.1, 0.3), color, 2.2)
        "leap_slam":
            spark_burst(Vector3(f.x, f.y + 0.2, 0.3), color, 24, 5.0, 0.1)
            announce("WAAARGH!", color, 0.35)
            sound("jump")
        "teleport":
            pass
        "tri_slash", "tri_slash_2", "tri_slash_3":
            var reach: float = 2.2
            var cy: float = 0.7 if mech == "tri_slash_3" else randf_range(-0.3, 0.3)
            _fade_free(_beam(center + Vector3(-fx * 0.4, -cy, 0.1), center + Vector3(fx * reach, cy, 0.1), color.lightened(0.5), 0.09), 0.3)
            spark_burst(center + Vector3(fx * 0.8, 0, 0), color, 16, 5.0, 0.07)
            if mech == "tri_slash_3":
                announce("DREI WELTEN!", color, 0.35)
                camera_shake = 0.7
            sound("hit")
        "sun_wheel":
            for k in range(2):
                shock_ring(center + Vector3(fx * 0.4, -0.2 + k * 0.5, 0), color, 2.4 + k)
            spark_burst(center, Color("ffd166"), 36, 6.0, 0.1)
            sound("lava")
        "sling_fist":
            var sling: float = float(f.pending.get("ability", {}).get("range", 3.0)) if f.pending.has("ability") else 3.0
            var arm_col := Color("e8b48a")
            var arm := _beam(center + Vector3(fx * 0.3, 0, 0), center + Vector3(fx * sling, 0, 0), arm_col, 0.16, true)
            _fade_free(arm, 0.28)
            shock_ring(center + Vector3(fx * sling, 0, 0), color, 1.6 + sling * 0.2)
            spark_burst(center + Vector3(fx * sling, 0, 0), color, 20, 6.0, 0.08)
            camera_shake = 0.3 + sling * 0.06
            sound("hit")
        "star_seal":
            shock_ring(Vector3(f.x, f.y + 0.1, 0.3), color, 3.6)
            spark_burst(Vector3(f.x, f.y + 0.3, 0.3), color, 40, 6.0, 0.1)
            announce("STERNSIEGEL!", color, 0.35)
            sound("electric")
        "ice_decoy":
            spark_burst(center, Color("e0f7ff"), 30, 5.0, 0.08)
            sound("block")
        "eagle":
            # The double-headed eagle answers: a black-red feather storm, the cry, he is lifted.
            shock_ring(Vector3(f.x, f.y + 0.2, 0.3), Color("e41e20"), 3.4)
            spark_burst(Vector3(f.x, f.y + 0.6, 0.3), Color(0.08, 0.02, 0.02), 50, 7.0, 0.1)
            spark_burst(Vector3(f.x, f.y + 0.6, 0.3), Color("e41e20"), 30, 6.0, 0.08)
            announce("SHQIPONJA!", Color("e41e20"), 0.45)
            camera_shake = 0.45
            sound("electric")
        "turbo":
            shock_ring(Vector3(f.x, f.y + 0.2, 0.3), color, 2.6)
            spark_burst(Vector3(f.x, f.y + 0.2, 0.3), color, 30, 7.0, 0.08)
            announce("TURBO!", color, 0.35)
            sound("electric")
        "breath":
            # Fire breath: a roaring cone of flame that follows Pyrax while she breathes.
            announce("FEUERATEM!", color, 0.3)
            sound("lava")
            for k in range(6):
                var bf: Dictionary = sim.fighters[index]
                var bx: float = float(bf.facing)
                var mouth := Vector3(bf.x + bx * 0.6, bf.y + 1.3, 0.35)
                _fade_free(_beam(mouth, mouth + Vector3(bx * 3.4, -0.25, 0), color, 0.5 + 0.08 * (k % 2)), 0.2)
                for d in range(3):
                    spark_burst(mouth + Vector3(bx * (1.0 + d * 1.1), randf_range(-0.3, 0.3), 0), color.lightened(0.15 * d), 8, 3.0 + d, 0.09 + d * 0.03)
                await get_tree().create_timer(0.15).timeout
                if index >= sim.fighters.size(): return
        "rebirth":
            # Ashes to ashes: she burns up and rises again from the fire.
            shock_ring(Vector3(f.x, f.y + 0.2, 0.3), color, 3.2)
            spark_burst(center, color, 60, 9.0, 0.12)
            spark_burst(center, Color("fff3b0"), 30, 6.0, 0.08)
            _fade_free(_beam(Vector3(f.x, f.y, 0.3), Vector3(f.x, f.y + 6.0, 0.3), color, 0.9), 0.6)
            flash_screen(Color("ffb347"), 0.35)
            announce("WIEDERGEBURT!", color, 0.45)
            camera_shake = 0.6
            sound("lava")
        "soul_weigh":
            spark_burst(center + Vector3(fx * 0.6, 0, 0), color, 16, 4.0, 0.08)
            sound("slash")
        "war_horn":
            announce("WALHALLS HORN!", color, 0.4)
            for k in range(3):
                shock_ring(center + Vector3(fx * (1.0 + k * 1.2), 0, 0), color, 2.0 + k * 1.2)
            spark_burst(center + Vector3(fx * 2.0, 0, 0), color, 40, 8.0, 0.1)
            camera_shake = 0.5
            sound("hit")
        "fox_orbit":
            shock_ring(center, color, 1.6)
            spark_burst(center, color, 24, 4.0, 0.08)
            sound("electric")
        "fox_release":
            spark_burst(center, color, 30, 6.0, 0.08)
            announce("FUCHSFEUER!", color, 0.3)
            sound("electric")
        "missile_salvo":
            spark_burst(Vector3(f.x, f.y + 1.9, 0.3), Color("fde68a"), 20, 5.0, 0.08)
            announce("RAKETENSALVE!", color, 0.3)
            sound("lava")
        "blizzard":
            announce("SCHNEESTURM!", color, 0.35)
            spark_burst(center + Vector3(0, 1.0, 0), color, 30, 5.0, 0.1)
            sound("electric")
        "arrow_rain":
            _fade_free(_beam(center, center + Vector3(fx * 1.5, 6.0, 0), color, 0.08), 0.3)
            announce("PFEILREGEN!", color, 0.3)
            sound("slash")
        "reap":
            _fade_free(_beam(center + Vector3(fx * 0.2, 1.0, 0), center + Vector3(fx * 3.2, -0.6, 0), color, 0.35), 0.3)
            spark_burst(center + Vector3(fx * 1.6, 0, 0), color, 30, 6.0, 0.1)
            sound("slash")
        "bramble":
            for k in range(3):
                erupt_pillar(Vector3(f.x + fx * (1.2 + k), f.y, 0.3), color, false)
            announce("DORNENHECKE!", color, 0.3)
            sound("slash")
        "root_snare":
            spark_burst(center, color, 14, 3.0, 0.08)
            sound("block")
        "stampede":
            announce("STAMPEDE!", color, 0.3)
            shock_ring(Vector3(f.x, f.y + 0.1, 0.3), color, 2.0)
            camera_shake = 0.4
            sound("hit")
        "hex":
            spark_burst(center + Vector3(fx * 0.6, 0, 0), color, 20, 3.0, 0.1)
            sound("electric")
        "bone_prison":
            announce("KNOCHENKERKER!", color, 0.35)
            sound("block")
        "toxic_cloud":
            announce("GIFTWOLKE!", color, 0.3)
            spark_burst(center, color, 40, 5.0, 0.14)
            sound("lava")
        "flashbang":
            spark_burst(center + Vector3(fx * 0.6, 0, 0), color, 10, 3.0, 0.06)
            sound("slash")
        "orbital_strike":
            announce("ZIEL MARKIERT", color, 0.3)
            sound("electric")
        "bat_form":
            announce("FLEDERMAUSGESTALT!", color, 0.3)
            sound("electric")
            for k in range(6):
                if index >= sim.fighters.size(): return
                var vf: Dictionary = sim.fighters[index]
                spark_burst(Vector3(vf.x, vf.y + 1.1, 0.35), Color(0.12, 0.02, 0.04), 14, 4.0, 0.1)
                spark_burst(Vector3(vf.x, vf.y + 1.1, 0.35), color, 6, 3.0, 0.07)
                await get_tree().create_timer(0.16).timeout
        "revenant":
            erupt_pillar(Vector3(f.x + fx * 1.0, f.y, 0.3), color, true)
            announce("ERHEBE DICH!", color, 0.3)
            sound("block")
        "time_bomb", "phase_swap", "chain_leash":
            spark_burst(center + Vector3(fx * 0.6, 0, 0), color, 14, 4.0, 0.08)
            sound("slash")
        "flame_wall":
            shock_ring(Vector3(f.x + fx * 1.5, f.y + 0.1, 0.3), color, 2.0)
            spark_burst(Vector3(f.x + fx * 1.5, f.y + 0.5, 0.3), color, 40, 6.0, 0.1)
            camera_shake = 0.5
            sound("lava")

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
## Energy beams share one glow material (shaders/beam_glow.gdshader); color and fade are
## per-instance parameters. solid = a lit, opaque limb (stretched arm) instead of energy.
var _beam_mat: ShaderMaterial = null

func _beam(a: Vector3, b: Vector3, color: Color, width: float, solid: bool = false) -> MeshInstance3D:
    var m := MeshInstance3D.new()
    var cyl := CylinderMesh.new()
    cyl.top_radius = width * 0.5
    cyl.bottom_radius = width * 0.5
    cyl.height = a.distance_to(b)
    cyl.radial_segments = 10
    cyl.rings = 1
    m.mesh = cyl
    m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if not solid else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    if solid:
        var mat := StandardMaterial3D.new()
        mat.albedo_color = color
        mat.roughness = 0.6
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        m.material_override = mat
    else:
        if _beam_mat == null:
            _beam_mat = ShaderMaterial.new()
            _beam_mat.shader = preload("res://shaders/beam_glow.gdshader")
        m.material_override = _beam_mat
        m.set_instance_shader_parameter("color", color)
        m.set_instance_shader_parameter("alpha", 1.0)
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
    elif mat == _beam_mat and mat != null: tw.tween_property(node, "instance_shader_parameters/alpha", 0.0, time)
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
func play_finisher(winner: int, loser: int, kind: String, fin_name: String, variant: String = "") -> void:
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
    # Fighters with their own finisher (fighter_kits.gd) play their variant; the rest use the element finisher.
    if await _finisher_variant(variant, winner, loser, center, floor_y, side, flesh): kind = "__done"
    match kind:
        "__done":
            pass
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
        result_label.text = "%s\nFINISHER: %s" % [winner_text(), fin_name]
        result_panel.show()

## KO at the blast zone: light pillar pointing back into the stage, sparks, flash, slow-mo.
## Animates one number of a fighter dictionary over time (tweens only work on objects).
## Called without await it runs alongside the rest of the cinematic.
func _tween_dict(d: Dictionary, key: String, to: float, time: float) -> void:
    var from: float = float(d[key])
    var t := 0.0
    while t < time:
        await get_tree().process_frame
        t += get_process_delta_time()
        d[key] = lerpf(from, to, clampf(t / time, 0.0, 1.0))

## Own finisher per fighter (variant from fighter_kits.gd). Returns false for unknown variants.
func _finisher_variant(variant: String, winner: int, loser: int, center: Vector3, floor_y: float, side: float, flesh: Color) -> bool:
    var lf: Dictionary = sim.fighters[loser]
    var wf: Dictionary = sim.fighters[winner]
    var lv = views[loser]
    match variant:
        "ninja":
            # Raijin execution: six lightning blinks through the opponent, then everything falls apart.
            sound("electric")
            for k in range(6):
                var s2: float = 1.0 if k % 2 == 0 else -1.0
                wf.x = lf.x + s2 * 1.2
                wf.facing = -int(s2)
                wf.pose = "Attack" if k % 2 == 0 else "Kick"
                var cut := _beam(center + Vector3(-1.3, randf_range(-0.7, 0.7), 0.45), center + Vector3(1.3, randf_range(-0.7, 0.7), 0.45), Color("aef8ff"), 0.07)
                _fade_free(cut, 0.3)
                spark_burst(center, Color("49def4"), 18, 7.0, 0.08)
                lf.pose = "HitReact"
                sound("hit")
                await _wait(0.12)
            wf.x = lf.x - side * 1.8
            wf.facing = int(side)
            wf.pose = "Idle"
            await _wait(0.6)
            flash_screen(Color("dff7ff"), 0.6)
            camera_shake = 1.0
            sound("electric")
            if gore_on and lv.has_bone("head"):
                for key in ["head", "left_arm", "right_arm", "left_leg", "right_leg"]:
                    if not lv.has_bone(key): continue
                    var at: Vector3 = lv.bone_world(key)
                    lv.gore_hide_bone(key)
                    gib(at, Vector3(randf_range(-4, 4), randf_range(3, 7), 0), flesh, 0.22, floor_y)
                    blood_spray(at, Vector3(randf_range(-1, 1), 1, 0), 30, 6.0)
                blood_pool(lf.x, floor_y, 2.4)
                screen_blood(0.8)
                lf.pose = "Defeat"
            else:
                lv.visible = false
                spark_burst(center, Color("e0f7ff"), 90, 12.0, 0.12)
            return true
        "valkyrie":
            # Judgement of light: a giant spear of light falls from the sky onto the opponent.
            wf.pose = "Summon"
            await _wait(0.4)
            var column := _beam(Vector3(lf.x, 16.0, 0.3), Vector3(lf.x, floor_y, 0.3), Color("fff3b0"), 0.2)
            _fade_free(column, 1.2)
            await _wait(0.25)
            var spear := _beam(Vector3(lf.x, floor_y + 12.0, 0.3), Vector3(lf.x, floor_y + 8.0, 0.3), Color("ffe26a"), 0.35)
            var tw := create_tween()
            tw.tween_property(spear, "position:y", spear.position.y - 9.5, 0.28).set_ease(Tween.EASE_IN)
            await _wait(0.28)
            _fade_free(spear, 0.6)
            flash_screen(Color("fff8d6"), 0.8)
            shock_ring(center, Color("ffe26a"), 6.0)
            camera_shake = 1.2
            sound("electric")
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 120, 10.0)
                for k in range(10):
                    gib(center + Vector3(randf_range(-0.3, 0.3), randf_range(-0.5, 0.5), 0), Vector3(randf_range(-6, 6), randf_range(2, 8), 0), flesh, randf_range(0.12, 0.28), floor_y)
                blood_pool(lf.x, floor_y, 2.2)
                screen_blood(0.7)
            lv.visible = false
            spark_burst(center, Color("ffe26a"), 120, 9.0, 0.14)
            return true
        "golem":
            # Volcano grave: the ground opens and the opponent sinks into rising lava.
            wf.pose = "Slam"
            camera_shake = 0.8
            sound("lava")
            for k in range(5):
                erupt_pillar(Vector3(lf.x + (k - 2) * 0.7, floor_y - 0.4, 0.2), Color("ff6d2b"), false)
            lf.pose = "HitReact"
            _tween_dict(lf, "y", floor_y - 2.6, 1.3)
            for k in range(8):
                var lava := _beam(Vector3(lf.x + randf_range(-0.6, 0.6), floor_y - 0.3, 0.25), Vector3(lf.x, floor_y + 2.0 + k * 0.25, 0.25), Color("ff5a1f").lerp(Color("ffd060"), k / 8.0), 0.35)
                _fade_free(lava, 1.0)
                lv.char_body((k + 1) / 8.0)
                spark_burst(Vector3(lf.x, floor_y + 0.3, 0.3), Color("ff7a2a"), 20, 6.0, 0.1)
                await _wait(0.16)
            var geyser := _beam(Vector3(lf.x, floor_y - 0.5, 0.3), Vector3(lf.x, floor_y + 9.0, 0.3), Color("ffb347"), 0.9)
            _fade_free(geyser, 0.9)
            flash_screen(Color("ff7a2a"), 0.5)
            camera_shake = 1.2
            if gore_on:
                for k in range(8):
                    gib(Vector3(lf.x, floor_y + 0.5, 0.2), Vector3(randf_range(-3, 3), randf_range(6, 11), 0), Color(0.08, 0.04, 0.03), randf_range(0.12, 0.25), floor_y)
            lv.visible = false
            lf.y = floor_y
            return true
        "pirate":
            # Broadside: three cannonballs fly in from off screen.
            wf.pose = "Summon"
            announce("FEUER FREI!", Color("fbbf24"), 0.5)
            await _wait(0.35)
            for k in range(3):
                var ball: Node3D = WeaponModels.projectile("cannonball", Color("fbbf24"))
                add_child(ball)
                var from := Vector3(lf.x - side * 14.0, lf.y + 0.6 + k * 0.4, 0.3)
                ball.position = from
                var fly := create_tween()
                fly.tween_property(ball, "position", center + Vector3(0, -0.4 + k * 0.4, 0), 0.32)
                sound("lava")
                await _wait(0.32)
                ball.queue_free()
                spark_burst(center, Color("fbbf24"), 50, 10.0, 0.14)
                shock_ring(center, Color("fb923c"), 3.0 + k)
                flash_screen(Color("fb923c"), 0.35)
                camera_shake = 0.9 + k * 0.2
                lf.pose = "HitReact"
                lf.x += side * 0.5
                if gore_on:
                    blood_spray(center, Vector3(side, 0.6, 0), 40, 8.0)
                await _wait(0.18)
            if gore_on:
                for k in range(12):
                    gib(center + Vector3(randf_range(-0.3, 0.3), randf_range(-0.5, 0.6), 0), Vector3(side * randf_range(3, 9), randf_range(2, 8), 0), flesh, randf_range(0.12, 0.3), floor_y)
                blood_pool(lf.x, floor_y, 2.4)
                screen_blood(0.9)
                lv.visible = false
            else:
                var start_x: float = lf.x
                var t := 0.0
                while t < 0.8:
                    await get_tree().process_frame
                    t += get_process_delta_time()
                    lf.x = start_x + side * 9.0 * t
                    lf.y = floor_y + 6.0 * t
                lv.visible = false
            return true
        "knight":
            # Shield judge: three shield bashes, then a leaping shield slam that flattens the opponent.
            for k in range(3):
                wf.pose = "Attack"
                await _wait(0.12)
                views[winner].shield_flash()
                spark_burst(center + Vector3(-side * 0.5, 0, 0), Color("e2e8f0"), 24, 6.0, 0.08)
                lf.pose = "HitReact"
                lf.x += side * 0.35
                wf.x += side * 0.35
                camera_shake = 0.5
                sound("block")
                wf.pose = "Block"
                await _wait(0.2)
            center = Vector3(lf.x, lf.y + 1.0, 0.0)
            var jump_from: float = wf.y
            _tween_dict(wf, "y", jump_from + 3.2, 0.3)
            _tween_dict(wf, "x", lf.x, 0.3)
            wf.pose = "Rise"
            await _wait(0.35)
            wf.pose = "Stomp"
            _tween_dict(wf, "y", floor_y + 0.4, 0.14)
            await _wait(0.14)
            flash_screen(Color.WHITE, 0.5)
            shock_ring(Vector3(lf.x, floor_y + 0.2, 0.3), Color("e2e8f0"), 5.0)
            camera_shake = 1.4
            sound("hit")
            var squash := create_tween()
            squash.tween_property(lv, "scale", Vector3(1.4, 0.12, 1.4), 0.12)
            if gore_on:
                blood_spray(Vector3(lf.x, floor_y + 0.2, 0.3), Vector3(0, 1, 0), 120, 8.0)
                blood_pool(lf.x, floor_y, 3.0)
                screen_blood(0.8)
            await _wait(0.6)
            wf.y = floor_y
            wf.x = lf.x - side * 1.3
            lv.visible = false
            lv.scale = Vector3.ONE
            return true
        "samurai":
            # Thousand cuts: darkness, a storm of slashes, the blade returns to its sheath.
            wf.pose = "Charge"
            create_tween().tween_property(screen_flash, "color", Color(0, 0, 0, 0.8), 0.25)
            await _wait(0.3)
            wf.x = lf.x + side * 1.9
            wf.facing = int(side)
            for k in range(14):
                var ang: float = randf() * PI
                var off := Vector3(cos(ang), sin(ang), 0) * 1.8
                _fade_free(_beam(center - off + Vector3(0, 0, 0.5), center + off + Vector3(0, 0, 0.5), Color("f0fffc"), 0.05), 0.5)
                if k % 3 == 0: sound("hit")
                await _wait(0.05)
            await _wait(0.5)
            create_tween().tween_property(screen_flash, "color", Color(0, 0, 0, 0.35), 0.2)
            announce("…", Color("99f6e4"), 0.3)
            sound("block") # the blade clicks into the sheath
            await _wait(0.4)
            flash_screen(Color("e6fffa"), 0.6)
            camera_shake = 1.0
            if gore_on and lv.has_bone("head"):
                for key in ["head", "left_arm", "right_arm", "left_leg", "right_leg"]:
                    if not lv.has_bone(key): continue
                    var at: Vector3 = lv.bone_world(key)
                    lv.gore_hide_bone(key)
                    gib(at, Vector3(randf_range(-3, 3), randf_range(2, 6), 0), flesh, 0.2, floor_y)
                blood_fountain(center + Vector3(0, 0.5, 0), Vector3(0, 1, 0), 1.6)
                blood_spray(center, Vector3(0, 1, 0), 100, 9.0)
                blood_pool(lf.x, floor_y, 2.8)
                screen_blood(1.0)
                await _wait(0.6)
                lf.pose = "Defeat"
            else:
                lv.visible = false
                spark_burst(center, Color("99f6e4"), 100, 10.0, 0.12)
            return true
        "warrok":
            # Earth breaker: lifted high overhead, then smashed into the ground.
            wf.pose = "Roar"
            sound("lava")
            await _wait(0.3)
            wf.x = lf.x - side * 0.8
            lf.pose = "HitReact"
            _tween_dict(lf, "y", floor_y + 3.4, 0.45)
            wf.pose = "Rise"
            await _wait(0.6)
            wf.pose = "Slam"
            _tween_dict(lf, "y", floor_y, 0.12)
            await _wait(0.12)
            center = Vector3(lf.x, floor_y + 0.5, 0.0)
            flash_screen(Color.WHITE, 0.55)
            shock_ring(center, Color("f97316"), 7.0)
            for k in range(6):
                erupt_pillar(Vector3(lf.x + (k - 2.5) * 0.9, floor_y - 0.4, 0.2), Color("f97316"), false)
            camera_shake = 1.6
            sound("hit")
            lf.pose = "Defeat"
            if gore_on:
                for k in range(14):
                    gib(center, Vector3(randf_range(-7, 7), randf_range(3, 9), 0), flesh, randf_range(0.12, 0.3), floor_y)
                blood_spray(center, Vector3(0, 1, 0), 140, 11.0)
                blood_pool(lf.x, floor_y, 3.0)
                screen_blood(1.0)
                lv.visible = false
            await _wait(0.5)
            return true
        "kairo":
            # Solar flood: charging aura, then a beam that swallows the opponent.
            wf.pose = "Charge"
            sound("electric")
            for k in range(4):
                shock_ring(Vector3(wf.x, wf.y + 1.0, 0.3), Color("7dd3fc"), 1.5 + k * 0.6)
                await _wait(0.15)
            wf.pose = "Beam"
            var fl1 := _beam(Vector3(wf.x + side * 0.5, wf.y + 1.2, 0.35), Vector3(wf.x + side * 16.0, wf.y + 1.2, 0.35), Color("7dd3fc"), 1.4)
            var fl2 := _beam(Vector3(wf.x + side * 0.5, wf.y + 1.2, 0.4), Vector3(wf.x + side * 16.0, wf.y + 1.2, 0.4), Color("e0f7ff"), 0.6)
            flash_screen(Color("dff7ff"), 0.7)
            camera_shake = 1.3
            lf.pose = "HitReact"
            for k in range(6):
                lv.char_body((k + 1) / 6.0)
                spark_burst(center, Color("bae6fd"), 20, 9.0, 0.1)
                await _wait(0.12)
            _fade_free(fl1, 0.5)
            _fade_free(fl2, 0.4)
            if gore_on:
                for k in range(8):
                    gib(center, Vector3(side * randf_range(4, 10), randf_range(1, 5), 0), Color(0.08, 0.05, 0.04), randf_range(0.12, 0.24), floor_y)
            lv.visible = false
            return true
        "varakh":
            # Star fall: a rain of ki shots from above, then one big blast.
            wf.pose = "Summon"
            wf.y = floor_y + 1.5
            for k in range(10):
                var from := Vector3(lf.x + randf_range(-3, 3), floor_y + 9.0, 0.3)
                _fade_free(_beam(from, Vector3(lf.x + randf_range(-0.4, 0.4), floor_y + 0.5, 0.3), Color("ffe838"), 0.12), 0.25)
                spark_burst(center, Color("fde047"), 14, 7.0, 0.08)
                lf.pose = "HitReact" if k % 2 == 0 else "Dazed"
                camera_shake = 0.5
                if k % 3 == 0: sound("electric")
                await _wait(0.09)
            wf.pose = "Cast"
            await _wait(0.3)
            flash_screen(Color("fff7c2"), 0.8)
            shock_ring(center, Color("ffe838"), 7.0)
            spark_burst(center, Color("ffe838"), 120, 12.0, 0.14)
            camera_shake = 1.5
            sound("lava")
            if gore_on:
                for k in range(12):
                    gib(center, Vector3(randf_range(-8, 8), randf_range(3, 10), 0), flesh, randf_range(0.12, 0.3), floor_y)
                blood_pool(lf.x, floor_y, 2.6)
                screen_blood(0.8)
            lv.visible = false
            wf.y = floor_y
            return true
        "xylar":
            # Supernova: a giant orb crushes the opponent into the ground.
            wf.pose = "Summon"
            var nova: Node3D = WeaponModels.projectile("orb", Color("c084fc"))
            add_child(nova)
            gore_nodes.append(nova)
            nova.position = Vector3(wf.x, wf.y + 3.0, 0.3)
            nova.scale = Vector3.ONE * 0.3
            create_tween().tween_property(nova, "scale", Vector3.ONE * 5.0, 1.0)
            sound("lava")
            await _wait(1.0)
            var drop := create_tween()
            drop.tween_property(nova, "position", center, 0.45).set_ease(Tween.EASE_IN)
            await _wait(0.45)
            lf.pose = "HitReact"
            camera_shake = 1.2
            await _wait(0.3)
            flash_screen(Color("e9d5ff"), 0.9)
            shock_ring(center, Color("c084fc"), 9.0)
            spark_burst(center, Color("d8b4fe"), 140, 13.0, 0.15)
            create_tween().tween_property(nova, "scale", Vector3.ONE * 0.01, 0.25)
            camera_shake = 1.7
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 120, 11.0)
                blood_pool(lf.x, floor_y, 3.0)
                screen_blood(0.9)
            lv.visible = false
            return true
        "ren":
            # Shadow army: clones surround the opponent and pummel, then a spiral core blast.
            var ghosts: Array = []
            for k in range(6):
                var gv = FighterView.new()
                add_child(gv)
                gv.setup(wf.profile)
                for m in gv.find_children("*", "MeshInstance3D", true, false):
                    m.transparency = 0.4
                ghosts.append(gv)
                gore_nodes.append(gv)
            sound("jump")
            for round_k in range(4):
                for k in range(ghosts.size()):
                    var ang: float = TAU * k / ghosts.size() + round_k * 0.4
                    var gx: float = lf.x + cos(ang) * 1.3
                    ghosts[k].update_state({"x": gx, "y": floor_y + maxf(0.0, sin(ang)) * 1.2, "facing": 1 if gx < lf.x else -1,
                        "pose": ["Attack", "Kick", "Uppercut"][(k + round_k) % 3], "blocking": false}, 0.1)
                spark_burst(center, Color("ff9b3d"), 30, 8.0, 0.1)
                lf.pose = "HitReact"
                camera_shake = 0.6
                sound("hit")
                await _wait(0.22)
            wf.pose = "SpecialAttack"
            wf.x = lf.x - side * 1.0
            var core: Node3D = WeaponModels.projectile("orb", Color("7dd3fc"))
            add_child(core)
            gore_nodes.append(core)
            core.position = center
            create_tween().tween_property(core, "scale", Vector3.ONE * 3.5, 0.4)
            await _wait(0.4)
            flash_screen(Color("dbeafe"), 0.7)
            shock_ring(center, Color("7dd3fc"), 7.0)
            camera_shake = 1.4
            sound("lava")
            for gv in ghosts: gv.visible = false
            core.visible = false
            if gore_on:
                for k in range(12):
                    gib(center, Vector3(side * randf_range(3, 10), randf_range(2, 8), 0), flesh, randf_range(0.12, 0.3), floor_y)
                blood_spray(center, Vector3(side, 0.5, 0), 100, 10.0)
                blood_pool(lf.x, floor_y, 2.4)
                screen_blood(0.8)
            lv.visible = false
            return true
        "amethya":
            # Thunder plunge: a lightning thrust straight through, then the sky answers.
            wf.pose = "Charge"
            for k in range(3):
                spark_burst(Vector3(wf.x, wf.y + 1.0, 0.3), Color("60d5ff"), 20, 5.0, 0.07)
                sound("electric")
                await _wait(0.15)
            var from_x: float = wf.x
            wf.x = lf.x + side * 1.3
            wf.pose = "Dash"
            _fade_free(_beam(Vector3(from_x, floor_y + 1.1, 0.4), Vector3(wf.x, floor_y + 1.1, 0.4), Color("bfefff"), 0.18), 0.5)
            flash_screen(Color.WHITE, 0.5)
            lf.pose = "HitReact"
            if gore_on: blood_spray(center, Vector3(side, 0.3, 0), 80, 9.0)
            await _wait(0.6)
            for k in range(3):
                _fade_free(_beam(Vector3(lf.x + randf_range(-0.5, 0.5), 15.0, 0.3), Vector3(lf.x, floor_y, 0.3), Color("9be7ff"), 0.3), 0.25)
                flash_screen(Color("e0f7ff"), 0.5)
                camera_shake = 1.0
                sound("electric")
                await _wait(0.2)
            if gore_on:
                for k in range(12):
                    gib(center, Vector3(randf_range(-7, 7), randf_range(3, 9), 0), flesh, randf_range(0.12, 0.3), floor_y)
                blood_pool(lf.x, floor_y, 2.4)
                screen_blood(0.9)
            lv.visible = false
            spark_burst(center, Color("e0f7ff"), 100, 12.0, 0.12)
            return true
        "oryn":
            # Planet bind: rocks are drawn to the opponent and crush it into a sphere.
            wf.pose = "Summon"
            _tween_dict(lf, "y", floor_y + 3.0, 0.8)
            sound("lava")
            var rocks: Array = []
            for k in range(14):
                var rock := MeshInstance3D.new()
                var bm := BoxMesh.new()
                bm.size = Vector3.ONE * randf_range(0.3, 0.7)
                rock.mesh = bm
                var rm := StandardMaterial3D.new()
                rm.albedo_color = Color(0.3, 0.26, 0.24)
                rock.material_override = rm
                add_child(rock)
                gore_nodes.append(rock)
                var ang: float = TAU * k / 14.0
                rock.position = Vector3(lf.x + cos(ang) * 7.0, floor_y + 3.0 + sin(ang) * 5.0, 0.2)
                rocks.append(rock)
            await _wait(0.6)
            for rock in rocks:
                create_tween().tween_property(rock, "position", Vector3(lf.x, floor_y + 4.0, 0.2) + (rock.position - Vector3(lf.x, floor_y + 4.0, 0.2)).normalized() * 0.5, 0.7).set_ease(Tween.EASE_IN)
            lf.pose = "HitReact"
            await _wait(0.7)
            camera_shake = 1.3
            flash_screen(Color("9900ee"), 0.5)
            sound("hit")
            shock_ring(Vector3(lf.x, floor_y + 4.0, 0.3), Color("c084fc"), 4.0)
            lv.visible = false
            if gore_on:
                blood_spray(Vector3(lf.x, floor_y + 4.0, 0.3), Vector3(0, -1, 0), 90, 6.0)
                blood_pool(lf.x, floor_y, 2.0)
            await _wait(0.5)
            for rock in rocks:
                create_tween().tween_property(rock, "position:y", floor_y + 0.2, 0.4).set_ease(Tween.EASE_IN)
            await _wait(0.4)
            camera_shake = 1.0
            lf.y = floor_y
            return true
        "jubei":
            # Three worlds cut: three dashes from three directions, then the cuts open at once.
            for k in range(3):
                var s3: float = [1.0, -1.0, 1.0][k]
                var from_x: float = wf.x
                wf.x = lf.x + s3 * 1.6
                wf.facing = -int(s3)
                wf.pose = "Dash"
                var hy: float = [0.2, -0.3, 0.6][k]
                _fade_free(_beam(Vector3(from_x, floor_y + 1.0 + hy, 0.45), Vector3(wf.x, floor_y + 1.0 - hy, 0.45), Color("b8fff0"), 0.08), 0.6)
                spark_burst(center, Color("3bfac8"), 16, 6.0, 0.07)
                sound("hit")
                await _wait(0.22)
            wf.pose = "Idle"
            await _wait(0.5)
            flash_screen(Color("e6fffa"), 0.6)
            camera_shake = 1.2
            sound("hit")
            lf.pose = "HitReact"
            if gore_on:
                blood_spray(center, Vector3(side, 0.6, 0), 120, 10.0)
                for k in range(8):
                    gib(center, Vector3(randf_range(-6, 6), randf_range(3, 8), 0), flesh, randf_range(0.12, 0.28), floor_y)
                blood_pool(lf.x, floor_y, 2.4)
            lv.visible = false
            spark_burst(center, Color("3bfac8"), 80, 10.0, 0.12)
            return true
        "hikaru":
            # Thirteenth form: a ring of sun fire, the blade draws a full circle.
            wf.pose = "Charge"
            for k in range(3):
                shock_ring(Vector3(wf.x, floor_y + 0.2, 0.3), Color("ff6524"), 2.0 + k)
                sound("lava")
                await _wait(0.18)
            wf.x = lf.x - side * 1.2
            wf.pose = "Spin"
            for k in range(12):
                var ang: float = TAU * k / 12.0
                spark_burst(center + Vector3(cos(ang) * 1.6, sin(ang) * 1.6, 0.2), Color("ffb347"), 8, 3.0, 0.08)
                await _wait(0.03)
            flash_screen(Color("ffd166"), 0.7)
            camera_shake = 1.2
            lf.pose = "HitReact"
            for k in range(4):
                erupt_pillar(Vector3(lf.x + randf_range(-1.2, 1.2), floor_y, 0.3), Color("ff6524"), false)
            sound("lava")
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 80, 8.0)
                blood_pool(lf.x, floor_y, 2.0)
            await _wait(0.4)
            lv.visible = false
            spark_burst(center, Color("ffb347"), 100, 11.0, 0.14)
            return true
        "tobi":
            # Feather storm: a gatling of stretched fists, then one giant sling punch.
            wf.pose = "Barrage"
            for k in range(14):
                var hy2: float = randf_range(-0.6, 0.6)
                _fade_free(_beam(Vector3(wf.x, floor_y + 1.1, 0.4), center + Vector3(0, hy2, 0.1), Color("e8b48a"), 0.1, true), 0.12)
                spark_burst(center + Vector3(0, hy2, 0), Color("ff2b2b"), 6, 4.0, 0.06)
                lf.pose = "HitReact"
                sound("hit")
                await _wait(0.05)
            wf.pose = "Charge"
            await _wait(0.45)
            wf.pose = "HeavyPunch"
            _fade_free(_beam(Vector3(wf.x, floor_y + 1.1, 0.4), center + Vector3(side * 0.6, 0, 0.1), Color("e8b48a"), 0.3, true), 0.4)
            flash_screen(Color.WHITE, 0.5)
            camera_shake = 1.6
            sound("hit")
            shock_ring(center, Color("ff2b2b"), 6.0)
            if gore_on:
                blood_spray(center, Vector3(side, 0.3, 0), 120, 12.0)
                screen_blood(0.7)
            var start_x2: float = lf.x
            var t2 := 0.0
            while t2 < 0.6:
                await get_tree().process_frame
                t2 += get_process_delta_time()
                lf.x = start_x2 + side * 26.0 * t2
                lf.y = floor_y + 6.0 * t2
            lv.visible = false
            return true
        "raiga":
            # Compass nova: the twelve-ray seal opens under the opponent and erupts into the sky.
            wf.pose = "Slam"
            var seal := WeaponModels.projectile("star_seal", Color("00e5ff"))
            add_child(seal)
            gore_nodes.append(seal)
            seal.position = Vector3(lf.x, floor_y + 0.05, 0.3)
            seal.scale = Vector3.ONE * 0.2
            create_tween().tween_property(seal, "scale", Vector3.ONE * 1.6, 0.6).set_ease(Tween.EASE_OUT)
            sound("electric")
            await _wait(0.7)
            lf.pose = "HitReact"
            for k in range(12):
                var ang2: float = TAU * k / 12.0
                _fade_free(_beam(Vector3(lf.x + cos(ang2) * 2.4, floor_y, 0.3 + sin(ang2) * 0.4), Vector3(lf.x, floor_y + 12.0, 0.3), Color("7df9ff"), 0.08), 0.5)
            flash_screen(Color("e0ffff"), 0.7)
            camera_shake = 1.4
            sound("electric")
            if gore_on:
                for k in range(10):
                    gib(center, Vector3(randf_range(-3, 3), randf_range(6, 12), 0), flesh, randf_range(0.12, 0.3), floor_y)
                blood_pool(lf.x, floor_y, 2.2)
            lv.visible = false
            spark_burst(center, Color("00e5ff"), 100, 12.0, 0.12)
            await _wait(0.5)
            return true
        "glaciem":
            # Eternal ice: frost climbs the opponent, then the statue shatters.
            wf.pose = "Cast"
            sound("block")
            var block := WeaponModels.projectile("ice_decoy", Color("9be7ff"))
            add_child(block)
            gore_nodes.append(block)
            block.position = Vector3(lf.x, floor_y + 0.9, 0.3)
            block.scale = Vector3(1.4, 0.1, 1.4)
            create_tween().tween_property(block, "scale", Vector3(1.6, 1.6, 1.6), 0.9)
            lf.pose = "HitReact"
            await _wait(1.1)
            wf.x = lf.x - side * 1.2
            wf.pose = "Kick"
            await _wait(0.12)
            flash_screen(Color("e0f7ff"), 0.6)
            camera_shake = 1.2
            sound("hit")
            block.visible = false
            for k in range(20):
                gib(center, Vector3(randf_range(-6, 6), randf_range(2, 8), 0), Color("bff3ff") if not gore_on or k % 2 == 0 else flesh, randf_range(0.1, 0.3), floor_y)
            lv.visible = false
            spark_burst(center, Color("e0f7ff"), 90, 10.0, 0.12)
            await _wait(0.4)
            return true
        "zip":
            # Light wall: Zip laps the opponent faster than the eye, the sonic boom follows.
            wf.pose = "Dash"
            for k in range(10):
                var sk: float = 1.0 if k % 2 == 0 else -1.0
                wf.x = lf.x + sk * 2.4
                _fade_free(_beam(Vector3(lf.x - 2.4, floor_y + 0.9, 0.45), Vector3(lf.x + 2.4, floor_y + 1.1, 0.45), Color("93c5fd"), 0.1), 0.2)
                lf.pose = "HitReact"
                sound("hit")
                await _wait(0.06)
            wf.x = lf.x - side * 3.0
            wf.pose = "Idle"
            await _wait(0.4)
            shock_ring(center, Color("3b82f6"), 9.0)
            flash_screen(Color("dbeafe"), 0.6)
            camera_shake = 1.3
            sound("electric")
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 90, 9.0)
                blood_pool(lf.x, floor_y, 2.0)
            lv.visible = false
            spark_burst(center, Color("93c5fd"), 90, 11.0, 0.12)
            return true
        "templar":
            # Dragon judgment: the greatsword falls from above, a cross of fire burns the ground.
            wf.pose = "Rise"
            _tween_dict(wf, "y", floor_y + 4.0, 0.5)
            await _wait(0.55)
            wf.x = lf.x
            wf.pose = "Slam"
            _tween_dict(wf, "y", floor_y, 0.15)
            await _wait(0.16)
            flash_screen(Color("ffcf8a"), 0.7)
            camera_shake = 1.6
            sound("lava")
            lf.pose = "HitReact"
            _fade_free(_beam(Vector3(lf.x - 4.0, floor_y + 0.1, 0.3), Vector3(lf.x + 4.0, floor_y + 0.1, 0.3), Color("ff5a1f"), 0.4), 0.9)
            _fade_free(_beam(Vector3(lf.x, floor_y, 0.3), Vector3(lf.x, floor_y + 8.0, 0.3), Color("ffb347"), 0.5), 0.9)
            for k in range(6):
                erupt_pillar(Vector3(lf.x + (k - 2.5) * 0.9, floor_y, 0.3), Color("ff5a1f"), false)
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 100, 9.0)
                blood_pool(lf.x, floor_y, 2.6)
                screen_blood(0.6)
            lv.visible = false
            spark_burst(center, Color("ff8a3d"), 110, 12.0, 0.14)
            await _wait(0.5)
            return true
        "pyrax":
            # Glutsturz: she climbs into the sky, folds her wings and falls as a comet of fire.
            wf.pose = "Rise"
            _tween_dict(wf, "y", floor_y + 6.0, 0.6)
            sound("lava")
            await _wait(0.65)
            wf.x = lf.x
            wf.pose = "Slam"
            _fade_free(_beam(Vector3(lf.x, floor_y + 6.0, 0.3), Vector3(lf.x, floor_y, 0.3), Color("ff6610"), 0.8), 0.6)
            _tween_dict(wf, "y", floor_y, 0.14)
            await _wait(0.15)
            flash_screen(Color("ffb347"), 0.8)
            camera_shake = 1.6
            lf.pose = "HitReact"
            shock_ring(Vector3(lf.x, floor_y + 0.1, 0.3), Color("ff6610"), 7.0)
            for k in range(8):
                erupt_pillar(Vector3(lf.x + (k - 3.5) * 0.8, floor_y, 0.3), Color("ff6610"), false)
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 70, 8.0)
                screen_blood(0.4)
            lv.visible = false
            spark_burst(center, Color(0.15, 0.1, 0.08), 90, 8.0, 0.12)
            spark_burst(center, Color("ff8a3d"), 80, 11.0, 0.12)
            wf.pose = "Roar"
            await _wait(0.6)
            return true
        "phoenix":
            # The ninth ash: Scarlet becomes a firebird, swallows the opponent and rises from the ashes.
            wf.pose = "Summon"
            announce("NEUNTE ASCHE", Color("ff8a1f"), 0.45)
            sound("lava")
            await _wait(0.4)
            wf.x = lf.x - side * 0.3
            flash_screen(Color("ff8a1f"), 0.6)
            for k in range(5):
                _fade_free(_beam(Vector3(lf.x - 2.0 + k, floor_y, 0.3), Vector3(lf.x, floor_y + 7.0, 0.3), Color("ffb347"), 0.35), 0.7)
            spark_burst(center, Color("ff8a1f"), 120, 10.0, 0.14)
            lf.pose = "HitReact"
            camera_shake = 1.2
            await _wait(0.3)
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 50, 6.0)
            lv.visible = false
            spark_burst(center, Color(0.2, 0.15, 0.12), 80, 5.0, 0.12)
            wf.x = lf.x - side * 1.6
            wf.pose = "Rise"
            shock_ring(Vector3(wf.x, floor_y + 0.2, 0.3), Color("fff3b0"), 4.0)
            _fade_free(_beam(Vector3(wf.x, floor_y, 0.3), Vector3(wf.x, floor_y + 9.0, 0.3), Color("fde68a"), 0.6), 0.8)
            await _wait(0.6)
            return true
        "pyrus":
            # Sternenfall: Pyrus raises his staff and the sky falls, one meteor after another.
            wf.pose = "Summon"
            announce("STERNENFALL!", Color("ff7a1a"), 0.4)
            await _wait(0.45)
            for k in range(5):
                var mx: float = lf.x + randf_range(-1.2, 1.2) if k < 4 else lf.x
                _fade_free(_beam(Vector3(mx + 3.0, floor_y + 12.0, 0.3), Vector3(mx, floor_y, 0.3), Color("ff7a1a"), 0.35 + k * 0.08), 0.5)
                shock_ring(Vector3(mx, floor_y + 0.1, 0.3), Color("ffb347"), 2.5 + k * 0.6)
                spark_burst(Vector3(mx, floor_y + 0.4, 0.3), Color("ff7a1a"), 30, 8.0, 0.1)
                camera_shake = 0.6 + k * 0.25
                lf.pose = "HitReact"
                sound("lava")
                await _wait(0.18)
            flash_screen(Color("fff1c1"), 0.9)
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 80, 9.0)
                blood_pool(lf.x, floor_y, 2.2)
                screen_blood(0.5)
            lv.visible = false
            spark_burst(center, Color("ff8a3d"), 100, 12.0, 0.14)
            wf.pose = "Victory"
            await _wait(0.6)
            return true
        "don_valente":
            # The last offer: a gold coin flips, the bodyguards answer from both sides.
            wf.pose = "Idle"
            announce("EIN LETZTES ANGEBOT …", Color("facc15"), 0.5)
            spark_burst(Vector3(wf.x, wf.y + 2.2, 0.4), Color("facc15"), 12, 2.0, 0.1)
            await _wait(0.8)
            announce("ABGELEHNT.", Color("facc15"), 0.4)
            await _wait(0.3)
            for k in range(10):
                var sx: float = -1.0 if k % 2 == 0 else 1.0
                var from := Vector3(lf.x + sx * 7.0, floor_y + randf_range(0.8, 2.2), 0.35)
                _fade_free(_beam(from, center + Vector3(0, randf_range(-0.4, 0.4), 0.1), Color("fde68a"), 0.06), 0.15)
                spark_burst(center, Color("facc15"), 8, 5.0, 0.06)
                lf.pose = "HitReact"
                if gore_on and k % 2 == 0: blood_spray(center, Vector3(-sx, 0.3, 0), 18, 6.0)
                sound("hit")
                await _wait(0.07)
            camera_shake = 1.0
            if gore_on:
                blood_pool(lf.x, floor_y, 2.4)
                screen_blood(0.4)
                lf.pose = "Defeat"
            else:
                lv.visible = false
                spark_burst(center, Color("facc15"), 90, 9.0, 0.1)
            wf.pose = "Victory"
            await _wait(0.6)
            return true
        "specter":
            # No reflection: the world goes dark, the void lance passes through, the body shatters like a mirror.
            flash_screen(Color(0.02, 0.0, 0.06), 0.9)
            wf.pose = "Dash"
            await _wait(0.35)
            wf.x = lf.x + side * 2.0
            wf.facing = -int(side)
            _fade_free(_beam(center + Vector3(-side * 3.0, 0, 0.1), center + Vector3(side * 3.0, 0, 0.1), Color("9b30ff"), 0.25), 0.6)
            lf.pose = "Dazed"
            sound("slash")
            await _wait(0.5)
            flash_screen(Color("e9d5ff"), 0.7)
            camera_shake = 1.2
            sound("block")
            if gore_on:
                blood_spray(center, Vector3(0, 0.5, 0), 60, 7.0)
                screen_blood(0.3)
            lv.visible = false
            spark_burst(center, Color("c4b5fd"), 120, 9.0, 0.11)
            spark_burst(center, Color("9b30ff"), 50, 5.0, 0.15)
            wf.pose = "Idle"
            await _wait(0.6)
            return true
        "shira":
            # Nine lives: nine claw strikes from nine directions, faster than the eye.
            sound("slash")
            for k in range(9):
                var ang: float = TAU * k / 9.0
                wf.x = lf.x + cos(ang) * 1.3
                wf.facing = -1 if cos(ang) > 0.0 else 1
                wf.pose = "Attack" if k % 2 == 0 else "Kick"
                _fade_free(_beam(center + Vector3(cos(ang) * 1.4, sin(ang) * 1.0, 0.1), center - Vector3(cos(ang) * 1.4, sin(ang) * 1.0, -0.1), Color("f472b6"), 0.06), 0.25)
                spark_burst(center, Color("f9a8d4"), 10, 6.0, 0.07)
                lf.pose = "HitReact"
                if gore_on and k % 3 == 0: blood_spray(center, Vector3(cos(ang), 0.3, 0), 16, 5.0)
                sound("hit")
                await _wait(0.08)
            wf.x = lf.x - side * 1.8
            wf.facing = int(side)
            wf.pose = "Idle"
            announce("NEUN LEBEN", Color("f472b6"), 0.4)
            await _wait(0.4)
            camera_shake = 1.0
            if gore_on:
                blood_pool(lf.x, floor_y, 2.0)
                screen_blood(0.4)
                lf.pose = "Defeat"
            else:
                lv.visible = false
                spark_burst(center, Color("f472b6"), 80, 9.0, 0.1)
            await _wait(0.4)
            return true
        "reaper_hound":
            # The last way home: the hound howls, pounces and drags the opponent into the dark below.
            wf.pose = "Roar"
            announce("AUUUUH!", Color("d6d3d1"), 0.35)
            sound("electric")
            await _wait(0.5)
            wf.pose = "Dash"
            _tween_dict(wf, "x", lf.x - side * 0.4, 0.15)
            await _wait(0.16)
            lf.pose = "HitReact"
            camera_shake = 0.9
            sound("hit")
            if gore_on: blood_spray(center, Vector3(side, 0.4, 0), 40, 6.0)
            shock_ring(Vector3(lf.x, floor_y + 0.05, 0.3), Color(0.05, 0.05, 0.08), 3.5)
            spark_burst(Vector3(lf.x, floor_y + 0.2, 0.3), Color(0.08, 0.08, 0.1), 60, 4.0, 0.14)
            _tween_dict(lf, "y", floor_y - 3.0, 0.7)
            _tween_dict(wf, "y", floor_y - 3.0, 0.7)
            await _wait(0.75)
            lv.visible = false
            views[winner].visible = false
            flash_screen(Color(0.0, 0.0, 0.0), 0.6)
            await _wait(0.4)
            wf.y = floor_y
            wf.x = lf.x - side * 1.5
            views[winner].visible = true
            wf.pose = "Idle"
            spark_burst(Vector3(wf.x, floor_y + 0.4, 0.3), Color("d6d3d1"), 30, 4.0, 0.08)
            await _wait(0.5)
            return true
        "anubis":
            # Weighing of the heart: golden scales appear, the heart is lighter than a feather - or not.
            wf.pose = "Summon"
            announce("WÄGUNG DES HERZENS", Color("c9a227"), 0.5)
            var scale_c := Vector3(lf.x, floor_y + 3.4, 0.3)
            _fade_free(_beam(scale_c + Vector3(-1.4, 0, 0), scale_c + Vector3(1.4, 0, 0), Color("facc15"), 0.12), 1.4)
            _fade_free(_beam(scale_c, scale_c + Vector3(0, 1.0, 0), Color("facc15"), 0.12), 1.4)
            spark_burst(scale_c + Vector3(-1.4, -0.3, 0), Color("fde68a"), 10, 1.5, 0.08)
            spark_burst(scale_c + Vector3(1.4, -0.3, 0), Color("ef4444"), 10, 1.5, 0.08)
            lf.pose = "Dazed"
            await _wait(0.9)
            announce("ZU SCHWER.", Color("ef4444"), 0.4)
            flash_screen(Color(0.05, 0.03, 0.0), 0.7)
            wf.pose = "Dash"
            wf.x = lf.x + side * 1.4
            for k in range(2):
                _fade_free(_beam(center + Vector3(-1.2, 0.8 - k * 1.6, 0.1), center + Vector3(1.2, -0.8 + k * 1.6, 0.1), Color("facc15"), 0.1), 0.3)
                sound("slash")
                await _wait(0.12)
            camera_shake = 1.0
            if gore_on:
                blood_spray(center, Vector3(0, 0.6, 0), 60, 7.0)
                blood_pool(lf.x, floor_y, 2.0)
                screen_blood(0.3)
                lf.pose = "Defeat"
            else:
                lv.visible = false
                spark_burst(center, Color("c9a227"), 90, 7.0, 0.12)
            wf.pose = "Idle"
            await _wait(0.6)
            return true
        "brunhild":
            # Call of Valhalla: the horn sounds, the sky opens and her axe falls with the light.
            wf.pose = "Roar"
            announce("WALHALLS RUF", Color("ffd24a"), 0.5)
            sound("hit")
            for k in range(3):
                shock_ring(Vector3(wf.x, floor_y + 1.4, 0.3), Color("ffd24a"), 2.0 + k * 2.0)
            await _wait(0.6)
            _fade_free(_beam(Vector3(lf.x, floor_y + 14.0, 0.3), Vector3(lf.x, floor_y, 0.3), Color("fff3b0"), 1.3), 0.9)
            wf.pose = "Rise"
            _tween_dict(wf, "y", floor_y + 4.0, 0.35)
            await _wait(0.4)
            wf.x = lf.x - side * 0.6
            wf.pose = "Slam"
            _tween_dict(wf, "y", floor_y, 0.12)
            await _wait(0.13)
            flash_screen(Color("fff3b0"), 0.8)
            camera_shake = 1.6
            lf.pose = "HitReact"
            shock_ring(Vector3(lf.x, floor_y + 0.1, 0.3), Color("ffd24a"), 6.5)
            for k in range(6):
                erupt_pillar(Vector3(lf.x + (k - 2.5) * 0.9, floor_y, 0.3), Color("ffd24a"), false)
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 70, 8.0)
                screen_blood(0.4)
            lv.visible = false
            spark_burst(center, Color("fde68a"), 100, 10.0, 0.12)
            wf.pose = "Victory"
            await _wait(0.6)
            return true
        "celestial_fox":
            # Nine tails: nine foxfires circle the opponent, close in and burn to starlight.
            wf.pose = "Summon"
            announce("NEUN SCHWEIFE", Color("38bdf8"), 0.45)
            sound("electric")
            for k in range(9):
                var fa: float = TAU * k / 9.0
                var fp := center + Vector3(cos(fa) * 2.4, sin(fa) * 1.8, 0.1)
                spark_burst(fp, Color("38bdf8"), 12, 1.5, 0.1)
                _fade_free(_beam(fp, center, Color("7dd3fc"), 0.05), 0.5)
                await _wait(0.07)
            lf.pose = "Dazed"
            await _wait(0.3)
            flash_screen(Color("e0f2fe"), 0.8)
            camera_shake = 1.0
            spark_burst(center, Color("38bdf8"), 120, 9.0, 0.12)
            spark_burst(center, Color("fef3c7"), 60, 6.0, 0.08)
            if gore_on: blood_spray(center, Vector3(0, 1, 0), 40, 6.0)
            lv.visible = false
            _fade_free(_beam(center, center + Vector3(0, 10.0, 0), Color("bae6fd"), 0.4), 0.8)
            wf.pose = "Victory"
            await _wait(0.6)
            return true
        "cyborg_mech":
            # Protocol Omega: target locked, all launchers fire, the reactor overloads.
            wf.pose = "Charge"
            announce("ZIEL ERFASST", Color("22d3ee"), 0.4)
            for k in range(3):
                shock_ring(center, Color("ef4444"), 2.4 - k * 0.6)
                sound("electric")
                await _wait(0.2)
            wf.pose = "Barrage"
            for k in range(12):
                var from := Vector3(wf.x + randf_range(-0.4, 0.4), wf.y + 2.0, 0.35)
                var hit_p := center + Vector3(randf_range(-0.6, 0.6), randf_range(-0.6, 0.8), 0.1)
                _fade_free(_beam(from, hit_p, Color("22d3ee"), 0.07), 0.2)
                spark_burst(hit_p, Color("fde68a"), 10, 5.0, 0.07)
                lf.pose = "HitReact"
                if gore_on and k % 3 == 0: blood_spray(hit_p, Vector3(side, 0.4, 0), 14, 5.0)
                sound("hit")
                await _wait(0.06)
            announce("PROTOKOLL OMEGA", Color("22d3ee"), 0.4)
            flash_screen(Color("cffafe"), 0.9)
            camera_shake = 1.6
            shock_ring(Vector3(lf.x, floor_y + 0.2, 0.3), Color("22d3ee"), 7.0)
            if gore_on:
                blood_pool(lf.x, floor_y, 2.2)
                screen_blood(0.4)
            lv.visible = false
            spark_burst(center, Color("fb923c"), 110, 12.0, 0.14)
            wf.pose = "Idle"
            await _wait(0.6)
            return true
        "frostwyrm":
            # Endless winter: the wyrm breathes, the opponent freezes into a statue and bursts.
            wf.pose = "Beam"
            announce("EWIGER WINTER", Color("7dd3fc"), 0.45)
            sound("electric")
            for k in range(5):
                var mouth := Vector3(wf.x + side * 0.8, wf.y + 1.4, 0.35)
                _fade_free(_beam(mouth, center, Color("bae6fd"), 0.5 + 0.1 * (k % 2)), 0.2)
                spark_burst(center, Color("e0f2fe"), 14, 3.0, 0.08)
                await _wait(0.12)
            lf.pose = "Dazed"
            flash_screen(Color("e0f2fe"), 0.6)
            for k in range(6):
                erupt_pillar(Vector3(lf.x + (k - 2.5) * 0.4, floor_y, 0.3), Color("9be7ff"), false)
            await _wait(0.6)
            wf.pose = "Slam"
            sound("block")
            camera_shake = 1.3
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 40, 7.0)
                screen_blood(0.3)
            lv.visible = false
            spark_burst(center, Color("e0f2fe"), 120, 10.0, 0.12)
            spark_burst(center, Color("7dd3fc"), 60, 6.0, 0.16)
            wf.pose = "Roar"
            await _wait(0.6)
            return true
        "lepora":
            # Lunar eclipse: the moon goes dark, one arrow, then a hundred.
            flash_screen(Color(0.02, 0.03, 0.08), 0.9)
            announce("MONDFINSTERNIS", Color("86efac"), 0.5)
            wf.pose = "Cast"
            wf.x = lf.x - side * 5.0
            await _wait(0.5)
            _fade_free(_beam(Vector3(wf.x, wf.y + 1.3, 0.35), center, Color("86efac"), 0.08), 0.3)
            lf.pose = "HitReact"
            sound("slash")
            await _wait(0.3)
            for k in range(14):
                var ax: float = float(lf.x) + randf_range(-1.6, 1.6)
                _fade_free(_beam(Vector3(ax + 0.5, floor_y + 8.0, 0.3), Vector3(ax, floor_y + randf_range(0.0, 1.6), 0.3), Color("bbf7d0"), 0.05), 0.15)
                if k % 2 == 0: sound("hit")
                if gore_on and k % 4 == 0: blood_spray(center, Vector3(0, 0.5, 0), 12, 4.0)
                await _wait(0.04)
            camera_shake = 1.0
            if gore_on:
                blood_pool(lf.x, floor_y, 2.0)
                lf.pose = "Defeat"
            else:
                lv.visible = false
                spark_burst(center, Color("86efac"), 80, 8.0, 0.1)
            wf.pose = "Idle"
            await _wait(0.5)
            return true
        "nyx":
            # The last harvest: wings spread, the scythe falls, the soul is drawn into the blade.
            wf.pose = "Roar"
            announce("LETZTE ERNTE", Color("a855f7"), 0.45)
            flash_screen(Color(0.06, 0.0, 0.08), 0.8)
            _tween_dict(wf, "y", floor_y + 3.0, 0.4)
            await _wait(0.45)
            wf.x = lf.x - side * 1.2
            wf.pose = "Spin"
            _tween_dict(wf, "y", floor_y, 0.15)
            _fade_free(_beam(center + Vector3(-side * 1.5, 2.0, 0.1), center + Vector3(side * 1.5, -1.0, 0.1), Color("a855f7"), 0.3), 0.4)
            sound("slash")
            await _wait(0.2)
            lf.pose = "Dazed"
            camera_shake = 1.0
            if gore_on:
                blood_spray(center, Vector3(side, 0.5, 0), 60, 7.0)
                screen_blood(0.3)
            for k in range(6):
                spark_burst(center.lerp(Vector3(wf.x, wf.y + 1.2, 0.35), k / 5.0), Color("c084fc"), 10, 1.5, 0.1)
                await _wait(0.06)
            lv.visible = false
            spark_burst(Vector3(wf.x, wf.y + 1.2, 0.35), Color("a855f7"), 60, 5.0, 0.1)
            wf.pose = "Victory"
            await _wait(0.6)
            return true
        "albion":
            # Silver thunderstorm: the wyrm rises into the clouds, the storm answers his roar.
            wf.pose = "Rise"
            _tween_dict(wf, "y", floor_y + 4.5, 0.5)
            announce("SILBERGEWITTER", Color("e0f2fe"), 0.45)
            flash_screen(Color(0.05, 0.07, 0.12), 0.6)
            await _wait(0.55)
            wf.pose = "Roar"
            sound("electric")
            for k in range(6):
                var bx3: float = float(lf.x) + randf_range(-0.8, 0.8)
                _fade_free(_beam(Vector3(bx3 + randf_range(-1.0, 1.0), floor_y + 12.0, 0.3), Vector3(bx3, floor_y, 0.3), Color("e0f2fe"), 0.25), 0.25)
                flash_screen(Color("e0f2fe"), 0.25)
                lf.pose = "HitReact"
                camera_shake = 0.6 + k * 0.15
                sound("electric")
                await _wait(0.12)
            wf.pose = "Beam"
            _fade_free(_beam(Vector3(wf.x + side * 0.8, wf.y + 1.3, 0.35), center, Color("bae6fd"), 0.9), 0.6)
            await _wait(0.3)
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 60, 8.0)
                screen_blood(0.4)
            lv.visible = false
            spark_burst(center, Color("e0f2fe"), 120, 11.0, 0.12)
            _tween_dict(wf, "y", floor_y, 0.4)
            await _wait(0.5)
            wf.pose = "Victory"
            await _wait(0.3)
            return true
        "thorn_witch":
            # Rose grave: thorns grow around the opponent, a rose blooms on top.
            wf.pose = "Summon"
            announce("ROSENGRAB", Color("4ade80"), 0.45)
            sound("slash")
            for k in range(8):
                erupt_pillar(Vector3(lf.x + (k - 3.5) * 0.25, floor_y, 0.3), Color("4ade80"), false)
                lf.pose = "HitReact"
                if gore_on and k % 2 == 0: blood_spray(center, Vector3(randf_range(-1, 1), 0.5, 0), 12, 4.0)
                await _wait(0.08)
            lf.pose = "Dazed"
            await _wait(0.4)
            camera_shake = 0.8
            if gore_on:
                blood_pool(lf.x, floor_y, 1.8)
                screen_blood(0.3)
            lv.visible = false
            spark_burst(center, Color("4ade80"), 70, 5.0, 0.12)
            spark_burst(Vector3(lf.x, floor_y + 2.4, 0.35), Color("f43f5e"), 40, 2.5, 0.14)
            wf.pose = "Idle"
            await _wait(0.7)
            return true
        "treant":
            # Primeval forest: the ancient tree plants its feet, roots seize the opponent and a whole forest grows over them.
            wf.pose = "Slam"
            announce("URWALD", Color("65a30d"), 0.45)
            camera_shake = 0.8
            sound("hit")
            shock_ring(Vector3(wf.x, floor_y + 0.1, 0.3), Color("65a30d"), 4.0)
            await _wait(0.3)
            lf.pose = "Dazed"
            for k in range(10):
                erupt_pillar(Vector3(lf.x + randf_range(-1.5, 1.5), floor_y, 0.3), Color("4d7c0f"), false)
                sound("block")
                await _wait(0.07)
            _tween_dict(lf, "y", floor_y - 2.5, 0.8)
            await _wait(0.8)
            if gore_on: blood_pool(lf.x, floor_y, 2.0)
            lv.visible = false
            spark_burst(Vector3(lf.x, floor_y + 1.0, 0.35), Color("84cc16"), 90, 6.0, 0.14)
            wf.pose = "Roar"
            await _wait(0.6)
            return true
        "mossback":
            # Rockslide: the beast charges three times, the last ram buries the opponent under rubble.
            announce("BERGRUTSCH", Color("84cc16"), 0.45)
            for k in range(3):
                wf.pose = "Dash"
                wf.x = lf.x - side * 4.0 if k % 2 == 0 else lf.x + side * 4.0
                wf.facing = int(side) if k % 2 == 0 else -int(side)
                _tween_dict(wf, "x", lf.x + (side * 3.0 if k % 2 == 0 else -side * 3.0), 0.22)
                await _wait(0.12)
                lf.pose = "HitReact"
                camera_shake = 0.5 + k * 0.3
                sound("hit")
                spark_burst(center, Color("a8a29e"), 30, 6.0, 0.1)
                if gore_on: blood_spray(center, Vector3(side, 0.5, 0), 20, 6.0)
                await _wait(0.2)
            flash_screen(Color("d6d3d1"), 0.6)
            for k in range(8):
                erupt_pillar(Vector3(lf.x + (k - 3.5) * 0.35, floor_y, 0.3), Color("78716c"), false)
            camera_shake = 1.5
            if gore_on:
                blood_pool(lf.x, floor_y, 2.2)
                screen_blood(0.3)
            lv.visible = false
            spark_burst(center, Color("a8a29e"), 100, 9.0, 0.14)
            wf.pose = "Roar"
            await _wait(0.6)
            return true
        "sorceress_medea":
            # Star spell: the opponent is lifted into a constellation and goes out like a star.
            wf.pose = "Summon"
            announce("STERNENBANN", Color("c084fc"), 0.45)
            flash_screen(Color(0.03, 0.0, 0.08), 0.8)
            lf.pose = "Dazed"
            _tween_dict(lf, "y", floor_y + 2.5, 0.8)
            for k in range(7):
                var sa: float = TAU * k / 7.0
                var sp1 := Vector3(lf.x + cos(sa) * 2.0, floor_y + 3.6 + sin(sa) * 1.6, 0.3)
                var sa2: float = TAU * (k + 2) / 7.0
                var sp2 := Vector3(lf.x + cos(sa2) * 2.0, floor_y + 3.6 + sin(sa2) * 1.6, 0.3)
                spark_burst(sp1, Color("e9d5ff"), 8, 1.0, 0.1)
                _fade_free(_beam(sp1, sp2, Color("c084fc"), 0.04), 1.2)
                sound("electric")
                await _wait(0.1)
            await _wait(0.3)
            flash_screen(Color("f5f3ff"), 0.9)
            camera_shake = 1.0
            if gore_on:
                blood_spray(Vector3(lf.x, floor_y + 3.6, 0.35), Vector3(0, -1, 0), 50, 5.0)
                screen_blood(0.3)
            lv.visible = false
            spark_burst(Vector3(lf.x, floor_y + 3.6, 0.35), Color("c084fc"), 120, 8.0, 0.12)
            wf.pose = "Victory"
            await _wait(0.6)
            return true
        "skeleton_reaper":
            # Bone throne: bones rise from the floor, lock the opponent into a throne and the scythe falls.
            wf.pose = "Summon"
            announce("KNOCHENTHRON", Color("a78bfa"), 0.45)
            sound("block")
            for k in range(6):
                erupt_pillar(Vector3(lf.x + (k - 2.5) * 0.35, floor_y, 0.3), Color("e7e5e4"), true)
                await _wait(0.07)
            lf.pose = "Dazed"
            await _wait(0.3)
            wf.x = lf.x - side * 1.3
            wf.pose = "Spin"
            _fade_free(_beam(center + Vector3(-side * 1.6, 1.6, 0.1), center + Vector3(side * 1.4, -1.2, 0.1), Color("a78bfa"), 0.3), 0.4)
            sound("slash")
            flash_screen(Color("ede9fe"), 0.5)
            camera_shake = 1.1
            if gore_on:
                blood_spray(center, Vector3(side, 0.5, 0), 60, 7.0)
                blood_pool(lf.x, floor_y, 2.0)
                screen_blood(0.3)
            lv.visible = false
            spark_burst(center, Color("e7e5e4"), 90, 7.0, 0.12)
            wf.pose = "Idle"
            await _wait(0.7)
            return true
        "mutant_titan":
            # Toxic colossus: he grabs the opponent, poisons the air and smashes them into the ground.
            wf.pose = "Roar"
            announce("TOXISCHER KOLOSS", Color("84cc16"), 0.45)
            sound("lava")
            for k in range(3):
                shock_ring(Vector3(wf.x, floor_y + 1.2, 0.3), Color("84cc16"), 2.0 + k * 1.5)
                spark_burst(Vector3(wf.x, floor_y + 1.4, 0.35), Color("a3e635"), 30, 4.0, 0.14)
                await _wait(0.15)
            wf.x = lf.x - side * 0.9
            lf.pose = "HitReact"
            _tween_dict(lf, "y", floor_y + 3.0, 0.3)
            await _wait(0.35)
            wf.pose = "Slam"
            _tween_dict(lf, "y", floor_y, 0.1)
            await _wait(0.1)
            flash_screen(Color("bef264"), 0.6)
            camera_shake = 1.6
            shock_ring(Vector3(lf.x, floor_y + 0.1, 0.3), Color("84cc16"), 6.0)
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 70, 8.0)
                blood_pool(lf.x, floor_y, 2.4)
                screen_blood(0.4)
            lv.visible = false
            spark_burst(center, Color("84cc16"), 110, 10.0, 0.14)
            wf.pose = "Victory"
            await _wait(0.6)
            return true
        "swat_specops":
            # Breach: a flashbang, the room goes white, three shots in the light.
            wf.pose = "Cast"
            announce("ZUGRIFF!", Color("fb923c"), 0.4)
            spark_burst(center, Color("fef3c7"), 20, 4.0, 0.08)
            await _wait(0.4)
            flash_screen(Color(1, 1, 1), 1.0)
            sound("lava")
            lf.pose = "Dazed"
            await _wait(0.4)
            wf.pose = "Attack"
            for k in range(3):
                _fade_free(_beam(Vector3(wf.x + side * 0.6, wf.y + 1.3, 0.35), center + Vector3(0, 0.3 - k * 0.3, 0.1), Color("fde68a"), 0.05), 0.12)
                spark_burst(center, Color("fb923c"), 12, 5.0, 0.07)
                lf.pose = "HitReact"
                if gore_on: blood_spray(center, Vector3(side, 0.3, 0), 18, 6.0)
                sound("hit")
                await _wait(0.18)
            camera_shake = 0.8
            if gore_on:
                blood_pool(lf.x, floor_y, 1.8)
                lf.pose = "Defeat"
            else:
                lv.visible = false
                spark_burst(center, Color("fb923c"), 70, 8.0, 0.1)
            wf.pose = "Idle"
            await _wait(0.6)
            return true
        "vampire_lord":
            # Blood moon: the sky turns red, a swarm of bats lifts the opponent and drinks.
            flash_screen(Color(0.25, 0.0, 0.02), 0.9)
            announce("BLUTMOND", Color("dc2626"), 0.5)
            wf.pose = "Summon"
            await _wait(0.4)
            lf.pose = "HitReact"
            _tween_dict(lf, "y", floor_y + 2.0, 0.7)
            for k in range(8):
                spark_burst(center + Vector3(randf_range(-1.2, 1.2), randf_range(-0.6, 1.4), 0.1), Color(0.1, 0.02, 0.03), 10, 4.0, 0.1)
                spark_burst(center, Color("dc2626"), 6, 3.0, 0.07)
                sound("slash")
                await _wait(0.1)
            if gore_on:
                blood_spray(Vector3(lf.x, floor_y + 2.5, 0.35), Vector3(0, -1, 0), 60, 5.0)
                screen_blood(0.4)
            for k in range(5):
                spark_burst(Vector3(lf.x, floor_y + 2.5, 0.35).lerp(Vector3(wf.x, wf.y + 1.3, 0.35), k / 4.0), Color("dc2626"), 8, 1.0, 0.08)
                await _wait(0.06)
            lv.visible = false
            spark_burst(Vector3(lf.x, floor_y + 2.5, 0.35), Color(0.1, 0.02, 0.03), 80, 7.0, 0.12)
            wf.pose = "Victory"
            await _wait(0.6)
            return true
        "vanguard_soldier":
            # Photon strike: the target is painted, the satellite answers.
            wf.pose = "Summon"
            announce("PHOTONENSCHLAG", Color("fbbf24"), 0.45)
            for k in range(3):
                shock_ring(Vector3(lf.x, floor_y + 0.05, 0.3), Color("ef4444"), 2.5 - k * 0.7)
                sound("electric")
                await _wait(0.22)
            _fade_free(_beam(Vector3(lf.x, floor_y + 16.0, 0.3), Vector3(lf.x, floor_y, 0.3), Color("fde68a"), 1.8), 0.9)
            flash_screen(Color("fff7cc"), 1.0)
            camera_shake = 1.8
            lf.pose = "HitReact"
            shock_ring(Vector3(lf.x, floor_y + 0.1, 0.3), Color("fbbf24"), 8.0)
            sound("lava")
            await _wait(0.3)
            if gore_on:
                blood_pool(lf.x, floor_y, 2.4)
                screen_blood(0.4)
            lv.visible = false
            spark_burst(center, Color("fbbf24"), 120, 12.0, 0.14)
            wf.pose = "Idle"
            await _wait(0.6)
            return true
        "nekra":
            # Bone garden: the dead rise around the opponent and pull them into the earth.
            wf.pose = "Summon"
            announce("KNOCHENGARTEN", Color("e7e5e4"), 0.45)
            for k in range(8):
                erupt_pillar(Vector3(lf.x + (k - 3.5) * 0.4, floor_y, 0.3), Color("e7e5e4"), true)
                sound("block")
                await _wait(0.07)
            lf.pose = "Dazed"
            await _wait(0.3)
            _tween_dict(lf, "y", floor_y - 2.6, 0.9)
            spark_burst(Vector3(lf.x, floor_y + 0.3, 0.35), Color("a8a29e"), 60, 3.0, 0.12)
            await _wait(0.9)
            if gore_on: blood_pool(lf.x, floor_y, 1.8)
            lv.visible = false
            spark_burst(Vector3(lf.x, floor_y + 1.0, 0.35), Color("c4b5fd"), 50, 4.0, 0.1)
            wf.pose = "Idle"
            await _wait(0.6)
            return true
        "grimbolt":
            # Chain reaction: one bomb, then another, then all of them.
            wf.pose = "Cast"
            announce("KETTENREAKTION", Color("f59e0b"), 0.45)
            sound("slash")
            await _wait(0.4)
            for k in range(6):
                var bx4: float = float(lf.x) + randf_range(-1.4, 1.4)
                shock_ring(Vector3(bx4, floor_y + 0.3, 0.3), Color("f59e0b"), 1.6 + k * 0.3)
                spark_burst(Vector3(bx4, floor_y + 0.6, 0.3), Color("fb923c"), 30, 7.0, 0.1)
                lf.pose = "HitReact"
                camera_shake = 0.5 + k * 0.2
                sound("lava")
                await _wait(0.12)
            flash_screen(Color("fde68a"), 0.8)
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 70, 9.0)
                screen_blood(0.4)
            lv.visible = false
            spark_burst(center, Color(0.15, 0.12, 0.1), 90, 7.0, 0.14)
            spark_burst(center, Color("f59e0b"), 90, 12.0, 0.12)
            wf.pose = "Victory"
            await _wait(0.6)
            return true
        "echo":
            # Memory error: the opponent glitches, flickers between places and is deleted.
            announce("SPEICHERFEHLER", Color("5eead4"), 0.45)
            sound("electric")
            lf.pose = "Dazed"
            var home: float = float(lf.x)
            for k in range(8):
                lf.x = home + randf_range(-1.0, 1.0)
                lv.visible = k % 2 == 0
                spark_burst(Vector3(lf.x, floor_y + 1.0, 0.35), Color("5eead4"), 10, 3.0, 0.06)
                await _wait(0.08)
            lf.x = home
            lv.visible = true
            flash_screen(Color("ccfbf1"), 0.6)
            camera_shake = 0.8
            if gore_on: blood_spray(center, Vector3(0, 0.5, 0), 30, 5.0)
            lv.visible = false
            for k in range(4):
                spark_burst(center + Vector3(0, -0.8 + k * 0.5, 0), Color("5eead4"), 30, 4.0, 0.08)
            wf.pose = "Idle"
            await _wait(0.6)
            return true
        "kettenwart":
            # Eternal custody: chains from all sides, the cell door slams shut.
            wf.pose = "Cast"
            announce("EWIGE VERWAHRUNG", Color("a8a29e"), 0.45)
            for k in range(6):
                var ca: float = TAU * k / 6.0
                _fade_free(_beam(center + Vector3(cos(ca) * 4.0, sin(ca) * 2.5, 0.1), center, Color("a8a29e"), 0.06), 1.2)
                sound("block")
                await _wait(0.1)
            lf.pose = "Dazed"
            await _wait(0.3)
            for k in range(5):
                _fade_free(_beam(Vector3(lf.x - 1.0 + k * 0.5, floor_y + 3.0, 0.3), Vector3(lf.x - 1.0 + k * 0.5, floor_y, 0.3), Color("57534e"), 0.08), 1.0)
            camera_shake = 1.0
            sound("hit")
            await _wait(0.4)
            if gore_on: blood_pool(lf.x, floor_y, 1.6)
            lv.visible = false
            spark_burst(center, Color("78716c"), 70, 5.0, 0.12)
            wf.pose = "Idle"
            await _wait(0.6)
            return true
        "arber":
            # Flight of the Shqiponja: the eagle lifts him high, dives, both drills bore through.
            wf.eagle = 4.0
            wf.pose = "Summon"
            announce("SHQIPONJA!", Color("e41e20"), 0.4)
            sound("electric")
            _tween_dict(wf, "y", floor_y + 5.5, 0.7)
            await _wait(0.8)
            flash_screen(Color("e41e20"), 0.35)
            wf.x = lf.x - side * 0.9
            wf.pose = "Slam"
            _tween_dict(wf, "y", floor_y, 0.18)
            await _wait(0.2)
            camera_shake = 1.2
            wf.pose = "Barrage"
            lf.pose = "HitReact"
            for k in range(12):
                spark_burst(center + Vector3(randf_range(-0.3, 0.3), randf_range(-0.4, 0.4), 0.4), Color("ffb347"), 12, 6.0, 0.05)
                if gore_on and k % 3 == 0: blood_spray(center, Vector3(side, 0.3, 0), 20, 6.0)
                sound("hit")
                await _wait(0.07)
            flash_screen(Color(0.05, 0.0, 0.0), 0.5)
            shock_ring(center, Color("e41e20"), 8.0)
            _fade_free(_beam(center + Vector3(-3.0, 1.6, 0.4), center + Vector3(3.0, 1.6, 0.4), Color("e41e20"), 0.3), 0.8)
            camera_shake = 1.6
            sound("lava")
            if gore_on:
                blood_spray(center, Vector3(0, 1, 0), 110, 10.0)
                blood_pool(lf.x, floor_y, 2.4)
                screen_blood(0.6)
            lv.visible = false
            spark_burst(center, Color(0.08, 0.02, 0.02), 90, 10.0, 0.12)
            wf.pose = "Idle"
            await _wait(0.6)
            wf.eagle = 0.0
            return true
        "bruno":
            # The serious punch: one hit, the clouds split.
            wf.pose = "Charge"
            announce("…", Color("ffd23f"), 0.3)
            await _wait(0.6)
            wf.pose = "HeavyPunch"
            await _wait(0.12)
            flash_screen(Color.WHITE, 1.0)
            slow_motion(0.2, 0.4)
            camera_shake = 2.0
            sound("hit")
            shock_ring(center, Color("ffd23f"), 12.0)
            _fade_free(_beam(center, center + Vector3(side * 30.0, 6.0, 0), Color("fff7cc"), 1.6), 0.8)
            if gore_on:
                for k in range(16):
                    gib(center, Vector3(side * randf_range(8, 16), randf_range(0, 6), 0), flesh, randf_range(0.12, 0.3), floor_y)
                blood_spray(center, Vector3(side, 0.2, 0), 160, 16.0)
                screen_blood(1.0)
                lv.visible = false
            else:
                var start_x: float = lf.x
                var t := 0.0
                while t < 0.7:
                    await get_tree().process_frame
                    t += get_process_delta_time()
                    lf.x = start_x + side * 30.0 * t
                    lf.y = floor_y + 12.0 * t
                lv.visible = false
            await _wait(0.6)
            return true
    return false

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
    team_mode = TEAM_MODES[(TEAM_MODES.find(team_mode) + 1) % TEAM_MODES.size()]
    player_count = 2 if team_mode == "1v1" else 4
    var btn = selection.find_child("BtnPlayerCount", true, false)
    if btn is Button:
        btn.text = {"1v1": "👥 1 GEGEN 1", "ffa": "👥 4 SPIELER (FFA)", "2v2": "👥 TEAM 2 GEGEN 2", "3v1": "👥 TEAM 3 GEGEN 1"}[team_mode]
        btn.add_theme_color_override("font_color", {"1v1": Color("38bdf8"), "ffa": Color("c084fc"), "2v2": Color("4ade80"), "3v1": Color("fb923c")}[team_mode])
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
    _apply_p1_skin()
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
    if boss_active:
        start_boss(boss_id, boss_rush)
        return
    begin_match(p_list, mode, stock_count)
    # Finishers in versus matches with exactly two fighters left at the end.
    sim.finishers_enabled = finishers_on and not smoke
    apply_team_setup()
    _apply_loadout()

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
    last_reward_text = ""
    progression.begin_match(str(p_list[0].get("family", "")) if not p_list.is_empty() else "", mode)
    for v in views:
        if is_instance_valid(v): v.reset_gore()
    sim.finishers_enabled = false
    rebuild_fighters()
    for v in views:
        v.reset_gore()
        v.scale = Vector3.ONE
    if not active_mutators.is_empty() and adventure == null and not daily_active and not challenger_active and not boss_active and (story == null or not story.running):
        FunModes.apply(sim, views, active_mutators)
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
    if story == null or not story.running: music("boss" if boss_active else "fight")

## Announcer after the last KO: "you win/lose" against the computer, otherwise "winner" or "tie".
func _announce_result() -> void:
    if sim.result < 0: announcer("tie")
    elif sim.mode == "pve": announcer("you_win" if sim.result == 0 or sim.is_ally(0, sim.result) else "you_lose")
    else: announcer("winner")

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
    if adventure != null:
        return # no retries in the adventure: a lost wave ends the run
    if daily_active:
        start_daily()
        return
    if story != null and story.running:
        story.retry_fight()
        return
    if active or not result_panel.visible and not selection.visible:
        start_round(sim.mode)
    elif result_panel.visible:
        start_round(sim.mode)

# ── Controller navigation for menu panels ──

## The topmost menu panel the controller currently drives (null = none).
func _nav_context() -> Control:
    if title_panel != null and title_panel.visible: return title_panel
    if story != null and story.menu_panel.visible: return story.menu_panel
    if _boss_menu_open(): return boss_menu
    return null

func _nav_buttons(root: Control) -> Array:
    var out: Array = []
    for b in root.find_children("*", "Button", true, false):
        if b.is_visible_in_tree() and not b.disabled: out.append(b)
    return out

## D-pad moves the focus to the nearest button in that direction, A presses it.
func _nav_pad(b: int, root: Control) -> void:
    var dir := Vector2.ZERO
    match b:
        JOY_BUTTON_DPAD_UP: dir = Vector2.UP
        JOY_BUTTON_DPAD_DOWN: dir = Vector2.DOWN
        JOY_BUTTON_DPAD_LEFT: dir = Vector2.LEFT
        JOY_BUTTON_DPAD_RIGHT: dir = Vector2.RIGHT
        JOY_BUTTON_A:
            if nav_focus != null and is_instance_valid(nav_focus) and nav_focus.is_visible_in_tree():
                sound("start")
                nav_focus.emit_signal("pressed")
            return
        _: return
    _nav_move(root, dir)

func _nav_move(root: Control, dir: Vector2) -> void:
    var btns: Array = _nav_buttons(root)
    if btns.is_empty(): return
    if nav_focus == null or not is_instance_valid(nav_focus) or not btns.has(nav_focus):
        nav_focus = btns[0]
    else:
        var c: Vector2 = nav_focus.get_global_rect().get_center()
        var best: Button = null
        var best_score := INF
        for other in btns:
            if other == nav_focus: continue
            var d: Vector2 = other.get_global_rect().get_center() - c
            var along: float = d.dot(dir)
            if along <= 4.0: continue
            var score: float = along + absf(d.cross(dir)) * 2.5
            if score < best_score:
                best_score = score
                best = other
        if best != null: nav_focus = best
    var p: Node = nav_focus.get_parent()
    while p != null:
        if p is ScrollContainer:
            (p as ScrollContainer).ensure_control_visible(nav_focus)
            break
        p = p.get_parent()
    sound("jump")

## Keeps the focus frame on the focused button (drawn above every menu layer).
func _update_nav_frame() -> void:
    if nav_layer == null:
        nav_layer = CanvasLayer.new()
        nav_layer.layer = 90
        add_child(nav_layer)
        nav_frame = Panel.new()
        nav_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
        var st := StyleBoxFlat.new()
        st.bg_color = Color(1.0, 0.82, 0.3, 0.1)
        st.border_color = Color("fde68a")
        st.set_border_width_all(3)
        st.set_corner_radius_all(8)
        st.shadow_color = Color(1.0, 0.7, 0.2, 0.6)
        st.shadow_size = 12
        nav_frame.add_theme_stylebox_override("panel", st)
        nav_layer.add_child(nav_frame)
    var ctx: Control = _nav_context()
    if ctx == null or nav_focus == null or not is_instance_valid(nav_focus) or not nav_focus.is_visible_in_tree() or not ctx.is_ancestor_of(nav_focus):
        nav_frame.visible = false
        return
    var r: Rect2 = nav_focus.get_global_rect()
    nav_frame.visible = true
    nav_frame.position = r.position - Vector2(5, 5)
    nav_frame.size = r.size + Vector2(10, 10)

## Next arena for LB/RB in the fighter selection (classic and bought shop arenas).
func _step_arena(step: int) -> void:
    var list: Array = []
    for aid in ARENAS:
        if ARENAS[aid].get("boss", false) or not Backgrounds.arena_unlocked(progression, aid): continue
        list.append(aid)
    var k: int = wrapi(list.find(current_arena) + step, 0, list.size())
    apply_arena(list[k])
    show_status("ARENA: %s   ·   LB / RB wechseln" % ARENAS[list[k]].name, 1.6)

# ── Coins, shop arenas, start screen ──

## Shop loadout: bought weapons join the arena spawns, P1 holds the start weapon, wears the skin.
func _apply_loadout() -> void:
    sim.weapon_pool = Rewards.weapon_pool(progression, Combat.base_weapons())
    if progression.start_weapon != "" and sim.mode != "autonomous": sim.give_weapon(0, progression.start_weapon)
    _apply_p1_skin()

func _apply_p1_skin() -> void:
    if views.is_empty() or not is_instance_valid(views[0]) or views[0].profile.has("boss"): return
    if story != null and story.running: return
    var look: String = str(Rewards.skin(progression.skin).get("look", "")) if progression.skin != "" else ""
    BossModels.apply_skin(views[0].model, look)

func _register_shop_arenas() -> void:
    for bg in Backgrounds.LIST:
        ARENAS[Backgrounds.arena_id(bg)] = {
            "name": bg.name, "shop": bg.id, "sky": ARENAS["blood_moon"].sky, "thumb": null, "floor": null, "floor_em": null, "floor_norm": null,
            "sun_color": (bg.tint as Color).lightened(0.4), "sun_rot": Vector3(-40, 20, 0), "ambient_color": (bg.tint as Color).darkened(0.55),
            "fire_color": bg.trim, "exposure": Backgrounds.exposure(bg)}

## Next bought shop arena (the button in the arena row).
func _cycle_shop_arena() -> void:
    var owned: Array = []
    for bg in Backgrounds.LIST:
        if Backgrounds.is_unlocked(progression, bg.id): owned.append(Backgrounds.arena_id(bg))
    shop_arena_index = (shop_arena_index + 1) % owned.size()
    apply_arena(owned[shop_arena_index])
    show_status("★ SHOP-ARENA: %s  (%d von %d freigeschaltet – mehr im Shop)" % [ARENAS[owned[shop_arena_index]].name, owned.size(), Backgrounds.LIST.size()])

## XP and coins for a finished match (story fights included, AI-vs-AI not).
func _grant_match_rewards(result: int) -> void:
    if not progression.is_tracking(): return
    var bonus := 0
    if boss_active and result >= 0 and not sim.fighters[result].is_boss:
        bonus = 100 + 25 * maxi(0, _rush_list().find(boss_id))
    var r: Dictionary = progression.end_match(result, bonus, {"bounty": _bounty()})
    if r.is_empty(): return
    if int(r.level) > int(r.level_before):
        announce("LEVEL UP!  %d" % int(r.level), Color("fde047"), 1.2)
        flash_screen(Color("fde047"), 0.35)
    last_reward_text = "\n+%d XP  ·  +%d 🪙  ·  LEVEL %d%s" % [int(r.total), int(r.coins), int(r.level), "  ·  RANG %s!" % r.rank if r.rank_up else ""]
    last_reward_text += "\nKAMPFNOTE %s  (MÜNZEN ×%.2f)  ·  LIGA %s %+d  (%d LP)%s" % [r.grade, float(r.grade_mult), r.league, int(r.lp_change), int(r.rank_points),
        "  ·  2× XP-BOOST" if r.boosted else ""]
    for line in r.extras: last_reward_text += "\n" + str(line)
    if int(r.win_streak) >= 2: last_reward_text += "\n🔥 SIEGESSERIE %d  ·  MÜNZEN ×%.1f" % [int(r.win_streak), float(r.streak_bonus)]
    if int(r.level_coins) > 0: last_reward_text += "\n⭐ LEVEL-UP-BONUS +%d 🪙" % int(r.level_coins)
    var open_tiers: int = Rewards.path_tier(progression) - progression.path_claimed
    last_reward_text += "\n🏆 RUHMESPFAD STUFE %d · %d/%d XP%s" % [Rewards.path_tier(progression), int(progression.xp) % Rewards.PATH_XP, Rewards.PATH_XP,
        "  ·  BELOHNUNG WARTET!" if open_tiers > 0 else "  ·  nächste: " + Rewards.reward_text(Rewards.path_reward(Rewards.path_tier(progression) + 1))]
    for a in r.achievements: show_status("🏆 ERFOLG: %s – %s" % [a.title, a.text], 3.0)
    if title_info: _refresh_title_info()

## Fighter family with today's bounty.
func _bounty() -> String:
    var fams: Array = []
    for pr in mk_presets:
        if pr.id != "fusionskammer": fams.append(pr.id)
    return Rewards.bounty_family(Progression.today(), fams)

func _current_bg() -> Dictionary:
    var bg: Dictionary = Backgrounds.find(progression.menu_bg)
    if bg.is_empty() or not Backgrounds.is_unlocked(progression, bg.id): bg = Backgrounds.LIST[0]
    return bg

## Start screen: the chosen background's arena runs live behind the logo, a few house fighters
## stand in it, the camera drifts slowly. Logo and menu are real type (Russo One, Teko – OFL),
## no painted picture.
const LOGO_FONT := preload("res://assets/fonts/RussoOne-Regular.ttf")
const UI_FONT_FILE := preload("res://assets/fonts/Teko.ttf")
const LOGO_SHADER := preload("res://shaders/title_logo.gdshader")
const MENU_LABELS := {"story": "STORY", "adventure": "ABENTEUER", "versus": "VERSUS", "extras": "EXTRAS", "options": "OPTIONEN", "shop": "SHOP", "credits": "CREDITS"}
## Fighter line-ups for the start screen; the background picks one.
const TITLE_LINEUPS := [["kairo", "brunhild", "celestial_fox"], ["varakh", "nyx", "zip"], ["hikaru", "frostwyrm", "ren"],
    ["glaciem", "cyborg_mech", "amethya"], ["raiga", "treant", "shira"], ["oryn", "reaper_hound", "lepora"]]

func _teko(weight: int, spacing: int = 0) -> FontVariation:
    var fv := FontVariation.new()
    fv.base_font = UI_FONT_FILE
    fv.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
    fv.spacing_glyph = spacing
    return fv

## One logo line: white glyphs with outline and glow, colored by title_logo.gdshader.
func _logo_line(text: String, font: Font, size: int, colors: Array, glow: Color, shine_offset: float) -> Label:
    var l := Label.new()
    l.text = text
    l.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var ls := LabelSettings.new()
    ls.font = font
    ls.font_size = size
    ls.font_color = Color.WHITE
    ls.outline_size = maxi(6, size / 9)
    ls.outline_color = Color(0.02, 0.02, 0.03, 1.0)
    ls.shadow_size = maxi(10, size / 4)
    ls.shadow_color = Color(glow.r, glow.g, glow.b, 0.42)
    ls.shadow_offset = Vector2(0, 4)
    l.label_settings = ls
    var m := ShaderMaterial.new()
    m.shader = LOGO_SHADER
    m.set_shader_parameter("top_color", colors[0])
    m.set_shader_parameter("mid_color", colors[1])
    m.set_shader_parameter("bottom_color", colors[2])
    m.set_shader_parameter("shine_offset", shine_offset)
    l.material = m
    l.resized.connect(func(): _fit_logo_line(l))
    return l

## Tells the shader where the glyphs are, so the metal gradient spans exactly the letters.
func _fit_logo_line(l: Label) -> void:
    var ls: LabelSettings = l.label_settings
    var font: Font = ls.font
    var asc: float = font.get_ascent(ls.font_size)
    var cap: float = asc * 0.72
    var top: float = (l.size.y - font.get_height(ls.font_size)) * 0.5 + asc - cap
    var m: ShaderMaterial = l.material
    m.set_shader_parameter("text_top", top)
    m.set_shader_parameter("text_height", cap)
    m.set_shader_parameter("text_width", maxf(1.0, l.size.x))

func _make_logo() -> Control:
    var v := VBoxContainer.new()
    v.mouse_filter = Control.MOUSE_FILTER_IGNORE
    v.alignment = BoxContainer.ALIGNMENT_CENTER
    v.add_theme_constant_override("separation", -34)
    var chrome := [Color("ffffff"), Color("c9d3e2"), Color("3b4455")]
    var fire := [Color("fff4c2"), Color("ffb020"), Color("9a1c0c")]
    for pair in [["PROMPT", 112, chrome, Color("7dd3fc"), 0.0], ["FIGHTERS", 132, fire, Color("ff6a1a"), 0.35]]:
        var l := _logo_line(pair[0], LOGO_FONT, pair[1], pair[2], pair[3], pair[4])
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        v.add_child(l)
    # ULTIMATE between two blades.
    var row := HBoxContainer.new()
    row.mouse_filter = Control.MOUSE_FILTER_IGNORE
    row.alignment = BoxContainer.ALIGNMENT_CENTER
    row.add_theme_constant_override("separation", 18)
    v.add_child(row)
    for k in range(3):
        if k == 1:
            var u := _logo_line("ULTIMATE", _teko(600, 22), 62, [Color("ffe4e6"), Color("fb7185"), Color("881337")], Color("f43f5e"), 0.7)
            u.label_settings.outline_size = 6
            u.label_settings.shadow_size = 12
            row.add_child(u)
            continue
        var blade := TextureRect.new()
        blade.mouse_filter = Control.MOUSE_FILTER_IGNORE
        blade.custom_minimum_size = Vector2(150, 6)
        blade.size_flags_vertical = Control.SIZE_SHRINK_CENTER
        blade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        blade.stretch_mode = TextureRect.STRETCH_SCALE
        var gt := GradientTexture2D.new()
        gt.width = 256
        gt.height = 8
        var g := Gradient.new()
        g.set_color(0, Color(1, 0.45, 0.5, 0.0 if k == 0 else 1.0))
        g.set_color(1, Color(1, 0.45, 0.5, 1.0 if k == 0 else 0.0))
        gt.gradient = g
        blade.texture = gt
        row.add_child(blade)
    return v

func _menu_button(item: String, font: Font) -> Button:
    var b := Button.new()
    b.text = MENU_LABELS.get(item, item.to_upper())
    b.flat = true
    b.focus_mode = Control.FOCUS_NONE
    b.alignment = HORIZONTAL_ALIGNMENT_LEFT
    b.custom_minimum_size = Vector2(340, 58)
    b.add_theme_font_override("font", font)
    b.add_theme_font_size_override("font_size", 50)
    b.add_theme_color_override("font_color", Color(0.85, 0.88, 0.94, 0.85))
    b.add_theme_color_override("font_hover_color", Color.WHITE)
    b.add_theme_color_override("font_pressed_color", Color("fde68a"))
    b.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
    b.add_theme_constant_override("outline_size", 8)
    for st in ["normal", "hover", "pressed", "focus"]: b.add_theme_stylebox_override(st, StyleBoxEmpty.new())
    return b

func _shade_rect(fill: int, from: Vector2, to: Vector2, alpha: float) -> TextureRect:
    var r := TextureRect.new()
    r.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    r.mouse_filter = Control.MOUSE_FILTER_IGNORE
    r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    r.stretch_mode = TextureRect.STRETCH_SCALE
    var gt := GradientTexture2D.new()
    gt.fill = fill
    gt.fill_from = from
    gt.fill_to = to
    var g := Gradient.new()
    g.set_color(0, Color(0, 0, 0, 0.0))
    g.set_color(1, Color(0, 0, 0, alpha))
    gt.gradient = g
    r.texture = gt
    return r

func _build_title_screen() -> void:
    title_screen = Control.new()
    title_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root_ui.add_child(title_screen)
    # The live arena shows through; vignette and a dark band on the left keep text readable.
    title_screen.add_child(_shade_rect(GradientTexture2D.FILL_RADIAL, Vector2(0.55, 0.5), Vector2(1.25, 1.15), 0.8))
    title_screen.add_child(_shade_rect(GradientTexture2D.FILL_LINEAR, Vector2(0.42, 0), Vector2(0.0, 0), 0.72))
    title_logo = _make_logo()
    title_screen.add_child(title_logo)
    title_highlight = Panel.new()
    title_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
    title_screen.add_child(title_highlight)
    title_menu = VBoxContainer.new()
    title_menu.add_theme_constant_override("separation", 0)
    title_screen.add_child(title_menu)
    var menu_font := _teko(600, 3)
    title_hotspots.clear()
    for k in range(Backgrounds.MENU_ITEMS.size()):
        var hb := _menu_button(Backgrounds.MENU_ITEMS[k], menu_font)
        var idx := k
        hb.mouse_entered.connect(func():
            title_index = idx
            _layout_title())
        hb.pressed.connect(func(): _title_activate(idx))
        title_menu.add_child(hb)
        title_hotspots.append(hb)
    splash_cover = Panel.new()
    splash_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var sc_style := StyleBoxFlat.new()
    sc_style.bg_color = Color(1, 0.8, 0.4, 0.9)
    splash_cover.add_theme_stylebox_override("panel", sc_style)
    title_screen.add_child(splash_cover)
    splash_label = label("DRÜCKE START", 46, Color("fde68a"))
    splash_label.add_theme_font_override("font", _teko(500, 14))
    splash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    splash_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    splash_label.add_theme_color_override("font_outline_color", Color.BLACK)
    splash_label.add_theme_constant_override("outline_size", 10)
    splash_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    title_screen.add_child(splash_label)
    var splash_click := Button.new()
    splash_click.flat = true
    splash_click.name = "SplashClick"
    splash_click.focus_mode = Control.FOCUS_NONE
    splash_click.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for st in ["normal", "hover", "pressed", "focus"]: splash_click.add_theme_stylebox_override(st, StyleBoxEmpty.new())
    splash_click.pressed.connect(func(): if title_stage == "splash": _enter_main_menu())
    title_screen.add_child(splash_click)
    title_info = label("", 20, Color("fde68a"))
    title_info.add_theme_font_override("font", _teko(400, 1))
    title_info.add_theme_color_override("font_outline_color", Color.BLACK)
    title_info.add_theme_constant_override("outline_size", 6)
    title_info.position = Vector2(20, 8)
    title_screen.add_child(title_info)
    title_hint = label("↑ ↓ / Maus wählen  ·  ENTER / A bestätigen  ·  Hintergründe und Arenen im SHOP", 17, Color("cbd5e1"))
    title_hint.add_theme_font_override("font", _teko(400, 1))
    title_screen.add_child(title_hint)
    title_screen.resized.connect(_layout_title)

func _refresh_title_info() -> void:
    var lv: int = progression.level()
    var hooks := ""
    if Rewards.login_ready(progression, Progression.today()): hooks += "   ·   🎁 TAGESBELOHNUNG BEREIT (EXTRAS)"
    if Rewards.path_tier(progression) > progression.path_claimed: hooks += "   ·   🏆 RUHMESPFAD-BELOHNUNG!"
    if progression.chests > 0: hooks += "   ·   🎁 %d FREIE TRUHE(N)" % progression.chests
    if Rewards.wheel_free(progression, Progression.today()): hooks += "   ·   🎡 GRATIS-DREH"
    if not FunModes.daily_done(progression, Progression.today()): hooks += "   ·   🎯 TAGES-HERAUSFORDERUNG"
    if not progression.event.is_empty(): hooks += "   ·   %s %s" % [progression.event.icon, progression.event.name]
    if not comeback_gift.is_empty(): hooks = "   ·   🎉 WILLKOMMEN ZURÜCK! %d Tage weg: +%d 🪙 + 🎁" % [int(comeback_gift.days), int(comeback_gift.coins)] + hooks
    title_info.text = "🪙 %d   ·   LEVEL %d »%s«   ·   🏅 %s   ·   🔥 SERIE %d   ·   📚 %d %%%s" % [progression.coins, lv, Rewards.title_name(progression),
        Rewards.league_name(progression.rank_points), progression.win_streak, int(Rewards.collection(progression, Backgrounds.LIST) * 100), hooks]

## Logo at the top, menu on the left, "press start" under the logo.
func _layout_title() -> void:
    if title_screen == null: return
    var bg: Dictionary = _current_bg()
    var area: Vector2 = title_screen.size if title_screen.size.x > 10 else Vector2(1280, 720)
    var s: float = clampf(area.y / 720.0, 0.5, 2.0)
    title_logo.scale = Vector2.ONE * s * 0.82
    title_logo.size = title_logo.get_combined_minimum_size()
    var logo_w: float = title_logo.size.x * title_logo.scale.x
    var splash: bool = title_stage == "splash"
    # Centered on the splash screen, top right in the menu (the menu takes the left side).
    var logo_x: float = (area.x - logo_w) * 0.5 if splash else area.x - logo_w - 40.0 * s
    title_logo.position = Vector2(logo_x, 26.0 * s)
    title_menu.scale = Vector2.ONE * s
    title_menu.size = title_menu.get_combined_minimum_size()
    title_menu.position = Vector2(70.0 * s, area.y * 0.34)
    var trim: Color = bg.trim
    if title_index < title_hotspots.size():
        var b: Control = title_hotspots[title_index]
        title_highlight.position = title_menu.position + (b.position + Vector2(-26, 8)) * s
        title_highlight.size = Vector2(380, b.size.y - 14) * s
        for k in range(title_hotspots.size()):
            var on: bool = k == title_index
            title_hotspots[k].add_theme_color_override("font_color", Color.WHITE if on else Color(0.85, 0.88, 0.94, 0.78))
    var hs := StyleBoxFlat.new()
    hs.bg_color = Color(trim.r, trim.g, trim.b, 0.0)
    hs.border_color = trim.lightened(0.25)
    hs.border_width_left = int(6 * s)
    hs.shadow_color = Color(trim.r, trim.g, trim.b, 0.35)
    hs.shadow_size = int(14 * s)
    hs.bg_color = Color(trim.r, trim.g, trim.b, 0.18)
    title_highlight.add_theme_stylebox_override("panel", hs)
    splash_cover.visible = splash
    splash_label.visible = splash
    title_highlight.visible = not splash
    title_menu.visible = not splash
    for h in title_hotspots: h.visible = not splash
    var click: Control = title_screen.get_node_or_null("SplashClick")
    if click: click.visible = splash
    splash_label.size = Vector2(620, 70) * s
    splash_label.position = Vector2((area.x - splash_label.size.x) * 0.5, area.y * 0.78)
    splash_cover.size = Vector2(260, 3) * s
    splash_cover.position = Vector2((area.x - splash_cover.size.x) * 0.5, splash_label.position.y + splash_label.size.y)
    (splash_cover.get_theme_stylebox("panel") as StyleBoxFlat).bg_color = trim.lightened(0.2)
    title_hint.position = Vector2(20, area.y - 30)

## Live arena of the chosen background with a fighter line-up; skipped in headless runs.
func _title_scene_on() -> void:
    var bg: Dictionary = _current_bg()
    title_arena = "bg_" + str(bg.id)
    if not ARENAS.has(title_arena): title_arena = "blood_moon"
    if DisplayServer.get_name() == "headless": return
    if title_prev_arena == "": title_prev_arena = current_arena
    if current_arena != title_arena: apply_arena(title_arena)
    for v in views:
        if is_instance_valid(v): v.visible = false
    if selection != null and selection.visible:
        title_hid_selection = true
        selection.hide()
    _title_clear_showcase()
    var lineup: Array = TITLE_LINEUPS[absi(hash(str(bg.id))) % TITLE_LINEUPS.size()]
    for k in range(lineup.size()):
        var preset: Dictionary = {}
        for p in mk_presets:
            if str(p.id) == lineup[k]: preset = p
        if preset.is_empty(): continue
        var v = FighterView.new()
        add_child(v)
        v.setup(Prompt.interpret(str(preset.prompt), k))
        title_showcase.append(v)
    title_time = 0.0

func _title_clear_showcase() -> void:
    for v in title_showcase:
        if is_instance_valid(v): v.queue_free()
    title_showcase.clear()

func _title_scene_off() -> void:
    _title_clear_showcase()
    for v in views:
        if is_instance_valid(v): v.visible = true
    if title_hid_selection and selection != null: selection.show()
    title_hid_selection = false
    if title_prev_arena != "" and title_prev_arena != current_arena and DisplayServer.get_name() != "headless":
        apply_arena(title_prev_arena)
    title_prev_arena = ""

## Slow drift past the line-up; now and then one of them powers up.
func _title_camera(delta: float) -> void:
    title_time += delta
    var n: int = title_showcase.size()
    for k in range(n):
        var v = title_showcase[k]
        if not is_instance_valid(v): continue
        var x: float = 1.6 + (k - (n - 1) * 0.5) * 2.1
        var beat: float = fmod(title_time + k * 2.7, 8.1)
        var pose: String = "Charge" if beat > 6.6 else "Idle"
        v.update_state({"x": x, "y": 0.0, "facing": -1 if k == n - 1 else 1, "pose": pose, "state": "Attack" if pose == "Charge" else "Idle", "blocking": false}, delta)
        v.position.z = -0.6 * absf(k - (n - 1) * 0.5)
    var a: float = sin(title_time * 0.11) * 0.32
    var look := Vector3(1.1, 1.55, 0.0)
    camera.position = look + Vector3(sin(a) * 6.0, 0.35 + sin(title_time * 0.17) * 0.15, cos(a) * 6.0)
    camera.look_at(look)

## stage: "splash" (press start, at launch) or "menu" (straight into the main menu).
func show_title(stage: String = "menu") -> void:
    music("menu")
    title_stage = stage
    if title_screen == null: _build_title_screen()
    _title_scene_on()
    _close_title_panel()
    _refresh_title_info()
    title_screen.show()
    menu_return_title = false
    _layout_title.call_deferred()
    if splash_tween: splash_tween.kill()
    if title_stage == "splash":
        splash_tween = create_tween().set_loops()
        splash_tween.tween_property(splash_label, "modulate:a", 0.25, 0.7)
        splash_tween.tween_property(splash_label, "modulate:a", 1.0, 0.7)

func _enter_main_menu() -> void:
    title_stage = "menu"
    if Rewards.login_ready(progression, Progression.today()) and DisplayServer.get_name() != "headless":
        _open_title_panel.call_deferred("daily")
    if splash_tween: splash_tween.kill()
    splash_label.modulate.a = 1.0
    flash_screen(_current_bg().trim, 0.25)
    sound("start")
    _layout_title()

func hide_title() -> void:
    comeback_gift = {}
    if title_screen and title_screen.visible:
        title_screen.hide()
        _title_scene_off()

func _title_activate(idx: int) -> void:
    if title_stage == "splash":
        _enter_main_menu()
        return
    sound("start")
    match Backgrounds.MENU_ITEMS[idx]:
        "story":
            hide_title()
            story.open_menu()
            menu_return_title = true
        "versus": hide_title()
        "adventure": _open_title_panel("adventure")
        "extras": _open_title_panel("extras")
        "options": _open_title_panel("options")
        "shop": _open_title_panel("shop")
        "credits": _open_title_panel("credits")

func _title_pad(b: int) -> void:
    if title_stage == "splash":
        _enter_main_menu()
        return
    if title_panel != null and title_panel.visible:
        if b == JOY_BUTTON_B or b == JOY_BUTTON_BACK: _close_title_panel()
        else: _nav_pad(b, title_panel)
        return
    if b == JOY_BUTTON_B or b == JOY_BUTTON_BACK:
        show_title("splash")
        return
    match b:
        JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_LEFT: title_index = wrapi(title_index - 1, 0, Backgrounds.MENU_ITEMS.size())
        JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_RIGHT: title_index = wrapi(title_index + 1, 0, Backgrounds.MENU_ITEMS.size())
        JOY_BUTTON_A, JOY_BUTTON_START: _title_activate(title_index)
    _layout_title()
    sound("jump")

func _close_title_panel() -> void:
    if title_panel:
        title_panel.queue_free()
        title_panel = null
    title_panel_kind = ""

func _open_title_panel(kind: String) -> void:
    _close_title_panel()
    title_panel_kind = kind
    title_panel = PanelContainer.new()
    title_panel.position = Vector2(90, 50)
    title_panel.custom_minimum_size = Vector2(1100, 620)
    title_panel.add_theme_stylebox_override("panel", panel_style(Color(0.02, 0.03, 0.05, 0.96), _current_bg().trim, 2, 12))
    title_screen.add_child(title_panel)
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", 10)
    title_panel.add_child(v)
    match kind:
        "shop": _fill_shop(v)
        "adventure": _fill_adventure(v)
        "challenge": _fill_challenge(v)
        "options": _fill_options(v)
        "credits": _fill_credits(v)
        "extras": _fill_extras(v)
        "daily": _fill_daily(v)
        "path": _fill_path(v)
        "tasks": _fill_tasks(v)
        "collection": _fill_collection(v)
        "league": _fill_league(v)
        "wheel": _fill_wheel(v)
        "titles": _fill_titles(v)
    var back := button("ZURÜCK  ·  ESC / B", Color("64748b"), _close_title_panel)
    v.add_child(back)

func _fill_shop(v: VBoxContainer) -> void:
    v.add_child(label("🛒 SHOP  ·  🪙 %d MÜNZEN  ·  🎁 %d FREIE TRUHEN" % [progression.coins, progression.chests], 22, Color("fbbf24")))
    var tabs := HBoxContainer.new()
    tabs.add_theme_constant_override("separation", 8)
    v.add_child(tabs)
    var tab_list: Array = [["backgrounds", "🖼 HINTERGRÜNDE & ARENEN"], ["weapons", "⚔ WAFFEN"], ["skins", "✨ SKINS"], ["chest", "🎁 GLÜCKSTRUHE"]]
    if premium_visible(): tab_list.append(["premium", "💎 PREMIUM"])
    for t in tab_list:
        var tab_id: String = t[0]
        var tb := button(("▶ " if shop_tab == tab_id else "") + str(t[1]), Color("fbbf24") if shop_tab == tab_id else Color("64748b"), func():
            shop_tab = tab_id
            _open_title_panel("shop"))
        tb.custom_minimum_size = Vector2(250 if tab_list.size() <= 4 else 205, 36)
        tb.add_theme_font_size_override("font_size", 13)
        tabs.add_child(tb)
    match shop_tab:
        "weapons": _fill_shop_items(v, "weapons")
        "skins": _fill_shop_items(v, "skins")
        "chest": _fill_chest(v)
        "premium":
            if premium_visible(): _fill_shop_premium(v)
            else: _fill_shop_backgrounds(v)
        _: _fill_shop_backgrounds(v)

## Real-money products: fixed price, exact contents, nothing random, everything also earnable.
func _fill_shop_premium(v: VBoxContainer) -> void:
    var note := "Feste Preise, genauer Inhalt, keine Zufallskäufe. Alles hier kannst du auch mit Münzen erspielen."
    if store.backend == "local": note = "🧪 TESTMODUS – es wird nichts berechnet. Echte Käufe laufen später über Steam bzw. Google Play."
    v.add_child(label(note, 12, Color("cbd5e1") if store.backend != "local" else Color("fde047")))
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(1060, 400)
    v.add_child(scroll)
    var list := VBoxContainer.new()
    list.add_theme_constant_override("separation", 8)
    scroll.add_child(list)
    for p in store.products():
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 14)
        list.add_child(row)
        var info := VBoxContainer.new()
        info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(info)
        info.add_child(label("💎 " + str(p.name), 16, Color("fde68a")))
        var d := label(str(p.desc), 12, Color("e2e8f0"))
        d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        d.custom_minimum_size = Vector2(760, 0)
        info.add_child(d)
        var pid: String = str(p.id)
        var owned: bool = store.owns(pid)
        var b := button("✓ GEKAUFT" if owned else store.price_text(pid), Color("22c55e") if owned else Color("f59e0b"), func(): _buy_product(pid))
        b.custom_minimum_size = Vector2(180, 44)
        b.disabled = owned
        row.add_child(b)
    var restore := button("KÄUFE WIEDERHERSTELLEN", Color("64748b"), func():
        store.restore()
        show_status("Käufe werden geprüft …", 2.0))
    v.add_child(restore)

func _buy_product(id: String) -> void:
    if store.owns(id): return
    store.buy(id)
    sound("start")

func _fill_shop_backgrounds(v: VBoxContainer) -> void:
    v.add_child(label("Jeder Hintergrund ist ein eigenes Startmenü – und schaltet seine spielbare Arena frei. Münzen gibt es für jeden Kampf, Bosse und Story-Kapitel.", 12, Color("cbd5e1")))
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(1060, 420)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    v.add_child(scroll)
    var grid := GridContainer.new()
    grid.columns = 4
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 10)
    scroll.add_child(grid)
    shop_buttons.clear()
    for bg in Backgrounds.LIST:
        var card := VBoxContainer.new()
        card.custom_minimum_size = Vector2(255, 0)
        grid.add_child(card)
        var thumb := TextureRect.new()
        thumb.custom_minimum_size = Vector2(255, 140)
        thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
        thumb.texture = load(Backgrounds.thumb_path(bg))
        card.add_child(thumb)
        var owned: bool = Backgrounds.is_unlocked(progression, bg.id)
        var active_bg: bool = _current_bg().id == bg.id
        if not owned: thumb.modulate = Color(0.45, 0.45, 0.5)
        card.add_child(label("%s  ·  ARENA ✓" % bg.name if owned else "%s  ·  + ARENA" % bg.name, 13, bg.trim))
        var text := "✓ AKTIV" if active_bg else ("ALS STARTMENÜ" if owned else "🔒 KAUFEN  ·  🪙 %d" % int(bg.price))
        var id: String = bg.id
        var b := button(text, bg.trim if owned else Color("fbbf24"), func(): _shop_press(id))
        b.custom_minimum_size.y = 34
        b.add_theme_font_size_override("font_size", 13)
        if not owned and progression.coins < int(bg.price): b.modulate = Color(0.6, 0.6, 0.6)
        card.add_child(b)
        shop_buttons.append(b)
    _highlight_shop()

## Weapons and skins: cards with rarity, price and buy / equip.
func _fill_shop_items(v: VBoxContainer, kind: String) -> void:
    var weapons: bool = kind == "weapons"
    v.add_child(label("Gekaufte Waffen erscheinen in jeder Arena. Eine davon hältst du als STARTWAFFE zu Beginn jedes Kampfes." if weapons
        else "Skins verwandeln deinen Kämpfer (Spieler 1) – jeder Kämpfer, jede Arena. Pfad-Skins gibt es nur im Ruhmespfad.", 12, Color("cbd5e1")))
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(1060, 420)
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    v.add_child(scroll)
    var grid := GridContainer.new()
    grid.columns = 4
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 10)
    scroll.add_child(grid)
    for item in (Rewards.WEAPONS if weapons else Rewards.SKINS):
        var rar: Array = Rewards.RARITY[item.rarity]
        var card := PanelContainer.new()
        card.custom_minimum_size = Vector2(255, 150)
        card.add_theme_stylebox_override("panel", panel_style(Color(0.04, 0.05, 0.08, 0.95), rar[1], 2, 8))
        grid.add_child(card)
        var cv := VBoxContainer.new()
        card.add_child(cv)
        var owned: bool = Rewards.owns_weapon(progression, item.id) if weapons else Rewards.owns_skin(progression, item.id)
        var equipped: bool = (progression.start_weapon == item.id) if weapons else (progression.skin == item.id)
        cv.add_child(label(("⚔ " if weapons else "✨ ") + str(item.name), 16, rar[1]))
        cv.add_child(label(str(rar[0]) + ("  ·  " + str(item.info) if weapons else ""), 11, Color("cbd5e1")))
        if not weapons:
            var sw := ColorRect.new()
            sw.custom_minimum_size = Vector2(230, 26)
            sw.color = {"gold": Color("d4a93a"), "silver": Color("cbd5e1"), "marble": Color("f1ede4"), "emerald": Color("34d399"), "frost": Color("bae6fd"),
                "obsidian": Color("3b1d1a"), "neon": Color("f0abfc"), "shadow": Color("1e1b2e"), "lava": Color("f97316"), "crystal": Color("67e8f9"),
                "ghost": Color("e2e8f0"), "galaxy": Color("312e81"), "celestial": Color("fde68a"), "infernal": Color("b91c1c")}.get(item.look, Color.GRAY)
            cv.add_child(sw)
        var id: String = item.id
        var text: String
        if equipped: text = "✓ AUSGERÜSTET (ablegen)"
        elif owned: text = "ALS STARTWAFFE" if weapons else "ANLEGEN"
        elif item.has("path"): text = "🏆 RUHMESPFAD STUFE %d" % int(item.path)
        else: text = "🔒 KAUFEN  ·  🪙 %d" % int(item.price)
        var b := button(text, rar[1], func(): _shop_item_press(kind, id))
        b.custom_minimum_size.y = 34
        b.add_theme_font_size_override("font_size", 13)
        if not owned and (item.has("path") or progression.coins < int(item.price)): b.modulate = Color(0.6, 0.6, 0.6)
        cv.add_child(b)

func _shop_item_press(kind: String, id: String) -> void:
    var weapons: bool = kind == "weapons"
    var owned: bool = Rewards.owns_weapon(progression, id) if weapons else Rewards.owns_skin(progression, id)
    if owned:
        if weapons: Rewards.equip_weapon(progression, "" if progression.start_weapon == id else id)
        else: Rewards.equip_skin(progression, "" if progression.skin == id else id)
        sound("jump")
        _apply_p1_skin()
    elif (Rewards.buy_weapon(progression, id) if weapons else Rewards.buy_skin(progression, id)):
        sound("victory")
        flash_screen(Color("fbbf24"), 0.35)
        if weapons: Rewards.equip_weapon(progression, id)
        else: Rewards.equip_skin(progression, id)
        show_status("🎉 FREIGESCHALTET UND AUSGERÜSTET!", 2.0)
        _apply_p1_skin()
    else:
        sound("block")
        show_status("🔒 Nicht genug Münzen – oder nur im Ruhmespfad erhältlich.", 2.0)
    _open_title_panel("shop")

func _fill_chest(v: VBoxContainer) -> void:
    v.add_child(label("Die Glückstruhe enthält Münzen, Skins, Waffen oder sogar Hintergründe. Doppelte Gegenstände werden zu Münzen.", 12, Color("cbd5e1")))
    v.add_child(label("🎁  GLÜCKSTRUHE", 40, Color("fbbf24")))
    v.add_child(label("Chancen: 50 % Münzen · 25 % Skin · 17 % Waffe · 8 % Hintergrund", 14, Color("e2e8f0")))
    var free_text := "🎁 KOSTENLOS ÖFFNEN (%d übrig)" % progression.chests if progression.chests > 0 else "🎁 ÖFFNEN  ·  🪙 %d" % Rewards.CHEST_PRICE
    var ob := button(free_text, Color("fbbf24"), _open_chest)
    ob.custom_minimum_size = Vector2(520, 70)
    ob.add_theme_font_size_override("font_size", 22)
    v.add_child(ob)
    var res := label(chest_result, 26, Color("fde68a"))
    res.name = "ChestResult"
    v.add_child(res)
    var boost := button("⚡ XP-BOOSTER: 2× XP für 3 Kämpfe  ·  🪙 %d   (aktiv: %d)" % [Rewards.BOOST_PRICE, progression.boost_matches], Color("38bdf8"), func():
        if Rewards.buy_boost(progression):
            sound("victory")
            show_status("⚡ XP-BOOSTER AKTIV: 2× XP für %d Kämpfe" % progression.boost_matches, 2.0)
        else: sound("block")
        _open_title_panel("shop"))
    boost.custom_minimum_size.y = 46
    v.add_child(boost)
    v.add_child(label("Freie Truhen: Tag 7 im Login-Kalender, jede 5. Stufe, Ruhmespfad.", 12, Color("94a3b8")))

func _open_chest() -> void:
    var r: Dictionary = Rewards.open_chest(progression, chest_rng, Backgrounds.LIST)
    if r.is_empty():
        sound("block")
        show_status("🔒 Nicht genug Münzen für die Glückstruhe.", 2.0)
        return
    # Short reveal: names flicker past, then the prize.
    var res: Label = title_panel.find_child("ChestResult", true, false)
    var names: Array = ["120 🪙", "SKIN GALAXIE", "WAFFE DONNERHAMMER", "400 🪙", "SKIN NEONPULS", "HINTERGRUND DOJO", "90 🪙"]
    for k in range(10):
        if res: res.text = "… %s …" % names[k % names.size()]
        sound("jump")
        await _wait(0.06 + k * 0.012)
    var rarity := "L" if str(r.kind) in ["skin", "weapon", "background"] else "S"
    chest_result = "✨ GEWONNEN: %s ✨" % Rewards.reward_text(r)
    flash_screen(Rewards.RARITY[rarity][1], 0.5)
    sound("victory")
    _open_title_panel("shop")

func _highlight_shop() -> void:
    for k in range(shop_buttons.size()):
        var b: Button = shop_buttons[k]
        b.add_theme_color_override("font_color", Color("ffffff") if k == shop_index else Color("cbd5e1"))
        b.scale = Vector2.ONE * (1.04 if k == shop_index else 1.0)

func _shop_press(id: String) -> void:
    var bg: Dictionary = Backgrounds.find(id)
    if Backgrounds.is_unlocked(progression, id):
        Backgrounds.select(progression, id)
        sound("jump")
        show_title()
        _open_title_panel("shop")
        return
    if Backgrounds.buy(progression, id):
        sound("victory")
        flash_screen(bg.trim, 0.4)
        show_status("🎉 %s FREIGESCHALTET – Startmenü und Arena!" % bg.name, 2.5)
        Backgrounds.select(progression, id)
        show_title()
        _open_title_panel("shop")
    else:
        sound("block")
        show_status("🔒 Nicht genug Münzen: %d von %d 🪙" % [progression.coins, int(bg.price)], 2.0)

func _fill_extras(v: VBoxContainer) -> void:
    v.add_child(label("★ EXTRAS", 24, Color("fde68a")))
    var ev: Dictionary = progression.event
    if not ev.is_empty(): v.add_child(label("%s  EVENT DER WOCHE: %s  –  %s" % [ev.icon, ev.name, ev.text], 15, Color("f472b6")))
    var ch_done: bool = FunModes.daily_done(progression, Progression.today())
    var chb := button("🎯  TAGES-HERAUSFORDERUNG" + ("  ·  ✓ GESCHAFFT · morgen neu" if ch_done else "  ·  HEUTE NOCH OFFEN!") + "  ·  🔥 %d Tage" % int(progression.challenge.get("streak", 0)), Color("fb923c"), func(): _open_title_panel("challenge"))
    chb.custom_minimum_size.y = 50
    chb.add_theme_font_size_override("font_size", 18)
    v.add_child(chb)
    var login_ready: bool = Rewards.login_ready(progression, Progression.today())
    var path_open: int = Rewards.path_tier(progression) - progression.path_claimed
    for spec in [["👁  BOSSKAMPF · HIMMEL UND HÖLLE", Color("ff5a1f"), func():
                _close_title_panel()
                hide_title()
                open_boss_menu()
                menu_return_title = true],
            ["🎁  TÄGLICHE BELOHNUNG" + ("  ·  BEREIT!" if login_ready else "  ·  morgen wieder"), Color("fbbf24"), func(): _open_title_panel("daily")],
            ["🏆  RUHMESPFAD  ·  STUFE %d / %d%s" % [Rewards.path_tier(progression), Rewards.PATH_TIERS, "  ·  %d BELOHNUNG(EN) ABHOLEN!" % path_open if path_open > 0 else ""], Color("f87171"), func(): _open_title_panel("path")],
            ["🎯  TAGESAUFGABEN & ERFOLGE", Color("4ade80"), func(): _open_title_panel("tasks")],
            ["🏅  LIGA  ·  %s  ·  %d LP" % [Rewards.league_name(progression.rank_points), progression.rank_points], Color("a78bfa"), func(): _open_title_panel("league")],
            ["🎡  GLÜCKSRAD" + ("  ·  GRATIS-DREH BEREIT!" if Rewards.wheel_free(progression, Progression.today()) else "  ·  %d 🪙 pro Dreh" % Rewards.WHEEL_PRICE), Color("f472b6"), func(): _open_title_panel("wheel")],
            ["🎖  TITEL  ·  »%s«" % Rewards.title_name(progression), Color("fde68a"), func(): _open_title_panel("titles")],
            ["📚  SAMMLUNG  ·  %d %%" % int(Rewards.collection(progression, Backgrounds.LIST) * 100), Color("38bdf8"), func(): _open_title_panel("collection")]]:
        var b := button(str(spec[0]), spec[1], spec[2])
        b.custom_minimum_size.y = 50
        b.add_theme_font_size_override("font_size", 18)
        v.add_child(b)

func _fill_daily(v: VBoxContainer) -> void:
    var day: int = Progression.today()
    var ready: bool = Rewards.login_ready(progression, day)
    v.add_child(label("🎁 TÄGLICHE BELOHNUNG", 24, Color("fbbf24")))
    v.add_child(label("Komm jeden Tag wieder! Sieben Tage am Stück – am 7. Tag gibt es zusätzlich eine Glückstruhe. Ein verpasster Tag beginnt von vorn.", 13, Color("cbd5e1")))
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 8)
    v.add_child(row)
    var last: int = int(progression.login.get("last", -1))
    var step: int = int(progression.login.get("step", 0))
    var next_step: int = (step % Rewards.LOGIN.size()) if last == day - 1 else (0 if last != day else step - 1)
    for k in range(Rewards.LOGIN.size()):
        var done: bool = (last == day and k < step) or (last == day - 1 and k < step % Rewards.LOGIN.size())
        var today: bool = ready and k == next_step
        var cell := PanelContainer.new()
        cell.custom_minimum_size = Vector2(140, 150)
        cell.add_theme_stylebox_override("panel", panel_style(Color(0.1, 0.08, 0.02, 0.95) if today else Color(0.04, 0.05, 0.08, 0.95),
            Color("fbbf24") if today else (Color("4ade80") if done else Color("334155")), 3 if today else 1, 10))
        row.add_child(cell)
        var cv := VBoxContainer.new()
        cell.add_child(cv)
        cv.add_child(label("TAG %d" % (k + 1), 18, Color("fde68a")))
        cv.add_child(label("%d 🪙" % Rewards.LOGIN[k], 22, Color("ffffff")))
        if k == Rewards.LOGIN.size() - 1: cv.add_child(label("+ 🎁 TRUHE", 14, Color("fbbf24")))
        cv.add_child(label("✓" if done else ("HEUTE" if today else ""), 20, Color("4ade80") if done else Color("fbbf24")))
    var claim := button("ABHOLEN!" if ready else "Heute schon abgeholt – bis morgen!", Color("fbbf24") if ready else Color("475569"), func():
        var r: Dictionary = Rewards.claim_login(progression, Progression.today())
        if not r.is_empty():
            sound("victory")
            flash_screen(Color("fbbf24"), 0.5)
            show_status("🎁 TAG %d: +%d 🪙%s" % [r.day, r.coins, "  + GLÜCKSTRUHE!" if r.chest else ""], 2.5)
            _refresh_title_info()
        _open_title_panel("daily"))
    claim.custom_minimum_size.y = 56
    claim.add_theme_font_size_override("font_size", 20)
    v.add_child(claim)

func _fill_path(v: VBoxContainer) -> void:
    var tier: int = Rewards.path_tier(progression)
    v.add_child(label("🏆 RUHMESPFAD  ·  STUFE %d / %d" % [tier, Rewards.PATH_TIERS], 24, Color("f87171")))
    var into: int = int(progression.xp) % Rewards.PATH_XP
    v.add_child(label("Jede Stufe braucht %d XP. Nächste Stufe: %d / %d XP.  Exklusiv: Skin HIMMELSGLANZ (Stufe 15), Skin HÖLLENFÜRST (Stufe 30)." % [Rewards.PATH_XP, into, Rewards.PATH_XP], 13, Color("cbd5e1")))
    var bar := ProgressBar.new()
    bar.custom_minimum_size = Vector2(1050, 18)
    bar.max_value = Rewards.PATH_TIERS
    bar.value = tier + float(into) / Rewards.PATH_XP
    bar.show_percentage = false
    v.add_child(bar)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(1060, 330)
    scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    v.add_child(scroll)
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 6)
    scroll.add_child(row)
    for t in range(1, Rewards.PATH_TIERS + 1):
        var r: Dictionary = Rewards.path_reward(t)
        var got: bool = t <= progression.path_claimed
        var reached: bool = t <= tier
        var special: bool = str(r.kind) in ["skin", "weapon"]
        var cell := PanelContainer.new()
        cell.custom_minimum_size = Vector2(130, 150)
        cell.add_theme_stylebox_override("panel", panel_style(Color(0.08, 0.04, 0.04, 0.95) if special else Color(0.04, 0.05, 0.08, 0.95),
            Color("4ade80") if got else (Color("fbbf24") if reached else (Color("f87171") if special else Color("334155"))), 2, 8))
        row.add_child(cell)
        var cv := VBoxContainer.new()
        cell.add_child(cv)
        cv.add_child(label("STUFE %d" % t, 14, Color("fde68a")))
        var rl := label(Rewards.reward_text(r), 13, Color("ffffff"))
        rl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        rl.custom_minimum_size.x = 110
        cv.add_child(rl)
        cv.add_child(label("✓" if got else ("ABHOLEN!" if reached else "🔒"), 16, Color("4ade80") if got else Color("fbbf24")))
    var open: int = tier - progression.path_claimed
    var claim := button("%d BELOHNUNG(EN) ABHOLEN!" % open if open > 0 else "Spiele weiter für die nächste Stufe", Color("f87171") if open > 0 else Color("475569"), func():
        var got: Array = Rewards.claim_path(progression)
        if not got.is_empty():
            sound("victory")
            flash_screen(Color("f87171"), 0.5)
            show_status("🏆 " + "  ·  ".join(got.map(func(g): return Rewards.reward_text(g))), 3.0)
            _refresh_title_info()
        _open_title_panel("path"))
    claim.custom_minimum_size.y = 50
    v.add_child(claim)

func _fill_tasks(v: VBoxContainer) -> void:
    progression.refresh_daily()
    v.add_child(label("🎯 TAGESAUFGABEN  ·  🔥 SIEGESSERIE %d  ·  📅 SPIELTAGE AM STÜCK %d" % [progression.win_streak, int(progression.streak.days)], 22, Color("4ade80")))
    for c in progression.daily.get("list", []):
        var line := "%s  %s   %d / %d   (+%d XP)" % ["✓" if c.done else "□", Progression.challenge_text(c), int(c.progress), int(c.goal), int(Progression.CHALLENGES[c.id].xp)]
        v.add_child(label(line, 17, Color("4ade80") if c.done else Color("e2e8f0")))
    v.add_child(label("Alle drei geschafft: +%d XP Bonus. Siegesserie: bis zu +50 %% Münzen." % Progression.DAILY_BONUS, 13, Color("94a3b8")))
    progression.refresh_weekly()
    v.add_child(label("📅 WOCHENAUFGABEN  (alle drei: + 🎁 TRUHE)", 20, Color("38bdf8")))
    for c in progression.weekly.get("list", []):
        v.add_child(label("%s  %s   %d / %d   (+%d 🪙)" % ["✓" if c.done else "□", Progression.weekly_text(c), int(c.progress), int(c.goal), int(Progression.WEEKLY[c.id].coins)], 16,
            Color("4ade80") if c.done else Color("e2e8f0")))
    var bounty: String = _bounty()
    var bname: String = bounty
    for pr in mk_presets: if pr.id == bounty: bname = pr.name
    v.add_child(label("💰 KOPFGELD HEUTE: %s – gewinne mit diesem Kämpfer: +150 🪙 %s   ·   ⭐ Erster Sieg des Tages: +100 🪙 %s" % [bname,
        "(kassiert)" if progression.bounty_day == Progression.today() else "", "(geschafft)" if progression.first_win_day == Progression.today() else ""], 14, Color("fbbf24")))
    v.add_child(label("🏆 ERFOLGE  ·  %d / %d  (je +100 🪙)" % [progression.achievements.size(), Progression.ACHIEVEMENTS.size()], 20, Color("fbbf24")))
    var grid := GridContainer.new()
    grid.columns = 3
    v.add_child(grid)
    for id in Progression.ACHIEVEMENTS:
        var a: Array = Progression.ACHIEVEMENTS[id]
        var have: bool = progression.achievements.has(id)
        var l := label(("🏆 " if have else "🔒 ") + str(a[0]) + " – " + str(a[1]), 12, Color("fde68a") if have else Color("64748b"))
        l.custom_minimum_size.x = 350
        grid.add_child(l)

func _fill_league(v: VBoxContainer) -> void:
    var cur: int = Rewards.league_for(progression.rank_points)
    v.add_child(label("🏅 LIGA  ·  %s  ·  %d LIGAPUNKTE" % [Rewards.LEAGUES[cur][0], progression.rank_points], 24, Rewards.LEAGUES[cur][2]))
    v.add_child(label("Sieg: +25 LP (mit Siegesserie bis +45), Niederlage: −15 LP. Jede neue Liga zahlt einmalig Münzen und Truhen.", 13, Color("cbd5e1")))
    for k in range(Rewards.LEAGUES.size() - 1, -1, -1):
        var lg: Array = Rewards.LEAGUES[k]
        var lr: Dictionary = Rewards.LEAGUE_REWARDS[k]
        var reward := "" if lr.is_empty() else "   ·   Aufstieg: %d 🪙%s" % [int(lr.get("coins", 0)), "  + %d 🎁" % int(lr.chests) if lr.has("chests") else ""]
        var mark := "▶ " if k == cur else ("✓ " if k <= progression.best_league else "🔒 ")
        v.add_child(label("%s%s  (ab %d LP)%s" % [mark, lg[0], int(lg[1]), reward], 20 if k == cur else 16, lg[2] if k <= progression.best_league else Color("64748b")))
    if cur + 1 < Rewards.LEAGUES.size():
        var bar := ProgressBar.new()
        bar.custom_minimum_size = Vector2(1050, 18)
        bar.min_value = int(Rewards.LEAGUES[cur][1])
        bar.max_value = int(Rewards.LEAGUES[cur + 1][1])
        bar.value = progression.rank_points
        v.add_child(bar)
        v.add_child(label("Noch %d LP bis %s" % [int(Rewards.LEAGUES[cur + 1][1]) - progression.rank_points, Rewards.LEAGUES[cur + 1][0]], 14, Color("e2e8f0")))

func _fill_wheel(v: VBoxContainer) -> void:
    var free: bool = Rewards.wheel_free(progression, Progression.today())
    v.add_child(label("🎡 GLÜCKSRAD", 26, Color("f472b6")))
    v.add_child(label("Jeden Tag ein Gratis-Dreh! Weitere Drehs für %d 🪙. Mit etwas Glück: der JACKPOT von 1000 Münzen." % Rewards.WHEEL_PRICE, 13, Color("cbd5e1")))
    var grid := GridContainer.new()
    grid.columns = 4
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 10)
    v.add_child(grid)
    wheel_cells.clear()
    for k in range(Rewards.WHEEL.size()):
        var cell := PanelContainer.new()
        cell.custom_minimum_size = Vector2(255, 80)
        cell.add_theme_stylebox_override("panel", panel_style(Color(0.05, 0.04, 0.08, 0.95), Color("f472b6"), 1, 10))
        var l := label(Rewards.wheel_text(Rewards.WHEEL[k]), 22, Color("fde047") if k == Rewards.WHEEL.size() - 1 else Color("ffffff"))
        l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        cell.add_child(l)
        grid.add_child(cell)
        wheel_cells.append(cell)
    var spin := button("🎡 GRATIS DREHEN!" if free else "🎡 DREHEN  ·  %d 🪙" % Rewards.WHEEL_PRICE, Color("f472b6"), _spin_wheel)
    spin.custom_minimum_size.y = 60
    spin.add_theme_font_size_override("font_size", 22)
    v.add_child(spin)
    var res := label(wheel_result, 24, Color("fde68a"))
    res.name = "WheelResult"
    v.add_child(res)

func _spin_wheel() -> void:
    if wheel_spinning: return
    var r: Dictionary = Rewards.spin_wheel(progression, chest_rng, Progression.today())
    if r.is_empty():
        sound("block")
        show_status("🔒 Nicht genug Münzen für einen weiteren Dreh.", 2.0)
        return
    wheel_spinning = true
    # The highlight runs around the wheel, slows down and stops on the prize.
    var steps: int = Rewards.WHEEL.size() * 3 + int(r.index)
    for k in range(steps + 1):
        for c in range(wheel_cells.size()):
            if is_instance_valid(wheel_cells[c]):
                wheel_cells[c].add_theme_stylebox_override("panel", panel_style(Color(0.35, 0.1, 0.25, 0.95) if c == k % wheel_cells.size() else Color(0.05, 0.04, 0.08, 0.95),
                    Color("fde047") if c == k % wheel_cells.size() else Color("f472b6"), 3 if c == k % wheel_cells.size() else 1, 10))
        sound("jump")
        await _wait(0.04 + pow(float(k) / steps, 3.0) * 0.28)
    wheel_result = "✨ %s ✨" % Rewards.wheel_text(r.reward)
    flash_screen(Color("f472b6"), 0.5)
    sound("victory")
    wheel_spinning = false
    _refresh_title_info()
    if title_panel_kind == "wheel": _open_title_panel("wheel")

func _fill_titles(v: VBoxContainer) -> void:
    v.add_child(label("🎖 TITEL  ·  AKTIV: »%s«" % Rewards.title_name(progression), 24, Color("fde68a")))
    v.add_child(label("Titel erscheinen im Hauptmenü. Freigeschaltet durch Siege, Bosse, Ligen, Story und Meisterschaft.", 13, Color("cbd5e1")))
    var grid := GridContainer.new()
    grid.columns = 3
    grid.add_theme_constant_override("h_separation", 8)
    grid.add_theme_constant_override("v_separation", 8)
    v.add_child(grid)
    for t in Rewards.TITLES:
        var have: bool = Rewards.title_unlocked(progression, t)
        var active_t: bool = progression.title == t.id
        var id: String = t.id
        var b := button(("✓ " if active_t else ("" if have else "🔒 ")) + "»%s«  (%s ≥ %d)" % [t.name, t.stat, int(t.need)], Color("fde68a") if have else Color("475569"), func():
            if Rewards.equip_title(progression, id):
                sound("jump")
                _refresh_title_info()
            else: sound("block")
            _open_title_panel("titles"))
        b.custom_minimum_size = Vector2(345, 40)
        b.add_theme_font_size_override("font_size", 13)
        grid.add_child(b)

func _fill_collection(v: VBoxContainer) -> void:
    var pct: int = int(Rewards.collection(progression, Backgrounds.LIST) * 100)
    v.add_child(label("📚 SAMMLUNG  ·  %d %%" % pct, 24, Color("38bdf8")))
    var bar := ProgressBar.new()
    bar.custom_minimum_size = Vector2(1050, 18)
    bar.value = pct
    v.add_child(bar)
    var bgs: int = Backgrounds.LIST.filter(func(b): return Backgrounds.is_unlocked(progression, b.id)).size()
    for line in ["🖼 Hintergründe & Arenen: %d / %d" % [bgs, Backgrounds.LIST.size()],
            "⚔ Waffen: %d / %d" % [progression.weapons_owned.size(), Rewards.WEAPONS.size()],
            "✨ Skins: %d / %d" % [progression.skins_owned.size(), Rewards.SKINS.size()],
            "🏆 Erfolge: %d / %d" % [progression.achievements.size(), Progression.ACHIEVEMENTS.size()],
            "⭐ Level %d · %s · %d XP insgesamt" % [progression.level(), Progression.rank_for(progression.level()), progression.xp],
            "🥊 Kämpfe %d · Siege %d · beste Combo %d" % [int(progression.stats.get("matches", 0)), int(progression.stats.get("wins", 0)), int(progression.stats.get("best_combo", 0))]]:
        v.add_child(label(line, 18, Color("e2e8f0")))

func _fill_options(v: VBoxContainer) -> void:
    v.add_child(label("⚙ OPTIONEN", 22, Color("fde68a")))
    v.add_child(label("🎪 MUTATOREN für Versus-Kämpfe (beliebig kombinierbar):", 15, Color("f472b6")))
    var mrow := HFlowContainer.new()
    mrow.add_theme_constant_override("h_separation", 6)
    mrow.add_theme_constant_override("v_separation", 6)
    v.add_child(mrow)
    for mid in FunModes.MUTATORS:
        var mu: Dictionary = FunModes.MUTATORS[mid]
        var on: bool = mid in active_mutators
        var mb := button("%s %s %s" % ["✓" if on else "  ", mu.icon, mu.name], Color("f472b6") if on else Color("475569"), func():
            if mid in active_mutators: active_mutators.erase(mid)
            else: active_mutators.append(mid)
            _open_title_panel("options"))
        mb.tooltip_text = str(mu.text)
        mrow.add_child(mb)
    for spec in [["KI-STUFE", _cycle_ai_level], ["STOCKS", _cycle_stocks], ["FINISHER / BLUT", _toggle_finishers], ["SPIELER / TEAM-MODUS", _toggle_player_count]]:
        var row_btn := button(str(spec[0]), Color("38bdf8"), func():
            spec[1].call()
            _open_title_panel("options"))
        v.add_child(row_btn)
    var state := label("KI-Stufe %d  ·  %d Stocks  ·  Finisher %s  ·  Modus %s" % [ai_level, stock_count, "an" if finishers_on else "aus", team_mode.to_upper()], 14, Color("cbd5e1"))
    v.add_child(state)
    if not Platform.is_mobile():
        var qnames := {"auto": "AUTOMATISCH", "high": "HOCH", "balanced": "AUSGEWOGEN (schnell)"}
        var q_now: String = qnames.get(str(Platform.setting("quality", "auto")), "?")
        var q_eff: String = "HOCH" if quality_setting() == "high" else "AUSGEWOGEN"
        var qb := button("GRAFIK: %s → %s" % [q_now, q_eff], Color("f472b6"), func():
            _cycle_quality()
            _open_title_panel("options"))
        v.add_child(qb)
        var fs := button("VOLLBILD AN / AUS", Color("a78bfa"), func():
            var w := get_window()
            w.mode = Window.MODE_WINDOWED if w.mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN)
        v.add_child(fs)
        var tt := button("TOUCH-STEUERUNG AUF DEM PC: %s" % ("AN" if Platform.touch_enabled() else "AUS"), Color("22c55e"), func():
            Platform.set_setting("touch_on_desktop", not bool(Platform.setting("touch_on_desktop", false)))
            if Platform.touch_enabled(): setup_touch()
            elif touch != null:
                touch.mode = "off"
                touch.get_parent().queue_free()
                touch = null
            _open_title_panel("options"))
        v.add_child(tt)
    if touch != null:
        var sz := button("TOUCH-KNÖPFE: GRÖSSE %d %%" % int(round(touch.scale_factor * 100)), Color("22c55e"), func():
            var steps := [0.8, 0.9, 1.0, 1.15, 1.3]
            var k: int = (steps.find(snappedf(touch.scale_factor, 0.05)) + 1) % steps.size()
            touch.apply_settings(steps[k], touch.opacity)
            _open_title_panel("options"))
        v.add_child(sz)
        var op := button("TOUCH-KNÖPFE: DECKKRAFT %d %%" % int(round(touch.opacity * 100)), Color("22c55e"), func():
            var steps := [0.35, 0.5, 0.6, 0.8, 1.0]
            var k: int = (steps.find(snappedf(touch.opacity, 0.05)) + 1) % steps.size()
            touch.apply_settings(touch.scale_factor, steps[k])
            _open_title_panel("options"))
        v.add_child(op)

func _fill_credits(v: VBoxContainer) -> void:
    v.add_child(label("PROMPT FIGHTERS ULTIMATE", 26, Color("fde68a")))
    for line in ["Ein Smash-Kampfspiel aus Prompts – 49 Kämpfer, 19 Bosse, zwei Storykampagnen.", "",
            "Engine: Godot 4.7 · 3D-Scans und HDRIs: Poly Haven (CC0) · Charaktere: Mixamo",
            "Musik (CC0): Cleyton Kauffman · cynicmusic · Juhani Junkala · nene · Yoiyami · Centurion_of_war · Sound & Ansager: Kenney (CC0)",
            "Ambience: Nature Ambient Pack Vol 1 by JC Sounds (CC BY 4.0) · Stimmen: Piper TTS",
            "Storymodus »Die göttliche Prüfung« frei nach Dante Alighieri", "", "Danke fürs Spielen!"]:
        v.add_child(label(line, 15, Color("e2e8f0")))

## Team layout of the current versus mode (empty = everyone for themselves).
func team_layout() -> Array:
    return {"2v2": [0, 0, 1, 1], "3v1": [0, 0, 0, 1]}.get(team_mode, [])

## Applies teams to the running match: versus team modes or heroes against the boss.
func apply_team_setup() -> void:
    if boss_active:
        var teams: Array = []
        for f in sim.fighters: teams.append(9 if f.is_boss else 0)
        sim.set_teams(teams)
        sim.time_left = 300.0
        sim.finishers_enabled = false
        return
    var layout: Array = team_layout()
    if layout.is_empty() or sim.fighters.size() != layout.size(): return
    sim.set_teams(layout)
    if team_mode == "3v1":
        # The lone fighter hits harder and is harder to launch.
        sim.fighters[3].power_mult = 1.5
        sim.fighters[3].kb_taken_mult = 0.6
    status.text = "%s  /  %s" % [ARENAS[current_arena].name, "TEAM 2 GEGEN 2" if team_mode == "2v2" else "TEAM 3 GEGEN 1"]

func winner_text() -> String:
    return _winner_line() + last_reward_text

func _winner_line() -> String:
    if sim.result < 0: return "UNENTSCHIEDEN"
    var w: Dictionary = sim.fighters[sim.result]
    if boss_active:
        return "%s TRIUMPHIERT…" % Bosses.data(boss_id).name if w.is_boss else "BOSS BEZWUNGEN!"
    if not team_layout().is_empty(): return "TEAM %s GEWINNT!" % ("A" if int(w.team) == 0 else "B")
    return "SPIELER %d GEWINNT!" % (sim.result + 1)

# ── Boss mode ──

func open_boss_menu() -> void:
    if boss_menu == null: _build_boss_menu()
    boss_menu.show()
    boss_menu_index = 0
    _highlight_boss_menu()
    sound("jump")

func _build_boss_menu() -> void:
    boss_menu = PanelContainer.new()
    boss_menu.position = Vector2(140, 40)
    boss_menu.custom_minimum_size = Vector2(1000, 640)
    boss_menu.add_theme_stylebox_override("panel", panel_style(Color(0.05, 0.02, 0.01, 0.97), Color("ff5a1f"), 2, 12))
    selection.add_child(boss_menu)
    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", 10)
    boss_menu.add_child(v)
    v.add_child(label("👁  BOSSKAMPF · HIMMELREICH UND HÖLLENREICH", 20, Color("ffb13b")))
    v.add_child(label("Deine Kämpfer (Slots 1–2, bei 4 Spielern 1–3) kämpfen gemeinsam. Mehr Helden = mehr Boss-Leben.", 12, Color("cbd5e1")))
    boss_menu_buttons.clear()
    var cols := HBoxContainer.new()
    cols.add_theme_constant_override("separation", 14)
    v.add_child(cols)
    for realm in [["✨ HIMMELREICH – DIE NEUN CHÖRE", Bosses.HEAVEN, Color("ffe08a")], ["🔥 HÖLLENREICH – DIE ZEHN FÜRSTEN", Bosses.HELL, Color("ef4444")]]:
        var col := VBoxContainer.new()
        col.add_theme_constant_override("separation", 3)
        col.custom_minimum_size.x = 470
        cols.add_child(col)
        col.add_child(label(realm[0], 14, realm[2]))
        for bid in realm[1]:
            var b: Dictionary = Bosses.data(bid)
            var bb := button("%s · %s  (%s)" % [b.name, b.title, b.vice], b.color, func(): _pick_boss(bid, false))
            bb.custom_minimum_size.y = 36
            bb.add_theme_font_size_override("font_size", 13)
            col.add_child(bb)
            boss_menu_buttons.append(bb)
        var rush := button("⚔  RUSH: ALLE HINTEREINANDER", realm[2], func(): _pick_boss(realm[1][0], true))
        rush.custom_minimum_size.y = 38
        col.add_child(rush)
        boss_menu_buttons.append(rush)
    var back := button("ZURÜCK", Color("64748b"), close_boss_menu)
    v.add_child(back)
    boss_menu_buttons.append(back)
    v.add_child(label("🎮 Steuerkreuz wählen · A starten · B zurück", 11, Color("94a3b8")))

func close_boss_menu() -> void:
    if boss_menu: boss_menu.hide()

func _boss_menu_open() -> bool:
    return boss_menu != null and boss_menu.visible

func _highlight_boss_menu() -> void:
    for k in range(boss_menu_buttons.size()):
        boss_menu_buttons[k].modulate = Color(1.25, 1.1, 0.8) if k == boss_menu_index else Color(0.8, 0.8, 0.8)

func _pick_boss(bid: String, rush: bool) -> void:
    close_boss_menu()
    if boss_needs_full_game(bid, rush):
        show_full_game_offer()
        return
    start_boss(bid, rush)

func start_boss(bid: String, rush: bool) -> void:
    if not boss_active: pre_boss_arena = current_arena
    boss_active = true
    boss_rush = rush
    boss_id = bid
    var heroes: int = 3 if player_count == 4 else 2
    var p_list: Array = []
    for pi in range(heroes):
        p_list.append(remix_profiles[pi] if (pi < remix_profiles.size() and not remix_profiles[pi].is_empty()) else Prompt.interpret(prompts[pi].text, pi))
    p_list.append(Bosses.profile(bid, heroes))
    apply_arena(Bosses.data(bid).arena)
    begin_match(p_list, "manual" if current_combat_mode == "manual" else "pve", stock_count)
    apply_team_setup()
    _apply_loadout()
    if next_boss_button: next_boss_button.hide()
    var b: Dictionary = Bosses.data(bid)
    status.text = "%s  /  BOSSKAMPF: %s" % [ARENAS[current_arena].name, b.name]
    announce("%s\n%s" % [b.name, b.title], b.color, 1.8)
    show_status(str(b.intro), 3.5)
    flash_screen(b.color, 0.5)
    sound("victory")

## Boss rush order of the current boss's realm.
func _rush_list() -> Array:
    return Bosses.HELL if Bosses.HELL.has(boss_id) else Bosses.HEAVEN

# ── Fun systems: daily challenge, challengers ──────────────────────────────────

func _fill_challenge(v: VBoxContainer) -> void:
    var day: int = Progression.today()
    var c: Dictionary = FunModes.daily_challenge(day, mk_presets)
    var done: bool = FunModes.daily_done(progression, day)
    var streak: int = int(progression.challenge.get("streak", 0))
    var next_streak: int = streak + 1 if int(progression.challenge.get("done_day", -1)) == day - 1 else 1
    if done: next_streak = streak
    var idx: int = (next_streak - 1) % FunModes.DAILY_REWARD.size()
    var reward: int = int(FunModes.DAILY_REWARD[idx] * float(progression.event.get("daily_mult", 1.0)))
    v.add_child(label("🎯 TAGES-HERAUSFORDERUNG", 26, Color("fb923c")))
    v.add_child(label("Jeden Tag ein neuer Kampf – für alle gleich. Schaffe ihn an mehreren Tagen hintereinander: Die Belohnung steigt, am 7. Tag gibt es eine Glückstruhe.", 14, Color("cbd5e1")))
    var foes: Array = c.foes.map(func(o): return str(o.name))
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 14)
    v.add_child(row)
    var pic := TextureRect.new()
    pic.texture = _portrait_tex(str(c.fighter.id))
    pic.custom_minimum_size = Vector2(150, 150)
    pic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    pic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    row.add_child(pic)
    var info := VBoxContainer.new()
    row.add_child(info)
    info.add_child(label("DEIN KÄMPFER: %s" % c.fighter.name, 22, Color("fde68a")))
    info.add_child(label("GEGNER: %s  ·  KI-Stufe %d" % [" + ".join(foes), int(c.ai)], 18, Color("f87171")))
    info.add_child(label("REGELN: %s" % FunModes.mutator_text(c.mutators), 18, Color("f472b6")))
    info.add_child(label("ZIEL: %s" % c.goal.text, 18, Color("4ade80")))
    info.add_child(label("BELOHNUNG: %d 🪙%s  ·  🔥 Serie: %d Tage (Rekord %d)" % [reward, "  + 🎁 GLÜCKSTRUHE" if idx == FunModes.DAILY_REWARD.size() - 1 else "",
        streak, int(progression.challenge.get("best_streak", 0))], 16, Color("fbbf24")))
    var days := HBoxContainer.new()
    days.add_theme_constant_override("separation", 6)
    v.add_child(days)
    for k in range(FunModes.DAILY_REWARD.size()):
        var got: bool = k < (streak % FunModes.DAILY_REWARD.size() if streak % FunModes.DAILY_REWARD.size() != 0 or streak == 0 else FunModes.DAILY_REWARD.size())
        var d := label("TAG %d\n%d 🪙%s" % [k + 1, FunModes.DAILY_REWARD[k], "\n🎁" if k == FunModes.DAILY_REWARD.size() - 1 else ""], 13, Color("4ade80") if got else Color("94a3b8"))
        d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        d.custom_minimum_size = Vector2(110, 60)
        days.add_child(d)
    if done:
        v.add_child(label("✓ Heute geschafft! Morgen wartet ein neuer Kampf.", 18, Color("4ade80")))
        v.add_child(button("TROTZDEM SPIELEN (ohne Belohnung)", Color("94a3b8"), start_daily))
    else:
        v.add_child(button("▶  HERAUSFORDERUNG ANNEHMEN", Color("fb923c"), start_daily))
    v.add_child(button("ZURÜCK", CYAN, _close_title_panel))

func start_daily() -> void:
    var day: int = Progression.today()
    daily_info = FunModes.daily_challenge(day, mk_presets)
    daily_active = true
    _close_title_panel()
    hide_title()
    var arenas: Array = []
    for aid in ARENAS:
        if not ARENAS[aid].get("boss", false) and not str(aid).begins_with("bg_"): arenas.append(aid)
    if not arenas.is_empty(): apply_arena(arenas[absi(hash("arena-%d" % day)) % arenas.size()])
    var p_list: Array = [Prompt.interpret(str(daily_info.fighter.prompt), 0)]
    for k in range(daily_info.foes.size()): p_list.append(Prompt.interpret(str(daily_info.foes[k].prompt), k + 1))
    daily_lives0 = 2
    begin_match(p_list, "pve", daily_lives0)
    if p_list.size() == 3: sim.set_teams([0, 1, 1])
    sim.ai_level = int(daily_info.ai)
    FunModes.apply(sim, views, daily_info.mutators)
    daily_time0 = sim.time_left
    status.text = "TAGES-HERAUSFORDERUNG  ·  %s  ·  %s" % [daily_info.goal.text, FunModes.mutator_text(daily_info.mutators)]
    announce("TAGES-HERAUSFORDERUNG\n%s" % daily_info.goal.text, Color("fb923c"), 1.4)

func _daily_finished() -> void:
    var used: float = daily_time0 - sim.time_left
    var lost: int = daily_lives0 - int(sim.fighters[0].lives)
    var met: bool = FunModes.goal_met(daily_info.goal, sim.result, used, lost)
    var day: int = Progression.today()
    if met and int(daily_info.get("day", -1)) == day and not FunModes.daily_done(progression, day):
        var r: Dictionary = FunModes.claim_daily(progression, day)
        result_label.text = "🎯 HERAUSFORDERUNG GESCHAFFT!\n+%d 🪙%s  ·  🔥 Serie: %d Tage%s" % [int(r.coins), "  + 🎁 GLÜCKSTRUHE" if r.chest else "", int(r.streak), last_reward_text]
        announce("GESCHAFFT!", Color("4ade80"), 0.8)
    elif met:
        result_label.text = "🎯 Geschafft! (Belohnung gibt es nur einmal am Tag)%s" % last_reward_text
    else:
        result_label.text = "🎯 Nicht geschafft: %s\nREVANCHE versucht es nochmal – heute ist noch Zeit!%s" % [daily_info.goal.text, last_reward_text]

## After a won solo fight a surprise challenger may step in; beating them pays extra.
func _challenger_after_match() -> void:
    if challenger_active:
        challenger_active = false
        if sim.result == 0:
            var coins := 150
            var chest: bool = randf() < 0.25
            progression.coins += coins
            if chest: progression.chests += 1
            progression.save_progress()
            result_label.text = "⚔ HERAUSFORDERER BESIEGT!\n+%d 🪙%s\n%s" % [coins, "  + 🎁 GLÜCKSTRUHE" if chest else "", result_label.text]
        return
    if sim.mode != "pve" or sim.result != 0 or boss_active or player_count != 2 or smoke: return
    if randf() >= FunModes.challenger_chance(Progression.today()): return
    challenger_pending = true
    result_label.text += "\n\n⚔ EIN HERAUSFORDERER NÄHERT SICH!"
    get_tree().create_timer(2.6, true, false, true).timeout.connect(_start_challenger)

func _start_challenger() -> void:
    if not challenger_pending: return
    challenger_pending = false
    var mine: String = str(sim.fighters[0].profile.get("family", ""))
    var pool: Array = mk_presets.filter(func(p): return str(p.id) != mine and str(p.id) != "fusionskammer")
    if pool.is_empty(): return
    var foe: Dictionary = pool[randi() % pool.size()]
    var me: Dictionary = sim.fighters[0].profile
    var mut: String = FunModes.MUTATORS.keys()[randi() % FunModes.MUTATORS.size()]
    challenger_active = true
    begin_match([me, Prompt.interpret(str(foe.prompt), 1)], "pve", 1)
    sim.ai_level = mini(9, ai_level + 2)
    FunModes.apply(sim, views, [mut])
    status.text = "⚔ HERAUSFORDERER: %s  ·  %s" % [foe.name, FunModes.mutator_text([mut])]
    announce("HERAUSFORDERER!\n%s" % foe.name, Color("f87171"), 1.4)
    flash_screen(Color("f87171"), 0.4)

# ── Adventure ──────────────────────────────────────────────────────────────────

func _portrait_tex(id: String) -> Texture2D:
    var p := "res://assets/textures/characters/portraits/portrait_%s.png" % id
    return load(p) if ResourceLoader.exists(p) else null

## Start screen panel: pick a fighter, see the records.
func _fill_adventure(v: VBoxContainer) -> void:
    v.add_child(label("ABENTEUER  ·  ENDLOSKAMPF", 26, Color("fde68a")))
    v.add_child(label("Ein Kämpfer, endlos viele Gegner. Jede Welle wird härter, jede %d. ist ein Boss. Schaden bleibt – nur %d %% heilen nach jedem Sieg." % [Adventure.BOSS_EVERY, int(Adventure.HEAL_SHARE * 100)], 14, Color("cbd5e1")))
    var best: Dictionary = progression.adventure_best
    var top := "🏆 BESTER LAUF: " + ("noch keiner" if best.is_empty() else "%d Punkte · Welle %d · %s" % [int(best.score), int(best.wave), _preset_name(str(best.family))])
    var board: Array = Adventure.leaderboard(progression, 5)
    if not board.is_empty():
        var parts: Array = []
        for k in range(board.size()): parts.append("%d. %s %d" % [k + 1, _preset_name(board[k].family), board[k].score])
        top += "      ·      " + "   ".join(parts)
    v.add_child(label(top, 15, Color("fbbf24")))
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(1060, 470)
    v.add_child(scroll)
    var grid := GridContainer.new()
    grid.columns = 6
    grid.add_theme_constant_override("h_separation", 6)
    grid.add_theme_constant_override("v_separation", 6)
    scroll.add_child(grid)
    for preset in mk_presets:
        if str(preset.id) == "fusionskammer": continue
        var rec: Dictionary = Adventure.record_of(progression, str(preset.id))
        var b := Button.new()
        b.custom_minimum_size = Vector2(170, 64)
        var relic: bool = progression.legend_relics.has(str(preset.id))
        b.text = "%s%s\n%s" % ["👑 " if relic else "", preset.name, ("Welle %d · %d" % [int(rec.wave), int(rec.score)]) if int(rec.get("runs", 0)) > 0 else "—"]
        if relic: b.add_theme_stylebox_override("normal", panel_style(Color("2a2110"), Color("fbbf24"), 2, 8))
        b.icon = _portrait_tex(str(preset.id))
        b.expand_icon = true
        b.alignment = HORIZONTAL_ALIGNMENT_LEFT
        b.add_theme_font_size_override("font_size", 13)
        b.add_theme_constant_override("icon_max_width", 52)
        var pr: Dictionary = preset
        b.pressed.connect(func(): start_adventure(pr))
        grid.add_child(b)
    v.add_child(label("👑 = Legende vollendet (Story → Legenden): +%d %% Heilung nach jeder Welle.  Alle %d Wellen: Meilenstein mit Münzen und Truhe." % [int(Adventure.RELIC_HEAL * 100), Adventure.MILESTONE], 13, Color("fde68a")))
    v.add_child(button("ZURÜCK", CYAN, _close_title_panel))

func _preset_name(id: String) -> String:
    for p in mk_presets:
        if str(p.id) == id: return str(p.name)
    return id.to_upper()

func start_adventure(preset: Dictionary) -> void:
    adventure = Adventure.new()
    adventure.start(preset, mk_presets)
    adventure.relic = progression.legend_relics.has(str(preset.id))
    _close_title_panel()
    hide_title()
    _adventure_wave()

## Builds the next wave: an opponent (or boss) in a fresh arena, damage carried over.
func _adventure_wave() -> void:
    var adv = adventure
    adventure_combo = 0
    result_panel.hide()
    var me: Dictionary = Prompt.interpret(str(adv.preset.prompt), 0)
    var title := ""
    if adv.is_boss_wave():
        var bid: String = adv.boss_for()
        if not boss_active: pre_boss_arena = current_arena
        boss_active = true
        boss_rush = false
        boss_id = bid
        apply_arena(Bosses.data(bid).arena)
        begin_match([me, Bosses.profile(bid, 1)], "pve", 1)
        apply_team_setup()
        title = "BOSS: %s" % Bosses.data(bid).name
        _adventure_cinematic(1, ["WELLE %d" % adv.wave, str(Bosses.data(bid).name), str(Bosses.data(bid).title)], Bosses.data(bid).color)
    else:
        if boss_active:
            boss_active = false
        var opp: Dictionary = adv.next_opponent()
        var arenas: Array = []
        for aid in ARENAS:
            if not ARENAS[aid].get("boss", false) and not str(aid).begins_with("bg_"): arenas.append(aid)
        if not arenas.is_empty(): apply_arena(arenas[adv.rng.randi() % arenas.size()])
        begin_match([me, Prompt.interpret(str(opp.prompt), 1)], "pve", 1)
        sim.time_left = Adventure.WAVE_TIME
        sim.fighters[1].power_mult = adv.power_mult()
        sim.fighters[1].kb_taken_mult = adv.kb_taken_mult()
        title = "GEGNER: %s" % str(opp.name)
    sim.ai_level = adv.ai_level()
    sim.finishers_enabled = false
    sim.fighters[0].damage_percent = adv.damage
    _apply_loadout()
    status.text = "ABENTEUER  ·  WELLE %d  ·  %d PUNKTE  ·  %s" % [adv.wave, adv.score, title]
    announce("WELLE %d\n%s" % [adv.wave, title], Color("e41e20") if adv.is_boss_wave() else Color("fde68a"), 1.4)

func _adventure_finished() -> void:
    var adv = adventure
    if sim.result == 0:
        var gain: int = adv.win_wave(sim.time_left, float(sim.fighters[0].damage_percent), adventure_combo)
        result_label.text = "WELLE %d GESCHAFFT!\n+%d Punkte  ·  gesamt %d\nSchaden %d %% → %d %%%s" % [adv.wave - 1, gain, adv.score,
            int(sim.fighters[0].damage_percent), int(adv.damage), last_reward_text]
        adventure_button.text = ("BOSS ▶  WELLE %d  (A)" if adv.is_boss_wave() else "WEITER ▶  WELLE %d  (A)") % adv.wave
        sound("victory")
        var cleared: int = adv.wave - 1
        if adv.is_milestone(cleared):
            progression.coins += 250
            progression.chests += 1
            progression.save_progress()
            result_label.text += "\n🏅 MEILENSTEIN %d: +250 Münzen · Glückstruhe" % cleared
            _adventure_cinematic(0, ["MEILENSTEIN", "%d WELLEN" % cleared, str(adv.preset.name)], Color("fbbf24"))
    else:
        var best: bool = adv.finish(progression)
        _adventure_cinematic(0, ["DAS ABENTEUER ENDET", "%d WELLEN  ·  %d PUNKTE" % [adv.wave - 1, adv.score], "NEUER REKORD!" if best else str(adv.preset.name)], Color("fbbf24") if best else Color("e2e8f0"))
        result_label.text = "ABENTEUER VORBEI\nWelle %d geschafft  ·  %d Punkte%s\nRekord %s: Welle %d · %d Punkte%s" % [adv.wave - 1, adv.score,
            "\n★ NEUER REKORD! ★" if best else "", str(adv.preset.name), int(Adventure.record_of(progression, adv.family).wave),
            int(Adventure.record_of(progression, adv.family).score), last_reward_text]
        adventure_button.text = "NEUER LAUF ▶  (A)"
        if best: announce("NEUER REKORD!", Color("fbbf24"), 1.0)

## Short cinematic: the fight holds, the camera glides close to one fighter, three lines of text.
func _adventure_cinematic(who: int, lines: Array, color: Color) -> void:
    if smoke or DisplayServer.get_name() == "headless" or who >= sim.fighters.size(): return
    var was_paused: bool = paused
    paused = true
    cinematic = true
    var f: Dictionary = sim.fighters[who]
    var target := Vector3(f.x, f.y + (2.4 if f.get("is_boss", false) else 1.3), 0.0)
    var from: Vector3 = camera.position
    var t := 0.0
    for k in range(lines.size()):
        announce(str(lines[k]), color if k != 1 else Color.WHITE, 0.55)
        var end_t: float = t + 0.75
        while t < end_t:
            await get_tree().process_frame
            t += get_process_delta_time()
            var w: float = clampf(t / 1.6, 0.0, 1.0)
            w = w * w * (3.0 - 2.0 * w)
            camera.position = from.lerp(target + Vector3(0.8 * sin(t * 0.6), 0.3, 3.4), w)
            camera.look_at(target)
    cinematic = false
    paused = was_paused

func _adventure_continue() -> void:
    if adventure == null: return
    if adventure.running: _adventure_wave()
    else: start_adventure(adventure.preset)

## Leaving mid-run still counts: the waves cleared so far go into the records.
func _adventure_abandon() -> void:
    if adventure == null: return
    if adventure.running: adventure.finish(progression)
    adventure = null
    if adventure_button: adventure_button.hide()

func _adventure_quit() -> void:
    _adventure_abandon()
    active = false
    result_panel.hide()
    if boss_active:
        boss_active = false
        if pre_boss_arena != "" and pre_boss_arena != current_arena: apply_arena(pre_boss_arena)
    show_title("menu")

func next_boss() -> void:
    var list: Array = _rush_list()
    var k: int = list.find(boss_id)
    if k >= 0 and k + 1 < list.size(): start_boss(list[k + 1], true)

func _next_boss_available() -> bool:
    if not boss_active or not boss_rush or sim.result < 0 or sim.fighters[sim.result].is_boss: return false
    return _rush_list().find(boss_id) + 1 < _rush_list().size()

## Big health bar of the boss at the top of the screen.
func update_boss_bar() -> void:
    var bi: int = -1
    for k in range(sim.fighters.size()):
        if sim.fighters[k].is_boss: bi = k
    if bi < 0 or not active:
        if boss_bar: boss_bar.hide()
        return
    if boss_bar == null:
        boss_bar = Control.new()
        boss_bar.position = Vector2(290, 92)
        boss_bar.size = Vector2(700, 34)
        root_ui.add_child(boss_bar)
        var bg := ColorRect.new()
        bg.color = Color(0.05, 0.02, 0.02, 0.85)
        bg.size = Vector2(700, 20)
        bg.position = Vector2(0, 14)
        boss_bar.add_child(bg)
        boss_bar_fill = ColorRect.new()
        boss_bar_fill.position = Vector2(2, 16)
        boss_bar_fill.size = Vector2(696, 16)
        boss_bar.add_child(boss_bar_fill)
        boss_bar_label = label("", 13, Color("ffe7c2"))
        boss_bar_label.position = Vector2(0, -6)
        boss_bar.add_child(boss_bar_label)
    var f: Dictionary = sim.fighters[bi]
    var ratio: float = clampf(float(f.boss_hp) / maxf(1.0, float(f.boss_max)), 0.0, 1.0)
    boss_bar.show()
    boss_bar_fill.size.x = 696.0 * ratio
    boss_bar_fill.color = Bosses.data(f.boss_id).color.lerp(Color("ff1a1a"), 1.0 - ratio) if f.boss_phase == 1 else Color("ff1a1a")
    boss_bar_label.text = "👁 %s  ·  %d / %d%s" % [f.profile.name, int(ceil(f.boss_hp)), int(f.boss_max), "  ·  PHASE 2" if f.boss_phase == 2 else ""]

## Warning shapes before a boss attack: danger zones, rings on the floor, a glowing boss.
func boss_telegraph(ev: Dictionary) -> void:
    var col := Color(1.0, 0.15, 0.08, 0.28)
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mat.albedo_color = col
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    var node := MeshInstance3D.new()
    node.material_override = mat
    match str(ev.shape):
        "band":
            var bm := BoxMesh.new()
            bm.size = Vector3(absf(float(ev.x2) - float(ev.x1)), absf(float(ev.y2) - float(ev.y1)), 0.4)
            node.mesh = bm
            node.position = Vector3((float(ev.x1) + float(ev.x2)) * 0.5, (float(ev.y1) + float(ev.y2)) * 0.5, 0.4)
        "circle":
            var tm := TorusMesh.new()
            tm.inner_radius = maxf(0.1, float(ev.radius) - 0.15)
            tm.outer_radius = float(ev.radius)
            node.mesh = tm
            node.position = Vector3(float(ev.x1), float(ev.y1) + 0.05, 0.3)
            if float(ev.y1) > 0.5: node.rotation_degrees = Vector3(90, 0, 0)
        _:
            var sm := SphereMesh.new()
            sm.radius = 2.2
            sm.height = 4.4
            node.mesh = sm
            node.position = Vector3(float(ev.x1), (float(ev.y1) + float(ev.y2)) * 0.5, 0.0)
            mat.albedo_color = Color(1.0, 0.7, 0.3, 0.18)
    add_child(node)
    var tw := create_tween()
    tw.tween_property(mat, "albedo_color:a", 0.55, maxf(0.05, float(ev.time) * 0.85))
    tw.tween_callback(node.queue_free)
    sound("electric")

func boss_death(index: int) -> void:
    var f: Dictionary = sim.fighters[index]
    var col: Color = Bosses.data(f.boss_id).color
    var c := Vector3(f.x, f.y + float(f.body_h) * 0.5, 0.3)
    cinematic = true
    slow_motion(0.2, 1.0)
    announce("BOSS BEZWUNGEN!", Color("ffe7a8"), 1.6)
    for k in range(6):
        spark_burst(c + Vector3(randf_range(-1.5, 1.5), randf_range(-1.2, 1.5), 0), col, 50, 10.0, 0.14)
        shock_ring(c, col.lightened(0.3), 3.0 + k * 1.5)
        flash_screen(Color("fff4d6"), 0.4)
        camera_shake = 1.2
        sound("lava")
        await _wait(0.18)
    if index < views.size(): views[index].visible = false
    flash_screen(Color.WHITE, 0.9)
    cinematic = false

func show_selection() -> void:
    _adventure_abandon()
    daily_active = false
    challenger_active = false
    challenger_pending = false
    music("menu")
    if boss_active:
        boss_active = false
        if pre_boss_arena != "" and pre_boss_arena != current_arena: apply_arena(pre_boss_arena)
    close_boss_menu()
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
    if p0.has("archetype"):
        mk_p1_sub_label.text = "%s · %s · GEWICHT %.2f" % [str(p0.archetype).to_upper(), p0.element.to_upper(), p0.weight]
    else:
        mk_p1_sub_label.text = "%s · %s" % [p0.element.to_upper(), preset.prompt.left(35)]
    var stars: int = progression.stars(p0.family)
    mk_p1_stats_label.text = "HP %d · KRAFT %d · RÜSTUNG %d · TEMPO %d · TECHNIK %d   ·   %s%s" % [
        p0.stats.vitality, p0.stats.power, p0.stats.defense, p0.stats.speed, p0.stats.technique,
        "★".repeat(stars) + "☆".repeat(5 - stars), "   ·   💰 KOPFGELD HEUTE!" if p0.family == _bounty() else ""
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
        # Gamepad cursors: a thick frame in the pad's player color.
        var frame: Panel = item.get("cursor")
        if frame != null:
            frame.visible = false
            for dev in Input.get_connected_joypads():
                if dev < pad_cursor.size() and pad_cursor[dev] == k:
                    frame.visible = true
                    frame.add_theme_stylebox_override("panel", panel_style(Color(0, 0, 0, 0), [Color("ff9900"), CYAN, Color("ef4444"), Color("22c55e")][dev % 4], 3, 6))
                    break

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
    if event is InputEventKey and title_screen != null and title_screen.visible:
        if title_stage == "splash":
            _enter_main_menu() # any key starts
            return
        match event.keycode:
            KEY_UP, KEY_W: _title_pad(JOY_BUTTON_DPAD_UP)
            KEY_DOWN, KEY_S: _title_pad(JOY_BUTTON_DPAD_DOWN)
            KEY_LEFT, KEY_A: _title_pad(JOY_BUTTON_DPAD_LEFT)
            KEY_RIGHT, KEY_D: _title_pad(JOY_BUTTON_DPAD_RIGHT)
            KEY_ENTER, KEY_KP_ENTER, KEY_SPACE: _title_pad(JOY_BUTTON_A)
            KEY_ESCAPE: _title_pad(JOY_BUTTON_B)
        return
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
        if _pad_menu_button(event.device, event.button_index): return
        buffer_press(event)
    elif event is InputEventJoypadMotion:
        _pad_menu_stick(event)

## Menu cursor per gamepad (card index) and the stick latch for menu navigation.
var pad_cursor: Array = [0, 1, 2, 3]
var pad_stick_latch: Array = [Vector2i.ZERO, Vector2i.ZERO, Vector2i.ZERO, Vector2i.ZERO]

func _fusion_open() -> bool:
    return fusionskammer_modal != null and fusionskammer_modal.visible

## Xbox standard menu buttons. Returns true if the press was used by a menu.
func _pad_menu_button(dev: int, b: int) -> bool:
    if title_screen != null and title_screen.visible:
        _title_pad(b)
        return true
    if b == JOY_BUTTON_START:
        if active and (result_panel == null or not result_panel.visible): paused = not paused
        elif selection != null and selection.visible and not _fusion_open(): start_round(current_combat_mode)
        return true
    if result_panel != null and result_panel.visible and adventure != null:
        if b == JOY_BUTTON_A: _adventure_continue()
        elif b == JOY_BUTTON_B or b == JOY_BUTTON_BACK: _adventure_quit()
        return true
    if result_panel != null and result_panel.visible:
        if b == JOY_BUTTON_A and _next_boss_available(): next_boss()
        elif b == JOY_BUTTON_A: restart_round()
        elif b == JOY_BUTTON_B or b == JOY_BUTTON_BACK: show_selection()
        return true
    if active and paused:
        # Pause: B resumes, View quits to the fighter selection.
        if b == JOY_BUTTON_B: paused = false
        elif b == JOY_BUTTON_BACK: show_selection()
        return true
    if story != null and story.menu_panel.visible:
        if b == JOY_BUTTON_B or b == JOY_BUTTON_BACK:
            story.close_menu()
            if menu_return_title: show_title("menu")
        else: _nav_pad(b, story.menu_panel)
        return true
    if selection == null or not selection.visible or active: return false
    if _boss_menu_open():
        if b == JOY_BUTTON_B or b == JOY_BUTTON_BACK:
            close_boss_menu()
            if menu_return_title: show_title("menu")
        else: _nav_pad(b, boss_menu)
        return true
    if _fusion_open():
        if b == JOY_BUTTON_B or b == JOY_BUTTON_BACK: close_fusionskammer()
        return true
    match b:
        JOY_BUTTON_X:
            open_boss_menu()
            return true
        JOY_BUTTON_B:
            show_title("menu")
            return true
        JOY_BUTTON_LEFT_SHOULDER:
            _step_arena(-1)
            return true
        JOY_BUTTON_RIGHT_SHOULDER:
            _step_arena(1)
            return true
        JOY_BUTTON_BACK:
            _cycle_combat_mode()
            show_status("MODUS: %s   ·   ⧉ wechseln" % {"pve": "SPIELER vs KI", "manual": "SPIELER vs SPIELER", "autonomous": "KI vs KI"}.get(current_combat_mode, current_combat_mode), 1.6)
            return true
        JOY_BUTTON_RIGHT_STICK, JOY_BUTTON_LEFT_STICK:
            _toggle_player_count()
            show_status("SPIELER / TEAMS: %s   ·   R3 wechseln" % team_mode.to_upper(), 1.6)
            return true
    if dev >= pad_cursor.size(): return true
    match b:
        JOY_BUTTON_DPAD_LEFT: _move_pad_cursor(dev, Vector2i(-1, 0))
        JOY_BUTTON_DPAD_RIGHT: _move_pad_cursor(dev, Vector2i(1, 0))
        JOY_BUTTON_DPAD_UP: _move_pad_cursor(dev, Vector2i(0, -1))
        JOY_BUTTON_DPAD_DOWN: _move_pad_cursor(dev, Vector2i(0, 1))
        JOY_BUTTON_A:
            var idx: int = pad_cursor[dev]
            if idx >= 0 and idx < mk_presets.size():
                if mk_presets[idx].id == "fusionskammer":
                    if dev == 0: open_fusionskammer()
                elif dev < prompts.size():
                    on_mk_fighter_selected(dev, idx)
        JOY_BUTTON_Y:
            if dev < prompts.size():
                var pool: Array = []
                for k in range(mk_presets.size()):
                    if mk_presets[k].id != "fusionskammer": pool.append(k)
                if not pool.is_empty():
                    pad_cursor[dev] = pool[randi() % pool.size()]
                    on_mk_fighter_selected(dev, pad_cursor[dev])
    return true

## Left stick in menus: one cursor step per flick.
func _pad_menu_stick(ev: InputEventJoypadMotion) -> void:
    if selection == null or not selection.visible or active or _fusion_open(): return
    if ev.device >= pad_cursor.size() or (ev.axis != JOY_AXIS_LEFT_X and ev.axis != JOY_AXIS_LEFT_Y): return
    var latch: Vector2i = pad_stick_latch[ev.device]
    var v: float = ev.axis_value
    var step := 0
    if absf(v) > 0.6: step = 1 if v > 0.0 else -1
    elif absf(v) > 0.3: return
    if ev.axis == JOY_AXIS_LEFT_X:
        if step != 0 and latch.x != step: _move_pad_cursor(ev.device, Vector2i(step, 0))
        latch.x = step
    else:
        if step != 0 and latch.y != step: _move_pad_cursor(ev.device, Vector2i(0, step))
        latch.y = step
    pad_stick_latch[ev.device] = latch

func _move_pad_cursor(dev: int, d: Vector2i) -> void:
    var cols: int = 17
    var count: int = mk_presets.size()
    var idx: int = clampi(int(pad_cursor[dev]), 0, count - 1)
    if d.x != 0: idx = wrapi(idx + d.x, 0, count)
    if d.y != 0:
        var nxt: int = idx + d.y * cols
        if nxt >= 0 and nxt < count: idx = nxt
    pad_cursor[dev] = idx
    if dev == 0: _on_card_hovered(idx)
    update_mk_grid_visuals()
    sound("jump")

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
var tap_jump_latch: Array = [false, false, false, false]
var cstick_latch: Array = [false, false, false, false]

func manual_commands() -> Array:
    var commands: Array = []
    for i in range(maxi(2, human_count())):
        var pre := "p%d_" % (i + 1)
        var buf: Dictionary = input_buffer[i]
        if Input.is_action_just_pressed(pre + "jump"): buf.jump = INPUT_BUFFER_FRAMES
        if Input.is_action_just_pressed(pre + "grab"): buf.grab = INPUT_BUFFER_FRAMES
        if Input.is_action_just_pressed(pre + "standard"): buf.standard = maxi(buf.standard, INPUT_BUFFER_FRAMES)
        if Input.is_action_just_pressed(pre + "special"): buf.special = maxi(buf.special, INPUT_BUFFER_FRAMES)
        # Tap jump: flicking the left stick up jumps (Xbox genre standard).
        var stick_y: float = Input.get_joy_axis(i, JOY_AXIS_LEFT_Y)
        if stick_y < -0.75 and not tap_jump_latch[i]: buf.jump = INPUT_BUFFER_FRAMES
        tap_jump_latch[i] = stick_y < -0.45
        var cmd := {
            "move": Input.get_axis(pre + "left", pre + "right"),
            "up": Input.is_action_pressed(pre + "up"),
            "down": Input.is_action_pressed(pre + "down"),
            "standard": buf.standard > 0,
            "special": buf.special > 0,
            "jump": buf.jump > 0,
            "block": Input.is_action_pressed(pre + "block"),
            "grab": buf.grab > 0,
            "standard_held": Input.is_action_pressed(pre + "standard"),
            "jump_held": Input.is_action_pressed(pre + "jump") or stick_y < -0.45,
        }
        # Right stick: a flick is a smash attack in that direction (an aerial while airborne).
        var cs := Vector2(Input.get_joy_axis(i, JOY_AXIS_RIGHT_X), Input.get_joy_axis(i, JOY_AXIS_RIGHT_Y))
        if i == 0 and touch != null:
            # A swipe on the touch screen is a right-stick flick.
            var swipe: Vector2 = touch.take_smash()
            if swipe != Vector2.ZERO:
                cs = swipe
                cstick_latch[0] = false
        if cs.length() > 0.65 and not cstick_latch[i]:
            cmd.standard = true
            cmd.smash = true
            cmd.standard_held = false
            if absf(cs.x) >= absf(cs.y):
                cmd.move = signf(cs.x)
                cmd.up = false
                cmd.down = false
            else:
                cmd.up = cs.y < 0.0
                cmd.down = cs.y > 0.0
        cstick_latch[i] = cs.length() > 0.3
        commands.append(cmd)
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
        for ev in sim.events:
            progression.track(ev)
            if ev.type == "finish": _grant_match_rewards(int(ev.get("winner", -1)))
        for event in sim.events:
            if event.type == "hit":
                if smoke: smoke_report.hits += 1
                if not first_hit_done:
                    first_hit_done = true
                    announce("ERSTES BLUT!" if gore_on else "ERSTER TREFFER!", Color("ff4d4d"), 0.5)
                if adventure != null and event.actor == 0: adventure_combo = maxi(adventure_combo, int(sim.fighters[0].combo))
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
                if event.actor < sim.fighters.size() and str(sim.fighters[event.actor].profile.get("family", "")) == "arber" and not event.special:
                    sound("drill")
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
                    announcer("final_round")
                sound("ko")
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
                play_finisher(event.actor, event.target, str(event.kind), str(event.name), str(event.get("variant", "")))
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
            elif event.type == "marked":
                var mt: Dictionary = sim.fighters[event.target]
                shock_ring(Vector3(mt.x, mt.y + 1.1, 0.3), Color("49def4"), 1.4)
                show_status("⚡ %s IST MARKIERT – SPEZIAL FÜR DEN BLITZSCHLAG!" % mt.profile.name, 1.4)
                sound("electric")
            elif event.type == "stuck":
                sound("block")
            elif event.type == "recall":
                sound("electric")
            elif event.type == "catch":
                var cf: Dictionary = sim.fighters[event.actor]
                spark_burst(Vector3(cf.x, cf.y + 1.2, 0.35), Color("ffe26a"), 24, 5.0, 0.08)
                sound("jump")
            elif event.type == "pool":
                # The blob became a lava pool: rebuild its visual with the new shape.
                if projectile_nodes.has(event.id):
                    projectile_nodes[event.id].queue_free()
                    projectile_nodes.erase(event.id)
                spark_burst(Vector3(event.x, 0.3, 0.3), Color("ff6d2b"), 30, 5.0, 0.1)
                sound("lava")
            elif event.type == "wall_block":
                spark_burst(Vector3(event.x, event.y, 0.4), Color("ff8a3d"), 22, 5.0, 0.08)
                sound("lava")
            elif event.type == "decoy":
                spark_burst(Vector3(event.from_x, event.from_y + 1.0, 0.3), Color("bff3ff"), 24, 5.0, 0.08)
            elif event.type == "eagle_strike":
                var ef: Dictionary = sim.fighters[event.actor]
                _fade_free(_beam(Vector3(ef.x, ef.y + 0.2, 0.4), Vector3(event.x, event.y + 1.0, 0.4), Color("e41e20"), 0.12), 0.25)
                spark_burst(Vector3(event.x, event.y + 1.0, 0.4), Color("e41e20"), 22, 6.0, 0.08)
                spark_burst(Vector3(event.x, event.y + 1.0, 0.4), Color(0.06, 0.02, 0.02), 14, 4.0, 0.08)
                camera_shake = 0.3
                sound("slash")
            elif event.type == "eagle_leave":
                var lf2: Dictionary = sim.fighters[event.actor]
                spark_burst(Vector3(lf2.x, lf2.y + 0.4, 0.3), Color(0.08, 0.02, 0.02), 30, 5.0, 0.08)
            elif event.type == "flashbang":
                flash_screen(Color(1, 1, 1), 0.55)
                shock_ring(Vector3(event.x, event.y, 0.35), Color("fef3c7"), 3.0)
            elif event.type == "bomb_stuck":
                var bt: Dictionary = sim.fighters[event.target]
                spark_burst(Vector3(bt.x, bt.y + 1.2, 0.35), Color("f59e0b"), 16, 3.0, 0.08)
                show_status("ZEITBOMBE KLEBT!", 1.0)
            elif event.type == "leashed":
                var lt: Dictionary = sim.fighters[event.target]
                var la: Dictionary = sim.fighters[event.actor]
                _fade_free(_beam(Vector3(la.x, la.y + 1.1, 0.35), Vector3(lt.x, lt.y + 1.1, 0.35), Color("a8a29e"), 0.06), 0.8)
                show_status("GEFESSELT", 1.0)
            elif event.type == "hexed":
                var hx: Dictionary = sim.fighters[event.target]
                spark_burst(Vector3(hx.x, hx.y + 1.8, 0.35), Color("c084fc"), 24, 3.0, 0.1)
                show_status("VERFLUCHT – +30 %% SCHADEN", 1.0)
            elif event.type == "soul_weigh":
                var wt: Dictionary = sim.fighters[event.target]
                spark_burst(Vector3(wt.x, wt.y + 1.2, 0.35), Color("c9a227"), 20, 4.0, 0.08)
                if float(event.mult) >= 1.5: show_status("HERZWÄGUNG ×%.1f" % float(event.mult), 1.0)
            elif event.type == "war_horn":
                var hw: Dictionary = sim.fighters[event.actor]
                shock_ring(Vector3(hw.x, hw.y + 1.0, 0.35), Color("ffd24a"), 1.4)
            elif event.type == "rebirth_heal":
                var hf: Dictionary = sim.fighters[event.actor]
                spark_burst(Vector3(hf.x, hf.y + 1.0, 0.35), Color("fde68a"), 24, 4.0, 0.08)
                show_status("ASCHE ZU ASCHE  −%d %%" % int(round(float(event.amount))), 1.0)
            elif event.type == "turbo_ram":
                var rf: Dictionary = sim.fighters[event.actor]
                shock_ring(Vector3(rf.x, rf.y + 1.0, 0.35), Color("60a5fa"), 1.8)
                camera_shake = 0.4
            elif event.type == "reflect":
                spark_burst(Vector3(event.x, event.y, 0.4), Color("e2e8f0"), 26, 6.0, 0.08)
                show_status("REFLEKTIERT!", 0.8)
                sound("block")
            elif event.type == "bulwark_block":
                var bf: Dictionary = sim.fighters[event.actor]
                views[event.actor].shield_flash()
                spark_burst(Vector3(bf.x + bf.facing * 0.6, bf.y + 1.1, 0.4), Color("e2e8f0"), 18, 5.0, 0.07)
                sound("block")
            elif event.type == "iai_cut":
                var sf: Dictionary = sim.fighters[event.actor]
                var cut := _beam(Vector3(event.from_x, event.y + 1.0, 0.45), Vector3(sf.x, sf.y + 1.0, 0.45), Color("e6fffa"), 0.12)
                _fade_free(cut, 0.4)
                flash_screen(Color.WHITE, 0.35)
                slow_motion(0.2, 0.18)
                announce("ISSEN!", Color("99f6e4"), 0.4)
                sound("hit")
            elif event.type == "slam":
                var sc: Color = event.color
                shock_ring(Vector3(event.x, event.y + 0.2, 0.3), sc, float(event.radius) * 2.0)
                for k in range(6):
                    erupt_pillar(Vector3(event.x + (k - 2.5) * float(event.radius) * 0.33, event.y - 0.4, 0.2), sc, false)
                camera_shake = 1.3
                sound("lava")
                sound("hit")
            elif event.type == "yank":
                var yf: Dictionary = sim.fighters[event.actor]
                _fade_free(_beam(Vector3(event.from_x, yf.y + 1.1, 0.4), Vector3(yf.x, yf.y + 1.1, 0.4), Color("a8a29e"), 0.05), 0.35)
                announce("ENTERN!", Color("fbbf24"), 0.35)
                sound("jump")
            elif event.type == "heat_full":
                var hf: Dictionary = sim.fighters[event.actor]
                shock_ring(Vector3(hf.x, hf.y + 1.0, 0.3), Color("ff6d2b"), 3.0)
                show_status("🔥 %s GLÜHT – SPEZIAL = KERNSCHMELZE!" % hf.profile.name, 1.8)
                sound("lava")
            elif event.type == "armor":
                views[event.actor].flash()
                var af: Dictionary = sim.fighters[event.actor]
                spark_burst(Vector3(af.x, af.y + 1.2, 0.4), Color("fbbf24"), 10, 4.0, 0.07)
                sound("block")
            elif event.type == "boss_telegraph":
                boss_telegraph(event)
            elif event.type == "boss_phase":
                announce("PHASE 2 · ZORN DES HIMMELS", Color("ff3b1f"), 1.2)
                flash_screen(Color("ff3b1f"), 0.6)
                camera_shake = 1.5
                sound("victory")
            elif event.type == "boss_defeated":
                boss_death(event.actor)
            elif event.type == "boss_attack":
                sound("lava" if str(event.pattern) in ["fire_breath", "ring_burst", "fire_pillars", "dive"] else "electric")
            elif event.type == "clone_ready":
                spark_burst(Vector3(event.x, sim.fighters[event.actor].y + 1.0, 0.3), Color("ff9b3d"), 16, 4.0, 0.08)
            elif event.type == "echo_strike":
                spark_burst(Vector3(event.x + float(event.facing) * 0.8, event.y, 0.4), Color("ffb870"), 12, 5.0, 0.07)
            elif event.type == "clone_swap":
                var cw: Dictionary = sim.fighters[event.actor]
                for pos in [Vector3(event.from_x, event.from_y + 1.0, 0.3), Vector3(cw.x, cw.y + 1.0, 0.3)]:
                    spark_burst(pos, Color("ff9b3d"), 22, 5.0, 0.08)
                if event.actor < views.size(): views[event.actor].reset_physics_interpolation()
                sound("jump")
            elif event.type == "nova_launch":
                announce("NOVA!", Color("c084fc"), 0.35)
                sound("lava")
            elif event.type == "shield_pierce":
                announce("SCHILD DURCHBROCHEN!", Color("ffd23f"), 0.5)
                sound("block")
            elif event.type == "one_punch_ko":
                flash_screen(Color.WHITE, 0.8)
                slow_motion(0.15, 0.4)
                announce("ERNSTFALL!", Color("ffd23f"), 0.7)
                camera_shake = 1.8
                sound("hit")
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
                _announce_result()
                flash_screen(Color.WHITE, 0.4)
                slow_motion(0.3, 0.9)
                sound("victory")
                if story != null and story.running:
                    story.on_fight_finished(sim.result)
                elif adventure != null and adventure.running:
                    _adventure_finished()
                    get_tree().create_timer(1.1, true, false, true).timeout.connect(_show_result_panel_if_finished)
                elif daily_active:
                    _daily_finished()
                    get_tree().create_timer(1.1, true, false, true).timeout.connect(_show_result_panel_if_finished)
                else:
                    result_label.text = winner_text()
                    _challenger_after_match()
                    get_tree().create_timer(1.1, true, false, true).timeout.connect(_show_result_panel_if_finished)
            elif event.type == "finish" and story != null and story.running:
                sound("victory")
                story.on_fight_finished(sim.result)
            elif event.type == "finish":
                result_label.text = winner_text()
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
    _update_touch_mode()
    if fps_label and fps_label.visible:
        fps_label.text = "%d FPS" % Engine.get_frames_per_second()
    if smoke and active: fps_samples.append(Engine.get_frames_per_second())
    if not paused: status_message_time = maxf(0.0, status_message_time - delta)
    if active and not paused:
        var step: int = int(ceil(sim.countdown / 0.8)) if sim.countdown > 0.0 else 0
        if step != last_countdown_step:
            if step > 0:
                announce(str(step), Color("f7c844"), 0.35)
                announcer(str(step))
            elif last_countdown_step > 0:
                announce("GO!", Color("4ade80"), 0.4)
                announcer("fight")
            last_countdown_step = step
    _update_nav_frame()
    if title_screen != null and title_screen.visible and not title_showcase.is_empty():
        _title_camera(delta)
        return
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
    if index < sim.fighters.size() and sim.fighters[index].is_boss: return ""
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
        "ninja", "golem", "valkyrie", "dragon", "kairo", "varakh", "xylar", "glaciem", "oryn",
        "tobi", "jubei", "ren", "amethya", "bruno", "hikaru", "zip", "raiga", "albion",
        "pyrax", "anubis", "specter", "phoenix", "brunhild", "steel_knight", "vanguard_soldier",
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
    update_boss_bar()
    if next_boss_button: next_boss_button.visible = result_panel.visible and _next_boss_available() and adventure == null
    if revanche_button: revanche_button.visible = adventure == null
    if adventure_button: adventure_button.visible = adventure != null and result_panel.visible
    timer.text = "%02d" % int(ceil(sim.time_left))
    var active_count: int = mini(health_bars.size(), sim.fighters.size())
    for i in range(active_count):
        var f: Dictionary = sim.fighters[i]
        var tag: String = ""
        if f.is_boss: tag = "👁 "
        elif boss_active: tag = "[HELD] "
        elif not team_layout().is_empty() and (story == null or not story.running): tag = "[%s] " % ("A" if int(f.team) == 0 else "B")
        names[i].text = "%sP%d  ·  %s" % [tag, i+1, f.profile.name]
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

        health_text[i].text = "%d HP" % int(ceil(f.boss_hp)) if f.is_boss else "%d %%" % int(round(p_dmg))
        health_text[i].add_theme_color_override("font_color", dmg_col)

        var super_val: float = f.get("super", 0.0)
        var combo_val: int = f.get("combo", 0)
        var super_str: String = "⚡ SUPER!" if super_val >= 100.0 else "SUPER %d%%" % int(super_val)
        var combo_str: String = " · %d HITS" % combo_val if combo_val > 1 else ""
        var kit_str: String = ""
        if bool(f.get("phys", {}).get("heat", false)):
            kit_str = " · 🔥 KERNSCHMELZE!" if float(f.heat) >= Combat.HEAT_MAX else " · GLUT %d%%" % int(f.heat)
        special_text[i].text = super_str + combo_str + kit_str + (" · SPEZIAL!" if f.cooldowns[1] <= 0 and super_val >= 40 else "")

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
    if paused: status.text = ("PAUSE  ·  WEITER oder AUSWAHL antippen" if touch != null else "PAUSE  ·  ESC / ☰ / B zum Fortsetzen  ·  ⧉ Kämpferauswahl")
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
    audio_director = load("res://scripts/audio_director.gd").new()
    audio_director.name = "AudioDirector"
    add_child(audio_director)
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
    if DisplayServer.get_name() == "headless": return
    # Recorded variants (CC0) where available, the old jingles for "start" and "victory".
    if audio_director != null and audio_director.SFX_PITCH.has(key) and audio_director.has_sfx(key):
        audio_director.sfx(key)
    elif audio.has(key): audio[key].play()

## Music for a context (see audio_director.gd TRACKS); safe before setup and in tests.
func music(context: String) -> void:
    if audio_director != null: audio_director.play_music(context, current_arena)

func announcer(line: String) -> void:
    if audio_director != null: audio_director.announce(line)

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

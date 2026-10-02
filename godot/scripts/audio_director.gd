extends Node
## Audio director: music with crossfades per context (menu, arena, boss, story mood), sound
## effects with several recorded variants and pitch spread, the announcer and voiced dialogue
## (music ducks while someone speaks). Buses: Music, SFX, Voice under Master.
## Arenas get a quiet ambience loop under the music (wind, surf, fire, forest).
## Licenses: docs/AUDIO_LICENSES.md (CC0, ambience CC BY 4.0 JC Sounds).

const MUSIC_DIR := "res://assets/audio/music/"
const SFX_DIR := "res://assets/audio/sfx/"
const ANNOUNCER_DIR := "res://assets/audio/voice/announcer/"
const AMBIENCE_DIR := "res://assets/audio/ambience/"

## Music per context. Fights pick by arena (stable per arena), bosses and story have their own.
const TRACKS := {
	"menu": "menu_theme", "victory": "menu_theme",
	"boss": "boss_epic", "boss_final": "boss_metal_loop",
	"story_calm": "story_first_light", "story_sad": "story_emotional_solo", "story_hope": "story_emotional",
	"story_tense": "battle_tempest",
}
const FIGHT_TRACKS := ["battle_valor", "battle_tempest", "boss_metal_loop"]
## Sound keys used by main.gd and their pitch spread (fraction).
const SFX_PITCH := {"hit": 0.12, "block": 0.1, "jump": 0.12, "land": 0.1, "electric": 0.15, "lava": 0.12,
	"ko": 0.06, "slash": 0.12, "drill": 0.1, "ui_select": 0.05, "ui_confirm": 0.03, "ui_back": 0.03}
const SFX_DB := {"hit": -4.0, "block": -6.0, "jump": -10.0, "land": -12.0, "electric": -9.0, "lava": -8.0,
	"ko": -3.0, "slash": -7.0, "drill": -9.0, "ui_select": -12.0, "ui_confirm": -9.0, "ui_back": -10.0}
const DUCK_DB := -10.0

## Ambience per arena; arenas not listed are matched by keywords in their id (AMBIENCE_KEYS).
const AMBIENCE := {
	"blood_moon": "forest_night", "volcano_sanctum": "bonfire", "imperial_colosseum": "torches", "pirate_galleon": "ocean",
	"gladiator_fortress": "torches", "mystic_grove": "forest_enchanted", "frozen_summit": "winter_wind", "neon_metropolis": "",
	"heaven_gate": "desert_wind", "heaven_spheres": "desert_wind", "wheel_heaven": "desert_wind", "empyrean": "bonfire",
	"hell_gate": "bonfire", "hell_flames": "bonfire", "hell_city": "torches", "cocytus": "winter_wind",
}
const AMBIENCE_KEYS := [["ocean", "ocean"], ["harbor", "ocean"], ["ship", "ocean"], ["ice", "winter_wind"], ["frost", "winter_wind"],
	["snow", "winter_wind"], ["polar", "winter_wind"], ["aurora", "winter_wind"], ["lava", "bonfire"], ["forge", "bonfire"],
	["foundry", "bonfire"], ["volcan", "bonfire"], ["jungle", "forest_enchanted"], ["grove", "forest_enchanted"], ["forest", "forest_night"],
	["temple", "torches"], ["dojo", "torches"], ["castle", "torches"], ["ruin", "desert_wind"], ["desert", "desert_wind"],
	["roof", "desert_wind"], ["storm", "desert_wind"], ["war", "desert_wind"]]
const AMBIENCE_DB := -20.0

var music_a: AudioStreamPlayer
var music_b: AudioStreamPlayer
var current_track := ""
var sfx_players := {}
var announcer: AudioStreamPlayer
var ambience: AudioStreamPlayer
var current_ambience := ""
var voice: AudioStreamPlayer
var _duck := 0.0
var enabled := true

func _ready() -> void:
	enabled = DisplayServer.get_name() != "headless"
	_ensure_bus("Music", -6.0)
	_ensure_bus("SFX", 0.0)
	_ensure_bus("Voice", 0.0)
	music_a = _player("Music")
	music_b = _player("Music")
	announcer = _player("Voice")
	announcer.volume_db = -2.0
	voice = _player("Voice")
	ambience = _player("SFX")

func _ensure_bus(bus_name: String, db: float) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0: return
	AudioServer.add_bus()
	var idx: int = AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_send(idx, "Master")
	AudioServer.set_bus_volume_db(idx, db)

func _player(bus: String) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = bus
	add_child(p)
	return p

## Files in a res:// folder, also in exported builds (where only .import/.remap entries are listed).
static func list_audio(dir: String) -> Array:
	var out: Array = []
	var d := DirAccess.open(dir)
	if d == null: return out
	for f in d.get_files():
		var name: String = f.trim_suffix(".import").trim_suffix(".remap")
		if (name.ends_with(".ogg") or name.ends_with(".wav")) and not out.has(dir + name): out.append(dir + name)
	out.sort()
	return out

# ── Music ──

func play_music(context: String, arena: String = "", fade: float = 1.2) -> void:
	play_ambience(ambience_for(arena) if context in ["fight", "boss", "boss_final"] else "")
	var track: String = TRACKS.get(context, "")
	if context == "fight":
		track = FIGHT_TRACKS[absi(hash(arena)) % FIGHT_TRACKS.size()]
	if track == "" or track == current_track: return
	current_track = track
	if not enabled: return
	var path := MUSIC_DIR + track + ".ogg"
	if not ResourceLoader.exists(path): return
	var stream = load(path)
	if stream is AudioStreamOggVorbis: stream.loop = true
	var old: AudioStreamPlayer = music_a if music_a.playing else music_b
	var new: AudioStreamPlayer = music_b if old == music_a else music_a
	new.stream = stream
	new.volume_db = -40.0
	new.play()
	var tw := create_tween().set_parallel(true)
	tw.tween_property(new, "volume_db", 0.0, fade)
	if old.playing:
		tw.tween_property(old, "volume_db", -40.0, fade)
		tw.chain().tween_callback(old.stop)

func stop_music(fade: float = 1.0) -> void:
	current_track = ""
	play_ambience("", fade)
	for p in [music_a, music_b]:
		if p.playing:
			var tw := create_tween()
			tw.tween_property(p, "volume_db", -40.0, fade)
			tw.tween_callback(p.stop)

# ── Ambience ──

static func ambience_for(arena: String) -> String:
	if AMBIENCE.has(arena): return AMBIENCE[arena]
	var id := arena.to_lower()
	for pair in AMBIENCE_KEYS:
		if str(pair[0]) in id: return str(pair[1])
	return ""

## Crossfades to an ambience loop by file name; "" fades it out.
func play_ambience(loop: String, fade: float = 1.5) -> void:
	if loop == current_ambience: return
	current_ambience = loop
	if not enabled or ambience == null: return
	var path := AMBIENCE_DIR + loop + ".ogg"
	var tw := create_tween()
	if ambience.playing: tw.tween_property(ambience, "volume_db", -50.0, fade * 0.5)
	if loop == "" or not ResourceLoader.exists(path):
		tw.tween_callback(ambience.stop)
		return
	var stream = load(path)
	if stream is AudioStreamOggVorbis: stream.loop = true
	tw.tween_callback(_start_ambience.bind(stream))
	tw.tween_property(ambience, "volume_db", AMBIENCE_DB, fade)

func _start_ambience(stream: AudioStream) -> void:
	ambience.stream = stream
	ambience.volume_db = -50.0
	ambience.play()

# ── Sound effects ──

func sfx(key: String) -> void:
	if not enabled: return
	if not sfx_players.has(key):
		var files: Array = list_audio(SFX_DIR + key + "/")
		if files.is_empty():
			sfx_players[key] = null
			return
		var rnd := AudioStreamRandomizer.new()
		rnd.random_pitch = 1.0 + float(SFX_PITCH.get(key, 0.08))
		rnd.random_volume_offset_db = 1.5
		rnd.playback_mode = AudioStreamRandomizer.PLAYBACK_RANDOM_NO_REPEATS
		for f in files: rnd.add_stream(-1, load(f))
		var p := _player("SFX")
		p.stream = rnd
		p.max_polyphony = 4
		p.volume_db = float(SFX_DB.get(key, -8.0))
		sfx_players[key] = p
	if sfx_players[key] != null: (sfx_players[key] as AudioStreamPlayer).play()

func has_sfx(key: String) -> bool:
	return not list_audio(SFX_DIR + key + "/").is_empty()

# ── Voices ──

## Announcer line by file name without extension, e.g. "fight", "round_1", "you_win".
func announce(line: String) -> void:
	var path := ANNOUNCER_DIR + line + ".ogg"
	if not enabled or not ResourceLoader.exists(path): return
	announcer.stream = load(path)
	announcer.play()

## Voiced dialogue line; the music ducks while it plays. Returns the length in seconds (0 = none).
func speak(path: String) -> float:
	if path == "" or not ResourceLoader.exists(path): return 0.0
	var stream = load(path)
	if not enabled: return stream.get_length() if stream else 0.0
	voice.stream = stream
	voice.play()
	return stream.get_length()

func stop_voice() -> void:
	voice.stop()

func is_speaking() -> bool:
	return voice.playing

func _process(delta: float) -> void:
	var want: float = DUCK_DB if (voice != null and voice.playing) or (announcer != null and announcer.playing) else 0.0
	_duck = move_toward(_duck, want, delta * (40.0 if want < _duck else 12.0))
	var idx := AudioServer.get_bus_index("Music")
	if idx >= 0: AudioServer.set_bus_volume_db(idx, -6.0 + _duck)

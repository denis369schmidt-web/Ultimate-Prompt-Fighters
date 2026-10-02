extends RefCounted
## Start menu backgrounds (shop) and their arenas. Every background is a painted title screen
## with the menu drawn into the picture; "menu" is the rectangle (normalized x0, y0, x1, y1)
## around its six entries STORY · VERSUS · EXTRAS · OPTIONS · SHOP · CREDITS, which the title
## screen turns into real buttons. Buying a background with coins also unlocks its arena.
## Arena: motif (builder in arena_builder.gd) plus theme values (materials, colors, weather).

const MENU_ITEMS := ["story", "adventure", "versus", "extras", "options", "shop", "credits"]

const LIST := [
	{"id": "neon_alley", "name": "NEON-GASSE", "img": "bg_01", "price": 0, "menu": [0.37, 0.49, 0.63, 0.89],
		"motif": "city_street", "trim": Color("ff3db4"), "accent": Color("22d3ee"), "weather": "rain", "sky": "shanghai_bund", "tint": Color(0.5, 0.35, 0.7)},
	{"id": "moon_temple", "name": "MONDTEMPEL", "img": "bg_02", "price": 250, "menu": [0.37, 0.49, 0.63, 0.89],
		"motif": "temple", "trim": Color("ffb13b"), "accent": Color("ff7a1a"), "weather": "fireflies", "sky": "rogland_moonlit_night", "tint": Color(0.6, 0.62, 0.8)},
	{"id": "holo_city", "name": "HOLO-METROPOLE", "img": "bg_03", "price": 400, "menu": [0.37, 0.49, 0.63, 0.89],
		"motif": "scifi_city", "trim": Color("38bdf8"), "accent": Color("f472b6"), "weather": "dust", "sky": "shanghai_bund", "tint": Color(0.45, 0.6, 0.9)},
	{"id": "warehouse", "name": "LAGERHALLE", "img": "bg_04", "price": 300, "menu": [0.37, 0.37, 0.63, 0.76],
		"motif": "industrial", "trim": Color("f59e0b"), "accent": Color("84cc16"), "weather": "dust", "sky": "rogland_moonlit_night", "tint": Color(0.55, 0.5, 0.45)},
	{"id": "cyber_stadium", "name": "CYBER-STADION", "img": "bg_05", "price": 500, "menu": [0.37, 0.37, 0.63, 0.76],
		"motif": "stadium", "trim": Color("bae6fd"), "accent": Color("ffffff"), "weather": "dust", "sky": "rogland_moonlit_night", "tint": Color(0.6, 0.7, 0.95), "future": true},
	{"id": "orbital_ring", "name": "ORBITALRING", "img": "bg_06", "price": 900, "menu": [0.37, 0.37, 0.63, 0.76],
		"motif": "space", "trim": Color("a78bfa"), "accent": Color("38bdf8"), "weather": "fireflies", "sky": "rogland_moonlit_night", "tint": Color(0.25, 0.25, 0.45)},
	{"id": "neon_skyline", "name": "NEON-SKYLINE", "img": "bg_07", "price": 350, "menu": [0.06, 0.43, 0.24, 0.86],
		"motif": "city_roof", "trim": Color("22d3ee"), "accent": Color("f472b6"), "weather": "rain", "sky": "shanghai_bund", "tint": Color(0.4, 0.55, 0.75)},
	{"id": "colosseum_dusk", "name": "KOLOSSEUM", "img": "bg_08", "price": 400, "menu": [0.10, 0.44, 0.27, 0.87],
		"motif": "colosseum", "trim": Color("ffd166"), "accent": Color("ff9245"), "weather": "dust", "sky": "colosseum", "tint": Color(1.0, 0.85, 0.65)},
	{"id": "aurora_peaks", "name": "POLARLICHT-GIPFEL", "img": "bg_09", "price": 600, "menu": [0.06, 0.41, 0.23, 0.84],
		"motif": "mountains", "trim": Color("6ee7b7"), "accent": Color("a7f3d0"), "weather": "snow", "sky": "lago_disola", "tint": Color(0.5, 0.65, 0.8)},
	{"id": "space_hangar", "name": "RAUMSCHIFF-HANGAR", "img": "bg_10", "price": 800, "menu": [0.42, 0.42, 0.58, 0.86],
		"motif": "space_interior", "trim": Color("7dd3fc"), "accent": Color("f8fafc"), "weather": "dust", "sky": "rogland_moonlit_night", "tint": Color(0.3, 0.35, 0.5)},
	{"id": "graffiti_alley", "name": "GRAFFITI-GASSE", "img": "bg_11", "price": 300, "menu": [0.06, 0.39, 0.21, 0.82],
		"motif": "city_street", "trim": Color("c084fc"), "accent": Color("f472b6"), "weather": "rain", "sky": "shanghai_bund", "tint": Color(0.55, 0.35, 0.65), "graffiti": true},
	{"id": "no_mans_land", "name": "NIEMANDSLAND", "img": "bg_12", "price": 500, "menu": [0.43, 0.40, 0.59, 0.83],
		"motif": "war", "trim": Color("94a3b8"), "accent": Color("f97316"), "weather": "dust", "sky": "misty_pines", "tint": Color(0.5, 0.52, 0.55)},
	{"id": "sunset_stadium", "name": "SONNENSTADION", "img": "bg_13", "price": 450, "menu": [0.76, 0.19, 0.94, 0.82],
		"motif": "stadium", "trim": Color("fb923c"), "accent": Color("fde68a"), "weather": "dust", "sky": "rogland_sunset", "tint": Color(1.0, 0.7, 0.5)},
	{"id": "rain_rooftop", "name": "REGENDACH", "img": "bg_14", "price": 350, "menu": [0.78, 0.19, 0.96, 0.82],
		"motif": "city_roof", "trim": Color("38bdf8"), "accent": Color("fb7185"), "weather": "rain", "sky": "shanghai_bund", "tint": Color(0.35, 0.45, 0.6)},
	{"id": "dojo", "name": "DOJO", "img": "bg_15", "price": 450, "menu": [0.75, 0.19, 0.94, 0.82],
		"motif": "dojo", "trim": Color("f59e0b"), "accent": Color("fde68a"), "weather": "dust", "sky": "rogland_sunset", "tint": Color(0.8, 0.6, 0.4)},
	{"id": "night_market", "name": "NACHTMARKT", "img": "bg_16", "price": 350, "menu": [0.74, 0.18, 0.93, 0.80],
		"motif": "city_street", "trim": Color("fb7185"), "accent": Color("fbbf24"), "weather": "rain", "sky": "shanghai_bund", "tint": Color(0.6, 0.4, 0.55)},
	{"id": "ruined_city", "name": "RUINENSTADT", "img": "bg_17", "price": 550, "menu": [0.76, 0.18, 0.95, 0.80],
		"motif": "war", "trim": Color("5eead4"), "accent": Color("94a3b8"), "weather": "rain", "sky": "misty_pines", "tint": Color(0.45, 0.55, 0.52), "ruins": true},
	{"id": "arena_sun", "name": "SONNENARENA", "img": "bg_18", "price": 600, "menu": [0.39, 0.48, 0.59, 0.88],
		"motif": "colosseum", "trim": Color("fbbf24"), "accent": Color("ffedd5"), "weather": "dust", "sky": "colosseum", "tint": Color(1.0, 0.8, 0.55), "statues": true},
	{"id": "storm_roof", "name": "STURMDACH", "img": "bg_19", "price": 700, "menu": [0.41, 0.48, 0.62, 0.88],
		"motif": "city_roof", "trim": Color("60a5fa"), "accent": Color("ef4444"), "weather": "rain", "sky": "shanghai_bund", "tint": Color(0.35, 0.4, 0.65), "storm": true},
	{"id": "jungle_ruins", "name": "DSCHUNGELRUINEN", "img": "bg_20", "price": 650, "menu": [0.40, 0.47, 0.59, 0.88],
		"motif": "temple", "trim": Color("4ade80"), "accent": Color("2dd4bf"), "weather": "fireflies", "sky": "misty_pines", "tint": Color(0.55, 0.75, 0.5), "jungle": true},
	{"id": "frozen_works", "name": "EISWERK", "img": "bg_21", "price": 700, "menu": [0.42, 0.47, 0.60, 0.88],
		"motif": "industrial", "trim": Color("7dd3fc"), "accent": Color("e0f2fe"), "weather": "snow", "sky": "lago_disola", "tint": Color(0.75, 0.85, 1.0), "frozen": true},
	{"id": "foundry", "name": "GIESSEREI", "img": "bg_22", "price": 750, "menu": [0.40, 0.45, 0.60, 0.86],
		"motif": "foundry", "trim": Color("f97316"), "accent": Color("fde047"), "weather": "embers", "sky": "rogland_sunset", "tint": Color(0.7, 0.35, 0.2)},
	{"id": "molten_forge", "name": "SCHMELZOFEN", "img": "bg_23", "price": 1000, "menu": [0.42, 0.45, 0.61, 0.86],
		"motif": "foundry", "trim": Color("ef4444"), "accent": Color("fb923c"), "weather": "embers", "sky": "rogland_sunset", "tint": Color(0.65, 0.3, 0.2), "molten": true},
]

## Stage materials per motif (Poly Haven scans, see arena_builder.gd).
const MOTIF_STAGE := {
	"city_street": ["ph:concrete_panels", "ph:castle_brick_01"], "temple": ["ph:mossy_cobblestone", "ph:japanese_stone_wall"],
	"scifi_city": ["ph:metal_plate", "ph:concrete_panels"], "industrial": ["ph:metal_plate", "ph:concrete_panels"],
	"stadium": ["ph:concrete_panels", "ph:metal_plate"], "space": ["ph:metal_plate", "ph:concrete_panels"],
	"city_roof": ["ph:concrete_panels", "ph:castle_brick_01"], "colosseum": ["ph:large_sandstone_blocks_01", "ph:large_sandstone_blocks"],
	"mountains": ["ph:snow_02", "ph:rock_wall_10"], "space_interior": ["ph:metal_plate", "ph:concrete_panels"],
	"war": ["ph:dark_rock", "ph:rock_wall_10"], "dojo": ["ph:brown_planks_07", "ph:dark_planks"], "foundry": ["ph:metal_plate", "ph:dark_rock"],
}

## Scene brightness per motif: night scenes stay dark so neon and fire can glow.
const MOTIF_EXPOSURE := {
	"city_street": 0.5, "city_roof": 0.52, "scifi_city": 0.55, "space": 0.5, "space_interior": 0.62, "industrial": 0.6,
	"foundry": 0.55, "war": 0.62, "temple": 0.62, "stadium": 0.7, "colosseum": 0.78, "mountains": 0.55, "dojo": 0.62,
}

static func exposure(bg: Dictionary) -> float:
	var e: float = float(MOTIF_EXPOSURE.get(bg.motif, 0.8))
	if bg.get("jungle", false) or bg.get("frozen", false): e += 0.15
	if bg.id == "sunset_stadium": e += 0.15
	return e

static func find(id: String) -> Dictionary:
	for bg in LIST:
		if bg.id == id: return bg
	return {}

static func arena_id(bg: Dictionary) -> String:
	return "bg_" + str(bg.id)

## Background of an arena id ("bg_neon_alley" → neon_alley entry), or {}.
static func for_arena(arena: String) -> Dictionary:
	return find(arena.trim_prefix("bg_")) if arena.begins_with("bg_") else {}

## Small preview (512 px wide) for shop cards; the full image is only loaded for the active menu.
static func thumb_path(bg: Dictionary) -> String:
	var t := "res://assets/textures/menu_bg/thumbs/%s.png" % bg.img
	return t if ResourceLoader.exists(t) else image_path(bg)

static func image_path(bg: Dictionary) -> String:
	return "res://assets/textures/menu_bg/%s.png" % bg.img

## Arena theme for arena_builder.gd (same keys as its THEMES).
static func theme(bg: Dictionary) -> Dictionary:
	var mats: Array = MOTIF_STAGE.get(bg.motif, ["ph:concrete_panels", "ph:castle_brick_01"])
	var under := "island"
	if bg.motif in ["city_street", "city_roof", "scifi_city"]: under = "tower"
	elif bg.motif in ["colosseum", "stadium", "dojo", "temple"]: under = "pedestal"
	return {"top": mats[0], "side": mats[1], "trim": bg.trim, "under": under, "weather": bg.weather, "rock_tint": Color(0.8, 0.8, 0.8),
		"sky": bg.sky, "sky_rot": float(hash(bg.id) % 360), "sky_tint": (bg.tint as Color) * (0.55 if exposure(bg) < 0.6 else 1.0), "sky_energy": 1.2}

# ── shop rules (state lives in progression.gd: coins, unlocked, menu_bg) ──

static func is_unlocked(prog, id: String) -> bool:
	var bg: Dictionary = find(id)
	return not bg.is_empty() and (int(bg.price) == 0 or prog.unlocked.has(id))

static func arena_unlocked(prog, arena: String) -> bool:
	var bg: Dictionary = for_arena(arena)
	return bg.is_empty() or is_unlocked(prog, str(bg.id))

## Buys a background (and its arena). Returns false if not affordable or already owned.
static func buy(prog, id: String) -> bool:
	var bg: Dictionary = find(id)
	if bg.is_empty() or is_unlocked(prog, id) or int(prog.coins) < int(bg.price): return false
	prog.coins = int(prog.coins) - int(bg.price)
	prog.unlocked[id] = true
	prog.save_progress()
	return true

static func select(prog, id: String) -> bool:
	if not is_unlocked(prog, id): return false
	prog.menu_bg = id
	prog.save_progress()
	return true

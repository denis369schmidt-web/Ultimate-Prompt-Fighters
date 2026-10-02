extends RefCounted
## Pure local provider. Replace interpret() with a validated provider later, never execute prompt text.

const FighterKits = preload("res://scripts/fighter_kits.gd")

const STAT_KEYS = ["vitality", "power", "defense", "speed", "technique"]
const ELEMENTS = {
	"electric": ["blitz", "elektr", "electric", "storm"],
	"fire": ["lava", "feuer", "fire", "brenn", "phoenix", "phönix", "flamme"],
	"ice": ["eis", "ice", "frost"],
	"wind": ["wind", "air"]
}

static func interpret(raw: Variant, slot: int = 0) -> Dictionary:
	var text := str(raw).strip_edges().left(512) if raw is String else ""
	if text.is_empty(): text = "Ausgeglichener Kämpfer"
	var lower := text.to_lower()
	var seed_value: int = 2166136261
	for character in lower:
		seed_value = ((seed_value ^ character.unicode_at(0)) * 16777619) & 0x7fffffff
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var sorceress_medea_early := has_any(lower, ["sorceress medea", "erzmagierin", "medea"])
	var skeleton_reaper_early := has_any(lower, ["skeleton reaper", "skelettkrieger", "skelett schnitter"])
	var sylvan_early := has_any(lower, ["sylvan beast", "quadruped", "sylvan", "tree beast"])
	var brunhild := has_any(lower, ["brunhild", "golden golem", "gold golem", "goldener golem", "aureus", "gold titan", "golden armored golem", "golden armor golem", "gold golem"])
	var lepora := has_any(lower, ["lepora", "mondjägerin", "mondbogen", "moon huntress", "huntress bow"])
	var thorn_witch := not sorceress_medea_early and has_any(lower, ["thorn witch", "bramble", "sorceress", "dornenhexe", "cracked skin", "thorn", "thorn sorceress"])
	var nyx_harvester := not skeleton_reaper_early and has_any(lower, ["nyx", "harvester", "soul harvester", "winged demon", "seelenernter", "nyx harvester"])
	var cat_girl := has_any(lower, ["cat girl", "katzenkriegerin", "feline", "kitsune warrior", "cat warrior", "kitsune"])
	var blue_dragon := has_any(lower, ["blue dragon", "blauer drache", "ice wyrm", "frost drake", "dragon blue", "blue wyrm"])
	var white_sci := has_any(lower, ["white sci", "cyborg mech", "android", "robotic fighter", "mecha titan", "cyborg"])
	var skeleton_dog := has_any(lower, ["skeleton hound", "knochenhund", "skeleton dog", "reaper hound", "bone hound", "hoellenhund", "undead dog"])
	var wooden_forest := not sylvan_early and has_any(lower, ["wooden forest", "treant", "waldgolem", "baumgolem", "forest ancient", "treant golem"])
	var nine_tailed := has_any(lower, ["nine tailed", "nine-tailed fox", "neunschwaenzig", "celestial fox", "celestial kyuubi"])
	var sylvan_beast := has_any(lower, ["sylvan beast", "quadruped", "sylvan", "tree beast"])

	var varakh := has_any(lower, ["varakh", "scharlachfürst", "sternenprinz", "nova-strahl"])
	var kairo := not varakh and has_any(lower, ["kairo", "sturmmönch", "solar-kanone"])
	var xylar := not varakh and not kairo and has_any(lower, ["xylar", "leerenkaiser", "nadelstrahl"])
	var tobi := not kairo and not varakh and not xylar and has_any(lower, ["tobi der", "federfaust", "schleuderfaust", "gummikapitän"])
	var jubei := not kairo and not varakh and not tobi and not xylar and has_any(lower, ["jubei", "windklinge", "sturmschnitt", "schattenschütze", "dreiklingen", "tigerschnitt"])
	var ren := not kairo and not varakh and not tobi and not jubei and not xylar and has_any(lower, ["ren die", "kirschkriegerin", "blütenwirbel", "wirbelfuchs", "spiralkern"])
	var oryn := not kairo and not varakh and not tobi and not jubei and not ren and not xylar and has_any(lower, ["oryn", "schwerkraftprophet", "abstoßungswelle"])
	var amethya := not kairo and not varakh and not tobi and not jubei and not ren and not oryn and not xylar and has_any(lower, ["amethya", "donnerhexe", "amethystblitz", "donnerklinge", "tausend funken"])
	var bruno := not kairo and not varakh and not tobi and not jubei and not ren and not oryn and not amethya and not xylar and has_any(lower, ["bruno", "einschlag-held", "meteorfaust", "ernstfall"])
	var hikaru := not kairo and not varakh and not tobi and not jubei and not ren and not oryn and not amethya and not bruno and not xylar and has_any(lower, ["hikaru", "glutklinge", "morgenrot", "sonnentänzer"])
	var glaciem := not kairo and not varakh and not tobi and not jubei and not ren and not amethya and not bruno and not hikaru and not xylar and has_any(lower, ["glaciem", "frostassassine", "eissplitter", "ice ninja", "cryomancer"])
	var zip := not kairo and not varakh and not tobi and not jubei and not ren and not amethya and not bruno and not hikaru and not glaciem and not oryn and not xylar and has_any(lower, ["zip der", "blitzkurier", "turbo-sprint", "turbo-rolle", "tempoigel"])
	var raiga := not kairo and not varakh and not tobi and not jubei and not ren and not amethya and not bruno and not hikaru and not glaciem and not oryn and not zip and not xylar and has_any(lower, ["raiga", "donnerfaust", "sternschlag", "kompassdämon", "kompassnova"])
	var albion := not kairo and not varakh and not tobi and not jubei and not ren and not amethya and not bruno and not hikaru and not glaciem and not oryn and not zip and not raiga and not xylar and has_any(lower, ["albion", "silberwyrm", "sturmstrahl", "weißer drache", "weisser drache", "weiße drache", "weisse drache", "white dragon"])
	var anubis := not kairo and not varakh and not tobi and not jubei and not ren and not amethya and not bruno and not hikaru and not glaciem and not oryn and not zip and not raiga and not albion and not xylar and has_any(lower, ["anubis", "jackal", "khopesh", "ägyptisch", "egypt", "pharaoh", "pharao", "underworld", "unterwelt", "osiris", "jackal god"])
	var phoenix := not kairo and not varakh and not tobi and not jubei and not ren and not amethya and not bruno and not hikaru and not glaciem and not oryn and not zip and not raiga and not albion and not anubis and not xylar and has_any(lower, ["phoenix", "phönix", "empress", "kaiserin", "glaive", "fire queen", "firebird", "feuervogel", "fenix"])
	var specter := not kairo and not varakh and not tobi and not jubei and not ren and not amethya and not bruno and not hikaru and not glaciem and not oryn and not zip and not raiga and not albion and not anubis and not phoenix and not xylar and has_any(lower, ["specter", "spectre", "void lance", "phantom warrior", "kristall phantom", "wraith", "crystal"])
	var valkyrie := not kairo and not varakh and not tobi and not jubei and not ren and not amethya and not bruno and not hikaru and not glaciem and not oryn and not zip and not raiga and not albion and not anubis and not phoenix and not specter and not xylar and has_any(lower, ["valkyrie", "walküre", "moe", "angel", "engel", "lichtflügel", "waifu"])
	var pyrax := not kairo and not varakh and not tobi and not jubei and not ren and not amethya and not bruno and not hikaru and not glaciem and not oryn and not zip and not raiga and not albion and not xylar and has_any(lower, ["pyrax", "glutwyvern", "glutsturm", "feuerdrache", "feuer-drache", "fire dragon", "flammenwurf"])
	var dragon := not kairo and not varakh and not tobi and not jubei and not ren and not amethya and not bruno and not hikaru and not glaciem and not oryn and not zip and not raiga and not albion and not anubis and not phoenix and not specter and not valkyrie and not xylar and not pyrax and (has_any(lower, ["drachenritter", "drake", "wyrm", "slayer", "drakon", "drache"]) or lower.contains("dragon"))
	var heavy := not kairo and not varakh and not tobi and not jubei and not ren and not amethya and not bruno and not hikaru and not glaciem and not oryn and not zip and not raiga and not albion and not anubis and not phoenix and not specter and not valkyrie and not dragon and not xylar and not pyrax and has_any(lower, ["golem", "panzer", "lavagolem", "tank", "stein", "heavy", "titan"])

	var steel_knight := has_any(lower, ["steel knight", "stahlritter", "ritter in vollplatte", "eiserner ritter", "iron knight"])
	var vanguard_soldier := has_any(lower, ["vanguard", "vanguard soldat", "heavy vanguard"])
	var sorceress_medea := has_any(lower, ["sorceress medea", "erzmagierin", "medea"])
	var skeleton_reaper := has_any(lower, ["skeleton reaper", "skelettkrieger", "skelett schnitter"])
	var mutant_titan := has_any(lower, ["mutant titan", "mutierter koloss", "abomination titan"])
	var swat_specops := has_any(lower, ["swat", "specops", "swat agent", "swat-agent"])
	var samurai_dreyar := has_any(lower, ["samurai dreyar", "dreyar", "meister samurai", "katana meister"])
	var pirate_captain := has_any(lower, ["pirate captain", "korsar", "piratenkapitaen", "freibeuter", "captain pirate"])
	var vampire_lord := has_any(lower, ["vampire lord", "vampirfuerst", "vampir", "blutfuerst", "gothic lord"])
	var wizard_sorcerer := has_any(lower, ["wizard sorcerer", "elementarmagier", "zauberer", "erzmagier", "archmage"])
	var warrok_brute := has_any(lower, ["warrok brute", "magma brute", "warrok", "daemonenkoloss", "lava brute"])

	# Five original fighters (checked first: their names never collide with others).
	var nekra := has_any(lower, ["nekra", "seelenhirtin", "knochengarten"])
	var grimbolt := has_any(lower, ["grimbolt", "goblin-tüftler", "goblin tüftler", "zeitbombe"])
	var echo := has_any(lower, ["echo das hologramm", "hologramm-androidin", "phasentausch"])
	var kettenwart := has_any(lower, ["kettenwart", "kerkermeister", "seelenketten"])
	var don_valente := has_any(lower, ["don valente", "unterweltpate", "leibwächter-geschütz"])

	var arber := has_any(lower, ["arbër", "arber", "bohrmeister", "shqiponja", "doppeladler", "doppelkopfadler", "zwei bohrmaschinen"])

	var fam := "ninja"
	if arber: fam = "arber"
	elif nekra: fam = "nekra"
	elif grimbolt: fam = "grimbolt"
	elif echo: fam = "echo"
	elif kettenwart: fam = "kettenwart"
	elif don_valente: fam = "don_valente"
	elif brunhild: fam = "brunhild"
	elif lepora: fam = "lepora"
	elif thorn_witch: fam = "thorn_witch"
	elif nyx_harvester: fam = "nyx"
	elif cat_girl: fam = "shira"
	elif blue_dragon: fam = "frostwyrm"
	elif white_sci: fam = "cyborg_mech"
	elif skeleton_dog: fam = "reaper_hound"
	elif wooden_forest: fam = "treant"
	elif nine_tailed: fam = "celestial_fox"
	elif sylvan_beast: fam = "mossback"
	elif steel_knight: fam = "steel_knight"
	elif vanguard_soldier: fam = "vanguard_soldier"
	elif sorceress_medea: fam = "sorceress_medea"
	elif skeleton_reaper: fam = "skeleton_reaper"
	elif mutant_titan: fam = "mutant_titan"
	elif swat_specops: fam = "swat_specops"
	elif samurai_dreyar: fam = "samurai_dreyar"
	elif pirate_captain: fam = "pirate_captain"
	elif vampire_lord: fam = "vampire_lord"
	elif wizard_sorcerer: fam = "wizard_sorcerer"
	elif warrok_brute: fam = "warrok_brute"
	elif kairo: fam = "kairo"
	elif varakh: fam = "varakh"
	elif xylar: fam = "xylar"
	elif pyrax: fam = "pyrax"
	elif tobi: fam = "tobi"
	elif jubei: fam = "jubei"
	elif ren: fam = "ren"
	elif amethya: fam = "amethya"
	elif bruno: fam = "bruno"
	elif hikaru: fam = "hikaru"
	elif glaciem: fam = "glaciem"
	elif oryn: fam = "oryn"
	elif zip: fam = "zip"
	elif raiga: fam = "raiga"
	elif albion: fam = "albion"
	elif anubis: fam = "anubis"
	elif phoenix: fam = "phoenix"
	elif specter: fam = "specter"
	elif valkyrie: fam = "valkyrie"
	elif dragon: fam = "dragon"
	elif heavy: fam = "golem"

	var fam_configs: Dictionary = {
		"nekra": {
			"values": [18, 26, 12, 20, 24], "element": "soul_dark", "weight": 0.9,
			"std_name": "Knochenpeitsche", "std_range": 2.3, "std_cd": 0.46, "std_windup": 0.09, "std_push": 0.22,
			"spec_name": "Knochengarten", "spec_type": "eruption", "spec_range": 4.0, "spec_cd": 3.2, "spec_windup": 0.3, "spec_push": 0.8, "spec_angle": 80.0, "spec_dmg_bonus": 1.0,
			"fname": "NEKRA (SEELENHIRTIN)", "modules": ["bone_staff", "soul_lantern"]
		},
		"grimbolt": {
			"values": [16, 20, 14, 30, 20], "element": "fire", "weight": 0.85,
			"std_name": "Schraubenschlüssel", "std_range": 1.8, "std_cd": 0.36, "std_windup": 0.06, "std_push": 0.2,
			"spec_name": "Zeitbombe", "spec_type": "mine", "spec_range": 3.0, "spec_cd": 3.0, "spec_windup": 0.2, "spec_push": 0.9, "spec_angle": 70.0, "spec_dmg_bonus": 2.0,
			"fname": "GRIMBOLT (GOBLIN-TÜFTLER)", "modules": ["wrench", "bomb_satchel"]
		},
		"echo": {
			"values": [16, 22, 14, 28, 20], "element": "plasma", "weight": 0.9,
			"std_name": "Glitch-Hieb", "std_range": 2.0, "std_cd": 0.4, "std_windup": 0.07, "std_push": 0.22,
			"spec_name": "Phasentausch", "spec_type": "swap", "spec_range": 4.0, "spec_cd": 2.6, "spec_windup": 0.16, "spec_push": 0.6, "spec_angle": 40.0, "spec_dmg_bonus": 0.5,
			"fname": "ECHO (HOLOGRAMM)", "modules": ["holo_core", "phase_emitter"]
		},
		"kettenwart": {
			"values": [28, 26, 26, 8, 12], "element": "shadow_bone", "weight": 1.35,
			"std_name": "Kettenschwung", "std_range": 2.6, "std_cd": 0.62, "std_windup": 0.16, "std_push": 0.38,
			"spec_name": "Seelenketten", "spec_type": "whirl", "spec_range": 3.6, "spec_cd": 3.4, "spec_windup": 0.28, "spec_push": 0.9, "spec_angle": 50.0, "spec_dmg_bonus": 2.0,
			"fname": "KETTENWART (KERKERMEISTER)", "modules": ["soul_chains", "iron_mask"]
		},
		"don_valente": {
			"values": [24, 24, 22, 14, 16], "element": "ki_gold", "weight": 1.2,
			"std_name": "Goldener Schlagring", "std_range": 1.9, "std_cd": 0.5, "std_windup": 0.1, "std_push": 0.3,
			"spec_name": "Leibwächter-Geschütz", "spec_type": "turret", "spec_range": 5.0, "spec_cd": 4.0, "spec_windup": 0.22, "spec_push": 0.5, "spec_angle": 25.0, "spec_dmg_bonus": 0.0,
			"fname": "DON VALENTE (UNTERWELTPATE)", "modules": ["gold_knuckles", "fedora"]
		},
		"arber": {
			"values": [24, 26, 20, 18, 12], "element": "metal_drill", "weight": 1.08,
			"std_name": "Doppelbohrer", "std_range": 1.9, "std_cd": 0.42, "std_windup": 0.07, "std_push": 0.22,
			"spec_name": "Ruf der Shqiponja", "spec_type": "summon", "spec_range": 3.2, "spec_cd": 7.0, "spec_windup": 0.28, "spec_push": 0.7, "spec_angle": 60.0, "spec_dmg_bonus": 1.0,
			"fname": "ARBËR (DER BOHRMEISTER)", "modules": ["twin_drills", "double_eagle"]
		},
		"brunhild": {
			"values": [26, 28, 22, 12, 12], "element": "metal_gold", "weight": 1.40,
			"std_name": "Midas Strike", "std_range": 2.30, "std_cd": 0.58, "std_windup": 0.12, "std_push": 0.35,
			"spec_name": "Midas Quake", "spec_type": "shockwave", "spec_range": 3.80, "spec_cd": 3.6, "spec_windup": 0.32, "spec_push": 0.90, "spec_angle": 45.0, "spec_dmg_bonus": 3.0,
			"fname": "BRUNHILD (AXTKRIEGERIN)", "modules": ["golden_armor", "titan_core"]
		},
		"lepora": {
			"values": [18, 24, 14, 26, 18], "element": "wind_arrow", "weight": 0.95,
			"std_name": "Mondtritt", "std_range": 2.10, "std_cd": 0.44, "std_windup": 0.08, "std_push": 0.20,
			"spec_name": "Mist Arrow", "spec_type": "beam", "spec_range": 4.20, "spec_cd": 2.8, "spec_windup": 0.18, "spec_push": 0.65, "spec_angle": 32.0, "spec_dmg_bonus": 1.5,
			"fname": "LEPORA (MONDJÄGERIN)", "modules": ["moon_bow", "mist_quiver"]
		},
		"thorn_witch": {
			"values": [20, 26, 16, 22, 16], "element": "nature_thorn", "weight": 0.98,
			"std_name": "Bramble Whip", "std_range": 2.40, "std_cd": 0.48, "std_windup": 0.09, "std_push": 0.22,
			"spec_name": "Thorn Burst", "spec_type": "radial", "spec_range": 3.40, "spec_cd": 3.1, "spec_windup": 0.22, "spec_push": 0.70, "spec_angle": 360.0, "spec_dmg_bonus": 2.0,
			"fname": "THORN SORCERESS", "modules": ["thorn_circlet", "bramble_whip"]
		},
		"nyx": {
			"values": [22, 28, 16, 24, 10], "element": "soul_dark", "weight": 1.10,
			"std_name": "Reaper Slash", "std_range": 2.35, "std_cd": 0.46, "std_windup": 0.08, "std_push": 0.25,
			"spec_name": "Soul Reaping", "spec_type": "reach_strike", "spec_range": 3.50, "spec_cd": 3.2, "spec_windup": 0.25, "spec_push": 0.85, "spec_angle": 40.0, "spec_dmg_bonus": 2.5,
			"fname": "NYX HARVESTER", "modules": ["demon_wings", "soul_scythe"]
		},
		"shira": {
			"values": [18, 26, 14, 28, 14], "element": "claw_strike", "weight": 0.92,
			"std_name": "Feral Scratch", "std_range": 2.05, "std_cd": 0.40, "std_windup": 0.06, "std_push": 0.18,
			"spec_name": "Cat Rush Strike", "spec_type": "dash_slash", "spec_range": 3.20, "spec_cd": 2.6, "spec_windup": 0.16, "spec_push": 0.65, "spec_angle": 35.0, "spec_dmg_bonus": 1.8,
			"fname": "SHIRA (ONI-KLINGE)", "modules": ["ornate_sash", "feral_claws"]
		},
		"frostwyrm": {
			"values": [26, 28, 20, 16, 10], "element": "ice_breath", "weight": 1.35,
			"std_name": "Wyrm Tail", "std_range": 2.50, "std_cd": 0.52, "std_windup": 0.10, "std_push": 0.30,
			"spec_name": "Glacial Breath", "spec_type": "beam", "spec_range": 4.00, "spec_cd": 3.6, "spec_windup": 0.30, "spec_push": 0.85, "spec_angle": 42.0, "spec_dmg_bonus": 2.5,
			"fname": "FROSTWYRM", "modules": ["blue_scales", "frost_breath"]
		},
		"cyborg_mech": {
			"values": [20, 26, 22, 18, 14], "element": "plasma_pulse", "weight": 1.20,
			"std_name": "Mech Strike", "std_range": 2.20, "std_cd": 0.48, "std_windup": 0.09, "std_push": 0.24,
			"spec_name": "Plasma Burst", "spec_type": "beam", "spec_range": 3.80, "spec_cd": 3.2, "spec_windup": 0.24, "spec_push": 0.78, "spec_angle": 38.0, "spec_dmg_bonus": 2.0,
			"fname": "CYBORG MECH", "modules": ["joint_plating", "plasma_cannon"]
		},
		"reaper_hound": {
			"values": [18, 28, 14, 28, 12], "element": "death_bite", "weight": 0.90,
			"std_name": "Shadow Bite", "std_range": 2.10, "std_cd": 0.42, "std_windup": 0.07, "std_push": 0.20,
			"spec_name": "Grave Maw", "spec_type": "reach_strike", "spec_range": 3.30, "spec_cd": 2.8, "spec_windup": 0.20, "spec_push": 0.75, "spec_angle": 35.0, "spec_dmg_bonus": 2.2,
			"fname": "REAPER HOUND", "modules": ["bone_collar", "shadow_fang"]
		},
		"treant": {
			"values": [28, 24, 24, 12, 12], "element": "wood_root", "weight": 1.45,
			"std_name": "Branch Slam", "std_range": 2.40, "std_cd": 0.60, "std_windup": 0.14, "std_push": 0.38,
			"spec_name": "Verdant Root Crush", "spec_type": "shockwave", "spec_range": 3.70, "spec_cd": 3.7, "spec_windup": 0.35, "spec_push": 0.95, "spec_angle": 48.0, "spec_dmg_bonus": 3.0,
			"fname": "ANCIENT TREANT", "modules": ["bark_carapace", "verdant_root"]
		},
		"celestial_fox": {
			"values": [22, 28, 16, 24, 10], "element": "nine_fire", "weight": 1.05,
			"std_name": "Tail Whip", "std_range": 2.30, "std_cd": 0.46, "std_windup": 0.08, "std_push": 0.22,
			"spec_name": "Celestial Foxfire", "spec_type": "radial", "spec_range": 3.60, "spec_cd": 3.3, "spec_windup": 0.24, "spec_push": 0.80, "spec_angle": 360.0, "spec_dmg_bonus": 2.5,
			"fname": "CELESTIAL KYUUBI", "modules": ["fox_orb", "nine_tails"]
		},
		"mossback": {
			"values": [26, 26, 22, 14, 12], "element": "wood_beast", "weight": 1.30,
			"std_name": "Sylvan Charge", "std_range": 2.35, "std_cd": 0.50, "std_windup": 0.10, "std_push": 0.32,
			"spec_name": "Forest Stomp", "spec_type": "shockwave", "spec_range": 3.60, "spec_cd": 3.4, "spec_windup": 0.28, "spec_push": 0.88, "spec_angle": 45.0, "spec_dmg_bonus": 2.6,
			"fname": "MOSSBACK (STEINBESTIE)", "modules": ["moss_hide", "sylvan_horn"]
		},
		"steel_knight": {
			"values": [24, 24, 26, 12, 14], "element": "metal", "weight": 1.15,
			"std_name": "Ritterschlag", "std_range": 2.20, "std_cd": 0.50, "std_windup": 0.10, "std_push": 0.28,
			"spec_name": "Schildstoß", "spec_type": "shockwave", "spec_range": 3.40, "spec_cd": 3.2, "spec_windup": 0.22, "spec_push": 0.85, "spec_angle": 40.0, "spec_dmg_bonus": 2.0,
			"fname": "CARDINAL (ROTER MÖNCH)", "modules": ["plate_armor", "iron_blade"]
		},
		"vanguard_soldier": {
			"values": [24, 24, 22, 16, 14], "element": "plasma", "weight": 1.10,
			"std_name": "Vanguard-Hieb", "std_range": 2.10, "std_cd": 0.44, "std_windup": 0.08, "std_push": 0.22,
			"spec_name": "Photonen-Salve", "spec_type": "beam", "spec_range": 3.90, "spec_cd": 3.0, "spec_windup": 0.20, "spec_push": 0.70, "spec_angle": 30.0, "spec_dmg_bonus": 1.8,
			"fname": "VANGUARD SOLDIER", "modules": ["cyber_armor", "plasma_cannon"]
		},
		"sorceress_medea": {
			"values": [14, 28, 12, 20, 26], "element": "dark_magic", "weight": 0.90,
			"std_name": "Arkaner Impuls", "std_range": 2.30, "std_cd": 0.45, "std_windup": 0.08, "std_push": 0.20,
			"spec_name": "Astral-Explosion", "spec_type": "radial", "spec_range": 3.60, "spec_cd": 3.2, "spec_windup": 0.22, "spec_push": 0.75, "spec_angle": 360.0, "spec_dmg_bonus": 2.2,
			"fname": "ERZMAGIERIN MEDEA", "modules": ["arcane_robe", "astral_orb"]
		},
		"skeleton_reaper": {
			"values": [16, 26, 14, 24, 20], "element": "shadow_bone", "weight": 0.90,
			"std_name": "Knochenklinge", "std_range": 2.15, "std_cd": 0.42, "std_windup": 0.07, "std_push": 0.22,
			"spec_name": "Seelenernte", "spec_type": "beam", "spec_range": 3.80, "spec_cd": 3.0, "spec_windup": 0.20, "spec_push": 0.72, "spec_angle": 32.0, "spec_dmg_bonus": 2.0,
			"fname": "FLAYER (HÄUTER)", "modules": ["bone_scythe", "death_mantle"]
		},
		"mutant_titan": {
			"values": [28, 28, 24, 10, 10], "element": "acid", "weight": 1.35,
			"std_name": "Mutantenfaust", "std_range": 2.35, "std_cd": 0.56, "std_windup": 0.12, "std_push": 0.35,
			"spec_name": "Gift-Schockwelle", "spec_type": "shockwave", "spec_range": 3.60, "spec_cd": 3.5, "spec_windup": 0.30, "spec_push": 0.90, "spec_angle": 45.0, "spec_dmg_bonus": 2.5,
			"fname": "MUTANT TITAN", "modules": ["mutant_skin", "colossus_strike"]
		},
		"swat_specops": {
			"values": [20, 22, 20, 20, 18], "element": "electric", "weight": 1.04,
			"std_name": "Taktischer Schlag", "std_range": 2.05, "std_cd": 0.40, "std_windup": 0.06, "std_push": 0.20,
			"spec_name": "Schock-Granate", "spec_type": "shockwave", "spec_range": 3.40, "spec_cd": 2.8, "spec_windup": 0.18, "spec_push": 0.65, "spec_angle": 35.0, "spec_dmg_bonus": 1.5,
			"fname": "SWAT SPECOPS", "modules": ["tactical_vest", "shock_grenade"]
		},
		"samurai_dreyar": {
			"values": [20, 28, 16, 22, 14], "element": "wind_slash", "weight": 1.05,
			"std_name": "Klingenwirbel", "std_range": 2.25, "std_cd": 0.46, "std_windup": 0.08, "std_push": 0.25,
			"spec_name": "Drachenschneide", "spec_type": "dash_slash", "spec_range": 3.40, "spec_cd": 3.0, "spec_windup": 0.22, "spec_push": 0.78, "spec_angle": 38.0, "spec_dmg_bonus": 2.0,
			"fname": "KOMMANDANT (SILBERWOLF)", "modules": ["samurai_armor", "twin_katanas"]
		},
		"pirate_captain": {
			"values": [22, 26, 18, 20, 14], "element": "water", "weight": 1.08,
			"std_name": "Entermesser-Hieb", "std_range": 2.10, "std_cd": 0.44, "std_windup": 0.08, "std_push": 0.24,
			"spec_name": "Breitseiten-Schuss", "spec_type": "beam", "spec_range": 3.60, "spec_cd": 3.2, "spec_windup": 0.24, "spec_push": 0.80, "spec_angle": 35.0, "spec_dmg_bonus": 2.2,
			"fname": "SERAPHINE (KORSARIN)", "modules": ["corsair_coat", "flintlock_cutlass"]
		},
		"vampire_lord": {
			"values": [18, 28, 14, 22, 18], "element": "blood_oni", "weight": 1.02,
			"std_name": "Blutkrallen", "std_range": 2.15, "std_cd": 0.42, "std_windup": 0.07, "std_push": 0.22,
			"spec_name": "Karmesin-Nebel", "spec_type": "radial", "spec_range": 3.50, "spec_cd": 3.0, "spec_windup": 0.20, "spec_push": 0.75, "spec_angle": 360.0, "spec_dmg_bonus": 2.5,
			"fname": "VAMPIRFÜRST VLAD", "modules": ["vampire_cape", "blood_chalice"]
		},
		"wizard_sorcerer": {
			"values": [14, 30, 12, 18, 26], "element": "fire", "weight": 0.92,
			"std_name": "Flammenfunke", "std_range": 2.35, "std_cd": 0.48, "std_windup": 0.09, "std_push": 0.20,
			"spec_name": "Meteor-Schauer", "spec_type": "shockwave", "spec_range": 3.80, "spec_cd": 3.4, "spec_windup": 0.28, "spec_push": 0.85, "spec_angle": 45.0, "spec_dmg_bonus": 3.0,
			"fname": "ERZMAGIER PYRUS", "modules": ["wizard_robe", "elemental_staff"]
		},
		"warrok_brute": {
			"values": [30, 30, 26, 6, 8], "element": "fire", "weight": 1.45,
			"std_name": "Magmaschlag", "std_range": 2.40, "std_cd": 0.62, "std_windup": 0.15, "std_push": 0.40,
			"spec_name": "Vulkan-Eruption", "spec_type": "shockwave", "spec_range": 3.70, "spec_cd": 3.6, "spec_windup": 0.35, "spec_push": 0.95, "spec_angle": 50.0, "spec_dmg_bonus": 3.5,
			"fname": "WARROK KOLOSS", "modules": ["magma_carapace", "volcanic_fists"]
		},
		"pyrax": {
			"values": [22, 28, 18, 20, 12], "element": "fire", "weight": 1.15,
			"std_name": "Glutklaue", "std_range": 2.30, "std_cd": 0.48, "std_windup": 0.09, "std_push": 0.28,
			"spec_name": "Glutsturm", "spec_type": "fire_burst", "spec_range": 3.65, "spec_cd": 3.4, "spec_windup": 0.28, "spec_push": 0.72, "spec_angle": 38.0, "spec_dmg_bonus": 2.0,
			"fname": "PYRAX (GLUTWYVERN)", "modules": ["flame_tail", "dragon_wings"]
		},
		"xylar": {
			"values": [20, 28, 16, 22, 14], "element": "ki_purple", "weight": 1.02,
			"std_name": "Leerenpeitsche", "std_range": 2.20, "std_cd": 0.48, "std_windup": 0.09, "std_push": 0.24,
			"spec_name": "Nadelstrahl", "spec_type": "beam", "spec_range": 3.70, "spec_cd": 3.4, "spec_windup": 0.24, "spec_push": 0.78, "spec_angle": 38.0, "spec_dmg_bonus": 2.0,
			"fname": "XYLAR (LEERENKAISER)", "modules": ["void_carapace", "void_needle"]
		},
		"kairo": {
			"values": [20, 26, 16, 20, 18], "element": "ki_purple", "weight": 1.05,
			"std_name": "Standard Strike", "std_range": 2.15, "std_cd": 0.57, "std_windup": 0.12, "std_push": 0.20,
			"spec_name": "Solar-Kanone", "spec_type": "beam", "spec_range": 3.60, "spec_cd": 3.4, "spec_windup": 0.36, "spec_push": 0.72, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "KAIRO (STURMMÖNCH)", "modules": ["storm_robe", "sun_staff"]
		},
		"varakh": {
			"values": [18, 28, 16, 22, 16], "element": "ki_gold", "weight": 1.06,
			"std_name": "Prinzenschlag", "std_range": 2.10, "std_cd": 0.54, "std_windup": 0.11, "std_push": 0.26,
			"spec_name": "Nova-Strahl", "spec_type": "beam", "spec_range": 3.60, "spec_cd": 3.5, "spec_windup": 0.38, "spec_push": 0.78, "spec_angle": 42.0, "spec_dmg_bonus": 2.0,
			"fname": "VARAKH (SCHARLACHFÜRST)", "modules": ["scarlet_plate", "nova_core"]
		},
		"tobi": {
			"values": [18, 28, 16, 26, 12], "element": "rubber", "weight": 0.95,
			"std_name": "Standard Strike", "std_range": 2.85, "std_cd": 0.52, "std_windup": 0.10, "std_push": 0.28,
			"spec_name": "Schleuderfaust", "spec_type": "reach_strike", "spec_range": 3.20, "spec_cd": 2.9, "spec_windup": 0.28, "spec_push": 0.75, "spec_angle": 35.0, "spec_dmg_bonus": 0.0,
			"fname": "TOBI (FEDERFAUST)", "modules": ["spring_bracers", "sling_fist"]
		},
		"jubei": {
			"values": [22, 28, 18, 18, 14], "element": "wind_slash", "weight": 1.12,
			"std_name": "Windklingenhieb", "std_range": 2.40, "std_cd": 0.50, "std_windup": 0.10, "std_push": 0.28,
			"spec_name": "Sturmschnitt", "spec_type": "dash_slash", "spec_range": 3.10, "spec_cd": 3.0, "spec_windup": 0.24, "spec_push": 0.75, "spec_angle": 38.0, "spec_dmg_bonus": 0.0,
			"fname": "JUBEI (WINDKLINGE)", "modules": ["wind_blades", "storm_katana"]
		},
		"ren": {
			"values": [22, 24, 16, 24, 14], "element": "wind_spiral", "weight": 0.98,
			"std_name": "Wirbelkombo", "std_range": 2.05, "std_cd": 0.48, "std_windup": 0.09, "std_push": 0.22,
			"spec_name": "Blütenwirbel", "spec_type": "vortex_strike", "spec_range": 3.00, "spec_cd": 2.8, "spec_windup": 0.20, "spec_push": 0.68, "spec_angle": 35.0, "spec_dmg_bonus": 0.0,
			"fname": "REN (KIRSCHKRIEGERIN)", "modules": ["blossom_coat", "petal_vortex"]
		},
		"amethya": {
			"values": [16, 26, 14, 28, 16], "element": "electric_arc", "weight": 0.98,
			"std_name": "Donnerschnitt", "std_range": 2.20, "std_cd": 0.46, "std_windup": 0.08, "std_push": 0.22,
			"spec_name": "Amethystblitz", "spec_type": "electric_dash", "spec_range": 3.15, "spec_cd": 2.7, "spec_windup": 0.18, "spec_push": 0.68, "spec_angle": 35.0, "spec_dmg_bonus": 0.0,
			"fname": "AMETHYA (DONNERHEXE)", "modules": ["thunder_coat", "amethyst_arc"]
		},
		"bruno": {
			"values": [24, 34, 18, 16, 8], "element": "impact_force", "weight": 1.05,
			"std_name": "Meteorhaken", "std_range": 2.25, "std_cd": 0.42, "std_windup": 0.08, "std_push": 0.32,
			"spec_name": "Meteorfaust", "spec_type": "serious_blow", "spec_range": 3.40, "spec_cd": 3.6, "spec_windup": 0.26, "spec_push": 0.85, "spec_angle": 40.0, "spec_dmg_bonus": 2.0,
			"fname": "BRUNO (EINSCHLAG-HELD)", "modules": ["impact_gauntlets", "meteor_boots"]
		},
		"hikaru": {
			"values": [20, 26, 16, 22, 16], "element": "sun_flame", "weight": 1.02,
			"std_name": "Morgenklinge", "std_range": 2.30, "std_cd": 0.50, "std_windup": 0.10, "std_push": 0.24,
			"spec_name": "Morgenrotschnitt", "spec_type": "flame_slash", "spec_range": 3.05, "spec_cd": 3.0, "spec_windup": 0.22, "spec_push": 0.70, "spec_angle": 38.0, "spec_dmg_bonus": 0.0,
			"fname": "HIKARU (GLUTKLINGE)", "modules": ["ember_mantle", "dawn_blade"]
		},
		"glaciem": {
			"values": [18, 26, 16, 24, 16], "element": "ice", "weight": 1.05,
			"std_name": "Standard Strike", "std_range": 1.80, "std_cd": 0.54, "std_windup": 0.10, "std_push": 0.20,
			"spec_name": "Eissplitter", "spec_type": "ice_slow", "spec_range": 2.55, "spec_cd": 2.8, "spec_windup": 0.26, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "GLACIEM (FROSTASSASSINE)", "modules": ["frost_mantle", "ice_dagger"]
		},
		"oryn": {
			"values": [20, 27, 17, 19, 17], "element": "gravity", "weight": 1.05,
			"std_name": "Standard Strike", "std_range": 2.30, "std_cd": 0.56, "std_windup": 0.11, "std_push": 0.20,
			"spec_name": "Abstoßungswelle", "spec_type": "radial_blast", "spec_range": 3.00, "spec_cd": 3.0, "spec_windup": 0.30, "spec_push": 0.62, "spec_angle": 45.0, "spec_dmg_bonus": 0.0,
			"fname": "ORYN (SCHWERKRAFTPROPHET)", "modules": ["rune_halo", "gravity_robe"]
		},
		"zip": {
			"values": [16, 22, 14, 34, 14], "element": "wind", "weight": 0.88,
			"std_name": "Standard Strike", "std_range": 1.65, "std_cd": 0.44, "std_windup": 0.08, "std_push": 0.22,
			"spec_name": "Turbo-Sprint", "spec_type": "electric_dash", "spec_range": 3.35, "spec_cd": 2.6, "spec_windup": 0.16, "spec_push": 0.65, "spec_angle": 35.0, "spec_dmg_bonus": 0.0,
			"fname": "ZIP (BLITZKURIER)", "modules": ["jet_boots", "turbo_core"]
		},
		"raiga": {
			"values": [22, 28, 16, 22, 12], "element": "blood_oni", "weight": 1.02,
			"std_name": "Donnerhieb", "std_range": 2.10, "std_cd": 0.48, "std_windup": 0.09, "std_push": 0.24,
			"spec_name": "Sternschlag", "spec_type": "radial_blast", "spec_range": 2.80, "spec_cd": 2.7, "spec_windup": 0.22, "spec_push": 0.70, "spec_angle": 40.0, "spec_dmg_bonus": 0.0,
			"fname": "RAIGA (DONNERFAUST)", "modules": ["thunder_fists", "star_sigil"]
		},
		"albion": {
			"values": [22, 30, 20, 18, 10], "element": "holy_light", "weight": 1.28,
			"std_name": "Silberklaue", "std_range": 2.20, "std_cd": 0.54, "std_windup": 0.11, "std_push": 0.26,
			"spec_name": "Sturmstrahl", "spec_type": "beam", "spec_range": 3.40, "spec_cd": 3.2, "spec_windup": 0.30, "spec_push": 0.72, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "ALBION (SILBERWYRM)", "modules": ["dragon_plate", "storm_breath"]
		},
		"anubis": {
			"values": [20, 28, 18, 18, 16], "element": "shadow_gold", "weight": 1.08,
			"std_name": "Standard Strike", "std_range": 2.10, "std_cd": 0.62, "std_windup": 0.13, "std_push": 0.20,
			"spec_name": "Anubis Wrath", "spec_type": "curse_strike", "spec_range": 2.70, "spec_cd": 3.1, "spec_windup": 0.30, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "AURUM (GOLDKONSTRUKT)", "modules": ["anubis_armor", "khopesh"]
		},
		"phoenix": {
			"values": [19, 24, 15, 20, 22], "element": "fire", "weight": 0.98,
			"std_name": "Standard Strike", "std_range": 2.00, "std_cd": 0.55, "std_windup": 0.11, "std_push": 0.20,
			"spec_name": "Phoenix Flare", "spec_type": "flame_wave", "spec_range": 2.75, "spec_cd": 3.0, "spec_windup": 0.29, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "SCARLET (FEUERJÄGERIN)", "modules": ["feather_armor", "phoenix_glaive"]
		},
		"specter": {
			"values": [16, 25, 17, 22, 20], "element": "void", "weight": 0.98,
			"std_name": "Standard Strike", "std_range": 2.20, "std_cd": 0.58, "std_windup": 0.11, "std_push": 0.20,
			"spec_name": "Void Lance", "spec_type": "void_strike", "spec_range": 2.90, "spec_cd": 2.9, "spec_windup": 0.28, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "RAVENNA (SCHATTENKLINGE)", "modules": ["crystal_armor", "void_lance"]
		},
		"valkyrie": {
			"values": [17, 22, 16, 23, 22], "element": "holy", "weight": 1.05,
			"std_name": "Standard Strike", "std_range": 1.85, "std_cd": 0.52, "std_windup": 0.10, "std_push": 0.20,
			"spec_name": "Radiant Pierce", "spec_type": "holy_pierce", "spec_range": 2.45, "spec_cd": 3.2, "spec_windup": 0.32, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "BOLTAR (ARMBRUSTRITTER)", "modules": ["radiant_armor", "light_rapier"]
		},
		"dragon": {
			"values": [23, 26, 21, 15, 15], "element": "fire", "weight": 1.20,
			"std_name": "Standard Strike", "std_range": 1.95, "std_cd": 0.72, "std_windup": 0.16, "std_push": 0.20,
			"spec_name": "Wyrm Flame", "spec_type": "fire_breath", "spec_range": 2.85, "spec_cd": 3.5, "spec_windup": 0.38, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "TEMPLAR (KREUZRITTER)", "modules": ["dragon_plate", "greatsword"]
		},
		"golem": {
			"values": [27, 24, 27, 10, 12], "element": "fire", "weight": 1.32,
			"std_name": "Standard Strike", "std_range": 1.55, "std_cd": 0.90, "std_windup": 0.22, "std_push": 0.20,
			"spec_name": "Magma Quake", "spec_type": "ground_quake", "spec_range": 2.25, "spec_cd": 3.1, "spec_windup": 0.35, "spec_push": 0.62, "spec_angle": 52.0, "spec_dmg_bonus": 0.0,
			"fname": "MAGMOR (GLUTOGER)", "modules": ["basalt", "gauntlets"]
		},
		"ninja": {
			"values": [18, 20, 14, 29, 19], "element": "shadow", "weight": 0.92,
			"std_name": "Standard Strike", "std_range": 1.75, "std_cd": 0.60, "std_windup": 0.12, "std_push": 0.20,
			"spec_name": "Raijin Dash", "spec_type": "electric_dash", "spec_range": 2.40, "spec_cd": 3.3, "spec_windup": 0.35, "spec_push": 0.62, "spec_angle": 42.0, "spec_dmg_bonus": 0.0,
			"fname": "VOLT SHADOW", "modules": ["shadow_armor", "twin_blades"]
		}
	}

	var cfg: Dictionary = fam_configs[fam]
	var values: Array = cfg.values.duplicate()
	for n in range(8):
		var a := rng.randi_range(0, 4)
		var b := rng.randi_range(0, 4)
		if a != b and values[a] > 8 and values[b] < 36:
			values[a] -= 1
			values[b] += 1
	var stats := {}
	for n in range(5): stats[STAT_KEYS[n]] = values[n]

	var element: String = cfg.element
	for candidate in ELEMENTS:
		if has_any(lower, ELEMENTS[candidate]):
			element = candidate
			break

	var colors := {"electric": Color("43e5ff"), "fire": Color("ff733e"), "ice": Color("b4e5ff"), "wind": Color("9dffcd"), "shadow": Color("b19dff"), "holy": Color("ffe26a"), "shadow_gold": Color("c9a227"), "void": Color("9b30ff"), "ki_purple": Color("b347ff"), "ki_gold": Color("ffe838"), "gravity": Color("9900ee"), "rubber": Color("ff2b2b"), "wind_slash": Color("3bfac8"), "wind_spiral": Color("4ae0ff"), "electric_arc": Color("60d5ff"), "impact_force": Color("ff4040"), "sun_flame": Color("ff6524"), "blood_oni": Color("00e5ff"), "holy_light": Color("70d6ff"), "water": Color("38bdf8"), "metal": Color("cbd5e1"), "dark_magic": Color("c084fc"), "shadow_bone": Color("a78bfa"), "acid": Color("84cc16"), "plasma": Color("5eead4"), "soul_dark": Color("a855f7")}

	var standard := {
		"name": cfg.std_name,
		"damage": 6.0 + stats.power * 0.24, "range": cfg.std_range,
		"cooldown": cfg.std_cd, "windup": cfg.std_windup,
		"active": 0.08, "recovery": 0.14,
		"cost": 20, "push": cfg.std_push,
		"angle": 28.0, "hitstun": 0.20
	}
	var special := {
		"name": cfg.spec_name,
		"type": cfg.spec_type,
		"damage": 16.0 + stats.power * 0.32 + cfg.spec_dmg_bonus, "range": cfg.spec_range,
		"cooldown": cfg.spec_cd, "windup": cfg.spec_windup,
		"active": 0.16, "recovery": 0.28,
		"cost": 40, "push": cfg.spec_push,
		"angle": cfg.spec_angle, "hitstun": 0.38
	}

	var profile := {
		"prompt": text, "slot": slot, "seed": seed_value, "family": fam,
		"name": cfg.fname, "element": element,
		"modules": cfg.modules,
		"color": colors.get(element, Color("9b30ff")), "stats": stats, "standard": standard, "special": special,
		"health": 90.0 + stats.vitality * 1.6, "speed": 2.3 + stats.speed * 0.065,
		"weight": clampf(cfg.weight, 0.85, 1.35)
	}
	# The fighter kit (fighter_kits.gd) sets role, weight, run speed and attack names.
	var kit: Dictionary = FighterKits.for_family(fam)
	if not kit.is_empty():
		profile["archetype"] = kit.archetype
		if kit.has("weight"): profile.weight = float(kit.weight)
		if kit.has("speed"): profile.speed = float(kit.speed)
		if kit.has("standard_name"): standard.name = kit.standard_name
		if kit.has("special_name"): special.name = kit.special_name
	return profile

static func has_any(text: String, words: Array) -> bool:
	for word in words:
		if text.contains(word): return true
	return false

static func valid(p: Dictionary) -> bool:
	if p.get("is_remix", false) or p.has("equipment"):
		var st = p.get("stats", {})
		var t = int(st.get("vitality", 0)) + int(st.get("power", 0)) + int(st.get("defense", 0)) + int(st.get("speed", 0)) + int(st.get("technique", 0))
		return t == 100 and p.has("standard") and p.has("special")

	var total := 0
	for key in STAT_KEYS:
		var v: int = p.stats[key]
		if v < 8 or v > 36: return false
		total += v
	for key in ["standard", "special"]:
		var a: Dictionary = p[key]
		if a.damage < 3 or a.damage > 45 or a.cooldown < 0.2 or a.cooldown > 8.0: return false
		if a.range < 0.9 or a.range > 5.0: return false
	return total == 100 and p.has("family") and p.has("modules")

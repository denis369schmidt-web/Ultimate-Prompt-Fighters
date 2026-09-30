extends RefCounted
## Motion styles: how each fighter stands, runs, celebrates, taunts and goes down.
## fighter_view.gd turns a style into limb directions (_style_pose); every family has one.
##   tempo  – run cycle speed at an average run speed (scaled by the fighter's real speed)
##   sturdy – how little a hit throws the body around (0 = flails, 1 = barely moves)
##   quotes – taunt lines shown above the fighter

const STYLES := {
	"boxer": {"tempo": 12.0, "sturdy": 0.4, "quotes": ["Komm her!", "Ist das alles?", "Deckung hoch!"]},
	"ninja": {"tempo": 14.0, "sturdy": 0.2, "quotes": ["…", "Zu langsam.", "Du siehst mich nicht."]},
	"brute": {"tempo": 7.5, "sturdy": 0.8, "quotes": ["RAAAH!", "Zerquetschen!", "Mehr!"]},
	"knight": {"tempo": 9.5, "sturdy": 0.6, "quotes": ["Für die Ehre!", "Ergib dich.", "Steh auf, Feigling."]},
	"mage": {"tempo": 8.5, "sturdy": 0.3, "quotes": ["Spürst du das?", "Wie vorhergesagt.", "Lächerlich."]},
	"swordsman": {"tempo": 12.0, "sturdy": 0.4, "quotes": ["Zieh.", "Eine Klinge genügt.", "Schon vorbei."]},
	"elegant": {"tempo": 10.5, "sturdy": 0.25, "quotes": ["Zu langsam!", "Wie süß.", "Tanz mit mir!"]},
	"martial": {"tempo": 12.0, "sturdy": 0.45, "quotes": ["Noch einer!", "Konzentration!", "Ich werde stärker."]},
	"cocky": {"tempo": 11.0, "sturdy": 0.45, "quotes": ["Zu einfach.", "Kniee nieder.", "Langweilig."]},
	"floaty": {"tempo": 7.0, "sturdy": 0.3, "quotes": ["Wie niedlich.", "Unter meiner Würde.", "Noch ein Versuch?"]},
	"trickster": {"tempo": 13.5, "sturdy": 0.15, "quotes": ["Hehe!", "Fang mich doch!", "Ätsch!"]},
	"stoic": {"tempo": 9.0, "sturdy": 0.7, "quotes": ["Hm.", "Ok.", "Ich hab Hunger."]},
	"beast": {"tempo": 12.5, "sturdy": 0.55, "quotes": ["GRRRR!", "*schnaub*", "KRRAAH!"]},
	"undead": {"tempo": 6.0, "sturdy": 0.5, "quotes": ["Knochen… knacken…", "Du gehörst mir…", "Hhhhh…"]},
}

const FAMILY_STYLE := {
	"ninja": "ninja", "golem": "brute", "valkyrie": "elegant", "dragon": "knight", "kairo": "martial", "varakh": "cocky",
	"xylar": "floaty", "glaciem": "ninja", "oryn": "mage", "tobi": "trickster", "jubei": "swordsman", "ren": "trickster",
	"amethya": "swordsman", "bruno": "stoic", "hikaru": "swordsman", "zip": "trickster", "raiga": "boxer",
	"albion": "beast", "pyrax": "beast", "anubis": "knight", "specter": "floaty", "phoenix": "elegant",
	"golden_golem": "brute", "lepora": "elegant", "tripo_fantasy_female": "mage", "tripo_nyx_harvester": "floaty",
	"tripo_cat_girl": "trickster", "tripo_dragon_blue": "beast", "tripo_white_sci": "knight", "tripo_skeleton_dog": "beast",
	"tripo_wooden_forest": "brute", "tripo_nine_tailed": "floaty", "tripo_quadruped_tree": "beast", "steel_knight": "knight",
	"vanguard_soldier": "knight", "sorceress_medea": "mage", "skeleton_reaper": "undead", "mutant_titan": "brute",
	"swat_specops": "boxer", "samurai_dreyar": "swordsman", "pirate_captain": "cocky", "vampire_lord": "floaty",
	"wizard_sorcerer": "mage", "warrok_brute": "brute", "nekra": "undead", "grimbolt": "trickster", "echo": "trickster",
	"kettenwart": "brute", "don_valente": "cocky",
}

static func style_of(family: String) -> String:
	return FAMILY_STYLE.get(family, "boxer")

static func data(style: String) -> Dictionary:
	return STYLES.get(style, STYLES["boxer"])

static func quote(family: String, seed_v: int) -> String:
	var q: Array = data(style_of(family)).quotes
	return str(q[absi(seed_v) % q.size()])

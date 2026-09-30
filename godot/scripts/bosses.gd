extends RefCounted
## Boss enemies: the nine choirs of angels (heaven) and ten princes of hell with their vices.
## Data only – the behaviour runs in combat.gd (_boss_update), the bodies in boss_models.gd.
##
## Per boss: name, title, realm, vice/virtue, color, arena (boss level), hp (for two heroes,
## scaled by hero count), dmg (base damage), hover (height of its lower edge), body_w/body_h
## (hurtbox), model (boss_models.gd builder), patterns per phase (phase 2 at half health), intro.
## body/look/height: a sculpted, textured 3D body (animated through the fighter pose system)
## restyled as living marble, gold, obsidian … and decorated with wings, halo, horns (boss_models.gd).

## Heaven from the lowest to the highest choir (Dante's spheres), hell circle by circle.
const HEAVEN := ["angelus", "michael", "principatus", "potestas", "virtus", "dominatio", "ophan", "cherub", "seraph"]
const HELL := ["ahriman", "lilith", "asmodeus", "beelzebub", "mammon", "baphomet", "belphegor", "bel_marduk", "leviathan", "lucifer"]
const ORDER := HEAVEN + HELL

const BOSSES := {
	# ── Himmelreich ──
	"angelus": {"name": "ANGELUS", "title": "WÄCHTER DES MONDES", "realm": "heaven", "vice": "Beständigkeit", "color": Color("bfe3ff"),
		"arena": "heaven_spheres", "hp": 450.0, "dmg": 11.0, "hover": 0.5, "body_w": 0.9, "body_h": 3.2, "body": "res://assets/models/mixamo/eve_warrior.glb", "look": "marble", "height": 3.2, "speed": 2.6, "model": "angelus",
		"patterns": [["feather_volley", "sweep_short", "wing_gale"], ["feather_volley", "sweep_short", "wing_gale", "holy_rain"]],
		"intro": "Der erste Wächter prüft, ob dein Wille hält, was er verspricht."},
	"michael": {"name": "MICHAEL", "title": "ERZENGEL DES SCHWERTES", "realm": "heaven", "vice": "Ruhm", "color": Color("ffcf4a"),
		"arena": "heaven_spheres", "hp": 520.0, "dmg": 12.0, "hover": 0.5, "body_w": 1.0, "body_h": 3.4, "body": "res://assets/models/mixamo/paladin_armed.glb", "look": "gold", "height": 3.4, "speed": 2.6, "model": "michael",
		"patterns": [["sword_sweep", "dive", "feather_volley"], ["sword_sweep", "dive", "feather_volley", "judgement_beam"]],
		"intro": "Sein Schwert fragt nicht nach deinem Namen – nur nach deinem Mut."},
	"principatus": {"name": "PRINCIPATUS", "title": "FÜRST DER VÖLKER", "realm": "heaven", "vice": "Liebe", "color": Color("ff6b8a"),
		"arena": "heaven_spheres", "hp": 580.0, "dmg": 12.0, "hover": 0.6, "body_w": 1.0, "body_h": 3.3, "body": "res://assets/models/mixamo/sorceress_medea.glb", "look": "rose", "height": 3.3, "speed": 2.4, "model": "principatus",
		"patterns": [["thorn_volley", "wreath_ring", "wing_gale"], ["thorn_volley", "wreath_ring", "wing_gale", "holy_rain"]],
		"intro": "Kränze aus Rosen – und aus Dornen. Wer liebt, muss beides tragen."},
	"potestas": {"name": "POTESTAS", "title": "DIE GEWALT DES HIMMELS", "realm": "heaven", "vice": "Weisheit", "color": Color("ffa94d"),
		"arena": "heaven_spheres", "hp": 640.0, "dmg": 13.0, "hover": 0.5, "body_w": 1.0, "body_h": 3.4, "body": "res://assets/models/mixamo/steel_knight.glb", "look": "silver", "height": 3.4, "speed": 2.5, "model": "potestas",
		"patterns": [["spear_rain", "charge", "sweep_short"], ["spear_rain", "charge", "sweep_short", "fire_pillars"]],
		"intro": "Die Gewalten halten die Dämonen an der Kette. Heute halten sie dich."},
	"virtus": {"name": "VIRTUS", "title": "DIE TUGEND", "realm": "heaven", "vice": "Tapferkeit", "color": Color("9be7ff"),
		"arena": "heaven_spheres", "hp": 700.0, "dmg": 13.0, "hover": 0.6, "body_w": 1.0, "body_h": 3.3, "body": "res://assets/models/mixamo/maria_prop.glb", "look": "pearl", "height": 3.3, "speed": 2.2, "model": "virtus",
		"patterns": [["scroll_beam", "fire_pillars", "stillness"], ["scroll_beam", "fire_pillars", "stillness", "scepter_orbs"]],
		"intro": "Auf ihrer Schriftrolle steht jede Tat, die du begangen hast."},
	"dominatio": {"name": "DOMINATIO", "title": "DIE HERRSCHAFT", "realm": "heaven", "vice": "Gerechtigkeit", "color": Color("e9d5ff"),
		"arena": "heaven_spheres", "hp": 760.0, "dmg": 14.0, "hover": 0.6, "body_w": 1.1, "body_h": 3.4, "body": "res://assets/models/mixamo/monk_ganfaul.glb", "look": "ivory", "height": 3.4, "speed": 2.2, "model": "dominatio",
		"patterns": [["judgement_beam", "scepter_orbs", "dive"], ["judgement_beam", "scepter_orbs", "dive", "holy_nova"]],
		"intro": "Das Zepter der Herrschaft wiegt jede Seele – auch deine."},
	"ophan": {"name": "OPHANIEL", "title": "DER RÄDERTHRON", "realm": "heaven", "vice": "Kontemplation", "color": Color("ffd24a"),
		"arena": "wheel_heaven", "hp": 820.0, "dmg": 15.0, "hover": 1.1, "body_w": 1.6, "body_h": 3.4, "speed": 2.0, "model": "ophan",
		"patterns": [["eye_lasers", "wheel_roll", "ring_burst"], ["eye_lasers", "wheel_roll", "ring_burst", "eye_storm"]],
		"intro": "Räder in Rädern, voller Augen ringsum."},
	"cherub": {"name": "KERUVIM", "title": "WÄCHTER DES TORES", "realm": "heaven", "vice": "Glaube", "color": Color("ff8a1f"),
		"arena": "heaven_gate", "hp": 880.0, "dmg": 15.0, "hover": 1.0, "body_w": 1.3, "body_h": 3.3, "speed": 2.4, "model": "cherub",
		"patterns": [["sword_sweep", "fire_breath", "wing_gale"], ["sword_sweep", "fire_breath", "wing_gale", "dive"]],
		"intro": "Vier Gesichter. Ein Flammenschwert. Kein Durchgang."},
	"seraph": {"name": "SERAPHAEL", "title": "DAS BRENNENDE AUGE", "realm": "heaven", "vice": "Liebe, die brennt", "color": Color("ff3b1f"),
		"arena": "empyrean", "hp": 1000.0, "dmg": 16.0, "hover": 1.2, "body_w": 1.8, "body_h": 3.6, "speed": 1.8, "model": "seraph",
		"patterns": [["judgement_beam", "feather_storm", "fire_pillars"], ["judgement_beam", "feather_storm", "fire_pillars", "holy_nova"]],
		"intro": "Sechs Flügel. Ein Blick. Es sieht dich."},
	# ── Höllenreich ──
	"ahriman": {"name": "AHRIMAN", "title": "DIE LEERE HÜLLE", "realm": "hell", "vice": "Materialismus", "color": Color("b91c1c"),
		"arena": "hell_gate", "hp": 450.0, "dmg": 11.0, "hover": 0.8, "body_w": 1.4, "body_h": 3.4, "body": "res://assets/polyhaven/models/marble_bust_01/marble_bust_01.gltf", "look": "obsidian", "height": 3.4, "speed": 1.8, "model": "ahriman",
		"patterns": [["eye_lasers", "mask_crush", "void_pull"], ["eye_lasers", "mask_crush", "void_pull", "ring_burst"]],
		"intro": "Ein Gesicht ohne Seele. Alles, was ihr besitzen wolltet – und nichts darin."},
	"lilith": {"name": "LILITH", "title": "DIE VERFÜHRERIN", "realm": "hell", "vice": "Verführung", "color": Color("f472b6"),
		"arena": "hell_flames", "hp": 520.0, "dmg": 12.0, "hover": 0.4, "body_w": 1.0, "body_h": 3.3, "body": "res://assets/models/mixamo/arissa_fighter.glb", "look": "obsidian", "height": 3.3, "speed": 2.6, "model": "lilith",
		"patterns": [["charm_pull", "owl_swarm", "moon_ring"], ["charm_pull", "owl_swarm", "moon_ring", "lust_flames"]],
		"intro": "Ihre Stimme ist Honig. Ihre Krallen sind es nicht."},
	"asmodeus": {"name": "ASMODEUS", "title": "FÜRST DER WOLLUST", "realm": "hell", "vice": "Wollust", "color": Color("e11d48"),
		"arena": "hell_flames", "hp": 580.0, "dmg": 12.0, "hover": 0.1, "body_w": 1.0, "body_h": 3.3, "body": "res://assets/models/mixamo/cop_zombie.glb", "look": "bone", "height": 3.3, "speed": 2.4, "model": "asmodeus",
		"patterns": [["lust_flames", "charm_pull", "sweep_short"], ["lust_flames", "charm_pull", "sweep_short", "dive"]],
		"intro": "Der Sturm der Begierde trägt ihn – und jeden, der ihm nachgibt."},
	"beelzebub": {"name": "BEELZEBUB", "title": "HERR DER FLIEGEN", "realm": "hell", "vice": "Völlerei", "color": Color("84cc16"),
		"arena": "hell_flames", "hp": 640.0, "dmg": 13.0, "hover": 1.0, "body_w": 1.5, "body_h": 3.0, "speed": 2.6, "model": "beelzebub",
		"patterns": [["fly_swarm", "acid_rain", "dive"], ["fly_swarm", "acid_rain", "dive", "fly_storm"]],
		"intro": "Er frisst. Er summt. Er ist nie satt."},
	"mammon": {"name": "MAMMON", "title": "DER GIERIGE", "realm": "hell", "vice": "Gier", "color": Color("facc15"),
		"arena": "hell_city", "hp": 700.0, "dmg": 13.0, "hover": 0.1, "body_w": 1.2, "body_h": 3.0, "body": "res://assets/models/mixamo/goblin_warrior.glb", "look": "bronze", "height": 3.0, "speed": 1.6, "model": "mammon",
		"patterns": [["coin_rain", "chest_quake", "debt_chains"], ["coin_rain", "chest_quake", "debt_chains", "gold_storm"]],
		"intro": "Er zählt jede Münze. Er zählt jede Schuld. Er zählt auch dich."},
	"baphomet": {"name": "BAPHOMET", "title": "DER ZORN", "realm": "hell", "vice": "Zorn", "color": Color("f97316"),
		"arena": "hell_city", "hp": 760.0, "dmg": 14.0, "hover": 0.3, "body_w": 1.2, "body_h": 3.6, "body": "res://assets/models/mixamo/demon_warlord.glb", "look": "obsidian", "height": 3.6, "speed": 2.2, "model": "baphomet",
		"patterns": [["fire_pillars", "dive", "ring_burst"], ["fire_pillars", "dive", "ring_burst", "fire_breath"]],
		"intro": "Halb Tier, halb Gott, ganz Zorn. Das Gleichgewicht ist zerbrochen."},
	"belphegor": {"name": "BELPHEGOR", "title": "DIE TRÄGHEIT", "realm": "hell", "vice": "Trägheit", "color": Color("a3a3a3"),
		"arena": "hell_city", "hp": 820.0, "dmg": 14.0, "hover": 0.1, "body_w": 1.2, "body_h": 3.4, "body": "res://assets/models/mixamo/warrok_brute.glb", "look": "rust", "height": 3.4, "speed": 1.2, "model": "belphegor",
		"patterns": [["stillness", "boulder_rain", "holy_nova"], ["stillness", "boulder_rain", "holy_nova", "chest_quake"]],
		"intro": "Er muss nicht aufstehen. Du wirst zu ihm kommen – langsam."},
	"bel_marduk": {"name": "BEL MARDUK", "title": "DER KRIEG", "realm": "hell", "vice": "Krieg", "color": Color("dc2626"),
		"arena": "hell_flames", "hp": 880.0, "dmg": 15.0, "hover": 0.4, "body_w": 1.2, "body_h": 3.5, "body": "res://assets/models/mixamo/gladiator_heraklios.glb", "look": "bronze", "height": 3.5, "speed": 2.4, "model": "bel_marduk",
		"patterns": [["spear_rain", "charge", "sword_sweep"], ["spear_rain", "charge", "sword_sweep", "fire_pillars"]],
		"intro": "Der alte Gott der Schlachten. Er hat jeden Krieg gesegnet."},
	"leviathan": {"name": "LEVIATHAN", "title": "DER NEID", "realm": "hell", "vice": "Neid", "color": Color("38bdf8"),
		"arena": "hell_city", "hp": 940.0, "dmg": 15.0, "hover": 0.6, "body_w": 1.7, "body_h": 3.4, "body": "res://assets/models/tripo_dragon_blue.glb", "look": "abyss", "height": 3.4, "speed": 2.4, "model": "leviathan",
		"patterns": [["charge", "water_beam", "tidal_ring"], ["charge", "water_beam", "tidal_ring", "acid_rain"]],
		"intro": "Er will, was du hast. Er will, was du bist."},
	"lucifer": {"name": "LUZIFER", "title": "DER GEFALLENE", "realm": "hell", "vice": "Hochmut", "color": Color("7dd3fc"),
		"arena": "cocytus", "hp": 1100.0, "dmg": 17.0, "hover": 0.5, "body_w": 1.2, "body_h": 3.6, "body": "res://assets/models/mixamo/vampire_lord.glb", "look": "frost", "height": 3.6, "speed": 2.2, "model": "lucifer",
		"patterns": [["ice_volley", "black_beam", "dark_feathers"], ["ice_volley", "black_beam", "dark_feathers", "dark_nova", "dive"]],
		"intro": "Einst der Lichtträger. Nun eingefroren im tiefsten Eis – und hungrig nach dem Licht in dir."},
}

## Attack patterns. type: sweep | emit (radial, aimed, rain, swarm) | gale (force < 0 pulls) |
## dive | charge (ground = rolls along the floor) | ring | beam | pillars | nova | slow.
## dmg is a factor of the boss damage; color overrides the boss color; shape/speed/... shape the shots.
const PATTERNS := {
	"sword_sweep": {"type": "sweep", "len": 9.5, "lo": -0.3, "hi": 1.3, "windup": 0.9, "dmg": 1.0},
	"sweep_short": {"type": "sweep", "len": 5.5, "lo": -0.3, "hi": 1.6, "windup": 0.7, "dmg": 0.9},
	"fire_breath": {"type": "emit", "emit": "radial", "count": 3, "interval": 0.35, "dmg": 0.55, "shape": "fireball", "speed": 8.0, "life": 1.6, "size": 0.45},
	"lust_flames": {"type": "emit", "emit": "radial", "count": 3, "interval": 0.3, "dmg": 0.5, "shape": "fireball", "speed": 7.0, "life": 1.8, "size": 0.45, "color": Color("fb7185")},
	"eye_lasers": {"type": "emit", "emit": "aimed", "count": 10, "interval": 0.12, "dmg": 0.35, "shape": "bolt", "speed": 21.0, "life": 1.0, "size": 0.3},
	"eye_storm": {"type": "emit", "emit": "aimed", "count": 18, "interval": 0.08, "dmg": 0.35, "shape": "bolt", "speed": 21.0, "life": 1.0, "size": 0.3},
	"feather_volley": {"type": "emit", "emit": "aimed", "count": 8, "interval": 0.14, "dmg": 0.4, "shape": "shard", "speed": 16.0, "life": 1.1, "size": 0.35, "color": Color("f5f0e6")},
	"thorn_volley": {"type": "emit", "emit": "aimed", "count": 12, "interval": 0.1, "dmg": 0.35, "shape": "arrow", "speed": 18.0, "life": 1.0, "size": 0.3},
	"scepter_orbs": {"type": "emit", "emit": "aimed", "count": 6, "interval": 0.22, "dmg": 0.5, "shape": "orb", "speed": 9.0, "life": 1.8, "size": 0.4, "explode": 1.3},
	"ice_volley": {"type": "emit", "emit": "aimed", "count": 12, "interval": 0.1, "dmg": 0.35, "shape": "shard", "speed": 17.0, "life": 1.0, "size": 0.35, "freeze": 0.5, "color": Color("bae6fd")},
	"feather_storm": {"type": "emit", "emit": "rain", "count": 16, "interval": 0.12, "dmg": 0.45, "shape": "shard", "life": 1.6, "size": 0.35, "gravity": 6.0},
	"dark_feathers": {"type": "emit", "emit": "rain", "count": 20, "interval": 0.1, "dmg": 0.45, "shape": "shard", "life": 1.6, "size": 0.35, "gravity": 6.0, "color": Color("312e81")},
	"holy_rain": {"type": "emit", "emit": "rain", "count": 14, "interval": 0.12, "dmg": 0.45, "shape": "lance", "life": 1.6, "size": 0.35, "gravity": 4.0},
	"spear_rain": {"type": "emit", "emit": "rain", "count": 16, "interval": 0.1, "dmg": 0.5, "shape": "lance", "life": 1.6, "size": 0.35, "gravity": 6.0},
	"acid_rain": {"type": "emit", "emit": "rain", "count": 20, "interval": 0.08, "dmg": 0.35, "shape": "orb", "life": 1.6, "size": 0.25, "gravity": 8.0, "color": Color("a3e635")},
	"coin_rain": {"type": "emit", "emit": "rain", "count": 22, "interval": 0.08, "dmg": 0.4, "shape": "coin", "life": 1.6, "size": 0.3, "gravity": 9.0},
	"gold_storm": {"type": "emit", "emit": "radial", "count": 4, "interval": 0.25, "dmg": 0.45, "shape": "coin", "speed": 9.0, "life": 1.6, "size": 0.3},
	"boulder_rain": {"type": "emit", "emit": "rain", "count": 8, "interval": 0.25, "dmg": 0.9, "shape": "meteor", "life": 1.8, "size": 0.55, "gravity": 7.0, "color": Color("78716c")},
	"fly_swarm": {"type": "emit", "emit": "swarm", "count": 10, "interval": 0.12, "dmg": 0.3, "shape": "bat", "speed": 6.5, "life": 3.0, "size": 0.3, "homing": 4.0, "color": Color("365314")},
	"fly_storm": {"type": "emit", "emit": "swarm", "count": 18, "interval": 0.07, "dmg": 0.3, "shape": "bat", "speed": 7.5, "life": 3.0, "size": 0.3, "homing": 5.0, "color": Color("365314")},
	"owl_swarm": {"type": "emit", "emit": "swarm", "count": 8, "interval": 0.18, "dmg": 0.4, "shape": "bat", "speed": 7.0, "life": 2.6, "size": 0.35, "homing": 4.0, "color": Color("78716c")},
	"wing_gale": {"type": "gale", "force": 5.5, "time": 1.6, "shots": 5, "shape": "shard", "color": Color("f5f0e6")},
	"void_pull": {"type": "gale", "force": -5.0, "time": 1.8, "shots": 6, "shape": "orb", "color": Color("7f1d1d")},
	"charm_pull": {"type": "gale", "force": -6.0, "time": 1.6, "shots": 6, "shape": "orb", "color": Color("f9a8d4")},
	"debt_chains": {"type": "gale", "force": -6.5, "time": 1.5, "shots": 4, "shape": "hook", "color": Color("a8a29e"), "slow": 1.5},
	"dive": {"type": "dive", "radius": 4.5, "dmg": 1.3},
	"mask_crush": {"type": "dive", "radius": 5.0, "dmg": 1.4},
	"wheel_roll": {"type": "charge", "speed": 10.0, "ground": true, "dmg": 1.0},
	"charge": {"type": "charge", "speed": 12.0, "ground": false, "dmg": 1.0},
	"ring_burst": {"type": "ring", "speed": 8.0, "dmg": 0.9},
	"moon_ring": {"type": "ring", "speed": 7.0, "dmg": 0.8, "color": Color("e0e7ff")},
	"wreath_ring": {"type": "ring", "speed": 7.5, "dmg": 0.85},
	"tidal_ring": {"type": "ring", "speed": 9.0, "dmg": 0.9, "color": Color("0ea5e9")},
	"chest_quake": {"type": "ring", "speed": 6.5, "dmg": 1.0, "color": Color("facc15")},
	"judgement_beam": {"type": "beam", "dmg": 1.4},
	"scroll_beam": {"type": "beam", "dmg": 1.2},
	"water_beam": {"type": "beam", "dmg": 1.3, "color": Color("38bdf8")},
	"black_beam": {"type": "beam", "dmg": 1.5, "color": Color("1e1b4b")},
	"fire_pillars": {"type": "pillars", "dmg": 1.1},
	"holy_nova": {"type": "nova", "radius": 4.6, "dmg": 1.6},
	"dark_nova": {"type": "nova", "radius": 5.2, "dmg": 1.7, "color": Color("312e81")},
	"stillness": {"type": "slow", "radius": 7.0, "time": 2.6, "dmg": 0.6},
}

static func data(id: String) -> Dictionary:
	return BOSSES.get(id, {})

static func pattern(name: String) -> Dictionary:
	return PATTERNS.get(name, {})

## Combat profile of a boss. hero_count scales its health.
static func profile(id: String, hero_count: int = 2) -> Dictionary:
	var b: Dictionary = BOSSES[id]
	var hp: float = float(b.hp) * (0.5 + 0.25 * maxi(1, hero_count))
	return {
		"prompt": "%s · %s" % [b.name, b.title], "slot": 3, "seed": hash(id) & 0x7fffffff, "family": "boss_" + id, "boss": id,
		"name": "%s · %s" % [b.name, b.title], "element": "holy" if b.realm == "heaven" else "hellfire", "modules": [], "color": b.color,
		"stats": {"vitality": 30, "power": 30, "defense": 20, "speed": 10, "technique": 10},
		"standard": {"name": "Berührung", "damage": float(b.dmg), "range": 2.0, "cooldown": 1.0, "windup": 0.2, "active": 0.1,
			"recovery": 0.2, "push": 0.4, "angle": 40.0, "hitstun": 0.3},
		"special": {"name": b.title, "damage": float(b.dmg), "range": 4.0, "cooldown": 2.0, "windup": 0.5, "active": 0.2,
			"recovery": 0.3, "push": 0.6, "angle": 45.0, "hitstun": 0.4},
		"health": hp, "speed": float(b.speed), "weight": 1.45,
	}

extends RefCounted
## Signature specials: every fighter family gets its own special move built from a
## mechanic plus individual shape, color and numbers. The combat core (combat.gd)
## executes the mechanics, main.gd draws them.
##
## Mechanics:
##   projectile  – flying shot. Options: shape, speed, life, size, count (spread), gravity,
##                 pierce, homing, wave (sine), turn (returns), freeze, explode (radius),
##                 fuse (explodes after time), swap (swap places on hit), pull (drags target)
##   meteor      – projectile dropping from above onto the area in front
##   beam        – long instant hitbox in front (length, thick)
##   dash        – rushes forward hitting everything on the way (speed, multi = rehits)
##   teleport    – blinks behind the nearest opponent and strikes
##   eruption    – ground wave of pillars travelling forward (count, speed)
##   whirl       – spinning all-around multi-hit (radius, time, pull > 0 draws opponents in; push_mult scales the launch)
##   barrage     – rapid hits in front (hits)
##   power       – slow, huge single strike
##   counter     – guard stance; a hit during it is answered automatically
##   mine        – places a trap that explodes on contact (or after fuse)
##   turret      – places a turret that fires bolts for a few seconds
##   rage        – temporary power and speed boost
##   clone       – a shadow double runs forward and strikes

const SIGS := {
	"ninja": {"mech": "teleport", "color": Color("49def4"), "dmg": 1.0},
	"golem": {"mech": "eruption", "color": Color("ff6d2b"), "count": 3, "speed": 9.0, "dmg": 0.8},
	"valkyrie": {"mech": "projectile", "shape": "lance", "color": Color("ffe26a"), "speed": 20.0, "life": 0.6, "size": 0.6, "pierce": true, "dmg": 0.9},
	"dragon": {"mech": "beam", "color": Color("ff5a1f"), "length": 4.2, "thick": 1.2, "dmg": 0.9, "burn": true},
	"goku": {"mech": "beam", "color": Color("7dd3fc"), "length": 9.0, "thick": 0.7, "dmg": 1.1, "windup": 0.5},
	"vegeta": {"mech": "projectile", "shape": "orb", "color": Color("ffe838"), "speed": 7.0, "life": 1.6, "size": 0.9, "explode": 2.2, "dmg": 1.2},
	"frieza": {"mech": "projectile", "shape": "bolt", "color": Color("c084fc"), "speed": 30.0, "life": 0.5, "size": 0.3, "dmg": 0.75, "windup": 0.1},
	"subzero": {"mech": "projectile", "shape": "shard", "color": Color("9be7ff"), "speed": 14.0, "life": 0.8, "size": 0.5, "freeze": 1.0, "dmg": 0.6},
	"pain": {"mech": "whirl", "color": Color("9900ee"), "radius": 3.2, "time": 0.35, "pull": 0.0, "push_mult": 2.2, "dmg": 0.8},
	"luffy": {"mech": "barrage", "color": Color("ff2b2b"), "hits": 7, "range": 2.8, "dmg": 1.3},
	"zoro": {"mech": "dash", "color": Color("3bfac8"), "speed": 13.0, "multi": 3, "dmg": 1.0},
	"naruto": {"mech": "clone", "color": Color("ff9b3d"), "speed": 10.0, "dmg": 0.9},
	"sasuke": {"mech": "dash", "color": Color("60d5ff"), "speed": 19.0, "multi": 1, "dmg": 1.1},
	"saitama": {"mech": "power", "color": Color("ffd23f"), "dmg": 1.8, "windup": 0.55},
	"tanjiro": {"mech": "whirl", "color": Color("ff6524"), "radius": 2.4, "time": 0.6, "pull": 0.0, "dmg": 1.1},
	"sonic": {"mech": "dash", "color": Color("3b82f6"), "speed": 16.0, "multi": 4, "dmg": 1.0},
	"akaza": {"mech": "counter", "color": Color("00e5ff"), "dmg": 1.5},
	"blue_eyes": {"mech": "beam", "color": Color("e0f2fe"), "length": 8.0, "thick": 1.4, "dmg": 1.15, "windup": 0.45},
	"charizard": {"mech": "projectile", "shape": "fireball", "color": Color("ff6610"), "speed": 9.0, "life": 1.4, "size": 0.6, "gravity": 9.0, "rise": 5.0, "explode": 2.0, "dmg": 1.0},
	"anubis": {"mech": "projectile", "shape": "hook", "color": Color("c9a227"), "speed": 16.0, "life": 0.5, "size": 0.5, "pull": true, "dmg": 0.6},
	"phoenix": {"mech": "projectile", "shape": "firebird", "color": Color("ff8a1f"), "speed": 11.0, "life": 1.2, "size": 0.7, "wave": 1.0, "pierce": true, "dmg": 0.9},
	"specter": {"mech": "teleport", "color": Color("9b30ff"), "dmg": 1.1},
	"golden_golem": {"mech": "eruption", "color": Color("ffd24a"), "count": 4, "speed": 7.0, "dmg": 0.8},
	"tripo_fran_statue": {"mech": "projectile", "shape": "arrow", "color": Color("86efac"), "speed": 24.0, "life": 0.8, "size": 0.4, "gravity": 3.0, "pierce": true, "dmg": 0.8},
	"tripo_fantasy_female": {"mech": "mine", "color": Color("4ade80"), "shape": "thorns", "dmg": 1.0},
	"tripo_nyx_harvester": {"mech": "projectile", "shape": "scythe", "color": Color("a855f7"), "speed": 13.0, "life": 1.4, "size": 0.7, "turn": 0.5, "pierce": true, "dmg": 0.8},
	"tripo_cat_girl": {"mech": "barrage", "color": Color("f472b6"), "hits": 5, "range": 1.9, "dmg": 1.0},
	"tripo_dragon_blue": {"mech": "beam", "color": Color("7dd3fc"), "length": 5.5, "thick": 1.1, "freeze": 0.8, "dmg": 0.9},
	"tripo_white_sci": {"mech": "beam", "color": Color("22d3ee"), "length": 10.0, "thick": 0.3, "dmg": 0.8, "windup": 0.2},
	"tripo_skeleton_dog": {"mech": "dash", "color": Color("d6d3d1"), "speed": 12.0, "multi": 2, "dmg": 1.0},
	"tripo_wooden_forest": {"mech": "eruption", "color": Color("65a30d"), "count": 3, "speed": 6.0, "dmg": 0.9},
	"tripo_nine_tailed": {"mech": "projectile", "shape": "foxfire", "color": Color("38bdf8"), "speed": 8.0, "life": 1.5, "size": 0.45, "count": 3, "homing": 6.0, "dmg": 0.45},
	"tripo_quadruped_tree": {"mech": "rage", "color": Color("84cc16"), "time": 6.0},
	"steel_knight": {"mech": "counter", "color": Color("e2e8f0"), "dmg": 1.3},
	"vanguard_soldier": {"mech": "projectile", "shape": "grenade", "color": Color("fbbf24"), "speed": 8.0, "life": 1.6, "size": 0.4, "gravity": 12.0, "rise": 6.0, "explode": 2.4, "dmg": 1.0},
	"sorceress_medea": {"mech": "projectile", "shape": "orb", "color": Color("c084fc"), "speed": 6.0, "life": 2.2, "size": 0.55, "homing": 9.0, "dmg": 0.9},
	"skeleton_reaper": {"mech": "whirl", "color": Color("a78bfa"), "radius": 2.6, "time": 0.55, "pull": 5.0, "dmg": 1.0},
	"mutant_titan": {"mech": "rage", "color": Color("84cc16"), "time": 7.0},
	"swat_specops": {"mech": "projectile", "shape": "bullet", "color": Color("fb923c"), "speed": 26.0, "life": 0.45, "size": 0.3, "count": 3, "spread": 0.12, "dmg": 0.35},
	"samurai_dreyar": {"mech": "dash", "color": Color("99f6e4"), "speed": 22.0, "multi": 1, "dmg": 1.25, "windup": 0.35},
	"pirate_captain": {"mech": "projectile", "shape": "pellet", "color": Color("d6d3d1"), "speed": 20.0, "life": 0.3, "size": 0.35, "count": 5, "spread": 0.22, "dmg": 0.3},
	"vampire_lord": {"mech": "projectile", "shape": "bat", "color": Color("dc2626"), "speed": 9.0, "life": 1.6, "size": 0.45, "count": 3, "homing": 7.0, "lifesteal": 0.5, "dmg": 0.4},
	"wizard_sorcerer": {"mech": "meteor", "color": Color("ff7a1a"), "size": 0.9, "explode": 2.2, "dmg": 1.2},
	"warrok_brute": {"mech": "eruption", "color": Color("f97316"), "count": 2, "speed": 5.0, "dmg": 1.2},
	# ── the five new fighters ──
	"nekra": {"mech": "eruption", "color": Color("e7e5e4"), "shape": "bone", "count": 5, "speed": 11.0, "dmg": 0.6},
	"grimbolt": {"mech": "mine", "color": Color("f59e0b"), "shape": "bomb", "fuse": 1.6, "explode": 3.0, "dmg": 1.3},
	"echo": {"mech": "projectile", "shape": "glitch", "color": Color("5eead4"), "speed": 15.0, "life": 0.7, "size": 0.6, "swap": true, "dmg": 0.6},
	"kettenwart": {"mech": "whirl", "color": Color("78716c"), "radius": 3.6, "time": 0.5, "pull": 18.0, "dmg": 0.7},
	"don_valente": {"mech": "turret", "color": Color("facc15"), "dmg": 0.35},
}

## Body pose shown while a special runs, per mechanic.
const MECH_POSE := {
	"projectile": "Cast", "meteor": "Summon", "beam": "Beam", "dash": "Dash", "teleport": "SpecialAttack",
	"eruption": "Slam", "whirl": "Spin", "barrage": "Barrage", "power": "HeavyPunch", "counter": "Counter",
	"mine": "Crouch", "turret": "Cast", "rage": "Roar", "clone": "SpecialAttack",
}

static func for_family(family: String) -> Dictionary:
	return SIGS.get(family, {})

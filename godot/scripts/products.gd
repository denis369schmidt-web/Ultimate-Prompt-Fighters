extends RefCounted
## Real-money products for Steam and Google Play – a fair model:
##   * every product has a fixed, visible price and shows exactly what it contains,
##   * no paid random rewards, no paid currency, no pay-to-win (everything is also earnable with coins),
##   * Steam: the base game is sold on its store page, packs are DLC (steam_dlc = DLC app id),
##   * Google Play: free to start, one-time "Vollversion" unlock plus the same packs (play_sku = product id).
## Fill in the real ids after creating them in Steamworks / Play Console (docs/STORE_RELEASE.md).

const PRODUCTS := [
	{"id": "full_game", "name": "VOLLVERSION", "price_eur": 7.99, "steam_dlc": 0, "play_sku": "pfu_full_game", "platforms": ["play", "local"],
		"desc": "Schaltet »Die göttliche Prüfung« (21 Kapitel), alle 19 Bosse und den Boss-Rush frei. Einmal kaufen, für immer spielen.",
		"grants": {}},
	{"id": "pack_neon", "name": "NEON-NÄCHTE-PAKET", "price_eur": 2.99, "steam_dlc": 0, "play_sku": "pfu_pack_neon",
		"desc": "5 Startmenüs mit Arenen (Neon-Skyline, Graffiti-Gasse, Regendach, Nachtmarkt, Sturmdach) + Skins NEONPULS und KRISTALL.",
		"grants": {"backgrounds": ["neon_skyline", "graffiti_alley", "rain_rooftop", "night_market", "storm_roof"], "skins": ["neon", "crystal"]}},
	{"id": "pack_legends", "name": "HIMMEL-&-HÖLLE-PAKET", "price_eur": 3.99, "steam_dlc": 0, "play_sku": "pfu_pack_legends",
		"desc": "Skins GALAXIE, GEIST, LAVAHERZ, SCHATTENFORM + Waffen SEELENSENSE und DONNERHAMMER.",
		"grants": {"skins": ["galaxy", "ghost", "lava", "shadow"], "weapons": ["soul_scythe", "thunder_hammer"]}},
	{"id": "pack_arenas", "name": "ARENA-SAMMLUNG", "price_eur": 4.99, "steam_dlc": 0, "play_sku": "pfu_pack_arenas",
		"desc": "Alle 22 zusätzlichen Startmenüs mit ihren spielbaren Arenen auf einen Schlag.",
		"grants": {"backgrounds": "all"}},
	{"id": "pack_weapons", "name": "WAFFENKAMMER", "price_eur": 2.99, "steam_dlc": 0, "play_sku": "pfu_pack_weapons",
		"desc": "Alle 8 Shop-Waffen – Schattenkatana bis Plasmakanone.",
		"grants": {"weapons": "all"}},
	{"id": "supporter", "name": "UNTERSTÜTZER-PAKET", "price_eur": 4.99, "steam_dlc": 0, "play_sku": "pfu_supporter",
		"desc": "Danke für deine Unterstützung! Exklusiver Titel »Gönner der Arenen«, Skin GOLDRAUSCH und 1000 Münzen.",
		"grants": {"skins": ["gold"], "title": "supporter", "coins": 1000}},
]

static func find(id: String) -> Dictionary:
	for p in PRODUCTS: if p.id == id: return p
	return {}

## Products offered on a backend ("steam", "play", "local").
static func for_backend(backend: String) -> Array:
	return PRODUCTS.filter(func(p): return not p.has("platforms") or backend in p.platforms)

## Gives the contents of an owned product (idempotent: coins only once, tracked in prog.granted).
static func apply(prog, id: String, backgrounds: Array, weapons: Array) -> void:
	var p: Dictionary = find(id)
	if p.is_empty(): return
	var g: Dictionary = p.grants
	var bgs = g.get("backgrounds", [])
	if bgs is String: bgs = backgrounds.filter(func(b): return int(b.price) > 0).map(func(b): return b.id)
	for b in bgs: prog.unlocked[b] = true
	for s in g.get("skins", []): prog.skins_owned[s] = true
	var ws = g.get("weapons", [])
	if ws is String: ws = weapons.map(func(w): return w.id)
	for w in ws: prog.weapons_owned[w] = true
	if g.has("title"): prog.stats[str(g.title)] = 1
	if not prog.granted.has(id):
		prog.granted[id] = true
		prog.coins += int(g.get("coins", 0))
	prog.save_progress()

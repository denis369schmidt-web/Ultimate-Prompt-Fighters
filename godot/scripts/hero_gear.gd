extends Node3D
## Own look of the house heroes (kairo … lepora, brunhild … mossback): every hero gets an outfit recolor
## (shaders/hero_recolor.gdshader: skin stays, cloth and armor move into the hero palette),
## gear that rides on the skeleton (BoneAttachment3D) and reactive effects – halos spin up while
## charging, jets fire while dashing, gauntlets heat up before a heavy blow, everything flashes
## on hits. All meshes, textures and effects are generated here; nothing is imported.
##
## fighter_view.gd calls equip() after setup, apply_state() every frame and flash() on hits.

const RECOLOR := preload("res://shaders/hero_recolor.gdshader")

## primary/secondary: outfit colors, accent: bright trims, rim: fresnel glow and effect color.
const HEROES := {
	"kairo": {"primary": Color("d99a2b"), "secondary": Color("16323f"), "accent": Color("fde68a"), "rim": Color("7dd3fc"),
		"gear": ["sun_halo", "wrist_rings", "prayer_beads", "aura_rise"]},
	"varakh": {"primary": Color("b3121f"), "secondary": Color("1a1016"), "accent": Color("ffd24a"), "rim": Color("ffe838"),
		"gear": ["crest_pauldrons", "blade_crown", "cape", "sparks"]},
	"xylar": {"primary": Color("5b21b6"), "secondary": Color("0f0a1a"), "accent": Color("e9d5ff"), "rim": Color("c084fc"),
		"gear": ["shard_orbit", "void_horns", "hover_sigil", "nova_orb"]},
	"glaciem": {"primary": Color("7dd3fc"), "secondary": Color("0b2540"), "accent": Color("f0f9ff"), "rim": Color("bae6fd"),
		"gear": ["ice_pauldrons", "ice_tiara", "frost_mist"]},
	"oryn": {"primary": Color("3b0764"), "secondary": Color("0a0a12"), "accent": Color("d8b4fe"), "rim": Color("a855f7"),
		"gear": ["rune_rings", "gravity_orbs", "aura_sink"]},
	"tobi": {"primary": Color("1e3a8a"), "secondary": Color("2b1b0e"), "accent": Color("fbbf24"), "rim": Color("ff4d4d"),
		"gear": ["spring_bracers", "bandana"]},
	"jubei": {"primary": Color("0f766e"), "secondary": Color("0b1412"), "accent": Color("99f6e4"), "rim": Color("3bfac8"),
		"gear": ["wind_scarf", "back_blades", "wind_swirl"]},
	"ren": {"primary": Color("db2777"), "secondary": Color("3b0a24"), "accent": Color("fce7f3"), "rim": Color("fda4af"),
		"gear": ["hair_ribbons", "petals", "petal_vortex"]},
	"amethya": {"primary": Color("7c3aed"), "secondary": Color("140a24"), "accent": Color("c4b5fd"), "rim": Color("60d5ff"),
		"gear": ["arc_arms", "crystal_tiara", "floating_crystals"]},
	"bruno": {"primary": Color("d97706"), "secondary": Color("1c1917"), "accent": Color("fde047"), "rim": Color("ffd23f"),
		"gear": ["impact_gauntlets", "headband"]},
	"hikaru": {"primary": Color("c2410c"), "secondary": Color("1f0d07"), "accent": Color("fed7aa"), "rim": Color("ff7a2e"),
		"gear": ["ember_mantle", "lantern", "hip_blade", "embers"]},
	"zip": {"primary": Color("0284c7"), "secondary": Color("0c1222"), "accent": Color("e0f2fe"), "rim": Color("38bdf8"),
		"gear": ["jet_boots", "visor", "head_fins", "bolt_emblem", "speed_trail"]},
	"raiga": {"primary": Color("0e7490"), "secondary": Color("0b1020"), "accent": Color("a5f3fc"), "rim": Color("22d3ee"),
		"gear": ["thunder_drums", "fist_rings", "ground_star"]},
	"albion": {"primary": Color("e2e8f0"), "secondary": Color("334155"), "accent": Color("f8fafc"), "rim": Color("bae6fd"),
		"gear": ["silver_wings", "wyrm_horns", "breath_glow"]},
	"pyrax": {"primary": Color("7c2d12"), "secondary": Color("1c0a05"), "accent": Color("fdba74"), "rim": Color("ff6610"),
		"gear": ["ember_wings", "wyrm_horns", "flame_tail", "embers"]},
	"lepora": {"primary": Color("94a3b8"), "secondary": Color("172033"), "accent": Color("f1f5f9"), "rim": Color("5eead4"),
		"gear": ["moon_circlet", "quiver", "moon_bow", "fireflies"]},
	"brunhild": {"primary": Color("d9a520"), "secondary": Color("3a2a12"), "accent": Color("fff1b8"), "rim": Color("ffd24a"), "metal": 0.7, "rough": 0.3,
		"gear": ["winged_helm", "crest_pauldrons", "great_axe", "cape"]},
	"thorn_witch": {"primary": Color("166534"), "secondary": Color("2a1a10"), "accent": Color("bbf7d0"), "rim": Color("4ade80"),
		"gear": ["thorn_crown", "vine_whips", "thorn_spikes", "fireflies"]},
	"nyx": {"primary": Color("4c1d95"), "secondary": Color("120612"), "accent": Color("e9d5ff"), "rim": Color("a855f7"),
		"gear": ["ember_wings", "void_horns", "soul_scythe", "aura_sink"]},
	"shira": {"primary": Color("db2777"), "secondary": Color("1a0a14"), "accent": Color("fbcfe8"), "rim": Color("f472b6"),
		"gear": ["cat_ears", "cat_tail", "back_blades", "wind_scarf"]},
	"frostwyrm": {"primary": Color("3b82f6"), "secondary": Color("0b2540"), "accent": Color("e0f2fe"), "rim": Color("7dd3fc"), "metal": 0.4,
		"gear": ["silver_wings", "wyrm_horns", "breath_glow", "ice_tail", "frost_mist"]},
	"cyborg_mech": {"primary": Color("e5e7eb"), "secondary": Color("1f2937"), "accent": Color("f8fafc"), "rim": Color("22d3ee"), "metal": 0.6, "rough": 0.3,
		"gear": ["visor", "mech_plating", "shoulder_cannon", "jet_boots"]},
	"reaper_hound": {"primary": Color("57534e"), "secondary": Color("0c0a09"), "accent": Color("8f877c"), "rim": Color("ef4444"),
		"gear": ["skull_mask", "bone_spikes", "bone_tail", "aura_sink"]},
	"treant": {"primary": Color("65a30d"), "secondary": Color("4a3219"), "accent": Color("d9f99d"), "rim": Color("a3e635"), "rough": 0.85,
		"gear": ["bark_armor", "antlers", "moss_tufts", "fireflies"]},
	"celestial_fox": {"primary": Color("f1f5f9"), "secondary": Color("1e3a8a"), "accent": Color("fde68a"), "rim": Color("38bdf8"),
		"gear": ["fox_ears", "nine_tails", "foxfire_orbs", "moon_circlet"]},
	"mossback": {"primary": Color("4d7c0f"), "secondary": Color("57534e"), "accent": Color("a8987a"), "rim": Color("84cc16"), "rough": 0.9,
		"gear": ["stone_back", "ram_horns", "moss_tufts"]},
	"arber": {"primary": Color("1f1b1a"), "secondary": Color("2e2724"), "accent": Color("e8b923"), "rim": Color("ff3b30"), "recolor": 0.7, "sash": Color("a3161a"),
		"hide": ["BattleAxe", "Earrings"], "gear": ["qeleshe", "xhamadan", "tool_belt", "twin_drills", "double_eagle"]},
	# Concept-art trio (Kalyx, Vorruk, Neris): own skin color via "skin".
	"kalyx": {"primary": Color("9c6a42"), "secondary": Color("3f2718"), "accent": Color("d9a93a"), "recolor": 1.0, "rim": Color("7dd3fc"), "skin": Color("62749f"), "rough": 0.78,
		"hide": ["lower_armor_horns", "Upper_body", "upper_cloth", "Eyes_ring", "shoulder2"], "gear": ["kalyx_skin", "crystal_crown", "gold_chains", "bandolier", "gold_bracers", "kalyx_belt"]},
	"vorruk": {"primary": Color("d39a63"), "secondary": Color("8a5532"), "accent": Color("eadbb8"), "rim": Color("6d58b0"), "skin": Color("b77d4b"), "recolor": 0.9, "rough": 0.85, "metal": 0.0,
		"gear": ["flesh_plates", "hip_lappets", "long_claws", "head_lobes"]},
	"neris": {"primary": Color("6b7280"), "secondary": Color("2f3a66"), "accent": Color("c9a227"), "rim": Color("fbbf24"), "skin": Color("f1dccb"), "recolor": 0.9,
		"hide": ["Cloak", "Skirt", "Weapons"], "gear": ["neris_face", "glow_veins", "neris_hair", "shoulder_crystals", "chain_gauntlet", "neris_scarf", "belt_chain"]},
	# Nations: the flag flies on a banner on the back and sits on the chest, the outfit wears its colors.
	"konrad": {"primary": Color("b80000"), "secondary": Color("1a1a1a"), "accent": Color("ffce00"), "rim": Color("ffce00"), "flag": "de",
		"gear": ["flag_banner", "flag_crest", "forge_hammer", "smith_apron"]},
	"bogdan": {"primary": Color("0039a6"), "secondary": Color("d8dce4"), "accent": Color("d52b1e"), "rim": Color("bfdbfe"), "flag": "ru",
		"gear": ["flag_banner", "flag_crest", "bogatyr_helm", "bogatyr_mace", "frost_mist"]},
	"kaan": {"primary": Color("e30a17"), "secondary": Color("f8fafc"), "accent": Color("ffffff"), "rim": Color("ff4d4d"), "flag": "tr",
		"gear": ["flag_banner", "flag_crest", "kilij", "cape"]},
	"amra": {"primary": Color("fecb00"), "secondary": Color("002395"), "accent": Color("ffffff"), "rim": Color("38bdf8"), "flag": "ba",
		"gear": ["flag_banner", "flag_crest", "wind_scarf"]},
	"dusty": {"primary": Color("b22234"), "secondary": Color("3c3b6e"), "accent": Color("ffffff"), "rim": Color("fde68a"), "flag": "us",
		"gear": ["flag_banner", "flag_crest", "cowboy_hat", "lasso_coil"]},
}

var view: Node3D
var hero: Dictionary = {}
var family := ""
var t := 0.0
var charge := 0.0
var dash := 0.0
var hit_flash := 0.0
var run_speed := 0.0
var pose := "Idle"
var glows: Array = []        # [material, base_energy]
var spinners: Array = []     # [node, axis, speed]
var sways: Array = []        # [node, base_rot_deg, amp_deg, freq, phase, run_lift_deg]
var body_mats: Array = []    # recolor ShaderMaterials
var react: Dictionary = {}   # name -> node shown/scaled by state
var particles: Dictionary = {}
var arcs: Array = []         # [ImmediateMesh, from, to, count]
var arc_timer := 0.0
var _bones: Dictionary = {}
var drill_bits: Array = []   # spinning bits (Arbër)
var drill_sparks: Array = []
var drilling := false
var eagle_wings: Array = []  # [node, side (inner ±1, outer ±0.5)]
var eagle_on := false
var eagle_facing := 1

static var _tex: Dictionary = {}

static func has_hero(fam: String) -> bool:
	return HEROES.has(fam)

static func equip(v: Node3D, fam: String) -> Node3D:
	if not HEROES.has(fam) or v.model == null: return null
	var g = load("res://scripts/hero_gear.gd").new()
	g.name = "HeroGear"
	g.view = v
	g.family = fam
	g.hero = HEROES[fam]
	v.add_child(g)
	g._build()
	return g

# ─────────────────────────────────────────────────────────── build ──

func _build() -> void:
	for mi in view.model.find_children("*", "MeshInstance3D", true, false):
		for part in hero.get("hide", []):
			if str(part) in str(mi.name): mi.visible = false
	_recolor_body()
	for item in hero.gear:
		if has_method("_g_" + item): call("_g_" + item)
		else: push_warning("hero_gear: unknown gear " + item)

func _recolor_body() -> void:
	for mi in view.model.find_children("*", "MeshInstance3D", true, false):
		if mi.mesh == null or mi.has_meta("gear"): continue
		for sfc in range(mi.mesh.get_surface_count()):
			var src = mi.get_active_material(sfc)
			var sm := ShaderMaterial.new()
			sm.shader = RECOLOR
			var tex: Texture2D = null
			var col := Color.WHITE
			var nrm: Texture2D = null
			if src is BaseMaterial3D:
				tex = src.albedo_texture
				col = src.albedo_color
				if src.normal_enabled: nrm = src.normal_texture
				sm.next_pass = src.next_pass
			sm.set_shader_parameter("has_tex", tex != null)
			if tex != null: sm.set_shader_parameter("albedo_tex", tex)
			# Untextured mannequins: start from mid grey so both palette colors show.
			sm.set_shader_parameter("base_color", Color(1, 1, 1) if tex != null else Color(0.55, 0.55, 0.58))
			sm.set_shader_parameter("has_normal", nrm != null)
			if nrm != null: sm.set_shader_parameter("normal_tex", nrm)
			sm.set_shader_parameter("primary", hero.primary)
			sm.set_shader_parameter("secondary", hero.secondary)
			sm.set_shader_parameter("accent", hero.accent)
			sm.set_shader_parameter("rim_color", hero.rim)
			sm.set_shader_parameter("recolor", float(hero.get("recolor", 0.85)))
			sm.set_shader_parameter("metallic_v", float(hero.get("metal", 0.2)))
			sm.set_shader_parameter("roughness_v", float(hero.get("rough", 0.5)))
			if hero.has("skin"):
				sm.set_shader_parameter("skin_tint", hero.skin)
				sm.set_shader_parameter("skin_tint_amount", 0.92)
			mi.set_surface_override_material(sfc, sm)
			body_mats.append(sm)

# ─────────────────────────────────────────────────────── skeleton ──

const EXTRA_BONES := {
	"chest": ["spine2", "spine1", "chest", "upperchest"],
	"neck": ["neck"],
	"left_hand": ["lefthand", "hand.l", "hand_l"],
	"right_hand": ["righthand", "hand.r", "hand_r"],
	"left_foot": ["leftfoot", "foot.l", "foot_l"],
	"right_foot": ["rightfoot", "foot.r", "foot_r"],
	"left_shoulder": ["leftshoulder", "shoulder.l", "clavicle_l"],
	"right_shoulder": ["rightshoulder", "shoulder.r", "clavicle_r"],
}
const FALLBACK_POS := {"head": Vector3(0, 1.62, 0), "neck": Vector3(0, 1.5, 0), "chest": Vector3(0, 1.3, 0),
	"spine": Vector3(0, 1.1, 0), "hips": Vector3(0, 0.95, 0), "left_hand": Vector3(0.7, 1.35, 0),
	"right_hand": Vector3(-0.7, 1.35, 0), "left_forearm": Vector3(0.45, 1.35, 0), "right_forearm": Vector3(-0.45, 1.35, 0),
	"left_arm": Vector3(0.2, 1.4, 0), "right_arm": Vector3(-0.2, 1.4, 0), "left_foot": Vector3(0.12, 0.08, 0),
	"right_foot": Vector3(-0.12, 0.08, 0), "left_shoulder": Vector3(0.12, 1.45, 0), "right_shoulder": Vector3(-0.12, 1.45, 0)}

func _bone_idx(key: String) -> int:
	if _bones.has(key): return _bones[key]
	var sk: Skeleton3D = view.skeleton
	var idx := -1
	if sk != null:
		if view.bone_map.has(key): idx = view.bone_map[key]
		elif EXTRA_BONES.has(key):
			for cand in EXTRA_BONES[key]:
				for b in range(sk.get_bone_count()):
					var bn := sk.get_bone_name(b).to_lower()
					if bn.ends_with(cand) and not "end" in bn and not "index" in bn and not "thumb" in bn:
						idx = b
						break
				if idx != -1: break
	_bones[key] = idx
	return idx

## Rotation and scale from the fighter root down to the skeleton (model rotation excluded).
func _chain_basis() -> Basis:
	var b := Basis.IDENTITY
	var n: Node = view.skeleton
	while n != null and n != view:
		if n is Node3D:
			var nb: Basis = (n as Node3D).basis
			if n == view.model: nb = Basis.from_scale((n as Node3D).scale)
			b = nb * b
		n = n.get_parent()
	return b

## A node that follows the bone; its axes match the model at rest pose, units are meters.
func _attach(key: String, offset: Vector3 = Vector3.ZERO) -> Node3D:
	var sk: Skeleton3D = view.skeleton
	var idx := _bone_idx(key)
	var pivot := Node3D.new()
	if sk == null or idx == -1:
		pivot.position = FALLBACK_POS.get(key, Vector3(0, 1.2, 0)) + offset
		add_child(pivot)
		return pivot
	var ba := BoneAttachment3D.new()
	ba.bone_name = sk.get_bone_name(idx)
	sk.add_child(ba)
	# Undo the bone's rest orientation and every transform between the fighter and the
	# skeleton (armature rotation, centimeter scale), so offsets read as meters in model space.
	var holder := Node3D.new()
	holder.basis = (_chain_basis() * sk.get_bone_global_rest(idx).basis).inverse()
	ba.add_child(holder)
	pivot.position = offset
	holder.add_child(pivot)
	return pivot

# ──────────────────────────────────────────────────────── materials ──

func _mat(color: Color, metal: float = 0.0, rough: float = 0.6) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metal
	m.roughness = rough
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.specular_mode = BaseMaterial3D.SPECULAR_TOON
	m.rim_enabled = true
	m.rim = 0.5
	m.rim_tint = 0.4
	return m

func _metal(color: Color, rough: float = 0.28) -> StandardMaterial3D:
	var m := _mat(color, 0.95, rough)
	m.normal_enabled = true
	m.normal_texture = _noise("hammered", 0.035, true, 5.0)
	m.normal_scale = 0.35
	m.clearcoat_enabled = true
	m.clearcoat = 0.6
	m.uv1_scale = Vector3(3, 3, 3)
	return m

func _cloth(color: Color) -> StandardMaterial3D:
	var m := _mat(Color.WHITE, 0.0, 0.85)
	m.albedo_texture = _noise("cloth_" + color.to_html(), 0.012, false, 0.0, [color.darkened(0.35), color])
	m.normal_enabled = true
	m.normal_texture = _noise("folds", 0.01, true, 9.0)
	m.uv1_scale = Vector3(1, 4, 1)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

func _glow(color: Color, energy: float = 3.0, additive: bool = false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy
	if additive:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		m.cull_mode = BaseMaterial3D.CULL_DISABLED
	glows.append([m, energy])
	return m

func _crystal(color: Color) -> StandardMaterial3D:
	var m := _mat(Color(color.r, color.g, color.b, 0.62), 0.1, 0.04)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = 0.9
	m.rim = 1.0
	m.rim_tint = 0.1
	m.clearcoat_enabled = true
	m.clearcoat = 1.0
	glows.append([m, 0.9])
	return m

func _membrane(color: Color, vein: Color) -> StandardMaterial3D:
	var m := _mat(color, 0.0, 0.55)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.albedo_texture = _noise("membrane", 0.03, false, 0.0, [Color(0.55, 0.55, 0.55), Color.WHITE])
	m.emission_enabled = true
	m.emission_texture = _veins_tex()
	m.emission = vein
	m.emission_energy_multiplier = 0.3
	m.rim = 0.25
	glows.append([m, 0.3])
	return m

static func _noise(key: String, freq: float, normal: bool, bump: float = 6.0, ramp: Array = []) -> Texture2D:
	if _tex.has(key): return _tex[key]
	var nt := NoiseTexture2D.new()
	nt.width = 256 if load("res://scripts/platform.gd").low_graphics() else 1024
	nt.height = nt.width
	nt.seamless = true
	var fn := FastNoiseLite.new()
	fn.frequency = freq
	fn.fractal_octaves = 5
	fn.seed = key.hash()
	nt.noise = fn
	if normal:
		nt.as_normal_map = true
		nt.bump_strength = bump
	if ramp.size() >= 2:
		var g := Gradient.new()
		g.set_color(0, ramp[0])
		g.set_color(1, ramp[1])
		nt.color_ramp = g
	_tex[key] = nt
	return nt

## Branching glowing veins for wing membranes (drawn once).
static func _veins_tex() -> Texture2D:
	if _tex.has("veins"): return _tex["veins"]
	var img := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	img.fill(Color.BLACK)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for k in range(9):
		var p := Vector2(rng.randf_range(0, 40), rng.randf_range(0, 256))
		var dir := Vector2(1, rng.randf_range(-0.4, 0.4)).normalized()
		var w := 3.0
		for s in range(160):
			for dx in range(-int(w), int(w) + 1):
				for dy in range(-int(w), int(w) + 1):
					var q := Vector2i(int(p.x) + dx, int(p.y) + dy)
					if q.x >= 0 and q.y >= 0 and q.x < 256 and q.y < 256 and Vector2(dx, dy).length() <= w:
						img.set_pixelv(q, Color.WHITE)
			dir = dir.rotated(rng.randf_range(-0.25, 0.25))
			p += dir * 1.6
			w = maxf(0.6, w - 0.02)
	var tx := ImageTexture.create_from_image(img)
	_tex["veins"] = tx
	return tx

## Concentric runes for the prophet's rings.
static func _rune_tex() -> Texture2D:
	if _tex.has("runes"): return _tex["runes"]
	var n := 256
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var c := Vector2(n * 0.5, n * 0.5)
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	for y in range(n):
		for x in range(n):
			var d := Vector2(x, y).distance_to(c) / (n * 0.5)
			var a := atan2(y - c.y, x - c.x)
			var v := 0.0
			if absf(d - 0.94) < 0.025 or absf(d - 0.62) < 0.018: v = 1.0
			# Glyph band: short radial strokes and dots between the two circles.
			var seg := int(floor((a + PI) / TAU * 24.0))
			var local := fmod((a + PI) / TAU * 24.0, 1.0)
			if d > 0.68 and d < 0.88:
				var kind := (seg * 7 + 3) % 4
				match kind:
					0: v = 1.0 if absf(local - 0.5) < 0.07 else 0.0
					1: v = 1.0 if absf(d - 0.78) < 0.03 and local > 0.2 and local < 0.8 else 0.0
					2: v = 1.0 if (absf(local - 0.3) < 0.06 or absf(local - 0.7) < 0.06) and d < 0.84 else 0.0
					3: v = 1.0 if Vector2(local - 0.5, (d - 0.78) * 4.0).length() < 0.16 else 0.0
			if v > 0.0: img.set_pixel(x, y, Color(1, 1, 1, v))
	var tx := ImageTexture.create_from_image(img)
	_tex["runes"] = tx
	return tx

# ────────────────────────────────────────────────────────── meshes ──

func _part(parent: Node3D, mesh: Mesh, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	mi.scale = scl
	mi.set_meta("gear", true)
	mi.layers = 1 | 2
	parent.add_child(mi)
	return mi

func _sphere(r: float, segs: int = 32) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = segs
	s.rings = segs / 2
	return s

func _torus(inner: float, outer: float, rings: int = 64) -> TorusMesh:
	var tm := TorusMesh.new()
	tm.inner_radius = inner
	tm.outer_radius = outer
	tm.rings = rings
	tm.ring_segments = 14
	return tm

func _cyl(top: float, bottom: float, h: float, segs: int = 24) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = top
	c.bottom_radius = bottom
	c.height = h
	c.radial_segments = segs
	return c

func _box(x: float, y: float, z: float) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = Vector3(x, y, z)
	return b

## Tapered blade with a diamond cross-section along +Y (length, width, thickness).
func _blade(length: float, width: float, thick: float, curve: float = 0.0) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := 10
	var rows: Array = []
	for i in range(n + 1):
		var f := float(i) / n
		var w: float = width * (1.0 - pow(f, 1.8)) * 0.5
		var th: float = thick * (1.0 - f * 0.8) * 0.5
		var y := f * length
		var bend := curve * f * f
		rows.append([Vector3(-w + bend, y, 0), Vector3(bend, y, th), Vector3(w + bend, y, 0), Vector3(bend, y, -th)])
	for i in range(n):
		for k in range(4):
			var a: Vector3 = rows[i][k]
			var b: Vector3 = rows[i][(k + 1) % 4]
			var c: Vector3 = rows[i + 1][(k + 1) % 4]
			var d: Vector3 = rows[i + 1][k]
			st.add_vertex(a); st.add_vertex(b); st.add_vertex(c)
			st.add_vertex(a); st.add_vertex(c); st.add_vertex(d)
	st.generate_normals()
	return st.commit()

## Faceted crystal: hexagonal prism with pointed ends.
func _crystal_mesh(length: float, radius: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var top := Vector3(0, length * 0.5, 0)
	var bot := Vector3(0, -length * 0.5, 0)
	var ring_hi: Array = []
	var ring_lo: Array = []
	for k in range(6):
		var a := TAU * k / 6.0
		var p := Vector3(cos(a) * radius, 0, sin(a) * radius)
		ring_hi.append(p + Vector3(0, length * 0.22, 0))
		ring_lo.append(p - Vector3(0, length * 0.22, 0))
	for k in range(6):
		var k2 := (k + 1) % 6
		st.add_vertex(top); st.add_vertex(ring_hi[k2]); st.add_vertex(ring_hi[k])
		st.add_vertex(ring_hi[k]); st.add_vertex(ring_hi[k2]); st.add_vertex(ring_lo[k2])
		st.add_vertex(ring_hi[k]); st.add_vertex(ring_lo[k2]); st.add_vertex(ring_lo[k])
		st.add_vertex(bot); st.add_vertex(ring_lo[k]); st.add_vertex(ring_lo[k2])
	st.generate_normals()
	return st.commit()

## Membrane wing: finger struts fanning out, skin stretched between them (flat in XY, +X outward).
func _wing(parent: Node3D, side: float, span: float, skin: Material, bone_m: Material, fingers: int = 4) -> Node3D:
	var w := Node3D.new()
	parent.add_child(w)
	var tips: Array = []
	for k in range(fingers):
		var a := deg_to_rad(lerpf(70.0, -35.0, float(k) / (fingers - 1)))
		var len_k: float = span * (1.0 - 0.18 * absf(k - 1.2) / fingers)
		tips.append(Vector3(cos(a) * len_k * side, sin(a) * len_k, 0))
	# Arm bone to the wrist, then fingers.
	var wrist := Vector3(0.28 * span * side, 0.25 * span, 0)
	var arm := _part(w, _cyl(0.018, 0.035, 1.0), Vector3.ZERO, bone_m)
	_align(arm, Vector3.ZERO, wrist)
	for tip in tips:
		var f := _part(w, _cyl(0.006, 0.016, 1.0), Vector3.ZERO, bone_m)
		_align(f, wrist, tip)
		var claw := _part(w, _cyl(0.0, 0.012, 0.07), tip, bone_m)
		_align(claw, tip, tip + (tip - wrist).normalized() * 0.07)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array = [Vector3.ZERO] + tips + [Vector3(0.05 * side, -0.35 * span, 0)]
	for k in range(pts.size() - 1):
		var a: Vector3 = pts[k] if k > 0 else Vector3.ZERO
		var b: Vector3 = pts[k + 1]
		# Scalloped edge: sag the membrane between two tips.
		var mid: Vector3 = (a + b) * 0.5
		var sag: Vector3 = mid.lerp(wrist, 0.24) if k > 0 else mid
		var root_p: Vector3 = wrist if k > 0 else Vector3.ZERO
		for tri in [[root_p, a, sag], [root_p, sag, b]]:
			for v in tri:
				st.set_uv(Vector2(0.5 + v.x / (span * 2.0), 0.5 - v.y / (span * 2.0)))
				st.add_vertex(v)
	st.generate_normals()
	var skin_mi := MeshInstance3D.new()
	skin_mi.mesh = st.commit()
	skin_mi.material_override = skin
	skin_mi.set_meta("gear", true)
	skin_mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	w.add_child(skin_mi)
	return w

func _align(node: Node3D, a: Vector3, b: Vector3) -> void:
	var d := b - a
	var l := d.length()
	if l < 0.0001: return
	var y := d / l
	var x := y.cross(Vector3.FORWARD if absf(y.dot(Vector3.FORWARD)) < 0.95 else Vector3.RIGHT).normalized()
	var z := x.cross(y).normalized()
	node.transform = Transform3D(Basis(x, y * l, z), (a + b) * 0.5)

## Cloth strip made of hanging segments; each swings a little later than the one above it.
func _ribbon(parent: Node3D, length: float, width: float, segs: int, mat: Material, base_rot: Vector3, amp: float, lift: float, phase: float = 0.0) -> void:
	var seg_len := length / segs
	var node := Node3D.new()
	node.rotation_degrees = base_rot
	parent.add_child(node)
	sways.append([node, base_rot, amp, 2.1, phase, lift])
	for i in range(segs):
		var w: float = width * (1.0 - 0.35 * float(i) / segs)
		_part(node, _box(w, seg_len * 1.04, 0.012), Vector3(0, -seg_len * 0.5, 0), mat)
		if i == segs - 1: break
		var nxt := Node3D.new()
		nxt.position = Vector3(0, -seg_len, 0)
		node.add_child(nxt)
		sways.append([nxt, Vector3(8, 0, 0), amp * 0.8, 2.1, phase + 0.7 * (i + 1), lift * 0.4])
		node = nxt

func _particles(parent: Node3D, color: Color, amount: int, radius: float, dir: Vector3, grav: Vector3, vel: Vector2, life: float, size: float, energy: float = 3.0) -> CPUParticles3D:
	var p := CPUParticles3D.new()
	# Phones: half the particles.
	p.amount = maxi(4, amount / 2) if load("res://scripts/platform.gd").low_graphics() else amount
	p.lifetime = life
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = radius
	p.direction = dir
	p.spread = 40.0
	p.gravity = grav
	p.initial_velocity_min = vel.x
	p.initial_velocity_max = vel.y
	p.scale_amount_min = 0.4
	p.scale_amount_max = 1.0
	var sm := _sphere(size, 8)
	var em := _glow(color, energy, true)
	em.vertex_color_use_as_albedo = true
	sm.material = em
	p.mesh = sm
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 1, 1, 1))
	ramp.set_color(1, Color(1, 1, 1, 0))
	p.color_ramp = ramp
	parent.add_child(p)
	return p

# ──────────────────────────────────────────────────────────── gear ──

func _g_sun_halo() -> void:
	var back := _attach("chest", Vector3(0, 0.12, -0.24))
	var halo := Node3D.new()
	back.add_child(halo)
	var gold := _metal(hero.primary.lightened(0.2), 0.22)
	_part(halo, _torus(0.3, 0.335), Vector3.ZERO, gold, Vector3(90, 0, 0))
	_part(halo, _torus(0.2, 0.215), Vector3.ZERO, _glow(hero.rim, 2.6), Vector3(90, 0, 0))
	for k in range(12):
		var a := TAU * k / 12.0
		var ray := _part(halo, _blade(0.16 if k % 2 == 0 else 0.1, 0.05, 0.015), Vector3(cos(a) * 0.335, sin(a) * 0.335, 0), gold)
		ray.rotation = Vector3(0, 0, a - PI * 0.5)
	spinners.append([halo, Vector3(0, 0, 1), 0.35])
	react["halo"] = halo

func _g_wrist_rings() -> void:
	for side in ["left_forearm", "right_forearm"]:
		var fa := _attach(side)
		var ring := Node3D.new()
		fa.add_child(ring)
		# Along the forearm: rings sit around the wrist end.
		var dir := _bone_dir(side)
		ring.position = dir * 0.2
		ring.basis = _basis_along(dir)
		_part(ring, _torus(0.045, 0.058), Vector3.ZERO, _glow(hero.rim, 3.0))
		_part(ring, _torus(0.05, 0.06), Vector3(0, 0.035, 0), _metal(hero.accent))

func _g_prayer_beads() -> void:
	var neck := _attach("neck", Vector3(0, -0.02, 0.02))
	var wood := _mat(hero.secondary.lightened(0.25), 0.1, 0.4)
	for k in range(18):
		var a := TAU * k / 18.0
		var p := Vector3(cos(a) * 0.13, -0.06 - 0.07 * maxf(0.0, sin(a)), sin(a) * 0.12)
		_part(neck, _sphere(0.02 if k != 4 else 0.035, 12), p, wood if k != 4 else _glow(hero.rim, 2.0))

func _g_aura_rise() -> void:
	var p := _particles(self, hero.rim, 36, 0.45, Vector3.UP, Vector3(0, 2.0, 0), Vector2(0.3, 1.0), 1.2, 0.03)
	p.position = Vector3(0, 0.9, 0)
	particles["aura"] = p

func _g_crest_pauldrons() -> void:
	var gold := _metal(hero.accent.darkened(0.1), 0.24)
	var dark := _metal(hero.secondary.lightened(0.1), 0.35)
	for side in [["left_arm", 1.0], ["right_arm", -1.0]]:
		var sh := _attach(side[0], Vector3(0.02 * side[1], 0.07, 0))
		var s: float = side[1]
		_part(sh, _sphere(0.11, 24), Vector3(0.02 * s, 0, 0), dark, Vector3.ZERO, Vector3(1.1, 0.7, 1.0))
		for k in range(3):
			var plate := _part(sh, _blade(0.22 - k * 0.04, 0.12, 0.025), Vector3(0.05 * s, 0.02 - k * 0.045, 0), gold)
			plate.rotation_degrees = Vector3(0, 0, -s * (55 + k * 18))
	# Chest crest
	var chest := _attach("chest", Vector3(0, 0.05, 0.13))
	_part(chest, _crystal_mesh(0.12, 0.04), Vector3.ZERO, _glow(hero.rim, 2.5), Vector3(90, 0, 0), Vector3(1, 1, 0.5))

func _g_blade_crown() -> void:
	var head := _attach("head", Vector3(0, 0.3, 0))
	var crown := Node3D.new()
	head.add_child(crown)
	var gold := _metal(hero.accent, 0.2)
	_part(crown, _torus(0.12, 0.135), Vector3.ZERO, _glow(hero.rim, 2.2))
	for k in range(7):
		var a := TAU * k / 7.0
		var b := _part(crown, _blade(0.13 if k % 2 == 0 else 0.09, 0.045, 0.012), Vector3(cos(a) * 0.13, 0.0, sin(a) * 0.13), gold)
		b.rotation = Vector3(0, -a, 0)
	spinners.append([crown, Vector3.UP, 0.6])
	sways.append([crown, Vector3.ZERO, 3.0, 1.3, 0.0, 0.0])

func _g_cape() -> void:
	var back := _attach("chest", Vector3(0, 0.08, -0.13))
	var m := _cloth(hero.primary.darkened(0.15))
	_ribbon(back, 1.05, 0.5, 6, m, Vector3(12, 0, 0), 5.0, 30.0)
	var clasp := _metal(hero.accent)
	for s in [-1.0, 1.0]:
		_part(back, _sphere(0.035, 16), Vector3(0.2 * s, 0.02, 0.02), clasp)

func _g_sparks() -> void:
	var p := _particles(self, hero.rim, 24, 0.5, Vector3.UP, Vector3(0, 1.2, 0), Vector2(0.4, 1.3), 0.8, 0.018, 5.0)
	p.position = Vector3(0, 1.0, 0)
	particles["aura"] = p

func _g_shard_orbit() -> void:
	var orbit := Node3D.new()
	var hips := _attach("hips", Vector3(0, 0.25, 0))
	hips.add_child(orbit)
	var m := _crystal(hero.rim)
	for k in range(6):
		var a := TAU * k / 6.0
		var c := _part(orbit, _crystal_mesh(0.22, 0.04), Vector3(cos(a) * 0.55, sin(k * 1.9) * 0.18, sin(a) * 0.55), m)
		c.rotation = Vector3(0.3 * k, a, 0.4)
	spinners.append([orbit, Vector3.UP, 0.9])
	react["orbit"] = orbit

func _g_void_horns() -> void:
	var head := _attach("head", Vector3(0, 0.14, 0.0))
	var m := _mat(Color(0.05, 0.04, 0.08), 0.6, 0.18)
	m.clearcoat_enabled = true
	var tip := _glow(hero.rim, 3.0)
	for s in [-1.0, 1.0]:
		var root := Node3D.new()
		root.position = Vector3(0.08 * s, 0.02, -0.02)
		head.add_child(root)
		var prev := Vector3.ZERO
		for k in range(6):
			var f := (k + 1) / 6.0
			var p := Vector3(0.1 * s * f + 0.06 * s * sin(f * 2.5), 0.2 * f, -0.12 * f * f)
			var seg := _part(root, _cyl(0.028 * (1.0 - f) + 0.004, 0.03 * (1.0 - f + 1.0 / 6.0) + 0.004, 1.0), Vector3.ZERO, tip if k == 5 else m)
			_align(seg, prev, p)
			prev = p

func _g_hover_sigil() -> void:
	var disc := Node3D.new()
	disc.position = Vector3(0, 0.04, 0)
	add_child(disc)
	var q := QuadMesh.new()
	q.size = Vector2(1.3, 1.3)
	var m := _glow(hero.rim, 2.2, true)
	m.albedo_texture = _rune_tex()
	m.emission_texture = _rune_tex()
	_part(disc, q, Vector3.ZERO, m, Vector3(-90, 0, 0))
	spinners.append([disc, Vector3.UP, 0.5])

func _g_nova_orb() -> void:
	var hand := _attach("right_hand", Vector3(0, 0.0, 0.12))
	var orb := Node3D.new()
	hand.add_child(orb)
	_part(orb, _sphere(0.1), Vector3.ZERO, _glow(hero.accent, 4.0))
	_part(orb, _sphere(0.16), Vector3.ZERO, _glow(hero.rim, 1.4, true))
	orb.scale = Vector3.ONE * 0.01
	react["charge_orb"] = orb

func _g_ice_pauldrons() -> void:
	var m := _crystal(hero.rim)
	for side in [["left_arm", 1.0], ["right_arm", -1.0]]:
		var sh := _attach(side[0], Vector3(0.0, 0.08, 0))
		var s: float = side[1]
		for k in range(5):
			var c := _part(sh, _crystal_mesh(0.14 + 0.05 * (k % 3), 0.028), Vector3(0.03 * s + 0.02 * k * s, 0.03, -0.05 + 0.03 * k), m)
			c.rotation_degrees = Vector3(-20 + k * 10, 0, -s * (20 + k * 14))

func _g_ice_tiara() -> void:
	var head := _attach("head", Vector3(0, 0.2, 0.04))
	var m := _crystal(hero.rim)
	_part(head, _torus(0.11, 0.118), Vector3(0, -0.02, -0.02), _metal(hero.accent, 0.15), Vector3(-12, 0, 0))
	for k in range(5):
		var x := (k - 2) * 0.045
		var c := _part(head, _crystal_mesh(0.07 + (0.06 if k == 2 else 0.0) - absf(k - 2) * 0.01, 0.014), Vector3(x, 0.03, 0.1 - absf(k - 2) * 0.012), m)
		c.rotation_degrees = Vector3(0, 0, -(k - 2) * 10)

func _g_frost_mist() -> void:
	for side in ["left_hand", "right_hand"]:
		var h := _attach(side)
		var p := _particles(h, hero.rim.lightened(0.3), 14, 0.06, Vector3.DOWN, Vector3(0, -0.6, 0), Vector2(0.05, 0.25), 1.1, 0.02, 1.6)
		particles[side + "_mist"] = p

func _g_rune_rings() -> void:
	var back := _attach("chest", Vector3(0, 0.1, -0.35))
	var tex := _rune_tex()
	for k in range(3):
		var ring := Node3D.new()
		ring.rotation_degrees = Vector3(0, 0, k * 60.0)
		back.add_child(ring)
		var q := QuadMesh.new()
		q.size = Vector2.ONE * (0.75 - k * 0.18)
		var m := _glow(hero.rim, 2.4, true)
		m.albedo_texture = tex
		m.emission_texture = tex
		_part(ring, q, Vector3(0, 0, -0.02 * k), m, Vector3(0, 0, 0))
		spinners.append([ring, Vector3(0, 0, 1), 0.4 * (1 if k % 2 == 0 else -1) * (1.0 + k * 0.4)])
	react["rings"] = back

func _g_gravity_orbs() -> void:
	var dark := _mat(Color(0.03, 0.02, 0.05), 0.2, 0.1)
	dark.rim = 1.0
	dark.rim_tint = 0.0
	for side in ["left_hand", "right_hand"]:
		var h := _attach(side)
		var orbit := Node3D.new()
		h.add_child(orbit)
		for k in range(3):
			var a := TAU * k / 3.0
			var o := _part(orbit, _sphere(0.035, 16), Vector3(cos(a) * 0.13, 0.02, sin(a) * 0.13), dark)
			_part(o, _torus(0.04, 0.046), Vector3.ZERO, _glow(hero.rim, 2.5), Vector3(70, 0, 0))
		spinners.append([orbit, Vector3.UP, 2.2])

func _g_aura_sink() -> void:
	var p := _particles(self, hero.rim, 30, 0.8, Vector3.DOWN, Vector3(0, -1.4, 0), Vector2(0.1, 0.5), 1.3, 0.025)
	p.position = Vector3(0, 1.3, 0)
	particles["aura"] = p

func _g_spring_bracers() -> void:
	var copper := _metal(Color("c07a3a"), 0.25)
	for side in ["left_forearm", "right_forearm"]:
		var fa := _attach(side)
		var dir := _bone_dir(side)
		var coil := Node3D.new()
		coil.basis = _basis_along(dir)
		coil.position = dir * 0.05
		fa.add_child(coil)
		for k in range(7):
			_part(coil, _torus(0.05, 0.062, 32), Vector3(0, k * 0.028, 0), copper, Vector3(8 if k % 2 == 0 else -8, 0, 0))
		_part(coil, _cyl(0.045, 0.045, 0.19), Vector3(0, 0.085, 0), _glow(hero.rim, 1.5))
		react[side + "_coil"] = coil

func _g_bandana() -> void:
	var head := _attach("head", Vector3(0, 0.12, 0))
	var m := _cloth(hero.rim.darkened(0.2))
	_part(head, _cyl(0.105, 0.108, 0.045, 32), Vector3(0, 0, 0), m, Vector3(-6, 0, 0))
	var knot := Node3D.new()
	knot.position = Vector3(0, 0.0, -0.1)
	head.add_child(knot)
	_part(knot, _sphere(0.03, 12), Vector3.ZERO, m)
	for s in [-1.0, 1.0]:
		_ribbon(knot, 0.32, 0.045, 4, m, Vector3(40, s * 15, s * 10), 8.0, 25.0, s)

func _g_wind_scarf() -> void:
	var neck := _attach("neck", Vector3(0, -0.02, 0))
	var m := _cloth(hero.primary.lightened(0.1))
	_part(neck, _torus(0.07, 0.11), Vector3(0, -0.02, 0.0), m, Vector3(0, 0, 0), Vector3(1, 1.4, 1))
	var tail := Node3D.new()
	tail.position = Vector3(0.05, -0.02, -0.09)
	neck.add_child(tail)
	_ribbon(tail, 0.95, 0.11, 7, m, Vector3(70, 10, 0), 10.0, 20.0)
	_ribbon(tail, 0.7, 0.09, 6, m, Vector3(60, -12, 0), 9.0, 18.0, 1.3)

func _g_back_blades() -> void:
	var back := _attach("chest", Vector3(0, 0.0, -0.14))
	var sheath := _mat(hero.secondary.lightened(0.15), 0.3, 0.3)
	sheath.clearcoat_enabled = true
	var wrap := _cloth(hero.primary)
	var guard := _metal(hero.accent, 0.2)
	for s in [-1.0, 1.0]:
		var blade := Node3D.new()
		blade.rotation_degrees = Vector3(0, 0, s * 32)
		back.add_child(blade)
		_part(blade, _box(0.05, 0.72, 0.03), Vector3(0, -0.12, 0), sheath)
		_part(blade, _cyl(0.05, 0.05, 0.012), Vector3(0, 0.25, 0), guard)
		_part(blade, _cyl(0.018, 0.018, 0.2), Vector3(0, 0.36, 0), wrap)
		_part(blade, _sphere(0.022, 12), Vector3(0, 0.47, 0), _glow(hero.rim, 2.0))

func _g_wind_swirl() -> void:
	var p := _particles(self, hero.rim, 30, 0.6, Vector3(0, 0.3, 0), Vector3(0, 0.4, 0), Vector2(0.4, 1.0), 1.0, 0.018)
	p.position = Vector3(0, 0.8, 0)
	p.orbit_velocity_min = 0.5
	p.orbit_velocity_max = 0.9
	particles["aura"] = p

func _g_hair_ribbons() -> void:
	var head := _attach("head", Vector3(0, 0.16, -0.08))
	var m := _cloth(hero.primary)
	for s in [-1.0, 1.0]:
		var bow := Node3D.new()
		bow.position = Vector3(0.07 * s, 0, 0)
		head.add_child(bow)
		_part(bow, _sphere(0.035, 12), Vector3.ZERO, _glow(hero.accent, 1.2))
		_ribbon(bow, 0.45, 0.05, 5, m, Vector3(25, 0, s * 12), 9.0, 20.0, s * 0.8)

func _g_petals() -> void:
	var p := CPUParticles3D.new()
	p.amount = 26
	p.lifetime = 2.4
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.7
	p.gravity = Vector3(0.3, -0.35, 0)
	p.initial_velocity_min = 0.1
	p.initial_velocity_max = 0.4
	p.angular_velocity_min = -180
	p.angular_velocity_max = 180
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.1
	var q := QuadMesh.new()
	q.size = Vector2(0.05, 0.035)
	var m := _mat(hero.rim, 0.0, 0.6)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.emission_enabled = true
	m.emission = hero.primary
	m.emission_energy_multiplier = 0.6
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	q.material = m
	p.mesh = q
	p.position = Vector3(0, 1.3, 0)
	add_child(p)
	particles["aura"] = p

func _g_petal_vortex() -> void:
	var hand := _attach("right_hand", Vector3(0, 0, 0.1))
	var vortex := Node3D.new()
	hand.add_child(vortex)
	var m := _glow(hero.rim, 2.5)
	for k in range(14):
		var a := TAU * k / 7.0
		var r := 0.05 + 0.012 * k
		_part(vortex, _sphere(0.018, 8), Vector3(cos(a) * r, k * 0.006 - 0.04, sin(a) * r), m, Vector3.ZERO, Vector3(1.4, 0.4, 0.8))
	_part(vortex, _sphere(0.05), Vector3.ZERO, _glow(hero.accent, 4.0))
	spinners.append([vortex, Vector3.UP, 9.0])
	vortex.scale = Vector3.ONE * 0.01
	react["charge_orb"] = vortex

func _g_arc_arms() -> void:
	for side in ["left_forearm", "right_forearm"]:
		var fa := _attach(side)
		var im := ImmediateMesh.new()
		var mi := MeshInstance3D.new()
		mi.mesh = im
		mi.material_override = _glow(hero.rim.lightened(0.3), 5.0, true)
		mi.set_meta("gear", true)
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		fa.add_child(mi)
		var dir := _bone_dir(side)
		arcs.append([im, dir * -0.02, dir * 0.28, 3])
	var p := _particles(self, hero.rim, 16, 0.5, Vector3.UP, Vector3.ZERO, Vector2(0.5, 1.5), 0.35, 0.012, 6.0)
	p.position = Vector3(0, 1.2, 0)
	particles["aura"] = p

func _g_crystal_tiara() -> void:
	var head := _attach("head", Vector3(0, 0.2, 0.05))
	var m := _crystal(hero.primary.lightened(0.25))
	_part(head, _torus(0.105, 0.113), Vector3(0, -0.02, -0.03), _metal(hero.accent, 0.2), Vector3(-12, 0, 0))
	var c := _part(head, _crystal_mesh(0.16, 0.03), Vector3(0, 0.06, 0.09), m)
	c.rotation_degrees = Vector3(12, 0, 0)
	for s in [-1.0, 1.0]:
		var c2 := _part(head, _crystal_mesh(0.09, 0.02), Vector3(0.06 * s, 0.03, 0.075), m)
		c2.rotation_degrees = Vector3(10, 0, -s * 22)

func _g_floating_crystals() -> void:
	var back := _attach("chest", Vector3(0, 0.15, -0.3))
	var m := _crystal(hero.primary.lightened(0.2))
	for k in range(3):
		var holder := Node3D.new()
		holder.position = Vector3((k - 1) * 0.28, 0.1 - absf(k - 1) * 0.12, 0)
		back.add_child(holder)
		_part(holder, _crystal_mesh(0.26 - absf(k - 1) * 0.06, 0.05), Vector3.ZERO, m)
		spinners.append([holder, Vector3.UP, 1.0 + k * 0.3])
		sways.append([holder, Vector3.ZERO, 6.0, 1.4, k * 1.1, 0.0])

func _g_impact_gauntlets() -> void:
	var plate := _metal(hero.secondary.lightened(0.25), 0.3)
	var trim := _metal(hero.accent, 0.2)
	for side in ["left_hand", "right_hand"]:
		var h := _attach(side)
		var dir := _bone_dir(side)
		var g := Node3D.new()
		g.basis = _basis_along(dir)
		h.add_child(g)
		_part(g, _box(0.17, 0.2, 0.16), Vector3(0, 0.06, 0), plate)
		_part(g, _cyl(0.1, 0.085, 0.2, 24), Vector3(0, -0.12, 0), plate)
		_part(g, _torus(0.095, 0.115), Vector3(0, -0.03, 0), trim)
		_part(g, _torus(0.085, 0.1), Vector3(0, -0.2, 0), trim)
		var knuckles := _glow(hero.rim, 1.6)
		for k in range(4):
			_part(g, _box(0.036, 0.04, 0.04), Vector3(-0.057 + k * 0.038, 0.17, 0.06), knuckles)
		react[side + "_fist"] = g

func _g_headband() -> void:
	var head := _attach("head", Vector3(0, 0.13, 0))
	var m := _cloth(hero.primary)
	_part(head, _cyl(0.104, 0.107, 0.04, 32), Vector3.ZERO, m, Vector3(-8, 0, 0))
	_part(head, _box(0.06, 0.035, 0.012), Vector3(0, 0.0, 0.106), _metal(hero.accent))
	var knot := Node3D.new()
	knot.position = Vector3(0, 0, -0.105)
	head.add_child(knot)
	for s in [-1.0, 1.0]:
		_ribbon(knot, 0.35, 0.04, 4, m, Vector3(35, s * 18, s * 8), 8.0, 25.0, s)

func _g_ember_mantle() -> void:
	var neck := _attach("neck", Vector3(0, -0.04, 0))
	var m := _cloth(hero.primary)
	# Braided rope collar with a glowing knot, a short cape over the back.
	_part(neck, _torus(0.075, 0.1), Vector3(0, -0.02, 0), _cloth(hero.secondary.lightened(0.3)), Vector3.ZERO, Vector3(1.05, 1.6, 1.0))
	_part(neck, _sphere(0.03, 12), Vector3(0.0, -0.05, 0.09), _glow(hero.rim, 2.5))
	var back := Node3D.new()
	back.position = Vector3(0, -0.06, -0.1)
	neck.add_child(back)
	_ribbon(back, 0.8, 0.38, 6, m, Vector3(12, 0, 0), 5.0, 25.0)

func _g_lantern() -> void:
	var hip := _attach("hips", Vector3(-0.16, -0.02, 0.05))
	var hang := Node3D.new()
	hip.add_child(hang)
	sways.append([hang, Vector3.ZERO, 10.0, 2.6, 0.0, 12.0])
	_part(hang, _cyl(0.004, 0.004, 0.1), Vector3(0, -0.05, 0), _metal(hero.accent))
	var frame := _metal(hero.secondary.lightened(0.3), 0.3)
	_part(hang, _cyl(0.04, 0.05, 0.02), Vector3(0, -0.1, 0), frame)
	_part(hang, _cyl(0.045, 0.045, 0.1, 6), Vector3(0, -0.16, 0), _glow(hero.rim, 3.5))
	_part(hang, _cyl(0.05, 0.04, 0.02), Vector3(0, -0.22, 0), frame)

func _g_hip_blade() -> void:
	var hip := _attach("hips", Vector3(0.16, 0.0, 0.0))
	var b := Node3D.new()
	b.rotation_degrees = Vector3(0, 0, 70)
	hip.add_child(b)
	var sheath := _mat(hero.secondary.lightened(0.1), 0.3, 0.35)
	sheath.clearcoat_enabled = true
	_part(b, _box(0.045, 0.62, 0.028), Vector3(0, -0.2, 0), sheath)
	_part(b, _cyl(0.045, 0.045, 0.012, 8), Vector3(0, 0.12, 0), _metal(hero.accent))
	_part(b, _cyl(0.016, 0.016, 0.18), Vector3(0, 0.22, 0), _cloth(hero.primary))
	for k in range(3):
		_part(b, _torus(0.022, 0.028), Vector3(0, -0.1 - k * 0.16, 0), _glow(hero.rim, 1.8))

func _g_embers() -> void:
	var p := _particles(self, hero.rim, 30, 0.5, Vector3.UP, Vector3(0, 1.6, 0), Vector2(0.3, 1.1), 1.3, 0.022, 4.0)
	p.position = Vector3(0, 0.9, 0)
	particles["aura"] = p

func _g_jet_boots() -> void:
	var shell := _metal(hero.accent.darkened(0.1), 0.25)
	for side in ["left_foot", "right_foot"]:
		var f := _attach(side)
		var jet := Node3D.new()
		jet.position = Vector3(0, 0.04, -0.08)
		f.add_child(jet)
		_part(jet, _cyl(0.045, 0.065, 0.14), Vector3.ZERO, shell, Vector3(-80, 0, 0))
		_part(jet, _torus(0.05, 0.062), Vector3(0, 0, -0.06), _glow(hero.rim, 2.5), Vector3(90, 0, 0))
		var flame := Node3D.new()
		flame.position = Vector3(0, -0.01, -0.07)
		jet.add_child(flame)
		_part(flame, _cyl(0.0, 0.035, 0.16), Vector3(0, 0, -0.08), _glow(hero.rim, 5.0, true), Vector3(-90, 0, 0))
		flame.scale = Vector3.ONE * 0.3
		react[side + "_jet"] = flame
		for s in [-1.0, 1.0]:
			var fin := _part(f, _blade(0.09, 0.05, 0.01), Vector3(0.05 * s, 0.07, -0.05), _glow(hero.rim, 1.8))
			fin.rotation_degrees = Vector3(-100, 0, s * 30)

func _g_visor() -> void:
	var head := _attach("head", Vector3(0, 0.09, 0.07))
	var m := _glow(hero.rim, 2.6)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.albedo_color = Color(hero.rim.r, hero.rim.g, hero.rim.b, 0.75)
	_part(head, _cyl(0.11, 0.11, 0.035, 32), Vector3(0, 0, -0.035), m, Vector3.ZERO, Vector3(1.0, 1.0, 1.02))

func _g_head_fins() -> void:
	var head := _attach("head", Vector3(0, 0.12, -0.02))
	var m := _metal(hero.primary.lightened(0.15), 0.25)
	for s in [-1.0, 1.0]:
		var fin := _part(head, _blade(0.16, 0.07, 0.014), Vector3(0.1 * s, 0.0, -0.02), m)
		fin.rotation_degrees = Vector3(-110, 0, s * 25)
		var edge := _part(head, _blade(0.12, 0.02, 0.016), Vector3(0.1 * s, 0.0, -0.02), _glow(hero.rim, 2.0))
		edge.rotation_degrees = Vector3(-110, 0, s * 25)

func _g_bolt_emblem() -> void:
	var chest := _attach("chest", Vector3(0, 0.02, 0.13))
	var m := _glow(hero.accent, 3.2)
	var pts := [Vector3(0.03, 0.09, 0), Vector3(-0.02, 0.005, 0), Vector3(0.02, 0.0, 0), Vector3(-0.03, -0.09, 0)]
	for k in range(3):
		var seg := _part(chest, _box(0.022, 1.0, 0.01), Vector3.ZERO, m)
		_align(seg, pts[k], pts[k + 1])
	for side in [["left_shin", 1.0], ["right_shin", -1.0]]:
		var sh := _attach(side[0], Vector3(0, 0.0, 0.06))
		_part(sh, _box(0.06, 0.1, 0.02), Vector3.ZERO, _glow(hero.rim, 2.0))

func _g_speed_trail() -> void:
	var p := CPUParticles3D.new()
	p.amount = 40
	p.lifetime = 0.35
	p.local_coords = false
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.emission_box_extents = Vector3(0.1, 0.8, 0.2)
	p.gravity = Vector3.ZERO
	p.initial_velocity_min = 0.0
	p.initial_velocity_max = 0.1
	var bm := _box(0.5, 0.012, 0.012)
	var m := _glow(hero.rim, 4.0, true)
	m.vertex_color_use_as_albedo = true
	bm.material = m
	p.mesh = bm
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 1, 1, 0.9))
	ramp.set_color(1, Color(1, 1, 1, 0))
	p.color_ramp = ramp
	p.position = Vector3(0, 0.95, 0)
	p.emitting = false
	add_child(p)
	particles["trail"] = p

func _g_thunder_drums() -> void:
	var back := _attach("chest", Vector3(0, 0.12, -0.3))
	var ring := Node3D.new()
	back.add_child(ring)
	var frame := _metal(hero.accent.darkened(0.3), 0.3)
	_part(ring, _torus(0.5, 0.53), Vector3.ZERO, frame, Vector3(90, 0, 0))
	var skin := _mat(hero.secondary.lightened(0.5), 0.0, 0.7)
	for k in range(8):
		var a := TAU * k / 8.0
		var drum := Node3D.new()
		drum.position = Vector3(cos(a) * 0.515, sin(a) * 0.515, 0)
		ring.add_child(drum)
		_part(drum, _cyl(0.085, 0.085, 0.07), Vector3.ZERO, frame, Vector3(90, 0, 0))
		_part(drum, _cyl(0.08, 0.08, 0.075), Vector3.ZERO, skin, Vector3(90, 0, 0))
		# Three-comma swirl: three glowing dots arranged in a swirl on the drum face.
		for j in range(3):
			var aj := TAU * j / 3.0 + a
			_part(drum, _sphere(0.016, 8), Vector3(cos(aj) * 0.035, sin(aj) * 0.035, 0.04), _glow(hero.rim, 2.2))
	spinners.append([ring, Vector3(0, 0, 1), 0.25])
	react["halo"] = ring

func _g_fist_rings() -> void:
	for side in ["left_hand", "right_hand"]:
		var h := _attach(side)
		var holder := Node3D.new()
		h.add_child(holder)
		for k in range(2):
			_part(holder, _torus(0.1 + k * 0.03, 0.11 + k * 0.03), Vector3.ZERO, _glow(hero.rim, 2.4), Vector3(90 * k, 45 * k, 0))
		spinners.append([holder, Vector3(1, 1, 0).normalized(), 3.0])

func _g_ground_star() -> void:
	var star := Node3D.new()
	star.position = Vector3(0, 0.03, 0)
	add_child(star)
	var m := _glow(hero.rim, 3.5, true)
	for k in range(8):
		var a := TAU * k / 8.0
		var b := _part(star, _blade(0.9 if k % 2 == 0 else 0.55, 0.14, 0.004), Vector3.ZERO, m)
		b.rotation = Vector3(-PI * 0.5, 0, 0)
		b.rotate_y(a)
	_part(star, _torus(0.5, 0.53), Vector3.ZERO, m)
	star.scale = Vector3.ONE * 0.01
	spinners.append([star, Vector3.UP, 1.5])
	react["counter_star"] = star

func _g_silver_wings() -> void:
	var back := _attach("chest", Vector3(0, 0.05, -0.16))
	var skin := _membrane(hero.secondary.lightened(0.35), hero.rim)
	var bone := _metal(hero.accent, 0.2)
	for s in [-1.0, 1.0]:
		var root := Node3D.new()
		root.position = Vector3(0.08 * s, 0, 0)
		root.rotation_degrees = Vector3(-8, -s * 42, 0)
		back.add_child(root)
		_wing(root, s, 1.05, skin, bone)
		sways.append([root.get_child(0), Vector3(0, 0, 0), 9.0, 2.0, 0.0, 0.0])
	react["wings"] = back

func _g_ember_wings() -> void:
	var back := _attach("chest", Vector3(0, 0.05, -0.18))
	var skin := _membrane(hero.primary.darkened(0.35), hero.rim)
	var bone := _mat(hero.secondary.lightened(0.2), 0.3, 0.35)
	for s in [-1.0, 1.0]:
		var root := Node3D.new()
		root.position = Vector3(0.08 * s, 0, 0)
		root.rotation_degrees = Vector3(-8, -s * 44, 0)
		back.add_child(root)
		_wing(root, s, 1.15, skin, bone, 5)
		sways.append([root.get_child(0), Vector3(0, 0, 0), 11.0, 2.4, 0.5, 0.0])
	react["wings"] = back

func _g_wyrm_horns() -> void:
	var head := _attach("head", Vector3(0, 0.14, -0.02))
	var m := _mat(hero.accent.darkened(0.15), 0.3, 0.25)
	m.clearcoat_enabled = true
	for s in [-1.0, 1.0]:
		var prev := Vector3(0.07 * s, 0, 0)
		for k in range(7):
			var f := (k + 1) / 7.0
			var p := Vector3(0.07 * s + 0.05 * s * f, 0.05 * sin(f * PI) + 0.03 * f, -0.22 * f)
			var seg := _part(head, _cyl(0.024 * (1.0 - f) + 0.003, 0.024 * (1.0 - f + 1.0 / 7.0) + 0.003, 1.0), Vector3.ZERO, m)
			_align(seg, prev, p)
			prev = p

func _g_breath_glow() -> void:
	var head := _attach("head", Vector3(0, 0.06, 0.14))
	var orb := Node3D.new()
	head.add_child(orb)
	_part(orb, _sphere(0.07), Vector3.ZERO, _glow(hero.accent, 4.0))
	_part(orb, _sphere(0.13), Vector3.ZERO, _glow(hero.rim, 1.5, true))
	orb.scale = Vector3.ONE * 0.01
	react["charge_orb"] = orb

func _g_flame_tail() -> void:
	var hips := _attach("hips", Vector3(0, -0.02, -0.12))
	var m := _mat(hero.primary.darkened(0.1), 0.2, 0.4)
	var node := hips
	var seg_len := 0.14
	for k in range(7):
		var seg := Node3D.new()
		seg.rotation_degrees = Vector3(-35 + k * 12 if k == 0 else 12, 0, 0)
		seg.position = Vector3(0, 0, 0) if k == 0 else Vector3(0, 0, -seg_len)
		node.add_child(seg)
		var r := 0.07 * (1.0 - k / 8.0)
		_part(seg, _cyl(r * 0.85, r, seg_len * 1.1), Vector3(0, 0, -seg_len * 0.5), m, Vector3(90, 0, 0))
		sways.append([seg, seg.rotation_degrees, 6.0, 1.6, k * 0.5, 0.0])
		node = seg
	var tip := Node3D.new()
	tip.position = Vector3(0, 0, -seg_len)
	node.add_child(tip)
	_part(tip, _sphere(0.05), Vector3.ZERO, _glow(hero.rim, 4.0))
	var fire := _particles(tip, hero.rim, 28, 0.04, Vector3.UP, Vector3(0, 1.8, 0), Vector2(0.2, 0.6), 0.6, 0.035, 4.0)
	fire.local_coords = false
	particles["tail_fire"] = fire

func _g_moon_circlet() -> void:
	var head := _attach("head", Vector3(0, 0.15, 0.06))
	_part(head, _torus(0.105, 0.112), Vector3(0, 0, -0.05), _metal(hero.accent, 0.15), Vector3(-10, 0, 0))
	var moon := Node3D.new()
	moon.position = Vector3(0, 0.03, 0.06)
	head.add_child(moon)
	# Crescent: a glowing ring with a dark disc cut over one side.
	_part(moon, _torus(0.028, 0.042), Vector3.ZERO, _glow(hero.rim, 3.0), Vector3(90, 0, 0))
	_part(moon, _cyl(0.034, 0.034, 0.012), Vector3(0.016, 0.01, 0.004), _metal(hero.accent, 0.15), Vector3(90, 0, 0))

func _g_quiver() -> void:
	var back := _attach("chest", Vector3(0.05, -0.05, -0.14))
	var q := Node3D.new()
	q.rotation_degrees = Vector3(0, 0, -20)
	back.add_child(q)
	var leather := _mat(hero.secondary.lightened(0.2), 0.05, 0.6)
	_part(q, _cyl(0.06, 0.05, 0.48), Vector3.ZERO, leather)
	_part(q, _torus(0.055, 0.066), Vector3(0, 0.22, 0), _metal(hero.accent, 0.2))
	var glow := _glow(hero.rim, 2.6)
	for k in range(5):
		var a := TAU * k / 5.0
		var arrow := Node3D.new()
		arrow.position = Vector3(cos(a) * 0.028, 0.3, sin(a) * 0.028)
		q.add_child(arrow)
		_part(arrow, _cyl(0.005, 0.005, 0.22), Vector3.ZERO, leather)
		_part(arrow, _blade(0.06, 0.035, 0.004), Vector3(0, 0.1, 0), glow)

func _g_moon_bow() -> void:
	var hand := _attach("left_hand", Vector3(0, 0, 0.02))
	var bow := Node3D.new()
	bow.basis = _basis_along(_bone_dir("left_hand"))
	hand.add_child(bow)
	var limb := _metal(hero.accent, 0.18)
	var n := 12
	var prev := Vector3.ZERO
	for i in range(n + 1):
		var f := lerpf(-1.0, 1.0, float(i) / n)
		# Recurve limb in the local XZ-plane, grip at the origin.
		var p := Vector3(-0.05 * (1.0 - f * f) + 0.04 * pow(absf(f), 3.0), 0, f * 0.55)
		if i > 0:
			var seg := _part(bow, _cyl(0.008, 0.011, 1.0), Vector3.ZERO, limb)
			_align(seg, prev, p)
		prev = p
	var string_m := _glow(hero.rim, 3.0)
	var s := _part(bow, _cyl(0.002, 0.002, 1.0), Vector3.ZERO, string_m)
	_align(s, Vector3(0.03, 0, -0.55), Vector3(0.03, 0, 0.55))
	_part(bow, _crystal_mesh(0.07, 0.018), Vector3(-0.055, 0, 0), _crystal(hero.rim), Vector3(90, 0, 0))

func _g_fireflies() -> void:
	var p := _particles(self, hero.rim, 14, 0.9, Vector3.UP, Vector3(0, 0.05, 0), Vector2(0.05, 0.2), 2.5, 0.02, 4.0)
	p.position = Vector3(0, 1.1, 0)
	particles["aura"] = p

# ─────────────────────────────── own fighters (formerly scan models) ──

## Hanging chain of segments (tail, vine); returns the tip node. Each segment swings later.
func _chain(parent: Node3D, segs: int, seg_len: float, r0: float, r1: float, mat: Material, first_rot: Vector3, bend: Vector3, amp: float, phase: float = 0.0) -> Node3D:
	var node := parent
	for k in range(segs):
		var seg := Node3D.new()
		seg.rotation_degrees = first_rot if k == 0 else bend
		seg.position = Vector3.ZERO if k == 0 else Vector3(0, 0, -seg_len)
		node.add_child(seg)
		var r: float = lerpf(r0, r1, float(k) / maxf(1.0, segs - 1))
		_part(seg, _cyl(r * 0.85, r, seg_len * 1.12), Vector3(0, 0, -seg_len * 0.5), mat, Vector3(90, 0, 0))
		sways.append([seg, seg.rotation_degrees, amp, 1.7, phase + k * 0.45, 0.0])
		node = seg
	var tip := Node3D.new()
	tip.position = Vector3(0, 0, -seg_len)
	node.add_child(tip)
	return tip

func _bark() -> StandardMaterial3D:
	var m := _mat(Color.WHITE, 0.0, 0.9)
	m.albedo_texture = _noise("bark_" + hero.secondary.to_html(), 0.06, false, 0.0, [hero.secondary.darkened(0.45), hero.secondary.lightened(0.15)])
	m.normal_enabled = true
	m.normal_texture = _noise("bark_n", 0.07, true, 12.0)
	m.normal_scale = 1.4
	m.uv1_scale = Vector3(1, 5, 1)
	return m

func _bone_m() -> StandardMaterial3D:
	var m := _mat(hero.accent.darkened(0.08), 0.05, 0.45)
	m.normal_enabled = true
	m.normal_texture = _noise("bone_n", 0.05, true, 4.0)
	m.normal_scale = 0.5
	return m

## Brunhild: golden helm with swept wings.
func _g_winged_helm() -> void:
	var head := _attach("head", Vector3(0, 0.1, 0))
	var gold := _metal(hero.primary, 0.2)
	_part(head, _sphere(0.122, 32), Vector3(0, 0.02, -0.01), gold, Vector3.ZERO, Vector3(1.0, 0.82, 1.08))
	_part(head, _box(0.03, 0.12, 0.05), Vector3(0, 0.0, 0.12), gold)
	_part(head, _torus(0.118, 0.13), Vector3(0, -0.04, 0), _metal(hero.accent, 0.15), Vector3(-6, 0, 0))
	var feather := _metal(hero.accent, 0.18)
	for s in [-1.0, 1.0]:
		var w := Node3D.new()
		w.position = Vector3(0.12 * s, 0.03, -0.02)
		w.rotation_degrees = Vector3(-25, -s * 20, -s * 55)
		head.add_child(w)
		for k in range(5):
			var f := _part(w, _blade(0.16 + k * 0.035, 0.05, 0.01), Vector3(0, 0, -k * 0.03), feather)
			f.rotation_degrees = Vector3(-k * 14, 0, 0)

## Brunhild: two-handed bearded axe in the right hand, glowing edge.
func _g_great_axe() -> void:
	var hand := _attach("right_hand", Vector3(0, 0, 0.02))
	var ax := Node3D.new()
	ax.basis = _basis_along(_bone_dir("right_hand"))
	hand.add_child(ax)
	var haft := _mat(hero.secondary.lightened(0.15), 0.1, 0.55)
	var shaft := Node3D.new()
	shaft.rotation_degrees = Vector3(90, 0, 0)
	ax.add_child(shaft)
	_part(shaft, _cyl(0.022, 0.026, 1.25), Vector3(0, 0.25, 0), haft)
	for k in range(4):
		_part(shaft, _torus(0.024, 0.032), Vector3(0, -0.2 + k * 0.08, 0), _metal(hero.accent))
	var head := Node3D.new()
	head.position = Vector3(0, 0.78, 0)
	shaft.add_child(head)
	var steel := _metal(hero.primary.lightened(0.25), 0.18)
	# Bearded blade: a curved fan in the XY-plane, both faces.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var pts: Array = []
	for i in range(9):
		var a := lerpf(-1.1, 1.1, i / 8.0)
		pts.append(Vector3(0.12 + 0.24 * cos(a * 0.6), 0.2 * sin(a) - 0.05 * a * a, 0))
	for th in [0.012, -0.012]:
		var c := Vector3(0.03, 0, th)
		for i in range(8):
			var a: Vector3 = pts[i] + Vector3(0, 0, th * 0.2)
			var b: Vector3 = pts[i + 1] + Vector3(0, 0, th * 0.2)
			if th > 0:
				st.add_vertex(c); st.add_vertex(a); st.add_vertex(b)
			else:
				st.add_vertex(c); st.add_vertex(b); st.add_vertex(a)
	st.generate_normals()
	_part(head, st.commit(), Vector3.ZERO, steel)
	_part(head, _blade(0.4, 0.03, 0.02), Vector3(0.355, -0.2, 0), _glow(hero.rim, 2.4))
	_part(head, _box(0.06, 0.12, 0.06), Vector3.ZERO, steel)
	_part(head, _cyl(0.0, 0.03, 0.14), Vector3(-0.09, 0, 0), steel, Vector3(0, 0, 90))

## Thorn witch: crown of black thorns with glowing buds.
func _g_thorn_crown() -> void:
	var head := _attach("head", Vector3(0, 0.13, 0))
	var wood := _bark()
	_part(head, _torus(0.1, 0.118), Vector3.ZERO, wood, Vector3(-8, 0, 0))
	var bud := _glow(hero.rim, 3.0)
	for k in range(11):
		var a := TAU * k / 11.0
		var h: float = 0.07 + 0.1 * (0.5 + 0.5 * cos(a))
		var p := Vector3(sin(a) * 0.11, 0.0, cos(a) * 0.11)
		var thorn := _part(head, _cyl(0.0, 0.016, h, 8), p + Vector3(0, h * 0.5, 0), wood)
		thorn.rotation = Vector3(cos(a) * 0.35, 0, -sin(a) * 0.35)
		if k % 3 == 0:
			_part(head, _sphere(0.016, 12), p + Vector3(sin(a) * 0.02, h + 0.005, cos(a) * 0.02), bud)

## Thorn witch: thorny vines curling from both wrists.
func _g_vine_whips() -> void:
	var vine := _bark()
	var spike := _mat(hero.secondary.lightened(0.4), 0.0, 0.5)
	for side in ["left_hand", "right_hand"]:
		var h := _attach(side)
		var tip := _chain(h, 9, 0.11, 0.016, 0.007, vine, Vector3(70, 0, 0), Vector3(14, 6, 0), 9.0, 0.6 if side == "left_hand" else 0.0)
		_part(tip, _sphere(0.03, 12), Vector3.ZERO, _glow(hero.rim, 3.2))
		var n: Node = tip.get_parent()
		while n is Node3D and n != h:
			_part(n, _cyl(0.0, 0.008, 0.05, 6), Vector3(0.012, 0, -0.04), spike, Vector3(0, 0, -70))
			n = n.get_parent()
	var p := _particles(self, hero.rim, 10, 0.6, Vector3.UP, Vector3(0, 0.3, 0), Vector2(0.05, 0.25), 1.6, 0.016, 3.0)
	p.position = Vector3(0, 1.0, 0)
	particles["vine"] = p

## Thorn witch: spiked shoulder bark.
func _g_thorn_spikes() -> void:
	var wood := _bark()
	for side in ["left_shoulder", "right_shoulder"]:
		var s := -1.0 if side == "left_shoulder" else 1.0
		var sh := _attach(side, Vector3(0.06 * -s, 0.05, 0))
		_part(sh, _sphere(0.09, 16), Vector3.ZERO, wood, Vector3.ZERO, Vector3(1.2, 0.7, 1.1))
		for k in range(4):
			var sp := _part(sh, _cyl(0.0, 0.022, 0.16, 8), Vector3((k - 1.5) * 0.04, 0.08, -0.02), wood)
			sp.rotation_degrees = Vector3(-25, 0, (k - 1.5) * 18 - s * 20)

## Nyx: long scythe with a glowing soul blade.
func _g_soul_scythe() -> void:
	var hand := _attach("right_hand", Vector3(0, 0, 0.02))
	var sc := Node3D.new()
	sc.basis = _basis_along(_bone_dir("right_hand"))
	hand.add_child(sc)
	var shaft := Node3D.new()
	shaft.rotation_degrees = Vector3(90, 0, 0)
	sc.add_child(shaft)
	var bone := _bone_m()
	_part(shaft, _cyl(0.018, 0.022, 1.7), Vector3(0, 0.3, 0), _mat(hero.secondary.lightened(0.1), 0.4, 0.3))
	for k in range(5):
		_part(shaft, _sphere(0.03, 10), Vector3(0, -0.4 + k * 0.32, 0), bone, Vector3.ZERO, Vector3(1, 0.6, 1))
	var top := Node3D.new()
	top.position = Vector3(0, 1.15, 0)
	shaft.add_child(top)
	_part(top, _sphere(0.045, 16), Vector3.ZERO, _glow(hero.rim, 3.5))
	_part(top, _blade(0.75, 0.16, 0.02, -0.35), Vector3.ZERO, _glow(hero.rim, 2.2), Vector3(0, 0, -100))
	_part(top, _blade(0.7, 0.07, 0.025, -0.33), Vector3(0, 0.01, 0), _metal(hero.accent.darkened(0.3), 0.15), Vector3(0, 0, -100))

## Shira: cat ears with pink inner fur.
func _g_cat_ears() -> void:
	var head := _attach("head", Vector3(0, 0.15, -0.01))
	var fur := _cloth(hero.secondary.lightened(0.15))
	var inner := _mat(hero.primary.lightened(0.2), 0.0, 0.7)
	for s in [-1.0, 1.0]:
		var ear := Node3D.new()
		ear.position = Vector3(0.075 * s, 0.02, 0)
		ear.rotation_degrees = Vector3(-8, 0, -s * 18)
		head.add_child(ear)
		_part(ear, _cyl(0.0, 0.05, 0.13, 3), Vector3(0, 0.06, 0), fur, Vector3(0, 30, 0), Vector3(1, 1, 0.45))
		_part(ear, _cyl(0.0, 0.032, 0.09, 3), Vector3(0, 0.05, 0.012), inner, Vector3(0, 30, 0), Vector3(1, 1, 0.25))
		sways.append([ear, ear.rotation_degrees, 3.0, 3.1, s, 0.0])

## Shira: long cat tail with a ribbon and bell.
func _g_cat_tail() -> void:
	var hips := _attach("hips", Vector3(0, -0.03, -0.12))
	var fur := _cloth(hero.secondary.lightened(0.15))
	var tip := _chain(hips, 9, 0.1, 0.035, 0.022, fur, Vector3(-40, 0, 0), Vector3(14, 4, 0), 10.0)
	_part(tip, _sphere(0.026, 12), Vector3.ZERO, _cloth(hero.primary))
	var first: Node3D = hips.get_child(0)
	_part(first, _torus(0.035, 0.05), Vector3(0, 0, -0.04), _cloth(hero.primary), Vector3(90, 0, 0))
	_part(first, _sphere(0.025, 12), Vector3(0, -0.05, -0.04), _metal(hero.accent))

## Frostwyrm: segmented tail ending in an ice crystal.
func _g_ice_tail() -> void:
	var hips := _attach("hips", Vector3(0, -0.02, -0.12))
	var scales := _metal(hero.primary.darkened(0.2), 0.32)
	var ice := _crystal(hero.rim)
	var tip := _chain(hips, 8, 0.15, 0.09, 0.035, scales, Vector3(-45, 0, 0), Vector3(11, 0, 0), 6.0)
	_part(tip, _crystal_mesh(0.3, 0.06), Vector3(0, 0, -0.12), ice, Vector3(90, 0, 0))
	var n: Node = tip.get_parent()
	var k := 0
	while n is Node3D and n != hips:
		if k % 2 == 0:
			_part(n, _crystal_mesh(0.08, 0.018), Vector3(0, 0.05, -0.05), ice, Vector3(-30, 0, 0))
		n = n.get_parent()
		k += 1

## Cyborg: shoulder plates, chest core with glowing seams.
func _g_mech_plating() -> void:
	var white := _metal(hero.primary, 0.3)
	var dark := _metal(hero.secondary, 0.35)
	var seam := _glow(hero.rim, 2.4)
	for side in ["left_shoulder", "right_shoulder"]:
		var s := -1.0 if side == "left_shoulder" else 1.0
		var sh := _attach(side, Vector3(0.08 * -s, 0.06, 0))
		_part(sh, _box(0.2, 0.06, 0.2), Vector3(0, 0.02, 0), white, Vector3(0, 0, -s * 18))
		_part(sh, _box(0.17, 0.05, 0.17), Vector3(0, -0.04, 0), dark, Vector3(0, 0, -s * 24))
		_part(sh, _box(0.2, 0.012, 0.02), Vector3(0, 0.055, 0.08), seam, Vector3(0, 0, -s * 18))
	var chest := _attach("chest", Vector3(0, 0.02, 0.12))
	_part(chest, _cyl(0.06, 0.06, 0.03, 6), Vector3.ZERO, dark, Vector3(90, 0, 0))
	_part(chest, _sphere(0.04, 16), Vector3(0, 0, 0.02), _glow(hero.rim, 4.0))
	for k in range(2):
		_part(chest, _box(0.16 - k * 0.04, 0.01, 0.01), Vector3(0, -0.08 - k * 0.05, -0.01), seam)

## Cyborg: shoulder cannon whose muzzle charges up.
func _g_shoulder_cannon() -> void:
	var back := _attach("chest", Vector3(0.14, 0.18, -0.12))
	var mount := Node3D.new()
	back.add_child(mount)
	var white := _metal(hero.primary, 0.3)
	_part(mount, _box(0.08, 0.1, 0.1), Vector3.ZERO, _metal(hero.secondary, 0.35))
	_part(mount, _cyl(0.04, 0.05, 0.42), Vector3(0, 0.06, 0.12), white, Vector3(80, 0, 0))
	for k in range(3):
		_part(mount, _torus(0.045, 0.056), Vector3(0, 0.03 + k * 0.012, 0.05 + k * 0.08), _glow(hero.rim, 2.0), Vector3(80, 0, 0))
	var muzzle := Node3D.new()
	muzzle.position = Vector3(0, 0.1, 0.34)
	mount.add_child(muzzle)
	_part(muzzle, _sphere(0.05), Vector3.ZERO, _glow(hero.rim, 4.5))
	muzzle.scale = Vector3.ONE * 0.01
	react["charge_orb"] = muzzle

## Reaper hound: bone skull mask with burning eyes.
func _g_skull_mask() -> void:
	var head := _attach("head", Vector3(0, 0.08, 0.06))
	var bone := _bone_m()
	var socket := _mat(Color(0.02, 0.01, 0.01), 0.0, 0.9)
	# Half mask over brow, eyes and snout; the lower jaw stays free.
	_part(head, _sphere(0.1, 24), Vector3(0, 0.02, 0.02), bone, Vector3.ZERO, Vector3(1.05, 0.62, 0.7))
	_part(head, _box(0.07, 0.035, 0.09), Vector3(0, -0.025, 0.08), bone, Vector3(12, 0, 0))
	var eye := _glow(hero.rim, 4.0)
	for s in [-1.0, 1.0]:
		_part(head, _sphere(0.024, 12), Vector3(0.04 * s, 0.015, 0.075), socket, Vector3.ZERO, Vector3(1.2, 0.9, 0.5))
		_part(head, _sphere(0.009, 8), Vector3(0.04 * s, 0.015, 0.088), eye)
		_part(head, _cyl(0.0, 0.008, 0.045, 6), Vector3(0.022 * s, -0.06, 0.11), bone, Vector3(170, 0, 0))
		_part(head, _cyl(0.0, 0.02, 0.15, 8), Vector3(0.075 * s, 0.07, -0.04), bone, Vector3(-55, 0, -s * 30))

## Reaper hound: vertebra spikes down the back.
func _g_bone_spikes() -> void:
	var bone := _bone_m()
	for key in ["chest", "spine"]:
		var b := _attach(key, Vector3(0, 0.0, -0.13))
		for k in range(3):
			_part(b, _cyl(0.0, 0.03, 0.17 - k * 0.03, 8), Vector3(0, 0.08 - k * 0.08, 0), bone, Vector3(-60, 0, 0))

## Reaper hound: whip of vertebrae with a ghost flame.
func _g_bone_tail() -> void:
	var hips := _attach("hips", Vector3(0, -0.03, -0.12))
	var tip := _chain(hips, 10, 0.09, 0.03, 0.015, _bone_m(), Vector3(-35, 0, 0), Vector3(10, 0, 0), 9.0)
	var fire := _particles(tip, hero.rim, 22, 0.04, Vector3.UP, Vector3(0, 1.4, 0), Vector2(0.2, 0.5), 0.55, 0.03, 4.0)
	fire.local_coords = false
	particles["tail_fire"] = fire

## Treant: bark plates over chest, shoulders and forearms, a glowing heartwood.
func _g_bark_armor() -> void:
	var bark := _bark()
	var chest := _attach("chest", Vector3(0, 0.0, 0.05))
	_part(chest, _sphere(0.2, 20), Vector3.ZERO, bark, Vector3.ZERO, Vector3(1.25, 1.0, 0.8))
	_part(chest, _sphere(0.045, 14), Vector3(0, 0, 0.16), _glow(hero.rim, 3.5))
	for side in ["left_shoulder", "right_shoulder", "left_forearm", "right_forearm"]:
		_part(_attach(side), _sphere(0.1, 14), Vector3(0, 0.03, 0), bark, Vector3.ZERO, Vector3(1.3, 0.9, 1.3))

## Treant: branching antlers with leaf buds.
func _g_antlers() -> void:
	var head := _attach("head", Vector3(0, 0.12, -0.01))
	var wood := _bark()
	var leaf := _mat(hero.primary, 0.0, 0.7)
	for s in [-1.0, 1.0]:
		var prev := Vector3(0.06 * s, 0, 0)
		var pts: Array = []
		for k in range(5):
			var f := (k + 1) / 5.0
			var p := Vector3(0.06 * s + 0.2 * s * f, 0.32 * f - 0.05 * f * f, -0.06 * f)
			var seg := _part(head, _cyl(0.012 * (1.2 - f), 0.016 * (1.3 - f), 1.0, 8), Vector3.ZERO, wood)
			_align(seg, prev, p)
			pts.append(p)
			prev = p
		for k in [1, 2, 3]:
			var a: Vector3 = pts[k]
			var b: Vector3 = a + Vector3(-0.02 * s, 0.1, 0.03 * (k - 2))
			var br := _part(head, _cyl(0.004, 0.009, 1.0, 6), Vector3.ZERO, wood)
			_align(br, a, b)
			_part(head, _sphere(0.025, 8), b, leaf, Vector3.ZERO, Vector3(1.2, 0.5, 0.8))

## Moss tufts on shoulders, head and back, swaying.
func _g_moss_tufts() -> void:
	var moss := _mat(Color.WHITE, 0.0, 0.95)
	moss.albedo_texture = _noise("moss_" + hero.primary.to_html(), 0.12, false, 0.0, [hero.primary.darkened(0.45), hero.primary.lightened(0.1)])
	for key in ["left_shoulder", "right_shoulder", "head", "chest"]:
		var b := _attach(key, Vector3(0, 0.08 if key == "head" else 0.04, -0.06 if key == "chest" else 0.0))
		for k in range(5):
			var a := TAU * k / 5.0
			var tuft := _part(b, _sphere(0.035, 8), Vector3(cos(a) * 0.05, 0.0, sin(a) * 0.05), moss, Vector3.ZERO, Vector3(1.0, 0.55, 1.0))
			sways.append([tuft, Vector3.ZERO, 6.0, 1.3, a, 0.0])

## Celestial fox: tall fox ears with gold tips.
func _g_fox_ears() -> void:
	var head := _attach("head", Vector3(0, 0.15, -0.01))
	var fur := _cloth(hero.primary)
	var tipm := _metal(hero.accent, 0.2)
	for s in [-1.0, 1.0]:
		var ear := Node3D.new()
		ear.position = Vector3(0.07 * s, 0.03, 0)
		ear.rotation_degrees = Vector3(-5, 0, -s * 14)
		head.add_child(ear)
		_part(ear, _cyl(0.0, 0.05, 0.18, 4), Vector3(0, 0.08, 0), fur, Vector3(0, 45, 0), Vector3(1, 1, 0.45))
		_part(ear, _cyl(0.0, 0.02, 0.05, 4), Vector3(0, 0.155, 0), tipm, Vector3(0, 45, 0), Vector3(1, 1, 0.45))
		sways.append([ear, ear.rotation_degrees, 2.5, 2.7, s, 0.0])

## Celestial fox: nine tails fanning out behind, each with a glowing tip.
func _g_nine_tails() -> void:
	var hips := _attach("hips", Vector3(0, 0.0, -0.12))
	var fur := _cloth(hero.primary)
	var glow := _glow(hero.rim, 3.0)
	for k in range(9):
		var root := Node3D.new()
		root.rotation_degrees = Vector3(0, lerpf(-70.0, 70.0, k / 8.0), 0)
		hips.add_child(root)
		var tip := _chain(root, 7, 0.13, 0.06, 0.035, fur, Vector3(20 + 12 * absf(k - 4.0) * 0.25, 0, 0), Vector3(9, 0, 0), 8.0, k * 0.7)
		_part(tip, _sphere(0.035, 12), Vector3(0, 0, 0.01), glow)

## Celestial fox: three blue foxfire flames orbiting.
func _g_foxfire_orbs() -> void:
	var orbit := Node3D.new()
	var hips := _attach("hips", Vector3(0, 0.35, 0))
	hips.add_child(orbit)
	for k in range(3):
		var a := TAU * k / 3.0
		var o := Node3D.new()
		o.position = Vector3(cos(a) * 0.55, 0.1 * sin(k * 2.0), sin(a) * 0.55)
		orbit.add_child(o)
		_part(o, _sphere(0.045, 12), Vector3.ZERO, _glow(hero.rim, 4.0))
		_part(o, _sphere(0.08, 12), Vector3.ZERO, _glow(hero.rim, 1.2, true))
		var f := _particles(o, hero.rim, 10, 0.03, Vector3.UP, Vector3(0, 1.0, 0), Vector2(0.1, 0.3), 0.5, 0.02, 4.0)
		f.local_coords = false
	spinners.append([orbit, Vector3.UP, 1.2])
	react["orbit"] = orbit

## Mossback: shell of boulders and crystal spikes on the back.
func _g_stone_back() -> void:
	var rock := _mat(Color.WHITE, 0.0, 0.92)
	rock.albedo_texture = _noise("rock_" + hero.secondary.to_html(), 0.08, false, 0.0, [hero.secondary.darkened(0.4), hero.secondary.lightened(0.25)])
	rock.normal_enabled = true
	rock.normal_texture = _noise("rock_n", 0.09, true, 10.0)
	var crystal := _crystal(hero.rim)
	var back := _attach("chest", Vector3(0, 0.05, -0.16))
	for k in range(7):
		var a := k * 2.1
		var p := Vector3(sin(a) * 0.14, 0.12 - k * 0.05, -0.02 * (k % 2))
		_part(back, _sphere(0.08 + 0.02 * (k % 3), 10), p, rock, Vector3(k * 20, k * 33, 0), Vector3(1.2, 0.8, 1.0))
	for k in range(4):
		_part(back, _crystal_mesh(0.22 - k * 0.03, 0.035), Vector3((k - 1.5) * 0.08, 0.15, -0.08), crystal, Vector3(-40, 0, (k - 1.5) * 15))

## Mossback: heavy curled ram horns.
func _g_ram_horns() -> void:
	var head := _attach("head", Vector3(0, 0.1, -0.02))
	var m := _bone_m()
	for s in [-1.0, 1.0]:
		var prev := Vector3(0.08 * s, 0.02, 0)
		for k in range(10):
			var f := (k + 1) / 10.0
			var ang := f * PI * 1.4
			var p := Vector3((0.1 + 0.07 * cos(ang)) * s, 0.02 + 0.09 * sin(ang), -0.08 * f)
			var seg := _part(head, _cyl(0.022 * (1.15 - f) + 0.006, 0.026 * (1.2 - f) + 0.008, 1.0, 10), Vector3.ZERO, m)
			_align(seg, prev, p)
			prev = p

# ──────────────────────────────── Arbër, the drill master (own fighter) ──

static var _embroidery: Texture2D = null

## Black velvet with gold scrollwork and a red border, as on a festive xhamadan vest.
static func _embroidery_tex() -> Texture2D:
	if _embroidery != null: return _embroidery
	var n := 256
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var gold := Color("d4a017")
	var red := Color("b91c1c")
	for y in range(n):
		for x in range(n):
			var u := float(x) / n
			var v := float(y) / n
			var c := Color(0.045, 0.04, 0.045)
			# Velvet: faint vertical nap.
			c = c.lightened(0.04 * sin(u * 220.0) * sin(v * 7.0))
			# Border bands top and bottom, red with a gold line.
			if v < 0.07 or v > 0.93: c = red
			if absf(v - 0.085) < 0.008 or absf(v - 0.915) < 0.008: c = gold
			# Scrolls: rows of mirrored spirals.
			var cu := fmod(u * 4.0, 1.0) - 0.5
			var cv := fmod(v * 3.0, 1.0) - 0.5
			var r := sqrt(cu * cu + cv * cv)
			var a := atan2(cv, absf(cu))
			var spiral := absf(fmod(r * 18.0 - a * 1.4 + 20.0, TAU / 1.4) - 1.2)
			if r > 0.08 and r < 0.42 and spiral < 0.22 and v > 0.1 and v < 0.9: c = gold.darkened(0.15 * r)
			if r < 0.05 and v > 0.1 and v < 0.9: c = red.lightened(0.1)
			img.set_pixel(x, y, c)
	img.generate_mipmaps()
	_embroidery = ImageTexture.create_from_image(img)
	return _embroidery

## Open shell around the torso (front left open), a slice of a cylinder.
func _arc_shell(r: float, h: float, a0: float, a1: float, segs: int = 28) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for k in range(segs):
		var t0 := lerpf(a0, a1, float(k) / segs)
		var t1 := lerpf(a0, a1, float(k + 1) / segs)
		var p0 := Vector3(sin(t0) * r, 0, cos(t0) * r)
		var p1 := Vector3(sin(t1) * r, 0, cos(t1) * r)
		var u0 := float(k) / segs
		var u1 := float(k + 1) / segs
		var lo := Vector3(0, -h * 0.5, 0)
		var hi := Vector3(0, h * 0.5, 0)
		for tri in [[p0 + lo, u0, 1.0], [p1 + lo, u1, 1.0], [p1 + hi * 1.0, u1, 0.0], [p0 + lo, u0, 1.0], [p1 + hi, u1, 0.0], [p0 + hi, u0, 0.0]]:
			st.set_uv(Vector2(tri[1], tri[2]))
			st.add_vertex(tri[0])
	st.generate_normals()
	return st.commit()

## White felt cap (qeleshe): short dome, slightly flattened.
func _g_qeleshe() -> void:
	var head := _attach("head", Vector3(0, 0.13, -0.005))
	var felt := _mat(Color.WHITE, 0.0, 0.95)
	felt.albedo_texture = _noise("felt", 0.09, false, 0.0, [Color(0.68, 0.66, 0.62), Color(0.8, 0.79, 0.75)])
	felt.rim = 0.15
	felt.normal_enabled = true
	felt.normal_texture = _noise("felt_n", 0.2, true, 3.0)
	felt.normal_scale = 0.4
	_part(head, _cyl(0.096, 0.104, 0.07, 32), Vector3(0, 0.0, 0), felt)
	_part(head, _sphere(0.097, 32), Vector3(0, 0.03, 0), felt, Vector3.ZERO, Vector3(1.0, 0.42, 1.0))
	# Stitched rim.
	_part(head, _torus(0.1, 0.108), Vector3(0, -0.033, 0), _mat(Color(0.8, 0.79, 0.74), 0.0, 0.9))

## Embroidered vest over the bare chest, red sash (brez) with fringe at the waist.
func _g_xhamadan() -> void:
	var chest := _attach("chest", Vector3(0, -0.04, -0.01))
	var velvet := _mat(Color.WHITE, 0.0, 0.7)
	velvet.albedo_texture = _embroidery_tex()
	velvet.cull_mode = BaseMaterial3D.CULL_DISABLED
	velvet.rim = 0.35
	var vest := _part(chest, _arc_shell(0.205, 0.46, deg_to_rad(30.0), deg_to_rad(330.0)), Vector3(0, 0, 0.01), velvet, Vector3.ZERO, Vector3(1.3, 1.0, 1.0))
	vest.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	var gold := _metal(hero.accent, 0.25)
	# Gold cord along the opening and silver-gold buttons.
	for s in [-1.0, 1.0]:
		var edge := Vector3(sin(deg_to_rad(30.0)) * 0.205 * 1.3 * s, 0, cos(deg_to_rad(30.0)) * 0.205 + 0.01)
		_part(chest, _cyl(0.008, 0.008, 0.46), edge, gold)
		for k in range(4):
			_part(chest, _sphere(0.012, 10), edge + Vector3(0, 0.12 - k * 0.07, 0.005), gold)
	var hips := _attach("hips", Vector3(0, 0.1, 0))
	var sash := _cloth(hero.get("sash", hero.secondary))
	_part(hips, _cyl(0.19, 0.185, 0.12, 32), Vector3.ZERO, sash, Vector3.ZERO, Vector3(1.15, 1.0, 0.95))
	var knot := Node3D.new()
	knot.position = Vector3(0.12, -0.02, 0.1)
	hips.add_child(knot)
	_part(knot, _sphere(0.035, 12), Vector3.ZERO, sash)
	for k in range(2):
		_ribbon(knot, 0.3, 0.05, 4, sash, Vector3(8, 0, 6 - k * 12), 6.0, 18.0, k * 0.8)

## Leather tool belt: pouches, a tape measure, spare drill bits.
func _g_tool_belt() -> void:
	var hips := _attach("hips", Vector3(0, 0.02, 0))
	var leather := _mat(Color("5b3a1e"), 0.05, 0.6)
	leather.normal_enabled = true
	leather.normal_texture = _noise("leather_n", 0.15, true, 4.0)
	_part(hips, _cyl(0.178, 0.178, 0.045, 32), Vector3.ZERO, leather, Vector3.ZERO, Vector3(1.13, 1.0, 0.94))
	_part(hips, _box(0.06, 0.05, 0.02), Vector3(0, 0, 0.165), _metal(Color("c0c0c0"), 0.2))
	for s in [-1.0, 1.0]:
		var pouch := _part(hips, _box(0.09, 0.11, 0.05), Vector3(0.17 * s, -0.06, 0.06), leather, Vector3(0, s * 30, 0))
		pouch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		_part(hips, _box(0.095, 0.03, 0.055), Vector3(0.17 * s, -0.01, 0.06), leather.duplicate(), Vector3(0, s * 30, 0))
	# Yellow tape measure on the left, bits in loops on the right.
	_part(hips, _cyl(0.035, 0.035, 0.025, 20), Vector3(-0.19, -0.04, -0.05), _mat(Color("facc15"), 0.1, 0.4), Vector3(0, 0, 90))
	var steel := _metal(Color("9ca3af"), 0.2)
	for k in range(4):
		_part(hips, _cyl(0.004 + k * 0.001, 0.004 + k * 0.001, 0.12, 8), Vector3(0.2, -0.06, -0.02 - k * 0.018), steel)

## Spiral drill bit: two twisted flutes around a core (along +Y).
func _drill_bit(length: float, radius: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps := 40
	var ring := 8
	for flute in range(2):
		for i in range(steps):
			var f0 := float(i) / steps
			var f1 := float(i + 1) / steps
			var r0: float = radius * (1.0 - pow(f0, 6.0))
			var r1: float = radius * (1.0 - pow(f1, 6.0))
			var a0 := f0 * TAU * 3.0 + flute * PI
			var a1 := f1 * TAU * 3.0 + flute * PI
			for k in range(ring):
				var b0 := TAU * k / ring
				var b1 := TAU * (k + 1) / ring
				var c0 := Vector3(cos(a0), 0, sin(a0)) * r0 * 0.55
				var c1 := Vector3(cos(a1), 0, sin(a1)) * r1 * 0.55
				var w0: float = r0 * 0.45
				var w1: float = r1 * 0.45
				var q := [c0 + Vector3(cos(b0) * w0, f0 * length + sin(b0) * w0 * 0.6, sin(b0) * w0), c0 + Vector3(cos(b1) * w0, f0 * length + sin(b1) * w0 * 0.6, sin(b1) * w0),
					c1 + Vector3(cos(b1) * w1, f1 * length + sin(b1) * w1 * 0.6, sin(b1) * w1), c1 + Vector3(cos(b0) * w1, f1 * length + sin(b0) * w1 * 0.6, sin(b0) * w1)]
				st.add_vertex(q[0]); st.add_vertex(q[1]); st.add_vertex(q[2])
				st.add_vertex(q[0]); st.add_vertex(q[2]); st.add_vertex(q[3])
	st.generate_normals()
	return st.commit()

## One cordless drill: housing, grip, battery with charge LEDs, chuck and spinning bit.
func _build_drill(parent: Node3D, mirror: float) -> void:
	var shell := _mat(hero.get("sash", hero.secondary), 0.25, 0.35)
	shell.clearcoat_enabled = true
	shell.clearcoat = 0.8
	var rubber := _mat(Color(0.06, 0.06, 0.07), 0.0, 0.85)
	var steel := _metal(Color("d1d5db"), 0.18)
	var d := Node3D.new()
	parent.add_child(d)
	# Motor housing along +Y (forward out of the fist), grip down through the fist.
	_part(d, _cyl(0.045, 0.05, 0.2, 20), Vector3(0, 0.06, 0), shell)
	_part(d, _sphere(0.05, 16), Vector3(0, -0.04, 0), shell, Vector3.ZERO, Vector3(1, 0.7, 1))
	_part(d, _cyl(0.05, 0.05, 0.03, 20), Vector3(0, -0.02, 0), rubber)
	for k in range(5):
		_part(d, _box(0.004, 0.05, 0.02), Vector3(0.045 * mirror, 0.03 + k * 0.0, -0.02 + k * 0.01), rubber, Vector3(0, 0, 0))
	var grip := _part(d, _box(0.045, 0.16, 0.06), Vector3(0, -0.05, -0.08), rubber, Vector3(-100, 0, 0))
	grip.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	_part(d, _box(0.02, 0.035, 0.025), Vector3(0, 0.0, -0.045), _mat(Color("ef4444"), 0.1, 0.4), Vector3(-100, 0, 0))
	# Battery pack under the grip with a green charge bar.
	_part(d, _box(0.075, 0.06, 0.1), Vector3(0, -0.07, -0.17), _mat(Color(0.1, 0.1, 0.11), 0.2, 0.5))
	for k in range(3):
		_part(d, _box(0.012, 0.008, 0.004), Vector3(-0.016 + k * 0.016, -0.05, -0.12), _glow(Color("4ade80"), 2.4))
	# Chuck and bit.
	_part(d, _cyl(0.026, 0.034, 0.06, 18), Vector3(0, 0.19, 0), steel)
	_part(d, _torus(0.026, 0.034), Vector3(0, 0.21, 0), _metal(Color(0.15, 0.15, 0.16), 0.3))
	var bit := Node3D.new()
	bit.position = Vector3(0, 0.22, 0)
	d.add_child(bit)
	_part(bit, _drill_bit(0.26, 0.022), Vector3.ZERO, steel)
	drill_bits.append(bit)
	var tip := Node3D.new()
	tip.position = Vector3(0, 0.27, 0)
	bit.add_child(tip)
	var sp := _particles(tip, Color("ffb347"), 18, 0.02, Vector3.UP, Vector3(0, -6.0, 0), Vector2(1.5, 3.5), 0.35, 0.012, 5.0)
	sp.local_coords = false
	sp.emitting = false
	drill_sparks.append(sp)

func _g_twin_drills() -> void:
	for side in ["left_hand", "right_hand"]:
		var h := _attach(side, Vector3(0, 0, 0.02))
		var holder := Node3D.new()
		# Along the forearm: the drill continues the punch line past the fist.
		holder.basis = _basis_along(_bone_dir(side.replace("hand", "forearm"))).scaled(Vector3.ONE * 1.35)
		h.add_child(holder)
		_build_drill(holder, -1.0 if side == "left_hand" else 1.0)

## A feather: tapered blade, darker quill line.
func _feather(parent: Node3D, length: float, width: float, pos: Vector3, rot: Vector3, mat: Material) -> MeshInstance3D:
	return _part(parent, _blade(length, width, 0.012, 0.02), pos, mat, rot)

## Shqiponja: the black double-headed eagle he rides while his special lasts.
func _g_double_eagle() -> void:
	var root := Node3D.new()
	root.name = "Shqiponja"
	add_child(root)
	var body_n := Node3D.new()
	body_n.position = Vector3(0, -0.12, 0)
	root.add_child(body_n)
	var plume := _mat(Color.WHITE, 0.15, 0.45)
	plume.albedo_texture = _noise("plume", 0.05, false, 0.0, [Color(0.02, 0.02, 0.025), Color(0.11, 0.1, 0.12)])
	plume.normal_enabled = true
	plume.normal_texture = _noise("plume_n", 0.12, true, 6.0)
	plume.normal_scale = 0.8
	plume.rim = 0.7
	plume.rim_tint = 0.2
	plume.cull_mode = BaseMaterial3D.CULL_DISABLED
	var red_edge := _mat(Color("7f1d1d"), 0.1, 0.5)
	red_edge.cull_mode = BaseMaterial3D.CULL_DISABLED
	var beak_m := _metal(hero.accent, 0.3)
	var eye_m := _glow(Color("ff3b30"), 4.0)
	# Body: broad chest, layered breast feathers, tail fan behind (+Z = flying direction).
	_part(body_n, _sphere(0.34, 24), Vector3.ZERO, plume, Vector3.ZERO, Vector3(1.0, 0.62, 1.55))
	for k in range(9):
		var a := lerpf(-0.9, 0.9, k / 8.0)
		_feather(body_n, 0.2, 0.08, Vector3(sin(a) * 0.22, -0.12, 0.25 - absf(a) * 0.1), Vector3(-160, rad_to_deg(a), 0), plume)
	for k in range(7):
		var a := lerpf(-38.0, 38.0, k / 6.0)
		var tf := _feather(body_n, 0.62 - absf(a) * 0.004, 0.13, Vector3(0, 0.0, -0.45), Vector3(-92, a, 0), plume)
		tf.scale = Vector3(1, 1, 1)
		_feather(body_n, 0.12, 0.13, Vector3(sin(deg_to_rad(a)) * 0.6, 0.0, -0.45 - cos(deg_to_rad(a)) * 0.56), Vector3(-92, a, 0), red_edge)
	# Two necks and heads, looking left and right of the flight direction.
	for s in [-1.0, 1.0]:
		var neck := Node3D.new()
		neck.position = Vector3(0.1 * s, 0.1, 0.42)
		neck.rotation_degrees = Vector3(-12, s * 38, 0)
		body_n.add_child(neck)
		_part(neck, _cyl(0.07, 0.1, 0.32, 16), Vector3(0, 0.0, 0.14), plume, Vector3(80, 0, 0))
		for k in range(4):
			_feather(neck, 0.12, 0.06, Vector3(0.05 * s, 0.03, 0.06 + k * 0.06), Vector3(-150, s * 30, 0), plume)
		var head := Node3D.new()
		head.position = Vector3(0, 0.05, 0.32)
		neck.add_child(head)
		_part(head, _sphere(0.1, 20), Vector3.ZERO, plume, Vector3.ZERO, Vector3(0.9, 0.9, 1.15))
		# Hooked beak: upper part curving down, small lower part.
		var upper := _part(head, _cyl(0.0, 0.045, 0.16, 12), Vector3(0, 0.0, 0.13), beak_m, Vector3(100, 0, 0))
		upper.scale = Vector3(1, 1, 0.8)
		_part(head, _cyl(0.0, 0.02, 0.06, 10), Vector3(0, -0.035, 0.2), beak_m, Vector3(160, 0, 0))
		_part(head, _cyl(0.0, 0.03, 0.08, 10), Vector3(0, -0.03, 0.1), beak_m.duplicate(), Vector3(95, 0, 0))
		for e in [-1.0, 1.0]:
			_part(head, _sphere(0.018, 10), Vector3(0.06 * e, 0.025, 0.06), eye_m)
		# Red tongue, as on the flag.
		_part(head, _blade(0.08, 0.02, 0.006), Vector3(0, -0.045, 0.16), _mat(Color("dc2626"), 0.0, 0.5), Vector3(80, 0, 0))
		# A little crest of feathers.
		for k in range(3):
			_feather(head, 0.1, 0.035, Vector3(0, 0.07, -0.04 - k * 0.03), Vector3(-130 - k * 10, 0, 0), plume)
	# Wings: shoulder pivot (flaps), forearm, a fan of long primaries, rows of coverts.
	for s in [-1.0, 1.0]:
		var shoulder := Node3D.new()
		shoulder.position = Vector3(0.24 * s, 0.08, 0.1)
		body_n.add_child(shoulder)
		eagle_wings.append([shoulder, s])
		var arm := Node3D.new()
		arm.rotation_degrees = Vector3(0, 0, 0)
		shoulder.add_child(arm)
		_part(arm, _cyl(0.06, 0.09, 0.8, 12), Vector3(0.4 * s, 0, 0), plume, Vector3(0, 0, 90))
		var hand := Node3D.new()
		hand.position = Vector3(0.78 * s, 0, 0)
		arm.add_child(hand)
		eagle_wings.append([hand, s * 0.5])
		_part(hand, _cyl(0.04, 0.06, 0.6, 10), Vector3(0.3 * s, 0, 0), plume, Vector3(0, 0, 90))
		# Primaries spread at the tip, like fingers.
		for k in range(8):
			var a: float = lerpf(-8.0, 62.0, k / 7.0)
			var ln: float = 0.72 + 0.12 * sin(k / 7.0 * PI)
			var fp := Node3D.new()
			fp.position = Vector3((0.5 + k * 0.02) * s, 0, -0.02 * k)
			fp.rotation_degrees = Vector3(0, s * (90.0 + a), 0)
			hand.add_child(fp)
			_feather(fp, ln, 0.11, Vector3.ZERO, Vector3(90, 0, 0), plume)
			_feather(fp, 0.14, 0.11, Vector3(0, 0, ln - 0.1), Vector3(90, 0, 0), red_edge)
		# Secondaries along the arm (trailing edge, pointing back).
		for k in range(9):
			var x: float = (0.1 + k * 0.13) * s
			var parent: Node3D = arm if absf(x) < 0.78 else hand
			var px: float = x if parent == arm else x - 0.78 * s
			_feather(parent, 0.5 - k * 0.012, 0.12, Vector3(px, -0.01, -0.02), Vector3(-90, 0, s * 4.0), plume)
		# Coverts: short feathers over the leading edge.
		for k in range(10):
			_feather(arm if k < 6 else hand, 0.2, 0.09, Vector3(((0.05 + (k % 6) * 0.13)) * s, 0.03, 0.02), Vector3(-80, 0, 0), plume)
	# Legs with golden talons, tucked back under the body.
	for s in [-1.0, 1.0]:
		var leg := Node3D.new()
		leg.position = Vector3(0.1 * s, -0.18, -0.05)
		leg.rotation_degrees = Vector3(-50, 0, 0)
		body_n.add_child(leg)
		_part(leg, _cyl(0.03, 0.04, 0.22, 10), Vector3(0, -0.1, 0), _mat(Color("caa15a"), 0.2, 0.5))
		for k in range(3):
			var claw := _part(leg, _cyl(0.0, 0.012, 0.09, 8), Vector3((k - 1) * 0.025, -0.22, 0.03), beak_m, Vector3(60, 0, (k - 1) * 20))
			claw.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	# Feathers it sheds while flying.
	var fall := _particles(body_n, Color(0.12, 0.02, 0.02), 8, 0.6, Vector3.DOWN, Vector3(0, -1.0, 0), Vector2(0.2, 0.6), 1.6, 0.03, 0.6)
	fall.local_coords = false
	particles["eagle_feathers"] = fall
	root.scale = Vector3.ONE * 0.01
	root.visible = false
	react["eagle"] = root

# ───────────────────────────────────────────────────── bone helpers ──

## Direction from a bone to its child in model space (rest pose), e.g. along the forearm.
func _bone_dir(key: String) -> Vector3:
	var sk: Skeleton3D = view.skeleton
	var idx := _bone_idx(key)
	if sk == null or idx == -1: return Vector3.RIGHT if key.begins_with("left") else Vector3.LEFT
	var rest: Transform3D = sk.get_bone_global_rest(idx)
	for c in range(sk.get_bone_count()):
		if sk.get_bone_parent(c) == idx:
			var d: Vector3 = _chain_basis() * (sk.get_bone_global_rest(c).origin - rest.origin)
			if d.length() > 0.0001: return d.normalized()
	return Vector3.RIGHT if key.begins_with("left") else Vector3.LEFT

## A basis whose +Y points along dir.
func _basis_along(dir: Vector3) -> Basis:
	var y := dir.normalized()
	var ref := Vector3.FORWARD if absf(y.dot(Vector3.FORWARD)) < 0.9 else Vector3.UP
	var x := y.cross(ref).normalized()
	var z := x.cross(y).normalized()
	return Basis(x, y, z)

# ──────────────────────────────────────────────── concept-art trio ──

## Kalyx body: the base model has pale cool skin and red cloth. Split by hue instead of
## brightness, so the skin turns slate blue, the cloth turns suede/leather and the metal gold.
const KALYX_BODY_SHADER := """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx, cull_disabled;
uniform sampler2D albedo_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool has_tex = true;
uniform vec4 base_color : source_color = vec4(1.0);
uniform vec3 primary : source_color = vec3(0.6, 0.4, 0.25);
uniform vec3 secondary : source_color = vec3(0.3, 0.18, 0.1);
uniform vec3 accent : source_color = vec3(0.85, 0.66, 0.23);
uniform float recolor : hint_range(0.0, 1.0) = 1.0;
uniform vec3 skin_tint : source_color = vec3(0.38, 0.45, 0.62);
uniform sampler2D normal_tex : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool has_normal = false;
uniform float roughness_v : hint_range(0.0, 1.0) = 0.75;
uniform vec3 rim_color : source_color = vec3(0.5, 0.8, 1.0);
uniform float rim_strength = 0.55;
uniform float rim_power = 3.0;
uniform float flash = 0.0;
uniform float charge = 0.0;

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void fragment() {
	vec4 tex = has_tex ? texture(albedo_tex, UV) : vec4(1.0);
	vec3 src = tex.rgb * base_color.rgb;
	vec3 hsv = rgb2hsv(src);
	float lum = dot(src, vec3(0.299, 0.587, 0.114));
	float cool = smoothstep(0.28, 0.38, hsv.x) * (1.0 - smoothstep(0.76, 0.84, hsv.x));
	float grey = 1.0 - smoothstep(0.07, 0.15, hsv.y);
	float skin = max(cool, grey * smoothstep(0.45, 0.6, hsv.z)) * smoothstep(0.03, 0.09, hsv.z);
	float gold = smoothstep(0.06, 0.09, hsv.x) * (1.0 - smoothstep(0.17, 0.21, hsv.x)) * smoothstep(0.28, 0.4, hsv.y) * smoothstep(0.42, 0.58, hsv.z) * (1.0 - skin);
	vec3 leather = mix(secondary, primary, smoothstep(0.14, 0.32, hsv.z)) * (0.45 + hsv.z * 1.6);
	vec3 col = mix(leather, accent * (0.5 + lum * 0.75), gold);
	col = mix(col, skin_tint * (0.42 + lum * 0.95), skin);
	ALBEDO = mix(src, col, recolor);
	ROUGHNESS = mix(mix(roughness_v, 0.28, gold), 0.5, skin);
	METALLIC = gold * 0.85;
	if (has_normal) {
		NORMAL_MAP = texture(normal_tex, UV).rgb;
	}
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power + 1.0);
	SPECULAR = 0.45;
	EMISSION = rim_color * fres * (rim_strength * 0.6 + charge * 0.9) + vec3(1.0, 0.95, 0.9) * flash * 0.8;
}
"""
static var _kalyx_body: Shader = null

func _g_kalyx_skin() -> void:
	if _kalyx_body == null:
		_kalyx_body = Shader.new()
		_kalyx_body.code = KALYX_BODY_SHADER
	for bm in body_mats:
		var keep := {}
		for u in (bm as ShaderMaterial).shader.get_shader_uniform_list():
			keep[u.name] = bm.get_shader_parameter(u.name)
		bm.shader = _kalyx_body
		for k in keep: bm.set_shader_parameter(k, keep[k])
		bm.set_shader_parameter("recolor", 1.0)

const KALYX_FROST := Color("7dd3fc")
const KALYX_GLUT := Color("ff5a1f")
const KALYX_EMBER := Color("ffb347")   # rear spikes while the crown burns
var crown_mats: Array = []       # Kalyx: crystal materials that take the mode color
var crown_rear_mats: Array = []  # rear spikes: ember in frost mode, white-hot in ember mode
var crown_mode := "frost"

## Curved crystal shard for the crown: faceted five-sided section, thickest just above the
## root, tapering to a point, the upper half sweeping back (-Z) like a flame tongue.
func _kalyx_shard(length: float, radius: float, sweep: float, seed_v: int) -> ArrayMesh:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_v
	var sides := 5
	var jitter: Array = []
	for k in range(sides): jitter.append(rng.randf_range(0.8, 1.15))
	var n := 7
	var rows: Array = []
	for i in range(n + 1):
		var f := float(i) / n
		var r: float = radius * (0.8 + 0.5 * f) * pow(1.0 - f, 0.85)
		var c := Vector3(0, f * length, -sweep * length * f * f)
		var row: Array = []
		for k in range(sides):
			var a := TAU * k / sides + f * 0.5
			row.append(c + Vector3(cos(a) * r * jitter[k], 0, sin(a) * r * jitter[k] * 0.75))
		rows.append(row)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(n):
		var c0 := Color(1, 1, 1).darkened(0.45 * (1.0 - float(i) / n))
		var c1 := Color(1, 1, 1).darkened(0.45 * (1.0 - float(i + 1) / n))
		for k in range(sides):
			var k2 := (k + 1) % sides
			var a: Vector3 = rows[i][k]
			var b: Vector3 = rows[i][k2]
			var c: Vector3 = rows[i + 1][k2]
			var d: Vector3 = rows[i + 1][k]
			st.set_color(c0); st.add_vertex(a)
			st.set_color(c1); st.add_vertex(c)
			st.set_color(c0); st.add_vertex(b)
			st.set_color(c0); st.add_vertex(a)
			st.set_color(c1); st.add_vertex(d)
			st.set_color(c1); st.add_vertex(c)
	st.generate_normals()
	return st.commit()

## Kalyx: a crown of crystal flames grows from the bald skull. Big centre spikes, smaller ones
## to the sides, all sweeping back. Front spikes take the mode color (frost blue / ember red),
## the rear spikes glow ember like the back of the concept art.
func _g_crystal_crown() -> void:
	var head := _attach("head", Vector3(0, 0.15, -0.025))
	var front_m := _crystal(KALYX_FROST)
	front_m.vertex_color_use_as_albedo = true
	var rear_m := _crystal(KALYX_GLUT)
	rear_m.vertex_color_use_as_albedo = true
	var core_f := _glow(KALYX_FROST, 2.2, true)
	var core_r := _glow(KALYX_GLUT, 2.2, true)
	crown_mats = [front_m, core_f]
	crown_rear_mats = [rear_m, core_r]
	# x, z, length, tilt back, tilt out, radius, sweep, rear
	var spikes := [
		[0.0, 0.035, 0.27, 14.0, 0.0, 0.07, 0.5, false],
		[0.0, -0.01, 0.35, 28.0, 0.0, 0.074, 0.55, false],
		[0.045, 0.015, 0.23, 16.0, 16.0, 0.058, 0.5, false],
		[-0.045, 0.015, 0.225, 16.0, 17.0, 0.058, 0.5, false],
		[0.0, -0.055, 0.32, 52.0, 0.0, 0.066, 0.6, true],
		[0.042, -0.06, 0.24, 58.0, 14.0, 0.054, 0.55, true],
		[-0.042, -0.06, 0.235, 58.0, 15.0, 0.054, 0.55, true],
	]
	for k in range(spikes.size()):
		var sp: Array = spikes[k]
		var x: float = sp[0]
		var rear: bool = sp[7]
		var mesh := _kalyx_shard(float(sp[2]), float(sp[5]), float(sp[6]), 31 + k * 7)
		var rot := Vector3(-float(sp[3]), 0.0, -float(sp[4]) * signf(x))
		var pos := Vector3(x, -0.035, float(sp[1]))
		_part(head, mesh, pos, rear_m if rear else front_m, rot)
		# Inner light: a thin glowing core inside each shard.
		_part(head, mesh, pos + Vector3(0, 0.01, 0), core_r if rear else core_f, rot, Vector3(0.38, 0.85, 0.38))
	# Temple nodes: crystal breaks out of the skull above the ears and flares back.
	for sx in [-1.0, 1.0]:
		var node := Node3D.new()
		node.position = Vector3(0.063 * sx, -0.04, 0.03)
		node.rotation_degrees = Vector3(0, 0, -8.0 * sx)
		head.add_child(node)
		_part(node, _sphere(0.043, 7), Vector3.ZERO, front_m, Vector3(0, 0, 0), Vector3(0.42, 0.85, 1.0))
		var fl := [[0.15, 62.0, 30.0, 0.034], [0.11, 80.0, 40.0, 0.028], [0.08, 45.0, 22.0, 0.024]]
		for j in range(fl.size()):
			var f: Array = fl[j]
			var m2 := _kalyx_shard(float(f[0]), float(f[3]), 0.5, 101 + j * 13 + int(sx))
			var r2 := Vector3(-float(f[1]), 0, -float(f[2]) * sx)
			_part(node, m2, Vector3(0.004 * sx, 0.01 - j * 0.012, -0.005), front_m, r2)
			_part(node, m2, Vector3(0.004 * sx, 0.015 - j * 0.012, -0.005), core_f, r2, Vector3(0.38, 0.85, 0.38))
	# Glowing eyes.
	var eye := _glow(Color("bfefff"), 2.4)
	for s in [-1.0, 1.0]:
		_part(head, _sphere(0.0105, 10), Vector3(0.031 * s, -0.068, 0.122), eye, Vector3.ZERO, Vector3(1.25, 0.7, 0.5))
	var p := _particles(head, KALYX_FROST, 8, 0.1, Vector3.UP, Vector3(0, 0.35, -0.15), Vector2(0.15, 0.4), 0.9, 0.009, 3.0)
	p.position = Vector3(0, 0.16, -0.06)
	particles["crown"] = p

func _kalyx_crown(mode: String) -> void:
	if mode == crown_mode or crown_mats.is_empty(): return
	crown_mode = mode
	var col: Color = KALYX_GLUT if mode == "glut" else KALYX_FROST
	var rear_col: Color = KALYX_EMBER if mode == "glut" else KALYX_GLUT
	for pair in [[crown_mats, col], [crown_rear_mats, rear_col]]:
		var c: Color = pair[1]
		for m in pair[0]:
			m.albedo_color = Color(c.r, c.g, c.b, m.albedo_color.a)
			if m.emission_enabled: m.emission = c
	if particles.has("crown") and particles.crown is CPUParticles3D:
		var pm = (particles.crown as CPUParticles3D).mesh.material
		if pm is StandardMaterial3D:
			pm.albedo_color = col
			pm.emission = col

## Triangle pattern for Kalyx's gold arm rings (white triangles on grey, used as albedo).
static func _kalyx_tri_tex() -> Texture2D:
	if _tex.has("kalyx_tri"): return _tex["kalyx_tri"]
	var w := 128
	var h := 32
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in range(h):
		for x in range(w):
			var u := fmod(float(x) / 16.0, 1.0)
			var v := float(y) / h
			var band := v < 0.14 or v > 0.86
			var tri := absf(u - 0.5) * 2.0 < (v - 0.18) / 0.64 and v > 0.18 and v < 0.82
			var c := 1.0 if band or tri else 0.62
			img.set_pixel(x, y, Color(c, c, c))
	var tx := ImageTexture.create_from_image(img)
	_tex["kalyx_tri"] = tx
	return tx

func _kalyx_gold() -> StandardMaterial3D:
	return _metal(hero.accent, 0.24)

## Kalyx: three gold chains around the neck, the longest with a pointed gold pendant.
func _g_gold_chains() -> void:
	var chest := _attach("chest", Vector3(0, 0.2, 0.0))
	var gold := _kalyx_gold()
	# radius x, radius z, drop at the front, tube
	var chains := [[0.085, 0.075, 0.025, 0.006], [0.098, 0.085, 0.055, 0.0055], [0.11, 0.094, 0.085, 0.0065]]
	for k in range(chains.size()):
		var ch: Array = chains[k]
		var holder := Node3D.new()
		holder.position = Vector3(0, -float(ch[2]) * 0.5, 0.01)
		holder.rotation_degrees = Vector3(rad_to_deg(atan2(float(ch[2]), float(ch[1]) * 2.0)) + 8.0, 0, 0)
		chest.add_child(holder)
		var ring := _part(holder, _torus(1.0 - float(ch[3]) / float(ch[0]) * 2.0, 1.0, 48), Vector3.ZERO, gold)
		ring.scale = Vector3(float(ch[0]), float(ch[0]), float(ch[1]))
		if k == chains.size() - 1:
			var pend := Node3D.new()
			pend.position = Vector3(0, 0, float(ch[1]))
			pend.rotation_degrees = Vector3(-holder.rotation_degrees.x, 0, 0)
			holder.add_child(pend)
			_part(pend, _torus(0.006, 0.011, 16), Vector3(0, -0.004, 0.004), gold, Vector3(0, 0, 90))
			_part(pend, _blade(0.11, 0.044, 0.014), Vector3(0, -0.012, 0.008), gold, Vector3(0, 0, 180))
			_part(pend, _crystal_mesh(0.022, 0.006), Vector3(0, -0.032, 0.014), crown_mats[0] if not crown_mats.is_empty() else _crystal(KALYX_FROST))

## Kalyx: leather baldric from the left shoulder to the right hip with a round gold crest.
func _g_bandolier() -> void:
	var chest := _attach("chest", Vector3.ZERO)
	var leather := _mat(hero.secondary.darkened(0.1), 0.0, 0.75)
	var stitch := _mat(hero.secondary.lightened(0.25), 0.0, 0.8)
	var front := [Vector3(0.12, 0.215, -0.01), Vector3(0.105, 0.19, 0.075), Vector3(0.06, 0.1, 0.125), Vector3(0.0, 0.0, 0.135), Vector3(-0.07, -0.1, 0.13), Vector3(-0.13, -0.2, 0.105)]
	var back := [Vector3(0.12, 0.215, -0.01), Vector3(0.1, 0.17, -0.1), Vector3(0.04, 0.06, -0.125), Vector3(-0.04, -0.06, -0.125), Vector3(-0.13, -0.2, -0.09)]
	for path in [front, back]:
		for k in range(path.size() - 1):
			var a: Vector3 = path[k]
			var b: Vector3 = path[k + 1]
			var seg := _part(chest, _box(0.048, 1.0, 0.012), Vector3.ZERO, leather)
			_align(seg, a, b + (b - a).normalized() * 0.006)
			for e in [-1.0, 1.0]:
				var st := _part(chest, _box(0.004, 1.0, 0.004), Vector3.ZERO, stitch)
				var off: Vector3 = (b - a).cross(Vector3(0, 0, 1)).normalized() * 0.019 * e + Vector3(0, 0, 0.007 if path == front else -0.007)
				_align(st, a + off, b + off)
	# Gold crest on the shoulder strap.
	var crest := Node3D.new()
	crest.position = Vector3(0.105, 0.185, 0.085)
	crest.basis = _basis_along(Vector3(0.1, 0.45, 1.0))
	chest.add_child(crest)
	var gold := _kalyx_gold()
	_part(crest, _cyl(0.034, 0.036, 0.012, 24), Vector3.ZERO, gold)
	_part(crest, _torus(0.026, 0.033, 24), Vector3(0, 0.007, 0), gold)
	_part(crest, _crystal_mesh(0.03, 0.009), Vector3(0, 0.01, 0), crown_mats[0] if not crown_mats.is_empty() else _crystal(KALYX_FROST), Vector3(90, 0, 0))

## Kalyx: gold arm rings with a triangle band on the upper arms, leather bracers with gold
## rings on the forearms.
func _g_gold_bracers() -> void:
	var gold := _kalyx_gold()
	var tri := _metal(hero.accent, 0.3)
	tri.albedo_texture = _kalyx_tri_tex()
	tri.uv1_scale = Vector3(2, 1, 1)
	var leather := _mat(hero.secondary, 0.0, 0.8)
	for side in ["left_forearm", "right_forearm"]:
		var fa := _attach(side, Vector3.ZERO)
		var hold := Node3D.new()
		hold.basis = _basis_along(_bone_dir(side))
		fa.add_child(hold)
		_part(hold, _cyl(0.05, 0.057, 0.15, 18), Vector3(0, 0.15, 0), leather)
		for y in [0.085, 0.215]: _part(hold, _torus(0.054, 0.064, 32), Vector3(0, y, 0), gold, Vector3.ZERO, Vector3(1, 1.4, 1))
	for side in ["left_arm", "right_arm"]:
		var ua := _attach(side, Vector3.ZERO)
		var hold2 := Node3D.new()
		hold2.basis = _basis_along(_bone_dir(side))
		ua.add_child(hold2)
		_part(hold2, _cyl(0.058, 0.058, 0.035, 24), Vector3(0, 0.17, 0), tri)
		for y in [0.15, 0.19]: _part(hold2, _torus(0.056, 0.063, 32), Vector3(0, y, 0), gold)

## Kalyx: wide gold belt buckle with a crystal crest and leather side pouches.
func _g_kalyx_belt() -> void:
	var hips := _attach("hips", Vector3(0, -0.03, 0.0))
	var gold := _kalyx_gold()
	var buckle := Node3D.new()
	buckle.position = Vector3(0, 0.0, 0.12)
	hips.add_child(buckle)
	_part(buckle, _cyl(0.05, 0.052, 0.014, 6), Vector3.ZERO, gold, Vector3(90, 0, 0))
	_part(buckle, _torus(0.038, 0.046, 6), Vector3(0, 0, 0.008), gold, Vector3(90, 0, 0))
	_part(buckle, _crystal_mesh(0.045, 0.012), Vector3(0, 0, 0.012), crown_mats[0] if not crown_mats.is_empty() else _crystal(KALYX_FROST))
	var leather := _mat(hero.secondary.darkened(0.05), 0.0, 0.8)
	for s in [-1.0, 1.0]:
		var pouch := Node3D.new()
		pouch.position = Vector3(0.15 * s, -0.05, 0.0)
		pouch.rotation_degrees = Vector3(0, 30 * s, 0)
		hips.add_child(pouch)
		_part(pouch, _box(0.075, 0.09, 0.04), Vector3.ZERO, leather)
		_part(pouch, _box(0.08, 0.04, 0.045), Vector3(0, 0.03, 0.002), _mat(hero.secondary.darkened(0.25), 0.0, 0.8))
		_part(pouch, _sphere(0.008, 8), Vector3(0, 0.016, 0.026), gold)
	var back := Node3D.new()
	back.position = Vector3(0, -0.04, -0.115)
	hips.add_child(back)
	_part(back, _box(0.12, 0.08, 0.045), Vector3.ZERO, leather)
	_part(back, _box(0.125, 0.035, 0.05), Vector3(0, 0.028, 0), _mat(hero.secondary.darkened(0.25), 0.0, 0.8))

## Vorruk: grown skin plates like rock strata. All plates of one bone are merged into a single
## mesh (one draw call). Vertex colors darken the roots hidden under the plate above and
## light the cut edges, so every layer reads on its own.
var _vr_mats: Dictionary = {}

## Plates use the body's own recolor material (same color and skin texture, sampled from a
## wrinkled skin patch of the atlas); a multiply pass with the vertex colors shades the layers.
func _vr_mat(kind: String) -> Material:
	if _vr_mats.has(kind): return _vr_mats[kind]
	var m: Material
	if kind == "claw":
		var c := StandardMaterial3D.new()
		c.vertex_color_use_as_albedo = true
		c.roughness = 0.38
		c.metallic = 0.0
		c.metallic_specular = 0.35
		c.clearcoat_enabled = true
		c.clearcoat = 0.35
		c.clearcoat_roughness = 0.3
		c.rim_enabled = true
		c.rim = 0.15
		m = c
	elif not body_mats.is_empty():
		var sm: ShaderMaterial = body_mats[0].duplicate()
		if kind == "belly":
			sm.set_shader_parameter("primary", hero.accent)
			sm.set_shader_parameter("secondary", Color("a8865c"))
			sm.set_shader_parameter("recolor", 1.0)
		var ao := StandardMaterial3D.new()
		ao.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ao.vertex_color_use_as_albedo = true
		ao.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ao.blend_mode = BaseMaterial3D.BLEND_MODE_MUL
		sm.next_pass = ao
		body_mats.append(sm)
		m = sm
	else:
		var c := _mat(hero.accent if kind == "belly" else hero.skin, 0.0, 0.85)
		c.vertex_color_use_as_albedo = true
		m = c
	_vr_mats[kind] = m
	return m

## Frame for a plate: root at pos, hanging along hang, outer face toward out.
func _vr_xf(pos: Vector3, hang: Vector3, out: Vector3) -> Transform3D:
	var y := -hang.normalized()
	var z := (out - y * out.dot(y)).normalized()
	return Transform3D(Basis(y.cross(z), y, z), pos)

## One thick curved shingle: root edge at the origin, hangs along -Y, bulges to +Z,
## the sides wrap back to the body, the lip flares out and waves.
func _vr_lobe(st: SurfaceTool, xf: Transform3D, w: float, l: float, thick: float, wrap: float = 0.35, flare: float = 0.2, wave: float = 0.08, phase: float = 0.0) -> void:
	var nu := 8
	var nv := 4
	var outer: Array = []
	var inner: Array = []
	for i in range(nu + 1):
		var u := -1.0 + 2.0 * i / nu
		var lu := l * (1.0 - 0.32 * pow(u, 4)) * (1.0 + wave * sin(u * PI * 1.5 + phase))
		var co: Array = []
		var ci: Array = []
		for j in range(nv + 1):
			var v := float(j) / nv
			var hw := w * 0.5 * (1.0 - 0.1 * v)
			var p := Vector3(u * hw, -v * lu, -wrap * u * u * hw + flare * v * v * lu)
			var th := thick * (0.6 + 0.4 * (1.0 - u * u)) * (0.25 + 0.75 * smoothstep(0.0, 0.6, v))
			ci.append(p)
			co.append(p + Vector3(2.0 * wrap * u, 0.0, 1.0).normalized() * th)
		outer.append(co)
		inner.append(ci)
	var c_root := Color(0.42, 0.38, 0.36)
	var c_lip := Color(1.0, 1.0, 1.0)
	var c_edge := Color(0.9, 0.88, 0.85)
	var c_in := Color(0.32, 0.3, 0.3)
	var put := func(p: Vector3, c: Color) -> void:
		st.set_color(c)
		st.set_uv(Vector2(0.13 + clampf(p.x / w + 0.5, 0.0, 1.0) * 0.14, 0.38 + clampf(-p.y / l, 0.0, 1.2) * 0.2))
		st.add_vertex(xf * p)
	for i in range(nu):
		for j in range(nv):
			var ca := c_root.lerp(c_lip, float(j) / nv)
			var cb := c_root.lerp(c_lip, float(j + 1) / nv)
			var a: Vector3 = outer[i][j]; var b: Vector3 = outer[i + 1][j]
			var c: Vector3 = outer[i + 1][j + 1]; var d: Vector3 = outer[i][j + 1]
			put.call(a, ca); put.call(b, ca); put.call(c, cb)
			put.call(a, ca); put.call(c, cb); put.call(d, cb)
			a = inner[i][j]; b = inner[i + 1][j]; c = inner[i + 1][j + 1]; d = inner[i][j + 1]
			put.call(a, c_in); put.call(c, c_in); put.call(b, c_in)
			put.call(a, c_in); put.call(d, c_in); put.call(c, c_in)
		# Lip (bottom) and root (top) edges.
		var o0: Vector3 = outer[i][nv]; var o1: Vector3 = outer[i + 1][nv]
		var i0: Vector3 = inner[i][nv]; var i1: Vector3 = inner[i + 1][nv]
		put.call(o0, c_edge); put.call(i1, c_edge); put.call(i0, c_edge)
		put.call(o0, c_edge); put.call(o1, c_edge); put.call(i1, c_edge)
		o0 = outer[i][0]; o1 = outer[i + 1][0]; i0 = inner[i][0]; i1 = inner[i + 1][0]
		put.call(o0, c_root); put.call(i0, c_root); put.call(i1, c_root)
		put.call(o0, c_root); put.call(i1, c_root); put.call(o1, c_root)
	for j in range(nv):
		var ce := c_root.lerp(c_edge, smoothstep(0.0, 0.7, float(j) / nv))
		var ce2 := c_root.lerp(c_edge, smoothstep(0.0, 0.7, float(j + 1) / nv))
		var oa: Vector3 = outer[nu][j]; var ob: Vector3 = outer[nu][j + 1]
		var ia: Vector3 = inner[nu][j]; var ib: Vector3 = inner[nu][j + 1]
		put.call(oa, ce); put.call(ib, ce2); put.call(ob, ce2)
		put.call(oa, ce); put.call(ia, ce); put.call(ib, ce2)
		oa = outer[0][j]; ob = outer[0][j + 1]; ia = inner[0][j]; ib = inner[0][j + 1]
		put.call(oa, ce); put.call(ob, ce2); put.call(ib, ce2)
		put.call(oa, ce); put.call(ib, ce2); put.call(ia, ce)

## Plates on one bone. spec: [pos, hang, out, width, length, thick, wrap, flare, wave]
func _vr_plates(key: String, specs: Array, kind: String = "skin") -> void:
	var node := _attach(key)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for k in range(specs.size()):
		var s: Array = specs[k]
		_vr_lobe(st, _vr_xf(s[0], s[1], s[2]), s[3], s[4], s[5], s[6] if s.size() > 6 else 0.35,
			s[7] if s.size() > 7 else 0.2, s[8] if s.size() > 8 else 0.08, k * 1.7)
	st.index()
	st.generate_normals()
	st.generate_tangents()
	_part(node, st.commit(), Vector3.ZERO, _vr_mat(kind))

## Vorruk: overlapping skin plates over back, shoulders, chest and forearms, cream belly scutes.
func _g_flesh_plates() -> void:
	# Back, from the hump behind the head down to the waist, like roof tiles.
	_vr_plates("chest", [
		[Vector3(0, 0.40, -0.20), Vector3(0, -1, -0.5), Vector3(0, 0.4, -1), 0.40, 0.20, 0.05, 0.45],
		[Vector3(0, 0.28, -0.28), Vector3(0, -1, -0.3), Vector3(0, 0.2, -1), 0.56, 0.22, 0.055, 0.5],
		[Vector3(0, 0.14, -0.31), Vector3(0, -1, -0.15), Vector3(0, 0.1, -1), 0.6, 0.22, 0.055, 0.5],
		[Vector3(0, 0.00, -0.30), Vector3(0, -1, 0.0), Vector3(0, 0, -1), 0.56, 0.2, 0.05, 0.5],
		# Collar plates over the chest.
		[Vector3(0.15, 0.27, 0.2), Vector3(0.35, -1, 0.5), Vector3(0.2, 0.3, 1), 0.3, 0.17, 0.045, 0.4],
		[Vector3(-0.15, 0.27, 0.2), Vector3(-0.35, -1, 0.5), Vector3(-0.2, 0.3, 1), 0.3, 0.17, 0.045, 0.4],
	])
	_vr_plates("spine", [
		[Vector3(0, 0.12, -0.2), Vector3(0, -1, 0.1), Vector3(0, 0, -1), 0.5, 0.2, 0.05, 0.5],
		[Vector3(0, -0.02, -0.17), Vector3(0, -1, 0.15), Vector3(0, 0, -1), 0.44, 0.18, 0.045, 0.5],
	])
	_vr_plates("spine", [
		[Vector3(0, 0.2, 0.24), Vector3(0, -1, 0.1), Vector3(0, 0, 1), 0.34, 0.12, 0.014, 0.55, 0.05, 0.02],
		[Vector3(0, 0.1, 0.25), Vector3(0, -1, 0.1), Vector3(0, 0, 1), 0.33, 0.12, 0.014, 0.55, 0.05, 0.02],
		[Vector3(0, 0.0, 0.25), Vector3(0, -1, 0.05), Vector3(0, 0, 1), 0.31, 0.12, 0.014, 0.55, 0.05, 0.02],
		[Vector3(0, -0.1, 0.24), Vector3(0, -1, 0.0), Vector3(0, 0, 1), 0.29, 0.12, 0.014, 0.55, 0.05, 0.02],
	], "belly")
	for s in [1.0, -1.0]:
		var arm := "left_arm" if s > 0 else "right_arm"
		# Shoulder: three layers hugging the deltoid, running down the upper arm.
		_vr_plates(arm, [
			[Vector3(-0.02 * s, 0.1, -0.01), Vector3(s, -0.5, 0), Vector3(0.3 * s, 1, 0), 0.32, 0.17, 0.04, 0.9, 0.15],
			[Vector3(0.08 * s, 0.09, 0.0), Vector3(s, -0.4, 0), Vector3(0.2 * s, 1, 0), 0.3, 0.16, 0.04, 0.9, 0.15],
			[Vector3(0.17 * s, 0.08, 0.0), Vector3(s, -0.3, 0), Vector3(0.1 * s, 1, 0), 0.27, 0.15, 0.035, 0.9, 0.15],
		])

## Vorruk: legs and hips wrapped in hanging hide lappets (no trousers on a colossus).
func _g_hip_lappets() -> void:
	var ring: Array = []
	for k in range(7):
		var a := TAU * (k + 0.5) / 7.0
		var d := Vector3(sin(a), 0, cos(a))
		ring.append([Vector3(d.x * 0.28, 0.1, d.z * 0.22 + 0.02), Vector3(d.x * 0.2, -1, d.z * 0.2), d, 0.36, 0.27, 0.045, 0.5, 0.12, 0.04])
	_vr_plates("hips", ring)
	for s in [1.0, -1.0]:
		# Pillar legs: few broad plates, a knee cap and a heavy ring over the ankle.
		var thigh: Array = []
		for k in range(4):
			var a := TAU * (k + 0.5) / 4.0
			var d := Vector3(sin(a), 0, cos(a))
			thigh.append([Vector3(d.x * 0.15, -0.14, d.z * 0.17 + 0.02), Vector3(d.x * 0.12, -1, d.z * 0.12), d, 0.3, 0.3, 0.045, 0.6, 0.12, 0.03])
		_vr_plates("left_leg" if s > 0 else "right_leg", thigh)
		var shin: Array = [[Vector3(0, 0.1, 0.13), Vector3(0, -1, 0.3), Vector3(0, 0.2, 1), 0.22, 0.17, 0.05, 0.6, 0.2, 0.03]]
		for k in range(5):
			var a := TAU * k / 5.0
			var d := Vector3(sin(a), 0, cos(a))
			shin.append([Vector3(d.x * 0.15, -0.12, d.z * 0.14 + 0.01), Vector3(d.x * 0.15, -1, d.z * 0.15), d, 0.24, 0.24, 0.045, 0.6, 0.15, 0.03])
		_vr_plates("left_shin" if s > 0 else "right_shin", shin)

## Curved claw along +Y, bending toward +X, thin sideways (Z). Root lighter, tip near black.
func _vr_claw_mesh(length: float, r: float, arc_deg: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := 8
	var sides := 7
	var arc := deg_to_rad(arc_deg)
	var rad := length / arc
	var rings: Array = []
	var cols: Array = []
	for k in range(n + 1):
		var f := float(k) / n
		var th := f * arc
		var c := Vector3(rad * (1.0 - cos(th)), rad * sin(th), 0)
		var a1 := Vector3(cos(th), -sin(th), 0)
		var rf := r * pow(1.0 - f, 0.8) + 0.0015
		var ring: Array = []
		for m in range(sides):
			var ph := TAU * m / sides
			ring.append(c + a1 * cos(ph) * rf * 1.3 + Vector3(0, 0, 1) * sin(ph) * rf * 0.75)
		rings.append(ring)
		cols.append(Color(0.3, 0.22, 0.16).lerp(Color(0.045, 0.035, 0.03), smoothstep(0.0, 0.5, f)))
	var tip := Vector3(rad * (1.0 - cos(arc)), rad * sin(arc), 0)
	for k in range(n):
		for m in range(sides):
			var m2 := (m + 1) % sides
			for v in [[k, m], [k, m2], [k + 1, m2], [k, m], [k + 1, m2], [k + 1, m]]:
				st.set_color(cols[v[0]])
				st.add_vertex(rings[v[0]][v[1]])
	for m in range(sides):
		var m2 := (m + 1) % sides
		st.set_color(cols[n]); st.add_vertex(rings[n][m]); st.add_vertex(rings[n][m2]); st.add_vertex(tip)
		st.set_color(cols[0]); st.add_vertex(rings[0][m2]); st.add_vertex(rings[0][m]); st.add_vertex(Vector3.ZERO)
	st.index()
	st.generate_normals()
	return st.commit()

## Node on any skeleton bone by name suffix (finger tips), axes like _attach.
func _vr_attach_bone(suffix: String) -> Node3D:
	var sk: Skeleton3D = view.skeleton
	if sk == null: return null
	for b in range(sk.get_bone_count()):
		if sk.get_bone_name(b).to_lower().ends_with(suffix):
			var ba := BoneAttachment3D.new()
			ba.bone_name = sk.get_bone_name(b)
			sk.add_child(ba)
			var holder := Node3D.new()
			holder.basis = (_chain_basis() * sk.get_bone_global_rest(b).basis).inverse()
			ba.add_child(holder)
			var pivot := Node3D.new()
			pivot.set_meta("bone", b)
			holder.add_child(pivot)
			return pivot
	return null

## Claw basis: +Y along dir, bending (+X) toward curl.
func _vr_claw_basis(dir: Vector3, curl: Vector3) -> Basis:
	var y := dir.normalized()
	var x := (curl - y * curl.dot(y)).normalized()
	return Basis(x, y, x.cross(y))

## Vorruk: four long curved dark claws on each hand, sitting on the finger tips.
func _g_long_claws() -> void:
	var claw_m := _vr_mat("claw")
	var long_claw := _vr_claw_mesh(0.3, 0.042, 70.0)
	var thumb_claw := _vr_claw_mesh(0.2, 0.036, 60.0)
	var sk: Skeleton3D = view.skeleton
	var done_right := false
	if sk != null:
		# Right hand: two broad fingers carry two claws each, the thumb one.
		var fingers := [["righthandindex4", "righthandindex3", 2], ["righthandpinky4", "righthandpinky3", 2], ["righthandthumb4", "righthandthumb3", 1]]
		for f in fingers:
			var tipn := _vr_attach_bone(str(f[0]))
			var basen := _vr_attach_bone(str(f[1]))
			if tipn == null or basen == null: continue
			var dir: Vector3 = _chain_basis() * (sk.get_bone_global_rest(tipn.get_meta("bone")).origin - sk.get_bone_global_rest(basen.get_meta("bone")).origin)
			basen.queue_free()
			var side := dir.normalized().cross(Vector3.UP).normalized()
			for k in range(int(f[2])):
				var off: float = 0.0 if int(f[2]) == 1 else (k - 0.5) * 0.06
				var c := _part(tipn, long_claw if int(f[2]) == 2 else thumb_claw, -dir.normalized() * 0.05 + side * off, claw_m)
				c.basis = _vr_claw_basis(dir + side * off * 2.0, Vector3.DOWN)
			done_right = true
	# Fused left hand (and the right one on rigs without fingers): claws out of the knuckles.
	for s in ([1.0] if done_right else [1.0, -1.0]):
		var hand := _attach("left_hand" if s > 0 else "right_hand")
		for k in range(4):
			var z := -0.16 + k * 0.055
			var c := _part(hand, long_claw, Vector3(0.28 * s, -0.03, z), claw_m)
			c.basis = _vr_claw_basis(Vector3(s, 0, (k - 1.5) * 0.12), Vector3.DOWN)

## Vorruk: small head under wavy skin ridges running back over the skull, heavy brow.
func _g_head_lobes() -> void:
	# Ridges start behind the brow and roll back over the skull to the nape.
	_vr_plates("head", [
		[Vector3(0, 0.07, -0.16), Vector3(0, -1, -0.35), Vector3(0, 0, -1), 0.26, 0.16, 0.04, 0.6, 0.2],
		[Vector3(0, 0.15, -0.13), Vector3(0, -1, -0.8), Vector3(0, 0.6, -1), 0.24, 0.14, 0.04, 0.65, 0.2],
		[Vector3(0, 0.21, -0.07), Vector3(0, -0.7, -1), Vector3(0, 1, -0.6), 0.22, 0.13, 0.035, 0.7, 0.2],
		[Vector3(0, 0.24, 0.0), Vector3(0, -0.4, -1), Vector3(0, 1, -0.2), 0.19, 0.12, 0.035, 0.7, 0.2],
		[Vector3(0, 0.22, 0.07), Vector3(0, -0.2, -1), Vector3(0, 1, 0.1), 0.15, 0.1, 0.03, 0.7, 0.2],
	])

## Neris, "die Kettenhand": ash-blond pixie cut, crystal mask over the right half of the face,
## amber eyes, golden veins under pale skin, violet crystal shards on the shoulders, a chunky
## royal-blue knit scarf, leather harness and belt with a bronze buckle, a tool box and a rusty
## chain to the floor, and the iron-and-brass chain gauntlet with claw fingers on the right hand.
## Skin markings are decals on the body only (layer NERIS_SKIN), so they bend with the skin.

const NERIS_VIOLET := Color("8b5cf6")
const NERIS_GOLD := Color("ffb02e")
const NERIS_WOOL := Color("263a78")
const NERIS_LEATHER := Color("3a2212")
const NERIS_BRASS := Color("b8893a")
const NERIS_IRON := Color("3a3f47")
const NERIS_RUST := Color("7a4325")
const NERIS_HAIR := Color("a88e5c")
const NERIS_SKIN := 1 << 19

func _neris_leather(col: Color) -> StandardMaterial3D:
	var m := _mat(Color.WHITE, 0.0, 0.6)
	m.albedo_texture = _noise("leather_" + col.to_html(), 0.09, false, 0.0, [col.darkened(0.4), col.lightened(0.08)])
	m.normal_enabled = true
	m.normal_texture = _noise("leather_n", 0.12, true, 3.0)
	m.normal_scale = 0.6
	m.uv1_scale = Vector3(2, 2, 2)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

## Iron with rust blooms (noise between rust and iron), for the gauntlet, box and chains.
func _neris_iron(base: Color, rust: Color, rough: float = 0.5) -> StandardMaterial3D:
	var m := _mat(Color.WHITE, 0.8, rough)
	m.albedo_texture = _noise("rust_%s_%s" % [base.to_html(), rust.to_html()], 0.06, false, 0.0, [rust, base])
	m.normal_enabled = true
	m.normal_texture = _noise("hammered", 0.035, true, 5.0)
	m.normal_scale = 0.5
	m.uv1_scale = Vector3(2, 2, 2)
	return m

func _neris_wool(col: Color) -> StandardMaterial3D:
	var m := _mat(col, 0.0, 0.95)
	m.albedo_texture = _nknit_tex(false)
	m.normal_enabled = true
	m.normal_texture = _nknit_tex(true)
	m.normal_scale = 1.3
	m.rim = 0.25
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

## Knitted stockinette: columns of V-shaped stitches (albedo shade or normal map), drawn once.
static func _nknit_tex(normal: bool) -> Texture2D:
	var key := "knit_n" if normal else "knit_a"
	if _tex.has(key): return _tex[key]
	var n := 128
	var cell := 32.0
	var hgt := PackedFloat32Array()
	hgt.resize(n * n)
	for y in range(n):
		for x in range(n):
			var u := fmod(float(x), cell) / cell
			var v := fmod(float(y), cell) / cell
			var h := 0.0
			for side in [-1.0, 1.0]:
				var d := Vector2(-side * 0.5, 1.0).normalized()
				var p := Vector2(u - (0.5 + side * 0.2), v - 0.5)
				var a: float = p.dot(d)
				var b: float = p.dot(Vector2(-d.y, d.x))
				h = maxf(h, sqrt(maxf(0.0, 1.0 - pow(a / 0.5, 2.0) - pow(b / 0.2, 2.0))))
			hgt[y * n + x] = h
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for y in range(n):
		for x in range(n):
			var h: float = hgt[y * n + x]
			if normal:
				var dx: float = hgt[y * n + (x + 1) % n] - hgt[y * n + (x + n - 1) % n]
				var dy: float = hgt[((y + 1) % n) * n + x] - hgt[((y + n - 1) % n) * n + x]
				var nv := Vector3(-dx * 1.6, dy * 1.6, 1.0).normalized()
				img.set_pixel(x, y, Color(nv.x * 0.5 + 0.5, nv.y * 0.5 + 0.5, nv.z * 0.5 + 0.5))
			else:
				var s := 0.38 + 0.62 * h
				img.set_pixel(x, y, Color(s, s, s))
	img.generate_mipmaps()
	var tx := ImageTexture.create_from_image(img)
	_tex[key] = tx
	return tx

## Rest position of a bone in model space (meters).
func _nrest(idx: int) -> Vector3:
	return _chain_basis() * view.skeleton.get_bone_global_rest(idx).origin

func _nbone(suffix: String) -> int:
	var sk: Skeleton3D = view.skeleton
	if sk == null: return -1
	var s := suffix.to_lower()
	for b in range(sk.get_bone_count()):
		if sk.get_bone_name(b).to_lower().ends_with(s): return b
	return -1

## Like _attach, for any bone index (finger bones of the claw gauntlet).
func _nattach(idx: int) -> Node3D:
	var sk: Skeleton3D = view.skeleton
	var ba := BoneAttachment3D.new()
	ba.bone_name = sk.get_bone_name(idx)
	sk.add_child(ba)
	var holder := Node3D.new()
	holder.basis = (_chain_basis() * sk.get_bone_global_rest(idx).basis).inverse()
	ba.add_child(holder)
	var pivot := Node3D.new()
	holder.add_child(pivot)
	return pivot

## Basis with +Y along dir and +X towards side (made perpendicular).
func _nframe(dir: Vector3, side: Vector3) -> Basis:
	var y := dir.normalized()
	var x := (side - y * side.dot(y)).normalized()
	return Basis(x, y, x.cross(y).normalized())

func _nxf(pos: Vector3, rot_deg: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE) -> Transform3D:
	return Transform3D(Basis.from_euler(rot_deg * (PI / 180.0)) * Basis.from_scale(scl), pos)

## Many small static parts with one material in one mesh: [[mesh, Transform3D], ...].
func _nmerged(parts: Array) -> ArrayMesh:
	var st := SurfaceTool.new()
	for p in parts: st.append_from(p[0], 0, p[1])
	return st.commit()

## Chain links (alternating rings) walked along a polyline, as one mesh.
func _nlinks(points: Array, link_len: float, wire: float) -> ArrayMesh:
	var ring := _torus(link_len * 0.3 - wire, link_len * 0.3 + wire, 12)
	ring.ring_segments = 6
	var parts: Array = []
	var pitch := link_len * 0.72
	var walked := 0.0
	var k := 0
	for i in range(points.size() - 1):
		var a: Vector3 = points[i]
		var b: Vector3 = points[i + 1]
		var seg := (b - a).length()
		if seg < 0.00001: continue
		var tng := (b - a) / seg
		var ref := Vector3.UP if absf(tng.dot(Vector3.UP)) < 0.9 else Vector3.FORWARD
		var n0 := tng.cross(ref).normalized()
		while walked <= seg:
			var y := n0 if k % 2 == 0 else tng.cross(n0).normalized()
			var bs := Basis(tng, y, tng.cross(y).normalized()) * Basis.from_scale(Vector3(link_len / (link_len * 0.6 + wire * 2.0), 1.0, 1.0))
			parts.append([ring, Transform3D(bs, a + tng * walked)])
			walked += pitch
			k += 1
		walked -= seg
	return _nmerged(parts)

## Tube along a path (scarf rolls, belt), radius per point, cross-section squash (x: side, y: normal).
func _ntube(path: Array, radii: Array, ref: Vector3, sides: int, squash: Vector2, uv_len: float, closed: bool) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var n := path.size()
	var rows: Array = []
	var along := 0.0
	for i in range(n):
		var prev: Vector3 = path[(i - 1 + n) % n] if (closed or i > 0) else path[i]
		var nxt: Vector3 = path[(i + 1) % n] if (closed or i < n - 1) else path[i]
		var tng := (nxt - prev).normalized()
		var nx := tng.cross(ref).normalized()
		var ny := nx.cross(tng).normalized()
		if i > 0: along += (path[i] - path[i - 1]).length()
		var row: Array = []
		for s in range(sides + 1):
			var a := TAU * s / sides
			var off: Vector3 = (nx * cos(a) * squash.x + ny * sin(a) * squash.y) * float(radii[i])
			row.append([path[i] + off, (nx * cos(a) / squash.x + ny * sin(a) / squash.y).normalized(), Vector2(float(s) / sides * 6.0, along / uv_len)])
		rows.append(row)
	if closed:
		var first: Array = []
		along += (path[0] - path[n - 1]).length()
		for v in rows[0]: first.append([v[0], v[1], Vector2(v[2].x, along / uv_len)])
		rows.append(first)
	for i in range(rows.size() - 1):
		for s in range(sides):
			var q: Array = [rows[i][s], rows[i][s + 1], rows[i + 1][s + 1], rows[i + 1][s]]
			for idx in [0, 1, 2, 0, 2, 3]:
				st.set_normal(q[idx][1])
				st.set_uv(q[idx][2])
				st.add_vertex(q[idx][0])
	return st.commit()

## Decal on the body skin only (gear is not on NERIS_SKIN). Projects along -Y of its basis.
func _skin_decal(parent: Node3D, pos: Vector3, bs: Basis, size: Vector3, albedo: Texture2D, emission: Texture2D, energy: float) -> Decal:
	var d := Decal.new()
	d.size = size
	d.texture_albedo = albedo
	if emission != null:
		d.texture_emission = emission
		d.emission_energy = energy
	d.cull_mask = NERIS_SKIN
	d.normal_fade = 0.35
	d.upper_fade = 0.15
	d.lower_fade = 0.15
	d.transform = Transform3D(bs, pos)
	parent.add_child(d)
	return d

static var _neris_shader: Shader = null

## Body on the decal layer; recolor variant whose skin test also accepts the body's
## strongly saturated, darker skin texture (so the skin turns pale instead of navy).
func _neris_mark_body() -> void:
	for mi in view.model.find_children("*", "MeshInstance3D", true, false):
		if not mi.has_meta("gear"): mi.layers = mi.layers | NERIS_SKIN
	if _neris_shader == null:
		_neris_shader = Shader.new()
		_neris_shader.code = RECOLOR.code.replace("(1.0 - smoothstep(0.62, 0.78, hsv.y)) * smoothstep(0.4, 0.56, hsv.z)", "(1.0 - smoothstep(0.9, 0.98, hsv.y)) * smoothstep(0.08, 0.2, hsv.z)")
	for bm in body_mats: (bm as ShaderMaterial).shader = _neris_shader

## Neris: ash-blond, tousled pixie cut with a side-swept fringe; locks hug the skull.
func _g_neris_hair() -> void:
	var head := _attach("head", Vector3.ZERO)
	var c := Vector3(0, 0.112, 0.012)
	var r := Vector3(0.079, 0.1, 0.102)
	var rng := RandomNumberGenerator.new()
	rng.seed = 4711
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Scalp cap under the locks (hairline low in the back, high at the forehead).
	var cols := 24
	var rws := 8
	var grid: Array = []
	for j in range(rws + 1):
		var row: Array = []
		for i in range(cols + 1):
			var a := -PI + TAU * i / cols
			var e_min := lerpf(deg_to_rad(34.0), deg_to_rad(-36.0), smoothstep(deg_to_rad(40.0), deg_to_rad(150.0), absf(a)))
			var e := lerpf(e_min, deg_to_rad(89.0), float(j) / rws)
			row.append([_nskull(c, r, a, e, 0.004), Vector2(float(i) / cols * 4.0, float(j) / rws)])
		grid.append(row)
	for j in range(rws):
		for i in range(cols):
			var q: Array = [grid[j][i], grid[j][i + 1], grid[j + 1][i + 1], grid[j + 1][i]]
			for idx in [0, 1, 2, 0, 2, 3]:
				st.set_color(Color(0.5, 0.47, 0.42))
				st.set_normal((q[idx][0] - c).normalized())
				st.set_uv(q[idx][1])
				st.add_vertex(q[idx][0])
	# Locks: [root yaw, root pitch, tip yaw, tip pitch, width, lift, flick]  (yaw 0 = face, -90 = her right)
	var locks: Array = []
	# Back and sides: two layers combed down and slightly back, ends flicking out a little.
	for layer in range(2):
		var cnt := 24
		for k in range(cnt):
			var a0 := -PI + TAU * (k + 0.5 * layer) / cnt
			if absf(a0) < deg_to_rad(48.0): continue
			var back := smoothstep(deg_to_rad(60.0), deg_to_rad(170.0), absf(a0))
			var e1 := lerpf(-6.0, -34.0, back) + rng.randf_range(-6, 4) + layer * 10.0
			var a1 := a0 + signf(a0) * rng.randf_range(0.0, 0.18)
			locks.append([a0 * (0.4 + layer * 0.3), 86.0 - layer * 22.0, a1, e1, 0.042 - layer * 0.006, 0.008 + layer * 0.006, 0.006 + rng.randf() * 0.01])
	# Top: from the crown forward and over to her left.
	for k in range(7):
		var a0 := deg_to_rad(-60.0 + k * 22.0)
		locks.append([a0 * 0.3, 88.0, a0 + 0.35, 40.0 + rng.randf_range(-6, 6), 0.06, 0.016, 0.008])
	# Side-swept fringe: parted above her right eye, falling across the forehead to her left temple.
	for k in range(13):
		var f := float(k) / 12.0
		locks.append([deg_to_rad(-38.0 + f * 16.0 + rng.randf_range(-3, 3)), 66.0 - f * 6.0, deg_to_rad(-22.0 + f * 80.0 + rng.randf_range(-4, 4)), 15.0 - f * 18.0 + rng.randf_range(-6, 6), 0.036, 0.012 + f * 0.006 + rng.randf() * 0.004, 0.004])
	# Short strands framing the right side of the face.
	for k in range(3):
		locks.append([deg_to_rad(-62.0 - k * 9.0), 55.0, deg_to_rad(-58.0 - k * 10.0), -8.0 - k * 4.0, 0.035, 0.008, 0.004])
	for lk in locks:
		_lock_shade = rng.randf_range(0.78, 1.08)
		_nlock(st, c, r, float(lk[0]), deg_to_rad(float(lk[1])), float(lk[2]), deg_to_rad(float(lk[3])), float(lk[4]), float(lk[5]), float(lk[6]))
	var m := _mat(Color.WHITE, 0.0, 0.62)
	m.albedo_texture = _noise("hair_strands", 0.05, false, 0.0, [NERIS_HAIR.darkened(0.45), NERIS_HAIR.lightened(0.2)])
	m.uv1_scale = Vector3(0.7, 0.04, 1)
	m.vertex_color_use_as_albedo = true
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.rim = 0.2
	m.rim_tint = 0.7
	_part(head, st.commit(), Vector3.ZERO, m)

var _lock_shade := 1.0

func _nskull(c: Vector3, r: Vector3, a: float, e: float, lift: float) -> Vector3:
	return c + Vector3(r.x * cos(e) * sin(a), r.y * sin(e), r.z * cos(e) * cos(a)) * (1.0 + lift / r.y)

func _nlock(st: SurfaceTool, c: Vector3, r: Vector3, a0: float, e0: float, a1: float, e1: float, w0: float, lift: float, flick: float) -> void:
	var seg := 8
	var rows: Array = []
	for i in range(seg + 1):
		var t := float(i) / seg
		var l := 0.007 + lift * sin(PI * minf(1.0, t * 1.4)) + flick * t * t * t
		var p := _nskull(c, r, lerpf(a0, a1, t), lerpf(e0, e1, t), l)
		var tb := minf(1.0, t + 0.04)
		var ta := tb - 0.04
		var tng := (_nskull(c, r, lerpf(a0, a1, tb), lerpf(e0, e1, tb), l) - _nskull(c, r, lerpf(a0, a1, ta), lerpf(e0, e1, ta), l)).normalized()
		var nrm := (p - c).normalized()
		var side := tng.cross(nrm).normalized()
		var w := w0 * 0.5 * (1.0 - 0.9 * pow(t, 1.6))
		rows.append([p - side * w, p + nrm * (0.005 * (1.0 - t) + 0.0015), p + side * w, t, nrm])
	for i in range(seg):
		for k in range(2):
			var q: Array = [rows[i][k], rows[i][k + 1], rows[i + 1][k + 1], rows[i + 1][k]]
			var ta: float = rows[i][3]
			var tb: float = rows[i + 1][3]
			var nn: Array = [rows[i][4], rows[i][4], rows[i + 1][4], rows[i + 1][4]]
			var uvs: Array = [Vector2(k * 0.5, ta), Vector2(k * 0.5 + 0.5, ta), Vector2(k * 0.5 + 0.5, tb), Vector2(k * 0.5, tb)]
			var shade: Array = [(0.6 + 0.4 * ta) * _lock_shade, (0.6 + 0.4 * ta) * _lock_shade, (0.6 + 0.4 * tb) * _lock_shade, (0.6 + 0.4 * tb) * _lock_shade]
			for idx in [0, 1, 2, 0, 2, 3]:
				st.set_color(Color(shade[idx], shade[idx], shade[idx]))
				st.set_normal(nn[idx])
				st.set_uv(uvs[idx])
				st.add_vertex(q[idx])

## Neris: crystal mask over the right half of the face and the forehead, amber glowing eyes.
func _g_neris_face() -> void:
	_neris_mark_body()
	var head := _attach("head", Vector3.ZERO)
	var bs := Basis.from_euler(Vector3(PI * 0.5, 0, 0))
	var mask := _skin_decal(head, Vector3(0, 0.08, 0.07), bs, Vector3(0.17, 0.14, 0.24), _nmask_tex("albedo"), _nmask_tex("emission"), 1.4)
	mask.texture_orm = _nmask_tex("orm")
	_skin_decal(head, Vector3(0, 0.074, 0.08), bs, Vector3(0.1, 0.1, 0.04), _neyes_tex(false), _neyes_tex(true), 4.0)

## Face decal (0.17 x 0.24 m, u: +X = her left, v: down from 0.2 m above the head bone):
## ragged blue-violet crystal patch with glowing cracks over the right half and the forehead;
## also evens out the body's own face paint (skin-colored) and tints the lips.
static func _nmask_tex(kind: String) -> Texture2D:
	var key := "neris_mask_" + kind
	if _tex.has(key): return _tex[key]
	var n := 192
	var fn := FastNoiseLite.new()
	fn.seed = 5
	fn.frequency = 0.035
	fn.fractal_octaves = 3
	var cell := FastNoiseLite.new()
	cell.noise_type = FastNoiseLite.TYPE_CELLULAR
	cell.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_SUB
	cell.frequency = 0.045
	cell.seed = 9
	var facet := FastNoiseLite.new()
	facet.noise_type = FastNoiseLite.TYPE_CELLULAR
	facet.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE
	facet.frequency = 0.045
	facet.seed = 9
	var skin := Color8(214, 198, 184)
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for y in range(n):
		for x in range(n):
			var mx := (float(x) / n - 0.5) * 0.17
			var my := 0.2 - float(y) / n * 0.24
			var inside := maxf(0.004 - mx, my - 0.104)
			inside = minf(inside, minf(0.072 - absf(mx), my - 0.012 + mx * 0.3))
			var a := clampf((inside * 120.0 + fn.get_noise_2d(x, y) * 1.3) * 2.0, 0.0, 1.0)
			var crack := 1.0 - smoothstep(0.0, 0.1, absf(cell.get_noise_2d(x, y)))
			var paint := 1.0 - smoothstep(0.75, 1.0, Vector2((mx - 0.038) / 0.034, (my - 0.02) / 0.032).length())
			var lips := 1.0 - smoothstep(0.6, 1.0, Vector2(mx / 0.021, (my - 0.003) / 0.008).length())
			if kind == "orm":
				# Even roughness/metal: the body paint underneath is shaded like cloth, not skin.
				img.set_pixel(x, y, Color(1.0, lerpf(0.55, 0.32, a), lerpf(0.0, 0.12, a), 1.0))
			elif kind == "emission":
				var e := crack * a * 0.9
				img.set_pixel(x, y, Color(0.55 * e, 0.42 * e, 1.0 * e, 1.0))
			else:
				var base := Color("2a2378").lerp(Color("6550d8"), clampf(0.5 + facet.get_noise_2d(x, y) * 0.8 + fn.get_noise_2d(x * 2.0, y * 2.0) * 0.3, 0.0, 1.0))
				base = base.lerp(Color("b4a4ff"), crack * 0.75)
				var col := skin.lerp(Color8(168, 112, 118), lips)
				var ca := maxf(paint, lips) * (1.0 - a)
				var out_a := a * 0.95 + ca
				var mixed := base.lerp(col, ca / maxf(out_a, 0.001))
				img.set_pixel(x, y, Color(mixed.r, mixed.g, mixed.b, clampf(out_a, 0.0, 1.0)))
	img.generate_mipmaps()
	var tx := ImageTexture.create_from_image(img)
	_tex[key] = tx
	return tx

static func _neyes_tex(emission: bool) -> Texture2D:
	var key := "neris_eyes_e" if emission else "neris_eyes"
	if _tex.has(key): return _tex[key]
	var n := 64
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for y in range(n):
		for x in range(n):
			var a := 0.0
			for s in [-1.0, 1.0]:
				var d := Vector2(float(x) / n - (0.5 + s * 0.32), (float(y) / n - 0.5) * 2.2).length()
				a = maxf(a, 1.0 - smoothstep(0.03, 0.07, d))
			img.set_pixel(x, y, Color(a, 0.62 * a, 0.16 * a, 1.0) if emission else Color(1.0, 0.62, 0.16, a))
	var tx := ImageTexture.create_from_image(img)
	_tex[key] = tx
	return tx

## Golden veins: branching lines (albedo with alpha; emission in gold), drawn once.
static func _nvein_tex(emission: bool) -> Texture2D:
	var key := "neris_veins_e" if emission else "neris_veins"
	if _tex.has(key): return _tex[key]
	var n := 192
	var alpha := PackedFloat32Array()
	alpha.resize(n * n)
	var rng := RandomNumberGenerator.new()
	rng.seed = 23
	var stack: Array = []
	for k in range(3): stack.append([Vector2(30.0 + k * 66.0 + rng.randf_range(-10, 10), 0.0), Vector2(rng.randf_range(-0.25, 0.25), 1.0).normalized(), 1.8, 0])
	while not stack.is_empty():
		var br: Array = stack.pop_back()
		var p: Vector2 = br[0]
		var dir: Vector2 = br[1]
		var w: float = br[2]
		var depth: int = br[3]
		for s in range(140):
			for dy in range(-3, 4):
				for dx in range(-3, 4):
					var q := Vector2i(int(p.x) + dx, int(p.y) + dy)
					if q.x < 0 or q.y < 0 or q.x >= n or q.y >= n: continue
					var v := 1.0 - smoothstep(w * 0.5, w * 0.5 + 1.0, Vector2(dx, dy).length())
					alpha[q.y * n + q.x] = maxf(alpha[q.y * n + q.x], v)
			dir = dir.rotated(rng.randf_range(-0.22, 0.22))
			p += dir * 1.5
			w = maxf(0.8, w - 0.01)
			if depth < 2 and rng.randf() < 0.018:
				stack.append([p, dir.rotated(rng.randf_range(0.5, 0.9) * (1.0 if rng.randf() < 0.5 else -1.0)), w * 0.75, depth + 1])
			if p.x < 0 or p.y < 0 or p.x >= n or p.y >= n: break
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	for i in range(n * n):
		var a: float = alpha[i]
		if emission: img.set_pixel(i % n, i / n, Color(1.0 * a, 0.7 * a, 0.2 * a, 1.0))
		else: img.set_pixel(i % n, i / n, Color(1.0, 0.8, 0.4, a * 0.85))
	img.generate_mipmaps()
	var tx := ImageTexture.create_from_image(img)
	_tex[key] = tx
	return tx

## Harness strap decal (0.32 x 0.36 m): stitched leather band from her left shoulder (u high,
## top) to her right flank, with a brass buckle; back=true flips it for the back decal.
static func _nstrap_tex(back: bool) -> Texture2D:
	var key := "neris_strap_b" if back else "neris_strap"
	if _tex.has(key): return _tex[key]
	var n := 256
	var fn := FastNoiseLite.new()
	fn.seed = 3
	fn.frequency = 0.06
	var a := Vector2(0.86, -0.05)
	var b := Vector2(0.08, 1.05)
	var dir := (b - a).normalized()
	var nrm := Vector2(-dir.y, dir.x)
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var leather := Color("5a3620")
	for y in range(n):
		for x in range(n):
			var p := Vector2(float(x) / n, float(y) / n)
			var d := (p - a).dot(nrm)
			var t := (p - a).dot(dir) / (b - a).length()
			var hw := 0.052
			var al := 1.0 - smoothstep(hw - 0.006, hw, absf(d))
			if al <= 0.0:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var col := leather.lerp(leather.darkened(0.45), clampf(0.5 + fn.get_noise_2d(x, y), 0.0, 1.0) * 0.6)
			col = col.darkened(smoothstep(hw - 0.016, hw, absf(d)) * 0.5)
			var stitch := absf(absf(d) - (hw - 0.012)) < 0.0035 and fmod(t * 60.0, 1.0) < 0.55
			if stitch: col = Color("c8a878")
			# Brass buckle: frame across the strap at t = 0.3, rivets at t = 0.55 and 0.75.
			var bt := absf(t - 0.3) * 1.1
			if bt < 0.04 and absf(d) < hw + 0.008:
				var frame := bt > 0.026 or absf(d) > hw - 0.008
				if frame: col = Color("c9a050").lerp(Color("7a5a24"), clampf(bt * 12.0 - 0.2, 0.0, 1.0))
				al = 1.0
			for rt in [0.55, 0.75]:
				if Vector2((t - rt) * 1.12, d).length() < 0.012: col = Color("b8893a")
			img.set_pixel(x, y, Color(col.r, col.g, col.b, al))
	if back: img.flip_y()
	img.generate_mipmaps()
	var tx := ImageTexture.create_from_image(img)
	_tex[key] = tx
	return tx

## Neris: golden glowing veins under the skin of the arms and the belly.
func _g_glow_veins() -> void:
	_neris_mark_body()
	var alb := _nvein_tex(false)
	var em := _nvein_tex(true)
	for side in ["left_forearm", "left_arm", "right_arm"]:
		if _bone_idx(side) == -1: continue
		var a := _attach(side, Vector3.ZERO)
		var dir := _bone_dir(side)
		var l := 0.26
		# Decal X along the arm, projected from the front (+Z) onto the skin.
		var y := (Vector3.BACK - dir * Vector3.BACK.dot(dir)).normalized()
		var bs := Basis(dir, y, dir.cross(y).normalized())
		_skin_decal(a, dir * l * 0.55, bs, Vector3(l, 0.14, 0.1), alb, em, 3.0)
	var sp := _attach("spine", Vector3.ZERO)
	_skin_decal(sp, Vector3(0, 0.04, 0.08), Basis.from_euler(Vector3(PI * 0.5, 0, 0)), Vector3(0.2, 0.2, 0.16), alb, em, 1.8)

## Neris: small clusters of violet crystal shards growing out of shoulders and upper arms.
func _g_shoulder_crystals() -> void:
	var outer := _crystal(NERIS_VIOLET)
	outer.albedo_color = Color(0.55, 0.4, 0.95, 0.55)
	var core := _glow(Color("c4b5fd"), 1.6)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for side in ["left_arm", "right_arm"]:
		var a := _attach(side, Vector3.ZERO)
		var dir := _bone_dir(side)
		var s: float = 1.0 if side.begins_with("left") else -1.0
		var up := (Vector3.UP - dir * Vector3.UP.dot(dir)).normalized()
		var fwd := dir.cross(up).normalized() * s
		var outs: Array = []
		var cores: Array = []
		# [along the arm, around (0 = up), shards, size]
		for cl in [[0.03, 15.0, 6, 1.5], [0.12, 65.0, 4, 1.0], [0.07, -30.0, 3, 0.8]]:
			var ang := deg_to_rad(float(cl[1]))
			var nrm := (up * cos(ang) - fwd * sin(ang)).normalized()
			var base: Vector3 = dir * float(cl[0]) + nrm * 0.04
			for k in range(int(cl[2])):
				var ln: float = (0.055 if k == 0 else rng.randf_range(0.025, 0.042)) * float(cl[3])
				var tilt := nrm.rotated(dir, rng.randf_range(-0.6, 0.6)).rotated(up.cross(nrm).normalized() if absf(up.dot(nrm)) < 0.99 else dir, rng.randf_range(-0.5, 0.5)).normalized()
				var bs := _nframe(tilt, dir)
				var pos: Vector3 = base + dir * rng.randf_range(-0.015, 0.015) + tilt * ln * 0.25
				outs.append([_crystal_mesh(ln, ln * 0.22), Transform3D(bs, pos)])
				cores.append([_crystal_mesh(ln * 0.6, ln * 0.09), Transform3D(bs, pos)])
		_part(a, _nmerged(cores), Vector3.ZERO, core)
		_part(a, _nmerged(outs), Vector3.ZERO, outer)

## Neris: mechanical chain gauntlet on the right forearm and hand: iron lames with brass rims,
## a winch drum, chain wound around forearm and hand, a spinning gear and claw-tipped fingers.
func _g_chain_gauntlet() -> void:
	var fa_i := _bone_idx("right_forearm")
	var h_i := _bone_idx("right_hand")
	var mid_i := _nbone("RightHandMiddle1")
	var ind := _nbone("RightHandIndex1")
	var pin := _nbone("RightHandPinky1")
	if fa_i == -1 or h_i == -1 or mid_i == -1 or ind == -1 or pin == -1: return
	var iron := _neris_iron(NERIS_IRON, Color("5a3a28"), 0.45)
	var brass := _metal(NERIS_BRASS, 0.3)
	var chain_m := _neris_iron(Color("5b5550"), NERIS_RUST, 0.6)
	var across := (_nrest(ind) - _nrest(pin)).normalized()
	var hand_dir := (_nrest(mid_i) - _nrest(h_i)).normalized()
	var palm := across.cross(hand_dir).normalized()   # palm normal (right hand)
	# Forearm: +Y to the wrist, +X towards the palm side.
	var L := (_nrest(h_i) - _nrest(fa_i)).length()
	var fa := _attach("right_forearm", Vector3.ZERO)
	var fb := Node3D.new()
	fb.basis = _nframe(_nrest(h_i) - _nrest(fa_i), palm)
	fa.add_child(fb)
	var iron_parts: Array = []
	var brass_parts: Array = []
	for k in range(3):
		var y0 := L * (0.36 + k * 0.2)
		var r0 := 0.047 - k * 0.003
		iron_parts.append([_cyl(r0 - 0.004, r0, L * 0.22, 14), _nxf(Vector3(0, y0 + L * 0.1, 0))])
		brass_parts.append([_torus(r0 - 0.004, r0 + 0.004, 16), _nxf(Vector3(0, y0 + L * 0.2, 0))])
	# Ridge plates on the back of the forearm and rivets.
	for k in range(3):
		iron_parts.append([_box(0.018, L * 0.5, 0.012), _nxf(Vector3(-0.046, L * 0.62, (k - 1) * 0.022))])
	for k in range(6):
		var ang := TAU * k / 6.0
		brass_parts.append([_sphere(0.005, 6), _nxf(Vector3(cos(ang) * 0.047, L * 0.4, sin(ang) * 0.047))])
	# Winch drum on the back of the forearm near the elbow, with chain wound on it.
	var drum := Vector3(-0.062, L * 0.3, 0)
	iron_parts.append([_cyl(0.024, 0.024, 0.05, 14), _nxf(drum, Vector3(90, 0, 0))])
	for s in [-1.0, 1.0]:
		brass_parts.append([_cyl(0.031, 0.031, 0.006, 16), _nxf(drum + Vector3(0, 0, 0.026 * s), Vector3(90, 0, 0))])
	brass_parts.append([_cyl(0.008, 0.008, 0.07, 8), _nxf(drum, Vector3(90, 0, 0))])
	_part(fb, _nmerged(iron_parts), Vector3.ZERO, iron)
	_part(fb, _nmerged(brass_parts), Vector3.ZERO, brass)
	# Chain: coiled on the drum, then spiralling down the forearm to the wrist.
	var pts: Array = []
	for i in range(40):
		var t := float(i) / 39.0
		var ang := t * TAU * 2.0
		pts.append(drum + Vector3(cos(ang) * 0.03, sin(ang) * 0.03, lerpf(-0.018, 0.018, t)))
	for i in range(60):
		var t := float(i) / 59.0
		var ang := PI + t * TAU * 2.3
		pts.append(Vector3(cos(ang) * 0.056, lerpf(L * 0.32, L * 0.95, t), sin(ang) * 0.056))
	_part(fb, _nlinks(pts, 0.024, 0.0032), Vector3.ZERO, chain_m)
	# Hand: back plate, knuckle guard, spinning gear with an amber core, chain loop round the palm.
	var hand := _attach("right_hand", Vector3.ZERO)
	var hb := Node3D.new()
	hb.basis = _nframe(hand_dir, palm)
	hand.add_child(hb)
	var h_iron: Array = []
	h_iron.append([_box(0.012, 0.06, 0.07), _nxf(Vector3(-0.024, 0.035, 0))])
	h_iron.append([_box(0.016, 0.018, 0.078), _nxf(Vector3(-0.018, 0.075, 0))])
	h_iron.append([_cyl(0.036, 0.04, 0.03, 14), _nxf(Vector3(0.0, -0.004, 0), Vector3.ZERO, Vector3(0.8, 1.0, 1.15))])
	_part(hb, _nmerged(h_iron), Vector3.ZERO, iron)
	# Palm: dark leather pad, so no bare skin shows between the iron.
	_part(hb, _box(0.008, 0.075, 0.072), Vector3(0.02, 0.042, 0), _neris_leather(Color("1c1714")))
	var gear := Node3D.new()
	gear.position = Vector3(-0.034, 0.035, 0)
	hb.add_child(gear)
	_part(gear, _ngear(0.022, 0.006, 10), Vector3.ZERO, brass, Vector3(0, 0, 90))
	_part(gear, _sphere(0.008, 10), Vector3(-0.004, 0, 0), _glow(NERIS_GOLD, 3.0))
	spinners.append([gear, Vector3.RIGHT, 1.5])
	var loop: Array = []
	for i in range(26):
		var ang := TAU * i / 25.0
		loop.append(Vector3(cos(ang) * 0.026 - 0.004, 0.05 + sin(ang * 0.5) * 0.004, sin(ang) * 0.05))
	_part(hb, _nlinks(loop, 0.02, 0.0028), Vector3.ZERO, chain_m)
	# Claw fingers: iron sleeves on every phalanx, a hooked claw on the last one.
	var claw_m := _neris_iron(Color("2b2f36"), Color("4a3a30"), 0.35)
	for f in ["Index", "Middle", "Ring", "Pinky", "Thumb"]:
		for seg in range(1, 4):
			var bi := _nbone("RightHand%s%d" % [f, seg])
			var bj := _nbone("RightHand%s%d" % [f, seg + 1])
			if bi == -1 or bj == -1: continue
			var d := _nrest(bj) - _nrest(bi)
			var ln := d.length()
			var p := _nattach(bi)
			var fbs := Node3D.new()
			fbs.basis = _nframe(d, palm)
			p.add_child(fbs)
			var rad := (0.0125 if f != "Pinky" else 0.0108) * (1.0 - seg * 0.06)
			var parts: Array = [[_cyl(rad * 0.9, rad, ln * 0.96, 8), _nxf(Vector3(0.001, ln * 0.5, 0))]]
			parts.append([_box(rad * 1.2, ln * 0.8, rad * 1.6), _nxf(Vector3(-rad * 0.7, ln * 0.5, 0))])
			_part(fbs, _nmerged(parts), Vector3.ZERO, claw_m)
			if seg == 3: _part(fbs, _blade(0.03, 0.014, 0.008, 0.012), Vector3(-0.002, ln * 0.7, 0), claw_m)

## Brass gear wheel lying in the XZ plane (teeth around the rim).
func _ngear(r: float, h: float, teeth: int) -> ArrayMesh:
	var parts: Array = [[_cyl(r, r, h, 20), Transform3D.IDENTITY], [_cyl(r * 0.45, r * 0.45, h * 1.6, 12), Transform3D.IDENTITY]]
	for k in range(teeth):
		var ang := TAU * k / teeth
		parts.append([_box(r * 0.3, h, r * 0.32), Transform3D(Basis(Vector3.UP, -ang), Vector3(cos(ang), 0, sin(ang)) * r * 1.08)])
	return _nmerged(parts)

## Neris: chunky royal-blue knit scarf, wound twice round the neck, one end hanging in front.
func _g_neris_scarf() -> void:
	var chest := _attach("chest", Vector3.ZERO)
	var wool := _neris_wool(NERIS_WOOL)
	for w in [[0.15, 0.088, 0.078, 0.036, 0.0, 0.0], [0.125, 0.105, 0.098, 0.034, 0.035, 1.3]]:
		var path: Array = []
		var radii: Array = []
		for i in range(28):
			var a := TAU * i / 28.0
			var front := maxf(0.0, cos(a))
			path.append(Vector3(sin(a) * float(w[1]), float(w[0]) - front * float(w[4]) - 0.01 * front, cos(a) * float(w[2]) + 0.012))
			radii.append(float(w[3]) * (1.0 + 0.1 * sin(a * 5.0 + float(w[5]))))
		_part(chest, _ntube(path, radii, Vector3.UP, 12, Vector2(1.0, 0.85), 0.014, true), Vector3.ZERO, wool)
	# Hanging end: three knitted slabs that swing one after the other.
	var node := Node3D.new()
	node.position = Vector3(0.06, 0.09, 0.118)
	node.rotation_degrees = Vector3(-16, 0, 12)
	chest.add_child(node)
	sways.append([node, node.rotation_degrees, 4.0, 2.1, 0.0, 14.0])
	for i in range(2):
		var seg_len := 0.08
		var path2: Array = []
		var rad2: Array = []
		for k in range(4):
			path2.append(Vector3(0, -seg_len * 1.12 * k / 3.0 + 0.008, 0))
			rad2.append(0.05 - i * 0.002)
		_part(node, _ntube(path2, rad2, Vector3.BACK, 10, Vector2(1.0, 0.32), 0.014, false), Vector3.ZERO, wool)
		if i == 1: break
		var nxt := Node3D.new()
		nxt.position = Vector3(0, -seg_len, 0)
		node.add_child(nxt)
		sways.append([nxt, Vector3(6, 0, 0), 3.0, 2.1, 0.7 * (i + 1), 6.0])
		node = nxt

## Neris: leather harness across the chest with buckle and pouch; belt with a round bronze
## buckle, a tool box on the left hip and a rusty chain hanging to the floor.
func _g_belt_chain() -> void:
	var leather := _neris_leather(NERIS_LEATHER)
	var brass := _metal(NERIS_BRASS.darkened(0.1), 0.35)
	var iron := _neris_iron(NERIS_IRON, NERIS_RUST, 0.55)
	# Harness: leather strap over her left shoulder, diagonally down to the right flank. Drawn as
	# decals front and back, so it lies exactly on the top and the skin.
	_neris_mark_body()
	var chest := _attach("chest", Vector3.ZERO)
	_skin_decal(chest, Vector3(0, 0.02, 0.06), Basis.from_euler(Vector3(PI * 0.5, 0, 0)), Vector3(0.3, 0.26, 0.36), _nstrap_tex(false), null, 0.0)
	_skin_decal(chest, Vector3(0, 0.02, -0.06), Basis.from_euler(Vector3(-PI * 0.5, 0, 0)), Vector3(0.3, 0.26, 0.36), _nstrap_tex(true), null, 0.0)
	# Belt: leather band round the hips, a round bronze buckle in front.
	var hips := _attach("hips", Vector3.ZERO)
	var band: Array = []
	var rad: Array = []
	for i in range(32):
		var a := TAU * i / 32.0
		band.append(Vector3(sin(a) * 0.158, 0.035 - maxf(0.0, cos(a)) * 0.02, cos(a) * 0.118 + 0.012))
		rad.append(0.026)
	_part(hips, _ntube(band, rad, Vector3.UP, 8, Vector2(0.3, 1.0), 0.1, true), Vector3.ZERO, leather)
	var bz := Vector3(0, 0.015, 0.138)
	var bp: Array = [[_torus(0.019, 0.03, 24), _nxf(bz, Vector3(90, 0, 0))], [_cyl(0.019, 0.019, 0.006, 20), _nxf(bz + Vector3(0, 0, -0.002), Vector3(90, 0, 0))], [_sphere(0.008, 10), _nxf(bz + Vector3(0, 0, 0.004))]]
	_part(hips, _nmerged(bp), Vector3.ZERO, brass)
	# Tool box on the left hip: iron case, brass corners, gauge and crank.
	var box := Node3D.new()
	box.position = Vector3(0.172, -0.03, -0.01)
	box.rotation_degrees = Vector3(0, 90, -6)
	hips.add_child(box)
	_part(box, _box(0.085, 0.075, 0.045), Vector3.ZERO, iron)
	var corners: Array = []
	for sx in [-1.0, 1.0]:
		for sy in [-1.0, 1.0]:
			corners.append([_box(0.014, 0.014, 0.05), _nxf(Vector3(sx * 0.038, sy * 0.032, 0))])
	corners.append([_torus(0.012, 0.017, 16), _nxf(Vector3(0.012, 0.004, 0.024), Vector3(90, 0, 0))])
	corners.append([_cyl(0.004, 0.004, 0.03, 6), _nxf(Vector3(-0.03, 0.0, 0.032), Vector3(90, 0, 0))])
	corners.append([_cyl(0.005, 0.005, 0.022, 6), _nxf(Vector3(-0.03, -0.01, 0.047))])
	_part(box, _nmerged(corners), Vector3.ZERO, brass)
	_part(box, _cyl(0.012, 0.012, 0.004, 16), Vector3(0.012, 0.004, 0.025), _glow(NERIS_GOLD, 1.2), Vector3(90, 0, 0))
	# Rusty chain from the belt down to the floor, swinging.
	var node := Node3D.new()
	node.position = Vector3(0.172, 0.0, 0.05)
	hips.add_child(node)
	var chain_m := _neris_iron(Color("6b5d52"), NERIS_RUST, 0.7)
	for i in range(8):
		var seg := Node3D.new()
		seg.position = Vector3.ZERO if i == 0 else Vector3(0, -0.11, 0)
		seg.rotation_degrees = Vector3(0, 0, 9 if i == 0 else 0)
		node.add_child(seg)
		sways.append([seg, seg.rotation_degrees, 3.0 + i * 0.5, 1.7, i * 0.45, 4.0])
		_part(seg, _nlinks([Vector3.ZERO, Vector3(0, -0.115, 0)], 0.034, 0.0045), Vector3.ZERO, chain_m)
		node = seg

# ─────────────────────────────────────────────────────── nations ──

## Flag image of a country, drawn here (no imported files): de, ru, tr, ba, us.
static func flag_image(code: String) -> Image:
	var w := 240
	var h := 160
	if code == "us": w = 304
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	match code:
		"de", "ru":
			var cols: Array = [Color("000000"), Color("dd0000"), Color("ffce00")] if code == "de" else [Color("ffffff"), Color("0039a6"), Color("d52b1e")]
			for k in range(3): img.fill_rect(Rect2i(0, k * h / 3, w, h / 3 + 1), cols[k])
		"tr":
			img.fill(Color("e30a17"))
			_disc(img, Vector2(88, 80), 40.0, Color.WHITE)
			_disc(img, Vector2(98, 80), 32.0, Color("e30a17"))
			_star(img, Vector2(140, 80), 20.0, PI, Color.WHITE)
		"ba":
			img.fill(Color("002395"))
			var tri := PackedVector2Array([Vector2(w * 0.27, 0), Vector2(w * 0.77, 0), Vector2(w * 0.77, h)])
			_poly(img, tri, Color("fecb00"))
			for k in range(9):
				var t: float = (k + 0.25) / 8.5
				var p: Vector2 = Vector2(w * 0.27, 0).lerp(Vector2(w * 0.77, h), t) + Vector2(-17, 0)
				_star(img, p, 9.0, -PI / 2.0, Color.WHITE)
		"us":
			for k in range(13): img.fill_rect(Rect2i(0, int(k * h / 13.0), w, int(h / 13.0) + 1), Color("b22234") if k % 2 == 0 else Color.WHITE)
			var cw := int(w * 0.4)
			var ch := int(h * 7.0 / 13.0)
			img.fill_rect(Rect2i(0, 0, cw, ch), Color("3c3b6e"))
			for r in range(9):
				var n: int = 6 if r % 2 == 0 else 5
				for c in range(n):
					var x: float = cw * ((c * 2 + (1 if r % 2 == 0 else 2)) / 12.0)
					_star(img, Vector2(x, ch * (r + 1) / 10.0), 3.6, -PI / 2.0, Color.WHITE)
	return img

static func _disc(img: Image, c: Vector2, r: float, col: Color) -> void:
	for y in range(maxi(0, int(c.y - r)), mini(img.get_height(), int(c.y + r) + 1)):
		for x in range(maxi(0, int(c.x - r)), mini(img.get_width(), int(c.x + r) + 1)):
			if Vector2(x + 0.5, y + 0.5).distance_to(c) <= r: img.set_pixel(x, y, col)

static func _poly(img: Image, pts: PackedVector2Array, col: Color) -> void:
	var box := Rect2(pts[0], Vector2.ZERO)
	for p in pts: box = box.expand(p)
	for y in range(maxi(0, int(box.position.y)), mini(img.get_height(), int(box.end.y) + 1)):
		for x in range(maxi(0, int(box.position.x)), mini(img.get_width(), int(box.end.x) + 1)):
			if Geometry2D.is_point_in_polygon(Vector2(x + 0.5, y + 0.5), pts): img.set_pixel(x, y, col)

## Five-pointed star, first point at angle a0.
static func _star(img: Image, c: Vector2, r: float, a0: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for k in range(10):
		var rr: float = r if k % 2 == 0 else r * 0.4
		var a: float = a0 + PI * k / 5.0
		pts.append(c + Vector2(cos(a), sin(a)) * rr)
	_poly(img, pts, col)

static func flag_texture(code: String) -> Texture2D:
	var key := "flag_" + code
	if not _tex.has(key): _tex[key] = ImageTexture.create_from_image(flag_image(code))
	return _tex[key]

func _flag_mat() -> StandardMaterial3D:
	var m := _mat(Color.WHITE, 0.0, 0.75)
	m.albedo_texture = flag_texture(str(hero.get("flag", "de")))
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.rim = 0.2
	return m

## Banner pole on the back with the country's flag, waving above the head.
func _g_flag_banner() -> void:
	var back := _attach("chest", Vector3(0.08, 0.0, -0.17))
	var pole_m := _metal(hero.accent.lerp(Color("c0a060"), 0.5), 0.3)
	_part(back, _cyl(0.014, 0.014, 1.15), Vector3(0, 0.45, 0), pole_m)
	_part(back, _sphere(0.035, 12), Vector3(0, 1.04, 0), _metal(Color("e8c766"), 0.2))
	var wave := Node3D.new()
	wave.position = Vector3(0, 0.98, 0)
	back.add_child(wave)
	sways.append([wave, Vector3.ZERO, 7.0, 2.4, 0.0, 22.0])
	var q := QuadMesh.new()
	var ratio: float = 1.9 if str(hero.get("flag", "")) == "us" else 1.5
	q.size = Vector2(0.36 * ratio, 0.36)
	var flag := _part(wave, q, Vector3(-0.18 * ratio - 0.015, -0.18, 0), _flag_mat(), Vector3(0, 90, 0))
	flag.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

## Flag shield on the chest.
func _g_flag_crest() -> void:
	var chest := _attach("chest", Vector3(0, 0.04, 0.16))
	var ratio: float = 1.9 if str(hero.get("flag", "")) == "us" else 1.5
	var q := QuadMesh.new()
	q.size = Vector2(0.12 * ratio, 0.12)
	_part(chest, _box(0.12 * ratio + 0.025, 0.145, 0.012), Vector3(0, 0, -0.008), _metal(hero.accent.lerp(Color("c0a060"), 0.6), 0.3))
	_part(chest, q, Vector3(0, 0, 0.0), _flag_mat())

## Konrad: forge hammer, its face glows like hot iron.
func _g_forge_hammer() -> void:
	var hand := _attach("right_hand", Vector3(0, 0, 0.02))
	var hm := Node3D.new()
	hm.basis = _basis_along(_bone_dir("right_hand"))
	hand.add_child(hm)
	var shaft := Node3D.new()
	shaft.rotation_degrees = Vector3(90, 0, 0)
	hm.add_child(shaft)
	_part(shaft, _cyl(0.022, 0.026, 0.75), Vector3(0, 0.15, 0), _mat(Color("5b3a1e"), 0.05, 0.6))
	var steel := _metal(Color("3a3a3e"), 0.3)
	_part(shaft, _box(0.3, 0.14, 0.14), Vector3(0, 0.55, 0), steel, Vector3(0, 0, 90))
	var face := _part(shaft, _box(0.02, 0.13, 0.13), Vector3(0, 0.71, 0), _glow(Color("ff7a1a"), 3.0), Vector3(0, 0, 90))
	react["hammer_glow"] = face
	for k in range(3):
		_part(shaft, _torus(0.024, 0.03), Vector3(0, -0.15 + k * 0.05, 0), _metal([Color("1a1a1a"), Color("dd0000"), Color("ffce00")][k]))

## Konrad: leather smith apron.
func _g_smith_apron() -> void:
	var hips := _attach("hips", Vector3(0, 0.06, 0.12))
	var leather := _mat(Color("6b4423"), 0.05, 0.65)
	leather.cull_mode = BaseMaterial3D.CULL_DISABLED
	_ribbon(hips, 0.45, 0.32, 3, leather, Vector3(4, 0, 0), 3.0, 10.0)
	_part(hips, _box(0.4, 0.025, 0.02), Vector3(0, 0.02, 0), _cloth(Color("1a1a1a")))

## Bogdan: pointed bogatyr helmet with rim and a nose guard.
func _g_bogatyr_helm() -> void:
	var head := _attach("head", Vector3(0, 0.12, 0))
	var steel := _metal(Color("c8ccd2"), 0.22)
	_part(head, _sphere(0.11, 24), Vector3(0, 0.02, 0), steel, Vector3.ZERO, Vector3(1.0, 0.75, 1.0))
	_part(head, _cyl(0.0, 0.07, 0.17, 16), Vector3(0, 0.15, 0), steel)
	_part(head, _sphere(0.018, 10), Vector3(0, 0.24, 0), _metal(Color("d52b1e"), 0.25))
	_part(head, _torus(0.105, 0.122), Vector3(0, -0.03, 0), _metal(Color("c9a227"), 0.25))
	_part(head, _box(0.018, 0.09, 0.012), Vector3(0, -0.07, 0.115), steel)

## Bogdan: flanged mace.
func _g_bogatyr_mace() -> void:
	var hand := _attach("right_hand", Vector3(0, 0, 0.02))
	var mc := Node3D.new()
	mc.basis = _basis_along(_bone_dir("right_hand"))
	hand.add_child(mc)
	var shaft := Node3D.new()
	shaft.rotation_degrees = Vector3(90, 0, 0)
	mc.add_child(shaft)
	_part(shaft, _cyl(0.024, 0.028, 0.8), Vector3(0, 0.2, 0), _mat(Color("4a3020"), 0.05, 0.6))
	var steel := _metal(Color("9aa3ad"), 0.25)
	_part(shaft, _sphere(0.1, 20), Vector3(0, 0.66, 0), steel)
	for k in range(6):
		var a := TAU * k / 6.0
		_part(shaft, _box(0.02, 0.2, 0.08), Vector3(cos(a) * 0.09, 0.66, sin(a) * 0.09), steel, Vector3(0, -rad_to_deg(a), 0))
	_part(shaft, _torus(0.026, 0.034), Vector3(0, -0.15, 0), _metal(Color("0039a6"), 0.3))

## Kaan: curved sabre (kılıç) with a gold guard.
func _g_kilij() -> void:
	var hand := _attach("right_hand", Vector3(0, 0, 0.02))
	var sb := Node3D.new()
	sb.basis = _basis_along(_bone_dir("right_hand"))
	hand.add_child(sb)
	var holder := Node3D.new()
	holder.rotation_degrees = Vector3(90, 0, 0)
	sb.add_child(holder)
	_part(holder, _cyl(0.018, 0.02, 0.16), Vector3(0, -0.02, 0), _mat(Color("3b1d12"), 0.05, 0.6))
	_part(holder, _box(0.16, 0.025, 0.03), Vector3(0, 0.07, 0), _metal(Color("e8c766"), 0.2))
	_part(holder, _blade(0.85, 0.07, 0.014, 0.16), Vector3(0, 0.08, 0), _metal(Color("e5e7eb"), 0.12))

## Dusty: wide-brimmed cowboy hat with a red band.
func _g_cowboy_hat() -> void:
	var head := _attach("head", Vector3(0, 0.25, -0.01))
	var felt := _mat(Color("8b5a2b"), 0.0, 0.85)
	var brim := _part(head, _cyl(0.23, 0.23, 0.014, 32), Vector3(0, -0.01, 0), felt)
	brim.scale = Vector3(1.0, 1.0, 0.85)
	_part(head, _cyl(0.088, 0.105, 0.13, 24), Vector3(0, 0.06, 0), felt)
	_part(head, _sphere(0.09, 16), Vector3(0, 0.12, 0), felt, Vector3.ZERO, Vector3(1.0, 0.3, 1.1))
	_part(head, _cyl(0.107, 0.107, 0.025, 24), Vector3(0, 0.01, 0), _cloth(Color("b22234")))
	_part(head, _sphere(0.016, 10), Vector3(0, 0.01, 0.106), _metal(Color("e5e7eb"), 0.2))

## Dusty: rope coil on the hip.
func _g_lasso_coil() -> void:
	var hips := _attach("hips", Vector3(-0.2, 0.0, 0.02))
	var rope := _mat(Color("c9a46a"), 0.0, 0.85)
	for k in range(3):
		_part(hips, _torus(0.11 - k * 0.006, 0.125 - k * 0.006), Vector3(0, -0.02 * k, 0), rope, Vector3(0, 0, 80))

# ─────────────────────────────────────────────────────── animation ──

func apply_state(state: Dictionary) -> void:
	pose = str(state.get("pose", "Idle"))
	if family == "kalyx": _kalyx_crown(str(state.get("crown", "frost")))
	var st: String = str(state.get("state", ""))
	var charging: bool = pose in ["Charge", "Beam", "Summon", "Cast", "SpecialAttack", "Roar"] or float(state.get("super_charge", 0.0)) > 0.0
	charge = move_toward(charge, 1.0 if charging else 0.0, 0.08)
	var vx: float = absf(float(state.get("vx", 0.0))) + absf(float(state.get("walk_v", 0.0)))
	var dashing: bool = pose in ["Dash", "DashAttack", "Rush"] or vx > 7.5
	dash = move_toward(dash, 1.0 if dashing else 0.0, 0.15)
	run_speed = lerpf(run_speed, clampf(vx / 8.0, 0.0, 1.0), 0.15)
	if react.has("counter_star"):
		var on: bool = pose in ["Counter", "Parry"] or st == "Counter"
		var s: float = move_toward((react["counter_star"] as Node3D).scale.x, 1.0 if on else 0.01, 0.12)
		(react["counter_star"] as Node3D).scale = Vector3.ONE * s
	if particles.has("trail"):
		(particles["trail"] as CPUParticles3D).emitting = dash > 0.5
	if not drill_bits.is_empty():
		drilling = st == "Attack" or pose in ["Attack", "Kick", "HeavyPunch", "Barrage", "Spin", "Slam", "SpecialAttack", "DashAttack"]
		for sp in drill_sparks: (sp as CPUParticles3D).emitting = drilling
	if react.has("eagle"):
		eagle_on = float(state.get("eagle", 0.0)) > 0.0
		eagle_facing = 1 if int(state.get("facing", 1)) >= 0 else -1

func flash() -> void:
	hit_flash = 1.0

func _process(delta: float) -> void:
	t += delta
	hit_flash = move_toward(hit_flash, 0.0, delta * 5.0)
	var speed: float = 1.0 + charge * 3.0 + dash * 1.5
	for sp in spinners:
		(sp[0] as Node3D).rotate(sp[1], float(sp[2]) * delta * speed)
	for sw in sways:
		var node: Node3D = sw[0]
		if not is_instance_valid(node): continue
		var base: Vector3 = sw[1]
		var amp: float = float(sw[2]) * (1.0 + run_speed * 1.2)
		node.rotation_degrees = Vector3(base.x + sin(t * float(sw[3]) + float(sw[4])) * amp + run_speed * float(sw[5]), base.y, base.z + cos(t * float(sw[3]) * 0.7 + float(sw[4])) * amp * 0.3)
	for g in glows:
		var m: StandardMaterial3D = g[0]
		m.emission_energy_multiplier = float(g[1]) * (1.0 + charge * 1.2 + hit_flash * 1.5 + sin(t * 4.0) * 0.06)
	for bm in body_mats:
		(bm as ShaderMaterial).set_shader_parameter("flash", hit_flash)
		(bm as ShaderMaterial).set_shader_parameter("charge", charge)
	if react.has("charge_orb"):
		var orb: Node3D = react["charge_orb"]
		orb.scale = Vector3.ONE * maxf(0.01, charge * (1.0 + sin(t * 18.0) * 0.08))
		orb.visible = charge > 0.02
	for side in ["left_foot_jet", "right_foot_jet"]:
		if react.has(side):
			(react[side] as Node3D).scale = Vector3.ONE * (0.3 + dash * 1.2 + sin(t * 40.0) * 0.05 * dash)
	for side in ["left_hand_fist", "right_hand_fist"]:
		if react.has(side):
			(react[side] as Node3D).scale = Vector3.ONE * (1.0 + charge * 0.18)
	if react.has("halo"):
		(react["halo"] as Node3D).scale = Vector3.ONE * (1.0 + charge * 0.25)
	for bit in drill_bits:
		(bit as Node3D).rotate_y(delta * (75.0 if drilling else 5.0))
	if react.has("eagle"):
		var eg: Node3D = react["eagle"]
		var s: float = move_toward(eg.scale.x, 1.3 if eagle_on else 0.01, delta * (2.8 if eagle_on else 3.5))
		eg.scale = Vector3.ONE * s
		eg.visible = s > 0.02
		# Turned a little toward the camera so both wings read in the side view.
		eg.rotation.y = lerp_angle(eg.rotation.y, deg_to_rad(58.0 * eagle_facing), minf(1.0, delta * 6.0))
		eg.position.y = sin(t * 2.1) * 0.06
		if particles.has("eagle_feathers"): (particles["eagle_feathers"] as CPUParticles3D).emitting = eg.visible
		for w in eagle_wings:
			var side: float = float(w[1])
			var inner: bool = absf(side) > 0.75
			(w[0] as Node3D).rotation.z = signf(side) * (0.5 if inner else 0.3) * sin(t * 4.4 - (0.0 if inner else 0.7))
	if particles.has("aura"):
		(particles["aura"] as CPUParticles3D).speed_scale = 1.0 + charge * 1.5
	arc_timer -= delta
	if arc_timer <= 0.0 and not arcs.is_empty():
		arc_timer = 0.05
		for a in arcs: _draw_arc(a)

## Jagged lightning ribbons around a limb, redrawn 20 times per second.
func _draw_arc(a: Array) -> void:
	var im: ImmediateMesh = a[0]
	var from: Vector3 = a[1]
	var to: Vector3 = a[2]
	im.clear_surfaces()
	var count: int = int(a[3]) + int(charge * 3.0)
	for k in range(count):
		im.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		var steps := 8
		var w := 0.007 + charge * 0.004
		for i in range(steps + 1):
			var f := float(i) / steps
			var p := from.lerp(to, f)
			var jitter := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * (0.06 * sin(f * PI) + 0.01)
			p += jitter
			im.surface_add_vertex(p + Vector3(0, w, 0))
			im.surface_add_vertex(p - Vector3(0, w, 0))
		im.surface_end()

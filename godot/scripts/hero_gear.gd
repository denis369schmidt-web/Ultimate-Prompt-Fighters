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

# ─────────────────────────────────────────────────────── animation ──

func apply_state(state: Dictionary) -> void:
	pose = str(state.get("pose", "Idle"))
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

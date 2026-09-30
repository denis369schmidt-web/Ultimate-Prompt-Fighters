extends Node3D
## Own look of the house heroes (kairo … lepora): every hero gets an outfit recolor
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
	nt.width = 256
	nt.height = 256
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

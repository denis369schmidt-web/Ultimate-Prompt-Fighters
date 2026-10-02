extends Node3D
## Procedural bodies of the angel bosses (bosses.gd), built from smooth primitives with
## generated textures (painted feathers, fibrous irises, veined eyeballs, hammered gold,
## folded cloth) and animated here: flapping wings, spinning wheels, eyes that follow the
## camera, burning halos and embers.
##   seraph – one giant eye inside six fiery wings full of smaller eyes
##   ophan  – three interlocking golden wheels covered in eyes around a core of light
##   cherub – robed body with four faces (human, lion, ox, eagle), four wings, flaming sword
##   humanoid kit (HUMANOIDS) – the other angel choirs and the demon princes
##   beelzebub – giant fly, leviathan – sea dragon, ahriman – colossal stone mask
## The origin is the lower edge of the hurtbox; the body rises to about 3.5 m.

var kind := "seraph"
var t := 0.0
var charge := 0.0             # 0..1 glow while an attack winds up
var hit_flash := 0.0
var look_at_pos := Vector3(0, 1, 6)
var eyes: Array = []          # [node] – turned towards look_at_pos
var wings: Array = []         # [node, base_rotation, phase, amplitude]
var spinners: Array = []      # [node, axis, speed]
var glows: Array = []         # [material, base_energy]
var fire: CPUParticles3D

## Generated textures are shared by all bosses (built once).
static var _tex: Dictionary = {}

static func build(boss_kind: String) -> Node3D:
	var m = load("res://scripts/boss_models.gd").new()
	m.kind = boss_kind
	m._build()
	return m

func _build() -> void:
	match kind:
		"seraph": _build_seraph()
		"ophan": _build_ophan()
		"cherub": _build_cherub()
		"beelzebub": _build_fly()
		"leviathan": _build_dragon()
		"ahriman": _build_mask()
		_: _build_humanoid(HUMANOIDS.get(kind, HUMANOIDS["angelus"]))
	_embers(load("res://scripts/bosses.gd").data(kind).get("color", Color("ff8a1f")))

# ─────────────────────────────────────────────────────────── textures ──

static func _noise_tex(key: String, freq: float, normal: bool, ramp: Array = [], size: int = 512, bump: float = 6.0) -> Texture2D:
	if _tex.has(key): return _tex[key]
	var n := FastNoiseLite.new()
	n.seed = hash(key) & 0xffff
	n.frequency = freq
	n.fractal_octaves = 5
	var nt := NoiseTexture2D.new()
	# Desktop: twice the resolution for crisp close-ups; phones keep the base size.
	var res: int = size if load("res://scripts/platform.gd").low_graphics() else mini(size * 2, 2048)
	nt.width = res
	nt.height = res
	nt.seamless = true
	nt.noise = n
	nt.generate_mipmaps = true
	if normal:
		nt.as_normal_map = true
		nt.bump_strength = bump
	elif not ramp.is_empty():
		var g := Gradient.new()
		g.set_color(0, ramp[0])
		g.set_color(1, ramp[1])
		nt.color_ramp = g
	_tex[key] = nt
	return nt

## Feather: central shaft, angled barbs, soft ragged edge, dark root → pale → burning tip.
static func _feather_tex() -> Texture2D:
	if _tex.has("feather"): return _tex["feather"]
	var w := 96
	var h := 384
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 77
	for y in range(h):
		var v: float = float(y) / h                       # 0 = tip, 1 = root
		var half: float = (0.5 - 0.42 * pow(absf(v - 0.45) / 0.55, 2.0)) * w * (0.35 if v > 0.92 else 1.0)
		for x in range(w):
			var dx: float = absf(x - w * 0.5)
			var a := 0.0
			var col := Color(0.86, 0.8, 0.7)
			if dx < 1.6:
				col = Color(0.95, 0.9, 0.8)
				a = 1.0
			elif dx < half:
				# Barbs run diagonally away from the shaft; gaps between them.
				var barb: float = fmod(y + dx * 0.9 + (7.0 if x < w * 0.5 else 0.0), 5.0)
				var edge: float = clampf((half - dx) / 5.0, 0.0, 1.0)
				a = edge * (0.55 + 0.45 * smoothstep(0.0, 1.5, barb))
				if rng.randf() < 0.02 * (1.0 - v): a *= 0.3   # ragged
				var shade: float = 0.75 + 0.25 * (1.0 - dx / maxf(1.0, half))
				col = Color(0.84, 0.78, 0.68) * shade
			if v > 0.6: col = col.lerp(Color(0.22, 0.17, 0.14), (v - 0.6) / 0.4 * 0.8)
			col.a = a
			img.set_pixel(x, y, col)
	img.generate_mipmaps()
	var tex := ImageTexture.create_from_image(img)
	_tex["feather"] = tex
	return tex

## Iris: dark pupil, radial fibres, bright collarette, dark limbal ring, transparent outside.
static func _iris_tex(key: String, iris: Color) -> Texture2D:
	if _tex.has(key): return _tex[key]
	var s := 256
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	var n := FastNoiseLite.new()
	n.seed = hash(key) & 0xffff
	n.frequency = 0.05
	for y in range(s):
		for x in range(s):
			var p := Vector2(x - s * 0.5, y - s * 0.5) / (s * 0.5)
			var r: float = p.length()
			var ang: float = atan2(p.y, p.x)
			var c := Color(0, 0, 0, 0)
			if r < 0.3:
				c = Color(0.01, 0.0, 0.0, 1.0)
			elif r < 1.0:
				var fibre: float = 0.5 + 0.5 * n.get_noise_2d(ang * 60.0, r * 6.0)
				c = iris.darkened(0.55).lerp(iris.lightened(0.35), fibre)
				if r < 0.42: c = c.lerp(iris.lightened(0.6), 0.5)          # collarette
				if r > 0.86: c = c.lerp(Color(0.05, 0.02, 0.01), (r - 0.86) / 0.14)  # limbal ring
				c.a = 1.0
			img.set_pixel(x, y, c)
	img.generate_mipmaps()
	var tex := ImageTexture.create_from_image(img)
	_tex[key] = tex
	return tex

## Eyeball: ivory with red veins creeping in from the back.
static func _sclera_tex() -> Texture2D:
	if _tex.has("sclera"): return _tex["sclera"]
	var s := 512
	var img := Image.create(s, s, false, Image.FORMAT_RGB8)
	img.fill(Color(0.86, 0.8, 0.72))
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for v in range(70):
		var p := Vector2(rng.randf() * s, s * (0.62 + rng.randf() * 0.38))
		var dir := Vector2(rng.randf_range(-0.4, 0.4), -1.0).normalized()
		var width: float = rng.randf_range(1.0, 2.6)
		for step in range(rng.randi_range(60, 160)):
			dir = dir.rotated(rng.randf_range(-0.35, 0.35))
			p += dir * 1.5
			var col := Color(0.55, 0.08, 0.06).lerp(Color(0.86, 0.8, 0.72), step / 180.0)
			for ox in range(-int(width), int(width) + 1):
				var px := int(p.x + ox) % s
				var py := clampi(int(p.y), 0, s - 1)
				img.set_pixel(px if px >= 0 else px + s, py, col)
			width = maxf(0.6, width * 0.992)
	img.generate_mipmaps()
	var tex := ImageTexture.create_from_image(img)
	_tex["sclera"] = tex
	return tex

# ─────────────────────────────────────────────────────────── materials ──

func _mat(color: Color, metal: float = 0.0, rough: float = 0.6) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metal
	m.roughness = rough
	return m

func _gold(tint: Color = Color("d4a93a")) -> StandardMaterial3D:
	var m := _mat(tint, 1.0, 0.32)
	m.normal_enabled = true
	m.normal_texture = _noise_tex("hammered", 0.035, true, [], 512, 5.0)
	m.normal_scale = 0.7
	m.roughness_texture = _noise_tex("gold_rough", 0.02, false, [Color(0.2, 0.2, 0.2), Color(0.55, 0.55, 0.55)])
	m.uv1_scale = Vector3(3, 3, 3)
	return m

func _cloth(tint: Color) -> StandardMaterial3D:
	var m := _mat(Color.WHITE, 0.0, 0.85)
	m.albedo_texture = _noise_tex("cloth_%s" % tint.to_html(), 0.012, false, [tint.darkened(0.35), tint])
	m.normal_enabled = true
	m.normal_texture = _noise_tex("folds", 0.01, true, [], 512, 10.0)
	m.uv1_scale = Vector3(1.0, 4.0, 1.0)   # stretched noise reads as vertical folds
	return m

func _skin(tint: Color) -> StandardMaterial3D:
	var m := _mat(Color.WHITE, 0.0, 0.55)
	m.albedo_texture = _noise_tex("skin_%s" % tint.to_html(), 0.04, false, [tint.darkened(0.2), tint.lightened(0.08)])
	m.normal_enabled = true
	m.normal_texture = _noise_tex("pores", 0.12, true, [], 256, 2.0)
	m.normal_scale = 0.4
	m.rim_enabled = true
	m.rim = 0.3
	return m

func _glow_mat(color: Color, energy: float = 3.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy
	glows.append([m, energy])
	return m

func _feather_mat(tip: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = _feather_tex()
	m.albedo_color = Color(0.78, 0.7, 0.6)   # warm ivory, never blown out to white
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	m.alpha_scissor_threshold = 0.35
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	m.roughness = 0.8
	m.emission_enabled = true
	m.emission_texture = _feather_tex()
	m.emission = tip
	m.emission_energy_multiplier = 0.15
	m.rim_enabled = true
	m.rim = 0.25
	m.rim_tint = 0.9
	glows.append([m, 0.15])
	return m

func _part(parent: Node3D, mesh: Mesh, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	mi.scale = scl
	parent.add_child(mi)
	return mi

func _sphere(parent: Node3D, r: float, pos: Vector3, mat: Material, scl: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 48
	s.rings = 24
	return _part(parent, s, pos, mat, Vector3.ZERO, scl)

func _torus(inner: float, outer: float) -> TorusMesh:
	var tm := TorusMesh.new()
	tm.inner_radius = inner
	tm.outer_radius = outer
	tm.rings = 96
	tm.ring_segments = 20
	return tm

func _cyl(top: float, bottom: float, h: float) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = top
	c.bottom_radius = bottom
	c.height = h
	c.radial_segments = 40
	return c

## An eye looking along +Z: veined eyeball, textured glowing iris, wet highlight shell.
func _eye(parent: Node3D, r: float, pos: Vector3, iris: Color, track: bool = true) -> Node3D:
	var e := Node3D.new()
	e.position = pos
	parent.add_child(e)
	var sclera := _mat(Color(0.82, 0.78, 0.74), 0.0, 0.18)
	sclera.albedo_texture = _sclera_tex()
	sclera.clearcoat_enabled = true
	sclera.clearcoat = 0.8
	_sphere(e, r, Vector3.ZERO, sclera)
	var irm := StandardMaterial3D.new()
	irm.albedo_texture = _iris_tex("iris_%s" % iris.to_html(), iris)
	irm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	irm.emission_enabled = true
	irm.emission_texture = irm.albedo_texture
	irm.emission_energy_multiplier = 1.8
	irm.roughness = 0.1
	glows.append([irm, 1.8])
	var q := QuadMesh.new()
	q.size = Vector2(r * 1.3, r * 1.3)
	_part(e, q, Vector3(0, 0, r * 0.93), irm)
	# Clear cornea shell over the iris for a wet highlight.
	var cornea := _mat(Color(1, 1, 1, 0.12), 0.0, 0.02)
	cornea.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cornea.metallic_specular = 1.0
	_sphere(e, r * 0.55, Vector3(0, 0, r * 0.62), cornea, Vector3(1, 1, 0.55))
	var lid := _torus(r * 0.9, r * 1.14)
	_part(e, lid, Vector3(0, 0, r * 0.3), _skin(Color(0.35, 0.18, 0.14)), Vector3(90, 0, 0))
	if track: eyes.append(e)
	return e

## A wing: a fan of painted feathers in two layers, burning at the tips, eyes scattered over it.
func _wing(parent: Node3D, root: Vector3, base_rot: Vector3, length: float, feathers: int, tip: Color, eye_count: int, amp: float, phase: float) -> Node3D:
	var w := Node3D.new()
	w.position = root
	w.rotation_degrees = base_rot
	parent.add_child(w)
	var fmat := _feather_mat(tip)
	for layer in range(2):
		var n: int = feathers if layer == 0 else int(feathers * 0.7)
		var scale_l: float = 1.0 if layer == 0 else 0.62
		for k in range(n):
			var a: float = lerpf(-55.0, 55.0, k / float(maxi(1, n - 1)))
			var len_k: float = length * scale_l * (0.7 + 0.3 * (1.0 - absf(a) / 60.0))
			var f := Node3D.new()
			f.rotation_degrees = Vector3(0, 0, a)
			f.position = Vector3(0, 0, 0.02 * layer)
			w.add_child(f)
			var q := QuadMesh.new()
			q.size = Vector2(len_k * 0.2, len_k)
			var fi := _part(f, q, Vector3(0, len_k * 0.5, 0), fmat, Vector3(0, (k % 2) * 8.0 - 4.0, 0))
			fi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			# Burning tip.
			if layer == 0:
				var ember := SphereMesh.new()
				ember.radius = 0.05
				ember.height = 0.1
				_part(f, ember, Vector3(0, len_k * 0.98, 0.02), _glow_mat(tip, 3.0), Vector3.ZERO, Vector3(1, 2.2, 1))
	for k in range(eye_count):
		var ea: float = deg_to_rad(lerpf(-35.0, 35.0, (k + 0.5) / float(eye_count)))
		var d: float = length * (0.42 + 0.22 * (k % 2))
		_eye(w, 0.11 + 0.04 * (k % 2), Vector3(-sin(ea) * d, cos(ea) * d, 0.12), tip, false)
	wings.append([w, base_rot, phase, amp])
	return w

## Round glowing embers drifting up (no square sprites).
func _embers(color: Color) -> void:
	fire = CPUParticles3D.new()
	fire.amount = 60
	fire.lifetime = 1.4
	fire.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	fire.emission_sphere_radius = 1.6
	fire.position = Vector3(0, 1.8, -0.2)
	fire.direction = Vector3(0, 1, 0)
	fire.spread = 35.0
	fire.gravity = Vector3(0, 1.2, 0)
	fire.initial_velocity_min = 0.3
	fire.initial_velocity_max = 1.1
	fire.scale_amount_min = 0.3
	fire.scale_amount_max = 1.0
	var sm := SphereMesh.new()
	sm.radius = 0.04
	sm.height = 0.08
	sm.radial_segments = 8
	sm.rings = 4
	var em := _glow_mat(color, 4.0)
	em.vertex_color_use_as_albedo = true
	em.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.material = em
	fire.mesh = sm
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1, 1, 1, 1))
	ramp.set_color(1, Color(1, 1, 1, 0))
	fire.color_ramp = ramp
	add_child(fire)

# ─────────────────────────────────────────────────────────── seraph ──

func _build_seraph() -> void:
	var core := Node3D.new()
	core.position = Vector3(0, 1.9, 0)
	add_child(core)
	# Burning halos behind everything.
	var hn := _part(core, _torus(2.3, 2.42), Vector3(0, 0, -0.6), _glow_mat(Color("ff5a1f"), 3.0), Vector3(90, 0, 0))
	spinners.append([hn, Vector3(0, 1, 0), 0.4])
	var hn2 := _part(core, _torus(1.92, 1.97), Vector3(0, 0, -0.5), _glow_mat(Color("ffd24a"), 2.5), Vector3(90, 0, 0))
	spinners.append([hn2, Vector3(0, 1, 0), -0.7])
	# Six wings: two raised, two spread, two lowered – feathers all around the eye.
	for side in [-1.0, 1.0]:
		_wing(core, Vector3(side * 0.3, 0.3, -0.2), Vector3(0, 0, -side * 25.0), 2.2, 16, Color("ff6a1f"), 3, 9.0, 0.0)
		_wing(core, Vector3(side * 0.4, 0.0, -0.1), Vector3(0, 0, -side * 90.0), 2.4, 18, Color("ffae3a"), 3, 12.0, 1.2)
		_wing(core, Vector3(side * 0.3, -0.3, 0.0), Vector3(0, 0, -side * 150.0), 2.0, 15, Color("ff3b1f"), 2, 8.0, 2.4)
	# Inner crown of covering feathers around the eye.
	var fm := _feather_mat(Color("ffae3a"))
	for k in range(22):
		var a: float = TAU * k / 22.0
		var q := QuadMesh.new()
		q.size = Vector2(0.32, 1.0)
		_part(core, q, Vector3(cos(a) * 1.15, sin(a) * 1.15, 0.28), fm, Vector3(0, 0, rad_to_deg(a) - 90.0))
	_eye(core, 0.85, Vector3(0, 0, 0.35), Color("ff2a1a"))

# ─────────────────────────────────────────────────────────── ophan ──

func _build_ophan() -> void:
	var core := Node3D.new()
	core.position = Vector3(0, 1.8, 0)
	add_child(core)
	var gold := _gold()
	var bronze := _gold(Color("9a6a2f"))
	_sphere(core, 0.45, Vector3.ZERO, _glow_mat(Color("fff3b0"), 4.0))
	var light := OmniLight3D.new()
	light.light_color = Color("ffd98a")
	light.light_energy = 1.8
	light.omni_range = 7.0
	core.add_child(light)
	var specs := [[1.75, Vector3(0, 0, 0), Vector3(0, 1, 0), 0.55], [1.55, Vector3(90, 0, 0), Vector3(1, 0, 0), -0.7],
		[1.35, Vector3(0, 0, 90), Vector3(0, 0, 1), 0.9]]
	for spec in specs:
		var ring := Node3D.new()
		ring.rotation_degrees = spec[1]
		core.add_child(ring)
		_part(ring, _torus(float(spec[0]) - 0.14, float(spec[0]) + 0.14), Vector3.ZERO, gold)
		_part(ring, _torus(float(spec[0]) + 0.16, float(spec[0]) + 0.21), Vector3.ZERO, bronze)
		_part(ring, _torus(float(spec[0]) - 0.21, float(spec[0]) - 0.16), Vector3.ZERO, bronze)
		var n: int = 14
		for k in range(n):
			var a: float = TAU * k / n
			var holder := Node3D.new()
			holder.position = Vector3(cos(a) * float(spec[0]), 0, sin(a) * float(spec[0]))
			holder.rotation = Vector3(0, -a + PI * 0.5, 0)
			ring.add_child(holder)
			_eye(holder, 0.13, Vector3(0, 0, 0.1), Color("ffcc33"), false)
		spinners.append([ring, spec[2], spec[3]])
	for k in range(8):
		var a: float = TAU * k / 8.0
		var sn := _part(core, _cyl(0.025, 0.025, 2.4), Vector3.ZERO, _glow_mat(Color("ffe08a"), 2.5), Vector3(0, 0, rad_to_deg(a)))
		spinners.append([sn, Vector3(0, 0, 1), 0.25])
	_eye(core, 0.3, Vector3(0, 0, 0.42), Color("ff8a1f"))

# ─────────────────────────────────────────────────────────── cherub ──

func _build_cherub() -> void:
	var body := Node3D.new()
	body.position = Vector3(0, 0.2, 0)
	add_child(body)
	var robe := _cloth(Color(0.86, 0.8, 0.68))
	var bronze := _gold(Color("a8742f"))
	_part(body, _cyl(0.45, 0.8, 2.0), Vector3(0, 1.1, 0), robe)
	_part(body, _cyl(0.5, 0.46, 0.6), Vector3(0, 2.0, 0), _cloth(Color(0.7, 0.2, 0.12)))
	for side in [-1.0, 1.0]:
		_part(body, _cyl(0.12, 0.16, 0.5), Vector3(side * 0.25, 0.0, 0.1), bronze)
		_sphere(body, 0.17, Vector3(side * 0.25, -0.28, 0.18), bronze, Vector3(1, 0.6, 1.4))
	_part(body, _torus(0.47, 0.55), Vector3(0, 1.5, 0), bronze)
	# Four faces around one head: human (front), lion (right), ox (left), eagle (back).
	var head := Node3D.new()
	head.position = Vector3(0, 2.55, 0)
	body.add_child(head)
	spinners.append([head, Vector3(0, 1, 0), 0.35])
	_sphere(head, 0.34, Vector3(0, 0, 0.18), _skin(Color(0.86, 0.7, 0.58)))
	_eye(head, 0.06, Vector3(-0.11, 0.06, 0.48), Color("ffae3a"), false)
	_eye(head, 0.06, Vector3(0.11, 0.06, 0.48), Color("ffae3a"), false)
	_sphere(head, 0.32, Vector3(0.22, 0, 0), _skin(Color("b07a2e")))
	var mane := _cloth(Color("7a4a1a"))
	for k in range(16):
		var a: float = TAU * k / 16.0
		_part(head, _cyl(0.0, 0.07, 0.32), Vector3(0.3, sin(a) * 0.3, cos(a) * 0.3), mane, Vector3(rad_to_deg(a), 0, -90))
	_sphere(head, 0.3, Vector3(-0.22, 0, 0), _skin(Color("4a3a2e")))
	for side in [-1.0, 1.0]:
		_part(head, _cyl(0.0, 0.06, 0.45), Vector3(-0.3, 0.25, side * 0.18), _mat(Color(0.9, 0.86, 0.78), 0.0, 0.35), Vector3(side * 40.0, 0, 30))
	_sphere(head, 0.28, Vector3(0, 0.02, -0.22), _skin(Color("efe7da")))
	_part(head, _cyl(0.0, 0.08, 0.3), Vector3(0, -0.02, -0.52), _gold(Color("d9a520")), Vector3(-90, 0, 0))
	_part(head, _torus(0.42, 0.5), Vector3(0, 0.5, 0), _glow_mat(Color("ffd24a"), 2.5))
	# Four wings: two raised over the head, two folded around the body.
	for side in [-1.0, 1.0]:
		_wing(body, Vector3(side * 0.35, 2.0, -0.3), Vector3(0, 0, -side * 30.0), 2.3, 16, Color("ffae3a"), 2, 10.0, 0.0)
		_wing(body, Vector3(side * 0.4, 1.3, -0.25), Vector3(0, side * 20.0, -side * 150.0), 1.6, 12, Color("ff6a1f"), 1, 5.0, 1.5)
	# Flaming sword that turns every way.
	var arm := Node3D.new()
	arm.position = Vector3(0.75, 1.6, 0.3)
	body.add_child(arm)
	_part(arm, _cyl(0.05, 0.05, 0.4), Vector3.ZERO, bronze)
	var guard := BoxMesh.new()
	guard.size = Vector3(0.5, 0.07, 0.1)
	_part(arm, guard, Vector3(0, 0.22, 0), bronze)
	var blade := PrismMesh.new()
	blade.size = Vector3(0.16, 2.5, 0.04)
	_part(arm, blade, Vector3(0, 1.5, 0), _glow_mat(Color("ff7a1a"), 4.0))
	var flame := _part(arm, _cyl(0.0, 0.2, 2.6), Vector3(0, 1.5, 0), _glow_mat(Color("ffcf4a"), 1.5))
	flame.transparency = 0.6
	wings.append([arm, Vector3(0, 0, -25), 0.7, 25.0])

# ─────────────────────────────────────────────────────── humanoid kit ──

## Angels and demon princes built from one parametric body. Keys: skin, robe (cloth color),
## armor (metal color), build (slim|normal|muscular|fat), head (human|woman|goat|demon|hag|king),
## hair, horns (length), halo, crown, wings (feather|bat|""), wing_tip, arms (down|forward|out|up_down),
## weapon (sword|flame_sword|spear|cross_staff|scepter|cane|""), left (wreath|scroll|rings|sack|""),
## tail, hooves, owls, chest (sits on a chest), pentagram, torch, aura.
const HUMANOIDS := {
	"angelus": {"skin": Color(0.9, 0.78, 0.66), "robe": Color(0.86, 0.9, 0.95), "head": "human", "hair": Color("d9a441"), "halo": true,
		"wings": "feather", "wing_tip": Color("bfe3ff"), "arms": "forward", "left": "wreath", "build": "slim"},
	"michael": {"skin": Color(0.86, 0.72, 0.6), "armor": Color("d4a93a"), "head": "human", "hair": Color("3b2a1a"), "halo": true,
		"wings": "feather", "wing_tip": Color("ffcf4a"), "arms": "up_down", "weapon": "flame_sword", "build": "muscular"},
	"principatus": {"skin": Color(0.9, 0.78, 0.66), "robe": Color(0.92, 0.88, 0.82), "sash": Color("b91c1c"), "head": "woman", "hair": Color("8a5a2b"),
		"halo": true, "wings": "feather", "wing_tip": Color("ff6b8a"), "arms": "out", "left": "wreath", "weapon": "wreath", "build": "slim"},
	"potestas": {"skin": Color(0.84, 0.7, 0.58), "armor": Color("b8bcc4"), "head": "human", "hair": Color("5a3a1a"), "halo": true,
		"wings": "feather", "wing_tip": Color("ffa94d"), "arms": "forward", "weapon": "cross_staff", "build": "muscular"},
	"virtus": {"skin": Color(0.9, 0.78, 0.66), "robe": Color(0.72, 0.8, 0.9), "head": "woman", "hair": Color("c9a227"), "halo": true, "crown": true,
		"wings": "feather", "wing_tip": Color("9be7ff"), "arms": "forward", "left": "scroll", "weapon": "scepter", "build": "slim"},
	"dominatio": {"skin": Color(0.86, 0.74, 0.62), "robe": Color(0.82, 0.76, 0.9), "head": "human", "hair": Color("e8d8b0"), "halo": true,
		"wings": "feather", "wing_tip": Color("e9d5ff"), "arms": "forward", "weapon": "cross_staff", "build": "normal"},
	"lilith": {"skin": Color(0.62, 0.58, 0.56), "head": "woman", "hair": Color("1c1917"), "crown": true, "wings": "feather", "wing_tip": Color("be185d"),
		"arms": "up_down", "left": "rings", "weapon": "rings", "owls": true, "hooves": true, "build": "slim", "robe_short": Color("3f0d1d")},
	"asmodeus": {"skin": Color(0.74, 0.6, 0.52), "robe": Color(0.78, 0.74, 0.66), "head": "hag", "hair": Color(0.92, 0.9, 0.86), "wings": "",
		"arms": "forward", "weapon": "cane", "hooves": true, "tail": true, "build": "slim"},
	"mammon": {"skin": Color(0.7, 0.62, 0.52), "robe": Color(0.35, 0.26, 0.18), "head": "hag", "hair": Color(0.55, 0.52, 0.48), "cap": true,
		"wings": "", "arms": "hug", "left": "sack", "chest": true, "build": "fat"},
	"baphomet": {"skin": Color(0.32, 0.28, 0.26), "robe_short": Color(0.25, 0.1, 0.06), "head": "goat", "horns": 1.0, "wings": "feather",
		"wing_tip": Color("f97316"), "arms": "up_down", "hooves": true, "pentagram": true, "torch": true, "build": "muscular"},
	"belphegor": {"skin": Color(0.46, 0.36, 0.3), "head": "demon", "horns": 0.7, "beard": true, "wings": "", "arms": "down", "chest": true,
		"tail": true, "hooves": true, "build": "muscular", "robe_short": Color(0.2, 0.15, 0.1)},
	"bel_marduk": {"skin": Color(0.72, 0.58, 0.44), "robe": Color(0.55, 0.42, 0.25), "head": "king", "wings": "feather", "wing_tip": Color("dc2626"),
		"four_wings": true, "arms": "forward", "weapon": "spear", "build": "muscular"},
	"lucifer": {"skin": Color(0.72, 0.78, 0.86), "head": "human", "hair": Color("111827"), "horns": 0.45, "wings": "bat", "wing_tip": Color("1e3a8a"),
		"arms": "out", "tail": true, "build": "muscular", "robe_short": Color(0.1, 0.1, 0.14), "ice": true},
}

func _build_humanoid(o: Dictionary) -> void:
	var body := Node3D.new()
	add_child(body)
	var skin_m := _skin(o.get("skin", Color(0.85, 0.7, 0.58)))
	var wide: float = {"slim": 0.85, "normal": 1.0, "muscular": 1.22, "fat": 1.5}[o.get("build", "normal")]
	var sit: bool = o.get("chest", false)
	var hip: float = 0.95 if sit else 1.15
	var metal: Material = _gold(o.armor) if o.has("armor") else null
	var robe: Material = _cloth(o.robe) if o.has("robe") else null
	# Legs: long robe, or legs with hooves / armored boots.
	if sit:
		var chest_m := _gold(Color("8a6a2a")) if o.get("build", "") == "fat" else _cloth(Color(0.18, 0.14, 0.12))
		var box := BoxMesh.new()
		box.size = Vector3(1.5, 0.75, 0.9)
		_part(body, box, Vector3(0, 0.38, -0.1), _cloth(Color(0.3, 0.2, 0.12)) if o.get("build", "") == "fat" else chest_m)
		var lid := BoxMesh.new()
		lid.size = Vector3(1.56, 0.12, 0.96)
		_part(body, lid, Vector3(0, 0.78, -0.1), _gold(Color("b8912f")))
		for side in [-1.0, 1.0]:
			var thigh := _part(body, _cyl(0.14 * wide, 0.17 * wide, 0.6), Vector3(side * 0.24, hip, 0.25), robe if robe else skin_m, Vector3(90, 0, 0))
			thigh.name = "thigh"
			_part(body, _cyl(0.12 * wide, 0.14 * wide, 0.7), Vector3(side * 0.26, hip - 0.4, 0.55), robe if robe else skin_m)
			_foot(body, Vector3(side * 0.26, 0.08, 0.62), o)
	elif robe and not o.has("robe_short"):
		_part(body, _cyl(0.4 * wide, 0.72 * wide, 1.5), Vector3(0, 0.78, 0), robe)
		if o.has("sash"):
			_part(body, _torus(0.44 * wide, 0.5 * wide), Vector3(0, 1.3, 0), _cloth(o.sash), Vector3(0, 0, 18))
	else:
		var leg_m: Material = metal if metal else skin_m
		for side in [-1.0, 1.0]:
			_part(body, _cyl(0.15 * wide, 0.19 * wide, 0.62), Vector3(side * 0.22, hip - 0.3, 0), leg_m)
			_part(body, _cyl(0.11 * wide, 0.15 * wide, 0.6), Vector3(side * 0.24, hip - 0.88, 0.03), leg_m)
			_foot(body, Vector3(side * 0.24, 0.06, 0.08), o)
		if o.has("robe_short"):
			_part(body, _cyl(0.36 * wide, 0.5 * wide, 0.55), Vector3(0, hip - 0.1, 0), _cloth(o.robe_short))
	# Torso.
	var torso_m: Material = metal if metal else (robe if robe else skin_m)
	_sphere(body, 0.36, Vector3(0, hip + 0.55, 0), torso_m, Vector3(1.15 * wide, 1.45, 0.8 * wide))
	_sphere(body, 0.3, Vector3(0, hip + 0.1, 0), torso_m, Vector3(1.0 * wide, 0.9, 0.8 * wide))
	if o.get("build", "") == "fat":
		_sphere(body, 0.42, Vector3(0, hip + 0.25, 0.18), robe if robe else skin_m, Vector3(1.2, 1.0, 1.0))
	if o.get("build", "") == "muscular" and not metal:
		for side in [-1.0, 1.0]:
			_sphere(body, 0.17, Vector3(side * 0.17, hip + 0.72, 0.22), skin_m, Vector3(1.2, 0.8, 0.6))
	if metal:
		_part(body, _torus(0.42 * wide, 0.5 * wide), Vector3(0, hip + 0.28, 0), _gold(Color("8a6a2a")))
		for side in [-1.0, 1.0]:
			_sphere(body, 0.2, Vector3(side * 0.48 * wide, hip + 0.88, 0), metal, Vector3(1.2, 0.8, 1.1))
	# Arms (static poses).
	var pose: String = o.get("arms", "down")
	for side in [-1.0, 1.0]:
		var sh := Node3D.new()
		sh.position = Vector3(side * 0.47 * wide, hip + 0.86, 0)
		body.add_child(sh)
		var rz: float = side * 14.0
		var rx: float = 0.0
		match pose:
			"forward": rx = -45.0
			"out": rz = side * 80.0
			"hug":
				rx = -70.0
				rz = -side * 25.0
			"up_down": rz = side * (155.0 if side > 0 else 20.0)
		sh.rotation_degrees = Vector3(rx, 0, rz)
		var arm_m: Material = metal if metal else (robe if robe and pose != "out" else skin_m)
		_part(sh, _cyl(0.09 * wide, 0.12 * wide, 0.58), Vector3(0, -0.29, 0), arm_m)
		_part(sh, _cyl(0.075 * wide, 0.095 * wide, 0.55), Vector3(0, -0.84, 0), skin_m if not metal else metal)
		_sphere(sh, 0.09 * wide, Vector3(0, -1.14, 0), skin_m)
		var hand := Node3D.new()
		hand.position = Vector3(0, -1.16, 0)
		sh.add_child(hand)
		var item: String = str(o.get("weapon", "")) if side > 0 else str(o.get("left", ""))
		_hand_item(hand, item, o)
	# Neck and head.
	_part(body, _cyl(0.1 * wide, 0.13 * wide, 0.25), Vector3(0, hip + 1.2, 0), skin_m)
	var head := Node3D.new()
	head.position = Vector3(0, hip + 1.5, 0.02)
	body.add_child(head)
	_head(head, o, skin_m)
	if o.get("halo", false):
		_part(head, _torus(0.34, 0.4), Vector3(0, 0.22, -0.28), _glow_mat(Color("ffe08a"), 3.0), Vector3(90, 0, 0))
	if o.get("crown", false):
		var crown_m := _gold()
		_part(head, _torus(0.2, 0.26), Vector3(0, 0.26, 0), crown_m)
		for k in range(7):
			var a: float = TAU * k / 7.0
			_part(head, _cyl(0.0, 0.045, 0.2), Vector3(cos(a) * 0.23, 0.36, sin(a) * 0.23), crown_m)
	# Wings.
	var tip: Color = o.get("wing_tip", Color("ffae3a"))
	match str(o.get("wings", "")):
		"feather":
			for side in [-1.0, 1.0]:
				_wing(body, Vector3(side * 0.3, hip + 0.95, -0.3), Vector3(0, side * 15.0, -side * 38.0), 2.2, 16, tip, 1, 9.0, 0.0)
				if o.get("four_wings", false):
					_wing(body, Vector3(side * 0.3, hip + 0.5, -0.35), Vector3(0, side * 15.0, -side * 120.0), 1.8, 13, tip, 0, 6.0, 1.3)
		"bat":
			for side in [-1.0, 1.0]:
				_bat_wing(body, Vector3(side * 0.3, hip + 0.95, -0.3), side, 2.8, tip)
	if o.get("tail", false): _tail(body, Vector3(0, hip - 0.05, -0.3), o.get("skin", Color(0.5, 0.3, 0.2)))
	if o.get("owls", false):
		for side in [-1.0, 1.0]: _owl(body, Vector3(side * 0.95, 0.35, 0.2))
	if o.get("ice", false):
		var ice := _mat(Color(0.75, 0.9, 1.0, 0.55), 0.0, 0.05)
		ice.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ice.emission_enabled = true
		ice.emission = Color("7dd3fc")
		ice.emission_energy_multiplier = 0.6
		for k in range(9):
			var a: float = TAU * k / 9.0
			var shard := Node3D.new()
			shard.position = Vector3(0, 1.8, 0)
			body.add_child(shard)
			_part(shard, _cyl(0.0, 0.12, 0.8), Vector3(cos(a) * 1.7, sin(a) * 1.3, -0.2), ice, Vector3(0, 0, rad_to_deg(a) + 90))
			spinners.append([shard, Vector3(0, 0, 1), 0.3])

## Places a Y-axis mesh (cylinder) between two points (works before the node is in the tree).
func _align(node: Node3D, a: Vector3, b: Vector3) -> void:
	var d: Vector3 = b - a
	if d.length() < 0.001: return
	var y: Vector3 = d.normalized()
	var x: Vector3 = y.cross(Vector3(0, 0, 1))
	if x.length() < 0.01: x = y.cross(Vector3(1, 0, 0))
	x = x.normalized()
	node.transform = Transform3D(Basis(x, y, x.cross(y)), (a + b) * 0.5)

func _foot(parent: Node3D, pos: Vector3, o: Dictionary) -> void:
	if o.get("hooves", false):
		_sphere(parent, 0.13, pos, _mat(Color(0.12, 0.1, 0.09), 0.2, 0.4), Vector3(1.0, 0.7, 1.3))
	elif o.has("armor"):
		_sphere(parent, 0.13, pos + Vector3(0, 0, 0.05), _gold(o.armor), Vector3(1.0, 0.6, 1.6))
	else:
		_sphere(parent, 0.11, pos + Vector3(0, 0, 0.05), _skin(o.get("skin", Color(0.8, 0.7, 0.6))), Vector3(1.0, 0.55, 1.7))

func _head(head: Node3D, o: Dictionary, skin_m: Material) -> void:
	var kind_h: String = str(o.get("head", "human"))
	var hair_c: Color = o.get("hair", Color(0.2, 0.15, 0.1))
	var eye_c: Color = Color("ffae3a") if o.get("realm", "") == "" else Color("ffae3a")
	match kind_h:
		"goat":
			var fur := _cloth(o.get("skin", Color(0.3, 0.28, 0.26)))
			_sphere(head, 0.3, Vector3.ZERO, fur, Vector3(0.9, 1.0, 1.0))
			_part(head, _cyl(0.12, 0.2, 0.5), Vector3(0, -0.12, 0.3), fur, Vector3(70, 0, 0))
			for side in [-1.0, 1.0]:
				_sphere(head, 0.05, Vector3(side * 0.13, 0.05, 0.24), _glow_mat(Color("facc15"), 3.0))
				_horn(head, Vector3(side * 0.15, 0.22, -0.05), side, 0.9 * float(o.get("horns", 1.0)))
				_part(head, PrismMesh.new(), Vector3(side * 0.3, 0.05, -0.02), fur, Vector3(0, 0, side * 70), Vector3(0.1, 0.25, 0.05))
			_part(head, _cyl(0.0, 0.1, 0.4), Vector3(0, -0.45, 0.28), _cloth(Color(0.2, 0.18, 0.16)), Vector3(180, 0, 0))
			if o.get("pentagram", false):
				_part(head, _torus(0.05, 0.065), Vector3(0, 0.2, 0.27), _glow_mat(Color("fde047"), 3.0), Vector3(90, 0, 0))
			if o.get("torch", false):
				_part(head, _cyl(0.03, 0.04, 0.35), Vector3(0, 0.45, -0.05), _gold(Color("6b4a1a")))
				_sphere(head, 0.12, Vector3(0, 0.7, -0.05), _glow_mat(Color("ff8a1f"), 4.0), Vector3(0.8, 1.6, 0.8))
		"demon":
			_sphere(head, 0.3, Vector3.ZERO, skin_m, Vector3(1.0, 1.05, 1.0))
			for side in [-1.0, 1.0]:
				_sphere(head, 0.05, Vector3(side * 0.11, 0.05, 0.26), _glow_mat(Color("ff3b1f"), 3.5))
				_horn(head, Vector3(side * 0.16, 0.2, 0.0), side, 0.7 * float(o.get("horns", 0.7)))
				_part(head, PrismMesh.new(), Vector3(side * 0.3, 0.08, 0.0), skin_m, Vector3(0, 0, side * 60), Vector3(0.1, 0.3, 0.05))
			_part(head, _cyl(0.0, 0.07, 0.18), Vector3(0, -0.02, 0.32), skin_m, Vector3(90, 0, 0))
			if o.get("beard", false):
				_part(head, _cyl(0.0, 0.2, 0.55), Vector3(0, -0.4, 0.12), _cloth(Color(0.25, 0.2, 0.16)), Vector3(180, 0, 0))
		"hag":
			_sphere(head, 0.28, Vector3.ZERO, skin_m, Vector3(0.95, 1.1, 1.0))
			_part(head, _cyl(0.0, 0.07, 0.3), Vector3(0, -0.02, 0.33), skin_m, Vector3(80, 0, 0))
			for side in [-1.0, 1.0]:
				_sphere(head, 0.045, Vector3(side * 0.1, 0.07, 0.24), _glow_mat(Color("f472b6") if o.get("hooves", false) else Color("facc15"), 3.0))
			var hair := _cloth(hair_c)
			for k in range(14):
				var a: float = lerpf(-2.4, 2.4, k / 13.0)
				_part(head, _cyl(0.03, 0.01, 0.7), Vector3(sin(a) * 0.25, 0.0, -cos(a) * 0.12 - 0.05), hair, Vector3(-20, 0, rad_to_deg(a) * 0.35))
			if o.get("cap", false):
				_part(head, _cyl(0.0, 0.3, 0.45), Vector3(0, 0.3, -0.02), _cloth(Color(0.3, 0.22, 0.16)), Vector3(-15, 0, 0))
		"king":
			_sphere(head, 0.27, Vector3.ZERO, skin_m)
			var crown_m := _gold(Color("8a6a2a"))
			_part(head, _cyl(0.24, 0.27, 0.5), Vector3(0, 0.35, 0), crown_m)
			for k in range(3):
				_part(head, _torus(0.24, 0.28), Vector3(0, 0.18 + k * 0.16, 0), _gold(Color("d4a93a")))
			var beard := BoxMesh.new()
			beard.size = Vector3(0.36, 0.6, 0.18)
			_part(head, beard, Vector3(0, -0.4, 0.12), _cloth(Color(0.12, 0.1, 0.1)))
			for side in [-1.0, 1.0]:
				_sphere(head, 0.04, Vector3(side * 0.1, 0.05, 0.24), _glow_mat(Color("dc2626"), 3.0))
		_:
			_sphere(head, 0.27, Vector3.ZERO, skin_m, Vector3(0.95, 1.08, 1.0))
			for side in [-1.0, 1.0]:
				_sphere(head, 0.04, Vector3(side * 0.095, 0.05, 0.23), _glow_mat(Color("7dd3fc") if o.has("horns") else Color("ffe08a"), 2.5))
			_part(head, _cyl(0.0, 0.05, 0.12), Vector3(0, -0.02, 0.27), skin_m, Vector3(90, 0, 0))
			var hair2 := _cloth(hair_c)
			_sphere(head, 0.29, Vector3(0, 0.06, -0.04), hair2, Vector3(1.0, 0.95, 1.0))
			if kind_h == "woman":
				for k in range(10):
					var a2: float = lerpf(-2.2, 2.2, k / 9.0)
					_part(head, _cyl(0.05, 0.02, 0.9), Vector3(sin(a2) * 0.24, -0.35, -cos(a2) * 0.1 - 0.08), hair2, Vector3(-10, 0, rad_to_deg(a2) * 0.2))
			if o.has("horns"):
				for side in [-1.0, 1.0]: _horn(head, Vector3(side * 0.14, 0.22, 0.02), side, float(o.horns))

## Curved horn: a chain of tapering segments curling back and out.
func _horn(parent: Node3D, pos: Vector3, side: float, length: float) -> void:
	var node := Node3D.new()
	node.position = pos
	parent.add_child(node)
	var horn_m := _mat(Color(0.85, 0.8, 0.7), 0.0, 0.45)
	horn_m.normal_enabled = true
	horn_m.normal_texture = _noise_tex("horn_ridges", 0.08, true, [], 256, 4.0)
	var seg: int = 7
	var cur := node
	for k in range(seg):
		var r: float = lerpf(0.07, 0.01, k / float(seg)) * (0.6 + length * 0.4)
		var l: float = length / seg * 1.3
		var joint := Node3D.new()
		joint.rotation_degrees = Vector3(-22.0, 0, side * -12.0)
		cur.add_child(joint)
		_part(joint, _cyl(r * 0.85, r, l), Vector3(0, l * 0.5, 0), horn_m)
		var nxt := Node3D.new()
		nxt.position = Vector3(0, l, 0)
		joint.add_child(nxt)
		cur = nxt

func _hand_item(hand: Node3D, item: String, o: Dictionary) -> void:
	# The hand node points down the arm; items are placed along its local -y axis.
	match item:
		"sword", "flame_sword":
			var s := Node3D.new()
			s.rotation_degrees = Vector3(180, 0, 0)
			hand.add_child(s)
			_part(s, _cyl(0.04, 0.04, 0.3), Vector3(0, -0.1, 0), _gold(Color("8a6a2a")))
			var guard := BoxMesh.new()
			guard.size = Vector3(0.42, 0.06, 0.08)
			_part(s, guard, Vector3(0, 0.08, 0), _gold())
			var blade := PrismMesh.new()
			blade.size = Vector3(0.14, 2.0, 0.035)
			_part(s, blade, Vector3(0, 1.1, 0), _glow_mat(Color("ff7a1a"), 4.0) if item == "flame_sword" else _gold(Color("d8dde6")))
			if item == "flame_sword":
				var fl := _part(s, _cyl(0.0, 0.18, 2.2), Vector3(0, 1.1, 0), _glow_mat(Color("ffcf4a"), 1.5))
				fl.transparency = 0.6
		"spear", "cross_staff":
			var st := Node3D.new()
			st.rotation_degrees = Vector3(180, 0, 0)
			st.position = Vector3(0, -0.2, 0)
			hand.add_child(st)
			_part(st, _cyl(0.035, 0.035, 3.2), Vector3(0, 0.6, 0), _gold(Color("8a6a2a")))
			if item == "spear":
				_part(st, PrismMesh.new(), Vector3(0, 2.35, 0), _gold(Color("d8dde6")), Vector3.ZERO, Vector3(0.18, 0.5, 0.05))
			else:
				var red := _glow_mat(Color("dc2626"), 1.6)
				for k in range(2):
					var bar := BoxMesh.new()
					bar.size = Vector3(0.5 - k * 0.15, 0.06, 0.06)
					_part(st, bar, Vector3(0, 2.0 + k * 0.28, 0), red)
				_part(st, _cyl(0.035, 0.035, 0.5), Vector3(0, 2.35, 0), red)
		"scepter":
			var sc := Node3D.new()
			sc.rotation_degrees = Vector3(180, 0, 0)
			hand.add_child(sc)
			_part(sc, _cyl(0.035, 0.03, 1.2), Vector3(0, 0.3, 0), _gold())
			_sphere(sc, 0.12, Vector3(0, 0.95, 0), _glow_mat(Color("9be7ff"), 3.0))
		"cane":
			_part(hand, _cyl(0.025, 0.025, 1.4), Vector3(0, -0.45, 0.05), _cloth(Color(0.2, 0.15, 0.1)))
		"wreath":
			var wr := Node3D.new()
			wr.position = Vector3(0, -0.2, 0.1)
			hand.add_child(wr)
			var leaf := _glow_mat(Color("b91c1c") if o.has("sash") else Color("4d7c0f"), 0.6)
			for k in range(12):
				var a: float = TAU * k / 12.0
				_sphere(wr, 0.06, Vector3(cos(a) * 0.22, 0, sin(a) * 0.22), leaf, Vector3(1.4, 0.6, 0.8))
		"rings":
			_part(hand, _torus(0.1, 0.14), Vector3(0, -0.15, 0.08), _gold(), Vector3(90, 0, 0))
		"scroll":
			_part(hand, _cyl(0.06, 0.06, 0.5), Vector3(0, -0.1, 0.1), _cloth(Color(0.9, 0.85, 0.7)), Vector3(0, 0, 90))
			var ribbon := QuadMesh.new()
			ribbon.size = Vector2(0.45, 1.2)
			var rm := _cloth(Color(0.92, 0.86, 0.72))
			rm.cull_mode = BaseMaterial3D.CULL_DISABLED
			_part(hand, ribbon, Vector3(0, -0.7, 0.12), rm, Vector3(0, 0, 8))
		"sack":
			_sphere(hand, 0.3, Vector3(0, -0.15, 0.25), _cloth(Color(0.55, 0.45, 0.3)))
			for k in range(5):
				var coin := CylinderMesh.new()
				coin.top_radius = 0.07
				coin.bottom_radius = 0.07
				coin.height = 0.02
				_part(hand, coin, Vector3(randf_range(-0.2, 0.2), -0.45 - k * 0.02, 0.35), _gold(Color("facc15")), Vector3(90, 0, 0))

## Bat wing: finger bones with a leathery, scalloped membrane between them.
func _bat_wing(parent: Node3D, root: Vector3, side: float, span: float, tip: Color) -> void:
	var w := Node3D.new()
	w.position = root
	w.rotation_degrees = Vector3(0, side * 15.0, 0)
	parent.add_child(w)
	var bone_m := _mat(Color(0.12, 0.1, 0.12), 0.1, 0.5)
	var tips: Array = []
	for k in range(5):
		var a: float = deg_to_rad(lerpf(30.0, -60.0, k / 4.0))
		var l: float = span * (1.0 - k * 0.12)
		tips.append(Vector3(side * cos(a) * l, sin(a) * l + 0.3, 0))
	for p in tips:
		var mid: Vector3 = p * 0.5
		var bone := _part(w, _cyl(0.015, 0.035, p.length()), mid, bone_m)
		_align(bone, Vector3.ZERO, p)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for k in range(tips.size() - 1):
		var a: Vector3 = tips[k]
		var b: Vector3 = tips[k + 1]
		var scallop: Vector3 = (a + b) * 0.36
		for v in [Vector3.ZERO, a, scallop, Vector3.ZERO, scallop, b]:
			st.set_uv(Vector2(v.x * 0.3 + 0.5, v.y * 0.3 + 0.5))
			st.set_normal(Vector3(0, 0, 1))
			st.add_vertex(v)
	var mem := StandardMaterial3D.new()
	mem.albedo_texture = _noise_tex("leather_%s" % tip.to_html(), 0.05, false, [Color(0.06, 0.03, 0.05), tip.darkened(0.55)])
	mem.normal_enabled = true
	mem.normal_texture = _noise_tex("veins", 0.03, true, [], 512, 8.0)
	mem.cull_mode = BaseMaterial3D.CULL_DISABLED
	mem.roughness = 0.7
	mem.rim_enabled = true
	mem.rim = 0.4
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mem
	w.add_child(mi)
	wings.append([w, w.rotation_degrees, 0.5 if side > 0 else 0.9, 10.0])

func _tail(parent: Node3D, pos: Vector3, col: Color) -> void:
	var m := _skin(col)
	var cur := Node3D.new()
	cur.position = pos
	cur.rotation_degrees = Vector3(120, 0, 0)
	parent.add_child(cur)
	wings.append([cur, cur.rotation_degrees, 0.3, 12.0])
	for k in range(8):
		var l := 0.22
		_part(cur, _cyl(0.05 - k * 0.005, 0.06 - k * 0.005, l), Vector3(0, l * 0.5, 0), m)
		var nxt := Node3D.new()
		nxt.position = Vector3(0, l, 0)
		nxt.rotation_degrees = Vector3(-14, 0, 6)
		cur.add_child(nxt)
		cur = nxt
	_part(cur, PrismMesh.new(), Vector3(0, 0.1, 0), m, Vector3.ZERO, Vector3(0.25, 0.25, 0.05))

func _owl(parent: Node3D, pos: Vector3) -> void:
	var feathers := _cloth(Color(0.45, 0.36, 0.28))
	_sphere(parent, 0.22, pos, feathers, Vector3(1.0, 1.3, 0.9))
	_sphere(parent, 0.16, pos + Vector3(0, 0.34, 0.02), feathers)
	for side in [-1.0, 1.0]:
		_sphere(parent, 0.045, pos + Vector3(side * 0.07, 0.36, 0.14), _glow_mat(Color("facc15"), 3.0))
		_part(parent, PrismMesh.new(), pos + Vector3(side * 0.09, 0.5, 0), feathers, Vector3.ZERO, Vector3(0.06, 0.12, 0.04))

# ─────────────────────────────────────────────────────── beelzebub ──

func _build_fly() -> void:
	var body := Node3D.new()
	body.position = Vector3(0, 1.2, 0)
	add_child(body)
	var chitin := _mat(Color(0.12, 0.13, 0.08), 0.35, 0.35)
	chitin.normal_enabled = true
	chitin.normal_texture = _noise_tex("chitin", 0.09, true, [], 512, 5.0)
	var hairy := _cloth(Color(0.16, 0.14, 0.1))
	_sphere(body, 0.55, Vector3(0, 0.6, 0), hairy, Vector3(1.1, 0.9, 0.9))
	# Striped abdomen curling down behind.
	for k in range(6):
		var r: float = 0.62 - k * 0.07
		var c: Material = chitin if k % 2 == 0 else _mat(Color(0.55, 0.45, 0.12), 0.3, 0.4)
		_sphere(body, r, Vector3(0, 0.25 - k * 0.22, -0.45 - k * 0.2), c, Vector3(1.0, 0.8, 1.0))
	# Head with huge compound eyes and a proboscis.
	var head := Node3D.new()
	head.position = Vector3(0, 0.95, 0.55)
	body.add_child(head)
	_sphere(head, 0.3, Vector3.ZERO, hairy)
	var facets := _mat(Color(0.6, 0.05, 0.03), 0.2, 0.2)
	facets.normal_enabled = true
	facets.normal_texture = _noise_tex("facets", 0.35, true, [], 256, 10.0)
	facets.emission_enabled = true
	facets.emission = Color("7f1d1d")
	facets.emission_energy_multiplier = 0.8
	for side in [-1.0, 1.0]:
		_sphere(head, 0.26, Vector3(side * 0.24, 0.05, 0.1), facets)
		_part(head, _cyl(0.008, 0.015, 0.5), Vector3(side * 0.08, 0.4, 0.1), chitin, Vector3(-20, 0, side * -25))
	_part(head, _cyl(0.02, 0.05, 0.45), Vector3(0, -0.35, 0.18), chitin, Vector3(25, 0, 0))
	# Veined translucent wings, two pairs, beating fast.
	var wing_m := StandardMaterial3D.new()
	wing_m.albedo_texture = _noise_tex("fly_wing", 0.06, false, [Color(0.55, 0.6, 0.5, 0.25), Color(0.9, 0.95, 0.85, 0.5)])
	wing_m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wing_m.cull_mode = BaseMaterial3D.CULL_DISABLED
	wing_m.normal_enabled = true
	wing_m.normal_texture = _noise_tex("veins", 0.03, true, [], 512, 8.0)
	wing_m.roughness = 0.1
	for side in [-1.0, 1.0]:
		for pair in range(2):
			var w := Node3D.new()
			w.position = Vector3(side * 0.35, 0.85, -0.1 - pair * 0.2)
			w.rotation_degrees = Vector3(0, 0, -side * (20.0 + pair * 25.0))
			body.add_child(w)
			var q := QuadMesh.new()
			q.size = Vector2(2.2 - pair * 0.5, 0.9 - pair * 0.15)
			_part(w, q, Vector3(side * (1.1 - pair * 0.25), 0.1, 0), wing_m)
			wings.append([w, w.rotation_degrees, pair * 0.8, 22.0, 6.0])
	# Six hairy legs dangling.
	for k in range(3):
		for side in [-1.0, 1.0]:
			var leg := Node3D.new()
			leg.position = Vector3(side * 0.3, 0.35, 0.2 - k * 0.25)
			leg.rotation_degrees = Vector3(0, 0, side * 35.0)
			body.add_child(leg)
			_part(leg, _cyl(0.025, 0.035, 0.55), Vector3(0, -0.27, 0), hairy)
			var knee := Node3D.new()
			knee.position = Vector3(0, -0.55, 0)
			knee.rotation_degrees = Vector3(0, 0, -side * 55.0)
			leg.add_child(knee)
			_part(knee, _cyl(0.015, 0.025, 0.6), Vector3(0, -0.3, 0), chitin)

# ─────────────────────────────────────────────────────── leviathan ──

func _build_dragon() -> void:
	var body := Node3D.new()
	add_child(body)
	var scales := _mat(Color("7fa7c4"), 0.85, 0.3)
	scales.normal_enabled = true
	scales.normal_texture = _noise_tex("scales", 0.18, true, [], 512, 9.0)
	scales.normal_scale = 0.8
	var belly := _mat(Color("d6c9a8"), 0.3, 0.5)
	# Serpentine coil rising to the head.
	var prev := Vector3(1.4, 0.3, -0.3)
	for k in range(14):
		var f: float = k / 13.0
		var pos := Vector3(sin(f * 5.0) * 1.1 * (1.0 - f * 0.4), 0.3 + f * 2.6, -0.3 + cos(f * 5.0) * 0.4)
		var r: float = lerpf(0.22, 0.42, sin(f * PI))
		_sphere(body, r, pos, scales if k % 3 else belly, Vector3(1.0, 1.0, 1.0))
		var mid: Vector3 = (pos + prev) * 0.5
		var seg := _part(body, _cyl(r * 0.9, r * 0.9, (pos - prev).length()), mid, scales)
		_align(seg, prev, pos)
		prev = pos
	# Head with jaws, teeth, horns and glowing eyes.
	var head := Node3D.new()
	head.position = prev + Vector3(0, 0.25, 0.25)
	body.add_child(head)
	spinners.append([head, Vector3(0, 1, 0), 0.0])
	_sphere(head, 0.32, Vector3.ZERO, scales, Vector3(1.0, 0.9, 1.3))
	_part(head, _cyl(0.12, 0.22, 0.6), Vector3(0, -0.05, 0.45), scales, Vector3(90, 0, 0))
	_part(head, _cyl(0.1, 0.18, 0.55), Vector3(0, -0.22, 0.4), belly, Vector3(80, 0, 0))
	var tooth_m := _mat(Color(0.95, 0.93, 0.85), 0.0, 0.3)
	for k in range(6):
		for side in [-1.0, 1.0]:
			_part(head, _cyl(0.0, 0.025, 0.1), Vector3(side * 0.09, -0.14, 0.3 + k * 0.08), tooth_m, Vector3(180, 0, 0))
	for side in [-1.0, 1.0]:
		_sphere(head, 0.06, Vector3(side * 0.17, 0.1, 0.25), _glow_mat(Color("22d3ee"), 4.0))
		_horn(head, Vector3(side * 0.15, 0.2, -0.1), side, 0.8)
		_bat_wing(body, Vector3(side * 0.3, 2.0, -0.4), side, 2.4, Color("0ea5e9"))
	# Fins along the back.
	for k in range(8):
		var f2: float = 0.2 + k * 0.09
		var fp := Vector3(sin(f2 * 5.0) * 1.1 * (1.0 - f2 * 0.4), 0.55 + f2 * 2.6, -0.55 + cos(f2 * 5.0) * 0.4)
		_part(body, PrismMesh.new(), fp, _glow_mat(Color("0369a1"), 0.8), Vector3(-30, 0, 0), Vector3(0.06, 0.35, 0.3))

# ─────────────────────────────────────────────────────── ahriman ──

func _build_mask() -> void:
	var face := Node3D.new()
	face.position = Vector3(0, 1.8, 0)
	add_child(face)
	var stone := _mat(Color.WHITE, 0.0, 0.85)
	stone.albedo_texture = _noise_tex("stone_mask", 0.03, false, [Color(0.28, 0.26, 0.25), Color(0.72, 0.7, 0.66)])
	stone.normal_enabled = true
	stone.normal_texture = _noise_tex("stone_n", 0.05, true, [], 512, 8.0)
	_sphere(face, 1.2, Vector3.ZERO, stone, Vector3(1.0, 1.35, 0.55))
	var dark := _mat(Color(0.02, 0.01, 0.01), 0.0, 1.0)
	for side in [-1.0, 1.0]:
		_sphere(face, 0.32, Vector3(side * 0.42, 0.32, 0.5), dark, Vector3(1.2, 0.8, 0.5))
		_sphere(face, 0.08, Vector3(side * 0.42, 0.3, 0.62), _glow_mat(Color("ef4444"), 5.0))
		var brow := BoxMesh.new()
		brow.size = Vector3(0.7, 0.16, 0.3)
		_part(face, brow, Vector3(side * 0.42, 0.62, 0.52), stone, Vector3(0, 0, side * -18))
		_sphere(face, 0.25, Vector3(side * 0.55, -0.35, 0.45), stone, Vector3(1.0, 0.6, 0.5))
	_part(face, PrismMesh.new(), Vector3(0, 0.0, 0.62), stone, Vector3(0, 0, 0), Vector3(0.28, 0.9, 0.3))
	var mouth := BoxMesh.new()
	mouth.size = Vector3(0.55, 0.05, 0.1)
	_part(face, mouth, Vector3(0, -0.72, 0.58), dark, Vector3(0, 0, 0))
	# Glowing cracks and orbiting shards.
	var crack := _glow_mat(Color("dc2626"), 3.0)
	for k in range(6):
		var cb := BoxMesh.new()
		cb.size = Vector3(0.03, randf_range(0.4, 0.9), 0.02)
		_part(face, cb, Vector3(randf_range(-0.7, 0.7), randf_range(-0.9, 0.9), 0.62), crack, Vector3(0, 0, randf_range(-50, 50)))
	var orbit := Node3D.new()
	face.add_child(orbit)
	spinners.append([orbit, Vector3(0, 1, 0), 0.5])
	for k in range(10):
		var a: float = TAU * k / 10.0
		_part(orbit, BoxMesh.new(), Vector3(cos(a) * 1.9, randf_range(-0.8, 0.8), sin(a) * 1.0), stone, Vector3(randf() * 90, randf() * 90, 0),
			Vector3.ONE * randf_range(0.15, 0.35))

# ─────────────────────────────────────────── sculpted bodies (bosses.gd "body") ──

## Restyles a sculpted body and adds wings, halo, crown, horns, tail … at its bones.
## The decoration node animates itself (wings, glows) as a child of the view.
## Shop skin on a fighter model: remembers the original materials, so skins can be switched
## or removed ("" restores the original look).
static func apply_skin(model: Node3D, look: String) -> void:
	for mi in model.find_children("*", "MeshInstance3D", true, false):
		if mi.mesh == null or mi.has_meta("gear"): continue
		if not mi.has_meta("orig_mats"):
			var orig: Array = []
			for sfc in range(mi.mesh.get_surface_count()): orig.append(mi.get_surface_override_material(sfc))
			mi.set_meta("orig_mats", orig)
		var saved: Array = mi.get_meta("orig_mats")
		for sfc in range(mini(saved.size(), mi.mesh.get_surface_count())): mi.set_surface_override_material(sfc, saved[sfc])
	if look == "": return
	var m = load("res://scripts/boss_models.gd").new()
	m._restyle(model, look)
	m.free()

static func decorate(view: Node3D, boss_id: String) -> void:
	var m = load("res://scripts/boss_models.gd").new()
	m.kind = boss_id
	view.add_child(m)
	m._decorate(view)

## Surface looks: living marble, gold, silver, obsidian with glowing veins, bone, bronze, frost …
## Skin looks as outfit palettes for the house heroes: primary, secondary, accent, metal, roughness.
const SKIN_PALETTE := {
	"marble": [Color(0.93, 0.91, 0.87), Color(0.42, 0.4, 0.38), Color(0.98, 0.96, 0.9), 0.05, 0.35],
	"pearl": [Color(0.88, 0.92, 1.0), Color(0.36, 0.4, 0.5), Color(1.0, 1.0, 1.0), 0.2, 0.3],
	"ivory": [Color(1.0, 0.93, 0.8), Color(0.45, 0.36, 0.26), Color(0.95, 0.8, 0.5), 0.1, 0.4],
	"rose": [Color(0.98, 0.66, 0.72), Color(0.42, 0.16, 0.24), Color(1.0, 0.86, 0.9), 0.15, 0.4],
	"frost": [Color(0.66, 0.84, 1.0), Color(0.12, 0.24, 0.4), Color(0.85, 0.97, 1.0), 0.3, 0.3],
	"gold": [Color(1.0, 0.76, 0.3), Color(0.32, 0.2, 0.08), Color(1.0, 0.92, 0.6), 0.85, 0.3],
	"silver": [Color(0.85, 0.88, 0.94), Color(0.2, 0.22, 0.27), Color(1.0, 1.0, 1.0), 0.85, 0.28],
	"bronze": [Color(0.8, 0.5, 0.26), Color(0.25, 0.14, 0.07), Color(1.0, 0.75, 0.45), 0.8, 0.38],
	"rust": [Color(0.6, 0.34, 0.2), Color(0.2, 0.12, 0.08), Color(0.85, 0.55, 0.3), 0.5, 0.6],
	"emerald": [Color(0.2, 0.8, 0.5), Color(0.04, 0.2, 0.12), Color(0.7, 1.0, 0.8), 0.4, 0.3],
	"neon": [Color(0.2, 0.95, 1.0), Color(0.06, 0.04, 0.16), Color(1.0, 0.3, 0.9), 0.3, 0.3],
	"lava": [Color(1.0, 0.42, 0.12), Color(0.12, 0.05, 0.04), Color(1.0, 0.82, 0.3), 0.3, 0.45],
	"infernal": [Color(0.85, 0.12, 0.1), Color(0.1, 0.03, 0.03), Color(1.0, 0.6, 0.2), 0.4, 0.4],
	"shadow": [Color(0.3, 0.26, 0.4), Color(0.04, 0.03, 0.06), Color(0.7, 0.5, 1.0), 0.3, 0.45],
	"crystal": [Color(0.7, 0.9, 1.0), Color(0.2, 0.3, 0.5), Color(1.0, 1.0, 1.0), 0.2, 0.15],
	"ghost": [Color(0.75, 0.95, 0.9), Color(0.2, 0.3, 0.32), Color(0.9, 1.0, 1.0), 0.0, 0.4],
	"galaxy": [Color(0.45, 0.3, 0.95), Color(0.05, 0.04, 0.16), Color(0.9, 0.85, 1.0), 0.4, 0.3],
	"celestial": [Color(0.95, 0.88, 0.6), Color(0.15, 0.2, 0.42), Color(1.0, 1.0, 0.85), 0.6, 0.3],
	"obsidian": [Color(0.22, 0.14, 0.15), Color(0.04, 0.03, 0.03), Color(1.0, 0.3, 0.15), 0.4, 0.22],
	"abyss": [Color(0.14, 0.3, 0.36), Color(0.02, 0.05, 0.08), Color(0.2, 0.85, 0.95), 0.4, 0.25],
	"bone": [Color(0.9, 0.85, 0.74), Color(0.36, 0.3, 0.24), Color(1.0, 0.96, 0.86), 0.0, 0.6],
}

func _restyle(model: Node3D, look: String) -> void:
	var marble: Texture2D = load("res://assets/polyhaven/textures/marble_01/marble_01_diff_2k.jpg")
	var veins := _noise_tex("lava_veins", 0.02, false, [], 512)
	var vein_ramp := Gradient.new()
	vein_ramp.offsets = PackedFloat32Array([0.0, 0.485, 0.5, 0.515, 1.0])
	vein_ramp.colors = PackedColorArray([Color.BLACK, Color.BLACK, Color.WHITE, Color.BLACK, Color.BLACK])
	var vt := NoiseTexture2D.new()
	vt.width = 512
	vt.height = 512
	vt.seamless = true
	vt.noise = (veins as NoiseTexture2D).noise
	vt.color_ramp = vein_ramp
	for mi in model.find_children("*", "MeshInstance3D", true, false):
		if mi.mesh == null or mi.has_meta("gear"): continue
		for sfc in range(mi.mesh.get_surface_count()):
			var base = mi.get_active_material(sfc)
			if base is ShaderMaterial and SKIN_PALETTE.has(look):
				# House heroes (hero_recolor shader): the skin recolors the outfit but keeps the
				# texture, the skin tones and every detail, instead of painting one flat color.
				var hm: ShaderMaterial = base.duplicate()
				var pal: Array = SKIN_PALETTE[look]
				hm.set_shader_parameter("primary", pal[0])
				hm.set_shader_parameter("secondary", pal[1])
				hm.set_shader_parameter("accent", pal[2])
				hm.set_shader_parameter("metallic_v", pal[3])
				hm.set_shader_parameter("roughness_v", pal[4])
				hm.set_shader_parameter("rim_color", pal[2])
				mi.set_surface_override_material(sfc, hm)
				continue
			var mat: StandardMaterial3D = base.duplicate() if base is StandardMaterial3D else StandardMaterial3D.new()
			mat.emission_enabled = false
			match look:
				"marble", "pearl", "ivory", "rose", "frost":
					mat.albedo_texture = marble
					mat.albedo_color = {"marble": Color(0.96, 0.94, 0.9), "pearl": Color(0.88, 0.93, 1.0), "ivory": Color(1.0, 0.94, 0.82),
						"rose": Color(1.0, 0.86, 0.86), "frost": Color(0.72, 0.84, 1.0)}[look]
					mat.metallic = 0.0
					mat.roughness = 0.32
					mat.clearcoat_enabled = true
					mat.clearcoat = 0.5
					mat.uv1_scale = Vector3(2, 2, 2)
					if look == "frost":
						mat.rim_enabled = true
						mat.rim = 0.6
						mat.emission_enabled = true
						mat.emission = Color("38bdf8")
						mat.emission_energy_multiplier = 0.35
				"gold", "silver", "bronze", "rust":
					mat.albedo_color = {"gold": Color(1.0, 0.78, 0.36), "silver": Color(0.86, 0.89, 0.95), "bronze": Color(0.78, 0.5, 0.26),
						"rust": Color(0.5, 0.32, 0.22)}[look]
					mat.metallic = 0.95 if look != "rust" else 0.6
					mat.roughness = 0.26 if look != "rust" else 0.55
					if mat.normal_texture == null:
						mat.normal_enabled = true
						mat.normal_texture = _noise_tex("hammered", 0.035, true, [], 512, 5.0)
						mat.normal_scale = 0.4
				"emerald":
					mat.albedo_color = Color(0.2, 0.75, 0.45)
					mat.metallic = 0.7
					mat.roughness = 0.2
					mat.clearcoat_enabled = true
				"neon", "lava", "infernal":
					mat.albedo_color = Color(0.06, 0.05, 0.08) if look == "neon" else Color(0.18, 0.08, 0.06)
					mat.metallic = 0.4
					mat.roughness = 0.25
					mat.emission_enabled = true
					mat.emission_texture = vt
					mat.emission = {"neon": Color("f0abfc"), "lava": Color("fb923c"), "infernal": Color("ef4444")}[look]
					mat.emission_energy_multiplier = 1.6
					mat.uv1_scale = Vector3(3, 3, 3)
					mat.rim_enabled = true
					mat.rim = 0.5
				"shadow":
					mat.albedo_color = Color(0.05, 0.04, 0.08)
					mat.roughness = 0.4
					mat.rim_enabled = true
					mat.rim = 1.0
					mat.rim_tint = 0.0
					mat.emission_enabled = true
					mat.emission = Color("6d28d9")
					mat.emission_energy_multiplier = 0.25
				"crystal", "ghost":
					mat.albedo_color = Color(0.55, 0.9, 1.0, 0.45) if look == "crystal" else Color(0.9, 0.95, 1.0, 0.3)
					mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
					mat.metallic = 0.2 if look == "crystal" else 0.0
					mat.roughness = 0.05
					mat.emission_enabled = true
					mat.emission = Color("67e8f9") if look == "crystal" else Color("e0f2fe")
					mat.emission_energy_multiplier = 0.4 if look == "crystal" else 0.8
					mat.rim_enabled = true
					mat.rim = 1.0
				"galaxy", "celestial":
					var stars := _noise_tex("stars", 0.2, false, [], 512)
					var sr := Gradient.new()
					sr.offsets = PackedFloat32Array([0.0, 0.82, 0.86, 1.0])
					sr.colors = PackedColorArray([Color.BLACK, Color.BLACK, Color.WHITE, Color.WHITE])
					var st := NoiseTexture2D.new()
					st.width = 512
					st.height = 512
					st.seamless = true
					st.noise = (stars as NoiseTexture2D).noise
					st.color_ramp = sr
					mat.albedo_color = Color(0.05, 0.04, 0.16) if look == "galaxy" else Color(0.95, 0.9, 0.78)
					mat.metallic = 0.3
					mat.roughness = 0.3
					mat.emission_enabled = true
					mat.emission_texture = st
					mat.emission = Color("c4b5fd") if look == "galaxy" else Color("fde68a")
					mat.emission_energy_multiplier = 2.0
					mat.uv1_scale = Vector3(4, 4, 4)
				"obsidian", "abyss", "bone":
					var tint: Color = {"obsidian": Color(0.2, 0.13, 0.14), "abyss": Color(0.14, 0.26, 0.32), "bone": Color(0.9, 0.85, 0.76)}[look]
					mat.albedo_color = tint
					mat.metallic = 0.35 if look != "bone" else 0.0
					mat.roughness = 0.22 if look != "bone" else 0.6
					mat.rim_enabled = true
					mat.rim = 0.4
					if look != "bone":
						# Glowing veins running over the whole body.
						mat.emission_enabled = true
						mat.emission_texture = vt
						mat.emission = Color("ff3b1f") if look == "obsidian" else Color("22d3ee")
						mat.emission_energy_multiplier = 0.9
						mat.uv1_scale = Vector3(3, 3, 3)
						glows.append([mat, 0.9])
			mi.set_surface_override_material(sfc, mat)

## Position of a mapped bone in the decoration space (meters, relative to the model).
func _bone(view: Node3D, key: String, fallback: Vector3) -> Vector3:
	var sk: Skeleton3D = view.skeleton
	if sk == null or not view.bone_map.has(key): return fallback
	var xf: Transform3D = sk.get_bone_global_rest(view.bone_map[key])
	var n: Node = sk
	while n != null and n != view.model:
		if n is Node3D: xf = (n as Node3D).transform * xf
		n = n.get_parent()
	return xf.origin * view.model.scale.x

func _decorate(view: Node3D) -> void:
	var b: Dictionary = load("res://scripts/bosses.gd").data(kind)
	var o: Dictionary = HUMANOIDS.get(kind, {})
	var h: float = float(b.get("height", 3.3))
	_restyle(view.model, str(b.get("look", "")))
	var root := Node3D.new()
	root.name = "BossDeco"
	view.model.add_child(root)
	root.scale = Vector3.ONE / maxf(0.0001, view.model.scale.x)
	var head: Vector3 = _bone(view, "head", Vector3(0, h * 0.88, 0))
	var hips: Vector3 = _bone(view, "hips", Vector3(0, h * 0.5, 0))
	var spine: Vector3 = _bone(view, "spine", Vector3(0, h * 0.6, 0))
	var back: Vector3 = spine.lerp(head, 0.55) + Vector3(0, 0, -0.18 * h / 3.3)
	var s: float = h / 3.3
	var tip: Color = o.get("wing_tip", b.get("color", Color("ffae3a")))
	match str(o.get("wings", "")):
		"feather":
			for side in [-1.0, 1.0]:
				_wing(root, back + Vector3(side * 0.18 * s, 0, 0), Vector3(0, side * 20.0, -side * 42.0), 2.3 * s, 18, tip, 1, 9.0, 0.0)
				if o.get("four_wings", false):
					_wing(root, back + Vector3(side * 0.18 * s, -0.4 * s, 0), Vector3(0, side * 20.0, -side * 115.0), 1.9 * s, 14, tip, 0, 6.0, 1.3)
		"bat":
			for side in [-1.0, 1.0]:
				_bat_wing(root, back + Vector3(side * 0.18 * s, 0, 0), side, 2.8 * s, tip)
	var crown_top: Vector3 = head + Vector3(0, 0.3 * s, 0)
	if o.get("halo", false):
		_part(root, _torus(0.32 * s, 0.37 * s), head + Vector3(0, 0.35 * s, -0.25 * s), _glow_mat(Color("ffe08a"), 3.0), Vector3(90, 0, 0))
	if o.get("crown", false) or kind == "bel_marduk":
		var crown_m := _gold()
		_part(root, _torus(0.17 * s, 0.22 * s), crown_top, crown_m)
		for k in range(8):
			var a: float = TAU * k / 8.0
			_part(root, _cyl(0.0, 0.04 * s, 0.22 * s), crown_top + Vector3(cos(a) * 0.19 * s, 0.1 * s, sin(a) * 0.19 * s), crown_m)
	if o.has("horns"):
		for side in [-1.0, 1.0]:
			_horn(root, head + Vector3(side * 0.12 * s, 0.18 * s, 0.02), side, float(o.horns) * s)
	if o.get("tail", false): _tail(root, hips + Vector3(0, -0.05, -0.2 * s), o.get("skin", Color(0.3, 0.2, 0.2)))
	if o.get("owls", false):
		for side in [-1.0, 1.0]: _owl(root, Vector3(side * 0.9 * s, 0.25, 0.2))
	if o.get("chest", false):
		var chest_path := "res://assets/polyhaven/models/treasure_chest/treasure_chest.gltf"
		if ResourceLoader.exists(chest_path):
			var chest: Node3D = load(chest_path).instantiate()
			chest.position = Vector3(0.9 * s, 0.0, 0.35)
			chest.scale = Vector3.ONE * 2.2 * s
			root.add_child(chest)
	if o.get("pentagram", false):
		_part(root, _torus(0.07 * s, 0.09 * s), head + Vector3(0, 0.12 * s, 0.2 * s), _glow_mat(Color("fde047"), 3.0), Vector3(90, 0, 0))
	if o.get("torch", false):
		_sphere(root, 0.14 * s, head + Vector3(0, 0.55 * s, 0), _glow_mat(Color("ff8a1f"), 4.0), Vector3(0.8, 1.6, 0.8))
	if o.get("ice", false):
		var ice := _mat(Color(0.75, 0.9, 1.0, 0.55), 0.0, 0.05)
		ice.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ice.emission_enabled = true
		ice.emission = Color("7dd3fc")
		ice.emission_energy_multiplier = 0.6
		var orbit := Node3D.new()
		orbit.position = spine
		root.add_child(orbit)
		spinners.append([orbit, Vector3(0, 1, 0), 0.4])
		for k in range(10):
			var a: float = TAU * k / 10.0
			_part(orbit, _cyl(0.0, 0.12, 0.8), Vector3(cos(a) * 1.4 * s, sin(k * 1.7) * 0.8, sin(a) * 0.9 * s), ice, Vector3(0, 0, rad_to_deg(a) + 90))
	if kind == "ahriman":
		# The colossal head: glowing eyes, an orbit of stone shards.
		for side in [-1.0, 1.0]:
			_sphere(root, 0.1 * s, Vector3(side * 0.36 * s, h * 0.62, 0.62 * s), _glow_mat(Color("ef4444"), 6.0))
		var shards := Node3D.new()
		shards.position = Vector3(0, h * 0.55, 0)
		root.add_child(shards)
		spinners.append([shards, Vector3(0, 1, 0), 0.5])
		var stone := _mat(Color(0.25, 0.2, 0.2), 0.3, 0.3)
		for k in range(10):
			var a2: float = TAU * k / 10.0
			_part(shards, BoxMesh.new(), Vector3(cos(a2) * 2.0 * s, sin(k * 1.3) * 0.9, sin(a2) * 1.1 * s), stone, Vector3(k * 30, k * 50, 0), Vector3.ONE * (0.2 + 0.1 * (k % 3)))
	_embers_at(root, spine.lerp(head, 0.4), b.get("color", Color("ff8a1f")), h)

func _embers_at(parent: Node3D, pos: Vector3, color: Color, h: float) -> void:
	_embers(color)
	remove_child(fire)
	fire.position = pos
	fire.emission_sphere_radius = h * 0.4
	parent.add_child(fire)

# ─────────────────────────────────────────────────────────── animation ──

## Called by the view every frame with the simulation state.
func apply_state(state: Dictionary, look: Vector3) -> void:
	look_at_pos = look
	var pose: String = str(state.get("pose", "Idle"))
	var target_charge: float = 1.0 if pose in ["Charge", "Summon", "Beam"] or state.get("state", "") == "Attack" else 0.0
	charge = move_toward(charge, target_charge, 0.05)

func flash() -> void:
	hit_flash = 1.0

func _process(delta: float) -> void:
	t += delta
	hit_flash = move_toward(hit_flash, 0.0, delta * 5.0)
	var speed: float = 1.0 + charge * 2.5
	for w in wings:
		var node: Node3D = w[0]
		var beat: float = float(w[4]) if w.size() > 4 else 1.0
		node.rotation_degrees = w[1] + Vector3(0, 0, sin(t * 2.2 * speed * beat + float(w[2])) * float(w[3]))
	for sp in spinners:
		var node2: Node3D = sp[0]
		node2.rotate(sp[1], float(sp[2]) * delta * speed)
	for g in glows:
		var m: StandardMaterial3D = g[0]
		m.emission_energy_multiplier = float(g[1]) * (1.0 + charge * 1.0 + hit_flash * 2.0 + sin(t * 5.0) * 0.08)
	for node3 in eyes:
		if not node3.is_inside_tree(): continue
		var to: Vector3 = look_at_pos - node3.global_position
		if to.length() > 0.1:
			var want := Basis.looking_at(-to.normalized(), Vector3.UP)
			var local: Basis = node3.get_parent().global_transform.basis.inverse() * want
			node3.transform.basis = node3.transform.basis.slerp(local.orthonormalized(), minf(1.0, delta * 6.0))
	position.y = sin(t * 1.3) * 0.12

extends Node3D
## Builds every arena in code: a floating stage with PBR surfaces and glowing trim,
## themed platforms, midground architecture, animated surfaces (water, lava, city
## windows), weather particles and accent lights. Gameplay geometry comes from
## combat.gd (stage edges, platforms), so visuals and collision always match.
##
## Visual quality: scanned PBR textures, photographic sky domes and professional 3D models
## from Poly Haven (CC0, see scripts/fetch_polyhaven_assets.py). Lighting and reflections
## come from matching HDRIs (set up in main.gd). Procedural materials remain as fallback.
##
## Performance: shared materials, cached model scenes with import LODs, far props do not
## cast shadows, no shadows from accent lights, modest CPU particle counts.

const Combat = preload("res://scripts/combat.gd")
const PBR_PATH := "res://assets/textures/arenas/pbr/%s_%s.png"
const PH_TEX := "res://assets/polyhaven/textures/%s/%s_%s_2k.jpg"
const PH_MODEL := "res://assets/polyhaven/models/%s/%s.gltf"
const PH_SKY := "res://assets/polyhaven/hdri/%s_sky.jpg"
const WATER_SHADER = preload("res://shaders/arena_water.gdshader")
const LAVA_SHADER = preload("res://shaders/arena_lava.gdshader")
const WINDOW_SHADER = preload("res://shaders/arena_windows.gdshader")

## Per arena: stage top / side materials, trim color, underside style, weather.
## Per arena: stage top / side materials ("ph:" = Poly Haven scan), trim color,
## underside style, weather, sky dome panorama and its rotation.
const THEMES := {
	"blood_moon": {"top": "ph:castle_wall_slates", "side": "ph:japanese_stone_wall", "trim": Color("ff4d4d"), "under": "island", "weather": "petals", "rock_tint": Color("8a7474"), "sky": "rogland_moonlit_night", "sky_rot": 0.0, "sky_tint": Color(0.62, 0.3, 0.32), "sky_energy": 1.8},
	"volcano_sanctum": {"top": "ph:volcanic_rock_tiles", "side": "ph:dark_rock", "trim": Color("ff7a1a"), "under": "island", "weather": "embers", "rock_tint": Color("ffffff"), "sky": "rogland_sunset", "sky_rot": 90.0, "sky_tint": Color(1.0, 0.62, 0.45)},
	"imperial_colosseum": {"top": "ph:marble_01", "side": "ph:large_sandstone_blocks", "trim": Color("ffd166"), "under": "pedestal", "weather": "dust", "rock_tint": Color("ffffff"), "sky": "colosseum", "sky_rot": 90.0},
	"pirate_galleon": {"top": "ph:brown_planks_07", "side": "ph:dark_planks", "trim": Color("7dd3fc"), "under": "pier", "weather": "spray", "rock_tint": Color("ffffff"), "sky": "small_harbour_sunset", "sky_rot": 0.0},
	"gladiator_fortress": {"top": "ph:large_sandstone_blocks_01", "side": "ph:castle_brick_01", "trim": Color("ff9245"), "under": "pedestal", "weather": "dust", "rock_tint": Color("d6c2a8"), "sky": "teutonic_castle_moat", "sky_rot": 90.0},
	"mystic_grove": {"top": "ph:mossy_cobblestone", "side": "ph:mossy_rock", "trim": Color("3bfac8"), "under": "island", "weather": "fireflies", "rock_tint": Color("9fb39a"), "sky": "misty_pines", "sky_rot": 90.0},
	"frozen_summit": {"top": "ph:snow_02", "side": "ph:rock_wall_10", "trim": Color("9be7ff"), "under": "island", "weather": "snow", "rock_tint": Color("b8c7d9"), "sky": "lago_disola", "sky_rot": 180.0},
	"neon_metropolis": {"top": "ph:metal_plate", "side": "ph:concrete_panels", "trim": Color("ff3db4"), "under": "tower", "weather": "rain", "rock_tint": Color("ffffff"), "sky": "shanghai_bund", "sky_rot": 90.0, "sky_energy": 2.2, "sky_y": -2.0},
}

var time := 0.0
var bobbers: Array = []        # [node, base_y, speed, amplitude]
var flickers: Array = []       # [light or material, base_energy, speed]
var rng := RandomNumberGenerator.new()
static var _mat_cache: Dictionary = {}

# ───────────────────────────────────────────────────────────── materials ──

static func pbr(tex_name: String, uv_scale: float = 0.35, tint: Color = Color.WHITE) -> StandardMaterial3D:
	var key := "%s|%.3f|%s" % [tex_name, uv_scale, tint.to_html()]
	if _mat_cache.has(key): return _mat_cache[key]
	if tex_name.begins_with("ph:"):
		var scan := _scan_material(tex_name.trim_prefix("ph:"), uv_scale, tint)
		if scan != null:
			_mat_cache[key] = scan
			return scan
		tex_name = "stone_tiles"
	var m := StandardMaterial3D.new()
	var alb := PBR_PATH % [tex_name, "albedo"]
	if ResourceLoader.exists(alb): m.albedo_texture = load(alb)
	var nrm := PBR_PATH % [tex_name, "normal"]
	if ResourceLoader.exists(nrm):
		m.normal_enabled = true
		m.normal_texture = load(nrm)
		m.normal_scale = 1.2
	var rough := PBR_PATH % [tex_name, "rough"]
	if ResourceLoader.exists(rough):
		m.roughness_texture = load(rough)
		m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	var em := PBR_PATH % [tex_name, "emission"]
	if ResourceLoader.exists(em):
		m.emission_enabled = true
		m.emission_texture = load(em)
		# Godot adds emission color and texture: black keeps only the texture's glowing cracks.
		m.emission = Color.BLACK
		m.emission_energy_multiplier = 2.2
	m.albedo_color = tint
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3.ONE * uv_scale
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_mat_cache[key] = m
	return m

## Material from a Poly Haven scan set (diffuse, OpenGL normal, roughness); null if missing.
static func _scan_material(scan: String, uv_scale: float, tint: Color) -> StandardMaterial3D:
	var diff := PH_TEX % [scan, scan, "diff"]
	if not ResourceLoader.exists(diff): return null
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(diff)
	m.albedo_color = tint
	var nrm := PH_TEX % [scan, scan, "nor_gl"]
	if ResourceLoader.exists(nrm):
		m.normal_enabled = true
		m.normal_texture = load(nrm)
	var rough := PH_TEX % [scan, scan, "rough"]
	if ResourceLoader.exists(rough):
		m.roughness_texture = load(rough)
		m.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_triplanar_sharpness = 4.0
	m.uv1_scale = Vector3.ONE * uv_scale
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return m

static func flat(color: Color, rough: float = 0.7, metal: float = 0.0) -> StandardMaterial3D:
	var key := "flat|%s|%.2f|%.2f" % [color.to_html(), rough, metal]
	if _mat_cache.has(key): return _mat_cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = rough
	m.metallic = metal
	_mat_cache[key] = m
	return m

static func glow(color: Color, energy: float = 2.5) -> StandardMaterial3D:
	var key := "glow|%s|%.2f" % [color.to_html(), energy]
	if _mat_cache.has(key): return _mat_cache[key]
	var m := StandardMaterial3D.new()
	m.albedo_color = color.darkened(0.3)
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = energy
	_mat_cache[key] = m
	return m

func shader_mat(shader: Shader, params: Dictionary) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = shader
	for k in params: m.set_shader_parameter(k, params[k])
	return m

# ───────────────────────────────────────────────────────────── primitives ──

func add_mesh(mesh: Mesh, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO, parent: Node = null, shadows: bool = true) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	(parent if parent else self).add_child(mi)
	return mi

func box(size: Vector3, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO, shadows: bool = true) -> MeshInstance3D:
	var b := BoxMesh.new()
	b.size = size
	return add_mesh(b, pos, mat, rot, null, shadows)

func cyl(top_r: float, bottom_r: float, h: float, pos: Vector3, mat: Material, sides: int = 16, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var c := CylinderMesh.new()
	c.top_radius = top_r
	c.bottom_radius = bottom_r
	c.height = h
	c.radial_segments = sides
	c.rings = 1
	return add_mesh(c, pos, mat, rot)

func sphere(r: float, pos: Vector3, mat: Material, shadows: bool = true) -> MeshInstance3D:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 16
	s.rings = 8
	return add_mesh(s, pos, mat, Vector3.ZERO, null, shadows)

func light(pos: Vector3, color: Color, energy: float, reach: float, flicker: float = 0.0) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = reach
	l.shadow_enabled = false
	add_child(l)
	if flicker > 0.0: flickers.append([l, energy, flicker])
	return l

func plane(size: Vector2, pos: Vector3, mat: Material, subdiv: int = 0) -> MeshInstance3D:
	var p := PlaneMesh.new()
	p.size = size
	p.subdivide_width = subdiv
	p.subdivide_depth = subdiv
	return add_mesh(p, pos, mat, Vector3.ZERO, null, false)

static var _scene_cache: Dictionary = {}

## Places a Poly Haven model. height > 0 scales it to that height (metres); the model's
## bottom (or top with hang = true) sits at pos.y. Returns null when the asset is missing.
func prop(model_name: String, pos: Vector3, height: float, rot_y: float = 0.0, shadows: bool = true, hang: bool = false) -> Node3D:
	var path := PH_MODEL % [model_name, model_name]
	if not _scene_cache.has(path):
		_scene_cache[path] = load(path) if ResourceLoader.exists(path) else null
	var scene: PackedScene = _scene_cache[path]
	if scene == null: return null
	var node: Node3D = scene.instantiate()
	add_child(node)
	node.rotation_degrees = Vector3(180.0 if hang else 0.0, rot_y, 0.0)
	var box := _bounds(node)
	if height > 0.0 and box.size.y > 0.001:
		node.scale = Vector3.ONE * (height / box.size.y)
		box = _bounds(node)
	var anchor: float = box.end.y if hang else box.position.y
	node.position = pos - Vector3(0, anchor - node.position.y, 0)
	for mi in node.find_children("*", "MeshInstance3D", true, false):
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node

## Bounding box of all meshes of a node in its parent's space.
func _bounds(node: Node3D) -> AABB:
	var inv: Transform3D = global_transform.affine_inverse()
	var box := AABB()
	var first := true
	for mi in node.find_children("*", "MeshInstance3D", true, false):
		if mi.mesh == null: continue
		var b: AABB = (inv * mi.global_transform) * mi.mesh.get_aabb()
		if first:
			box = b
			first = false
		else:
			box = box.merge(b)
	return box

## Photographic sky: a large inverted sphere with the tonemapped HDRI panorama. The
## matching HDR (main.gd) provides light and reflections.
## sky_y moves the photo's horizon: higher values hide more of the photographed ground.
func sky_dome(sky_name: String, rot_deg: float, tint: Color = Color.WHITE, sky_y: float = -8.0) -> void:
	var path := PH_SKY % sky_name
	if not ResourceLoader.exists(path): return
	var dome := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 220.0
	sph.height = 440.0
	sph.radial_segments = 64
	sph.rings = 32
	dome.mesh = sph
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.cull_mode = BaseMaterial3D.CULL_FRONT
	m.albedo_texture = load(path)
	m.albedo_color = tint
	m.uv1_scale = Vector3(-1, 1, 1)
	m.disable_fog = true
	m.disable_receive_shadows = true
	dome.material_override = m
	dome.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	dome.rotation_degrees.y = rot_deg
	dome.position.y = sky_y
	add_child(dome)

## Weather / ambience particles.
func particles(kind: String) -> void:
	var p := CPUParticles3D.new()
	var quad := QuadMesh.new()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.vertex_color_use_as_albedo = true
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	p.preprocess = 4.0
	p.local_coords = false
	match kind:
		"snow":
			p.amount = 260
			p.lifetime = 7.0
			p.position = Vector3(0, 13, -2)
			p.emission_box_extents = Vector3(28, 0.5, 10)
			p.direction = Vector3(0.15, -1, 0)
			p.spread = 12.0
			p.gravity = Vector3(0.3, -0.8, 0)
			p.initial_velocity_min = 1.0
			p.initial_velocity_max = 2.0
			quad.size = Vector2(0.07, 0.07)
			p.color = Color(1, 1, 1, 0.9)
		"rain":
			p.amount = 420
			p.lifetime = 1.2
			p.position = Vector3(0, 14, -2)
			p.emission_box_extents = Vector3(28, 0.5, 10)
			p.direction = Vector3(-0.1, -1, 0)
			p.spread = 2.0
			p.gravity = Vector3(0, -20, 0)
			p.initial_velocity_min = 10.0
			p.initial_velocity_max = 13.0
			quad.size = Vector2(0.018, 0.5)
			mat.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
			p.color = Color(0.7, 0.8, 1.0, 0.45)
		"embers":
			p.amount = 140
			p.lifetime = 6.0
			p.position = Vector3(0, -4, -3)
			p.emission_box_extents = Vector3(26, 1, 10)
			p.direction = Vector3(0.05, 1, 0)
			p.spread = 20.0
			p.gravity = Vector3(0.2, 0.3, 0)
			p.initial_velocity_min = 1.0
			p.initial_velocity_max = 2.4
			quad.size = Vector2(0.08, 0.08)
			mat.albedo_color = Color(2.5, 1.0, 0.3)
			p.color = Color(1.0, 0.55, 0.15)
		"petals":
			p.amount = 70
			p.lifetime = 8.0
			p.position = Vector3(0, 12, -2)
			p.emission_box_extents = Vector3(26, 1, 8)
			p.direction = Vector3(0.4, -1, 0)
			p.spread = 25.0
			p.gravity = Vector3(0.4, -0.5, 0)
			p.initial_velocity_min = 0.5
			p.initial_velocity_max = 1.2
			p.angular_velocity_min = -180
			p.angular_velocity_max = 180
			quad.size = Vector2(0.1, 0.07)
			p.color = Color(1.0, 0.5, 0.6)
		"fireflies":
			p.amount = 70
			p.lifetime = 6.0
			p.position = Vector3(0, 2.5, -2)
			p.emission_box_extents = Vector3(22, 3, 8)
			p.direction = Vector3(0, 1, 0)
			p.spread = 180.0
			p.gravity = Vector3.ZERO
			p.initial_velocity_min = 0.1
			p.initial_velocity_max = 0.5
			quad.size = Vector2(0.07, 0.07)
			mat.albedo_color = Color(1.8, 2.5, 1.2)
			p.color = Color(0.7, 1.0, 0.6)
		"dust", "spray":
			p.amount = 60
			p.lifetime = 7.0
			p.position = Vector3(0, 1.5 if kind == "dust" else -2.0, -2)
			p.emission_box_extents = Vector3(24, 2.5, 8)
			p.direction = Vector3(1, 0.2, 0)
			p.spread = 30.0
			p.gravity = Vector3(0.2, 0.05, 0)
			p.initial_velocity_min = 0.2
			p.initial_velocity_max = 0.8
			quad.size = Vector2(0.05, 0.05)
			p.color = Color(1.0, 0.92, 0.75, 0.5) if kind == "dust" else Color(0.85, 0.95, 1.0, 0.6)
	var grad := Gradient.new()
	grad.set_color(0, Color(1, 1, 1, 0.0))
	grad.add_point(0.15, Color(1, 1, 1, 1))
	grad.add_point(0.8, Color(1, 1, 1, 1))
	grad.set_color(grad.get_point_count() - 1, Color(1, 1, 1, 0.0))
	p.color_ramp = grad
	quad.material = mat
	p.mesh = quad
	add_child(p)

# ───────────────────────────────────────────────────────────── build ──

func build(id: String) -> void:
	for c in get_children(): c.queue_free()
	bobbers.clear()
	flickers.clear()
	rng.seed = hash(id)
	var th: Dictionary = THEMES.get(id, THEMES["blood_moon"])
	sky_dome(th.sky, th.sky_rot, th.get("sky_tint", Color.WHITE), float(th.get("sky_y", -8.0)))
	_stage(th)
	_platforms(th)
	var fn := "_scene_" + id
	if has_method(fn): call(fn, th)
	particles(th.weather)

## Main stage: textured top, trim that glows along the edges, themed underside.
func _stage(th: Dictionary) -> void:
	var width: float = Combat.STAGE_RIGHT - Combat.STAGE_LEFT
	var top_mat := pbr(th.top, 0.32)
	var side_mat := pbr(th.side, 0.25, th.rock_tint)
	box(Vector3(width + 0.3, 0.5, 5.2), Vector3(0, -0.25, -0.8), top_mat)
	var trim := glow(th.trim, 2.2)
	box(Vector3(width + 0.34, 0.07, 0.07), Vector3(0, -0.02, 1.82), trim, Vector3.ZERO, false)
	for side in [-1, 1]:
		box(Vector3(0.07, 0.07, 5.2), Vector3(side * (width * 0.5 + 0.17), -0.02, -0.8), trim, Vector3.ZERO, false)
		# Ledge caps mark the grab points.
		box(Vector3(0.35, 0.6, 5.3), Vector3(side * (width * 0.5 + 0.02), -0.35, -0.8), side_mat)
	match th.under:
		"island":
			box(Vector3(width - 0.4, 2.2, 4.6), Vector3(0, -1.6, -0.8), side_mat)
			# Hanging rock mass of scanned rocks; falls back to cones without the assets.
			var rocks_placed := 0
			for k in range(7):
				var rx: float = -width * 0.42 + k * width * 0.14
				var r := prop(["rock_face_01", "rock_face_02", "namaqualand_cliff_01"][k % 3], Vector3(rx, -0.6, -0.9 + rng.randf_range(-0.4, 0.4)),
					rng.randf_range(3.5, 6.0) * (1.0 - absf(rx) / width), rng.randf_range(0, 360), false, true)
				if r: rocks_placed += 1
			for k in range(0 if rocks_placed > 0 else 22):
				var x: float = rng.randf_range(-width * 0.45, width * 0.45)
				var h: float = rng.randf_range(1.5, 5.0) * (1.0 - absf(x) / width)
				var r: float = rng.randf_range(0.5, 1.4)
				cyl(r, 0.05, h, Vector3(x, -2.7 - h * 0.5, rng.randf_range(-2.5, 1.0)), side_mat, 7)
			for k in range(6):
				var cx: float = rng.randf_range(-width * 0.4, width * 0.4)
				var crystal := cyl(0.0, 0.22, 0.9, Vector3(cx, -3.0, 1.2), glow(th.trim, 3.0), 5, Vector3(180, 0, 0))
				crystal.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		"pedestal":
			box(Vector3(width - 0.6, 7.5, 4.0), Vector3(0, -4.0, -0.8), side_mat)
			for x in range(-8, 9, 2):
				cyl(0.35, 0.35, 7.0, Vector3(x, -4.0, 1.25), side_mat, 12)
		"pier":
			for x in range(-9, 10, 2):
				for z in [1.2, -2.6]:
					cyl(0.22, 0.26, 4.0, Vector3(x, -2.2, z), pbr("wood_planks", 0.5, Color(0.7, 0.6, 0.5)), 10)
		"tower":
			var tower := box(Vector3(width - 0.2, 40.0, 5.0), Vector3(0, -20.4, -0.8), shader_mat(WINDOW_SHADER, {"seed": 3.0}))
			tower.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			for side in [-1, 1]:
				box(Vector3(0.08, 40.0, 0.08), Vector3(side * (width * 0.5 - 0.1), -20.4, 1.72), glow(th.trim, 3.0), Vector3.ZERO, false)

## Pass-through platforms from the combat rules, dressed per theme.
func _platforms(th: Dictionary) -> void:
	for plat in Combat.PLATFORMS:
		var w: float = plat.x2 - plat.x1
		var cx: float = (plat.x1 + plat.x2) * 0.5
		box(Vector3(w + 0.1, 0.22, 1.7), Vector3(cx, plat.y - 0.11, -0.1), pbr(th.top, 0.4))
		box(Vector3(w + 0.14, 0.05, 0.05), Vector3(cx, plat.y - 0.01, 0.76), glow(th.trim, 2.0), Vector3.ZERO, false)
		var under := cyl(0.0, 0.26, 0.55, Vector3(cx, plat.y - 0.5, -0.1), glow(th.trim, 2.4), 6, Vector3(180, 0, 0))
		under.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		bobbers.append([under, under.position.y, rng.randf_range(1.0, 2.0), 0.06])

# ───────────────────────────────────────────────────────────── scenes ──

func _fire(pos: Vector3, color: Color = Color("ff8a2a"), energy: float = 2.2) -> void:
	var p := CPUParticles3D.new()
	p.amount = 40
	p.lifetime = 0.8
	p.position = pos
	p.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	p.emission_sphere_radius = 0.18
	p.direction = Vector3.UP
	p.spread = 12.0
	p.gravity = Vector3(0, 2.0, 0)
	p.initial_velocity_min = 0.6
	p.initial_velocity_max = 1.4
	p.scale_amount_min = 0.6
	p.scale_amount_max = 1.4
	var q := QuadMesh.new()
	q.size = Vector2(0.28, 0.28)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	m.vertex_color_use_as_albedo = true
	q.material = m
	p.mesh = q
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.85, 0.4, 1.0))
	grad.set_color(1, Color(color.r, color.g * 0.3, 0.0, 0.0))
	p.color_ramp = grad
	add_child(p)
	light(pos + Vector3(0, 0.3, 0.4), color, energy, 8.0, 9.0)

func _scene_blood_moon(th: Dictionary) -> void:
	var torii := "res://assets/models/arenas/arena_torii_gate.glb"
	if ResourceLoader.exists(torii):
		var g: Node3D = load(torii).instantiate()
		g.position = Vector3(0, -0.4, -10.0)
		g.scale = Vector3.ONE * 1.5
		add_child(g)
	for spec in [[-13.0, -9.0, 7.0], [12.0, -11.0, 8.0], [-22.0, -16.0, 9.0], [21.0, -15.0, 7.5]]:
		prop("quiver_tree_01", Vector3(spec[0], -1.5, spec[1]), spec[2], rng.randf_range(0, 360), false)
	prop("dead_tree_trunk_02", Vector3(-7.5, 0.0, -3.9), 0.7, 40.0)
	for x in [-30.0, -18.0, 17.0, 29.0]:
		prop(["rock_face_01", "rock_face_02"][int(absf(x)) % 2], Vector3(x, -6.0, -24.0), rng.randf_range(9, 14), rng.randf_range(0, 360), false)
	prop("gothic_statue", Vector3(8.2, 0.0, -3.5), 2.6, -20.0)
	for x in [-5.0, 4.0]:
		prop("wooden_lantern_01", Vector3(x, 0.0, -3.7), 1.2, 0.0)
		light(Vector3(x, 1.0, -3.0), Color("ff6a3d"), 1.4, 6.0, 7.0)
	for k in range(10):
		var lp := sphere(0.2, Vector3(rng.randf_range(-20, 20), rng.randf_range(5, 11), rng.randf_range(-14, -5)), glow(Color("ff5a3a"), 2.6), false)
		bobbers.append([lp, lp.position.y, rng.randf_range(0.4, 0.9), 0.35])
	# Blood-red moonlight from behind.
	var rim := DirectionalLight3D.new()
	rim.light_color = Color("ff3b3b")
	rim.light_energy = 0.8
	rim.rotation_degrees = Vector3(-20, 160, 0)
	add_child(rim)

func _scene_volcano_sanctum(th: Dictionary) -> void:
	var lava := plane(Vector2(200, 120), Vector3(0, -6.5, -30), shader_mat(LAVA_SHADER, {"uv_mult": Vector2(30, 18), "glow": 1.1}))
	lava.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for spec in [[-26.0, -22.0, 16.0], [24.0, -26.0, 20.0], [0.0, -40.0, 24.0], [-44.0, -34.0, 18.0], [44.0, -36.0, 22.0]]:
		prop("namaqualand_cliff_01", Vector3(spec[0], -7.0, spec[1]), spec[2], rng.randf_range(0, 360), false)
	for k in range(9):
		var x: float = rng.randf_range(-30, 30)
		if absf(x) < 11.0: x += signf(x) * 11.0
		prop(["rock_face_02", "boulder_01", "rock_07"][k % 3], Vector3(x, -7.0, rng.randf_range(-18, -7)), rng.randf_range(3, 8), rng.randf_range(0, 360), false)
	for x in [-18.0, 16.0, 30.0]:
		var fall := MeshInstance3D.new()
		var q := QuadMesh.new()
		q.size = Vector2(3.5, 22)
		fall.mesh = q
		fall.material_override = shader_mat(LAVA_SHADER, {"uv_mult": Vector2(2, 10), "flow": Vector2(0.0, -0.35), "glow": 1.6})
		fall.position = Vector3(x, 4.0, -26)
		add_child(fall)
		light(Vector3(x, -3.0, -22), Color("ff5a1a"), 1.6, 16.0, 3.0)
	for x in [-8.6, 8.6]:
		prop("stone_fire_pit", Vector3(x, 0.0, -3.4), 0.5, 0.0)
		_fire(Vector3(x, 0.5, -3.4))
	light(Vector3(0, -4.0, 2), Color("ff6a2a"), 1.2, 12.0, 2.0)

func _scene_imperial_colosseum(th: Dictionary) -> void:
	plane(Vector2(180, 140), Vector3(0, -7.2, -20), pbr("ph:large_sandstone_blocks_01", 0.08, Color(0.95, 0.85, 0.7)))
	var marble := pbr("ph:marble_01", 0.5)
	for x in [-8.4, 8.4]:
		box(Vector3(1.1, 0.6, 1.1), Vector3(x, 0.3, -3.4), marble)
		prop("gothic_statue", Vector3(x, 0.6, -3.4), 2.4, 180.0 if x > 0 else 0.0)
	for x in [-4.5, 4.5]:
		cyl(0.28, 0.32, 1.3, Vector3(x, 0.65, -3.6), marble, 16)
		prop("marble_bust_01", Vector3(x, 1.3, -3.6), 0.75, 0.0)
	prop("horse_statue_01", Vector3(-17.0, -7.2, -16.0), 9.0, 30.0, false)
	prop("horse_statue_01", Vector3(19.0, -7.2, -18.0), 9.0, -40.0, false)
	for x in [-11.0, -6.0, 6.0, 11.0]:
		prop("ceramic_vase_02", Vector3(x * 0.85, 0.0, -3.9), 0.75, rng.randf_range(0, 360))
	for x in [-10.6, 10.6]:
		prop("stone_fire_pit", Vector3(x, -7.2, -8.0), 1.2, 0.0, false)
		_fire(Vector3(x, -6.2, -8.0), Color("ffb347"), 3.0)

func _scene_pirate_galleon(th: Dictionary) -> void:
	plane(Vector2(260, 160), Vector3(0, -3.2, -30), shader_mat(WATER_SHADER, {}), 110)
	var wood := pbr("ph:brown_planks_07", 0.45)
	var dark_wood := pbr("ph:dark_planks", 0.45)
	var ship := Node3D.new()
	ship.position = Vector3(22, -3.0, -36)
	ship.rotation_degrees = Vector3(0, -18, 0)
	add_child(ship)
	for k in range(5):
		var hull := box(Vector3(22 - k * 1.6, 1.3, 7 - k * 0.8), Vector3(0, 0.7 + (4 - k) * 1.2, 0), dark_wood)
		hull.reparent(ship, false)
	var deck := box(Vector3(23, 0.3, 7.2), Vector3(0, 6.3, 0), wood)
	deck.reparent(ship, false)
	var sail := flat(Color(0.93, 0.9, 0.82), 0.95)
	for mx in [-6.0, 1.0, 7.0]:
		var mast := cyl(0.25, 0.32, 16.0, Vector3(mx, 14.0, 0), dark_wood, 10)
		mast.reparent(ship, false)
		for sy in [11.0, 16.0]:
			var sl := box(Vector3(6.5 - sy * 0.15, 3.8, 0.08), Vector3(mx, sy, 0.6), sail)
			sl.reparent(ship, false)
	bobbers.append([ship, ship.position.y, 0.5, 0.25])
	for spec in [[-16.0, -9.0, 0.0], [14.0, -12.0, 90.0]]:
		prop("modular_wooden_pier", Vector3(spec[0], -3.4, spec[1]), 3.0, spec[2], false)
	for x in [-8.5, 8.5]:
		prop("cannon_01", Vector3(x, 0.0, -3.1), 1.0, 90.0 if x < 0 else -90.0)
	prop("wooden_barrels_01", Vector3(-5.5, 0.0, -3.7), 1.1, 20.0)
	prop("Barrel_01", Vector3(5.0, 0.0, -3.6), 0.95, 0.0)
	prop("wooden_crate_02", Vector3(6.3, 0.0, -3.5), 0.7, 15.0)
	prop("treasure_chest", Vector3(1.8, 0.0, -3.7), 0.6, -10.0)
	for x in [-2.6, 3.6]:
		prop("Lantern_01", Vector3(x, 0.0, -3.9), 0.55, 0.0)
		light(Vector3(x, 0.8, -3.2), Color("ffcf7a"), 1.1, 6.0, 5.0)
	for k in range(6):
		prop(["rock_face_02", "rock_moss_set_02", "boulder_01"][k % 3], Vector3(rng.randf_range(-40, 40), -4.5, rng.randf_range(-30, -14)), rng.randf_range(2.5, 6), rng.randf_range(0, 360), false)

func _scene_gladiator_fortress(th: Dictionary) -> void:
	plane(Vector2(180, 140), Vector3(0, -7.2, -20), pbr("ph:large_sandstone_blocks_01", 0.08, Color(0.85, 0.75, 0.62)))
	var wall := pbr("ph:castle_brick_01", 0.2)
	box(Vector3(34, 13, 2.5), Vector3(0, -1.5, -14), wall)
	for x in range(-16, 17, 3):
		box(Vector3(1.4, 1.4, 2.6), Vector3(x, 5.7, -14), wall)
	prop("large_iron_gate", Vector3(0, -7.2, -12.6), 9.0, 0.0)
	for x in [-10.0, 10.0]:
		prop("stone_fire_pit", Vector3(x, 0.0, -3.4), 0.55, 0.0)
		_fire(Vector3(x, 0.55, -3.4))
	for x in [-6.0, -3.0, 3.0, 6.0]:
		prop("kite_shield", Vector3(x, 2.0, -12.7), 1.8, 0.0, false)
	prop("wine_barrel_01", Vector3(-7.4, 0.0, -3.7), 0.9, 0.0)
	prop("wooden_crate_02", Vector3(7.2, 0.0, -3.6), 0.8, 30.0)
	prop("Barrel_01", Vector3(8.1, 0.0, -3.9), 0.9, 0.0)

func _scene_mystic_grove(th: Dictionary) -> void:
	plane(Vector2(200, 140), Vector3(0, -5.5, -30), shader_mat(WATER_SHADER, {"deep_color": Color(0.01, 0.08, 0.07), "shallow_color": Color(0.05, 0.4, 0.33), "wave_height": 0.08}), 70)
	for k in range(8):
		var x: float = rng.randf_range(-32, 32)
		if absf(x) < 10.0: x += signf(x) * 10.0
		prop(["rock_moss_set_01", "rock_moss_set_02", "boulder_01", "tree_stump_01"][k % 4], Vector3(x, -5.8, rng.randf_range(-22, -8)), rng.randf_range(3, 7), rng.randf_range(0, 360), false)
	for spec in [[-15.0, -12.0], [16.0, -14.0], [-26.0, -20.0], [26.0, -22.0]]:
		prop("dead_tree_trunk_02", Vector3(spec[0], -5.8, spec[1]), 1.8, rng.randf_range(0, 360), false)
	for x in [-8.8, -7.2, 7.4, 8.9]:
		prop("fern_02", Vector3(x, 0.0, -3.6), 0.9, rng.randf_range(0, 360))
	prop("tree_stump_01", Vector3(-3.4, 0.0, -3.9), 0.7, 0.0)
	for k in range(12):
		var mx: float = rng.randf_range(-9, 9)
		var mz: float = rng.randf_range(-3.3, -2.4)
		cyl(0.05, 0.07, 0.4, Vector3(mx, 0.2, mz), flat(Color(0.85, 0.9, 0.8)), 6)
		var cap := sphere(0.18, Vector3(mx, 0.42, mz), glow(Color("22d3ee") if k % 2 == 0 else Color("c084fc"), 2.6), false)
		cap.scale = Vector3(1, 0.5, 1)
	light(Vector3(-6, 2.0, -2.5), Color("2dd4bf"), 1.6, 9.0, 1.0)
	light(Vector3(6, 2.0, -2.5), Color("c084fc"), 1.4, 9.0, 1.3)

func _scene_frozen_summit(th: Dictionary) -> void:
	var ice := pbr("ice", 0.25)
	plane(Vector2(200, 140), Vector3(0, -6.2, -30), pbr("ph:snow_02", 0.1))
	for k in range(10):
		var x: float = rng.randf_range(-40, 40)
		if absf(x) < 11.0: x += signf(x) * 11.0
		prop(["rock_face_01", "rock_face_02", "boulder_01"][k % 3], Vector3(x, -6.4, rng.randf_range(-30, -9)), rng.randf_range(4, 12), rng.randf_range(0, 360), false)
	for k in range(10):
		var x: float = rng.randf_range(-36, 36)
		var h: float = rng.randf_range(4, 12)
		cyl(0.0, rng.randf_range(0.7, 1.6), h, Vector3(x, -6.2 + h * 0.5, rng.randf_range(-28, -10)), ice, 6)
	prop("dead_tree_trunk_02", Vector3(-8.0, 0.0, -3.8), 0.7, 20.0)
	prop("moon_rock_03", Vector3(7.5, 0.0, -3.6), 0.8, 0.0)
	for k in range(8):
		var cx: float = rng.randf_range(-9, 9)
		var cl := cyl(0.0, 0.16, rng.randf_range(0.5, 1.1), Vector3(cx, 0.3, -3.0), glow(Color("9be7ff"), 1.6), 5)
		cl.rotation_degrees = Vector3(rng.randf_range(-20, 20), 0, rng.randf_range(-20, 20))
	light(Vector3(-5, 2.5, -2.0), Color("9be7ff"), 1.3, 10.0)
	light(Vector3(5, 2.5, -2.0), Color("c4b5fd"), 1.0, 10.0)

func _scene_neon_metropolis(th: Dictionary) -> void:
	var neon := [Color("ff3db4"), Color("22d3ee"), Color("a855f7"), Color("facc15")]
	# Roof edge of a neighbouring block hides the photo's street level; the skyline stays.
	var block := box(Vector3(140, 32, 12), Vector3(0, -14.0, -30), shader_mat(WINDOW_SHADER, {"seed": 11.0, "lit_ratio": 0.35}))
	block.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	box(Vector3(140, 0.25, 0.25), Vector3(0, 2.1, -23.9), glow(Color("22d3ee"), 3.0), Vector3.ZERO, false)
	# Two nearby towers frame the stage; the real skyline is the photographed backdrop.
	for k in range(2):
		var x: float = -19.0 if k == 0 else 20.0
		var bld := box(Vector3(9, 60, 9), Vector3(x, -30 + 30, -16), shader_mat(WINDOW_SHADER, {"seed": float(k + 5), "lit_ratio": 0.3}))
		bld.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for j in range(3):
			var sgn := box(Vector3(0.3, 4.0, 1.4), Vector3(x + (4.7 if k == 0 else -4.7), 4.0 + j * 7.0, -13.0), glow(neon[(k + j) % neon.size()], 4.0), Vector3.ZERO, false)
			flickers.append([sgn.material_override, 4.0, rng.randf_range(3.0, 9.0)])
	for x in [-8.8, 8.8]:
		prop("street_lamp_02", Vector3(x, 0.0, -3.6), 3.2, 90.0 if x < 0 else -90.0)
		light(Vector3(x * 0.9, 3.0, -3.0), Color("ffd9a8"), 1.2, 8.0)
	prop("modular_industrial_pipes_01", Vector3(-3.5, 0.0, -4.0), 1.4, 0.0)
	prop("security_light", Vector3(4.5, 1.8, -4.0), 0.4, 0.0)
	prop("Barrel_01", Vector3(6.2, 0.0, -3.6), 0.9, 0.0)
	prop("wooden_crate_02", Vector3(-6.6, 0.0, -3.6), 0.8, 10.0)
	var holo := Label3D.new()
	holo.text = "PROMPT FIGHTER"
	holo.font_size = 180
	holo.pixel_size = 0.02
	holo.modulate = Color(1.6, 0.5, 1.4, 0.9)
	holo.outline_size = 0
	holo.position = Vector3(0, 9.5, -16)
	add_child(holo)
	flickers.append([holo, 1.0, 11.0])
	light(Vector3(-6, 3.0, -1.5), Color("ff3db4"), 2.0, 11.0, 2.5)
	light(Vector3(6, 3.0, -1.5), Color("22d3ee"), 2.0, 11.0, 3.1)

# ───────────────────────────────────────────────────────────── animation ──

func _process(delta: float) -> void:
	time += delta
	for b in bobbers:
		if is_instance_valid(b[0]):
			b[0].position.y = b[1] + sin(time * b[2] + b[1]) * b[3]
	for f in flickers:
		if not is_instance_valid(f[0]): continue
		var k: float = 0.85 + 0.15 * sin(time * f[2]) * sin(time * f[2] * 1.7 + 1.3)
		if f[0] is OmniLight3D: f[0].light_energy = f[1] * k
		elif f[0] is StandardMaterial3D: f[0].emission_energy_multiplier = f[1] * (0.6 + 0.4 * k)
		elif f[0] is Label3D: f[0].modulate.a = 0.7 + 0.3 * k

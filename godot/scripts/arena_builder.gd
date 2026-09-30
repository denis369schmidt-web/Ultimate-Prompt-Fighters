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
## Hand-modelled Blender props (art/blender/generated/*.py).
const GEN_MODEL := "res://assets/models/generated/%s.glb"
const Backgrounds = preload("res://scripts/backgrounds.gd")
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
	"heaven_gate": {"top": "ph:marble_01", "side": "ph:large_sandstone_blocks", "trim": Color("ffb13b"), "under": "island", "weather": "embers", "rock_tint": Color("f3e3c3"), "sky": "rogland_sunset", "sky_rot": 180.0, "sky_tint": Color(1.0, 0.72, 0.45), "sky_energy": 1.4},
	"wheel_heaven": {"top": "ph:marble_01", "side": "ph:castle_wall_slates", "trim": Color("ffd24a"), "under": "island", "weather": "dust", "rock_tint": Color("d8c9a8"), "sky": "rogland_moonlit_night", "sky_rot": 60.0, "sky_tint": Color(0.75, 0.62, 0.35), "sky_energy": 1.6},
	"empyrean": {"top": "ph:volcanic_rock_tiles", "side": "ph:dark_rock", "trim": Color("ff3b1f"), "under": "island", "weather": "embers", "rock_tint": Color("8a5a4a"), "sky": "rogland_moonlit_night", "sky_rot": 200.0, "sky_tint": Color(0.75, 0.2, 0.12), "sky_energy": 1.5},
	"hell_gate": {"top": "ph:dark_rock", "side": "ph:volcanic_rock_tiles", "trim": Color("b91c1c"), "under": "island", "weather": "embers", "rock_tint": Color("5a4a44"), "sky": "rogland_moonlit_night", "sky_rot": 120.0, "sky_tint": Color(0.45, 0.12, 0.08), "sky_energy": 1.2},
	"hell_flames": {"top": "ph:volcanic_rock_tiles", "side": "ph:dark_rock", "trim": Color("ff5a1f"), "under": "island", "weather": "embers", "rock_tint": Color("6a4a3a"), "sky": "rogland_sunset", "sky_rot": 250.0, "sky_tint": Color(0.7, 0.18, 0.08), "sky_energy": 1.3},
	"hell_city": {"top": "ph:castle_wall_slates", "side": "ph:castle_brick_01", "trim": Color("f97316"), "under": "pedestal", "weather": "embers", "rock_tint": Color("4a3a36"), "sky": "rogland_moonlit_night", "sky_rot": 300.0, "sky_tint": Color(0.5, 0.1, 0.06), "sky_energy": 1.3},
	"cocytus": {"top": "ph:snow_02", "side": "ph:rock_wall_10", "trim": Color("7dd3fc"), "under": "island", "weather": "snow", "rock_tint": Color("8aa4c0"), "sky": "rogland_moonlit_night", "sky_rot": 30.0, "sky_tint": Color(0.3, 0.42, 0.62), "sky_energy": 1.2},
	"heaven_spheres": {"top": "ph:marble_01", "side": "ph:large_sandstone_blocks", "trim": Color("bfe3ff"), "under": "island", "weather": "fireflies", "rock_tint": Color("e8dcc4"), "sky": "rogland_moonlit_night", "sky_rot": 160.0, "sky_tint": Color(0.55, 0.62, 0.9), "sky_energy": 1.6},
	"neon_metropolis": {"top": "ph:metal_plate", "side": "ph:concrete_panels", "trim": Color("ff3db4"), "under": "tower", "weather": "rain", "rock_tint": Color("ffffff"), "sky": "shanghai_bund", "sky_rot": 90.0, "sky_energy": 2.2, "sky_y": -2.0},
}

var time := 0.0
var bobbers: Array = []        # [node, base_y, speed, amplitude]
var rotors: Array = []         # [node, axis, speed] – slowly turning scenery (boss levels)
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
	return _place(PH_MODEL % [model_name, model_name], pos, height, rot_y, shadows, hang)

## Places one of the generated Blender models; null when it has not been built.
func gen_prop(model_name: String, pos: Vector3, height: float, rot_y: float = 0.0, shadows: bool = true) -> Node3D:
	return _place(GEN_MODEL % model_name, pos, height, rot_y, shadows, false)

func _place(path: String, pos: Vector3, height: float, rot_y: float, shadows: bool, hang: bool) -> Node3D:
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
	rotors.clear()
	rng.seed = hash(id)
	var th: Dictionary = theme_for(id)
	sky_dome(th.sky, th.sky_rot, th.get("sky_tint", Color.WHITE), float(th.get("sky_y", -8.0)))
	_stage(th)
	_platforms(th)
	var fn := "_scene_" + id
	var bg: Dictionary = Backgrounds.for_arena(id)
	if has_method(fn): call(fn, th)
	elif not bg.is_empty(): call("_motif_" + str(bg.motif), th, bg)
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
	var galleon := gen_prop("galleon", Vector3.ZERO, 0.0, 0.0, false)
	if galleon != null:
		# Waterline origin, bow along -Z: turn it broadside to the camera.
		galleon.reparent(ship, false)
		galleon.position = Vector3.ZERO
		galleon.rotation_degrees = Vector3(0, 90, 0)
		galleon.scale = Vector3.ONE * 0.8
	else:
		_box_ship(ship, wood, dark_wood)
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

## Simple box ship, used when the Blender galleon has not been built.
func _box_ship(ship: Node3D, wood: Material, dark_wood: Material) -> void:
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
		var z: float = rng.randf_range(-28, -10)
		var crystal: String = ["ice_spire", "ice_cluster_large"][k % 2]
		if gen_prop(crystal, Vector3(x, -6.2, z), h, rng.randf_range(0, 360), false) == null:
			cyl(0.0, rng.randf_range(0.7, 1.6), h, Vector3(x, -6.2 + h * 0.5, z), ice, 6)
	prop("dead_tree_trunk_02", Vector3(-8.0, 0.0, -3.8), 0.7, 20.0)
	prop("moon_rock_03", Vector3(7.5, 0.0, -3.6), 0.8, 0.0)
	for x in [-9.6, 9.8]:
		gen_prop("ice_cluster_small", Vector3(x, 0.0, -3.4), 0.9, rng.randf_range(0, 360))
	for k in range(8):
		var cx: float = rng.randf_range(-9, 9)
		var cl := cyl(0.0, 0.16, rng.randf_range(0.5, 1.1), Vector3(cx, 0.3, -3.0), glow(Color("9be7ff"), 1.6), 5)
		cl.rotation_degrees = Vector3(rng.randf_range(-20, 20), 0, rng.randf_range(-20, 20))
	light(Vector3(-5, 2.5, -2.0), Color("9be7ff"), 1.3, 10.0)
	light(Vector3(5, 2.5, -2.0), Color("c4b5fd"), 1.0, 10.0)

# ── Boss levels ──

## Sea of clouds below the stage.
func _clouds(tint: Color, y: float = -3.5, count: int = 40) -> void:
	var cm := flat(tint, 1.0)
	for k in range(count):
		var c := sphere(rng.randf_range(2.0, 5.0), Vector3(rng.randf_range(-45, 45), y + rng.randf_range(-1.5, 1.0), rng.randf_range(-30, 4)), cm, false)
		c.scale = Vector3(1.6, 0.45, 1.0)
		bobbers.append([c, c.position.y, rng.randf_range(0.15, 0.35), 0.3])

## Background eye (sclera, iris, pupil) looking at the stage.
func _sky_eye(pos: Vector3, r: float, iris: Color) -> Node3D:
	var e := Node3D.new()
	e.position = pos
	add_child(e)
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	add_mesh(s, Vector3.ZERO, glow(Color(0.95, 0.9, 0.82), 0.6), Vector3.ZERO, e, false)
	var d := CylinderMesh.new()
	d.top_radius = r * 0.55
	d.bottom_radius = r * 0.55
	d.height = r * 0.1
	add_mesh(d, Vector3(0, 0, r * 0.92), glow(iris, 3.0), Vector3(90, 0, 0), e, false)
	var pu := CylinderMesh.new()
	pu.top_radius = r * 0.25
	pu.bottom_radius = r * 0.25
	pu.height = r * 0.12
	add_mesh(pu, Vector3(0, 0, r * 0.97), flat(Color(0.01, 0, 0)), Vector3(90, 0, 0), e, false)
	return e

func _scene_heaven_gate(th: Dictionary) -> void:
	_clouds(Color(0.78, 0.66, 0.52))
	var gold := flat(Color("c9a227"), 0.3, 1.0)
	var marble := pbr("ph:marble_01", 0.2)
	# The gate: two colossal pillars and an arch, a flaming sword turning in front of it.
	for side in [-1.0, 1.0]:
		cyl(1.2, 1.4, 22.0, Vector3(side * 9.0, 6.0, -18.0), marble, 18)
		cyl(1.7, 1.7, 1.0, Vector3(side * 9.0, 17.3, -18.0), gold, 18)
	var arch := TorusMesh.new()
	arch.inner_radius = 8.2
	arch.outer_radius = 9.8
	add_mesh(arch, Vector3(0, 17.0, -18.0), gold, Vector3(90, 0, 0), null, false)
	var light_wall := box(Vector3(16.0, 20.0, 0.2), Vector3(0, 7.0, -19.5), glow(Color("ffcf7a"), 0.5), Vector3.ZERO, false)
	light_wall.transparency = 0.75
	var sword := Node3D.new()
	sword.position = Vector3(0, 12.0, -16.5)
	add_child(sword)
	add_mesh(BoxMesh.new(), Vector3.ZERO, glow(Color("ff7a1a"), 5.0), Vector3.ZERO, sword, false).scale = Vector3(0.5, 11.0, 0.12)
	add_mesh(BoxMesh.new(), Vector3(0, -5.8, 0), gold, Vector3.ZERO, sword, false).scale = Vector3(3.0, 0.4, 0.4)
	rotors.append([sword, Vector3(0, 0, 1), 0.35])
	for k in range(8):
		var ray := cyl(0.15, 0.6, 40.0, Vector3(rng.randf_range(-30, 30), 12.0, rng.randf_range(-28, -10)), glow(Color("ffe7a8"), 1.2), 8)
		ray.transparency = 0.88
		ray.rotation_degrees = Vector3(0, 0, rng.randf_range(-12, 12))
	light(Vector3(0, 6.0, -8.0), Color("ffc46b"), 2.0, 22.0, 1.0)
	light(Vector3(0, 3.0, 2.0), Color("ffe2b0"), 1.2, 12.0)

func _scene_wheel_heaven(th: Dictionary) -> void:
	_clouds(Color(0.55, 0.5, 0.42), -4.0, 30)
	var gold := flat(Color("c9a227"), 0.28, 1.0)
	# Colossal wheels within wheels turning in the sky, their rims full of eyes.
	for spec in [[Vector3(-14, 9, -26), 7.0], [Vector3(15, 11, -30), 9.0], [Vector3(0, 16, -40), 13.0]]:
		var wheel := Node3D.new()
		wheel.position = spec[0]
		add_child(wheel)
		for k in range(3):
			var ring := Node3D.new()
			ring.rotation_degrees = [Vector3(90, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 90)][k]
			wheel.add_child(ring)
			var t := TorusMesh.new()
			t.inner_radius = float(spec[1]) * (1.0 - k * 0.12) - 0.3
			t.outer_radius = float(spec[1]) * (1.0 - k * 0.12) + 0.3
			t.rings = 48
			add_mesh(t, Vector3.ZERO, gold, Vector3.ZERO, ring, false)
			for e in range(10):
				var a: float = TAU * e / 10.0
				var rr: float = float(spec[1]) * (1.0 - k * 0.12)
				var eye := _sky_eye(Vector3.ZERO, 0.45, Color("ffcc33"))
				eye.reparent(ring, false)
				eye.position = Vector3(cos(a) * rr, 0, sin(a) * rr)
			rotors.append([ring, [Vector3(0, 1, 0), Vector3(1, 0, 0), Vector3(0, 0, 1)][k], 0.12 + k * 0.05])
		rotors.append([wheel, Vector3(0, 1, 0), 0.06])
		light(spec[0], Color("ffd98a"), 1.5, float(spec[1]) * 2.0, 0.6)
	light(Vector3(0, 4.0, -4.0), Color("ffe08a"), 1.6, 16.0)

func _scene_empyrean(th: Dictionary) -> void:
	_clouds(Color(0.35, 0.08, 0.05), -4.5, 30)
	# A colossal eye opens in the burning sky, framed by wings of light.
	var eye := _sky_eye(Vector3(0, 13.0, -45.0), 8.0, Color("ff2a1a"))
	bobbers.append([eye, eye.position.y, 0.2, 0.6])
	for side in [-1.0, 1.0]:
		for k in range(9):
			var feather := box(Vector3(2.2, 18.0 - k, 0.2), Vector3(side * (10.0 + k * 3.0), 12.0 + k * 0.6, -46.0), glow(Color("ff5a1f").lerp(Color("ffd24a"), k / 9.0), 1.4), Vector3(0, 0, -side * (20.0 + k * 9.0)), false)
			feather.transparency = 0.25
	for k in range(14):
		var col := cyl(0.3, 0.9, 30.0, Vector3(rng.randf_range(-40, 40), 5.0, rng.randf_range(-35, -15)), glow(Color("ff4a1f"), 2.2), 8)
		col.transparency = 0.55
		flickers.append([col.material_override, 2.2, rng.randf_range(2.0, 5.0)])
	for k in range(20):
		var fp := box(Vector3(0.15, 0.7, 0.03), Vector3(rng.randf_range(-18, 18), rng.randf_range(3, 12), rng.randf_range(-12, -3)), glow(Color("ffb13b"), 2.0), Vector3(0, 0, rng.randf_range(0, 360)), false)
		bobbers.append([fp, fp.position.y, rng.randf_range(0.3, 0.8), 0.5])
	light(Vector3(0, 5.0, -6.0), Color("ff5a3a"), 2.2, 20.0, 3.0)
	light(Vector3(0, 3.0, 2.0), Color("ffb08a"), 1.0, 12.0)

# ── Inferno ──

## Pale lost souls drifting in the dark.
func _souls(count: int, color: Color) -> void:
	for k in range(count):
		var soul := sphere(rng.randf_range(0.12, 0.25), Vector3(rng.randf_range(-24, 24), rng.randf_range(0.5, 9.0), rng.randf_range(-18, -4)), glow(color, 1.8), false)
		soul.scale = Vector3(1, 1.6, 1)
		bobbers.append([soul, soul.position.y, rng.randf_range(0.3, 0.8), 0.6])

func _scene_hell_gate(th: Dictionary) -> void:
	var stone := pbr("ph:dark_rock", 0.2, Color(0.5, 0.42, 0.4))
	# The gate of hell with its inscription.
	for side in [-1.0, 1.0]:
		box(Vector3(3.0, 20.0, 3.0), Vector3(side * 8.5, 7.0, -17.0), stone)
	box(Vector3(20.0, 3.5, 3.2), Vector3(0, 17.5, -17.0), stone)
	var words := Label3D.new()
	words.text = "LASST, DIE IHR EINTRETET, ALLE HOFFNUNG FAHREN"
	words.font_size = 110
	words.pixel_size = 0.012
	words.modulate = Color("ff5a3a")
	words.outline_size = 12
	words.position = Vector3(0, 17.5, -15.3)
	add_child(words)
	flickers.append([words, 1.0, 3.0])
	var dark := box(Vector3(14.0, 16.0, 0.4), Vector3(0, 7.0, -17.5), flat(Color(0.02, 0.0, 0.0)), Vector3.ZERO, false)
	dark.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# The dark river below.
	var river := plane(Vector2(200, 80), Vector3(0, -4.5, -20), shader_mat(WATER_SHADER, {}))
	river.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for spec in [[-13.0, -9.0, 7.0], [12.0, -11.0, 8.0], [-22.0, -14.0, 9.0], [20.0, -13.0, 7.5]]:
		prop("dead_tree_trunk_02", Vector3(spec[0], -1.2, spec[1]), spec[2] * 0.4, rng.randf_range(0, 360), false)
	_souls(26, Color("e2e8f0"))
	light(Vector3(0, 6.0, -12.0), Color("ff3b1f"), 2.0, 20.0, 2.0)
	light(Vector3(0, 3.0, 2.0), Color("ff8a6a"), 0.9, 12.0)

func _scene_hell_flames(th: Dictionary) -> void:
	var lava := plane(Vector2(220, 90), Vector3(0, -3.8, -20), shader_mat(LAVA_SHADER, {}))
	lava.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var rock := pbr("ph:dark_rock", 0.2, Color(0.35, 0.25, 0.22))
	for k in range(12):
		var x: float = rng.randf_range(-40, 40)
		if absf(x) < 11.0: x += signf(x) * 11.0
		var h: float = rng.randf_range(6, 16)
		cyl(rng.randf_range(0.8, 2.0), rng.randf_range(1.5, 3.0), h, Vector3(x, -3.8 + h * 0.5, rng.randf_range(-30, -10)), rock, 7)
		_fire(Vector3(x, -3.8 + h + 0.3, rng.randf_range(-30, -10)), Color("ff5a1f"), 2.6)
	# Burning tombs along the back of the stage.
	for x in [-8.0, -4.5, 4.5, 8.0]:
		box(Vector3(1.4, 0.7, 0.8), Vector3(x, 0.35, -3.6), rock)
		_fire(Vector3(x, 0.8, -3.6), Color("ff7a1a"), 1.8)
	_souls(18, Color("fecaca"))
	light(Vector3(0, 2.0, -6.0), Color("ff4a1f"), 2.4, 20.0, 4.0)

func _scene_hell_city(th: Dictionary) -> void:
	var iron := flat(Color(0.12, 0.1, 0.1), 0.5, 0.8)
	var ember := glow(Color("ff5a1f"), 2.5)
	# The iron walls and towers of the city of Dis.
	box(Vector3(120, 10, 3), Vector3(0, 1.0, -28), iron)
	for k in range(9):
		var x: float = -40.0 + k * 10.0
		var h: float = rng.randf_range(14, 24)
		box(Vector3(4.0, h, 4.0), Vector3(x, h * 0.5 - 4.0, -30), iron)
		cyl(0.0, 2.8, 4.0, Vector3(x, h - 2.0, -30), iron, 4)
		for w in range(3):
			var win := box(Vector3(0.6, 1.2, 0.1), Vector3(x, h * 0.3 + w * 3.0 - 4.0, -27.9), ember, Vector3.ZERO, false)
			flickers.append([win.material_override, 2.5, rng.randf_range(2.0, 6.0)])
		_fire(Vector3(x, h + 0.2, -30), Color("ff5a1f"), 2.0)
	for k in range(14):
		cyl(0.0, 0.25, rng.randf_range(1.5, 3.0), Vector3(rng.randf_range(-20, 20), -0.2, rng.randf_range(-12, -5)), iron, 4)
	_souls(14, Color("fed7aa"))
	light(Vector3(0, 5.0, -10.0), Color("ff6a2a"), 2.0, 22.0, 2.5)
	light(Vector3(0, 3.0, 2.0), Color("ffb08a"), 0.8, 12.0)

func _scene_cocytus(th: Dictionary) -> void:
	var ice := pbr("ice", 0.2)
	plane(Vector2(220, 120), Vector3(0, -5.5, -30), ice)
	# Souls frozen in the lake, the giant wings of the fallen one behind.
	var frozen := glow(Color("bae6fd"), 0.6)
	for k in range(30):
		var s := cyl(0.25, 0.3, 1.0, Vector3(rng.randf_range(-40, 40), -5.2, rng.randf_range(-30, -6)), frozen, 8)
		s.rotation_degrees = Vector3(rng.randf_range(-40, 40), 0, rng.randf_range(-60, 60))
	var wing_m := flat(Color(0.05, 0.06, 0.1), 0.8)
	for side in [-1.0, 1.0]:
		for k in range(5):
			box(Vector3(1.0, 26.0 - k * 3.0, 0.3), Vector3(side * (8.0 + k * 5.0), 9.0 - k, -44.0), wing_m, Vector3(0, 0, -side * (25.0 + k * 12.0)), false)
	for k in range(12):
		var x: float = rng.randf_range(-36, 36)
		var h: float = rng.randf_range(4, 12)
		if gen_prop(["ice_spire", "ice_cluster_large"][k % 2], Vector3(x, -5.5, rng.randf_range(-28, -10)), h, rng.randf_range(0, 360), false) == null:
			cyl(0.0, 1.2, h, Vector3(x, -5.5 + h * 0.5, rng.randf_range(-28, -10)), ice, 6)
	light(Vector3(0, 4.0, -6.0), Color("7dd3fc"), 1.6, 18.0, 1.0)
	light(Vector3(0, 3.0, 2.0), Color("c7d2fe"), 0.9, 12.0)

# ── Paradiso ──

func _scene_heaven_spheres(th: Dictionary) -> void:
	_clouds(Color(0.72, 0.74, 0.86), -4.0, 30)
	# The spheres of heaven: moon, planets and the sun, circling on golden rings.
	var specs := [[Vector3(-18, 9, -34), 3.0, Color("e2e8f0")], [Vector3(-6, 14, -44), 2.0, Color("fbbf24")], [Vector3(8, 12, -40), 2.6, Color("f9a8d4")],
		[Vector3(20, 10, -36), 5.0, Color("fff3b0")], [Vector3(30, 17, -50), 2.4, Color("f87171")], [Vector3(-30, 16, -48), 3.4, Color("fdba74")]]
	for spec in specs:
		var planet := sphere(float(spec[1]), spec[0], glow(spec[2], 1.2 if float(spec[1]) < 4.0 else 3.0), false)
		bobbers.append([planet, planet.position.y, rng.randf_range(0.1, 0.2), 0.8])
		var ring := TorusMesh.new()
		ring.inner_radius = float(spec[1]) * 1.5
		ring.outer_radius = float(spec[1]) * 1.58
		ring.rings = 64
		var rn := add_mesh(ring, spec[0], flat(Color("c9a227"), 0.3, 1.0), Vector3(70, 0, 20), null, false)
		rotors.append([rn, Vector3(0, 1, 0), 0.1])
	for k in range(60):
		var star := sphere(rng.randf_range(0.05, 0.14), Vector3(rng.randf_range(-60, 60), rng.randf_range(4, 30), rng.randf_range(-60, -25)), glow(Color("fff7e0"), 3.0), false)
		flickers.append([star.material_override, 3.0, rng.randf_range(1.0, 4.0)])
	light(Vector3(0, 5.0, -6.0), Color("dbeafe"), 1.6, 18.0, 0.6)

# ── Shop arenas: one builder per motif (backgrounds.gd), tuned by the background's colors ──

## Theme of an arena: fixed arenas from THEMES, shop arenas from their background.
static func theme_for(id: String) -> Dictionary:
	if THEMES.has(id): return THEMES[id]
	var bg: Dictionary = Backgrounds.for_arena(id)
	return Backgrounds.theme(bg) if not bg.is_empty() else THEMES["blood_moon"]

## A building facade: body with lit windows, optional neon edge.
func _facade(pos: Vector3, size: Vector3, seed_v: float, neon: Color = Color(0, 0, 0, 0)) -> void:
	var b := box(size, pos, shader_mat(WINDOW_SHADER, {"seed": seed_v, "lit_ratio": 0.24, "cell": Vector2(0.55, 0.8)}))
	b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if neon.a > 0.0:
		box(Vector3(0.12, size.y * 0.8, 0.12), pos + Vector3(size.x * 0.5, 0, size.z * 0.5), glow(neon, 3.0), Vector3.ZERO, false)

## Glowing neon sign that flickers.
func _neon_sign(pos: Vector3, size: Vector2, color: Color) -> void:
	var s := box(Vector3(size.x, size.y, 0.08), pos, glow(color, 3.2), Vector3.ZERO, false)
	flickers.append([s.material_override, 3.2, rng.randf_range(3.0, 9.0)])

func _motif_city_street(th: Dictionary, bg: Dictionary) -> void:
	var neon := [bg.trim, bg.accent, Color("facc15"), Color("a855f7")]
	# Two rows of buildings running into the depth, a wet street between them.
	for side in [-1.0, 1.0]:
		for k in range(7):
			var z: float = -6.0 - k * 7.0
			var h: float = rng.randf_range(10, 26)
			_facade(Vector3(side * rng.randf_range(12, 15), h * 0.5 - 4.0, z), Vector3(6, h, 6), float(k) + side * 3.0, neon[k % 4])
			for s in range(2):
				_neon_sign(Vector3(side * 9.2, rng.randf_range(2.0, 7.0), z + rng.randf_range(-2, 2)), Vector2(rng.randf_range(0.6, 1.6), rng.randf_range(1.2, 3.0)), neon[(k + s) % 4])
	var street := plane(Vector2(22, 60), Vector3(0, -2.0, -30), flat(Color(0.04, 0.04, 0.06), 0.08, 0.6))
	street.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	if bg.get("graffiti", false):
		for k in range(8):
			var side2: float = -1.0 if k % 2 == 0 else 1.0
			box(Vector3(0.05, 2.5, 4.0), Vector3(side2 * 9.05, 0.5, -6.0 - k * 5.0), glow(neon[k % 4].darkened(0.3), 0.8), Vector3.ZERO, false)
	for x in [-8.5, 8.5]:
		prop("street_lamp_02", Vector3(x, 0.0, -3.6), 3.2, 0.0)
		light(Vector3(x, 3.0, -3.0), Color("ffd8a8"), 1.3, 8.0, 0.5)
	for x in [-6.0, 6.5]:
		prop("wooden_barrels_01", Vector3(x, 0.0, -3.8), 1.0, rng.randf_range(0, 360))
	# Police lights flickering down the street.
	light(Vector3(-4.0, 1.0, -20.0), Color("ef4444"), 2.0, 12.0, 8.0)
	light(Vector3(4.0, 1.0, -22.0), Color("3b82f6"), 2.0, 12.0, 7.0)
	light(Vector3(0, 4.0, -8.0), bg.trim, 1.6, 18.0, 1.5)

func _motif_temple(th: Dictionary, bg: Dictionary) -> void:
	var jungle: bool = bg.get("jungle", false)
	var stone := pbr("ph:mossy_rock" if jungle else "ph:japanese_stone_wall", 0.25, Color(0.7, 0.72, 0.62) if jungle else Color(0.6, 0.58, 0.55))
	# Temple front: pillars, lintel, carved relief panels, torches.
	for x in [-11.0, -5.5, 5.5, 11.0]:
		cyl(1.0, 1.2, 16.0, Vector3(x, 4.0, -16.0), stone, 14)
	box(Vector3(26.0, 2.2, 3.0), Vector3(0, 12.6, -16.0), stone)
	box(Vector3(22.0, 3.0, 2.0), Vector3(0, 15.0, -16.5), stone)
	for x in [-8.2, 8.2]:
		box(Vector3(3.6, 5.0, 0.6), Vector3(x, 4.0, -15.2), pbr("ph:large_sandstone_blocks", 0.5, Color(0.55, 0.5, 0.45)))
		prop("lion_head", Vector3(x, 4.2, -14.8), 2.2, 0.0)
	var door := box(Vector3(6.0, 9.0, 0.3), Vector3(0, 3.5, -16.8), flat(Color(0.02, 0.02, 0.03)))
	door.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for x in [-3.8, 3.8]:
		cyl(0.2, 0.3, 1.6, Vector3(x, 0.8, -4.0), stone, 8)
		_fire(Vector3(x, 1.7, -4.0), bg.accent, 2.2)
	if jungle:
		for k in range(14):
			prop(["fern_02", "rock_moss_set_01", "rock_moss_set_02"][k % 3], Vector3(rng.randf_range(-22, 22), -0.2 if k % 3 == 0 else -1.0, rng.randf_range(-14, -4)), rng.randf_range(1.0, 3.0), rng.randf_range(0, 360), false)
		for k in range(10):
			var vine := cyl(0.05, 0.08, rng.randf_range(4, 9), Vector3(rng.randf_range(-12, 12), 9.0, -14.8), flat(Color(0.18, 0.35, 0.15)), 6)
			vine.rotation_degrees = Vector3(0, 0, rng.randf_range(-8, 8))
		for k in range(6):
			var shaft := cyl(0.4, 1.4, 22.0, Vector3(rng.randf_range(-16, 16), 8.0, rng.randf_range(-12, -6)), glow(Color("f0fdf4"), 0.6), 8)
			shaft.transparency = 0.85
			shaft.rotation_degrees = Vector3(0, 0, 18)
	else:
		sphere(3.0, Vector3(-14.0, 20.0, -40.0), glow(Color("f1f5f9"), 2.2), false)
	light(Vector3(0, 5.0, -8.0), bg.accent, 1.6, 16.0, 2.5)

func _motif_scifi_city(th: Dictionary, bg: Dictionary) -> void:
	for k in range(16):
		var x: float = rng.randf_range(-40, 40)
		if absf(x) < 12.0: x += signf(x) * 12.0
		var h: float = rng.randf_range(18, 45)
		_facade(Vector3(x, h * 0.5 - 8.0, rng.randf_range(-40, -14)), Vector3(rng.randf_range(4, 8), h, rng.randf_range(4, 8)), float(k), bg.trim)
	# Floating holo panels with fighters in them.
	for k in range(6):
		var hp := box(Vector3(3.2, 2.2, 0.05), Vector3(rng.randf_range(-16, 16), rng.randf_range(5, 11), rng.randf_range(-16, -8)), glow(bg.trim, 1.2), Vector3(0, rng.randf_range(-25, 25), 0), false)
		hp.transparency = 0.55
		bobbers.append([hp, hp.position.y, rng.randf_range(0.3, 0.6), 0.25])
	# Flying cars circling the towers.
	for k in range(5):
		var lane := Node3D.new()
		lane.position = Vector3(0, rng.randf_range(8, 16), -26.0)
		add_child(lane)
		var car := box(Vector3(1.4, 0.35, 0.7), Vector3(rng.randf_range(12, 22), 0, 0), flat(Color(0.2, 0.22, 0.26), 0.3, 0.8), Vector3.ZERO, false)
		car.reparent(lane, false)
		box(Vector3(0.2, 0.1, 0.5), Vector3(0.75, 0, 0), glow(bg.accent, 4.0), Vector3.ZERO, false).reparent(car, false)
		rotors.append([lane, Vector3(0, 1, 0), rng.randf_range(0.15, 0.35) * (1.0 if k % 2 else -1.0)])
	for k in range(10):
		var trail := box(Vector3(rng.randf_range(6, 14), 0.04, 0.04), Vector3(rng.randf_range(-20, 20), rng.randf_range(2, 10), rng.randf_range(-18, -8)), glow([bg.trim, bg.accent][k % 2], 3.0), Vector3.ZERO, false)
		flickers.append([trail.material_override, 3.0, rng.randf_range(2.0, 6.0)])
	light(Vector3(0, 5.0, -6.0), bg.trim, 1.8, 18.0, 1.0)

func _motif_industrial(th: Dictionary, bg: Dictionary) -> void:
	var frozen: bool = bg.get("frozen", false)
	var steel := flat(Color(0.3, 0.32, 0.35) if not frozen else Color(0.7, 0.78, 0.86), 0.45, 0.8)
	var wall := pbr("ph:concrete_panels", 0.3, Color(0.55, 0.52, 0.5) if not frozen else Color(0.8, 0.88, 0.95))
	# Hall: back wall with windows, steel frame, roof beams.
	box(Vector3(60, 18, 1.0), Vector3(0, 5.0, -18.0), wall)
	for x in range(-24, 25, 6):
		box(Vector3(0.6, 18, 0.6), Vector3(x, 5.0, -17.2), steel)
		var win := box(Vector3(3.6, 2.0, 0.1), Vector3(x + 3.0, 9.0, -17.4), glow(Color("cbd5e1") if not frozen else Color("e0f2fe"), 0.8), Vector3.ZERO, false)
		win.transparency = 0.2
	for z in [-15.0, -10.0, -5.0]:
		box(Vector3(60, 0.5, 0.5), Vector3(0, 13.5, z), steel)
		for x in [-10.0, 0.0, 10.0]:
			sphere(0.3, Vector3(x, 12.8, z), glow(Color("fef3c7"), 3.0), false)
			light(Vector3(x, 12.0, z), Color("fef3c7"), 0.8, 12.0, 0.3)
	# Machines, pipes, barrels.
	for k in range(6):
		var x: float = -20.0 + k * 8.0 + rng.randf_range(-1, 1)
		box(Vector3(rng.randf_range(2.5, 4.0), rng.randf_range(2, 5), 2.5), Vector3(x, 0.0, -12.0), steel)
		cyl(0.6, 0.6, rng.randf_range(3, 6), Vector3(x + 1.5, 1.5, -12.5), steel, 16)
	prop("modular_industrial_pipes_01", Vector3(-14.0, 0.0, -9.0), 4.0, 0.0, false)
	for x in [-7.5, 7.0]:
		prop("Barrel_01", Vector3(x, 0.0, -3.7), 1.0, rng.randf_range(0, 360))
		prop("wooden_crate_02", Vector3(x + 1.2, 0.0, -3.9), 0.9, rng.randf_range(0, 360))
	if frozen:
		# Giant frozen gears and icicles.
		for k in range(3):
			var gear := Node3D.new()
			gear.position = Vector3(-16.0 + k * 16.0, 7.0, -15.5)
			add_child(gear)
			var t := TorusMesh.new()
			t.inner_radius = 2.2
			t.outer_radius = 3.0
			add_mesh(t, Vector3.ZERO, steel, Vector3(90, 0, 0), gear, false)
			for s in range(12):
				var a: float = TAU * s / 12.0
				add_mesh(BoxMesh.new(), Vector3(cos(a) * 3.2, sin(a) * 3.2, 0), steel, Vector3(0, 0, rad_to_deg(a)), gear, false).scale = Vector3(0.6, 0.6, 0.5)
			rotors.append([gear, Vector3(0, 0, 1), 0.05 * (1 if k % 2 else -1)])
		for k in range(24):
			cyl(0.0, 0.15, rng.randf_range(0.6, 1.8), Vector3(rng.randf_range(-28, 28), 12.6, rng.randf_range(-16, -4)), glow(Color("e0f2fe"), 0.5), 6, Vector3(180, 0, 0))
	else:
		for k in range(6):
			box(Vector3(0.05, 2.4, 3.5), Vector3(-17.4 + k * 7.0, 1.6, -17.3), glow([bg.trim, bg.accent, Color("f472b6")][k % 3].darkened(0.3), 0.8), Vector3(0, 90, 0), false)
	light(Vector3(0, 4.0, -6.0), bg.trim, 1.2, 14.0, 1.0)

func _motif_stadium(th: Dictionary, bg: Dictionary) -> void:
	var future: bool = bg.get("future", false)
	var seat := flat(Color(0.18, 0.2, 0.24) if future else Color(0.35, 0.3, 0.28), 0.6)
	# Stands in a wide arc around the field, floodlight masts on top.
	for k in range(26):
		var a: float = lerpf(-1.25, 1.25, k / 25.0)
		var pos := Vector3(sin(a) * 34.0, 2.0, -cos(a) * 30.0 - 4.0)
		var st := box(Vector3(5.0, 10.0, 6.0), pos, seat, Vector3(-25, -rad_to_deg(a), 0))
		st.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for c in range(3):
			var fan := sphere(0.18, pos + Vector3(rng.randf_range(-2, 2), rng.randf_range(-2, 4), rng.randf_range(-1, 1)), glow(Color.from_hsv(rng.randf(), 0.6, 0.9), 0.8), false)
			bobbers.append([fan, fan.position.y, rng.randf_range(2.0, 5.0), 0.1])
		if k % 5 == 2:
			cyl(0.25, 0.3, 12.0, pos + Vector3(0, 10.0, -2.0), seat, 8)
			sphere(0.9, pos + Vector3(0, 16.5, -2.0), glow(Color("f8fafc") if future else Color("fff1d6"), 5.0), false)
			light(pos + Vector3(0, 14.0, 4.0), Color("f8fafc") if future else Color("ffd8a8"), 2.2, 30.0)
	if future:
		for k in range(10):
			var glass := box(Vector3(0.08, 9.0, 5.0), Vector3(-26.0 + k * 5.8, 6.0, -26.0), glow(Color("bae6fd"), 0.25), Vector3(0, 0, 12), false)
			glass.transparency = 0.7
		var floor_glow := plane(Vector2(60, 40), Vector3(0, -1.0, -18), glow(bg.trim.darkened(0.6), 0.6))
		floor_glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	else:
		plane(Vector2(80, 60), Vector3(0, -1.0, -20), pbr("ph:large_sandstone_blocks_01", 0.05, Color(0.8, 0.62, 0.45)))
		light(Vector3(-20, 6.0, -30), Color("fb923c"), 2.4, 40.0)

func _motif_space(th: Dictionary, bg: Dictionary) -> void:
	# The planet below, an orbital ring station with ships, a sea of stars.
	var earth := sphere(38.0, Vector3(-30.0, -34.0, -80.0), glow(Color("1d4ed8"), 0.9), false)
	earth.rotation_degrees = Vector3(0, 0, 20)
	sphere(38.8, Vector3(-30.0, -34.0, -80.0), glow(Color("7dd3fc"), 0.25), false).transparency = 0.8
	var ring := Node3D.new()
	ring.position = Vector3(10.0, -2.0, -34.0)
	ring.rotation_degrees = Vector3(70, 0, 0)
	add_child(ring)
	var t := TorusMesh.new()
	t.inner_radius = 12.0
	t.outer_radius = 14.5
	t.rings = 64
	add_mesh(t, Vector3.ZERO, flat(Color(0.25, 0.27, 0.32), 0.4, 0.8), Vector3.ZERO, ring, false)
	for k in range(20):
		var a: float = TAU * k / 20.0
		add_mesh(BoxMesh.new(), Vector3(cos(a) * 13.2, 0.8, sin(a) * 13.2), glow(bg.accent, 2.0), Vector3.ZERO, ring, false).scale = Vector3(0.6, 0.3, 0.6)
	rotors.append([ring, Vector3(0, 1, 0), 0.04])
	for k in range(8):
		var lane := Node3D.new()
		lane.position = Vector3(10.0, rng.randf_range(0, 6), -34.0)
		add_child(lane)
		var ship := box(Vector3(2.4, 0.5, 0.9), Vector3(rng.randf_range(16, 22), 0, 0), flat(Color(0.35, 0.37, 0.42), 0.4, 0.8), Vector3.ZERO, false)
		ship.reparent(lane, false)
		rotors.append([lane, Vector3(0, 1, 0), rng.randf_range(0.05, 0.12)])
	for k in range(90):
		var star := sphere(rng.randf_range(0.05, 0.16), Vector3(rng.randf_range(-70, 70), rng.randf_range(-10, 40), rng.randf_range(-90, -30)), glow(Color("fff7e0"), 3.0), false)
		flickers.append([star.material_override, 3.0, rng.randf_range(1.0, 4.0)])
	var neb := sphere(20.0, Vector3(40.0, 22.0, -95.0), glow(Color("be185d"), 0.35), false)
	neb.transparency = 0.8
	light(Vector3(0, 6.0, -4.0), bg.trim, 1.4, 18.0)

func _motif_space_interior(th: Dictionary, bg: Dictionary) -> void:
	var hull := flat(Color(0.55, 0.58, 0.64), 0.3, 0.9)
	# Octagonal frames of a corridor, the planet through the big window.
	for k in range(5):
		var z: float = -8.0 - k * 5.0
		for s in range(8):
			var a: float = TAU * s / 8.0 + PI / 8.0
			var seg := box(Vector3(9.0, 0.6, 0.8), Vector3(cos(a) * 11.0, 5.0 + sin(a) * 11.0, z), hull, Vector3(0, 0, rad_to_deg(a) + 90.0))
			seg.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for side in [-1.0, 1.0]:
			box(Vector3(0.3, 2.0, 0.3), Vector3(side * 6.5, 12.5, z), glow(Color("f8fafc"), 4.0), Vector3.ZERO, false)
	sphere(30.0, Vector3(0, -24.0, -70.0), glow(Color("1e40af"), 0.9), false)
	sphere(30.6, Vector3(0, -24.0, -70.0), glow(Color("93c5fd"), 0.3), false).transparency = 0.8
	for k in range(60):
		sphere(rng.randf_range(0.04, 0.12), Vector3(rng.randf_range(-40, 40), rng.randf_range(0, 30), rng.randf_range(-80, -40)), glow(Color("ffffff"), 3.0), false)
	plane(Vector2(40, 40), Vector3(0, -1.0, -20), flat(Color(0.2, 0.22, 0.26), 0.15, 0.9))
	light(Vector3(0, 8.0, -6.0), Color("e0f2fe"), 1.6, 20.0)

func _motif_city_roof(th: Dictionary, bg: Dictionary) -> void:
	var storm: bool = bg.get("storm", false)
	for k in range(22):
		var x: float = rng.randf_range(-60, 60)
		var h: float = rng.randf_range(20, 55)
		_facade(Vector3(x, h * 0.5 - 20.0, rng.randf_range(-70, -30)), Vector3(rng.randf_range(5, 10), h, 6), float(k) * 1.7, [bg.trim, bg.accent][k % 2] if k % 3 == 0 else Color(0, 0, 0, 0))
	# Rooftop clutter behind the stage: railing, AC units, water tank, neon signs.
	var metal := flat(Color(0.28, 0.3, 0.33), 0.5, 0.7)
	box(Vector3(24.0, 0.08, 0.08), Vector3(0, 1.0, -4.6), metal, Vector3.ZERO, false)
	for x in range(-11, 12, 2):
		box(Vector3(0.06, 1.0, 0.06), Vector3(x, 0.5, -4.6), metal, Vector3.ZERO, false)
	for x in [-7.0, -4.5, 6.0]:
		box(Vector3(1.4, 1.0, 1.0), Vector3(x, 0.5, -6.0), metal)
	cyl(1.2, 1.2, 2.6, Vector3(8.5, 2.6, -7.0), pbr("wood_planks", 0.5, Color(0.5, 0.4, 0.32)), 16)
	for k in range(3):
		_neon_sign(Vector3(-12.0 + k * 11.0, 4.5, -9.0), Vector2(2.6, 1.0), [bg.trim, bg.accent, Color("facc15")][k])
	if storm:
		for k in range(3):
			var bolt := box(Vector3(0.2, 30.0, 0.2), Vector3(rng.randf_range(-40, 40), 15.0, rng.randf_range(-60, -40)), glow(Color("dbeafe"), 6.0), Vector3(0, 0, rng.randf_range(-10, 10)), false)
			flickers.append([bolt.material_override, 6.0, rng.randf_range(8.0, 14.0)])
		light(Vector3(0, 20.0, -30.0), Color("dbeafe"), 3.0, 60.0, 12.0)
	light(Vector3(0, 4.0, -5.0), bg.trim, 1.4, 14.0, 1.0)

func _motif_colosseum(th: Dictionary, bg: Dictionary) -> void:
	_scene_imperial_colosseum(th)
	if bg.get("statues", false):
		for x in [-9.0, 9.0]:
			box(Vector3(1.4, 1.6, 1.4), Vector3(x, 0.8, -4.2), pbr("ph:large_sandstone_blocks", 0.5))
			prop("gothic_statue", Vector3(x, 1.6, -4.2), 3.0, 0.0 if x < 0 else 180.0)
	light(Vector3(-20, 8.0, -20), Color("fbbf24"), 2.0, 40.0)

func _motif_mountains(th: Dictionary, bg: Dictionary) -> void:
	var snow := pbr("ph:snow_02", 0.08)
	plane(Vector2(220, 140), Vector3(0, -6.0, -40), snow)
	for k in range(14):
		var x: float = rng.randf_range(-90, 90)
		var h: float = rng.randf_range(25, 60)
		var peak := cyl(0.0, h * 0.55, h, Vector3(x, -6.0 + h * 0.5, rng.randf_range(-110, -50)), pbr("ph:rock_wall_10", 0.1, Color(0.85, 0.88, 0.95)), 7)
		peak.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		cyl(0.0, h * 0.2, h * 0.36, Vector3(x, -6.0 + h * 0.82, peak.position.z + 0.1), glow(Color("f8fafc"), 0.6), 7)
	# Aurora: waving ribbons of green light.
	for k in range(9):
		var rib := box(Vector3(22.0, 9.0, 0.1), Vector3(-40.0 + k * 10.0, 30.0 + sin(k) * 4.0, -95.0), glow(Color("34d399").lerp(Color("22d3ee"), k / 9.0), 1.4), Vector3(0, rng.randf_range(-20, 20), rng.randf_range(-8, 8)), false)
		rib.transparency = 0.6
		bobbers.append([rib, rib.position.y, rng.randf_range(0.2, 0.4), 2.0])
	for k in range(70):
		sphere(rng.randf_range(0.06, 0.15), Vector3(rng.randf_range(-90, 90), rng.randf_range(30, 60), rng.randf_range(-110, -80)), glow(Color("ffffff"), 3.0), false)
	light(Vector3(0, 6.0, -6.0), Color("a7f3d0"), 1.4, 20.0, 0.5)

func _motif_war(th: Dictionary, bg: Dictionary) -> void:
	var rubble := pbr("ph:dark_rock", 0.2, Color(0.45, 0.45, 0.45))
	plane(Vector2(200, 120), Vector3(0, -3.0, -40), pbr("ph:rock_wall_10", 0.05, Color(0.35, 0.34, 0.32)))
	if bg.get("ruins", false):
		for k in range(10):
			var x: float = rng.randf_range(-50, 50)
			var h: float = rng.randf_range(8, 22)
			var ruin := box(Vector3(rng.randf_range(5, 9), h, 4.0), Vector3(x, -3.0 + h * 0.5, rng.randf_range(-60, -30)), rubble, Vector3(0, rng.randf_range(-20, 20), rng.randf_range(-6, 6)))
			ruin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Wrecked tanks, broken stakes, craters, burning debris.
	var hull_m := flat(Color(0.25, 0.27, 0.22), 0.8, 0.3)
	for spec in [[-14.0, -14.0, 25.0], [13.0, -18.0, -150.0], [-4.0, -30.0, 70.0]]:
		var tank := Node3D.new()
		tank.position = Vector3(spec[0], -2.4, spec[1])
		tank.rotation_degrees = Vector3(0, spec[2], rng.randf_range(-6, 6))
		add_child(tank)
		add_mesh(BoxMesh.new(), Vector3(0, 0.6, 0), hull_m, Vector3.ZERO, tank).scale = Vector3(5.0, 1.4, 3.0)
		add_mesh(BoxMesh.new(), Vector3(0.3, 1.7, 0), hull_m, Vector3.ZERO, tank).scale = Vector3(2.2, 0.9, 2.0)
		var barrel := CylinderMesh.new()
		barrel.top_radius = 0.15
		barrel.bottom_radius = 0.18
		barrel.height = 4.0
		add_mesh(barrel, Vector3(2.4, 1.9, 0), hull_m, Vector3(0, 0, 80), tank)
	for k in range(14):
		var stake := cyl(0.08, 0.12, rng.randf_range(2, 5), Vector3(rng.randf_range(-24, 24), -1.5, rng.randf_range(-20, -6)), flat(Color(0.2, 0.17, 0.14)), 6)
		stake.rotation_degrees = Vector3(rng.randf_range(-30, 30), 0, rng.randf_range(-40, 40))
	for k in range(4):
		_fire(Vector3(rng.randf_range(-20, 20), -2.2, rng.randf_range(-24, -8)), bg.accent, 1.8)
	light(Vector3(0, 6.0, -8.0), Color("cbd5e1"), 1.0, 20.0)

func _motif_dojo(th: Dictionary, bg: Dictionary) -> void:
	var wood := pbr("ph:dark_planks", 0.3, Color(0.55, 0.4, 0.28))
	# Wooden hall: back wall with glowing paper screens, pillars, beams, candles.
	box(Vector3(40, 14, 0.6), Vector3(0, 5.0, -9.0), wood)
	for x in [-12.0, -6.0, 6.0, 12.0]:
		var shoji := box(Vector3(4.6, 6.0, 0.1), Vector3(x, 3.5, -8.6), glow(Color("fde68a"), 0.7), Vector3.ZERO, false)
		shoji.transparency = 0.1
		for g in range(3):
			box(Vector3(4.6, 0.06, 0.12), Vector3(x, 1.0 + g * 2.0, -8.5), wood, Vector3.ZERO, false)
	for x in [-15.0, -9.0, -3.0, 3.0, 9.0, 15.0]:
		box(Vector3(0.6, 14, 0.6), Vector3(x, 5.0, -8.4), wood)
	box(Vector3(40, 0.7, 0.7), Vector3(0, 11.0, -8.4), wood)
	var scroll := box(Vector3(1.4, 3.2, 0.05), Vector3(0, 4.5, -8.5), flat(Color(0.9, 0.86, 0.75)), Vector3.ZERO, false)
	scroll.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for x in [-2.0, 2.0, -9.5, 9.5]:
		cyl(0.08, 0.1, 0.9, Vector3(x, 0.45, -4.0), flat(Color(0.95, 0.92, 0.85)), 8)
		_fire(Vector3(x, 1.0, -4.0), Color("ffb347"), 0.8)
	for x in [-7.0, 7.0]:
		prop("wooden_lantern_01", Vector3(x, 0.0, -4.2), 1.1, 0.0)
		light(Vector3(x, 1.2, -3.6), Color("ffb347"), 1.2, 8.0, 3.0)
	light(Vector3(0, 6.0, -4.0), Color("fcd34d"), 1.2, 16.0)

func _motif_foundry(th: Dictionary, bg: Dictionary) -> void:
	var iron := flat(Color(0.18, 0.16, 0.15), 0.5, 0.7)
	var lava := plane(Vector2(80, 40), Vector3(0, -2.5, -20), shader_mat(LAVA_SHADER, {}))
	lava.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	box(Vector3(80, 20, 1.0), Vector3(0, 6.0, -22.0), iron)
	# Furnaces with glowing mouths, a pouring ladle, pipes, sparks.
	for k in range(5):
		var x: float = -20.0 + k * 10.0
		box(Vector3(6.0, 9.0, 5.0), Vector3(x, 2.5, -17.0), iron)
		var mouth := box(Vector3(2.4, 2.0, 0.2), Vector3(x, 1.5, -14.4), glow(Color("ff7a1a"), 4.0), Vector3.ZERO, false)
		flickers.append([mouth.material_override, 4.0, rng.randf_range(2.0, 5.0)])
		cyl(0.5, 0.5, 10.0, Vector3(x + 2.0, 11.0, -18.0), iron, 12)
		_fire(Vector3(x, 1.6, -14.0), bg.accent, 2.0)
	if bg.get("molten", false):
		var ladle := Node3D.new()
		ladle.position = Vector3(7.0, 9.0, -12.0)
		ladle.rotation_degrees = Vector3(0, 0, -35)
		add_child(ladle)
		var cup := CylinderMesh.new()
		cup.top_radius = 2.2
		cup.bottom_radius = 1.6
		cup.height = 2.6
		add_mesh(cup, Vector3.ZERO, iron, Vector3.ZERO, ladle)
		var pour := cyl(0.35, 0.5, 11.0, Vector3(9.2, 3.0, -12.0), glow(Color("fb923c"), 5.0), 12)
		flickers.append([pour.material_override, 5.0, 6.0])
	for k in range(3):
		var bolt := box(Vector3(0.12, 10.0, 0.12), Vector3(rng.randf_range(-14, 14), 12.0, -15.0), glow(Color("fde68a"), 5.0), Vector3(0, 0, rng.randf_range(-20, 20)), false)
		flickers.append([bolt.material_override, 5.0, rng.randf_range(9.0, 15.0)])
	prop("modular_industrial_pipes_01", Vector3(12.0, 0.0, -9.0), 4.0, 90.0, false)
	light(Vector3(0, 3.0, -8.0), Color("ff7a1a"), 2.4, 20.0, 3.0)

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
	for r in rotors:
		if is_instance_valid(r[0]): r[0].rotate(r[1], float(r[2]) * delta)
	for b in bobbers:
		if is_instance_valid(b[0]):
			b[0].position.y = b[1] + sin(time * b[2] + b[1]) * b[3]
	for f in flickers:
		if not is_instance_valid(f[0]): continue
		var k: float = 0.85 + 0.15 * sin(time * f[2]) * sin(time * f[2] * 1.7 + 1.3)
		if f[0] is OmniLight3D: f[0].light_energy = f[1] * k
		elif f[0] is StandardMaterial3D: f[0].emission_energy_multiplier = f[1] * (0.6 + 0.4 * k)
		elif f[0] is Label3D: f[0].modulate.a = 0.7 + 0.3 * k

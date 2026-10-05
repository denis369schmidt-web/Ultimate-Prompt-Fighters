extends RefCounted
## 3D models of the arena weapons, built from primitives. Local +Y is the blade
## direction, the grip sits at the origin (so the model can be put into a hand).

static func _mat(color: Color, metal: float = 0.8, rough: float = 0.3, emit: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = metal
	m.roughness = rough
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emit
	return m

static func _part(root: Node3D, mesh: Mesh, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	root.add_child(mi)
	return mi

static func _box(root: Node3D, size: Vector3, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var b := BoxMesh.new()
	b.size = size
	return _part(root, b, pos, mat, rot)

static func _cyl(root: Node3D, r_top: float, r_bot: float, h: float, pos: Vector3, mat: Material, sides: int = 12, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var c := CylinderMesh.new()
	c.top_radius = r_top
	c.bottom_radius = r_bot
	c.height = h
	c.radial_segments = sides
	return _part(root, c, pos, mat, rot)

static func _ball(root: Node3D, r: float, pos: Vector3, mat: Material) -> MeshInstance3D:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 12
	s.rings = 6
	return _part(root, s, pos, mat)

## Blade with a pointed tip: a flat box plus a prism tip.
static func _blade(root: Node3D, length: float, width: float, thick: float, base_y: float, mat: Material) -> void:
	_box(root, Vector3(width, length, thick), Vector3(0, base_y + length * 0.5, 0), mat)
	var tip := PrismMesh.new()
	tip.size = Vector3(width, width * 1.2, thick)
	_part(root, tip, Vector3(0, base_y + length + width * 0.6, 0), mat)

static func build(id: String) -> Node3D:
	var root := Node3D.new()
	root.name = "Weapon_" + id
	match id:
		"sword_hero":
			var blade := _mat(Color(0.86, 0.9, 0.95), 0.95, 0.12)
			var gold := _mat(Color(0.95, 0.75, 0.25), 0.9, 0.25)
			var grip := _mat(Color(0.12, 0.25, 0.65), 0.2, 0.6)
			_cyl(root, 0.035, 0.035, 0.26, Vector3(0, 0.0, 0), grip)
			_ball(root, 0.05, Vector3(0, -0.15, 0), gold)
			_box(root, Vector3(0.36, 0.06, 0.06), Vector3(0, 0.15, 0), grip)
			for side in [-1, 1]:
				_box(root, Vector3(0.12, 0.05, 0.05), Vector3(side * 0.2, 0.19, 0), gold, Vector3(0, 0, side * -35))
			_ball(root, 0.035, Vector3(0, 0.16, 0.04), _mat(Color("f7c844"), 0.3, 0.2, 2.0))
			_blade(root, 0.85, 0.09, 0.02, 0.18, blade)
		"sword_buster":
			var steel := _mat(Color(0.62, 0.64, 0.68), 0.85, 0.35)
			var wrap := _mat(Color(0.35, 0.25, 0.18), 0.1, 0.9)
			_cyl(root, 0.04, 0.04, 0.34, Vector3(0, 0.0, 0), wrap)
			_box(root, Vector3(0.24, 0.08, 0.1), Vector3(0, 0.2, 0), steel)
			_box(root, Vector3(0.26, 1.15, 0.035), Vector3(0, 0.82, 0), steel)
			_box(root, Vector3(0.05, 1.0, 0.04), Vector3(-0.06, 0.8, 0), _mat(Color(0.35, 0.36, 0.4), 0.9, 0.4))
			var tip := PrismMesh.new()
			tip.size = Vector3(0.26, 0.16, 0.035)
			_part(root, tip, Vector3(0, 1.47, 0), steel)
			for k in range(2):
				_ball(root, 0.025, Vector3(0, 0.34 + k * 0.1, 0.02), _mat(Color(0.2, 0.2, 0.2)))
		"sword_plasma":
			var hilt := _mat(Color(0.7, 0.72, 0.75), 0.9, 0.25)
			_cyl(root, 0.04, 0.04, 0.3, Vector3(0, 0.0, 0), hilt)
			_box(root, Vector3(0.05, 0.08, 0.1), Vector3(0.03, 0.05, 0), _mat(Color(0.1, 0.1, 0.1), 0.5, 0.5))
			_cyl(root, 0.03, 0.03, 1.0, Vector3(0, 0.66, 0), _mat(Color(0.75, 1.0, 1.0), 0.0, 0.1, 6.0))
			var halo := _cyl(root, 0.05, 0.05, 1.02, Vector3(0, 0.66, 0), _mat(Color(0.1, 0.8, 1.0), 0.0, 0.1, 3.0))
			halo.transparency = 0.55
		"sword_frost":
			var dark := _mat(Color(0.18, 0.2, 0.28), 0.8, 0.3)
			var ice := _mat(Color(0.55, 0.8, 1.0), 0.2, 0.1, 2.2)
			_cyl(root, 0.035, 0.035, 0.28, Vector3(0, 0.0, 0), _mat(Color(0.1, 0.1, 0.14), 0.3, 0.6))
			_ball(root, 0.06, Vector3(0, 0.2, 0), _mat(Color(0.8, 0.85, 0.9), 0.4, 0.4))
			for side in [-1, 1]:
				_box(root, Vector3(0.18, 0.05, 0.05), Vector3(side * 0.13, 0.22, 0), dark, Vector3(0, 0, side * 25))
			_blade(root, 0.95, 0.12, 0.025, 0.24, dark)
			for k in range(5):
				_box(root, Vector3(0.03, 0.08, 0.03), Vector3(0, 0.36 + k * 0.17, 0.016), ice)
		"sword_crescent":
			var black := _mat(Color(0.05, 0.05, 0.06), 0.7, 0.25)
			_cyl(root, 0.032, 0.032, 0.34, Vector3(0, 0.0, 0), _mat(Color(0.8, 0.8, 0.8), 0.2, 0.7))
			_box(root, Vector3(0.14, 0.14, 0.04), Vector3(0, 0.22, 0), black, Vector3(0, 0, 45))
			_box(root, Vector3(0.2, 1.0, 0.03), Vector3(0.03, 0.8, 0), black)
			var tip := PrismMesh.new()
			tip.size = Vector3(0.2, 0.2, 0.03)
			_part(root, tip, Vector3(0.03, 1.4, 0), black)
			_box(root, Vector3(0.02, 0.95, 0.032), Vector3(-0.07, 0.8, 0), _mat(Color(0.9, 0.1, 0.1), 0.0, 0.3, 2.4))
		"blaster":
			var body := _mat(Color(0.9, 0.9, 0.95), 0.4, 0.3)
			var accent := _mat(Color(1.0, 0.3, 0.7), 0.0, 0.2, 3.0)
			_box(root, Vector3(0.08, 0.2, 0.08), Vector3(0, 0.0, 0), _mat(Color(0.15, 0.15, 0.18)), Vector3(0, 0, 0))
			_box(root, Vector3(0.12, 0.42, 0.12), Vector3(0, 0.24, 0.06), body, Vector3(90, 0, 0))
			_cyl(root, 0.035, 0.035, 0.18, Vector3(0, 0.24, 0.34), accent, 10, Vector3(90, 0, 0))
			_box(root, Vector3(0.14, 0.04, 0.3), Vector3(0, 0.33, 0.08), accent)
		"boomerang":
			var wood := _mat(Color(0.95, 0.75, 0.2), 0.2, 0.5, 0.6)
			_box(root, Vector3(0.09, 0.5, 0.03), Vector3(-0.1, 0.2, 0), wood, Vector3(0, 0, 30))
			_box(root, Vector3(0.09, 0.5, 0.03), Vector3(0.1, 0.2, 0), wood, Vector3(0, 0, -30))
		"shadow_katana":
			_cyl(root, 0.025, 0.025, 0.32, Vector3(0, 0.16, 0), _mat(Color(0.08, 0.06, 0.1), 0.2, 0.6), 8)
			_box(root, Vector3(0.14, 0.02, 0.14), Vector3(0, 0.33, 0), _mat(Color(0.6, 0.5, 0.9), 0.8, 0.3))
			_box(root, Vector3(0.035, 1.05, 0.012), Vector3(0.01, 0.86, 0), _mat(Color("a855f7"), 0.2, 0.15, 3.5), Vector3(0, 0, -3))
		"frost_axe":
			_cyl(root, 0.03, 0.035, 1.0, Vector3(0, 0.5, 0), _mat(Color(0.35, 0.28, 0.22), 0.0, 0.7), 8)
			_box(root, Vector3(0.42, 0.34, 0.04), Vector3(0.18, 0.92, 0), _mat(Color("bae6fd"), 0.6, 0.1, 1.5))
			for k in range(3): _cyl(root, 0.0, 0.03, 0.18, Vector3(0.38, 0.8 + k * 0.12, 0), _mat(Color("e0f2fe"), 0.2, 0.05, 2.0), 5, Vector3(0, 0, -90))
		"flame_whip":
			_cyl(root, 0.035, 0.035, 0.3, Vector3(0, 0.15, 0), _mat(Color(0.25, 0.15, 0.1), 0.0, 0.7), 8)
			for k in range(10):
				var t: float = k / 9.0
				_ball(root, 0.05 - t * 0.025, Vector3(sin(t * 3.0) * 0.25, 0.35 + t * 1.3, 0), _mat(Color("f97316").lerp(Color("fde047"), t), 0.0, 0.3, 3.0))
		"crystal_bow":
			var arc := TorusMesh.new()
			arc.inner_radius = 0.5
			arc.outer_radius = 0.54
			var bow := _part(root, arc, Vector3(0, 0.6, 0), _mat(Color("67e8f9"), 0.3, 0.1, 2.0), Vector3(90, 0, 0))
			bow.scale = Vector3(0.5, 1.0, 1.0)
			_cyl(root, 0.004, 0.004, 1.04, Vector3(-0.02, 0.6, 0), _mat(Color(0.9, 0.95, 1.0), 0.0, 0.3, 1.0), 4)
		"dragon_lance":
			_cyl(root, 0.03, 0.03, 1.9, Vector3(0, 0.8, 0), _mat(Color(0.3, 0.1, 0.08), 0.6, 0.4), 8)
			_cyl(root, 0.0, 0.09, 0.45, Vector3(0, 1.95, 0), _mat(Color("ef4444"), 0.8, 0.2, 1.5), 6)
			for s in [-1.0, 1.0]: _box(root, Vector3(0.18, 0.06, 0.03), Vector3(s * 0.1, 1.72, 0), _mat(Color(0.8, 0.65, 0.3), 0.9, 0.3), Vector3(0, 0, s * 30))
		"soul_scythe":
			_cyl(root, 0.03, 0.03, 1.6, Vector3(0, 0.8, 0), _mat(Color(0.12, 0.1, 0.1), 0.2, 0.6), 8)
			var blade2 := TorusMesh.new()
			blade2.inner_radius = 0.42
			blade2.outer_radius = 0.5
			var sc := _part(root, blade2, Vector3(0.3, 1.5, 0), _mat(Color("a3e635"), 0.5, 0.2, 2.0), Vector3(90, 0, 0))
			sc.scale = Vector3(1.0, 1.0, 0.25)
		"thunder_hammer":
			_cyl(root, 0.035, 0.04, 0.9, Vector3(0, 0.45, 0), _mat(Color(0.3, 0.22, 0.15), 0.0, 0.7), 8)
			_box(root, Vector3(0.5, 0.28, 0.28), Vector3(0, 0.98, 0), _mat(Color(0.55, 0.58, 0.62), 0.9, 0.3))
			_box(root, Vector3(0.52, 0.06, 0.3), Vector3(0, 0.98, 0), _mat(Color("fde047"), 0.2, 0.2, 3.0))
		"plasma_cannon":
			_cyl(root, 0.1, 0.12, 0.7, Vector3(0.25, 0.3, 0), _mat(Color(0.2, 0.22, 0.26), 0.9, 0.3), 12, Vector3(0, 0, -90))
			_ball(root, 0.09, Vector3(0.62, 0.3, 0), _mat(Color("22d3ee"), 0.0, 0.2, 5.0))
			_box(root, Vector3(0.08, 0.25, 0.08), Vector3(0.05, 0.15, 0), _mat(Color(0.15, 0.15, 0.18), 0.6, 0.5))
		"flail":
			var iron := _mat(Color(0.45, 0.45, 0.48), 0.85, 0.4)
			_cyl(root, 0.035, 0.04, 0.5, Vector3(0, 0.1, 0), _mat(Color(0.35, 0.22, 0.12), 0.0, 0.8))
			for k in range(6):
				_cyl(root, 0.02, 0.02, 0.08, Vector3(0, 0.4 + k * 0.08, 0), iron, 6, Vector3(0, 0, 90 * (k % 2)))
			_ball(root, 0.16, Vector3(0, 0.95, 0), iron)
			for dir in [Vector3.UP, Vector3.DOWN, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]:
				var spike := _cyl(root, 0.0, 0.04, 0.14, Vector3(0, 0.95, 0) + dir * 0.18, iron, 6)
				if dir.x != 0.0: spike.rotation_degrees = Vector3(0, 0, -90 * dir.x)
				elif dir.z != 0.0: spike.rotation_degrees = Vector3(90 * dir.z, 0, 0)
				elif dir.y < 0.0: spike.rotation_degrees = Vector3(180, 0, 0)
	return root

## Visual for a projectile (shape from the signature or weapon kind), flying along +X.
static func projectile(kind: String, color: Color) -> Node3D:
	var root := Node3D.new()
	var glow_m := _mat(color, 0.0, 0.3, 4.0)
	var core_m := _mat(color.lightened(0.6), 0.0, 0.2, 6.0)
	match kind:
		"crescent":
			var t := TorusMesh.new()
			t.inner_radius = 0.7
			t.outer_radius = 0.85
			var m := _part(root, t, Vector3.ZERO, _mat(Color(0.9, 0.08, 0.1), 0.0, 0.3, 4.0), Vector3(90, 0, 0))
			m.scale = Vector3(0.6, 1.0, 1.4)
		"laser", "bolt", "bullet":
			_box(root, Vector3(0.7 if kind != "bullet" else 0.35, 0.07, 0.07), Vector3.ZERO, core_m)
		"pellet":
			_ball(root, 0.07, Vector3.ZERO, core_m)
		"beam":
			_box(root, Vector3(0.9, 0.16, 0.06), Vector3.ZERO, _mat(Color(0.6, 0.9, 1.0), 0.0, 0.2, 5.0))
			var tip := PrismMesh.new()
			tip.size = Vector3(0.16, 0.3, 0.06)
			_part(root, tip, Vector3(0.55, 0, 0), _mat(Color(0.8, 0.95, 1.0), 0.0, 0.2, 5.0), Vector3(0, 0, -90))
		"saber":
			var sb := build("sword_plasma")
			sb.rotation_degrees = Vector3(0, 0, 90)
			root.add_child(sb)
		"boomerang":
			root.add_child(build("boomerang"))
		"lance":
			_cyl(root, 0.03, 0.05, 1.6, Vector3.ZERO, core_m, 8, Vector3(0, 0, 90))
			_cyl(root, 0.0, 0.12, 0.4, Vector3(0.95, 0, 0), glow_m, 6, Vector3(0, 0, -90))
		"orb", "foxfire", "fireball", "meteor":
			var r: float = {"orb": 0.35, "foxfire": 0.2, "fireball": 0.3, "meteor": 0.6}[kind]
			_ball(root, r, Vector3.ZERO, core_m)
			var halo := _ball(root, r * 1.6, Vector3.ZERO, glow_m)
			halo.transparency = 0.6
		"shard":
			var pr := PrismMesh.new()
			pr.size = Vector3(0.25, 0.8, 0.25)
			_part(root, pr, Vector3.ZERO, _mat(Color(0.75, 0.95, 1.0), 0.3, 0.05, 2.0), Vector3(0, 0, -90))
		"hook":
			_cyl(root, 0.02, 0.02, 0.8, Vector3(-0.4, 0, 0), _mat(Color(0.4, 0.4, 0.42), 0.9, 0.3), 6, Vector3(0, 0, 90))
			var hk := TorusMesh.new()
			hk.inner_radius = 0.12
			hk.outer_radius = 0.18
			_part(root, hk, Vector3(0.1, 0.05, 0), _mat(color, 0.9, 0.2, 1.5), Vector3(90, 0, 0))
		"firebird":
			_ball(root, 0.22, Vector3.ZERO, core_m)
			for side in [-1, 1]:
				_box(root, Vector3(0.5, 0.05, 0.35), Vector3(-0.1, 0.12, side * 0.3), glow_m, Vector3(side * 25, 0, 20))
		"roots":
			var rm := _mat(Color(0.36, 0.25, 0.14), 0.0, 0.85)
			for k in range(5):
				var rr := _cyl(root, 0.02, 0.09, 1.3 + 0.2 * (k % 2), Vector3(-0.5 + k * 0.25, 0.0, 0.0), rm, 6, Vector3(0, 0, -20 + k * 10))
				rr.position.y = 0.0
			_ball(root, 0.12, Vector3(0, -0.5, 0), glow_m)
		"bone_cage":
			var bm := _mat(Color(0.92, 0.9, 0.82), 0.0, 0.6)
			for k in range(6):
				var ang := TAU * k / 6.0
				_cyl(root, 0.04, 0.05, 2.2, Vector3(cos(ang) * 0.85, 0.0, sin(ang) * 0.4), bm, 6)
			var ring_m := TorusMesh.new()
			ring_m.inner_radius = 0.8
			ring_m.outer_radius = 0.9
			var top := _part(root, ring_m, Vector3(0, 1.1, 0), bm)
			top.scale = Vector3(1.0, 1.0, 0.5)
			var bot := _part(root, ring_m, Vector3(0, -1.0, 0), bm)
			bot.scale = Vector3(1.0, 1.0, 0.5)
			_ball(root, 0.2, Vector3(0, 1.25, 0), glow_m)
		"missile":
			_cyl(root, 0.06, 0.06, 0.45, Vector3.ZERO, _mat(Color(0.86, 0.88, 0.9), 0.7, 0.3), 8, Vector3(0, 0, 90))
			_cyl(root, 0.0, 0.06, 0.14, Vector3(0.29, 0, 0), glow_m, 8, Vector3(0, 0, -90))
			_ball(root, 0.08, Vector3(-0.28, 0, 0), core_m)
		"cloud":
			var cm := _mat(color.lerp(Color(0.95, 0.97, 1.0), 0.45), 0.0, 0.9, 0.3)
			cm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			cm.albedo_color.a = 0.85
			for k in range(5):
				_ball(root, 0.45 + 0.12 * (k % 2), Vector3(-1.0 + k * 0.5, 0.1 * (k % 3), 0.0), cm)
			var dark := _mat(color.darkened(0.45), 0.0, 0.9, 0.0)
			_ball(root, 0.5, Vector3(0, -0.15, 0.1), dark)
		"arrow":
			_cyl(root, 0.015, 0.015, 0.9, Vector3.ZERO, _mat(Color(0.5, 0.35, 0.2), 0.0, 0.7), 6, Vector3(0, 0, 90))
			_cyl(root, 0.0, 0.05, 0.14, Vector3(0.5, 0, 0), glow_m, 6, Vector3(0, 0, -90))
		"scythe":
			var sc := TorusMesh.new()
			sc.inner_radius = 0.4
			sc.outer_radius = 0.5
			var ring := _part(root, sc, Vector3.ZERO, glow_m, Vector3(90, 0, 0))
			ring.scale = Vector3(1.0, 1.0, 0.4)
		"grenade", "bomb":
			_ball(root, 0.2 if kind == "grenade" else 0.3, Vector3.ZERO, _mat(Color(0.15, 0.17, 0.15), 0.6, 0.4))
			_ball(root, 0.06, Vector3(0, 0.25 if kind == "bomb" else 0.18, 0), _mat(color, 0.0, 0.2, 6.0))
		"bat":
			_ball(root, 0.12, Vector3.ZERO, _mat(Color(0.1, 0.02, 0.03), 0.0, 0.6))
			for side in [-1, 1]:
				_box(root, Vector3(0.1, 0.03, 0.35), Vector3(0, 0.05, side * 0.2), _mat(color.darkened(0.5), 0.0, 0.6, 1.0), Vector3(side * 20, 0, 0))
		"clone":
			var body := CapsuleMesh.new()
			body.radius = 0.3
			body.height = 1.7
			var ghost := _part(root, body, Vector3(0, -0.05, 0), _mat(color, 0.0, 0.3, 2.5))
			ghost.transparency = 0.45
		"thorns", "mine":
			for k in range(6):
				_cyl(root, 0.0, 0.07, 0.35, Vector3(cos(k) * 0.18, 0.05, sin(k) * 0.18), glow_m, 5, Vector3(sin(k) * 25, 0, cos(k) * 25))
			_ball(root, 0.14, Vector3.ZERO, _mat(color.darkened(0.4), 0.2, 0.6))
		"glitch":
			for k in range(5):
				var gb := _box(root, Vector3(0.18, 0.18, 0.18), Vector3((k % 3 - 1) * 0.2, (k / 3) * 0.2 - 0.1, 0), _mat(color, 0.0, 0.2, 5.0))
				gb.transparency = 0.3
		"turret":
			_cyl(root, 0.25, 0.35, 0.5, Vector3(0, -0.3, 0), _mat(Color(0.25, 0.25, 0.28), 0.8, 0.3), 10)
			_box(root, Vector3(0.6, 0.18, 0.18), Vector3(0.2, 0.05, 0), _mat(Color(0.2, 0.2, 0.22), 0.8, 0.3))
			_ball(root, 0.08, Vector3(0.05, 0.2, 0), _mat(color, 0.0, 0.2, 6.0))
		"kunai":
			_cyl(root, 0.0, 0.06, 0.32, Vector3(0.12, 0, 0), _mat(Color(0.75, 0.8, 0.85), 0.9, 0.25), 4, Vector3(0, 0, -90))
			_cyl(root, 0.02, 0.02, 0.2, Vector3(-0.12, 0, 0), _mat(Color(0.1, 0.1, 0.12), 0.2, 0.6), 6, Vector3(0, 0, 90))
			var ring_k := TorusMesh.new()
			ring_k.inner_radius = 0.03
			ring_k.outer_radius = 0.05
			_part(root, ring_k, Vector3(-0.25, 0, 0), glow_m, Vector3(90, 0, 0))
		"lava_blob":
			_ball(root, 0.28, Vector3.ZERO, _mat(Color(0.25, 0.06, 0.02), 0.0, 0.8, 1.0))
			var glow_b := _ball(root, 0.34, Vector3.ZERO, _mat(color, 0.0, 0.3, 5.0))
			glow_b.transparency = 0.55
		"lava_pool":
			var disc := CylinderMesh.new()
			disc.top_radius = 1.2
			disc.bottom_radius = 1.25
			disc.height = 0.06
			_part(root, disc, Vector3(0, -0.12, 0), _mat(color, 0.0, 0.25, 4.0))
			for k in range(5):
				_ball(root, 0.12, Vector3(cos(k * 1.3) * 0.7, -0.05, sin(k * 1.3) * 0.3), _mat(Color("ffd060"), 0.0, 0.2, 6.0))
		"cannonball":
			_ball(root, 0.26, Vector3.ZERO, _mat(Color(0.08, 0.08, 0.09), 0.8, 0.35))
			var trail := _ball(root, 0.3, Vector3(-0.2, 0, 0), _mat(color, 0.0, 0.3, 3.0))
			trail.transparency = 0.7
		"coin":
			var cm := CylinderMesh.new()
			cm.top_radius = 0.18
			cm.bottom_radius = 0.18
			cm.height = 0.04
			cm.radial_segments = 24
			_part(root, cm, Vector3.ZERO, _mat(Color("facc15"), 1.0, 0.25, 0.6), Vector3(90, 0, 0))
		"holy_pillar":
			var col_m := CylinderMesh.new()
			col_m.top_radius = 0.55
			col_m.bottom_radius = 0.7
			col_m.height = 6.0
			var pill := _part(root, col_m, Vector3(0, 2.2, 0), _mat(color.lightened(0.3), 0.0, 0.2, 5.0))
			pill.transparency = 0.25
		"singularity":
			_ball(root, 0.35, Vector3.ZERO, _mat(Color(0.02, 0.0, 0.04), 0.0, 0.9))
			var halo_s := _ball(root, 0.6, Vector3.ZERO, _mat(color, 0.0, 0.3, 3.5))
			halo_s.transparency = 0.7
			var disk := TorusMesh.new()
			disk.inner_radius = 0.55
			disk.outer_radius = 0.75
			_part(root, disk, Vector3.ZERO, _mat(color.lightened(0.3), 0.0, 0.3, 4.0), Vector3(70, 0, 0))
		"spark_trail":
			_box(root, Vector3(0.8, 0.05, 0.3), Vector3(0, -0.1, 0), _mat(color, 0.0, 0.2, 5.0))
			for k in range(3):
				_box(root, Vector3(0.05, 0.3, 0.05), Vector3(-0.3 + k * 0.3, 0.05, 0), core_m, Vector3(0, 0, 20 * (k - 1)))
		"pillar", "bone":
			pass # eruption pillars are spawned along the path by main.gd
		"star_seal":
			# Twelve-ray star mandala lying on the floor.
			var ring := TorusMesh.new()
			ring.inner_radius = 1.55
			ring.outer_radius = 1.7
			ring.rings = 32
			_part(root, ring, Vector3.ZERO, _mat(color, 0.0, 0.3, 4.5))
			var inner := TorusMesh.new()
			inner.inner_radius = 0.7
			inner.outer_radius = 0.78
			inner.rings = 24
			_part(root, inner, Vector3.ZERO, _mat(color.lightened(0.4), 0.0, 0.3, 5.0))
			for k in range(12):
				var ray := _box(root, Vector3(0.05, 0.02, 1.5 if k % 2 == 0 else 1.0), Vector3.ZERO, _mat(color.lightened(0.2), 0.0, 0.3, 4.0), Vector3(0, k * 30.0, 0))
				ray.position = Vector3(sin(deg_to_rad(k * 30.0)), 0, cos(deg_to_rad(k * 30.0))) * (0.75 if k % 2 == 0 else 0.5)
		"ice_decoy":
			# Ice statue: a translucent crystal figure.
			var ice := _mat(color, 0.1, 0.05, 1.2)
			ice.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			ice.albedo_color = Color(color.r, color.g, color.b, 0.55)
			ice.refraction_enabled = false
			_cyl(root, 0.22, 0.32, 1.2, Vector3(0, -0.2, 0), ice, 6)
			_ball(root, 0.2, Vector3(0, 0.6, 0), ice)
			_cyl(root, 0.0, 0.12, 0.5, Vector3(0.3, 0.1, 0), ice, 5, Vector3(0, 0, -30))
			_cyl(root, 0.0, 0.12, 0.5, Vector3(-0.3, 0.1, 0), ice, 5, Vector3(0, 0, 30))
			_cyl(root, 0.0, 0.1, 0.4, Vector3(0, -0.8, 0.25), ice, 5, Vector3(60, 0, 0))
		"flame_wall":
			# Fire wall: a sword in the floor inside layered flame sheets.
			_box(root, Vector3(0.1, 1.5, 0.04), Vector3(0, -0.15, 0), _mat(Color(0.75, 0.75, 0.8), 0.9, 0.25))
			_box(root, Vector3(0.5, 0.08, 0.08), Vector3(0, 0.62, 0), _mat(Color(0.8, 0.6, 0.2), 0.9, 0.3))
			for k in range(3):
				var fl := _cyl(root, 0.05, 0.5 - k * 0.1, 2.0 - k * 0.3, Vector3(0, -0.05 + k * 0.1, 0), _mat(color.lerp(Color(1, 0.9, 0.4), k * 0.35), 0.0, 0.3, 4.0 + k), 7)
				fl.transparency = 0.35 + k * 0.15
		_:
			_ball(root, 0.2, Vector3.ZERO, _mat(color, 0.0, 0.2, 4.0))
	return root

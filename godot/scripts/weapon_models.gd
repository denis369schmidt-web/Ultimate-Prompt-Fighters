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
		"salamander":
			# Glimm: crystal salamander, fox sized. Slate blue head (frost) fading to an ember
			# dark tail, crystal crest alternating ice/ember, glowing fuse at the tail tip.
			# Built with the ground at rig y = 0; the origin sits in the middle of the body.
			var rig := Node3D.new()
			rig.position.y = -0.11
			root.add_child(rig)
			var skin_f := _mat(Color("2f4570"), 0.1, 0.5)
			var skin_r := _mat(Color("4d2a22"), 0.1, 0.55)
			var char_m := _mat(Color("251714"), 0.0, 0.7)
			var belly := _mat(Color("93a9c9"), 0.0, 0.6)
			var ice := _mat(Color("7dd3fc"), 0.1, 0.12, 1.6)
			var ember := _mat(Color("ff5a1f"), 0.1, 0.2, 2.2)
			var hot := _mat(Color("ffc56b"), 0.0, 0.2, 4.5)
			var eye_m := _mat(Color("9be3ff"), 0.0, 0.1, 1.4)
			var pupil := _mat(Color("0b0f1a"), 0.0, 0.2)
			var seg := func(a: Vector3, b: Vector3, r0: float, r1: float, m: Material) -> void:
				var d: Vector3 = b - a
				var c := CylinderMesh.new()
				c.bottom_radius = r0
				c.top_radius = r1
				c.height = d.length()
				c.radial_segments = 10
				c.rings = 1
				var mi := MeshInstance3D.new()
				mi.mesh = c
				mi.material_override = m
				var y := d.normalized()
				var x := y.cross(Vector3.FORWARD if absf(y.dot(Vector3.FORWARD)) < 0.9 else Vector3.RIGHT).normalized()
				mi.transform = Transform3D(Basis(x, y, x.cross(y)), (a + b) * 0.5)
				rig.add_child(mi)
			var blob := func(r: float, pos: Vector3, m: Material, scl: Vector3) -> void:
				var b := _ball(rig, r, pos, m)
				b.scale = scl
			# Body: one smooth ellipsoid, slate blue (frost half).
			var body_m := _mat(Color("34497a"), 0.1, 0.5)
			var bsph := SphereMesh.new()
			bsph.radius = 0.09
			bsph.height = 0.18
			bsph.radial_segments = 20
			bsph.rings = 12
			var bd := _part(rig, bsph, Vector3(-0.01, 0.112, 0), body_m, Vector3(0, 0, -90))
			bd.scale = Vector3(0.72, 2.6, 0.88)
			# Ember half: the hips and tail turn rust red.
			blob.call(0.08, Vector3(-0.135, 0.112, 0), skin_r, Vector3(1.55, 0.7, 0.86))
			blob.call(0.07, Vector3(-0.02, 0.085, 0), belly, Vector3(2.8, 0.42, 0.95))
			blob.call(0.056, Vector3(0.2, 0.125, 0), skin_f, Vector3(1.05, 0.8, 0.95))
			blob.call(0.07, Vector3(0.285, 0.135, 0), skin_f, Vector3(1.38, 0.56, 1.12))
			blob.call(0.058, Vector3(0.29, 0.113, 0), belly, Vector3(1.32, 0.38, 1.0))
			for s in [-1.0, 1.0]:
				# Bulging eyes on top of the head, looking forward and out.
				blob.call(0.021, Vector3(0.3, 0.165, s * 0.043), skin_f, Vector3.ONE)
				blob.call(0.016, Vector3(0.308, 0.172, s * 0.05), eye_m, Vector3.ONE)
				blob.call(0.008, Vector3(0.318, 0.174, s * 0.058), pupil, Vector3(0.7, 1.4, 0.7))
			# Crystal crest along the spine, swept back, alternating ice and ember.
			var crest := [[0.21, 0.165, 0.06], [0.13, 0.168, 0.095], [0.05, 0.17, 0.115], [-0.03, 0.17, 0.105], [-0.11, 0.165, 0.085], [-0.19, 0.155, 0.06]]
			for k in range(crest.size()):
				var cr: Array = crest[k]
				var h: float = cr[2]
				var sh := _cyl(rig, 0.0, h * 0.28, h, Vector3(float(cr[0]) - h * 0.21, float(cr[1]) + h * 0.42, 0), ice if k % 2 == 0 else ember, 5, Vector3(0, 0, 28))
				sh.scale = Vector3(1.0, 1.0, 0.6)
			# Glowing spots along the flanks: frost on the front half, ember on the back half.
			for s in [-1.0, 1.0]:
				for k in range(4):
					var sx: float = 0.13 - k * 0.085
					var sp := _ball(rig, 0.011, Vector3(sx, 0.125, s * (0.072 - absf(sx) * 0.05)), ice if sx > 0.0 else ember)
					sp.scale = Vector3(1.4, 0.8, 0.5)
			# Four short sprawling legs; diagonal pairs forward/back like a walking newt.
			for lg in [[0.11, 1.0, 0.05], [0.11, -1.0, -0.04], [-0.13, 1.0, -0.04], [-0.13, -1.0, 0.05]]:
				var lx: float = lg[0]
				var s: float = lg[1]
				var dx: float = lg[2]
				var leg_m: Material = skin_f if lx > 0.0 else skin_r
				var hip := Vector3(lx, 0.1, s * 0.05)
				var knee := Vector3(lx + dx, 0.14, s * 0.14)
				var foot := Vector3(lx + dx * 1.6, 0.012, s * 0.18)
				_ball(rig, 0.032, hip + Vector3(0, 0.005, s * 0.012), leg_m)
				seg.call(hip, knee, 0.034, 0.022, leg_m)
				_ball(rig, 0.022, knee, leg_m)
				seg.call(knee, foot, 0.021, 0.015, leg_m)
				var pad := _ball(rig, 0.026, foot, leg_m)
				pad.scale = Vector3(1.4, 0.5, 1.2)
				for t in [-1.0, 0.0, 1.0]:
					_ball(rig, 0.008, foot + Vector3(0.026, -0.004, t * 0.016), belly)
			# Tail: tapering, curling up, charcoal toward the end, ember bands and a glowing fuse.
			var tail := [Vector3(-0.2, 0.11, 0), Vector3(-0.31, 0.095, 0.02), Vector3(-0.42, 0.1, 0.035), Vector3(-0.51, 0.13, 0.02), Vector3(-0.575, 0.175, -0.005), Vector3(-0.6, 0.23, -0.015)]
			var tr := [0.056, 0.045, 0.034, 0.025, 0.018, 0.012]
			for k in range(tail.size() - 1):
				var tm: Material = skin_r if k < 2 else char_m
				seg.call(tail[k], tail[k + 1], tr[k], tr[k + 1], tm)
				_ball(rig, tr[k + 1], tail[k + 1], tm)
			for k in [2, 3]:
				var band := TorusMesh.new()
				band.inner_radius = tr[k] * 0.95
				band.outer_radius = tr[k] * 1.12
				band.rings = 16
				band.ring_segments = 6
				var bi := _part(rig, band, tail[k], ember)
				bi.look_at_from_position(tail[k], tail[k] + (tail[k + 1] - tail[k]), Vector3.UP)
				bi.rotate_object_local(Vector3.RIGHT, PI * 0.5)
			var tip: Vector3 = tail[tail.size() - 1]
			_ball(rig, 0.024, tip + Vector3(-0.005, 0.012, 0), ember)
			_ball(rig, 0.014, tip + Vector3(-0.008, 0.022, 0), hot)
			var flame := _cyl(rig, 0.0, 0.016, 0.06, tip + Vector3(-0.012, 0.055, 0), hot, 6, Vector3(0, 0, 15))
			flame.transparency = 0.25
			var sparks := CPUParticles3D.new()
			sparks.amount = 8
			sparks.lifetime = 0.6
			sparks.position = tip + Vector3(-0.01, 0.04, 0)
			sparks.direction = Vector3.UP
			sparks.spread = 25.0
			sparks.gravity = Vector3(0, 0.6, 0)
			sparks.initial_velocity_min = 0.2
			sparks.initial_velocity_max = 0.45
			var spm := SphereMesh.new()
			spm.radius = 0.008
			spm.height = 0.016
			spm.radial_segments = 6
			spm.rings = 3
			spm.material = _mat(Color("ffb347"), 0.0, 0.3, 5.0)
			sparks.mesh = spm
			var fade := Gradient.new()
			fade.set_color(0, Color(1, 1, 1, 1))
			fade.set_color(1, Color(1, 0.4, 0.1, 0))
			sparks.color_ramp = fade
			rig.add_child(sparks)
		"alien_hound":
			# Zirra: lean, long-legged alien sighthound. Violet fur, glowing turquoise stripes that
			# wrap the body, deep chest, tucked waist, long neck and snout, tall ears, thin tail.
			# Built in meters (+X forward, feet at y = -0.5) with its own looping gallop.
			var fur := _mat(Color("7a2cc4"), 0.0, 0.72)
			fur.rim_enabled = true
			fur.rim = 0.6
			fur.rim_tint = 0.35
			var belly_m := _mat(Color("a67ce0"), 0.0, 0.8)
			var dark := _mat(Color("2e1466"), 0.1, 0.45)
			var vein := _mat(Color("2ee6d6"), 0.0, 0.3, 2.6)
			var eye := _mat(Color("7ffff4"), 0.0, 0.2, 6.0)
			var ell := func(parent: Node3D, c: Vector3, r: Vector3, m: Material, rot: Vector3) -> MeshInstance3D:
				var sm := SphereMesh.new()
				sm.radius = 1.0
				sm.height = 2.0
				sm.radial_segments = 20
				sm.rings = 10
				var mi := _part(parent, sm, c, m, rot)
				mi.scale = r
				return mi
			# Glowing band around an ellipsoid at x offset dx (follows its cross-section).
			var band := func(parent: Node3D, c: Vector3, r: Vector3, dx: float, tilt: float, w: float) -> void:
				var f := sqrt(maxf(0.0, 1.0 - (dx / r.x) * (dx / r.x)))
				var tm := TorusMesh.new()
				tm.inner_radius = 1.0
				tm.outer_radius = 1.0 + w
				tm.rings = 24
				tm.ring_segments = 6
				var mi := _part(parent, tm, c + Vector3(dx, 0, 0), vein, Vector3(0, 0, 90 + tilt))
				mi.scale = Vector3(r.y * f * 1.02, 0.35, r.z * f * 1.02)
			var limb := func(parent: Node3D, length: float, r0: float, r1: float, m: Material) -> void:
				_cyl(parent, r1, r0, length, Vector3(0, -length * 0.5, 0), m, 10)
			var body := Node3D.new()
			body.name = "Body"
			root.add_child(body)
			# Torso: deep ribcage, tucked waist, compact haunch.
			var chest_c := Vector3(0.16, 0.16, 0)
			var chest_r := Vector3(0.28, 0.2, 0.14)
			ell.call(body, chest_c, chest_r, fur, Vector3(0, 0, -8))
			ell.call(body, Vector3(0.18, 0.06, 0), Vector3(0.2, 0.11, 0.11), belly_m, Vector3(0, 0, -6))
			var waist_c := Vector3(-0.17, 0.22, 0)
			var waist_r := Vector3(0.22, 0.1, 0.1)
			ell.call(body, waist_c, waist_r, fur, Vector3(0, 0, 6))
			ell.call(body, Vector3(-0.37, 0.2, 0), Vector3(0.15, 0.13, 0.12), fur, Vector3(0, 0, -10))
			# Stripes sweep back like chevrons, wider on the ribs, thin over the loin.
			band.call(body, chest_c, chest_r, 0.06, 24.0, 0.035)
			band.call(body, chest_c, chest_r, -0.06, 30.0, 0.03)
			band.call(body, chest_c, chest_r, -0.17, 36.0, 0.03)
			band.call(body, waist_c, waist_r, -0.04, 40.0, 0.07)
			band.call(body, Vector3(-0.37, 0.2, 0), Vector3(0.15, 0.13, 0.12), 0.03, 42.0, 0.06)
			# Neck and head.
			var neck := _cyl(body, 0.06, 0.11, 0.3, Vector3(0.4, 0.35, 0), fur, 12, Vector3(0, 0, -45))
			neck.name = "Neck"
			for k in range(2):
				var nb := TorusMesh.new()
				nb.inner_radius = 1.0
				nb.outer_radius = 1.08
				nb.rings = 18
				nb.ring_segments = 6
				var nm := _part(body, nb, Vector3(0.36 + k * 0.08, 0.31 + k * 0.08, 0), vein, Vector3(0, 0, -45 + k * 10))
				nm.scale = Vector3(0.1 - k * 0.018, 0.3, 0.1 - k * 0.018)
			var head := Node3D.new()
			head.name = "Head"
			head.position = Vector3(0.53, 0.52, 0)
			body.add_child(head)
			ell.call(head, Vector3(0, 0, 0), Vector3(0.1, 0.075, 0.07), fur, Vector3(0, 0, -6))
			# Long narrow snout, darker nose.
			_cyl(head, 0.022, 0.05, 0.24, Vector3(0.16, -0.035, 0), fur, 10, Vector3(0, 0, -96))
			ell.call(head, Vector3(0.28, -0.05, 0), Vector3(0.025, 0.02, 0.02), dark, Vector3.ZERO)
			ell.call(head, Vector3(0.12, -0.065, 0), Vector3(0.1, 0.018, 0.035), dark, Vector3(0, 0, -8))
			for s in [-1.0, 1.0]:
				ell.call(head, Vector3(0.07, 0.015, 0.05 * s), Vector3(0.022, 0.011, 0.012), eye, Vector3(0, 30 * s, -10))
				# Tall pointed ears, swept back, with a glowing inner line.
				var ear := Node3D.new()
				ear.position = Vector3(-0.03, 0.06, 0.045 * s)
				ear.rotation_degrees = Vector3(14 * s, 0, 28)
				head.add_child(ear)
				var em := _cyl(ear, 0.0, 0.05, 0.22, Vector3(0, 0.11, 0), fur, 4)
				em.scale = Vector3(1.0, 1.0, 0.35)
				_cyl(ear, 0.0, 0.006, 0.16, Vector3(0.012, 0.09, 0.0), vein, 4)
				# Cheek stripe running back from the eye.
				_cyl(head, 0.004, 0.009, 0.12, Vector3(0.0, 0.0, 0.066 * s), vein, 4, Vector3(0, 0, 80))
			# Legs: pivot chains so the gallop can swing them.
			for s in [-1.0, 1.0]:
				var side := "L" if s > 0 else "R"
				var fl := Node3D.new()
				fl.name = "F" + side
				fl.position = Vector3(0.26, 0.06, 0.085 * s)
				body.add_child(fl)
				ell.call(fl, Vector3(0, -0.03, 0), Vector3(0.07, 0.11, 0.05), fur, Vector3.ZERO)
				limb.call(fl, 0.3, 0.045, 0.032, fur)
				_cyl(fl, 0.005, 0.008, 0.2, Vector3(0.036, -0.17, 0), vein, 4)
				var fk := Node3D.new()
				fk.name = "Knee"
				fk.position = Vector3(0, -0.3, 0)
				fl.add_child(fk)
				_ball(fk, 0.033, Vector3.ZERO, fur)
				limb.call(fk, 0.27, 0.03, 0.02, fur)
				_cyl(fk, 0.005, 0.007, 0.2, Vector3(0.022, -0.13, 0), vein, 4)
				ell.call(fk, Vector3(0.03, -0.28, 0), Vector3(0.05, 0.022, 0.032), dark, Vector3.ZERO)
				var hl := Node3D.new()
				hl.name = "H" + side
				hl.position = Vector3(-0.38, 0.14, 0.08 * s)
				body.add_child(hl)
				ell.call(hl, Vector3(0.02, -0.08, 0), Vector3(0.09, 0.14, 0.06), fur, Vector3(0, 0, 20))
				limb.call(hl, 0.26, 0.055, 0.035, fur)
				var hk := Node3D.new()
				hk.name = "Knee"
				hk.position = Vector3(0, -0.26, 0)
				hl.add_child(hk)
				limb.call(hk, 0.26, 0.032, 0.022, fur)
				_ball(hk, 0.036, Vector3.ZERO, fur)
				_cyl(hk, 0.005, 0.007, 0.18, Vector3(-0.03, -0.12, 0), vein, 4)
				var hh := Node3D.new()
				hh.name = "Hock"
				hh.position = Vector3(0, -0.26, 0)
				hk.add_child(hh)
				_ball(hh, 0.024, Vector3.ZERO, fur)
				limb.call(hh, 0.18, 0.022, 0.018, fur)
				ell.call(hh, Vector3(0.035, -0.18, 0), Vector3(0.05, 0.022, 0.032), dark, Vector3.ZERO)
			# Long thin tail, low curve with a glowing tip.
			var tail := Node3D.new()
			tail.name = "Tail"
			tail.position = Vector3(-0.5, 0.25, 0)
			body.add_child(tail)
			var seg: Node3D = tail
			var bends := [-104.0, 10.0, 10.0, 8.0, -12.0, -18.0]
			for k in range(bends.size()):
				var t := Node3D.new()
				t.rotation_degrees = Vector3(0, 0, bends[k])
				if k > 0: t.position = Vector3(0, -0.1, 0)
				seg.add_child(t)
				var r0 := 0.026 - k * 0.0035
				_cyl(t, r0 - 0.0035, r0, 0.11, Vector3(0, -0.05, 0), vein if k == bends.size() - 1 else fur, 8)
				if k > 0: _ball(t, r0, Vector3.ZERO, fur)
				seg = t
			# Gallop (one stride per hop of the run bob in main.gd).
			var anim := Animation.new()
			anim.length = 0.26
			anim.loop_mode = Animation.LOOP_LINEAR
			var key := func(path: String, vals: Array, phase: float) -> void:
				var tr := anim.add_track(Animation.TYPE_VALUE)
				anim.track_set_path(tr, NodePath(path + ":rotation:z"))
				anim.track_set_interpolation_type(tr, Animation.INTERPOLATION_CUBIC)
				anim.value_track_set_update_mode(tr, Animation.UPDATE_CONTINUOUS)
				var n := vals.size()
				for k in range(n + 1):
					var tt := fposmod(float(k) / n + phase, 1.0) * anim.length
					anim.track_insert_key(tr, minf(tt, anim.length - 0.001), deg_to_rad(float(vals[k % n])))
			for side in ["L", "R"]:
				var ph := 0.0 if side == "L" else 0.08
				key.call("Body/F" + side, [40.0, 10.0, -30.0, -10.0], ph)
				key.call("Body/F" + side + "/Knee", [0.0, 0.0, -20.0, -80.0], ph)
				key.call("Body/H" + side, [20.0, 40.0, 10.0, -30.0], ph + 0.5)
				key.call("Body/H" + side + "/Knee", [-50.0, -45.0, -40.0, -70.0], ph + 0.5)
				key.call("Body/H" + side + "/Knee/Hock", [45.0, 40.0, 30.0, 70.0], ph + 0.5)
			key.call("Body", [-4.0, 0.0, 4.0, 0.0], 0.0)
			key.call("Body/Head", [6.0, 0.0, -6.0, 0.0], 0.1)
			key.call("Body/Tail", [6.0, -4.0, 6.0, 14.0], 0.0)
			var lib := AnimationLibrary.new()
			lib.add_animation("run", anim)
			var player := AnimationPlayer.new()
			player.add_animation_library("", lib)
			player.autoplay = "run"
			root.add_child(player)
		"anchor":
			# Neris's chain anchor: rusty iron ship anchor flying crown first (+X), a violet crystal
			# set into the crown, and a length of real chain links trailing back to her gauntlet.
			var iron := _mat(Color("4a4440"), 0.75, 0.55)
			var rust := _mat(Color("5c3a26"), 0.55, 0.7)
			var crys := _mat(color, 0.1, 0.05, 3.0)
			_cyl(root, 0.036, 0.042, 0.5, Vector3(-0.02, 0, 0), iron, 8, Vector3(0, 0, 90))
			# Crown: two arms curving back from the crown, spade flukes at their tips.
			var stick := func(pa: Vector3, pb: Vector3, r0: float, r1: float, m: Material) -> void:
				var d: Vector3 = pb - pa
				var c := CylinderMesh.new()
				c.bottom_radius = r0
				c.top_radius = r1
				c.height = d.length()
				c.radial_segments = 8
				c.rings = 1
				var y := d.normalized()
				var x := y.cross(Vector3.BACK if absf(y.z) < 0.9 else Vector3.RIGHT).normalized()
				var mi := _part(root, c, Vector3.ZERO, m)
				mi.transform = Transform3D(Basis(x, y, x.cross(y)), (pa + pb) * 0.5)
			var crown_p := Vector3(0.24, 0, 0)
			for s in [-1.0, 1.0]:
				var prev := crown_p
				for k in range(1, 6):
					var th := deg_to_rad(18.0 * k)
					var q := crown_p + Vector3(-(1.0 - cos(th)) * 0.21, s * sin(th) * 0.21, 0)
					stick.call(prev, q, 0.03 - k * 0.002, 0.028 - k * 0.002, iron)
					prev = q
				var fl := PrismMesh.new()
				fl.size = Vector3(0.13, 0.15, 0.03)
				_part(root, fl, prev + Vector3(-0.02, -s * 0.02, 0), rust, Vector3(0, 0, 180 + s * 30))
			_ball(root, 0.06, Vector3(0.24, 0, 0), iron)
			var gem := PrismMesh.new()
			gem.size = Vector3(0.09, 0.16, 0.09)
			_part(root, gem, Vector3(0.3, 0, 0), crys, Vector3(0, 0, -90))
			_ball(root, 0.035, Vector3(0.24, 0, 0.05), _mat(color.lightened(0.4), 0.0, 0.1, 5.0))
			# Stock (cross bar) and ring at the back.
			_cyl(root, 0.022, 0.022, 0.34, Vector3(-0.2, 0, 0), rust, 8, Vector3(90, 0, 0))
			for s in [-1.0, 1.0]: _ball(root, 0.03, Vector3(-0.2, 0, s * 0.17), iron)
			var ring := TorusMesh.new()
			ring.inner_radius = 0.035
			ring.outer_radius = 0.055
			ring.rings = 16
			ring.ring_segments = 6
			_part(root, ring, Vector3(-0.31, 0, 0), iron, Vector3(90, 0, 0))
			# Trailing chain: alternating links.
			var link := TorusMesh.new()
			link.inner_radius = 0.03
			link.outer_radius = 0.045
			link.rings = 12
			link.ring_segments = 6
			var chain_m := _mat(Color("6b5a4e"), 0.7, 0.6)
			for k in range(14):
				var li := _part(root, link, Vector3(-0.39 - k * 0.085, sin(k * 0.7) * 0.01, 0), chain_m, Vector3(90 if k % 2 == 0 else 0, 0, 0))
				li.scale = Vector3(1.35, 1.0, 1.0)
		"glassfly":
			# Fenn, the glass-winged one: a dove-sized insect creature. Slate chitin, head with a
			# miner's-lamp eye (amber lens in a brass bezel), thorax with crystal spines, segmented
			# abdomen with glowing seams and a crystal sting, six tucked legs and two pairs of
			# veined turquoise glass wings that flutter. +X is forward, the origin is the thorax.
			var chitin := _mat(Color("2c3440"), 0.35, 0.32)
			chitin.rim_enabled = true
			chitin.rim = 0.5
			chitin.rim_tint = 0.6
			var plate := _mat(Color("3d4756"), 0.4, 0.28)
			var seam := _mat(color, 0.0, 0.3, 2.2)
			var brass := _mat(Color("b8893a"), 0.85, 0.3)
			var lamp := _mat(Color("ffb02e"), 0.0, 0.1, 6.0)
			var crys := _mat(color.lightened(0.2), 0.2, 0.05, 1.4)
			var ell := func(parent: Node3D, c: Vector3, r: Vector3, m: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
				var sm := SphereMesh.new()
				sm.radius = 1.0
				sm.height = 2.0
				sm.radial_segments = 16
				sm.rings = 8
				var mi := _part(parent, sm, c, m, rot)
				mi.scale = r
				return mi
			var body := Node3D.new()
			body.name = "Body"
			root.add_child(body)
			# Thorax and head.
			ell.call(body, Vector3(0.0, 0, 0), Vector3(0.085, 0.062, 0.058), chitin)
			ell.call(body, Vector3(0.01, 0.03, 0), Vector3(0.07, 0.035, 0.045), plate)
			ell.call(body, Vector3(0.11, 0.008, 0), Vector3(0.05, 0.048, 0.054), chitin)
			for s in [-1.0, 1.0]:
				ell.call(body, Vector3(0.115, 0.022, s * 0.04), Vector3(0.024, 0.026, 0.02), _mat(Color("16313a"), 0.6, 0.08, 0.4))
				_cyl(body, 0.002, 0.008, 0.05, Vector3(0.165, -0.035, s * 0.016), chitin, 6, Vector3(0, s * 20, 120))
			var bez := TorusMesh.new()
			bez.inner_radius = 0.024
			bez.outer_radius = 0.034
			bez.rings = 18
			bez.ring_segments = 6
			_part(body, bez, Vector3(0.155, 0.012, 0), brass, Vector3(0, 0, 90))
			var lens := _ball(body, 0.026, Vector3(0.152, 0.012, 0), lamp)
			lens.scale = Vector3(0.7, 1, 1)
			# Crystal spines on the back.
			for k in range(3):
				var sp := PrismMesh.new()
				sp.size = Vector3(0.025, 0.06 - k * 0.012, 0.025)
				_part(body, sp, Vector3(0.03 - k * 0.035, 0.07 - k * 0.006, 0), crys, Vector3(0, 0, 25 + k * 8))
			# Segmented abdomen, gently curving down, glowing seams, crystal sting.
			var tail := Node3D.new()
			tail.name = "Tail"
			tail.position = Vector3(-0.07, 0, 0)
			body.add_child(tail)
			var seg_n := 7
			for k in range(seg_n):
				var f := float(k) / seg_n
				var r := 0.034 * (1.0 - f * 0.5)
				var p := Vector3(-0.03 - k * 0.048, -f * f * 0.05, 0)
				ell.call(tail, p, Vector3(0.036, r, r * 0.95), chitin if k % 2 == 0 else plate, Vector3(0, 0, -f * 25.0))
				var band := TorusMesh.new()
				band.inner_radius = r * 0.8
				band.outer_radius = r * 0.93
				band.rings = 14
				band.ring_segments = 4
				_part(tail, band, p + Vector3(-0.03, -f * 0.012, 0), seam, Vector3(0, 0, 90 - f * 25.0))
			var sting := PrismMesh.new()
			sting.size = Vector3(0.03, 0.09, 0.03)
			_part(tail, sting, Vector3(-0.385, -0.06, 0), crys, Vector3(0, 0, 105))
			# Six thin legs tucked under the thorax.
			for s in [-1.0, 1.0]:
				for k in range(3):
					var hip := Vector3(0.04 - k * 0.04, -0.045, s * 0.03)
					var knee := hip + Vector3(0.02 - k * 0.02, -0.02, s * 0.03)
					var foot := knee + Vector3(-0.03 - k * 0.01, -0.025, -s * 0.01)
					for pair in [[hip, knee], [knee, foot]]:
						var a: Vector3 = pair[0]
						var b: Vector3 = pair[1]
						var leg := _cyl(body, 0.004, 0.006, (b - a).length(), Vector3.ZERO, chitin, 5)
						var ly := (b - a).normalized()
						var lx := ly.cross(Vector3.BACK).normalized()
						leg.transform = Transform3D(Basis(lx, ly, lx.cross(ly)), (a + b) * 0.5)
			# Wings: two pairs of veined glass (front pair longer), fluttering.
			# Dragonfly wing outline in the XZ plane (span along side * Z), UV u = span, v = chord.
			var wing_mesh := func(span: float, chord: float, side: float) -> ArrayMesh:
				var st := SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_TRIANGLES)
				var n := 12
				var rows: Array = []
				for i in range(n + 1):
					var t := float(i) / n
					var sh := sqrt(sin(PI * (0.04 + 0.96 * t) * 0.5 + 0.0001)) * sqrt(maxf(0.0, 1.0 - pow(t, 4.0)) + 0.0001)
					var lead := chord * 0.3 * sh
					var trail := -chord * 0.7 * sh * (1.0 - 0.25 * t)
					rows.append([Vector3(lead, 0, side * span * t), Vector3(trail, 0, side * span * t), t])
				for i in range(n):
					var q: Array = [[rows[i][0], Vector2(rows[i][2], 0.0)], [rows[i][1], Vector2(rows[i][2], 1.0)], [rows[i + 1][1], Vector2(rows[i + 1][2], 1.0)], [rows[i + 1][0], Vector2(rows[i + 1][2], 0.0)]]
					for idx in [0, 1, 2, 0, 2, 3]:
						st.set_normal(Vector3.UP)
						st.set_uv(q[idx][1])
						st.add_vertex(q[idx][0])
				return st.commit()
			# Vein pattern: long veins along the span, cross veins between them (glass cells).
			var wimg := Image.create(128, 32, false, Image.FORMAT_RGBA8)
			var rng := RandomNumberGenerator.new()
			rng.seed = 31
			var lines := [2, 7, 12, 17, 23, 29]
			for y in range(32):
				for x in range(128):
					var v := 0.18
					for l in lines:
						if absi(y - int(l + sin(x * 0.03 + l) * 1.5)) <= (1 if l == 2 else 0): v = 1.0
					if x % 9 == int(y * 0.37) % 9 and y > 2: v = maxf(v, 0.75)
					if x > 108 and y < 6: v = maxf(v, 0.6)
					wimg.set_pixel(x, y, Color(v, v, v, minf(1.0, v + 0.25)))
			wimg.generate_mipmaps()
			var wtex := ImageTexture.create_from_image(wimg)
			var wing_m := StandardMaterial3D.new()
			wing_m.albedo_color = Color(color.r, color.g, color.b, 0.32)
			wing_m.albedo_texture = wtex
			wing_m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			wing_m.cull_mode = BaseMaterial3D.CULL_DISABLED
			wing_m.metallic = 0.2
			wing_m.roughness = 0.05
			wing_m.emission_enabled = true
			wing_m.emission = color
			wing_m.emission_texture = wtex
			wing_m.emission_energy_multiplier = 0.9
			wing_m.rim_enabled = true
			wing_m.rim = 0.8
			var vein_m := _mat(Color("1d2a33"), 0.5, 0.3)
			var anim := Animation.new()
			anim.length = 0.6
			anim.loop_mode = Animation.LOOP_LINEAR
			for w in [["WF", 0.045, 0.38, 0.085, -10.0, 0.0], ["WH", -0.02, 0.35, 0.095, 16.0, 0.25]]:
				for s in [-1.0, 1.0]:
					var piv := Node3D.new()
					piv.name = "%s%s" % [w[0], "L" if s < 0 else "R"]
					piv.position = Vector3(float(w[1]), 0.045, s * 0.03)
					piv.rotation_degrees = Vector3(0, float(w[4]) * s, 0)
					body.add_child(piv)
					var wm := MeshInstance3D.new()
					wm.mesh = wing_mesh.call(float(w[2]), float(w[3]), s)
					wm.material_override = wing_m
					piv.add_child(wm)
					_cyl(piv, 0.002, 0.004, float(w[2]) * 0.8, Vector3(float(w[3]) * 0.24, 0.001, s * float(w[2]) * 0.4), vein_m, 5, Vector3(90, 0, 0))
					var tr := anim.add_track(Animation.TYPE_VALUE)
					anim.track_set_path(tr, NodePath("Body/%s:rotation:x" % piv.name))
					anim.track_set_interpolation_type(tr, Animation.INTERPOLATION_CUBIC)
					var cycles := 5
					for k in range(cycles * 2 + 1):
						var tt := minf(fposmod(float(k) / (cycles * 2) + float(w[5]) / cycles, 1.0) * anim.length, anim.length - 0.001)
						anim.track_insert_key(tr, tt, deg_to_rad((28.0 if k % 2 == 0 else -18.0) * s))
			var tt2 := anim.add_track(Animation.TYPE_VALUE)
			anim.track_set_path(tt2, NodePath("Body/Tail:rotation:z"))
			anim.track_set_interpolation_type(tt2, Animation.INTERPOLATION_CUBIC)
			for k in range(5): anim.track_insert_key(tt2, minf(k * 0.15, 0.599), deg_to_rad([0.0, 6.0, 0.0, -5.0, 0.0][k]))
			var lib := AnimationLibrary.new()
			lib.add_animation("hover", anim)
			var player := AnimationPlayer.new()
			player.add_animation_library("", lib)
			player.autoplay = "hover"
			root.add_child(player)
		"anvil":
			var iron := _mat(Color(0.2, 0.2, 0.22), 0.9, 0.35)
			_box(root, Vector3(0.9, 0.22, 0.4), Vector3(0, 0.2, 0), iron)
			_box(root, Vector3(0.4, 0.3, 0.3), Vector3(0, -0.05, 0), iron)
			_box(root, Vector3(0.7, 0.14, 0.42), Vector3(0, -0.26, 0), iron)
			var horn := _cyl(root, 0.0, 0.11, 0.35, Vector3(0.6, 0.22, 0), iron, 8, Vector3(0, 0, -90))
			horn.scale = Vector3(1, 1, 0.8)
			_box(root, Vector3(0.92, 0.03, 0.42), Vector3(0, 0.32, 0), _mat(color, 0.0, 0.2, 3.0))
		"moon_crescent":
			var mt := TorusMesh.new()
			mt.inner_radius = 0.45
			mt.outer_radius = 0.6
			var mc := _part(root, mt, Vector3.ZERO, _mat(Color.WHITE, 0.0, 0.2, 3.0), Vector3(90, 0, 0))
			mc.scale = Vector3(0.55, 1.0, 1.0)
			var cut := _ball(root, 0.5, Vector3(0.22, 0, 0), _mat(Color("e30a17"), 0.0, 0.4, 1.5))
			cut.scale = Vector3(0.6, 1.0, 0.2)
		"lasso":
			var rope := _mat(Color("c9a46a"), 0.0, 0.8)
			var lt := TorusMesh.new()
			lt.inner_radius = 0.28
			lt.outer_radius = 0.34
			_part(root, lt, Vector3(0.1, 0, 0), rope, Vector3(90, 0, 0))
			_cyl(root, 0.02, 0.02, 1.2, Vector3(-0.7, 0, 0), rope, 6, Vector3(0, 0, 90))
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
		"skeleton":
			var bn := _mat(Color(0.9, 0.88, 0.8), 0.0, 0.6)
			_ball(root, 0.17, Vector3(0, 0.75, 0), bn)
			_ball(root, 0.04, Vector3(0.06, 0.78, 0.15), glow_m)
			_ball(root, 0.04, Vector3(-0.06, 0.78, 0.15), glow_m)
			_cyl(root, 0.04, 0.04, 0.7, Vector3(0, 0.25, 0), bn, 6)
			for k in range(3):
				_box(root, Vector3(0.36 - k * 0.04, 0.035, 0.18), Vector3(0, 0.45 - k * 0.11, 0), bn)
			_cyl(root, 0.03, 0.03, 0.55, Vector3(0.2, 0.3, 0), bn, 6, Vector3(0, 0, 20))
			_cyl(root, 0.03, 0.03, 0.55, Vector3(-0.2, 0.3, 0), bn, 6, Vector3(0, 0, -20))
			_cyl(root, 0.035, 0.035, 0.75, Vector3(0.1, -0.5, 0), bn, 6)
			_cyl(root, 0.035, 0.035, 0.75, Vector3(-0.1, -0.5, 0), bn, 6)
		"strike_marker":
			var mk := TorusMesh.new()
			mk.inner_radius = 0.75
			mk.outer_radius = 0.9
			_part(root, mk, Vector3.ZERO, glow_m)
			_cyl(root, 0.03, 0.03, 9.0, Vector3(0, 4.5, 0), glow_m, 6)
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

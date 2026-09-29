"""
Frozen Summit - procedural ice crystal assets (Blender 4.5, headless).

Run:
  blender.exe --background --python make_ice_crystals.py

Produces (Y-up GLB, meters, origin at bottom center, textures embedded):
  godot/assets/models/generated/ice_cluster_large.glb  (~3 m,  <=12k tris)
  godot/assets/models/generated/ice_cluster_small.glb  (~1 m,  <= 4k tris)
  godot/assets/models/generated/ice_spire.glb          (~12 m, <= 8k tris)
and a 1280x720 Eevee preview: art/blender/generated/ice_preview.png

Materials (all glTF-safe, opaque -> no alpha sorting issues in Godot):
  Ice / IceDeep : baked vertical gradient texture (deep blue base -> pale tip),
                  low roughness, faint cyan emission for a magical glow.
  Snow          : near-white, rough.
  Rock          : Poly Haven rock_wall_10 (CC0) diffuse / normal(GL) / roughness.
"""
import bpy
import bmesh
import math
import os
import random
from mathutils import Vector, Matrix, noise

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
OUT_DIR = os.path.join(ROOT, "godot", "assets", "models", "generated")
TEX_DIR = os.path.join(ROOT, "godot", "assets", "polyhaven", "textures", "rock_wall_10")
PREVIEW = os.path.join(HERE, "ice_preview.png")
RENDER_PREVIEW = True

# material slot order is identical on every part so joins stay consistent
M_ICE, M_ICE_DEEP, M_SNOW, M_ROCK = 0, 1, 2, 3


def reset_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


# ================================================================ materials
def lerp(a, b, t):
    return tuple(x + (y - x) * t for x, y in zip(a, b))


def gradient_image(name, stops, w=16, h=256, seed=1):
    """Vertical colour ramp with faint growth bands, packed so it embeds in GLB.
    stops: list of (v, (r,g,b)) in sRGB display values."""
    rng = random.Random(seed)
    img = bpy.data.images.new(name, w, h, alpha=False)
    bands = [rng.uniform(-1, 1) for _ in range(h)]
    px = []
    for y in range(h):
        v = y / (h - 1)
        for i in range(len(stops) - 1):
            if stops[i][0] <= v <= stops[i + 1][0]:
                t = (v - stops[i][0]) / (stops[i + 1][0] - stops[i][0])
                t = t * t * (3 - 2 * t)
                c = lerp(stops[i][1], stops[i + 1][1], t)
                break
        # soft horizontal growth striations (stronger toward the base)
        b = (bands[y] * 0.5 + bands[max(0, y - 1)] * 0.3 + bands[min(h - 1, y + 1)] * 0.2)
        k = 0.035 * (1.0 - v) * b
        for x in range(w):
            kx = k + 0.01 * math.sin(x * 0.8 + y * 0.05)
            px.extend((min(1, max(0, c[0] + kx)), min(1, max(0, c[1] + kx)),
                       min(1, max(0, c[2] + kx)), 1.0))
    img.pixels = px
    img.pack()
    return img


def ice_material(name, img, emit, emit_strength, rough):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    p = nt.nodes["Principled BSDF"]
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = img
    tex.extension = "EXTEND"
    nt.links.new(tex.outputs["Color"], p.inputs["Base Color"])
    p.inputs["Roughness"].default_value = rough
    p.inputs["Metallic"].default_value = 0.0
    p.inputs["IOR"].default_value = 1.31
    p.inputs["Emission Color"].default_value = (*emit, 1.0)
    p.inputs["Emission Strength"].default_value = emit_strength
    m.diffuse_color = (0.6, 0.85, 1.0, 1.0)
    return m


def snow_material():
    m = bpy.data.materials.new("Snow")
    m.use_nodes = True
    p = m.node_tree.nodes["Principled BSDF"]
    p.inputs["Base Color"].default_value = (0.86, 0.91, 0.98, 1.0)
    p.inputs["Roughness"].default_value = 0.85
    p.inputs["Emission Color"].default_value = (0.6, 0.8, 1.0, 1.0)
    p.inputs["Emission Strength"].default_value = 0.03
    m.diffuse_color = (0.9, 0.94, 1.0, 1.0)
    return m


def rock_material():
    m = bpy.data.materials.new("Rock")
    m.use_nodes = True
    nt = m.node_tree
    p = nt.nodes["Principled BSDF"]

    def img(fn, colorspace):
        im = bpy.data.images.load(os.path.join(TEX_DIR, fn), check_existing=True)
        im.colorspace_settings.name = colorspace
        n = nt.nodes.new("ShaderNodeTexImage")
        n.image = im
        return n

    diff = img("rock_wall_10_diff_2k.jpg", "sRGB")
    rough = img("rock_wall_10_rough_2k.jpg", "Non-Color")
    nor = img("rock_wall_10_nor_gl_2k.jpg", "Non-Color")
    nmap = nt.nodes.new("ShaderNodeNormalMap")
    nt.links.new(diff.outputs["Color"], p.inputs["Base Color"])
    nt.links.new(rough.outputs["Color"], p.inputs["Roughness"])
    nt.links.new(nor.outputs["Color"], nmap.inputs["Color"])
    nt.links.new(nmap.outputs["Normal"], p.inputs["Normal"])
    m.diffuse_color = (0.35, 0.35, 0.37, 1.0)
    return m


def build_materials():
    g_ice = gradient_image("IceGradient", [
        (0.00, (0.10, 0.36, 0.72)),
        (0.30, (0.30, 0.66, 0.94)),
        (0.72, (0.66, 0.90, 1.00)),
        (1.00, (0.93, 0.99, 1.00))], seed=3)
    g_deep = gradient_image("IceDeepGradient", [
        (0.00, (0.05, 0.20, 0.52)),
        (0.35, (0.16, 0.48, 0.86)),
        (0.80, (0.50, 0.82, 0.99)),
        (1.00, (0.82, 0.96, 1.00))], seed=9)
    ice = ice_material("Ice", g_ice, (0.25, 0.75, 1.0), 0.18, 0.05)
    deep = ice_material("IceDeep", g_deep, (0.12, 0.50, 1.0), 0.22, 0.07)
    return [ice, deep, snow_material(), rock_material()]


# ================================================================ helpers
def box_uv(bm, scale, faces=None):
    """World-space box mapping (uniform texel density), for rock/snow."""
    uv = bm.loops.layers.uv.verify()
    for f in (faces if faces is not None else bm.faces):
        n = f.normal
        ax = max(range(3), key=lambda i: abs(n[i]))
        for l in f.loops:
            c = l.vert.co
            u, v = ((c.y, c.z), (c.x, c.z), (c.x, c.y))[ax]
            l[uv].uv = (u * scale, v * scale)


def height_uv(bm, z0, z1, faces=None):
    """Cylindrical-ish UV: V runs from base (0) to tip (1) -> ice gradient."""
    uv = bm.loops.layers.uv.verify()
    for f in (faces if faces is not None else bm.faces):
        for l in f.loops:
            c = l.vert.co
            u = (math.atan2(c.y, c.x) / math.tau) % 1.0
            v = min(1.0, max(0.0, (c.z - z0) / (z1 - z0)))
            l[uv].uv = (u, v)


def bm_to_object(bm, name, mats, smooth=False):
    me = bpy.data.meshes.new(name)
    bm.normal_update()
    bm.to_mesh(me)
    bm.free()
    for m in mats:
        me.materials.append(m)
    for poly in me.polygons:
        poly.use_smooth = smooth
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    return ob


def join(objs, name):
    bpy.ops.object.select_all(action="DESELECT")
    for o in objs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = objs[0]
    if len(objs) > 1:
        bpy.ops.object.join()
    ob = bpy.context.view_layer.objects.active
    ob.name = name
    ob.data.name = name
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    bpy.ops.object.material_slot_remove_unused()
    # triangulate (clean tangents for the rock normal map, deterministic facets)
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    bmesh.ops.triangulate(bm, faces=bm.faces, quad_method="BEAUTY", ngon_method="BEAUTY")
    bm.to_mesh(ob.data)
    bm.free()
    ob.data.update()
    return ob


def tri_count(ob):
    ob.data.calc_loop_triangles()
    return len(ob.data.loop_triangles)


def aim_matrix(tilt, azimuth, spin):
    return (Matrix.Rotation(azimuth, 4, "Z") @ Matrix.Rotation(tilt, 4, "Y")
            @ Matrix.Rotation(spin, 4, "Z"))


def bevel_sharp(bm, width, min_angle=25):
    bm.normal_update()
    edges = [e for e in bm.edges if len(e.link_faces) == 2
             and e.calc_face_angle(0) > math.radians(min_angle)]
    if edges and width > 0:
        bmesh.ops.bevel(bm, geom=edges, offset=width, offset_type="OFFSET",
                        segments=1, profile=0.5, affect="EDGES", clamp_overlap=True)


# ================================================================ crystal
def crystal(rng, length, radius, mat, loc, tilt, azimuth, sides=6,
            tip_frac=0.28, rings=4, taper=0.14, bevel=0.035, chip=True, snow_tip=False):
    """Faceted hexagonal prism, irregular pyramidal termination, bevelled edges,
    one chipped corner, slight bend and noise. Built along +Z, then aimed."""
    bm = bmesh.new()
    ang = [i * math.tau / sides + rng.uniform(-0.09, 0.09) for i in range(sides)]
    rad = [rng.uniform(0.86, 1.10) for _ in range(sides)]
    body = length * (1.0 - tip_frac)
    bend = Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), 0)) * radius * 0.14
    z0 = -radius * 0.7  # buried into the base
    seed = rng.uniform(0, 100)

    zs = [z0] + [body * t for t in sorted(rng.uniform(0.15, 0.9) for _ in range(rings - 1))]
    rings_v = []
    for z in zs + [None]:
        ring = []
        for i in range(sides):
            if z is None:  # shoulder: each corner at its own height -> uneven facets
                zz, t = body + rng.uniform(-0.28, 0.28) * radius, 1.0
            else:
                zz, t = z, max(0.0, z / body)
            r = radius * rad[i] * (1.0 - taper * t) * rng.uniform(0.975, 1.025)
            p = Vector((math.cos(ang[i]) * r, math.sin(ang[i]) * r, zz)) + bend * t * t
            n = noise.noise(Vector((p.x * 2.5 + seed, p.y * 2.5, p.z * 2.5 / max(radius, 0.1))))
            p.xy *= 1.0 + 0.045 * n
            ring.append(bm.verts.new(p))
        rings_v.append(ring)

    if chip and rng.random() < 0.85:  # knocked-off shoulder corner
        v = rings_v[-1][rng.randrange(sides)]
        v.co.xy *= rng.uniform(0.70, 0.84)
        v.co.z -= radius * rng.uniform(0.2, 0.4)
    if chip and rings > 2 and rng.random() < 0.5:  # dent on a mid edge
        v = rings_v[rng.randrange(1, rings)][rng.randrange(sides)]
        v.co.xy *= rng.uniform(0.86, 0.93)

    apex = bm.verts.new(Vector((rng.uniform(-0.2, 0.2) * radius,
                                rng.uniform(-0.2, 0.2) * radius, length)) + bend)
    bm.faces.new(list(reversed(rings_v[0])))
    for a, b in zip(rings_v[:-1], rings_v[1:]):
        for i in range(sides):
            j = (i + 1) % sides
            bm.faces.new((a[i], a[j], b[j], b[i]))
    top = rings_v[-1]
    tip_faces = [bm.faces.new((top[i], top[(i + 1) % sides], apex)) for i in range(sides)]
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)

    bevel_sharp(bm, radius * bevel)
    for f in bm.faces:
        f.material_index = mat
    height_uv(bm, z0, length)

    m = Matrix.Translation(loc) @ aim_matrix(tilt, azimuth, rng.uniform(0, math.tau))
    bmesh.ops.transform(bm, matrix=m, verts=bm.verts)
    bm.normal_update()
    if snow_tip:  # dust of snow on upward-facing tip facets
        for f in bm.faces:
            if f.normal.z > 0.8 and f.calc_center_median().z > loc.z + length * 0.4:
                f.material_index = M_SNOW
    return bm


# ================================================================ rock
def boulder(rng, center, rx, ry, rz, subdiv=4, snow_thresh=0.6, sink=0.3, seed=0.0):
    bm = bmesh.new()
    bmesh.ops.create_icosphere(bm, subdivisions=subdiv, radius=1.0)
    for v in bm.verts:
        d = v.co.normalized()
        n = noise.fractal(d * 1.3 + Vector((seed, seed * 0.7, 0)), 0.7, 2.0, 3)
        c = noise.noise(d * 4.5 + Vector((seed, 0, seed)))
        r = 1.0 + 0.16 * n + 0.07 * c
        p = Vector((d.x * rx * r, d.y * ry * r, d.z * rz * r))
        # terracing: faceted rock planes
        p.z = p.z * 0.85 + 0.15 * round(p.z / (rz * 0.35)) * rz * 0.35
        v.co = p
    for v in bm.verts:
        v.co.z -= rz * sink
        if v.co.z < 0:
            v.co.z = 0.0
    bm.normal_update()
    bottom = [f for f in bm.faces if all(v.co.z < 1e-4 for v in f.verts)]
    bmesh.ops.delete(bm, geom=bottom, context="FACES")
    bmesh.ops.translate(bm, vec=center, verts=bm.verts)
    bm.normal_update()
    for f in bm.faces:
        c = f.calc_center_median()
        jitter = 0.22 * noise.noise(c * 2.1 + Vector((seed, 1.0, 2.0)))
        f.material_index = M_SNOW if f.normal.z + jitter > snow_thresh else M_ROCK
    box_uv(bm, 0.45)
    return bm


def surface_z(bms, x, y):
    best = -1.0
    for bm in bms:
        for v in bm.verts:
            if (v.co.x - x) ** 2 + (v.co.y - y) ** 2 < 0.02:
                best = max(best, v.co.z)
    if best < 0:
        for bm in bms:
            near = sorted(bm.verts, key=lambda v: (v.co.x - x) ** 2 + (v.co.y - y) ** 2)[:3]
            best = max(best, max(v.co.z for v in near))
    return best


# ================================================================ assets
def build_cluster(name, mats, seed, height, n_crystals, s, boulders=3):
    rng = random.Random(seed)
    rocks = [boulder(rng, Vector((0, 0, 0)), 1.0 * s, 0.85 * s, 1.15 * s, subdiv=5,
                     snow_thresh=0.72, sink=0.25, seed=seed * 1.3)]
    for k in range(boulders - 1):
        a = rng.uniform(0, math.tau) if k == 0 else a + rng.uniform(1.8, 2.6)
        rocks.append(boulder(rng, Vector((math.cos(a), math.sin(a), 0)) * 0.9 * s,
                             0.55 * s, 0.48 * s, 0.7 * s, subdiv=4, snow_thresh=0.7,
                             sink=0.3, seed=seed + k * 7.7))

    specs = [(0.05 * s, 0.0, height * 0.9, 0.24 * s, math.radians(rng.uniform(3, 8)),
              rng.uniform(0, math.tau))]
    golden = math.pi * (3 - math.sqrt(5))
    for i in range(1, n_crystals):
        a = i * golden * 1.0 + rng.uniform(-0.3, 0.3)
        f = math.sqrt(i / n_crystals)
        rr = s * (0.22 + 0.55 * f) * rng.uniform(0.85, 1.1)
        L = height * rng.uniform(0.32, 0.7) * (1.1 - 0.55 * f)
        R = s * 0.2 * (L / (height * 0.6)) ** 0.7 * rng.uniform(0.8, 1.1)
        tilt = math.radians(12 + 48 * f + rng.uniform(-7, 7))
        specs.append((math.cos(a) * rr, math.sin(a) * rr, L, R, tilt, a))

    parts = []
    for i, (x, y, L, R, tilt, az) in enumerate(specs):
        z = surface_z(rocks, x, y) - R * 0.3
        mat = M_ICE_DEEP if i in (0, 3, 6) else M_ICE
        parts.append(crystal(rng, L, R, mat, Vector((x, y, z)), tilt, az,
                             rings=5 if L > 0.45 * height else 3,
                             tip_frac=rng.uniform(0.2, 0.3)))

    objs = [bm_to_object(b, "%s_rock%d" % (name, k), mats, smooth=True) for k, b in enumerate(rocks)]
    objs += [bm_to_object(b, "%s_c%d" % (name, k), mats) for k, b in enumerate(parts)]
    ob = join(objs, name)
    normalize(ob, height)
    return ob


def spire_shard(rng, height, base_r, segs, lean_dir, mat, cap=True):
    """Stacked, rotated, stepped ice prism with slanted snowy ledges and a
    broken, snow-capped top. Layered faceting like a glacier shard."""
    bm = bmesh.new()
    sides = 6
    z = -0.5
    radius = base_r
    center = Vector((0, 0, 0))
    rot = rng.uniform(0, math.tau)
    seg_hs = [rng.uniform(0.8, 1.25) for _ in range(segs)]
    tot = sum(seg_hs)
    seg_hs = [h * (height - z) / tot for h in seg_hs]
    prev_top = None
    ledges = []
    for s in range(segs):
        rot += rng.uniform(-0.55, 0.55)
        slope = Vector((rng.uniform(-1, 1), rng.uniform(-1, 1))) * 0.42
        ang = [rot + i * math.tau / sides + rng.uniform(-0.13, 0.13) for i in range(sides)]
        rad = [rng.uniform(0.82, 1.14) for _ in range(sides)]
        r_bot = radius
        last = s == segs - 1
        r_top = radius * (rng.uniform(0.60, 0.68) if last else rng.uniform(0.76, 0.86))
        z1 = z + seg_hs[s]
        seg_lean = lean_dir * seg_hs[s] * rng.uniform(0.05, 0.10)
        rings = []
        nr = 4
        for k in range(nr):
            t = k / (nr - 1)
            rr = r_bot + (r_top - r_bot) * t
            ring = []
            for i in range(sides):
                d = Vector((math.cos(ang[i]), math.sin(ang[i])))
                p = Vector((d.x * rr * rad[i], d.y * rr * rad[i], z + (z1 - z) * t))
                p.xy += center.xy + seg_lean.xy * t
                if 0 < k < nr - 1:
                    p.xy += d * rr * rng.uniform(-0.05, 0.06)
                if k == nr - 1 or (k == 0 and s > 0):
                    p.z += slope.dot(p.xy - center.xy)
                ring.append(bm.verts.new(p))
            rings.append(ring)
        if prev_top is None:
            bm.faces.new(list(reversed(rings[0])))
        else:
            for i in range(sides):
                j = (i + 1) % sides
                ledges.append(bm.faces.new((prev_top[i], prev_top[j], rings[0][j], rings[0][i])))
        for a, b in zip(rings[:-1], rings[1:]):
            for i in range(sides):
                j = (i + 1) % sides
                bm.faces.new((a[i], a[j], b[j], b[i]))
        prev_top = rings[-1]
        center = center + seg_lean
        radius = r_top * rng.uniform(0.92, 0.97)
        z = z1

    top_face = bm.faces.new(prev_top)
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
    # jagged broken top: slant the break
    piv = top_face.calc_center_median()
    sd = Vector((rng.uniform(-1, 1), rng.uniform(-1, 1), 0)).normalized()
    for v in prev_top:
        v.co.z += (v.co - piv).dot(sd) * 0.75
    bm.normal_update()
    ice_faces = [f for f in bm.faces if f is not top_face]
    height_uv_faces = ice_faces
    cap_set = set()
    if cap:
        ext = bmesh.ops.extrude_face_region(bm, geom=[top_face])
        nv = [e for e in ext["geom"] if isinstance(e, bmesh.types.BMVert)]
        nf = [e for e in ext["geom"] if isinstance(e, bmesh.types.BMFace)]
        pv = sum((v.co for v in nv), Vector()) / len(nv)
        for v in nv:
            v.co.xy = pv.xy + (v.co.xy - pv.xy) * 1.12
            v.co.z += rng.uniform(0.18, 0.30)
        for v in nv:
            cap_set.update(v.link_faces)
        poke = bmesh.ops.poke(bm, faces=nf)
        for v in poke["verts"]:
            v.co.z += 0.25
        cap_set.update(poke["faces"])
        bmesh.ops.delete(bm, geom=[top_face], context="FACES_ONLY") if top_face.is_valid else None
    bm.normal_update()
    cap_set = {f for f in cap_set if f.is_valid}
    for f in bm.faces:
        snow = f.normal.z > 0.62 or (f in cap_set)
        f.material_index = M_SNOW if snow else mat
    bevel_sharp(bm, 0.045 * base_r / 1.8, min_angle=28)
    bm.normal_update()
    zmin = min(v.co.z for v in bm.verts)
    zmax = max(v.co.z for v in bm.verts)
    height_uv(bm, zmin, zmax * 1.05)
    return bm


def build_spire(mats, seed=11, height=12.0):
    rng = random.Random(seed)
    lean = Vector((0.6, 0.3, 0)).normalized()
    parts = []
    main = spire_shard(rng, 11.2, 2.0, 4, lean, M_ICE_DEEP)
    parts.append((main, False))
    # fused twin crystal and a tall flanking blade -> jagged glacier silhouette
    parts.append((crystal(rng, 8.2, 1.05, M_ICE, Vector((-1.3, 0.5, 0.0)), math.radians(11),
                          math.pi + 0.3, rings=5, tip_frac=0.26, bevel=0.035), False))
    parts.append((crystal(rng, 6.4, 0.8, M_ICE_DEEP, Vector((1.1, 0.9, 0.0)), math.radians(13),
                          0.6, rings=4, tip_frac=0.3, bevel=0.035), False))

    shard_specs = [  # x, y, length, radius, tilt deg, azimuth
        (1.7, -0.6, 5.2, 0.62, 18, -0.2),
        (-0.4, -1.8, 3.8, 0.52, 28, -1.7),
        (1.4, 1.4, 3.2, 0.45, 30, 0.9),
        (-2.2, -1.0, 2.6, 0.42, 38, 3.6),
        (2.4, 0.6, 1.9, 0.34, 48, 0.2),
        (0.6, -2.4, 1.6, 0.30, 52, -1.4),
        (-1.9, 1.9, 2.1, 0.36, 40, 2.3),
    ]
    for (x, y, L, R, td, az) in shard_specs:
        mat = M_ICE if L < 3.5 else M_ICE_DEEP
        parts.append((crystal(rng, L, R, mat, Vector((x, y, 0.2)), math.radians(td), az,
                              rings=4, tip_frac=rng.uniform(0.22, 0.32), bevel=0.04,
                              snow_tip=False), False))

    parts.append((boulder(rng, Vector((0, 0, 0)), 3.1, 2.7, 1.7, subdiv=5,
                          snow_thresh=0.62, sink=0.35, seed=4.0), True))
    parts.append((boulder(rng, Vector((2.6, -1.8, 0)), 1.3, 1.1, 1.1, subdiv=4,
                          snow_thresh=0.62, sink=0.3, seed=9.0), True))
    parts.append((boulder(rng, Vector((-2.4, -1.5, 0)), 1.0, 0.9, 0.8, subdiv=3,
                          snow_thresh=0.6, sink=0.3, seed=2.0), True))

    objs = [bm_to_object(b, "spire_p%d" % i, mats, smooth=sm) for i, (b, sm) in enumerate(parts)]
    ob = join(objs, "IceSpire")
    normalize(ob, height)
    return ob


def normalize(ob, height):
    """Origin at bottom center (XY centre of bounds), exact target height."""
    me = ob.data
    xs = [v.co.x for v in me.vertices]
    ys = [v.co.y for v in me.vertices]
    zs = [v.co.z for v in me.vertices]
    cx, cy = (min(xs) + max(xs)) * 0.5, (min(ys) + max(ys)) * 0.5
    k = height / (max(zs) - min(zs))
    me.transform(Matrix.Scale(k, 4) @ Matrix.Translation((-cx, -cy, -min(zs))))
    me.update()


# ================================================================ export
def export_glb(ob, filename):
    bpy.ops.object.select_all(action="DESELECT")
    ob.select_set(True)
    bpy.context.view_layer.objects.active = ob
    path = os.path.join(OUT_DIR, filename)
    bpy.ops.export_scene.gltf(
        filepath=path, export_format="GLB", use_selection=True, export_apply=True,
        export_yup=True, export_materials="EXPORT", export_image_format="AUTO",
        export_texcoords=True, export_normals=True, export_tangents=True,
        export_cameras=False, export_lights=False, export_animations=False)
    return path


# ================================================================ preview
def setup_preview(objs):
    sc = bpy.context.scene
    sc.render.engine = "BLENDER_EEVEE_NEXT"
    sc.render.resolution_x, sc.render.resolution_y = 1280, 720
    ee = sc.eevee
    for attr, val in (("use_raytracing", True), ("taa_render_samples", 32),
                      ("use_shadows", True)):
        if hasattr(ee, attr):
            setattr(ee, attr, val)
    sc.view_settings.view_transform = "AgX"
    try:
        sc.view_settings.look = "AgX - Medium High Contrast"
    except TypeError:
        pass

    world = bpy.data.worlds.new("Night")
    world.use_nodes = True
    bg = world.node_tree.nodes["Background"]
    bg.inputs["Color"].default_value = (0.008, 0.02, 0.06, 1)
    bg.inputs["Strength"].default_value = 1.0
    sc.world = world

    large, small, spire = objs
    large.location = (-4.0, -2.5, 0)
    small.location = (1.4, -10.8, 0)
    spire.location = (4.8, 5.5, 0)
    spire.rotation_euler.z = math.radians(20)

    bpy.ops.mesh.primitive_plane_add(size=120, location=(0, 20, 0))
    floor = bpy.context.active_object
    fm = bpy.data.materials.new("Floor")
    fm.use_nodes = True
    p = fm.node_tree.nodes["Principled BSDF"]
    p.inputs["Base Color"].default_value = (0.006, 0.013, 0.035, 1)
    p.inputs["Roughness"].default_value = 0.6
    floor.data.materials.append(fm)

    def light(name, kind, loc, target, energy, color, size=None):
        ld = bpy.data.lights.new(name, kind)
        ld.energy = energy
        ld.color = color
        if size is not None:
            ld.size = size
        lo = bpy.data.objects.new(name, ld)
        lo.location = loc
        lo.rotation_euler = (Vector(target) - Vector(loc)).to_track_quat("-Z", "Y").to_euler()
        sc.collection.objects.link(lo)
        return lo

    light("Key", "SUN", (-6, -8, 10), (0, 0, 0), 1.4, (0.88, 0.93, 1.0))
    light("Fill", "AREA", (-10, -12, 3), (0, 0, 2), 450, (0.3, 0.45, 0.9), size=10)
    light("RimL", "AREA", (-7, 3.5, 5), (-4.0, -2.5, 1.5), 1800, (0.2, 0.8, 1.0), size=3)
    light("RimL2", "AREA", (-1, 2.5, 4), (-4.0, -2.5, 1.5), 900, (0.4, 0.75, 1.0), size=2)
    light("RimS", "AREA", (2.4, -8.6, 1.6), (1.4, -10.8, 0.5), 160, (0.3, 0.85, 1.0), size=1.2)
    light("RimSp", "AREA", (9, 13, 12), (4.6, 5.0, 6), 7000, (0.25, 0.8, 1.0), size=6)
    light("RimSp2", "AREA", (-1, 12, 9), (4.6, 5.0, 6), 4000, (0.35, 0.7, 1.0), size=5)

    cam_d = bpy.data.cameras.new("Cam")
    cam_d.lens = 24
    cam = bpy.data.objects.new("Cam", cam_d)
    sc.collection.objects.link(cam)
    cam.location = (0.0, -17.0, 4.5)
    tgt = Vector((0.3, 0.0, 3.4))
    cam.rotation_euler = (tgt - cam.location).to_track_quat("-Z", "Y").to_euler()
    sc.camera = cam

    try:  # subtle bloom
        sc.use_nodes = True
        nt = sc.node_tree
        rl = nt.nodes.get("Render Layers") or nt.nodes.new("CompositorNodeRLayers")
        comp = nt.nodes.get("Composite") or nt.nodes.new("CompositorNodeComposite")
        g = nt.nodes.new("CompositorNodeGlare")
        g.glare_type = "BLOOM"
        g.quality = "HIGH"
        g.mix = -0.7
        g.threshold = 0.85
        g.size = 7
        nt.links.new(rl.outputs["Image"], g.inputs["Image"])
        nt.links.new(g.outputs["Image"], comp.inputs["Image"])
    except Exception as e:
        print("glare skipped:", e)

    sc.render.filepath = PREVIEW
    sc.render.image_settings.file_format = "PNG"
    bpy.ops.render.render(write_still=True)


# ================================================================ main
def main():
    reset_scene()
    mats = build_materials()
    large = build_cluster("IceClusterLarge", mats, seed=21, height=3.0, n_crystals=10, s=1.0)
    small = build_cluster("IceClusterSmall", mats, seed=5, height=1.0, n_crystals=4, s=0.36,
                          boulders=2)
    spire = build_spire(mats)

    report = []
    for ob, fn in ((large, "ice_cluster_large.glb"), (small, "ice_cluster_small.glb"),
                   (spire, "ice_spire.glb")):
        path = export_glb(ob, fn)
        d = ob.dimensions
        report.append("%s: %d tris, %.2f x %.2f x %.2f m, mats=%s -> %s" % (
            ob.name, tri_count(ob), d.x, d.y, d.z,
            [m.name for m in ob.data.materials], path))
    if RENDER_PREVIEW:
        setup_preview([large, small, spire])
    print("\n==== ICE REPORT ====")
    for r in report:
        print(r)


main()

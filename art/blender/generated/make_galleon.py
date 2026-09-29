"""
Procedural 17th-century pirate galleon for Prompt Fighter Ultimate (background prop).

Run (headless):
  blender.exe --background --python make_galleon.py [-- --no-render] [-- --extra <dir>]

Outputs:
  godot/assets/models/generated/galleon.glb       (GLB, textures embedded)
  art/blender/generated/galleon_preview.png       (1280x720 Eevee preview)

Conventions (Blender space, Z up):
  * origin = waterline (z=0), centred on the hull length/beam
  * bow points to Blender +Y  -> after glTF Y-up export the bow points to -Z (Godot forward)
  * 1 unit = 1 m. Hull length ~35 m on deck, main truck ~31 m (+flag pole to ~33 m) above waterline.
"""
import bpy, bmesh, math, os, sys, random, tempfile
import numpy as np
from mathutils import Vector

random.seed(7)
np.random.seed(7)

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
TEXDIR = os.path.join(ROOT, "godot", "assets", "polyhaven", "textures")
OUT_GLB = os.path.join(ROOT, "godot", "assets", "models", "generated", "galleon.glb")
OUT_PNG = os.path.join(HERE, "galleon_preview.png")
TMP = os.path.join(tempfile.gettempdir(), "pfu_galleon_gen")
os.makedirs(TMP, exist_ok=True)

ARGV = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
NO_RENDER = "--no-render" in ARGV
EXTRA_DIR = ARGV[ARGV.index("--extra") + 1] if "--extra" in ARGV else None

bpy.ops.wm.read_factory_settings(use_empty=True)

UVS = 3.0          # world metres per texture tile for planks
TEX_SIZE = 1024    # downscale the 2K scans for a background prop

# ----------------------------------------------------------------------------
# Materials
# ----------------------------------------------------------------------------
MATS = {}
IMG_CACHE = {}


def load_img(path, noncolor=False):
    if path in IMG_CACHE:
        return IMG_CACHE[path]
    img = bpy.data.images.load(path)
    if noncolor:
        img.colorspace_settings.name = "Non-Color"
    if TEX_SIZE and img.size[0] > TEX_SIZE:
        img.scale(TEX_SIZE, TEX_SIZE)
    IMG_CACHE[path] = img
    return img


def make_mat(name, color=(0.5, 0.5, 0.5), rough=0.6, metal=0.0, diff=None, nor=None,
             rgh=None, emis=None, emis_str=0.0, double=False, nor_strength=1.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    for n in list(nt.nodes):
        nt.nodes.remove(n)
    out = nt.nodes.new("ShaderNodeOutputMaterial")
    b = nt.nodes.new("ShaderNodeBsdfPrincipled")
    nt.links.new(b.outputs["BSDF"], out.inputs["Surface"])
    b.inputs["Base Color"].default_value = (*color, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    if diff:
        t = nt.nodes.new("ShaderNodeTexImage"); t.image = load_img(diff)
        nt.links.new(t.outputs["Color"], b.inputs["Base Color"])
    if rgh:
        t = nt.nodes.new("ShaderNodeTexImage"); t.image = load_img(rgh, True)
        nt.links.new(t.outputs["Color"], b.inputs["Roughness"])
    if nor:
        t = nt.nodes.new("ShaderNodeTexImage"); t.image = load_img(nor, True)
        nm = nt.nodes.new("ShaderNodeNormalMap")
        nm.inputs["Strength"].default_value = nor_strength
        nt.links.new(t.outputs["Color"], nm.inputs["Color"])
        nt.links.new(nm.outputs["Normal"], b.inputs["Normal"])
    if emis:
        b.inputs["Emission Color"].default_value = (*emis, 1)
        b.inputs["Emission Strength"].default_value = emis_str
    m.use_backface_culling = not double
    m.diffuse_color = (*color, 1)
    MATS[name] = m
    return m


def np_to_image(arr, name):
    """arr: (h, w, 3) float 0..1, row 0 = bottom. Saved as PNG in temp and reloaded."""
    h, w, _ = arr.shape
    rgba = np.concatenate([arr, np.ones((h, w, 1))], axis=2).astype(np.float32)
    img = bpy.data.images.new(name, w, h, alpha=False)
    img.pixels.foreach_set(rgba.ravel())
    path = os.path.join(TMP, name + ".png")
    img.filepath_raw = path
    img.file_format = "PNG"
    img.save()
    bpy.data.images.remove(img)
    img = bpy.data.images.load(path)
    IMG_CACHE[path] = img
    return path


def canvas_texture():
    H = W = 512
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    u = xx / W; v = yy / H
    base = np.array([0.83, 0.79, 0.69], np.float32)
    # low frequency mottling
    n = np.zeros((H, W), np.float32)
    for k in range(6):
        fx, fy = random.uniform(1, 6), random.uniform(1, 6)
        ph = random.uniform(0, 6.28)
        n += np.sin(u * fx * 6.28 + ph) * np.sin(v * fy * 6.28 + ph * 1.3) / 6
    n += np.random.normal(0, 0.025, (H, W)).astype(np.float32)
    col = base[None, None, :] * (1 + 0.07 * n[..., None])
    # vertical cloth panels (seams)
    pan = (u * 11) % 1.0
    seam = np.exp(-((pan - 0.0) ** 2) / 0.0004) + np.exp(-((pan - 1.0) ** 2) / 0.0004)
    seam += 0.5 * np.exp(-((pan - 0.06) ** 2) / 0.0002)
    col *= (1 - 0.13 * seam)[..., None]
    # reef bands near the head of the sail (top = v near 1)
    for rv in (0.86, 0.72):
        band = np.exp(-((v - rv) ** 2) / 0.00005)
        dots = (np.abs(((u * 28) % 1.0) - 0.5) < 0.12) & (np.abs(v - rv - 0.012) < 0.006)
        col *= (1 - 0.12 * band)[..., None]
        col[dots] *= 0.6
    # weathering: dirt towards the foot and edges
    dirt = (1 - v) ** 3 * 0.22 + 0.1 * np.clip(0.5 - np.abs(n) * 3, 0, 1) * (1 - v)
    tint = np.array([0.55, 0.47, 0.36], np.float32)
    col = col * (1 - dirt[..., None]) + tint * dirt[..., None] * 0.6
    # bolt rope border
    edge = np.minimum(np.minimum(u, 1 - u), np.minimum(v, 1 - v))
    col *= (1 - 0.25 * (edge < 0.012))[..., None]
    return np_to_image(np.clip(col, 0, 1), "galleon_canvas")


def flag_texture():
    H, W = 192, 320
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    col = np.zeros((H, W, 3), np.float32) + 0.018
    col += np.random.normal(0, 0.006, (H, W, 1)).astype(np.float32)
    bone = np.array([0.86, 0.82, 0.70], np.float32)
    red = np.array([0.55, 0.05, 0.04], np.float32)
    cx, cy = W * 0.42, H * 0.5
    dx, dy = xx - cx, yy - cy
    r = np.sqrt(dx * dx + dy * dy)
    mask = np.zeros((H, W), bool)
    mask |= (np.abs(r - 52) < 7)                              # ring
    for a in (math.radians(40), math.radians(-40)):          # crossed bars
        ca, sa = math.cos(a), math.sin(a)
        along = dx * ca + dy * sa
        perp = -dx * sa + dy * ca
        mask |= (np.abs(perp) < 6) & (np.abs(along) < 88)
    mask |= r < 14                                           # hub
    hub = r < 7
    col[mask] = bone
    col[hub] = red
    # hoist band
    col[:, :10] = np.array([0.1, 0.1, 0.1], np.float32)
    return np_to_image(np.clip(col, 0, 1), "galleon_flag")


def build_materials():
    dp = os.path.join(TEXDIR, "dark_planks", "dark_planks_%s_2k.jpg")
    bp = os.path.join(TEXDIR, "brown_planks_07", "brown_planks_07_%s_2k.jpg")
    make_mat("HullDark", diff=dp % "diff", nor=dp % "nor_gl", rgh=dp % "rough")
    make_mat("WoodUpper", diff=bp % "diff", nor=bp % "nor_gl", rgh=bp % "rough")
    make_mat("BoatWood", diff=bp % "diff", nor=bp % "nor_gl", rgh=bp % "rough", double=True)
    make_mat("PaintRed", color=(0.30, 0.035, 0.025), nor=bp % "nor_gl", rgh=bp % "rough")
    make_mat("PaintBlack", color=(0.025, 0.022, 0.02), nor=dp % "nor_gl", rgh=dp % "rough")
    make_mat("Trim", color=(0.62, 0.42, 0.12), rough=0.45, metal=0.35)
    make_mat("Iron", color=(0.05, 0.05, 0.055), rough=0.45, metal=0.85)
    make_mat("Rope", color=(0.13, 0.10, 0.07), rough=0.95)
    make_mat("PortBlack", color=(0.012, 0.01, 0.008), rough=1.0)
    make_mat("Lamp", color=(1.0, 0.72, 0.35), rough=0.3, emis=(1.0, 0.62, 0.25), emis_str=6.0)
    make_mat("WindowGlow", color=(0.12, 0.08, 0.04), rough=0.2, emis=(1.0, 0.55, 0.2), emis_str=1.6)
    cp = canvas_texture()
    make_mat("Canvas", diff=cp, rough=0.88, double=True)
    fp = flag_texture()
    make_mat("Flag", diff=fp, rough=0.8, double=True)


# ----------------------------------------------------------------------------
# Mesh builder
# ----------------------------------------------------------------------------
ROOT_OBJ = None
SHIP_OBJECTS = []


class MB:
    def __init__(self):
        self.v = []
        self.f = []

    def vert(self, co):
        self.v.append(Vector(co))
        return len(self.v) - 1

    def face(self, idx, mat, uv=None, want=None):
        self.f.append((list(idx), mat, uv, want))

    def build(self, name, smooth=True, sharp_deg=40, merge=None):
        me = bpy.data.meshes.new(name)
        bm = bmesh.new()
        bv = [bm.verts.new(co) for co in self.v]
        slots, recs, rec_faces = [], [], []
        for idx, mat, uv, want in self.f:
            if len(set(idx)) < 3:
                continue
            try:
                fc = bm.faces.new([bv[i] for i in idx])
            except ValueError:
                continue
            if mat not in slots:
                slots.append(mat)
            fc.material_index = slots.index(mat)
            uvmap = {idx[k]: uv[k] for k in range(len(idx))} if uv else None
            recs.append((fc, uvmap))
            if want is None:
                rec_faces.append(fc)
            elif not isinstance(want, str):
                fc.normal_update()
                if fc.normal.dot(Vector(want)) < 0:
                    fc.normal_flip()
        if rec_faces:
            bmesh.ops.recalc_face_normals(bm, faces=rec_faces)
        bm.verts.index_update()
        uvl = bm.loops.layers.uv.new("UVMap")
        for fc, uvmap in recs:
            if uvmap:
                for lp in fc.loops:
                    lp[uvl].uv = uvmap[lp.vert.index]
            else:
                fc.normal_update()
                n = fc.normal
                ax = max(range(3), key=lambda i: abs(n[i]))
                for lp in fc.loops:
                    c = lp.vert.co
                    if ax == 0:
                        q = (c.y, c.z)
                    elif ax == 1:
                        q = (c.x, c.z)
                    else:
                        q = (c.y, c.x)
                    lp[uvl].uv = (q[0] / UVS, q[1] / UVS)
        loose = [v for v in bm.verts if not v.link_faces]
        if loose:
            bmesh.ops.delete(bm, geom=loose, context="VERTS")
        if merge:
            bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=merge)
        bm.to_mesh(me)
        bm.free()
        for s in slots:
            me.materials.append(MATS[s])
        obj = bpy.data.objects.new(name, me)
        bpy.context.collection.objects.link(obj)
        if smooth:
            me.shade_smooth()
            try:
                me.set_sharp_from_angle(angle=math.radians(sharp_deg))
            except Exception:
                pass
        obj.parent = ROOT_OBJ
        SHIP_OBJECTS.append(obj)
        return obj


def tube(mb, pts, radii, sides, mat, caps=True, uvs=UVS):
    pts = [Vector(p) for p in pts]
    n = len(pts)
    if isinstance(radii, (int, float)):
        radii = [radii] * n
    T = []
    for i in range(n):
        if i == 0:
            t = pts[1] - pts[0]
        elif i == n - 1:
            t = pts[-1] - pts[-2]
        else:
            t = (pts[i + 1] - pts[i]).normalized() + (pts[i] - pts[i - 1]).normalized()
        T.append(t.normalized())
    ref = Vector((0, 0, 1)) if abs(T[0].z) < 0.9 else Vector((1, 0, 0))
    N = T[0].cross(ref).normalized()
    rings, L = [], [0.0]
    for i in range(n):
        if i > 0:
            N = (N - N.dot(T[i]) * T[i]).normalized()
            L.append(L[-1] + (pts[i] - pts[i - 1]).length)
        B = T[i].cross(N)
        rings.append([mb.vert(pts[i] + radii[i] * (math.cos(2 * math.pi * j / sides) * N +
                                                   math.sin(2 * math.pi * j / sides) * B))
                      for j in range(sides)])
    circ = 2 * math.pi * sum(radii) / n
    for i in range(n - 1):
        for j in range(sides):
            j2 = (j + 1) % sides
            idx = [rings[i][j], rings[i][j2], rings[i + 1][j2], rings[i + 1][j]]
            a0, a1 = j / sides * circ / uvs, (j + 1) / sides * circ / uvs
            uv = [(L[i] / uvs, a0), (L[i] / uvs, a1), (L[i + 1] / uvs, a1), (L[i + 1] / uvs, a0)]
            mb.face(idx, mat, uv)
    if caps:
        mb.face(rings[0][::-1], mat)
        mb.face(rings[-1], mat)


def box(mb, c, ax, ay, az, mat):
    c, ax, ay, az = Vector(c), Vector(ax), Vector(ay), Vector(az)
    vs = [mb.vert(c + sx * ax + sy * ay + sz * az) for sx in (-1, 1) for sy in (-1, 1) for sz in (-1, 1)]
    for f in [(0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)]:
        mb.face([vs[i] for i in f], mat)


def beam_box(mb, a, b, w, h, mat, up=(0, 0, 1)):
    a, b = Vector(a), Vector(b)
    d = b - a
    L = d.length
    t = d / L
    upv = Vector(up)
    if abs(t.dot(upv)) > 0.95:
        upv = Vector((1, 0, 0))
    s = t.cross(upv).normalized()
    u = s.cross(t).normalized()
    box(mb, (a + b) / 2, t * L / 2, s * w / 2, u * h / 2, mat)


def sphere(mb, c, r, mat, seg=8, rings=6):
    c = Vector(c)
    r = Vector(r) if not isinstance(r, (int, float)) else Vector((r, r, r))
    top = mb.vert(c + Vector((0, 0, r.z)))
    bot = mb.vert(c - Vector((0, 0, r.z)))
    grid = []
    for i in range(1, rings):
        th = math.pi * i / rings
        grid.append([mb.vert(c + Vector((r.x * math.sin(th) * math.cos(2 * math.pi * j / seg),
                                         r.y * math.sin(th) * math.sin(2 * math.pi * j / seg),
                                         r.z * math.cos(th)))) for j in range(seg)])
    for j in range(seg):
        j2 = (j + 1) % seg
        mb.face([top, grid[0][j], grid[0][j2]], mat)
        mb.face([bot, grid[-1][j2], grid[-1][j]], mat)
        for i in range(len(grid) - 1):
            mb.face([grid[i][j], grid[i + 1][j], grid[i + 1][j2], grid[i][j2]], mat)


def resample(poly, spacing):
    poly = [Vector(p) for p in poly]
    out = [poly[0]]
    acc = 0.0
    for a, b in zip(poly[:-1], poly[1:]):
        seg = (b - a).length
        pos = spacing - acc
        while pos < seg:
            out.append(a + (b - a) * (pos / seg))
            pos += spacing
        acc = seg - (pos - spacing)
    if (out[-1] - poly[-1]).length > spacing * 0.3:
        out.append(poly[-1])
    return out


def railing(mb, poly, h, post_mat="WoodUpper", rail_mat="Trim", spacing=0.5, post_w=0.09, rail_r=0.07):
    pts = resample(poly, spacing)
    for p in pts:
        box(mb, p + Vector((0, 0, h / 2)), (post_w / 2, 0, 0), (0, post_w / 2, 0), (0, 0, h / 2), post_mat)
    tops = [p + Vector((0, 0, h)) for p in pts]
    if len(tops) >= 2:
        tube(mb, tops, rail_r, 4, rail_mat)


# ----------------------------------------------------------------------------
# Hull shape functions (t: 0 = stern .. 1 = bow)
# ----------------------------------------------------------------------------
L_HULL = 35.0
Y0 = -17.5
BMAX = 4.9
THICK = 0.22
MAIN, QD, POOP, FC = 2.2, 4.8, 7.2, 4.5
TQ, TP, TF = 0.34, 0.15, 0.80
ZMAX = 0.6


def clamp01(x):
    return max(0.0, min(1.0, x))


def ss(e0, e1, x):
    t = clamp01((x - e0) / (e1 - e0))
    return t * t * (3 - 2 * t)


def sheer(t):
    return (3.3 + 2.7 * ss(TQ + 0.03, TQ - 0.03, t) + 2.2 * ss(TP + 0.025, TP - 0.025, t)
            + 2.3 * ss(TF - 0.03, TF + 0.03, t) + 0.6 * ((t - 0.55) / 0.55) ** 2)


def keel(t):
    return -3.4 + 2.4 * ss(0.86, 1.0, t) + 0.6 * ss(0.08, 0.0, t)


def beam(t):
    if t < 0.45:
        b = 0.70 + 0.30 * math.sin(math.pi / 2 * t / 0.45)
    else:
        x = (t - 0.45) / 0.55
        b = max(0.0, 1 - x * x) ** 0.55
    return BMAX * b


def hw(t, z):
    """outer half width of the hull at station t, height z"""
    t = clamp01(t)
    W = beam(t)
    zk = keel(t)
    kw = min(0.12, W)
    p = 0.45 + 0.7 * (abs(t - 0.5) / 0.5) ** 2
    if z <= ZMAX:
        s = clamp01((z - zk) / (ZMAX - zk))
        return kw + (W - kw) * math.sin(math.pi / 2 * s) ** p
    h = z - ZMAX
    return W * (1 - 0.13 * (1 - math.exp(-h / 2.2)) - 0.012 * h)


def hy(t, z):
    t = clamp01(t)
    zk, zs = keel(t), sheer(t)
    u = clamp01((z - zk) / (zs - zk))
    y = Y0 + L_HULL * t
    y -= 2.8 * (1 - u) ** 1.6 * ss(0.70, 1.0, t)   # raked, rounded forefoot
    y -= 1.4 * u * ss(0.20, 0.0, t)                # overhanging stern / transom rake
    return y


def t_of_y(y):
    return (y - Y0) / L_HULL


def hull_frame(t, z):
    p = Vector((hw(t, z), hy(t, z), z))
    e, dz = 0.003, 0.03
    a = Vector((hw(t + e, z), hy(t + e, z), z)); b = Vector((hw(t - e, z), hy(t - e, z), z))
    c = Vector((hw(t, z + dz), hy(t, z + dz), z + dz)); d = Vector((hw(t, z - dz), hy(t, z - dz), z - dz))
    along = (a - b).normalized()
    upv = (c - d).normalized()
    n = along.cross(upv).normalized()
    up = n.cross(along).normalized()
    return p, n, along, up


def M(v, sd):
    v = Vector(v)
    return Vector((sd * v.x, v.y, v.z))


# ----------------------------------------------------------------------------
# Hull
# ----------------------------------------------------------------------------
NO, NI = 22, 4


def build_hull():
    mb = MB()
    ts = set(round(0.5 - 0.5 * math.cos(math.pi * i / 79), 5) for i in range(80))
    for c in (TQ, TP, TF):
        for k in range(9):
            ts.add(round(c - 0.04 + 0.08 * k / 8, 5))
    ts = sorted(ts)
    stations = []
    for t in ts:
        zk, zs = keel(t), sheer(t)
        outer = []
        for k in range(NO):
            s = k / (NO - 1)
            s = s ** 0.9
            z = zk + (zs - zk) * s
            outer.append(Vector((hw(t, z), hy(t, z), z)))
        inner = []
        zb = MAIN - 0.05
        for m in range(NI):
            z = zb + (zs - zb) * m / (NI - 1)
            inner.append(Vector((max(hw(t, z) - THICK, 0.02), hy(t, z), z)))
        R = inner + outer[::-1]
        cls = ["i"] * NI + ["o"] * NO
        # arc length measured from keel
        arc = [0.0] * len(R)
        for k in range(len(R) - 2, -1, -1):
            arc[k] = arc[k + 1] + (R[k] - R[k + 1]).length
        ring = R + [Vector((-p.x, p.y, p.z)) for p in reversed(R)]
        vv = arc + arc[::-1]
        cl = cls + cls[::-1]
        ids = [mb.vert(p) for p in ring]
        uvs = [(ring[k].y / UVS, vv[k] / UVS) for k in range(len(ring))]
        stations.append((ids, uvs, cl, ring))

    nR = NI + NO
    # orientation test on a mid station, outer right face near the waterline
    i0 = len(stations) // 2
    j0 = NI + NO // 2
    A = stations[i0][3][j0]; B = stations[i0 + 1][3][j0]; C = stations[i0 + 1][3][j0 + 1]
    flip = (B - A).cross(C - A).x < 0

    for i in range(len(stations) - 1):
        ia, ua, cl, ra = stations[i]
        ib, ub, _, rb = stations[i + 1]
        for j in range(len(ia) - 1):
            idx = [ia[j], ib[j], ib[j + 1], ia[j + 1]]
            uv = [ua[j], ub[j], ub[j + 1], ua[j + 1]]
            if flip:
                idx.reverse(); uv.reverse()
            zc = (ra[j].z + ra[j + 1].z + rb[j].z + rb[j + 1].z) / 4
            if cl[j] == "i" and cl[j + 1] == "i":
                mat = "WoodUpper"
            elif cl[j] != cl[j + 1]:
                mat = "WoodUpper"
            elif zc < 2.5:
                mat = "HullDark"
            elif zc < 4.2:
                mat = "WoodUpper"
            else:
                mat = "PaintRed"
            mb.face(idx, mat, uv, "keep")

    # stern transom cap, split into lower planking and painted upper transom
    ids, _, _, ring = stations[0]
    Rr = [ids[NI + NO - 1 - k] for k in range(NO)]   # right outer ascending
    Ll = [ids[nR + k] for k in range(NO)]            # left outer ascending
    K = min(range(NO), key=lambda k: abs(ring[NI + NO - 1 - k].z - 2.6))
    mb.face(Rr[:K + 1] + Ll[:K + 1][::-1], "HullDark", None, (0, -1, 0))
    mb.face(Rr[K:] + Ll[K:][::-1], "PaintRed", None, (0, -1, 0))

    # wales and decorative bands
    for z, h, d, mat in [(0.25, 0.14, 0.13, "PaintBlack"), (1.75, 0.13, 0.12, "PaintBlack"),
                         (2.75, 0.12, 0.12, "PaintBlack"), (4.3, 0.08, 0.08, "Trim"),
                         (6.4, 0.08, 0.08, "Trim"), (8.3, 0.07, 0.07, "Trim")]:
        wale(mb, z, h, d, mat)

    # rudder
    zt = 4.2
    yb, ytp = hy(0.0, -2.6), hy(0.0, zt)
    pts = [Vector((0, yb - 0.05, -2.6)), Vector((0, ytp - 0.05, zt))]
    fr = [p + Vector((0, -1.3 if p.z < 1 else -0.6, 0)) for p in pts]
    q = [pts[0], pts[1], fr[1], fr[0]]
    vs = [mb.vert(p + Vector((sx, 0, 0))) for sx in (-0.17, 0.17) for p in q]
    for f in [(0, 1, 2, 3), (7, 6, 5, 4), (0, 4, 5, 1), (1, 5, 6, 2), (2, 6, 7, 3), (3, 7, 4, 0)]:
        mb.face([vs[k] for k in f], "HullDark")
    return mb.build("Galleon_Hull", sharp_deg=50, merge=0.004)


def wale(mb, z, h, d, mat, t0=0.003, t1=0.985, n=90):
    ts = [t0 + (t1 - t0) * (0.5 - 0.5 * math.cos(math.pi * i / (n - 1))) for i in range(n)]
    for sd in (1, -1):
        wants = [(sd * 0.3, 0, -1), (sd, 0, 0), (sd * 0.3, 0, 1)]
        seg = []

        def flush(seg):
            if len(seg) < 2:
                return
            for i in range(len(seg) - 1):
                for e in range(3):
                    mb.face([seg[i][e], seg[i + 1][e], seg[i + 1][e + 1], seg[i][e + 1]], mat, None, wants[e])
            mb.face(seg[0], mat, None, (0, -1, 0))
            mb.face(seg[-1], mat, None, (0, 1, 0))

        for t in ts:
            ok = (z + h + 0.12 < sheer(t)) and (z - h > keel(t) + 0.3) and hw(t, z) > 0.08
            if ok:
                prof = [(hw(t, z - h) - 0.02, z - h), (hw(t, z - h * 0.6) + d, z - h * 0.6),
                        (hw(t, z + h * 0.6) + d, z + h * 0.6), (hw(t, z + h) - 0.02, z + h)]
                seg.append([mb.vert((sd * x, hy(t, zz), zz)) for x, zz in prof])
            else:
                flush(seg); seg = []
        flush(seg)


# ----------------------------------------------------------------------------
# Decks, bulkheads, railings, deck furniture
# ----------------------------------------------------------------------------
def deck(mb, z, t0, t1, nt, mat="WoodUpper"):
    NX = 4
    grid = []
    for i in range(nt):
        t = t0 + (t1 - t0) * i / (nt - 1)
        w = max(hw(t, z) - THICK + 0.04, 0.03)
        y = hy(t, z)
        grid.append([mb.vert((-w + 2 * w * k / NX, y, z)) for k in range(NX + 1)])
    for i in range(nt - 1):
        for k in range(NX):
            idx = [grid[i][k], grid[i + 1][k], grid[i + 1][k + 1], grid[i][k + 1]]
            uv = [(mb.v[q].y / UVS, mb.v[q].x / UVS) for q in idx]
            mb.face(idx, mat, uv, (0, 0, 1))


def bulkhead(mb, t, z0, z1, facing, mat="WoodUpper"):
    NZ, NX = 4, 4
    rows = []
    for m in range(NZ + 1):
        z = z0 + (z1 - z0) * m / NZ
        w = max(hw(t, z) - THICK + 0.04, 0.03)
        y = hy(t, z)
        rows.append([mb.vert((-w + 2 * w * k / NX, y, z)) for k in range(NX + 1)])
    for m in range(NZ):
        for k in range(NX):
            idx = [rows[m][k], rows[m][k + 1], rows[m + 1][k + 1], rows[m + 1][k]]
            uv = [(mb.v[q].x / UVS, mb.v[q].z / UVS) for q in idx]
            mb.face(idx, mat, uv, (0, facing, 0))


def door(mb, t, x, z0, w, h, facing, mat="HullDark"):
    y = hy(t, z0 + h / 2) + facing * 0.04
    c = Vector((x, y, z0 + h / 2))
    ids = [mb.vert(c + Vector((sx * w / 2, 0, sz * h / 2))) for sx, sz in ((-1, -1), (1, -1), (1, 1), (-1, 1))]
    mb.face(ids, mat, None, (0, facing, 0))
    for a, b in [((-w / 2 - 0.06, 0, -h / 2), (-w / 2 - 0.06, 0, h / 2 + 0.06)),
                 ((w / 2 + 0.06, 0, -h / 2), (w / 2 + 0.06, 0, h / 2 + 0.06)),
                 ((-w / 2 - 0.06, 0, h / 2 + 0.06), (w / 2 + 0.06, 0, h / 2 + 0.06))]:
        beam_box(mb, c + Vector(a), c + Vector(b), 0.1, 0.1, "Trim")


def glow_window(mb, c, n, right, up, w, h, frame=True):
    c = Vector(c); n = Vector(n); right = Vector(right); up = Vector(up)
    ids = [mb.vert(c + n * 0.03 + right * sx * w / 2 + up * sz * h / 2)
           for sx, sz in ((-1, -1), (1, -1), (1, 1), (-1, 1))]
    mb.face(ids, "WindowGlow", None, tuple(n))
    if frame:
        f = 0.07
        box(mb, c + n * 0.06 + up * (h / 2 + f / 2), right * (w / 2 + f), up * f / 2, n * 0.06, "Trim")
        box(mb, c + n * 0.06 - up * (h / 2 + f / 2), right * (w / 2 + f), up * f / 2, n * 0.06, "Trim")
        box(mb, c + n * 0.06 + right * (w / 2 + f / 2), right * f / 2, up * h / 2, n * 0.06, "Trim")
        box(mb, c + n * 0.06 - right * (w / 2 + f / 2), right * f / 2, up * h / 2, n * 0.06, "Trim")
        box(mb, c + n * 0.05, right * 0.025, up * h / 2, n * 0.04, "Trim")      # mullion
        box(mb, c + n * 0.05, right * w / 2, up * 0.025, n * 0.04, "Trim")      # transom bar


def build_decks():
    mb = MB()
    deck(mb, MAIN, TQ - 0.03, TF + 0.03, 24)
    deck(mb, QD, 0.0, TQ - 0.005, 16)
    deck(mb, POOP, 0.0, TP - 0.005, 10)
    deck(mb, FC, TF + 0.005, 0.998, 12)
    bulkhead(mb, TQ - 0.005, MAIN - 0.05, QD, +1)
    bulkhead(mb, TP - 0.005, QD - 0.05, POOP, +1)
    bulkhead(mb, TF + 0.005, MAIN - 0.05, FC, -1)
    for x in (-1.3, 1.3):
        door(mb, TQ - 0.005, x, MAIN, 0.9, 1.75, +1)
        door(mb, TF + 0.005, x, MAIN, 0.8, 1.6, -1)
    door(mb, TP - 0.005, 0.0, QD, 0.9, 1.8, +1)
    for x in (-2.0, 2.0):
        c = Vector((x, hy(TP - 0.005, 6.0), 6.0))
        glow_window(mb, c, (0, 1, 0), (1, 0, 0), (0, 0, 1), 0.6, 0.7)

    # quarter windows on the stern castle sides
    for sd in (1, -1):
        for t in (0.035, 0.085):
            p, n, al, up = hull_frame(t, 6.0)
            glow_window(mb, M(p, sd), M(n, sd), M(al, sd), up, 0.55, 0.75)

    # capstan, barrels, gratings
    tube(mb, [(0, -3.8, MAIN), (0, -3.8, MAIN + 0.3), (0, -3.8, MAIN + 0.85), (0, -3.8, MAIN + 1.0)],
         [0.55, 0.4, 0.4, 0.6], 10, "WoodUpper")
    for k in range(4):
        a = k * math.pi / 4
        beam_box(mb, (-1.1 * math.cos(a), -3.8 - 1.1 * math.sin(a), MAIN + 0.9),
                 (1.1 * math.cos(a), -3.8 + 1.1 * math.sin(a), MAIN + 0.9), 0.08, 0.08, "WoodUpper")
    for (x, y) in [(3.0, 7.6), (3.0, 8.4), (-3.0, 7.9), (-2.4, 8.3), (2.9, -4.8)]:
        tube(mb, [(x, y, MAIN), (x, y, MAIN + 0.45), (x, y, MAIN + 0.9)], [0.3, 0.36, 0.3], 8, "WoodUpper")
        tube(mb, [(x, y, MAIN + 0.2), (x, y, MAIN + 0.26)], 0.35, 8, "Iron")
    box(mb, (0, -1.8, MAIN + 0.15), (1.0, 0, 0), (0, 0.8, 0), (0, 0, 0.15), "HullDark")
    box(mb, (0, 9.4, MAIN + 0.15), (0.9, 0, 0), (0, 0.7, 0), (0, 0, 0.15), "HullDark")
    # ship's wheel housing / binnacle on the quarterdeck
    box(mb, (0, -7.8, QD + 0.55), (0.35, 0, 0), (0, 0.3, 0), (0, 0, 0.55), "WoodUpper")
    tube(mb, [(0, -7.45, QD + 1.25), (0, -7.35, QD + 1.25)], 0.55, 10, "Trim")

    # railings on castle break fronts
    for t, z in ((TQ - 0.008, QD), (TP - 0.008, POOP), (TF + 0.008, FC)):
        w = hw(t, z) - THICK - 0.05
        y = hy(t, z)
        railing(mb, [(-w, y, z), (w, y, z)], 0.9)
    # castle top railings along the sheer
    poly = []
    for k in range(9):
        t = (TP - 0.012) * (1 - k / 8)
        zs = sheer(t)
        poly.append((hw(t, zs) - THICK / 2, hy(t, zs), zs))
    back = [(-x, y, z) for (x, y, z) in reversed(poly)]
    railing(mb, poly + back, 0.55, spacing=0.55)
    poly = []
    for k in range(9):
        t = TF + 0.012 + (0.975 - TF - 0.012) * k / 8
        zs = sheer(t)
        poly.append((hw(t, zs) - THICK / 2, hy(t, zs), zs))
    back = [(-x, y, z) for (x, y, z) in reversed(poly)]
    railing(mb, poly + back, 0.5, spacing=0.55)
    return mb.build("Galleon_Decks", sharp_deg=35)


def build_longboat():
    mb = MB()
    n, m = 12, 7
    cy, zb, depth, blen, bw = 4.6, MAIN + 0.35, 0.85, 6.2, 0.95
    rows = []
    for i in range(n):
        tt = i / (n - 1)
        b = bw * max(math.sin(math.pi * (0.06 + 0.88 * tt)), 0.0) ** 0.7 + 0.03
        y = cy + (tt - 0.5) * blen
        sheer_up = 0.25 * (2 * tt - 1) ** 2
        row = []
        for k in range(m):
            a = math.pi * k / (m - 1)
            x = b * math.cos(a)
            z = zb + depth + sheer_up - depth * math.sin(a) ** 0.7
            row.append(mb.vert((x, y, z)))
        rows.append(row)
    for i in range(n - 1):
        for k in range(m - 1):
            mb.face([rows[i][k], rows[i + 1][k], rows[i + 1][k + 1], rows[i][k + 1]], "BoatWood", None, "keep")
    for tt in (0.3, 0.5, 0.7):
        y = cy + (tt - 0.5) * blen
        box(mb, (0, y, zb + depth - 0.25), (0.85, 0, 0), (0, 0.12, 0), (0, 0, 0.04), "WoodUpper")
    for y in (cy - 1.8, cy + 1.8):
        box(mb, (0, y, MAIN + 0.2), (0.9, 0, 0), (0, 0.15, 0), (0, 0, 0.2), "HullDark")
    return mb.build("Galleon_Longboat", sharp_deg=60)


# ----------------------------------------------------------------------------
# Gun ports & cannons, stern, bow
# ----------------------------------------------------------------------------
def gun_port(mbp, mbc, t, z, sd, size=0.62):
    p, n, al, up = hull_frame(t, z)
    h = size / 2
    ids = [mbp.vert(M(p + n * 0.05 + al * sx * h * 0.9 + up * sz * h * 0.9, sd))
           for sx, sz in ((-1, -1), (1, -1), (1, 1), (-1, 1))]
    mbp.face(ids, "PortBlack", None, tuple(M(n, sd)))
    for c, ax, ay in [(p + up * (h + 0.05), al * (h + 0.1), up * 0.05),
                      (p - up * (h + 0.05), al * (h + 0.1), up * 0.05),
                      (p + al * (h + 0.05), al * 0.05, up * h),
                      (p - al * (h + 0.05), al * 0.05, up * h)]:
        box(mbp, M(c + n * 0.07, sd), M(ax, sd), M(ay, sd), M(n * 0.08, sd), "Trim")
    hinge = p + n * 0.12 + up * (h + 0.06)
    a = math.radians(30)
    d = (n * math.cos(a) + up * math.sin(a)).normalized()
    nl = al.cross(d).normalized()
    box(mbp, M(hinge + d * h, sd), M(al * h, sd), M(d * h, sd), M(nl * 0.04, sd), "PaintRed")
    pts = [p - n * 0.25, p + n * 0.75, p + n * 0.8, p + n * 0.98]
    tube(mbc, [M(q, sd) for q in pts], [0.15, 0.115, 0.145, 0.14], 8, "Iron")


def build_guns():
    mbp, mbc = MB(), MB()
    for sd in (1, -1):
        for k in range(8):
            gun_port(mbp, mbc, 0.25 + k * (0.745 - 0.25) / 7, 0.95, sd)
        for t in (0.07, 0.15, 0.23, 0.30):
            gun_port(mbp, mbc, t, 3.55, sd, 0.55)
        gun_port(mbp, mbc, 0.855, 3.25, sd, 0.5)
    return mbp.build("Galleon_GunPorts", sharp_deg=35), mbc.build("Galleon_Cannons", sharp_deg=50)


def transom_point(x, z, off=0.0):
    y = hy(0.0, z)
    zk, zs = keel(0.0), sheer(0.0)
    dy = -1.4 / (zs - zk)
    n = Vector((0, -1, dy)).normalized()
    return Vector((x, y, z)) + n * off, n


def build_stern():
    mb = MB()
    right = Vector((1, 0, 0))
    _, n = transom_point(0, 5.0)
    up = n.cross(right).normalized()
    if up.z < 0:
        up = -up
    # great cabin windows (under the poop) and gun-room windows
    for x in (-2.2, -1.1, 0.0, 1.1, 2.2):
        c, _ = transom_point(x, 6.0)
        glow_window(mb, c, n, right, up, 0.72, 1.0)
    for x in (-1.9, -0.65, 0.65, 1.9):
        c, _ = transom_point(x, 3.75)
        glow_window(mb, c, n, right, up, 0.6, 0.7)
    # stern gallery (balcony) with balustrade
    zg = 4.85
    c0, _ = transom_point(0, zg)
    depth = 0.95
    box(mb, c0 + Vector((0, -depth / 2, -0.08)), (3.0, 0, 0), (0, depth / 2, 0), (0, 0, 0.1), "WoodUpper")
    # carved support brackets
    for x in (-2.6, -1.3, 0, 1.3, 2.6):
        a, _ = transom_point(x, zg - 1.0)
        beam_box(mb, a, Vector((x, c0.y - depth + 0.1, zg - 0.12)), 0.12, 0.12, "Trim")
    yb = c0.y - depth + 0.08
    cL, _ = transom_point(-2.9, zg); cR, _ = transom_point(2.9, zg)
    poly = [(cL.x, cL.y - 0.05, zg), (-2.9, yb, zg), (2.9, yb, zg), (cR.x, cR.y - 0.05, zg)]
    railing(mb, poly, 0.85, post_mat="Trim", rail_mat="Trim", spacing=0.32, post_w=0.07)
    # ornate frame around the upper window band + name board
    for z in (5.35, 6.65):
        a, _ = transom_point(-2.8, z, 0.08); b, _ = transom_point(2.8, z, 0.08)
        beam_box(mb, a, b, 0.14, 0.12, "Trim")
    a, _ = transom_point(-2.1, 7.55, 0.06); b, _ = transom_point(2.1, 7.55, 0.06)
    beam_box(mb, a, b, 0.5, 0.12, "Trim")
    for x in (-2.8, 2.8):
        a, _ = transom_point(x, 5.35, 0.08); b, _ = transom_point(x, 6.65, 0.08)
        beam_box(mb, a, b, 0.14, 0.12, "Trim")

    # stern lanterns
    zs = sheer(0.0)
    ytop = hy(0.0, zs)
    for x, s in ((-2.3, 1.0), (0.0, 1.35), (2.3, 1.0)):
        base = Vector((x, ytop - 0.55 * s, zs + 0.35))
        beam_box(mb, (x, ytop + 0.15, zs - 0.1), base + Vector((0, 0, -0.05)), 0.1, 0.1, "Iron")
        tube(mb, [base, base + Vector((0, 0, 0.12 * s))], [0.16 * s, 0.2 * s], 6, "Iron")
        tube(mb, [base + Vector((0, 0, 0.12 * s)), base + Vector((0, 0, 0.55 * s)),
                  base + Vector((0, 0, 0.95 * s))], [0.24 * s, 0.33 * s, 0.26 * s], 6, "Lamp")
        tube(mb, [base + Vector((0, 0, 0.95 * s)), base + Vector((0, 0, 1.25 * s)),
                  base + Vector((0, 0, 1.4 * s))], [0.3 * s, 0.1 * s, 0.03 * s], 6, "Iron")
        sphere(mb, base + Vector((0, 0, 1.45 * s)), 0.07 * s, "Trim", 6, 4)
        for k in range(6):
            a = 2 * math.pi * (k + 0.5) / 6
            rr = 0.3 * s
            p0 = base + Vector((rr * math.cos(a), rr * math.sin(a), 0.12 * s))
            p1 = base + Vector((0.3 * s * math.cos(a), 0.3 * s * math.sin(a), 0.95 * s))
            beam_box(mb, p0, p1, 0.035 * s, 0.035 * s, "Iron")
    return mb.build("Galleon_SternDetails", sharp_deg=35)


def build_bow():
    mb = MB()
    stem_y = hy(0.995, 3.2)
    secs = []
    n = 9
    for i in range(n):
        f = i / (n - 1)
        y = stem_y - 0.6 + f * 4.6
        z = 2.9 + 1.4 * f ** 1.6
        w = 0.55 * (1 - f) + 0.14
        h = 0.5 * (1 - f) + 0.14
        secs.append([mb.vert((x, y, z + dz)) for x, dz in ((-w, -h), (w, -h), (w * 0.8, h), (-w * 0.8, h))])
    for i in range(n - 1):
        for k in range(4):
            k2 = (k + 1) % 4
            mb.face([secs[i][k], secs[i][k2], secs[i + 1][k2], secs[i + 1][k]], "PaintRed")
    mb.face(secs[0][::-1], "PaintRed"); mb.face(secs[-1], "PaintRed")
    tip = Vector((0, stem_y - 0.6 + 4.6, 2.9 + 1.4))
    # figurehead: a gilded rearing sea-serpent-like figure
    tube(mb, [tip + Vector((0, -1.2, -0.2)), tip + Vector((0, -0.2, 0.25)), tip + Vector((0, 0.35, 0.8)),
              tip + Vector((0, 0.45, 1.35)), tip + Vector((0, 0.25, 1.75))],
         [0.32, 0.3, 0.25, 0.2, 0.17], 8, "Trim")
    sphere(mb, tip + Vector((0, 0.45, 1.95)), (0.22, 0.42, 0.26), "Trim", 8, 6)
    for sd in (1, -1):   # swept wings / fins
        tube(mb, [tip + Vector((sd * 0.15, -0.3, 0.6)), tip + Vector((sd * 0.55, -0.9, 1.1)),
                  tip + Vector((sd * 0.7, -1.6, 1.3))], [0.12, 0.08, 0.02], 5, "Trim")
    # head rails from the beak back to the bow
    for sd in (1, -1):
        for zoff, r in ((0.0, 0.08), (0.55, 0.07)):
            t = 0.955
            zb = 4.3 + zoff
            pts = [tip + Vector((sd * 0.18, -0.4, zoff * 0.5)),
                   Vector((sd * 0.45, stem_y + 1.6, zb - 0.5)),
                   Vector((sd * (hw(t, zb) + 0.05), hy(t, zb), zb))]
            tube(mb, pts, r, 5, "Trim")
    # catheads
    for sd in (1, -1):
        t = 0.93
        zc = sheer(t) - 0.2
        p = Vector((sd * (hw(t, zc) - 0.2), hy(t, zc), zc))
        beam_box(mb, p, p + Vector((sd * 1.2, 0.5, 0.15)), 0.3, 0.3, "WoodUpper")
    # anchors hanging from the catheads
    for sd in (1, -1):
        t = 0.9
        x = sd * (hw(t, 3.0) + 0.35)
        y = hy(t, 3.0)
        tube(mb, [(x, y, 4.6), (x, y, 1.6)], 0.08, 6, "Iron")
        tube(mb, [(x, y - 0.8, 2.3), (x, y - 0.45, 1.75), (x, y, 1.55), (x, y + 0.45, 1.75), (x, y + 0.8, 2.3)],
             [0.05, 0.08, 0.09, 0.08, 0.05], 6, "Iron")
        box(mb, (x, y, 4.3), (0.9, 0, 0), (0, 0.08, 0), (0, 0, 0.08), "WoodUpper")
        tube(mb, [(x, y, 4.6), (x, y, 4.9)], 0.12, 6, "Iron")
    return mb.build("Galleon_Beakhead", sharp_deg=45)


# ----------------------------------------------------------------------------
# Masts, yards, sails
# ----------------------------------------------------------------------------
MASTS = {
    "main": dict(y=0.5,
                 segs=[(0.0, 20.5, 0.50, 0.38), (18.0, 27.8, 0.30, 0.20), (26.3, 31.4, 0.17, 0.08)],
                 top=(18.8, 1.6), nest=26.0,
                 yards=[(16.2, 18.0), (24.0, 13.0), (29.8, 8.0)],
                 sails=[(16.0, 7.8, 16.9, 18.0, 1.6), (23.8, 16.9, 12.2, 16.6, 1.3), (29.6, 24.6, 7.4, 11.8, 0.9)]),
    "fore": dict(y=11.0,
                 segs=[(0.0, 19.5, 0.45, 0.34), (17.0, 25.5, 0.27, 0.18), (24.3, 28.6, 0.15, 0.07)],
                 top=(17.8, 1.4), nest=None,
                 yards=[(15.3, 15.5), (22.0, 11.0), (26.8, 6.5)],
                 sails=[(15.1, 8.8, 14.6, 15.5, 1.5), (21.8, 15.9, 10.3, 14.4, 1.2), (26.6, 22.6, 6.0, 9.9, 0.8)]),
    "mizzen": dict(y=-9.5,
                   segs=[(0.0, 17.5, 0.36, 0.26), (14.8, 21.6, 0.20, 0.10)],
                   top=(15.5, 1.1), nest=None,
                   yards=[(20.2, 6.0)],
                   sails=[(20.0, 16.2, 5.5, 7.0, 0.7)]),
}
BOWSPRIT = (Vector((0, 14.0, 5.2)), Vector((0, 27.5, 10.8)))


def bs(f):
    return BOWSPRIT[0].lerp(BOWSPRIT[1], f)


def mast_r(m, z):
    for z0, z1, r0, r1 in m["segs"]:
        if z0 <= z <= z1:
            return r0 + (r1 - r0) * (z - z0) / (z1 - z0)
    return 0.2


SAIL_CORNERS = {}


def square_sail(mb, y0, z_top, z_bot, w_top, w_bot, bulge, key, nu=16, nv=12, roach=0.55):
    grid = []
    for i in range(nv + 1):
        v = i / nv
        row = []
        for j in range(nu + 1):
            u = j / nu
            x = (u - 0.5) * (w_top + (w_bot - w_top) * v)
            z = z_top + (z_bot + roach * math.sin(math.pi * u) - z_top) * v
            b = bulge * math.sin(math.pi * u) ** 0.8 * math.sin(0.7 * math.pi * v)
            b += 0.12 * bulge * math.sin(math.pi * v) * (1 - math.sin(math.pi * u))
            x *= 1 - 0.035 * b / max(bulge, 0.01)
            row.append(mb.vert((x, y0 + b, z)))
        grid.append(row)
    for i in range(nv):
        for j in range(nu):
            idx = [grid[i][j], grid[i][j + 1], grid[i + 1][j + 1], grid[i + 1][j]]
            uv = [(j / nu, 1 - i / nv), ((j + 1) / nu, 1 - i / nv), ((j + 1) / nu, 1 - (i + 1) / nv),
                  (j / nu, 1 - (i + 1) / nv)]
            mb.face(idx, "Canvas", uv, (0, 1, 0))
    SAIL_CORNERS[key] = (mb.v[grid[nv][0]].copy(), mb.v[grid[nv][nu]].copy())


def tri_sail(mb, A, B, C, bulge_dir, bulge, n=12):
    A, B, C = Vector(A), Vector(B), Vector(C)
    bd = Vector(bulge_dir)
    ids = {}
    for i in range(n + 1):
        for j in range(i + 1):
            la, lb, lc = 1 - i / n, (i - j) / n, j / n
            p = A * la + B * lb + C * lc
            p += bd * bulge * 27 * la * lb * lc ** 0.85 * 0.9
            ids[(i, j)] = (mb.vert(p), (lb + lc * 0.5, lc))
    for i in range(n):
        for j in range(i + 1):
            for tri in (((i, j), (i + 1, j), (i + 1, j + 1)), ((i, j), (i + 1, j + 1), (i, j + 1))):
                if tri[2][1] > tri[2][0] or any(k not in ids for k in tri):
                    continue
                mb.face([ids[k][0] for k in tri], "Canvas", [ids[k][1] for k in tri], tuple(bd))


def build_rig():
    mm, my, ms, mr = MB(), MB(), MB(), MB()
    rig = []   # (a, b, radius)
    ratlines = []

    def line(a, b, r=0.05):
        rig.append((Vector(a), Vector(b), r))

    for name, m in MASTS.items():
        y = m["y"]
        for z0, z1, r0, r1 in m["segs"]:
            tube(mm, [(0, y, z0), (0, y, (z0 + z1) / 2), (0, y, z1)], [r0, (r0 + r1) / 2 * 1.03, r1], 12, "WoodUpper")
            # iron bands
            for zz in (z0 + (z1 - z0) * 0.35, z0 + (z1 - z0) * 0.6):
                if zz > 3:
                    rr = mast_r(m, zz) + 0.03
                    tube(mm, [(0, y, zz - 0.06), (0, y, zz + 0.06)], rr, 12, "Iron")
        # mast caps
        for z0, z1, r0, r1 in m["segs"][:-1]:
            box(mm, (0, y + 0.2, z1 - 0.15), (r1 * 1.4, 0, 0), (0, r1 * 2.2, 0), (0, 0, 0.18), "HullDark")
        # top platform with trestles
        zt, R = m["top"]
        tube(mm, [(0, y, zt - 0.12), (0, y, zt + 0.12)], R, 14, "WoodUpper")
        tube(mm, [(0, y, zt + 0.12), (0, y, zt + 0.28)], R * 0.97, 14, "HullDark")
        for sd in (1, -1):
            beam_box(mm, (sd * 0.2, y - R * 0.9, zt - 0.25), (sd * 0.2, y + R * 0.9, zt - 0.25), 0.16, 0.2, "WoodUpper")
        # topmast crosstrees
        seg2 = m["segs"][1]
        zc = seg2[1] - 1.1
        beam_box(mm, (-1.2, y, zc), (1.2, y, zc), 0.12, 0.12, "WoodUpper")
        # crow's nest
        if m["nest"]:
            zn = m["nest"]
            tube(mm, [(0, y, zn - 0.45), (0, y, zn - 0.3), (0, y, zn + 0.55), (0, y, zn + 0.7)],
                 [0.55, 0.85, 0.85, 0.9], 12, "WoodUpper")
            for zz in (zn - 0.2, zn + 0.45):
                tube(mm, [(0, y, zz - 0.05), (0, y, zz + 0.05)], 0.9, 12, "Iron")
        # truck
        top_z = m["segs"][-1][1]
        sphere(mm, (0, y, top_z + 0.08), 0.13, "Trim", 6, 4)

        # yards and square sails
        yard_ys = []
        for k, (zy, ly) in enumerate(m["yards"]):
            yy = y + mast_r(m, zy) + 0.22
            sc = ly / 18.0 + 0.25
            tube(my, [(-ly / 2, yy, zy), (-ly / 4, yy, zy), (0, yy, zy), (ly / 4, yy, zy), (ly / 2, yy, zy)],
                 [0.07 * sc, 0.13 * sc, 0.2 * sc, 0.13 * sc, 0.07 * sc], 8, "WoodUpper")
            yard_ys.append(yy)
            # lifts to the masthead above
            zl = min(zy + 3.0, top_z - 0.2)
            for sd in (1, -1):
                line((sd * ly * 0.47, yy, zy), (sd * 0.2, y, zl), 0.035)
        for k, (zt_, zb_, wt, wb, bul) in enumerate(m["sails"]):
            square_sail(ms, yard_ys[k] + 0.18, zt_, zb_, wt, wb, bul, (name, k))

        # shrouds + ratlines
        nsh = 5 if name != "mizzen" else 4
        head_z = zt - 0.35
        feet = []
        tks = [t_of_y(y + 0.6 - 1.0 * k) for k in range(nsh)]
        zc_ = min(sheer(t) for t in tks) - 0.3
        for sd in (1, -1):
            lines = []
            for k, t in enumerate(tks):
                foot = Vector((sd * (hw(t, zc_) + 0.5), hy(t, zc_), zc_))
                head = Vector((sd * 0.35, y, head_z))
                line(foot, head, 0.05)
                lines.append((foot, head))
            tmid = sum(tks) / len(tks)
            span_y = (hy(tks[0], zc_) - hy(tks[-1], zc_)) / 2 + 0.5
            ymid = (hy(tks[0], zc_) + hy(tks[-1], zc_)) / 2
            box(mm, (sd * (hw(tmid, zc_) + 0.3), ymid, zc_ - 0.05), (0.32, 0, 0), (0, span_y, 0), (0, 0, 0.07), "WoodUpper")
            nr = int((head_z - zc_) * 0.85 / 0.62)
            for s in range(1, nr + 1):
                f = s / (nr + 1) * 0.88
                ratlines.append([a.lerp(b, f) for a, b in lines])
            # topmast shrouds to the rim of the top
            tm_head = Vector((sd * 0.22, y, seg2[1] - 1.3))
            tl = []
            for k in range(3):
                foot = Vector((sd * (R - 0.1), y + 0.35 - 0.4 * k, zt + 0.15))
                line(foot, tm_head, 0.04)
                tl.append((foot, tm_head))
            nr = int((tm_head.z - zt) * 0.8 / 0.62)
            for s in range(1, nr + 1):
                f = s / (nr + 1) * 0.85
                ratlines.append([a.lerp(b, f) for a, b in tl])
            # backstay
            tb = t_of_y(y - 6.0)
            zb = sheer(tb) - 0.3
            line((sd * (hw(tb, zb) + 0.3), hy(tb, zb), zb), (sd * 0.15, y, seg2[1] - 0.6), 0.045)

    yM, yF, yZ = MASTS["main"]["y"], MASTS["fore"]["y"], MASTS["mizzen"]["y"]
    # stays
    line((0, yM + 0.3, 18.5), (0, yF - 0.5, 6.2), 0.075)
    line((0, yM + 0.2, 27.2), (0, yF - 0.3, 18.1), 0.06)
    line((0, yM + 0.1, 31.0), (0, yF, 25.2), 0.045)
    line((0, yF + 0.3, 17.5), bs(0.82), 0.075)
    line((0, yF + 0.2, 25.0), bs(1.0), 0.06)
    line((0, yF + 0.1, 28.3), bs(1.0), 0.045)
    line((0, yZ + 0.2, 15.2), (0, yM - 0.5, 9.0), 0.06)
    line((0, yZ + 0.1, 21.2), (0, yM - 0.3, 18.9), 0.045)
    # bobstay & bowsprit shrouds
    line(bs(0.55), (0, hy(0.99, 1.2) + 0.1, 1.2), 0.06)
    for sd in (1, -1):
        line(bs(0.5), (sd * (hw(0.95, 3.5) + 0.05), hy(0.95, 3.5), 3.5), 0.045)
    # braces
    for k, (zy, ly) in enumerate(MASTS["main"]["yards"]):
        for sd in (1, -1):
            t = 0.08
            zs = sheer(t)
            line((sd * ly * 0.48, yM + 0.6, zy), (sd * (hw(t, zs) - 0.1), hy(t, zs), zs + 0.4), 0.035)
    for k, (zy, ly) in enumerate(MASTS["fore"]["yards"]):
        for sd in (1, -1):
            line((sd * ly * 0.48, yF + 0.5, zy), (sd * 0.4, yM, max(zy - 3.5, 6.0)), 0.035)
    for sd in (1, -1):
        line((sd * 2.9, yZ + 0.4, 20.2), (sd * 2.0, -18.6, 9.3), 0.03)
    # sheets of the courses
    for mname in ("main", "fore"):
        a, b = SAIL_CORNERS[(mname, 0)]
        for c, sd in ((a, -1), (b, 1)):
            t = t_of_y(c.y - 5.5)
            zs = sheer(t)
            line(c, (sd * (hw(t, zs) + 0.05), hy(t, zs), zs), 0.035)

    # bowsprit + spritsail
    tube(mm, [BOWSPRIT[0], bs(0.5), BOWSPRIT[1]], [0.38, 0.3, 0.14], 10, "WoodUpper")
    sp = bs(0.62)
    zy = sp.z - 0.45
    tube(my, [(-4.5, sp.y, zy), (0, sp.y, zy), (4.5, sp.y, zy)], [0.08, 0.15, 0.08], 8, "WoodUpper")
    line(sp, (0, sp.y, zy), 0.04)
    square_sail(ms, sp.y + 0.2, zy - 0.2, 4.3, 8.3, 9.6, 1.0, ("sprit", 0), nu=14, nv=8, roach=0.3)
    # jibs (headsails on the fore stays)
    F1, F1b = Vector((0, yF + 0.3, 17.5)), bs(0.82)
    tri_sail(ms, F1.lerp(F1b, 0.16), F1.lerp(F1b, 0.93), Vector((0, 16.3, 8.4)), (1, 0.15, 0), 0.7)
    F2, F2b = Vector((0, yF + 0.2, 25.0)), bs(1.0)
    tri_sail(ms, F2.lerp(F2b, 0.14), F2.lerp(F2b, 0.93), Vector((0, 18.6, 11.3)), (1, 0.15, 0), 0.6)
    for (F, Fb, fh, ft, C) in ((F1, F1b, 0.16, 0.93, (0, 16.3, 8.4)), (F2, Fb if False else F2b, 0.14, 0.93, (0, 18.6, 11.3))):
        line(C, (0.6, 15.2 if C[1] < 17 else 17.0, sheer(0.93) + 0.2), 0.03)

    # mizzen lateen yard and sail
    A = Vector((0.55, -2.8, 8.7)); B = Vector((0.55, -17.8, 19.3)); C = Vector((0.55, -17.4, 10.2))
    d = (B - A).normalized()
    tube(my, [A - d * 1.2, A.lerp(B, 0.5), B + d * 0.8], [0.09, 0.2, 0.07], 8, "WoodUpper")
    tri_sail(ms, A + Vector((0.12, 0, -0.2)), B + Vector((0.12, 0, -0.2)), C, (1, 0, 0), 0.8)
    line(C, (0.6, -18.4, sheer(0.0) + 0.3), 0.03)
    line(A, (0.3, -3.5, 3.4), 0.03)

    # flag pole + flag on the main truck
    top = MASTS["main"]["segs"][-1][1]
    tube(mm, [(0, yM, top), (0, yM, top + 1.8)], [0.06, 0.035], 6, "WoodUpper")

    # ropes: shrouds, stays ... and ratlines
    for a, b, r in rig:
        tube(mr, [a, b], r, 3, "Rope", caps=False)
    for pts in ratlines:
        tube(mr, pts, 0.028, 3, "Rope", caps=False)

    return (mm.build("Galleon_Masts", sharp_deg=50), my.build("Galleon_Yards", sharp_deg=50),
            ms.build("Galleon_Sails", sharp_deg=80), mr.build("Galleon_Rigging", smooth=False))


def build_flag():
    mb = MB()
    yM = MASTS["main"]["y"]
    top = MASTS["main"]["segs"][-1][1] + 1.7
    nu, nv, fl, fh = 14, 7, 3.2, 1.9
    grid = []
    for i in range(nv + 1):
        v = i / nv
        row = []
        for j in range(nu + 1):
            u = j / nu
            x = 0.28 * u * math.sin(2 * math.pi * (1.4 * u) - v * 0.8)
            y = yM + 0.08 + u * fl
            z = top - v * fh - 0.35 * u * u
            row.append(mb.vert((x, y, z)))
        grid.append(row)
    for i in range(nv):
        for j in range(nu):
            idx = [grid[i][j], grid[i][j + 1], grid[i + 1][j + 1], grid[i + 1][j]]
            uv = [(j / nu, 1 - i / nv), ((j + 1) / nu, 1 - i / nv), ((j + 1) / nu, 1 - (i + 1) / nv),
                  (j / nu, 1 - (i + 1) / nv)]
            mb.face(idx, "Flag", uv, (1, 0, 0))
    return mb.build("Galleon_Flag", sharp_deg=80)


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------
def main():
    global ROOT_OBJ
    build_materials()
    ROOT_OBJ = bpy.data.objects.new("Galleon", None)
    bpy.context.collection.objects.link(ROOT_OBJ)

    build_hull()
    build_decks()
    build_longboat()
    build_guns()
    build_stern()
    build_bow()
    build_rig()
    build_flag()

    tris = 0
    for o in SHIP_OBJECTS:
        o.data.calc_loop_triangles()
        n = len(o.data.loop_triangles)
        tris += n
        print("  %-24s %7d tris" % (o.name, n))
    print("TOTAL TRIANGLES:", tris)
    mn = Vector((1e9, 1e9, 1e9)); mx = -mn
    for o in SHIP_OBJECTS:
        for v in o.data.vertices:
            mn = Vector(map(min, mn, v.co)); mx = Vector(map(max, mx, v.co))
    print("BOUNDS (Blender, Z-up) min", tuple(round(c, 2) for c in mn), "max", tuple(round(c, 2) for c in mx))

    # export
    bpy.ops.object.select_all(action="DESELECT")
    ROOT_OBJ.select_set(True)
    for o in SHIP_OBJECTS:
        o.select_set(True)
    bpy.context.view_layer.objects.active = ROOT_OBJ
    os.makedirs(os.path.dirname(OUT_GLB), exist_ok=True)
    kw = dict(filepath=OUT_GLB, export_format="GLB", use_selection=True, export_yup=True,
              export_apply=True, export_materials="EXPORT", export_cameras=False, export_lights=False,
              export_image_format="JPEG", export_jpeg_quality=88)
    try:
        bpy.ops.export_scene.gltf(**kw)
    except TypeError:
        kw.pop("export_jpeg_quality", None)
        bpy.ops.export_scene.gltf(**kw)
    print("EXPORTED", OUT_GLB, os.path.getsize(OUT_GLB) // 1024, "KB")

    if not NO_RENDER:
        render()


def look_at(obj, target):
    d = Vector(target) - obj.location
    obj.rotation_euler = d.to_track_quat("-Z", "Y").to_euler()


def render():
    sc = bpy.context.scene
    for eng in ("BLENDER_EEVEE_NEXT", "BLENDER_EEVEE"):
        try:
            sc.render.engine = eng
            break
        except TypeError:
            continue
    sc.render.resolution_x, sc.render.resolution_y = 1280, 720
    sc.render.resolution_percentage = 100
    try:
        sc.eevee.taa_render_samples = 64
    except Exception:
        pass
    try:
        sc.view_settings.view_transform = "AgX"
        sc.view_settings.look = "AgX - Medium High Contrast"
    except Exception:
        pass
    w = bpy.data.worlds.new("SkyWorld")
    sc.world = w
    w.use_nodes = True
    nt = w.node_tree
    bg = nt.nodes["Background"]
    sky = nt.nodes.new("ShaderNodeTexSky")
    try:
        sky.sky_type = "NISHITA"
        sky.sun_disc = False
        sky.sun_elevation = math.radians(28)
        sky.sun_rotation = math.radians(140)
        bg.inputs["Strength"].default_value = 0.22
    except Exception:
        bg.inputs["Strength"].default_value = 1.0
    nt.links.new(sky.outputs["Color"], bg.inputs["Color"])

    sun = bpy.data.lights.new("Sun", "SUN")
    sun.energy = 4.5
    sun.angle = math.radians(1.5)
    so = bpy.data.objects.new("Sun", sun)
    sc.collection.objects.link(so)
    so.rotation_euler = Vector((0.55, -0.35, -0.75)).to_track_quat("-Z", "Y").to_euler()

    # sea plane (preview only, not exported)
    me = bpy.data.meshes.new("Sea")
    s = 600
    me.from_pydata([(-s, -s, 0), (s, -s, 0), (s, s, 0), (-s, s, 0)], [], [(0, 1, 2, 3)])
    sea = bpy.data.objects.new("Sea", me)
    sc.collection.objects.link(sea)
    wm = make_mat("SeaPreview", color=(0.02, 0.07, 0.085), rough=0.12)
    me.materials.append(wm)

    cam = bpy.data.cameras.new("Cam")
    cam.lens = 30
    cam.clip_end = 2000
    co = bpy.data.objects.new("Cam", cam)
    sc.collection.objects.link(co)
    sc.camera = co

    views = {"preview": ((-50.0, 40.0, 13.0), (0.0, 1.5, 12.0), 30)}
    if EXTRA_DIR:
        views.update({
            "side": ((-75.0, 2.0, 11.0), (0.0, 2.0, 11.0), 32),
            "stern": ((-30.0, -45.0, 12.0), (0.0, -8.0, 8.0), 35),
            "bowclose": ((-22.0, 26.0, 6.0), (0.0, 12.0, 5.0), 35),
            "hullclose": ((-24.0, -2.0, 3.0), (0.0, -2.0, 3.0), 30),
        })
    for name, (pos, tgt, lens) in views.items():
        co.location = Vector(pos)
        look_at(co, tgt)
        cam.lens = lens
        if name == "preview":
            sc.render.filepath = OUT_PNG
        else:
            os.makedirs(EXTRA_DIR, exist_ok=True)
            sc.render.filepath = os.path.join(EXTRA_DIR, "galleon_%s.png" % name)
        bpy.ops.render.render(write_still=True)
        print("RENDERED", sc.render.filepath)


main()

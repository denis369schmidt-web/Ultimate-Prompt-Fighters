"""Build Pro High-Detail Charizard (Glurak) matching the uploaded reference image.
Features:
- Stylized articulated dragon toy/vinyl aesthetic
- Warm vibrant orange body with smooth satin finish
- Cream/light-yellow chest, underbelly, throat and under-tail plates
- Dual swept-back horns on head, sharp snout with nostrils
- Articulated open mouth with sharp white conical teeth and tongue
- Fierce red reptilian eyes with brow ridge
- Triangular dorsal spines down the back and tail
- Massive articulated wings with orange structural struts, top thumb claw, and rich crimson red scalloped membranes
- 3-clawed hands and 3-clawed feet with white enamel talons
- Segmented 'S'-curving tail with spade tip and roaring fiery flame
- Rigged to SK_Dragon 18-bone armature with full combat animations
- Exports to godot/assets/models/charizard.glb and art/characters/charizard/PFU_Charizard.blend
"""
import bpy, bmesh, math, sys, os
from pathlib import Path
from mathutils import Vector, Euler

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
DRAGON_GLB = ROOT / "godot/assets/models/dragon.glb"
MODELS_DIR = ROOT / "godot/assets/models"
ART_DIR = ROOT / "art/characters/charizard"

MODELS_DIR.mkdir(parents=True, exist_ok=True)
ART_DIR.mkdir(parents=True, exist_ok=True)

def make_mat(name, col, rough=0.35, metal=0.0, emit=None, emit_str=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nodes = m.node_tree.nodes
    links = m.node_tree.links
    nodes.clear()
    out = nodes.new("ShaderNodeOutputMaterial"); out.location = (400, 0)
    bsdf = nodes.new("ShaderNodeBsdfPrincipled"); bsdf.location = (0, 0)
    links.new(bsdf.outputs["BSDF"], out.inputs["Surface"])
    bsdf.inputs["Base Color"].default_value = (*col, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metal
    if emit and emit_str > 0:
        if "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = (*emit, 1.0)
            bsdf.inputs["Emission Strength"].default_value = emit_str
        elif "Emission" in bsdf.inputs:
            bsdf.inputs["Emission"].default_value = (*emit, 1.0)
    return m

def build_charizard():
    print("=== STARTING PRO CHARIZARD (GLURAK) 3D BUILD ===")
    bpy.ops.wm.read_factory_settings(use_empty=True)

    # 1. Load SK_Dragon Armature and Actions
    bpy.ops.import_scene.gltf(filepath=str(DRAGON_GLB))
    armature = None
    for obj in bpy.data.objects:
        if obj.type == "ARMATURE":
            armature = obj
            break
    assert armature is not None, "Dragon Armature must be present"

    # Remove old dragon meshes
    for m in [o for o in bpy.data.objects if o.type == "MESH"]:
        bpy.data.objects.remove(m, do_unlink=True)

    # 2. Materials
    M_ORANGE = make_mat("M_CharizardOrange", (0.94, 0.48, 0.14), rough=0.38)
    M_CREAM = make_mat("M_CharizardCream", (0.96, 0.88, 0.58), rough=0.45)
    M_WING_RED = make_mat("M_CharizardWingRed", (0.70, 0.16, 0.14), rough=0.48)
    M_WING_STRUT = make_mat("M_CharizardWingStrut", (0.92, 0.44, 0.12), rough=0.36)
    M_CLAW = make_mat("M_CharizardClaws", (0.94, 0.94, 0.90), rough=0.20, metal=0.08)
    M_EYE_RED = make_mat("M_CharizardEye", (0.90, 0.10, 0.12), rough=0.15, emit=(1.0, 0.12, 0.12), emit_str=2.5)
    M_PUPIL = make_mat("M_CharizardPupil", (0.05, 0.05, 0.07), rough=0.2)
    M_MOUTH = make_mat("M_CharizardMouth", (0.28, 0.08, 0.10), rough=0.6)
    M_TONGUE = make_mat("M_CharizardTongue", (0.85, 0.30, 0.40), rough=0.4)
    M_FLAME_OUTER = make_mat("M_CharizardFlameOuter", (1.0, 0.45, 0.05), rough=0.1, emit=(1.0, 0.50, 0.05), emit_str=6.0)
    M_FLAME_CORE = make_mat("M_CharizardFlameCore", (1.0, 0.90, 0.30), rough=0.1, emit=(1.0, 0.95, 0.35), emit_str=12.0)

    def link_and_parent(obj, bone_name, mat):
        if obj.name not in bpy.context.scene.collection.objects:
            bpy.context.scene.collection.objects.link(obj)
        if obj.data.materials:
            obj.data.materials[0] = mat
        else:
            obj.data.materials.append(mat)
        obj.parent = armature
        mod = obj.modifiers.new("Armature", "ARMATURE")
        mod.object = armature
        vg = obj.vertex_groups.new(name=bone_name)
        all_indices = list(range(len(obj.data.vertices)))
        if all_indices:
            vg.add(all_indices, 1.0, 'REPLACE')
        bpy.context.view_layer.objects.active = obj
        obj.select_set(True)
        bpy.ops.object.shade_smooth()
        obj.select_set(False)
        return obj

    # -------------------------------------------------------------------------
    # HEAD & SNOUT & HORNS & TEETH (Bone: 'head', Z ~ 175 - 188)
    # -------------------------------------------------------------------------
    # Main skull
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=8.5, location=(0, -2.0, 182.0))
    skull = bpy.context.active_object
    skull.name = "Charizard_Head"
    skull.scale = (0.95, 1.25, 0.90)
    link_and_parent(skull, "head", M_ORANGE)

    # Upper snout
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -12.5, 180.5))
    snout = bpy.context.active_object
    snout.name = "Charizard_Snout"
    snout.scale = (8.5, 12.0, 6.2)
    link_and_parent(snout, "head", M_ORANGE)

    # Nostrils
    for sx in [-1.8, 1.8]:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=8, ring_count=6, radius=0.75, location=(sx, -18.2, 182.8))
        nostril = bpy.context.active_object
        nostril.scale = (0.7, 0.9, 0.6)
        link_and_parent(nostril, "head", M_MOUTH)

    # Dual Horns (swept back and outwards)
    for sx, side in [(-1.0, "R"), (1.0, "L")]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=2.2, depth=16.0, location=(sx * 4.6, 7.5, 191.0))
        horn = bpy.context.active_object
        horn.name = f"Charizard_Horn_{side}"
        horn.rotation_euler = (math.radians(-42), math.radians(sx * 18), 0)
        horn.scale = (1.0, 0.9, 1.0)
        link_and_parent(horn, "head", M_ORANGE)

        # Horn rounded tip
        bpy.ops.mesh.primitive_uv_sphere_add(segments=10, ring_count=8, radius=1.7, location=(sx * 6.5, 13.5, 196.5))
        htip = bpy.context.active_object
        link_and_parent(htip, "head", M_ORANGE)

    # Lower Jaw (articulated open)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -11.0, 175.0))
    jaw = bpy.context.active_object
    jaw.name = "Charizard_Jaw"
    jaw.scale = (7.8, 11.5, 3.8)
    jaw.rotation_euler = (math.radians(14), 0, 0)
    link_and_parent(jaw, "head", M_ORANGE)

    # Cream Chin / Throat underside
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=4.8, location=(0, -7.5, 174.2))
    throat_crest = bpy.context.active_object
    throat_crest.scale = (0.9, 1.3, 0.7)
    link_and_parent(throat_crest, "head", M_CREAM)

    # Sharp Teeth (Upper & Lower)
    teeth_locs_upper = [
        (-3.2, -16.5, 178.0), (3.2, -16.5, 178.0),
        (-3.4, -13.0, 178.2), (3.4, -13.0, 178.2),
        (-3.2, -9.5, 178.5), (3.2, -9.5, 178.5)
    ]
    for i, tloc in enumerate(teeth_locs_upper):
        bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.75, radius2=0.0, depth=2.0, location=tloc)
        tooth = bpy.context.active_object
        tooth.name = f"Charizard_Tooth_Upper_{i}"
        tooth.rotation_euler = (math.radians(180), 0, 0)
        link_and_parent(tooth, "head", M_CLAW)

    teeth_locs_lower = [
        (-2.8, -15.5, 176.5), (2.8, -15.5, 176.5),
        (-2.9, -12.0, 176.8), (2.9, -12.0, 176.8)
    ]
    for i, tloc in enumerate(teeth_locs_lower):
        bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=0.70, radius2=0.0, depth=1.8, location=tloc)
        tooth = bpy.context.active_object
        tooth.name = f"Charizard_Tooth_Lower_{i}"
        link_and_parent(tooth, "head", M_CLAW)

    # Tongue & Inner Mouth
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -10.0, 176.2))
    tongue = bpy.context.active_object
    tongue.name = "Charizard_Tongue"
    tongue.scale = (4.0, 7.5, 1.2)
    tongue.rotation_euler = (math.radians(10), 0, 0)
    link_and_parent(tongue, "head", M_TONGUE)

    # Fierce Reptilian Eyes
    for sx, side in [(-1.0, "R"), (1.0, "L")]:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=1.8, location=(sx * 4.6, -7.5, 184.2))
        eye = bpy.context.active_object
        eye.name = f"Charizard_Eye_{side}"
        eye.scale = (0.55, 1.25, 0.95)
        eye.rotation_euler = (math.radians(12), 0, math.radians(-sx * 15))
        link_and_parent(eye, "head", M_EYE_RED)

        # Black Pupil slit
        bpy.ops.mesh.primitive_cylinder_add(vertices=6, radius=0.45, depth=1.2, location=(sx * 4.95, -7.5, 184.2))
        pupil = bpy.context.active_object
        pupil.name = f"Charizard_Pupil_{side}"
        pupil.scale = (0.5, 0.4, 1.6)
        pupil.rotation_euler = (math.radians(12), 0, math.radians(-sx * 15))
        link_and_parent(pupil, "head", M_PUPIL)

        # Brow ridge
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(sx * 4.8, -7.0, 186.2))
        brow = bpy.context.active_object
        brow.name = f"Charizard_Brow_{side}"
        brow.scale = (1.5, 4.0, 1.4)
        brow.rotation_euler = (math.radians(10), 0, math.radians(-sx * 20))
        link_and_parent(brow, "head", M_ORANGE)

    # -------------------------------------------------------------------------
    # NECK (Bone: 'neck', Z ~ 162 - 175)
    # -------------------------------------------------------------------------
    bpy.ops.mesh.primitive_cylinder_add(vertices=14, radius=6.5, depth=14.0, location=(0, -2.5, 168.0))
    neck = bpy.context.active_object
    neck.name = "Charizard_Neck"
    neck.scale = (0.95, 1.15, 1.0)
    neck.rotation_euler = (math.radians(18), 0, 0)
    link_and_parent(neck, "neck", M_ORANGE)

    # Neck Front Cream Plate
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=6.7, depth=13.0, location=(0, -6.8, 167.5))
    neck_cream = bpy.context.active_object
    neck_cream.name = "Charizard_Neck_Cream"
    neck_cream.scale = (0.68, 0.50, 1.0)
    neck_cream.rotation_euler = (math.radians(18), 0, 0)
    link_and_parent(neck_cream, "neck", M_CREAM)

    # -------------------------------------------------------------------------
    # TORSO & CREAM UNDERBELLY (Bones: 'spine_02', 'spine_01', 'pelvis')
    # -------------------------------------------------------------------------
    # Upper Chest & Back (spine_02)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=18, ring_count=14, radius=16.0, location=(0, 2.0, 148.0))
    chest = bpy.context.active_object
    chest.name = "Charizard_Chest"
    chest.scale = (1.05, 1.15, 1.0)
    link_and_parent(chest, "spine_02", M_ORANGE)

    # Cream Upper Belly
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=15.2, location=(0, -8.0, 146.0))
    chest_cream = bpy.context.active_object
    chest_cream.name = "Charizard_Chest_Belly"
    chest_cream.scale = (0.85, 0.65, 1.05)
    link_and_parent(chest_cream, "spine_02", M_CREAM)

    # Lower Torso & Abdomen (spine_01)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=18, ring_count=14, radius=18.5, location=(0, 3.5, 124.0))
    belly = bpy.context.active_object
    belly.name = "Charizard_Torso_Lower"
    belly.scale = (1.12, 1.25, 1.0)
    link_and_parent(belly, "spine_01", M_ORANGE)

    # Cream Lower Underbelly
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=18.0, location=(0, -8.5, 122.0))
    belly_cream = bpy.context.active_object
    belly_cream.name = "Charizard_Underbelly"
    belly_cream.scale = (0.88, 0.68, 1.08)
    link_and_parent(belly_cream, "spine_01", M_CREAM)

    # Pelvis
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=12, radius=17.0, location=(0, 4.0, 100.0))
    pelvis_mesh = bpy.context.active_object
    pelvis_mesh.name = "Charizard_Pelvis"
    pelvis_mesh.scale = (1.10, 1.18, 0.95)
    link_and_parent(pelvis_mesh, "pelvis", M_ORANGE)

    # Triangular Dorsal Spines on back
    dorsal_spines = [
        ("spine_02", (0, 14.5, 156.0), 3.5, 5.5),
        ("spine_02", (0, 15.5, 146.0), 4.2, 6.2),
        ("spine_01", (0, 17.5, 134.0), 4.5, 6.5),
        ("spine_01", (0, 18.0, 122.0), 4.2, 6.0),
        ("pelvis",   (0, 17.0, 108.0), 3.8, 5.5)
    ]
    for i, (bname, loc, r, h) in enumerate(dorsal_spines):
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=r, radius2=0.0, depth=h, location=loc)
        dsp = bpy.context.active_object
        dsp.name = f"Charizard_DorsalSpine_{i}"
        dsp.rotation_euler = (math.radians(-50), 0, 0)
        dsp.scale = (0.45, 1.1, 1.0)
        link_and_parent(dsp, bname, M_ORANGE)

    # -------------------------------------------------------------------------
    # WINGS (Attached to 'spine_02' / Upper Back)
    # Huge articulated wings with structural struts, top thumb claw & crimson membranes
    # -------------------------------------------------------------------------
    for sx, side in [(-1.0, "R"), (1.0, "L")]:
        # Wing Shoulder Joint Ball
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=3.8, location=(sx * 10.0, 10.0, 154.0))
        wj = bpy.context.active_object
        wj.name = f"Charizard_Wing_Joint_{side}"
        link_and_parent(wj, "spine_02", M_ORANGE)

        # Main Wing Bone (Shoulder to Top Elbow)
        bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=2.6, depth=26.0, location=(sx * 22.0, 8.0, 168.0))
        wb1 = bpy.context.active_object
        wb1.name = f"Charizard_Wing_Bone1_{side}"
        wb1.rotation_euler = (math.radians(15), math.radians(sx * -42), math.radians(sx * 25))
        link_and_parent(wb1, "spine_02", M_WING_STRUT)

        # Wing Elbow Ball Joint
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=3.2, location=(sx * 33.0, 6.5, 180.0))
        we = bpy.context.active_object
        we.name = f"Charizard_Wing_Elbow_{side}"
        link_and_parent(we, "spine_02", M_ORANGE)

        # Protruding Wing Thumb Claw (Iconic Charizard feature!)
        bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=1.4, radius2=0.0, depth=4.5, location=(sx * 33.5, 4.5, 184.0))
        wt = bpy.context.active_object
        wt.name = f"Charizard_Wing_ThumbClaw_{side}"
        wt.rotation_euler = (math.radians(-25), math.radians(sx * 15), 0)
        link_and_parent(wt, "spine_02", M_ORANGE)

        # Outer Leading Wing Spar
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=2.2, depth=32.0, location=(sx * 48.0, 3.5, 178.0))
        wb2 = bpy.context.active_object
        wb2.name = f"Charizard_Wing_Bone2_{side}"
        wb2.rotation_euler = (math.radians(10), math.radians(sx * 18), math.radians(sx * -8))
        link_and_parent(wb2, "spine_02", M_WING_STRUT)

        # Three Radiating Finger Struts supporting the membrane
        finger_data = [
            ((sx * 38.0, 4.0, 160.0), (math.radians(12), math.radians(sx * -10), math.radians(sx * 55)), 28.0),
            ((sx * 50.0, 2.5, 155.0), (math.radians(10), math.radians(sx * 5), math.radians(sx * 40)), 30.0),
            ((sx * 62.0, 1.0, 158.0), (math.radians(8), math.radians(sx * 22), math.radians(sx * 22)), 26.0)
        ]
        for f_idx, (floc, frot, flen) in enumerate(finger_data):
            bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.6, depth=flen, location=floc)
            fstrut = bpy.context.active_object
            fstrut.name = f"Charizard_Wing_Strut_{side}_{f_idx}"
            fstrut.rotation_euler = frot
            link_and_parent(fstrut, "spine_02", M_WING_STRUT)

        # Rich Crimson Wing Membrane with Scalloped Profile
        bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=22.0, depth=1.2, location=(sx * 48.0, 2.8, 158.0))
        wmem = bpy.context.active_object
        wmem.name = f"Charizard_Wing_Membrane_{side}"
        wmem.scale = (1.15, 0.45, 0.95)
        wmem.rotation_euler = (math.radians(12), math.radians(sx * 15), math.radians(sx * -12))
        link_and_parent(wmem, "spine_02", M_WING_RED)

    # -------------------------------------------------------------------------
    # ARMS & 3-CLAWED HANDS (upperarm_l/r, lowerarm_l/r, hand_l/r)
    # -------------------------------------------------------------------------
    for sx, side, u_bone, l_bone, h_bone in [
        (1.0, "L", "upperarm_l", "lowerarm_l", "hand_l"),
        (-1.0, "R", "upperarm_r", "lowerarm_r", "hand_r")
    ]:
        # Shoulder Ball Joint
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=4.8, location=(sx * 16.0, -2.0, 152.0))
        sh_joint = bpy.context.active_object
        sh_joint.name = f"Charizard_Shoulder_Joint_{side}"
        link_and_parent(sh_joint, u_bone, M_ORANGE)

        # Upper Arm
        bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=3.8, depth=18.0, location=(sx * 28.0, -2.5, 145.0))
        uarm = bpy.context.active_object
        uarm.name = f"Charizard_UpperArm_{side}"
        uarm.rotation_euler = (0, math.radians(sx * -55), 0)
        link_and_parent(uarm, u_bone, M_ORANGE)

        # Elbow Joint
        bpy.ops.mesh.primitive_uv_sphere_add(segments=10, ring_count=8, radius=3.4, location=(sx * 42.0, -2.0, 138.0))
        elbow = bpy.context.active_object
        elbow.name = f"Charizard_Elbow_{side}"
        link_and_parent(elbow, l_bone, M_ORANGE)

        # Forearm
        bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=3.4, depth=17.0, location=(sx * 55.0, -2.5, 126.0))
        farm = bpy.context.active_object
        farm.name = f"Charizard_ForeArm_{side}"
        farm.rotation_euler = (0, math.radians(sx * -40), 0)
        link_and_parent(farm, l_bone, M_ORANGE)

        # Wrist Joint & Hand Palm
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=3.8, location=(sx * 70.0, -3.0, 114.0))
        hand = bpy.context.active_object
        hand.name = f"Charizard_Hand_{side}"
        hand.scale = (1.0, 1.25, 0.75)
        link_and_parent(hand, h_bone, M_ORANGE)

        # 3 Articulated Fingers with White Claws
        finger_angles = [-22, 0, 22]
        for f_idx, ang in enumerate(finger_angles):
            # Finger bone
            fy = -3.0 + (f_idx - 1) * 2.2
            fx = sx * (74.0 + abs(ang) * 0.08)
            fz = 111.0 - abs(ang) * 0.08
            bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.1, depth=4.5, location=(fx, fy, fz))
            fmesh = bpy.context.active_object
            fmesh.name = f"Charizard_Finger_{side}_{f_idx}"
            fmesh.rotation_euler = (0, math.radians(sx * -65), math.radians(ang))
            link_and_parent(fmesh, h_bone, M_ORANGE)

            # Curved White Claw
            cx = sx * (77.2 + abs(ang) * 0.08)
            bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=1.0, radius2=0.0, depth=3.5, location=(cx, fy, fz - 1.2))
            claw = bpy.context.active_object
            claw.name = f"Charizard_Claw_Hand_{side}_{f_idx}"
            claw.rotation_euler = (0, math.radians(sx * -80), math.radians(ang))
            link_and_parent(claw, h_bone, M_CLAW)

    # -------------------------------------------------------------------------
    # LEGS & FEET (thigh_l/r, calf_l/r, foot_l/r)
    # Thick articulated dragon legs, 3 large white foot claws + 1 heel claw
    # -------------------------------------------------------------------------
    for sx, side, t_bone, c_bone, f_bone in [
        (1.0, "L", "thigh_l", "calf_l", "foot_l"),
        (-1.0, "R", "thigh_r", "calf_r", "foot_r")
    ]:
        # Hip Ball Joint
        bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=10, radius=8.2, location=(sx * 22.0, 2.0, 95.0))
        hip = bpy.context.active_object
        hip.name = f"Charizard_Hip_Joint_{side}"
        link_and_parent(hip, t_bone, M_ORANGE)

        # Muscular Thigh
        bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=7.5, depth=26.0, location=(sx * 23.0, 1.0, 75.0))
        thigh = bpy.context.active_object
        thigh.name = f"Charizard_Thigh_{side}"
        thigh.scale = (1.05, 1.25, 1.0)
        link_and_parent(thigh, t_bone, M_ORANGE)

        # Knee Joint
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=6.5, location=(sx * 23.5, 0.0, 55.0))
        knee = bpy.context.active_object
        knee.name = f"Charizard_Knee_{side}"
        link_and_parent(knee, c_bone, M_ORANGE)

        # Calf / Shin
        bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=6.2, depth=24.0, location=(sx * 23.0, -1.0, 36.0))
        calf = bpy.context.active_object
        calf.name = f"Charizard_Calf_{side}"
        calf.scale = (1.0, 1.15, 1.0)
        link_and_parent(calf, c_bone, M_ORANGE)

        # Ankle / Foot Base
        bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=10, radius=6.8, location=(sx * 22.5, -8.0, 12.0))
        foot_base = bpy.context.active_object
        foot_base.name = f"Charizard_Foot_{side}"
        foot_base.scale = (1.15, 1.65, 0.75)
        link_and_parent(foot_base, f_bone, M_ORANGE)

        # 3 Forward White Foot Claws
        foot_claw_offsets = [(-3.6, -18.0), (0.0, -20.5), (3.6, -18.0)]
        for c_idx, (cox, coy) in enumerate(foot_claw_offsets):
            bpy.ops.mesh.primitive_cone_add(vertices=10, radius1=2.0, radius2=0.0, depth=6.5, location=(sx * 22.5 + cox, coy, 5.0))
            fclaw = bpy.context.active_object
            fclaw.name = f"Charizard_FootClaw_{side}_{c_idx}"
            fclaw.rotation_euler = (math.radians(-75), 0, math.radians(-cox * 3))
            link_and_parent(fclaw, f_bone, M_CLAW)

        # 1 Rear Heel Claw
        bpy.ops.mesh.primitive_cone_add(vertices=8, radius1=1.6, radius2=0.0, depth=4.8, location=(sx * 22.5, 4.5, 6.0))
        heel_claw = bpy.context.active_object
        heel_claw.name = f"Charizard_HeelClaw_{side}"
        heel_claw.rotation_euler = (math.radians(65), 0, 0)
        link_and_parent(heel_claw, f_bone, M_CLAW)

    # -------------------------------------------------------------------------
    # SEGMENTED S-CURVED TAIL & ROARING FLAME (pelvis & root)
    # Long powerful tail curving upward in an 'S' shape with spade flame tip
    # -------------------------------------------------------------------------
    tail_segments = [
        # (offset_x, offset_y, offset_z), radius, length, rot_x
        ((0, 18.0, 88.0), 7.5, 12.0, 42),
        ((0, 26.0, 78.0), 6.8, 12.0, 36),
        ((0, 35.0, 69.0), 6.0, 12.0, 25),
        ((0, 45.0, 63.0), 5.2, 12.0, 10),
        ((0, 56.0, 61.0), 4.5, 12.0, -8),
        ((0, 67.0, 63.0), 3.8, 12.0, -28),
        ((0, 76.0, 70.0), 3.2, 12.0, -45),
        ((0, 83.0, 80.0), 2.6, 12.0, -62),
        ((0, 87.0, 92.0), 2.0, 12.0, -78),
        ((0, 88.0, 105.0), 1.5, 10.0, -90)
    ]

    for t_idx, (tloc, trad, tlen, trot_x) in enumerate(tail_segments):
        # Orange segment core
        bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=trad, depth=tlen, location=tloc)
        tseg = bpy.context.active_object
        tseg.name = f"Charizard_Tail_Seg_{t_idx}"
        tseg.rotation_euler = (math.radians(trot_x), 0, 0)
        link_and_parent(tseg, "pelvis", M_ORANGE)

        # Cream underside on tail
        bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=trad * 0.98, depth=tlen * 0.98, location=(tloc[0], tloc[1] - trad * 0.45, tloc[2]))
        tcream = bpy.context.active_object
        tcream.name = f"Charizard_Tail_Cream_{t_idx}"
        tcream.scale = (0.75, 0.40, 1.0)
        tcream.rotation_euler = (math.radians(trot_x), 0, 0)
        link_and_parent(tcream, "pelvis", M_CREAM)

        # Ridge spine on top of tail (first 6 segments)
        if t_idx < 7:
            bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=trad * 0.35, radius2=0.0, depth=trad * 0.8, location=(tloc[0], tloc[1] + trad * 0.9, tloc[2]))
            tsp = bpy.context.active_object
            tsp.name = f"Charizard_Tail_Spine_{t_idx}"
            tsp.rotation_euler = (math.radians(trot_x - 90), 0, 0)
            link_and_parent(tsp, "pelvis", M_ORANGE)

    # Stylized Spade Tip at Tail End (Matching uploaded image!)
    bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=4.5, radius2=0.0, depth=9.0, location=(0, 88.0, 114.0))
    spade = bpy.context.active_object
    spade.name = "Charizard_Tail_Spade"
    spade.rotation_euler = (math.radians(180), 0, 0)
    spade.scale = (0.35, 1.25, 1.0)
    link_and_parent(spade, "pelvis", M_ORANGE)

    # Roaring Tail Flame (Outer Flame & Inner Glow Core)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=14, ring_count=10, radius=5.8, location=(0, 88.0, 122.0))
    flame_outer = bpy.context.active_object
    flame_outer.name = "Charizard_Tail_Flame_Outer"
    flame_outer.scale = (0.9, 1.1, 1.8)
    flame_outer.rotation_euler = (math.radians(15), 0, 0)
    link_and_parent(flame_outer, "pelvis", M_FLAME_OUTER)

    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=3.2, location=(0, 88.0, 121.0))
    flame_core = bpy.context.active_object
    flame_core.name = "Charizard_Tail_Flame_Core"
    flame_core.scale = (0.8, 0.9, 1.6)
    flame_core.rotation_euler = (math.radians(15), 0, 0)
    link_and_parent(flame_core, "pelvis", M_FLAME_CORE)

    # -------------------------------------------------------------------------
    # SMOOTH SHADING & EXPORT
    # -------------------------------------------------------------------------
    for obj in bpy.data.objects:
        if obj.type == "MESH":
            bpy.context.view_layer.objects.active = obj
            bpy.ops.object.shade_smooth()

    # Save .blend
    blend_path = ART_DIR / "PFU_Charizard.blend"
    bpy.ops.wm.save_as_mainfile(filepath=str(blend_path))
    print(f"SAVED BLEND: {blend_path}")

    # Export .glb
    glb_path = MODELS_DIR / "charizard.glb"
    bpy.ops.export_scene.gltf(
        filepath=str(glb_path),
        export_format="GLB",
        use_selection=False,
        export_apply=False,
        export_yup=True,
        export_animations=True,
        export_nla_strips=True,
        export_skins=True,
        export_morph=True
    )
    print(f"EXPORTED GLB: {glb_path} (size: {glb_path.stat().st_size} bytes)")
    print("=== PRO CHARIZARD (GLURAK) BUILD COMPLETE ===")

if __name__ == "__main__":
    build_charizard()

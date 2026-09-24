"""Generate the modular Broken Moonkeep arena and a gameplay-view preview."""

from __future__ import annotations

import math
import random
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import bpy
from mathutils import Vector

from blender_common import (
    BLEND_ROOT,
    EXPORT_ROOT,
    add_preview_lights,
    beveled_box,
    cylinder_between,
    ensure_output_dirs,
    ico_part,
    material,
    render_preview,
    reset_scene,
)


def aim_at(obj, target):
    obj.rotation_euler = (Vector(target) - obj.location).to_track_quat("-Z", "Y").to_euler()


def build_arena():
    reset_scene()
    ensure_output_dirs()
    random.seed(7117)

    stone = material("M_ArenaStone", (0.12, 0.15, 0.2), metallic=0.05, roughness=0.86)
    stone_dark = material("M_ArenaStoneDark", (0.035, 0.05, 0.085), metallic=0.08, roughness=0.9)
    stone_edge = material("M_ArenaMoonEdge", (0.13, 0.2, 0.32), metallic=0.12, roughness=0.58)
    timber = material("M_ArenaTimber", (0.12, 0.045, 0.018), metallic=0.0, roughness=0.82)
    iron = material("M_ArenaIron", (0.035, 0.04, 0.055), metallic=0.82, roughness=0.48)
    ember = material("M_ArenaEmber", (0.45, 0.025, 0.001), roughness=0.3, emission=(1.0, 0.035, 0.002), emission_strength=3.0)
    moon = material("M_ArenaMoon", (0.3, 0.42, 0.65), roughness=0.65, emission=(0.25, 0.48, 1.0), emission_strength=1.2)

    collection = bpy.context.collection

    # Flat combat lane: modular one-meter slabs, deterministic chips and height variation.
    for x in range(-5, 6):
        for y in range(-1, 3):
            z = -6 + ((x + y) % 3) * 0.6
            slab = beveled_box(
                f"Arena_Floor_{x:+d}_{y:+d}",
                (x * 100, y * 82, z),
                (48, 39, 7),
                stone if (x + y) % 2 else stone_dark,
                bevel=2.5,
                rotation=(0, 0, math.radians(((x * 7 + y * 3) % 5) - 2) * 0.18),
            )
            slab["PFU_Collision"] = "simple_box"

    # Rear ruined wall segments keep the fighting plane readable.
    for x in (-520, -420, -320, 320, 420, 520):
        height = 150 + ((abs(x) // 100) % 3) * 38
        beveled_box(f"RearWall_{x}", (x, 205, height / 2 - 5), (48, 25, height / 2), stone_dark, bevel=5)

    # Four modular columns with base, shaft and broken capital.
    for x in (-470, -255, 255, 470):
        beveled_box(f"ColumnBase_{x}", (x, 160, 18), (42, 42, 18), stone, bevel=4)
        for level in range(4):
            z = 58 + level * 68
            bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=30, depth=64, location=(x, 160, z))
            shaft = bpy.context.object
            shaft.name = f"ColumnShaft_{x}_{level}"
            shaft.data.materials.append(stone if level % 2 else stone_edge)
        cap_z = 326 if abs(x) < 300 else 290
        ico_part(f"BrokenCapital_{x}", (x, 160, cap_z), (48, 45, 28), stone, subdivisions=1)

    # Pointed gothic arch fragments, built from modular angled masonry beams.
    for center_x in (-365, 365):
        cylinder_between(f"ArchLeft_{center_x}", (center_x - 94, 160, 230), (center_x, 160, 360), 18, stone_edge, vertices=8)
        cylinder_between(f"ArchRight_{center_x}", (center_x + 94, 160, 230), (center_x, 160, 360), 18, stone_edge, vertices=8)
        beveled_box(f"ArchSill_{center_x}", (center_x, 168, 218), (105, 18, 13), stone, bevel=3)

    # Improvised timber and iron repairs on the outer ruins.
    for side in (-1, 1):
        x = side * 475
        cylinder_between(f"RepairPost_{side}", (x, 118, 40), (x, 118, 255), 10, timber, vertices=8)
        cylinder_between(f"RepairBrace_{side}", (x - side * 70, 116, 65), (x + side * 45, 116, 230), 9, timber, vertices=8)
        for z in (82, 205):
            beveled_box(f"IronBand_{side}_{z}", (x, 112, z), (18, 5, 6), iron, bevel=1.2)

    # Deterministic rubble piles kept outside the central combat lane.
    for side in (-1, 1):
        for index in range(18):
            x = side * random.uniform(355, 565)
            y = random.uniform(85, 245)
            z = random.uniform(4, 24)
            scale = random.uniform(10, 27)
            rubble = ico_part(f"Rubble_{side}_{index:02d}", (x, y, z), (scale, scale * 0.72, scale * 0.55), stone, subdivisions=1)
            rubble.rotation_euler = (random.random(), random.random(), random.random())

    # Two low-cost braziers with restrained emissive coals and local lights.
    for side in (-1, 1):
        x = side * 360
        beveled_box(f"BrazierBase_{side}", (x, 15, 18), (30, 25, 9), stone_dark, bevel=3)
        bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=23, depth=10, location=(x, 15, 39))
        bowl = bpy.context.object
        bowl.name = f"BrazierBowl_{side}"
        bowl.data.materials.append(iron)
        for index, offset in enumerate((-10, 0, 11)):
            ico_part(f"Ember_{side}_{index}", (x + offset, 15, 49 + abs(offset) * 0.15), (9, 7, 6), ember, subdivisions=1)
        bpy.ops.object.light_add(type="POINT", location=(x, -5, 72))
        fire_light = bpy.context.object
        fire_light.name = f"BrazierLight_{side}"
        fire_light.data.energy = 650
        fire_light.data.color = (1.0, 0.12, 0.015)
        fire_light.data.shadow_soft_size = 65

    # Stylized moon and distant keep silhouettes.
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=125, location=(-120, 520, 470))
    moon_obj = bpy.context.object
    moon_obj.name = "BackdropMoon"
    moon_obj.data.materials.append(moon)
    for x, width, height in ((40, 75, 250), (150, 55, 360), (245, 80, 285)):
        beveled_box(f"DistantKeep_{x}", (x, 430, height / 2 + 40), (width, 25, height / 2), stone_dark, bevel=3)

    # Side-on gameplay camera.
    bpy.ops.object.camera_add(location=(0, -1080, 245))
    camera = bpy.context.object
    camera.name = "PFU_GameplayCamera"
    camera.data.lens = 52
    camera.data.clip_end = 3000
    aim_at(camera, (0, 80, 145))
    bpy.context.scene.camera = camera

    add_preview_lights(150, energy=3000)
    render_preview("arena_model_preview.png")
    bpy.ops.wm.save_as_mainfile(filepath=str(BLEND_ROOT / "PFU_BrokenMoonkeep.blend"))

    bpy.ops.object.select_all(action="SELECT")
    for obj in (camera,):
        obj.select_set(False)
    bpy.ops.export_scene.fbx(
        filepath=str(EXPORT_ROOT / "PFU_BrokenMoonkeep.fbx"),
        use_selection=True,
        object_types={"MESH", "LIGHT"},
        apply_unit_scale=True,
        apply_scale_options="FBX_SCALE_ALL",
        axis_forward="-Z",
        axis_up="Y",
        bake_anim=False,
        path_mode="AUTO",
    )
    print("PFU_ARENA_GENERATED_OK")


if __name__ == "__main__":
    build_arena()

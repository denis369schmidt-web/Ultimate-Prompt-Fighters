"""Validate a loaded .blend file or re-import an exported FBX and print JSON."""

from __future__ import annotations

import json
import sys
from pathlib import Path

import bpy


def cli_args():
    argv = sys.argv
    return argv[argv.index("--") + 1 :] if "--" in argv else []


def clear_scene_and_data():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for action in list(bpy.data.actions):
        bpy.data.actions.remove(action)


def mesh_stats(mesh_objects):
    vertices = sum(len(obj.data.vertices) for obj in mesh_objects)
    triangles = 0
    unweighted = 0
    bad_normals = 0
    for obj in mesh_objects:
        obj.data.calc_loop_triangles()
        triangles += len(obj.data.loop_triangles)
        for vertex in obj.data.vertices:
            if vertex.normal.length < 0.9:
                bad_normals += 1
            if any(mod.type == "ARMATURE" for mod in obj.modifiers) and not vertex.groups:
                unweighted += 1
    return vertices, triangles, unweighted, bad_normals


def collect(label, expected_actions=0):
    meshes = [obj for obj in bpy.context.scene.objects if obj.type == "MESH"]
    armatures = [obj for obj in bpy.context.scene.objects if obj.type == "ARMATURE"]
    vertices, triangles, unweighted, bad_normals = mesh_stats(meshes)
    actions = sorted(action.name for action in bpy.data.actions)
    bones = sum(len(obj.data.bones) for obj in armatures)
    materials = sorted({slot.material.name for obj in meshes for slot in obj.material_slots if slot.material})
    result = {
        "label": label,
        "meshes": len(meshes),
        "vertices": vertices,
        "triangles": triangles,
        "armatures": len(armatures),
        "bones": bones,
        "actions": actions,
        "action_count": len(actions),
        "materials": materials,
        "unweighted_vertices": unweighted,
        "invalid_normals": bad_normals,
        "passes": bool(meshes)
        and bad_normals == 0
        and (not armatures or unweighted == 0)
        and (expected_actions == 0 or len(actions) >= expected_actions),
    }
    print("PFU_VALIDATION_JSON=" + json.dumps(result, sort_keys=True))
    if not result["passes"]:
        raise SystemExit(2)


def main():
    args = cli_args()
    mode = args[0] if args else "source"
    if mode == "source":
        expected = int(args[1]) if len(args) > 1 else 0
        collect(Path(bpy.data.filepath).name or "current", expected)
        return
    if mode == "import":
        if len(args) < 2:
            raise SystemExit("import mode needs an FBX path")
        path = Path(args[1]).resolve()
        expected = int(args[2]) if len(args) > 2 else 0
        clear_scene_and_data()
        bpy.ops.import_scene.fbx(filepath=str(path), automatic_bone_orientation=False)
        collect(path.name, expected)
        return
    raise SystemExit(f"Unknown validation mode: {mode}")


if __name__ == "__main__":
    main()


import json, struct
from pathlib import Path

p = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\models\ninja.glb")
with open(p, "rb") as f:
    magic, version, length = struct.unpack("<4sII", f.read(12))
    chunk_len, chunk_type = struct.unpack("<I4s", f.read(8))
    json_data = json.loads(f.read(chunk_len).decode("utf-8", errors="ignore"))
    nodes = json_data.get("nodes", [])
    skins = json_data.get("skins", [])
    if skins:
        joints = skins[0].get("joints", [])
        joint_names = [nodes[j].get("name", f"node_{j}") for j in joints]
        print(f"Ninja skeleton joints ({len(joints)}): {joint_names[:15]}")

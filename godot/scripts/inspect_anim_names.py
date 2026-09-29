import json, struct
from pathlib import Path

models = [
    r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\models\ninja.glb",
    r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\models\golem.glb",
    r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\models\akaza.glb"
]

for m in models:
    p = Path(m)
    with open(p, "rb") as f:
        magic, version, length = struct.unpack("<4sII", f.read(12))
        chunk_len, chunk_type = struct.unpack("<I4s", f.read(8))
        json_data = json.loads(f.read(chunk_len).decode("utf-8", errors="ignore"))
        anims = [a.get("name", "unnamed") for a in json_data.get("animations", [])]
        print(f"{p.name}: {anims}")

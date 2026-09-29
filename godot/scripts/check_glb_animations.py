import os
from pathlib import Path

models_dir = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate\godot\assets\models")
for glb in models_dir.rglob("*.glb"):
    with open(glb, "rb") as f:
        data = f.read(1024 * 1024) # read first 1MB
        if b"animations" in data:
            print(f"HAS ANIMATIONS: {glb.relative_to(models_dir)}")

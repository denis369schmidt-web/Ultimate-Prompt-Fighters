"""Downloads the Poly Haven assets (CC0) used by the arenas.

Poly Haven (https://polyhaven.com) publishes scanned/hand-made HDRIs, PBR textures and
3D models under CC0 (public domain, free for commercial use, no attribution required).

Per HDRI: 2k .hdr (lighting and reflections) + tonemapped .jpg for the visible sky,
resized to 6144x3072 (sharp on screen, ~12 MB of compressed video memory).
Per texture: 2k diffuse, OpenGL normal and roughness maps.
Per model: glTF with 1k textures.
Output: godot/assets/polyhaven/{hdri,textures,models}/  + manifest.json
Already downloaded files are skipped (md5 checked when available).

Usage: python scripts/fetch_polyhaven_assets.py
"""
import hashlib
import json
import os
import sys
import time
import urllib.request

from PIL import Image

SKY_SIZE = (6144, 3072)

API = "https://api.polyhaven.com/files/%s"
ROOT = os.path.join(os.path.dirname(__file__), "..", "godot", "assets", "polyhaven")
UA = {"User-Agent": "PromptFighterUltimate-asset-fetch/1.0"}

HDRIS = ["rogland_moonlit_night", "rogland_sunset", "colosseum", "small_harbour_sunset",
         "teutonic_castle_moat", "misty_pines", "lago_disola", "shanghai_bund"]

TEXTURES = ["castle_wall_slates", "japanese_stone_wall", "volcanic_rock_tiles", "dark_rock",
            "marble_01", "large_sandstone_blocks", "brown_planks_07", "dark_planks",
            "large_sandstone_blocks_01", "castle_brick_01", "mossy_cobblestone", "mossy_rock",
            "snow_02", "rock_wall_10", "metal_plate", "concrete_panels"]

MODELS = ["rock_face_01", "rock_face_02", "namaqualand_cliff_01", "boulder_01", "rock_moss_set_01",
          "rock_moss_set_02", "moon_rock_03", "rock_07", "dead_tree_trunk_02",
          "quiver_tree_01", "fern_02", "tree_stump_01", "Barrel_01", "wooden_barrels_01",
          "wooden_crate_02", "treasure_chest", "cannon_01", "modular_wooden_pier", "Lantern_01",
          "wooden_lantern_01", "street_lamp_02", "stone_fire_pit", "gothic_statue", "marble_bust_01",
          "horse_statue_01", "large_iron_gate", "kite_shield", "modular_industrial_pipes_01",
          "security_light", "ceramic_vase_02", "brass_diya_lantern", "wine_barrel_01", "lion_head"]


def get_json(url):
    for attempt in range(4):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60) as r:
                return json.loads(r.read().decode("utf-8"))
        except Exception as e:  # network hiccup: retry
            print("  retry", url, e)
            time.sleep(2 + attempt * 2)
    raise RuntimeError("failed: " + url)


def download(url, path, md5=None):
    if os.path.exists(path):
        if md5 is None: return False
        with open(path, "rb") as f:
            if hashlib.md5(f.read()).hexdigest() == md5: return False
    os.makedirs(os.path.dirname(path), exist_ok=True)
    for attempt in range(4):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=180) as r:
                data = r.read()
            with open(path + ".part", "wb") as f:
                f.write(data)
            os.replace(path + ".part", path)
            return True
        except Exception as e:
            print("  retry", url, e)
            time.sleep(2 + attempt * 3)
    raise RuntimeError("failed: " + url)


def main():
    manifest = {"source": "https://polyhaven.com", "license": "CC0 1.0", "hdris": [], "textures": [], "models": []}
    total = 0
    for name in HDRIS:
        files = get_json(API % name)
        hdr = files["hdri"]["2k"]["hdr"]
        if download(hdr["url"], os.path.join(ROOT, "hdri", name + "_2k.hdr"), hdr.get("md5")): total += hdr["size"]
        tm = files["tonemapped"]
        sky = os.path.join(ROOT, "hdri", name + "_sky.jpg")
        if not os.path.exists(sky):
            raw = os.path.join(ROOT, "hdri", name + "_raw.jpg")
            download(tm["url"], raw, tm.get("md5"))
            total += tm["size"]
            Image.MAX_IMAGE_PIXELS = None
            Image.open(raw).convert("RGB").resize(SKY_SIZE, Image.LANCZOS).save(sky, quality=90)
            os.remove(raw)
        manifest["hdris"].append(name)
        print("hdri", name)
    for name in TEXTURES:
        files = get_json(API % name)
        for key, suffix in (("Diffuse", "diff"), ("nor_gl", "nor_gl"), ("Rough", "rough")):
            info = files[key]["2k"]["jpg"]
            if download(info["url"], os.path.join(ROOT, "textures", name, "%s_%s_2k.jpg" % (name, suffix)), info.get("md5")):
                total += info["size"]
        manifest["textures"].append(name)
        print("texture", name)
    for name in MODELS:
        files = get_json(API % name)
        g = files["gltf"]["1k"]["gltf"]
        base = os.path.join(ROOT, "models", name)
        if download(g["url"], os.path.join(base, name + ".gltf"), g.get("md5")): total += g["size"]
        for rel, info in g["include"].items():
            if download(info["url"], os.path.join(base, rel), info.get("md5")): total += info["size"]
        manifest["models"].append(name)
        print("model", name)
    with open(os.path.join(ROOT, "manifest.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)
    print("done, downloaded %.1f MB" % (total / 1048576))


if __name__ == "__main__":
    sys.exit(main())

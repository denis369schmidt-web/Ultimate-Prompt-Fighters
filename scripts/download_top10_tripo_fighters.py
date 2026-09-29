import urllib.request
import json
import ssl
import re
from pathlib import Path
from PIL import Image

ROOT = Path(r"C:\Users\schmidtdenis\Desktop\Ultimate Prompt Fighters\PromptFighterUltimate")
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/128.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Origin': 'https://studio.tripo3d.ai',
    'Referer': 'https://studio.tripo3d.ai/',
}

with open("tripo_explore.html", "r", encoding="utf-8") as f:
    html = f.read()

ids = list(dict.fromkeys(re.findall(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', html)))
print(f"Total Explore IDs: {len(ids)}")

# Filter and download 10 characters
character_keywords = [
    'warrior', 'knight', 'demon', 'dragon', 'golem', 'robot', 'cyborg', 'samurai',
    'ninja', 'creature', 'wizard', 'monster', 'beast', 'paladin', 'gladiator', 'fighter',
    'mech', 'assassin', 'hero', 'valkyrie', 'titan', 'orc', 'ogre', 'elf', 'alien', 'character'
]

downloaded = []

for cid in ids:
    if len(downloaded) >= 10:
        break
    detail_url = f"https://api.tripo3d.ai/v2/studio/project/detail/v3/{cid}"
    try:
        req = urllib.request.Request(detail_url, headers=headers)
        with urllib.request.urlopen(req, context=ctx, timeout=8) as resp:
            data = json.loads(resp.read().decode('utf-8'))
        d = data.get("data", {})
        if not d: continue
        
        category = d.get("category", "").lower()
        biz = d.get("biz_info", {})
        title = biz.get("short_description") or biz.get("description") or d.get("project_name", "")
        img_url = biz.get("display_image") or ""
        
        t_low = (title + " " + category).lower()
        is_char = any(k in t_low for k in character_keywords)
        if not is_char:
            continue
            
        op = d.get("operator", {})
        rig = op.get("rigging", {})
        model_url = rig.get("model_url") or op.get("model_url") or d.get("model_url")
        if not model_url or not img_url:
            continue
            
        clean_name = re.sub(r'[^a-zA-Z0-9]+', '_', title.lower()).strip('_')
        words = [w for w in clean_name.split('_') if len(w) > 2 and w not in ['with', 'and', 'the', 'for', 'model']]
        short_id = "_".join(words[:2]) if len(words) >= 2 else words[0] if words else f"tripo_{cid[:6]}"
        short_id = f"tripo_{short_id}"
        
        # Avoid duplicate IDs
        if any(x["id"] == short_id for x in downloaded):
            short_id = f"{short_id}_{len(downloaded)+1}"

        print(f"\n[{len(downloaded)+1}/10] FOUND CHARACTER: {short_id} - '{title[:60]}'")
        
        char_dir = ROOT / f"art/characters/{short_id}"
        char_dir.mkdir(parents=True, exist_ok=True)
        
        # Download 3D Model
        ext = ".fbx" if ".fbx" in model_url else ".glb"
        model_path = char_dir / f"{short_id}{ext}"
        print(f"  Downloading model {model_path.name}...")
        m_req = urllib.request.Request(model_url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(m_req, context=ctx, timeout=35) as m_resp:
            m_bytes = m_resp.read()
            with open(model_path, "wb") as mf:
                mf.write(m_bytes)
        print(f"  Model saved ({len(m_bytes)} bytes)")
        
        # Download Preview Image
        webp_path = char_dir / "preview.webp"
        i_req = urllib.request.Request(img_url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(i_req, context=ctx, timeout=20) as i_resp:
            i_bytes = i_resp.read()
            with open(webp_path, "wb") as wf:
                wf.write(i_bytes)
                
        # Generate Portraits (512 & 256)
        p_img = Image.open(webp_path).convert("RGBA")
        w, h = p_img.size
        min_d = min(w, h)
        p_crop = p_img.crop(((w - min_d)//2, (h - min_d)//2, (w - min_d)//2 + min_d, (h - min_d)//2 + min_d))
        p_512 = p_crop.resize((512, 512), Image.Resampling.LANCZOS)
        p_256 = p_crop.resize((256, 256), Image.Resampling.LANCZOS)
        
        p512_path = ROOT / f"godot/assets/textures/ui/portrait_{short_id}.png"
        p256_path = ROOT / f"godot/assets/textures/characters/thumbs/thumb_{short_id}.png"
        p_512.save(p512_path)
        p_256.save(p256_path)
        print(f"  Portraits created: {p512_path.name}")
        
        downloaded.append({
            "id": short_id,
            "cid": cid,
            "name": title[:30].strip().title(),
            "description": title,
            "ext": ext,
            "local_path": str(model_path),
            "file": model_path.name
        })
    except Exception as err:
        print(f"  Error on {cid}: {err}")

with open(ROOT / "tripo_top10_fighters.json", "w", encoding="utf-8") as out_f:
    json.dump(downloaded, out_f, indent=2)

print(f"\nALL DONE! Downloaded {len(downloaded)} characters.")

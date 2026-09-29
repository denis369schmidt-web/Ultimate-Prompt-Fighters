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
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Origin': 'https://studio.tripo3d.ai',
    'Referer': 'https://studio.tripo3d.ai/',
}

# 1. Fetch related models for the original golem
related_url = 'https://api.tripo3d.ai/v2/studio/project/related_models/5207d449-6452-49aa-99cb-1ed13d2b40cd'
req = urllib.request.Request(related_url, headers=headers)
candidates = []
try:
    with urllib.request.urlopen(req, context=ctx, timeout=10) as resp:
        res = json.loads(resp.read().decode('utf-8'))
        print("Related models response code:", res.get("code"))
        items = res.get("data", {}).get("list", []) or res.get("data", [])
        if isinstance(items, list):
            for it in items:
                m_id = it.get("id") or it.get("project_id")
                if m_id:
                    candidates.append(m_id)
        print("Found related candidates:", len(candidates))
except Exception as e:
    print("Related models error:", e)

# 2. Also harvest IDs found in HTML
with open(ROOT / "tripo_page.html", "r", encoding="utf-8") as f:
    html = f.read()

html_ids = re.findall(r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}', html)
for hid in html_ids:
    if hid != "5207d449-6452-49aa-99cb-1ed13d2b40cd" and hid not in candidates:
        candidates.append(hid)

print(f"Total candidate IDs: {len(candidates)}")

# 3. For each candidate, fetch detail and check if it has a valid model
downloaded_fighters = []

for cid in candidates:
    if len(downloaded_fighters) >= 10:
        break
    detail_url = f"https://api.tripo3d.ai/v2/studio/project/detail/v3/{cid}"
    try:
        req = urllib.request.Request(detail_url, headers=headers)
        with urllib.request.urlopen(req, context=ctx, timeout=8) as resp:
            data = json.loads(resp.read().decode('utf-8'))
        d = data.get("data", {})
        if not d: continue

        biz = d.get("biz_info", {})
        title = biz.get("short_description") or biz.get("description") or d.get("project_name", "")
        img_url = biz.get("display_image") or ""
        
        # Get model url from operator or rigging
        op = d.get("operator", {})
        rig = op.get("rigging", {})
        model_url = rig.get("model_url") or op.get("model_url") or d.get("model_url")
        
        if not model_url or not img_url:
            continue
        
        # Determine a clean slug / id
        clean_name = re.sub(r'[^a-zA-Z0-9]+', '_', title.lower()).strip('_')
        parts = clean_name.split('_')
        short_id = "_".join(parts[:3]) if len(parts) >= 3 else clean_name
        if not short_id: short_id = f"tripo_{cid[:8]}"
        
        print(f"\n[{len(downloaded_fighters)+1}/10] Processing {short_id} ({title[:50]}...)")
        
        char_dir = ROOT / f"art/characters/{short_id}"
        char_dir.mkdir(parents=True, exist_ok=True)
        
        # Download model
        ext = ".fbx" if ".fbx" in model_url else ".glb"
        model_path = char_dir / f"{short_id}{ext}"
        print(f"  Downloading model to {model_path.name}...")
        m_req = urllib.request.Request(model_url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(m_req, context=ctx, timeout=35) as m_resp:
            m_bytes = m_resp.read()
            with open(model_path, "wb") as mf:
                mf.write(m_bytes)
        print(f"  Saved {len(m_bytes)} bytes")
        
        # Download image
        webp_path = char_dir / "preview.webp"
        i_req = urllib.request.Request(img_url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(i_req, context=ctx, timeout=20) as i_resp:
            i_bytes = i_resp.read()
            with open(webp_path, "wb") as wf:
                wf.write(i_bytes)
                
        # Generate Portraits
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
        print(f"  Generated portraits for {short_id}")
        
        downloaded_fighters.append({
            "id": short_id,
            "cid": cid,
            "title": title,
            "file": model_path.name,
            "ext": ext,
            "path": str(model_path)
        })
    except Exception as err:
        print(f"  Skipping {cid}: {err}")

with open(ROOT / "tripo_10_fighters.json", "w", encoding="utf-8") as out_f:
    json.dump(downloaded_fighters, out_f, indent=2)

print(f"\nSUCCESS! Downloaded {len(downloaded_fighters)} Tripo characters.")

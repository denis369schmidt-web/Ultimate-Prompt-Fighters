import re
import urllib.request
import ssl

with open('tripo_page.html', 'r', encoding='utf-8') as f:
    text = f.read()

# Look for all glb urls in the page
glbs = re.findall(r'https?:\\u002F\\u002F[^\s\"\'<>]+\.glb[^\s\"\'<>]*', text)
if not glbs:
    glbs = re.findall(r'https?://[^\s\"\'<>]+\.glb[^\s\"\'<>]*', text)

clean_glbs = [g.replace('\\u002F', '/') for g in glbs]
print(f"Total GLB URLs found: {len(clean_glbs)}")

# Check if any mentions 5207d449 or pbr_model
target_url = None
for g in clean_glbs:
    print("GLB:", g[:120])
    if 'pbr_model' in g and not target_url:
        target_url = g

# Let's inspect tripo_detail_api.json if it was saved
try:
    with open('tripo_detail_api.json', 'r', encoding='utf-8') as f:
        data = f.read()
    print("tripo_detail_api.json length:", len(data))
    for m in re.findall(r'https?:[^\s\"\'<>]+\.glb[^\s\"\'<>]*', data):
        c = m.replace('\\u002F', '/')
        print("API GLB:", c[:120])
        target_url = c
except Exception as e:
    print("No tripo_detail_api.json:", e)

# Download target GLB
if target_url:
    print("\nDOWNLOADING TARGET GLB:\n", target_url)
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    req = urllib.request.Request(target_url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req, context=ctx, timeout=30) as resp:
        content = resp.read()
        out_path = 'art/characters/golden_golem.glb'
        with open(out_path, 'wb') as out_f:
            out_f.write(content)
        print(f"DOWNLOADED {len(content)} bytes to {out_path}!")
else:
    print("NO GLB URL IDENTIFIED!")

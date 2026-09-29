import urllib.request
import json
import ssl
import re

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
    'Accept': 'application/json, text/plain, */*',
    'Origin': 'https://studio.tripo3d.ai',
    'Referer': 'https://studio.tripo3d.ai/',
}

# 1. Try public API detail endpoint
api_url = 'https://api.tripo3d.ai/v2/studio/project/detail/v3/5207d449-6452-49aa-99cb-1ed13d2b40cd'
try:
    req = urllib.request.Request(api_url, headers=headers)
    with urllib.request.urlopen(req, context=ctx, timeout=10) as resp:
        data = json.loads(resp.read().decode('utf-8'))
        print('API DETAIL SUCCESS!')
        with open('tripo_detail_api.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2)
except Exception as e:
    print('API DETAIL FAILED:', e)

# 2. Check HTML Script #6
with open('tripo_page.html', 'r', encoding='utf-8') as f:
    html = f.read()

scripts = re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL)
for i, s in enumerate(scripts):
    if len(s) > 10000:
        print('Scanning script #%d (len %d)' % (i, len(s)))
        # Search for .glb
        glb_matches = re.findall(r'\"[^\"]*?\.glb[^\"]*?\"', s)
        print('GLB matches in script #%d:' % i, glb_matches)
        
        # Search for output, model_url, pbr_model, etc
        keys = ['output', 'pbr_model', 'base_model', 'download_url', 'model_url', 'files', 'tripo-public']
        for k in keys:
            for match in re.findall(rf'\"{k}\":\s*(\"[^\"]+\")', s):
                print(f'  {k} -> {match}')
            for match in re.findall(rf'\"{k}\":\s*(\{{[^\}}]+\}})', s):
                print(f'  {k} (obj) -> {match[:200]}')

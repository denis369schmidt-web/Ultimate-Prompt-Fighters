import urllib.request
import json
import ssl
import re

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
}

url = 'https://studio.tripo3d.ai/3d-model/5207d449-6452-49aa-99cb-1ed13d2b40cd?invite_code=4G7BB2'
req = urllib.request.Request(url, headers=headers)
with urllib.request.urlopen(req, context=ctx, timeout=12) as resp:
    html = resp.read().decode('utf-8', errors='ignore')

with open('tripo_page.html', 'w', encoding='utf-8') as f:
    f.write(html)

print('Saved tripo_page.html (len %d)' % len(html))

# Look for json data or embedded states
scripts = re.findall(r'<script[^>]*>(.*?)</script>', html, re.DOTALL)
for i, s in enumerate(scripts):
    if '5207d449' in s or 'model' in s.lower() or 'glb' in s.lower():
        print('Script #%d has keywords, len: %d' % (i, len(s)))
        # check if it contains urls
        found_urls = re.findall(r'https?://[^\s\"\'<>]+', s)
        for u in found_urls:
            if any(ext in u.lower() for ext in ['.glb', '.obj', '.fbx', 'model', 'render', 'task', 'download', 'tripo']):
                print('  URL:', u)

# Check all URLs in entire html
all_urls = re.findall(r'https?://[^\s\"\'<>]+', html)
print('\nTotal URLs found in HTML:', len(all_urls))
for u in set(all_urls):
    if any(ext in u.lower() for ext in ['.glb', '.obj', '.fbx', 'output', 'model', 'thumbnail']):
        print('  MATCHING URL:', u)

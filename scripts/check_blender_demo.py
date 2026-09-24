import requests
url = 'https://download.blender.org/demo/asset-bundles/human-base-meshes/human-base-meshes-bundle-v1.4.1.zip'
r = requests.head(url, timeout=10)
print('Status:', r.status_code)
cl = r.headers.get('content-length')
print('Content-Length:', cl, 'bytes (approx', int(cl)/(1024*1024) if cl else 0, 'MB)')

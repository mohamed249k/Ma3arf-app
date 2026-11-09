import re

with open('reference_index.html', 'r', encoding='utf-8') as f:
    html = f.read()

ids = re.findall(r'id=["\']([^"\']+)["\']', html)
print('IDs found:', len(ids), ids)

classes = set(re.findall(r'class=["\']([^"\']+)["\']', html))
print('Class samples:', list(classes)[:30])

with open('reference_style.css', 'r', encoding='utf-8') as f:
    css = f.read()

colors = set(re.findall(r'#(?:[0-9a-fA-F]{3,8})\b', css))
print('Colors in CSS:', sorted(list(colors)))

vars_css = re.findall(r'(--[a-zA-Z0-9-]+):\s*([^;]+);', css)
print('CSS Variables:', vars_css)

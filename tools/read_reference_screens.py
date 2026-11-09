import sys, re
sys.stdout.reconfigure(encoding='utf-8')

with open('reference_index.html', 'r', encoding='utf-8') as f:
    html = f.read()

# Let's inspect the entire structure of reference_index.html
lines = html.splitlines()
print(f'Total lines: {len(lines)}')

for i, line in enumerate(lines[:120], 1):
    print(f'{i:3}: {line}')

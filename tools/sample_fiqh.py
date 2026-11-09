import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

with open('lib/data/questions_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

blocks = re.findall(r'Question\s*\((.*?)\n\s*\)', text, re.DOTALL)
fiqh_samples = []
ibadat_samples = []

for b in blocks[1:]:
    m_cat = re.search(r'category:\s*[\'"](.*?)[\'"]\s*,', b)
    m_q = re.search(r'question:\s*[\'"](.*?)[\'"]\s*,', b)
    if m_cat and m_q:
        cat = m_cat.group(1)
        q = m_q.group(1)
        if cat == 'الفقه' and len(fiqh_samples) < 5:
            fiqh_samples.append(q)
        elif cat == 'العبادات' and len(ibadat_samples) < 5:
            ibadat_samples.append(q)

print('Fiqh samples:')
for s in fiqh_samples:
    print(' ', s)
print('\nIbadat samples:')
for s in ibadat_samples:
    print(' ', s)

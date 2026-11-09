import sys
import re
from collections import Counter

sys.stdout.reconfigure(encoding='utf-8')

with open('lib/data/questions_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Let's extract questions 551 to 800
blocks = re.findall(r'Question\s*\((.*?)\n\s*\)', content, re.DOTALL)
phase3_cats = Counter()
for b in blocks[1:]: # skip class constructor
    m_id = re.search(r'\bid:\s*(\d+)', b)
    m_cat = re.search(r'category:\s*[\'"](.*?)[\'"]\s*,', b)
    if m_id and m_cat:
        qid = int(m_id.group(1))
        if qid > 550:
            phase3_cats[m_cat.group(1)] += 1

print("Phase 3 (551-800) Categories:")
for cat, cnt in phase3_cats.most_common():
    print(f"  {cat}: {cnt}")

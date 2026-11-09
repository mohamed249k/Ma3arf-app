import sys
import re
from collections import Counter

sys.stdout.reconfigure(encoding='utf-8')

with open('lib/data/questions_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

blocks = re.findall(r'Question\s*\((.*?)\n\s*\)', content, re.DOTALL)
phase2_cats = Counter()
base_cats = Counter()
for b in blocks[1:]:
    m_id = re.search(r'\bid:\s*(\d+)', b)
    m_cat = re.search(r'category:\s*[\'"](.*?)[\'"]\s*,', b)
    if m_id and m_cat:
        qid = int(m_id.group(1))
        if 300 < qid <= 550:
            phase2_cats[m_cat.group(1)] += 1
        elif qid <= 300:
            base_cats[m_cat.group(1)] += 1

print("Base (1-300) Categories:")
for cat, cnt in base_cats.most_common():
    print(f"  {cat}: {cnt}")

print("\nPhase 2 (301-550) Categories:")
for cat, cnt in phase2_cats.most_common():
    print(f"  {cat}: {cnt}")

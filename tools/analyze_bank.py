import sys
import os
import re
from collections import Counter
import json

sys.stdout.reconfigure(encoding='utf-8')

with open('lib/data/questions_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Let's parse each Question block accurately
# A Question instantiation looks like:
# Question(
#   id: ...,
#   question: ...,
#   choices: [...],
#   correct: ...,
#   explanation: ...,
#   source: ...,
#   category: ...,
#   difficulty: ...,
#   ...
# )

blocks = re.findall(r'Question\s*\((.*?)\n\s*\)', content, re.DOTALL)
print(f"Total Question() blocks: {len(blocks)}")

questions = []
for i, b in enumerate(blocks):
    m_id = re.search(r'\bid:\s*(\d+)', b)
    m_q = re.search(r'question:\s*[\'"](.*?)[\'"]\s*,', b, re.DOTALL)
    m_correct = re.search(r'correct:\s*(\d+)', b)
    m_cat = re.search(r'category:\s*[\'"](.*?)[\'"]\s*,', b)
    m_diff = re.search(r'difficulty:\s*[\'"](.*?)[\'"]\s*,', b)
    m_source = re.search(r'source:\s*[\'"](.*?)[\'"]\s*,', b, re.DOTALL)
    m_exp = re.search(r'explanation:\s*[\'"](.*?)[\'"]\s*,', b, re.DOTALL)

    q_obj = {
        'id': int(m_id.group(1)) if m_id else None,
        'question': m_q.group(1) if m_q else None,
        'correct': int(m_correct.group(1)) if m_correct else None,
        'category': m_cat.group(1) if m_cat else None,
        'difficulty': m_diff.group(1) if m_diff else None,
        'source': m_source.group(1) if m_source else None,
        'explanation': m_exp.group(1) if m_exp else None,
    }
    questions.append(q_obj)

ids = [q['id'] for q in questions if q['id'] is not None]
cats = [q['category'] for q in questions if q['category'] is not None]
diffs = [q['difficulty'] for q in questions if q['difficulty'] is not None]

print(f"Total parsed questions: {len(questions)}")
print(f"Total IDs: {len(ids)}, Unique IDs: {len(set(ids))}")
if ids:
    print(f"ID Range: min={min(ids)}, max={max(ids)}")
    missing_ids = set(range(min(ids), max(ids) + 1)) - set(ids)
    print(f"Missing IDs in range: {len(missing_ids)} {missing_ids if len(missing_ids) < 20 else ''}")

print("\nCategory Distribution:")
for cat, cnt in Counter(cats).most_common():
    print(f"  {cat}: {cnt}")

print("\nDifficulty Distribution:")
for diff, cnt in Counter(diffs).most_common():
    print(f"  {diff}: {cnt}")

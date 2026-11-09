import sys
import os
import re
import json
import hashlib

sys.stdout.reconfigure(encoding='utf-8')

with open('lib/data/questions_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Match Question blocks: Question( id: ... )
blocks = re.findall(r'Question\s*\((.*?)\n\s*\)', content, re.DOTALL)
questions = []

for b in blocks[1:]: # skip class constructor
    m_id = re.search(r'\bid:\s*(\d+)', b)
    m_cat = re.search(r'category:\s*[\'"](.*?)[\'"]\s*,', b)
    m_diff = re.search(r'difficulty:\s*[\'"](.*?)[\'"]\s*,', b)
    m_q = re.search(r'question:\s*[\'"](.*?)[\'"]\s*,', b, re.DOTALL)
    m_choices = re.search(r'choices:\s*\[(.*?)\]\s*,', b, re.DOTALL)
    m_correct = re.search(r'correct:\s*(\d+)', b)
    m_exp = re.search(r'explanation:\s*[\'"](.*?)[\'"]\s*,', b, re.DOTALL)
    m_source = re.search(r'source:\s*[\'"](.*?)[\'"]\s*,', b, re.DOTALL)
    m_stype = re.search(r'sourceType:\s*[\'"](.*?)[\'"]\s*,', b)
    m_sref = re.search(r'sourceReference:\s*[\'"](.*?)[\'"]\s*,', b)
    m_ver = re.search(r'isVerified:\s*(true|false)', b)
    m_rev = re.search(r'reviewStatus:\s*[\'"](.*?)[\'"]\s*,', b)

    choices = []
    if m_choices:
        choices = re.findall(r'[\'"](.*?)[\'"]', m_choices.group(1))

    q_data = {
        'id': int(m_id.group(1)) if m_id else None,
        'category': m_cat.group(1) if m_cat else '',
        'difficulty': m_diff.group(1) if m_diff else '',
        'question': m_q.group(1) if m_q else '',
        'choices': choices,
        'correct': int(m_correct.group(1)) if m_correct else 0,
        'explanation': m_exp.group(1) if m_exp else '',
        'source': m_source.group(1) if m_source else '',
        'sourceType': m_stype.group(1) if m_stype else '',
        'sourceReference': m_sref.group(1) if m_sref else '',
        'isVerified': (m_ver.group(1) == 'true') if m_ver else True,
        'reviewStatus': m_rev.group(1) if m_rev else 'verified',
    }
    questions.append(q_data)

os.makedirs('docs', exist_ok=True)
baseline_path = os.path.join('docs', 'baseline_snapshot_800.json')

with open(baseline_path, 'w', encoding='utf-8') as f:
    json.dump({
        'metadata': {
            'phase': 'Phase 4 Baseline Snapshot',
            'timestamp': '2026-11-01T20:55:00+02:00',
            'total_questions': len(questions),
            'id_min': min(q['id'] for q in questions),
            'id_max': max(q['id'] for q in questions),
        },
        'questions': questions,
    }, f, ensure_ascii=False, indent=2)

print(f"Successfully wrote baseline snapshot of {len(questions)} questions to {baseline_path}")

# Calculate sha256 of the baseline file
with open(baseline_path, 'rb') as f:
    sha = hashlib.sha256(f.read()).hexdigest()
print(f"Baseline Snapshot SHA-256: {sha}")

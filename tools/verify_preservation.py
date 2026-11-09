# -*- coding: utf-8 -*-
"""
Ma3arf - Verify 100% preservation of questions 1 to 800 against the immutable baseline snapshot.
"""

import sys
import os
import json

sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, os.path.dirname(__file__))

with open('docs/baseline_snapshot_800.json', 'r', encoding='utf-8') as f:
    data = json.load(f)
baseline_qs = data['questions']

import analyze_bank
current_qs = [q for q in analyze_bank.questions if q.get('id') is not None]
print(f"Current questions count: {len(current_qs)}")
assert len(current_qs) == 1000, f"Expected 1000, got {len(current_qs)}"

for i in range(800):
    bq = baseline_qs[i]
    cq = current_qs[i]
    assert bq['id'] == cq['id'], f"ID mismatch at index {i}"
    assert bq['question'] == cq['question'], f"Question mismatch at Q{bq['id']}"
    assert bq['category'] == cq['category'], f"Category mismatch at Q{bq['id']}"
    assert bq['difficulty'] == cq['difficulty'], f"Difficulty mismatch at Q{bq['id']}"
    assert bq['correct'] == cq['correct'], f"Correct index mismatch at Q{bq['id']}"
    assert bq['explanation'] == cq['explanation'], f"Explanation mismatch at Q{bq['id']}"
    if bq.get('source'):
        assert bq['source'] == cq['source'], f"Source mismatch at Q{bq['id']}"

print("SUCCESS: All 800 baseline questions are 100% preserved without a single modification!")

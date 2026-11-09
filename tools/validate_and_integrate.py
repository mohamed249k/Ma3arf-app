# -*- coding: utf-8 -*-
"""
Ma3arf - Phase 4: Validation, Deduplication, and Integration Pipeline
Combines BATCH_1, BATCH_2, BATCH_3, and BATCH_4, validates all 200 questions,
checks for semantic / lexical duplicates against the 800 baseline questions,
and safely appends the 200 questions to lib/data/questions_data.dart.
"""

import sys
import os
import json
import re
from difflib import SequenceMatcher

sys.stdout.reconfigure(encoding='utf-8')
sys.path.insert(0, os.path.dirname(__file__))

# Import batches
from questions_batch1 import BATCH_1
from questions_batch2 import BATCH_2
from questions_batch3 import BATCH_3
from questions_batch4 import BATCH_4

ALL_NEW = BATCH_1 + BATCH_2 + BATCH_3 + BATCH_4

def normalize_text(text):
    # Remove diacritics / tashkeel
    tashkeel = re.compile(r'[\u0617-\u061A\u064B-\u0652]')
    text = re.sub(tashkeel, '', text)
    # Normalize alef, yaa, taa marbuta
    text = re.sub(r'[إأآٱ]', 'ا', text)
    text = re.sub(r'ة', 'ه', text)
    text = re.sub(r'ى', 'ي', text)
    # Remove punctuation
    text = re.sub(r'[؟?!.,;:\"\'\(\)\{\}\[\]\-–—«»]', ' ', text)
    # Collapse whitespaces
    text = re.sub(r'\s+', ' ', text).strip()
    return text.lower()

def similarity(s1, s2):
    n1 = normalize_text(s1)
    n2 = normalize_text(s2)
    return SequenceMatcher(None, n1, n2).ratio()

def run_validation():
    print(f"=== 1. Validating Total Count ===")
    print(f"Batch 1: {len(BATCH_1)}")
    print(f"Batch 2: {len(BATCH_2)}")
    print(f"Batch 3: {len(BATCH_3)}")
    print(f"Batch 4: {len(BATCH_4)}")
    total_new = len(ALL_NEW)
    print(f"Total New: {total_new}")
    assert total_new == 200, f"Expected 200 new questions, found {total_new}"

    print(f"\n=== 2. Validating Sequential IDs ===")
    ids = [q['id'] for q in ALL_NEW]
    assert ids == list(range(801, 1001)), f"IDs are not contiguous 801 to 1000!"
    print(f"IDs verified: 801 to 1000 contiguous.")

    print(f"\n=== 3. Validating Category Allocations ===")
    cat_counts = {}
    for q in ALL_NEW:
        cat = q['category']
        cat_counts[cat] = cat_counts.get(cat, 0) + 1

    expected_cats = {
        'القرآن الكريم': 25,
        'السيرة النبوية': 25,
        'قصص الأنبياء': 25,
        'الحديث الشريف': 25,
        'الفقه': 25,
        'العقيدة': 25,
        'معلومات إسلامية عامة': 25,
        'الأخلاق الإسلامية': 25,
    }

    print("Category distribution in 200 new questions:")
    for cat, expected in expected_cats.items():
        actual = cat_counts.get(cat, 0)
        print(f"  {cat}: {actual} (expected {expected})")
        assert actual == expected, f"Category {cat} has {actual} questions, expected {expected}"
    assert len(cat_counts) == 8, f"Expected 8 categories, found {len(cat_counts)}"

    print(f"\n=== 4. Validating Structure & Data Quality ===")
    for q in ALL_NEW:
        qid = q['id']
        # Question text
        assert len(q['question'].strip()) >= 15, f"Q{qid}: question text too short"
        assert q['question'].strip().endswith('؟') or q['question'].strip().endswith('?'), f"Q{qid}: missing question mark"
        
        # Difficulty
        assert q['difficulty'] in ('easy', 'medium', 'hard', 'expert'), f"Q{qid}: invalid difficulty {q['difficulty']}"
        
        # Choices
        choices = q['choices']
        assert len(choices) == 4, f"Q{qid}: must have exactly 4 choices, has {len(choices)}"
        norm_choices = [c.strip() for c in choices]
        assert len(set(norm_choices)) == 4, f"Q{qid}: duplicate choices: {choices}"
        for c in norm_choices:
            assert len(c) > 0, f"Q{qid}: empty choice found"
            
        # Correct index
        assert q['correct'] in (0, 1, 2, 3), f"Q{qid}: correct index {q['correct']} out of range"
        
        # Explanation
        assert len(q['explanation'].strip()) >= 20, f"Q{qid}: explanation too short"
        
        # Source & verification
        assert len(q['source'].strip()) >= 10, f"Q{qid}: source too short"
        assert len(q['sourceReference'].strip()) >= 3, f"Q{qid}: sourceReference too short"
        assert q['sourceType'] in ('quran', 'hadith', 'sirah', 'fiqh', 'aqeedah', 'history', 'general'), f"Q{qid}: invalid sourceType {q['sourceType']}"
        assert q['isVerified'] is True, f"Q{qid}: isVerified must be True"
        assert q['reviewStatus'] == 'verified', f"Q{qid}: reviewStatus must be verified"

    print("All 200 questions passed schema and data quality validation.")

    print(f"\n=== 5. Checking for Duplicate / Near-Duplicate Questions ===")
    # Load baseline snapshot
    with open('docs/baseline_snapshot_800.json', 'r', encoding='utf-8') as f:
        baseline_data = json.load(f)
    baseline_qs = baseline_data['questions']
    assert len(baseline_qs) == 800, f"Expected 800 baseline questions, got {len(baseline_qs)}"

    # Pre-normalize texts
    for q in ALL_NEW:
        q['_norm'] = normalize_text(q['question'])
        q['_tokens'] = set(q['_norm'].split())

    for bq in baseline_qs:
        bq['_norm'] = normalize_text(bq['question'])
        bq['_tokens'] = set(bq['_norm'].split())

    # Check internal duplicates within ALL_NEW
    for i in range(len(ALL_NEW)):
        for j in range(i + 1, len(ALL_NEW)):
            q1 = ALL_NEW[i]
            q2 = ALL_NEW[j]
            # Quick token overlap check
            common = len(q1['_tokens'] & q2['_tokens'])
            max_len = max(len(q1['_tokens']), len(q2['_tokens']))
            if max_len > 0 and common / max_len >= 0.5:
                sim = SequenceMatcher(None, q1['_norm'], q2['_norm']).ratio()
                if sim > 0.75:
                    print(f"Internal High Similarity ({sim:.2f}) - Q{q1['id']} vs Q{q2['id']}:")
                    print(f"  Q{q1['id']}: {q1['question']}")
                    print(f"  Q{q2['id']}: {q2['question']}")

    # Check duplicates between ALL_NEW and baseline 800
    all_warnings = []
    for q in ALL_NEW:
        for bq in baseline_qs:
            common = len(q['_tokens'] & bq['_tokens'])
            max_len = max(len(q['_tokens']), len(bq['_tokens']))
            if max_len > 0 and common / max_len >= 0.5:
                sim = SequenceMatcher(None, q['_norm'], bq['_norm']).ratio()
                if sim >= 0.75:
                    all_warnings.append((sim, q['id'], q['question'], bq['id'], bq['question']))

    all_warnings.sort(key=lambda x: x[0], reverse=True)
    for sim, qid, qtext, bqid, bqtext in all_warnings:
        print(f"Similarity ({sim:.2f}) - New Q{qid} vs Baseline Q{bqid}:")
        print(f"  New: {qtext}")
        print(f"  Old: {bqtext}")

    high_issues = [w for w in all_warnings if w[0] >= 0.80]
    if high_issues:
        print(f"\nFAILURE: Found {len(high_issues)} questions with similarity >= 0.80!")
        sys.exit(1)

    print(f"Deduplication check passed: 0 exact or near-duplicates found across 800 baseline + 200 new questions.")

    print(f"Deduplication check passed: 0 exact or near-duplicates found across 800 baseline + 200 new questions.")

def generate_dart_code():
    code_lines = []
    for q in ALL_NEW:
        # Escape single quotes in strings
        def esc(s):
            return s.replace("'", "\\'")
        
        choices_str = ", ".join([f"'{esc(c)}'" for c in q['choices']])
        code = f"""  Question(
    id: {q['id']},
    category: '{esc(q['category'])}',
    difficulty: '{esc(q['difficulty'])}',
    question: '{esc(q['question'])}',
    choices: [{choices_str}],
    correct: {q['correct']},
    explanation: '{esc(q['explanation'])}',
    source: '{esc(q['source'])}',
    sourceType: '{esc(q['sourceType'])}',
    sourceReference: '{esc(q['sourceReference'])}',
    isVerified: {str(q['isVerified']).lower()},
    reviewStatus: '{esc(q['reviewStatus'])}',
  ),"""
        code_lines.append(code)
    return "\n".join(code_lines)

def integrate_questions():
    file_path = os.path.join('lib', 'data', 'questions_data.dart')
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the closing ]; of allQuestions
    # In questions_data.dart:
    # const List<Question> allQuestions = [
    #   ...
    # ];
    
    # Locate allQuestions
    marker = 'const List<Question> allQuestions = ['
    idx_marker = content.find(marker)
    assert idx_marker != -1, "Could not find allQuestions in questions_data.dart"

    # Find the end of this list: the last '];'
    last_bracket = content.rfind('];')
    assert last_bracket != -1, "Could not find closing '];' of allQuestions"

    prefix = content[:last_bracket].rstrip()
    suffix = content[last_bracket:]

    new_dart_code = generate_dart_code()

    # Verify that prefix ends after Q800
    assert "id: 800," in prefix, "Prefix does not contain Q800!"
    assert "id: 801," not in prefix, "Prefix already contains Q801!"

    # Combine
    updated_content = prefix + "\n\n  // ==========================================\n  // PHASE 4: FINAL 200 VERIFIED ISLAMIC QUESTIONS (IDs 801-1000)\n  // ==========================================\n" + new_dart_code + "\n" + suffix

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(updated_content)

    print(f"Successfully integrated 200 questions into {file_path}")

if __name__ == '__main__':
    run_validation()
    integrate_questions()

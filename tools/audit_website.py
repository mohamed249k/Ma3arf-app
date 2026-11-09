# -*- coding: utf-8 -*-
"""
Audit reference_index.html and reference_script.js for 100% Web-to-Flutter Parity.
"""

import sys
import re
import json

sys.stdout.reconfigure(encoding='utf-8')

with open('reference_index.html', 'r', encoding='utf-8') as f:
    html = f.read()

with open('reference_script.js', 'r', encoding='utf-8') as f:
    js = f.read()

print("=== 1. Website Sections / Screens ===")
sections = re.findall(r'<section\s+[^>]*id=["\']([^"\']+)["\']', html)
for s in sections:
    print(f" - Section: {s}")

print("\n=== 2. Website Modals / Overlays ===")
modals = re.findall(r'<div\s+[^>]*class="modal[^"]*"[^>]*id=["\']([^"\']+)["\']', html)
if not modals:
    modals = re.findall(r'id=["\']([^"\']*(?:modal|overlay|dialog)[^"\']*)["\']', html, re.I)
for m in set(modals):
    print(f" - Modal/Dialog: {m}")

print("\n=== 3. Website Categories ===")
# Find categories in JS
cats = re.findall(r'category\s*:\s*["\']([^"\']+)["\']', js)
cat_set = sorted(list(set(cats)))
print(f"Found {len(cat_set)} categories in JS:")
for c in cat_set:
    print(f" * {c}")

print("\n=== 4. Game Modes / Features in JS ===")
# Look for state variables, modes, functions
modes = re.findall(r'currentMode\s*=\s*["\']([^"\']+)["\']', js)
print("Modes found:", set(modes))

# Storage keys
storage_keys = re.findall(r'localStorage\.(?:getItem|setItem)\(["\']([^"\']+)["\']', js)
print("localStorage keys:", sorted(list(set(storage_keys))))

# Check achievements / badges in JS
achievements = re.findall(r'id\s*:\s*["\']([^"\']+)["\']\s*,\s*title\s*:\s*["\']([^"\']+)["\']', js)
print(f"Badges / Achievements ({len(achievements)}):")
for a in achievements[:10]:
    print(f" * {a[0]}: {a[1]}")

# Check levels / XP system
print("\n=== 5. Levels & Progression ===")
level_matches = re.findall(r'level\s*:\s*(\d+)\s*,\s*title\s*:\s*["\']([^"\']+)["\']', js)
print(f"Levels ({len(level_matches)}):")
for lvl in level_matches:
    print(f" * Level {lvl[0]}: {lvl[1]}")

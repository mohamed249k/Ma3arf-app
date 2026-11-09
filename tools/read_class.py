import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

with open('lib/data/questions_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

m = re.search(r'class Question\s*\{.*?\n\}', text, re.DOTALL)
if m:
    print(m.group(0))

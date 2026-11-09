import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

with open('lib/data/questions_data.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Let's inspect question 1
m = re.search(r'Question\s*\(\s*id:\s*1\b.*?\),', text, re.DOTALL)
if m:
    print(m.group(0))
else:
    print("Question 1 pattern not matched")

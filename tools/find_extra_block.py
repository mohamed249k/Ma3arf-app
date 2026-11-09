import sys
import re

sys.stdout.reconfigure(encoding='utf-8')

with open('lib/data/questions_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Let's inspect all Question occurrences
# Maybe the model class definition itself: class Question { ... } ?
for i, m in enumerate(re.finditer(r'Question\s*\(', content)):
    snippet = content[m.start():m.start() + 100]
    # Check if id: is in the next 150 characters
    if 'id:' not in content[m.start():m.start() + 150]:
        print(f"Occurrence {i} has no id nearby: {snippet}")

blocks = re.findall(r'Question\s*\((.*?)\n\s*\)', content, re.DOTALL)
print(f"Total blocks: {len(blocks)}")
for i, b in enumerate(blocks):
    m_id = re.search(r'\bid:\s*(\d+)', b)
    if not m_id:
        print(f"Block {i} has no id: {b[:150]}")

path = 'lib/features/review/mistakes_review_screen.dart'
with open(path, 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace(
    "title: const Text('مراجعة الأخطاء وتصحيحها')",
    "titleSpacing: 0,\n        title: const Text('مراجعة الأخطاء')",
)
c = c.replace(
    "'${mistakes.length} بحاجة للمراجعة'",
    "'${mistakes.length} أسئلة'",
)

with open(path, 'w', encoding='utf-8') as f:
    f.write(c)

print('Updated mistakes_review_screen.dart successfully!')

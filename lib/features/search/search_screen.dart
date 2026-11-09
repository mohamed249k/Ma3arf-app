import 'package:flutter/material.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:ma3arf/data/questions_data.dart';

class SearchScreen extends StatefulWidget {
  final GameState gameState;

  const SearchScreen({super.key, required this.gameState});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String? _selectedCategory;
  String? _selectedDifficulty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final normQuery = normalizeArabic(_query);
    final results = allQuestions.where((q) {
      final matchesQuery =
          normQuery.isEmpty ||
          normalizeArabic(q.question).contains(normQuery) ||
          normalizeArabic(q.explanation).contains(normQuery) ||
          q.choices.any((c) => normalizeArabic(c).contains(normQuery)) ||
          normalizeArabic(q.source).contains(normQuery);
      final matchesCat =
          _selectedCategory == null || q.category == _selectedCategory;
      final matchesDiff =
          _selectedDifficulty == null || q.difficulty == _selectedDifficulty;
      return matchesQuery && matchesCat && matchesDiff;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('البحث في المعارف الإسلامية')),
      body: IslamicGeometricBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Search Input Field
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _controller,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن آية، حديث، صحابي، مسألة فقهية...',
                    prefixIcon: AppIcon(AppIcons.search, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: AppIcon(AppIcons.close, size: 18),
                            onPressed: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF13221C)
                        : theme.colorScheme.surface,
                  ),
                  onChanged: (val) => setState(() => _query = val.trim()),
                ),
              ),

              // Category Filter Chips
              SizedBox(
                height: 38,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: [
                    ChoiceChip(
                      label: const Text('جميع التصنيفات'),
                      selected: _selectedCategory == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = null),
                    ),
                    const SizedBox(width: 8),
                    ...categoryIcons.keys.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          avatar: AppIcon(
                            AppIcons.getCategoryIcon(cat),
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.primary,
                          ),
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) => setState(
                            () => _selectedCategory = isSelected ? null : cat,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Results Counter & Divider
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Text(
                      'النتائج (${results.length})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Results List
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const IslamicStarPattern(
                              size: 80,
                              color: Color(0xFFD7B56D),
                              opacity: 0.2,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'لم يتم العثور على نتائج مطابقة',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'جرب كلمة بحث أخرى أو غير التصنيف المحدد',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) =>
                            _buildQuestionItem(results[i], theme, isDark),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionItem(Question q, ThemeData theme, bool isDark) {
    final isFav = widget.gameState.isFavorite(q.id);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.2 : 0.4),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: AppIconContainer(
          icon: AppIcons.getCategoryIcon(q.category),
          size: 38,
          iconSize: 20,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          iconColor: theme.colorScheme.primary,
        ),
        title: Text(
          q.question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(
                q.category,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
              const SizedBox(width: 8),
              Text(
                '• ${difficultyNames[q.difficulty] ?? q.difficulty}',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: AppIcon(
            isFav ? AppIcons.starFilled : AppIcons.star,
            color: isFav ? const Color(0xFFD7B56D) : theme.iconTheme.color,
            size: 20,
          ),
          onPressed: () async {
            await widget.gameState.toggleFavorite(q.id);
            setState(() {});
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                // Correct Answer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E8B68).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2E8B68).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      AppIcon(
                        AppIcons.checkCircle,
                        color: Color(0xFF2E8B68),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الإجابة الصحيحة: ${q.choices[q.correct]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E8B68),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (q.explanation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    q.explanation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.4,
                      color: isDark
                          ? const Color(0xFFA2B5AB)
                          : const Color(0xFF5A6E65),
                    ),
                  ),
                ],
                if (q.source.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      AppIcon(
                        AppIcons.learningMode,
                        size: 16,
                        color: Color(0xFFD7B56D),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'المصدر: ${q.source}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFFD7B56D)
                              : const Color(0xFF8C6B1B),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

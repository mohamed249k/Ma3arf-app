import 'package:flutter/material.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:ma3arf/data/questions_data.dart';
import 'package:ma3arf/features/quiz/quiz_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final GameState gameState;

  const FavoritesScreen({super.key, required this.gameState});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  void _startFavoritesQuiz() {
    final favorites = widget.gameState.getFavoriteQuestions();
    if (favorites.isEmpty) return;

    widget.gameState.selectGameConfig('favorites', 'favorites');
    final ready = widget.gameState.prepareQuizSession(
      customQuestions: favorites,
    );
    if (ready) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizScreen(gameState: widget.gameState),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final allFavs = widget.gameState.getFavoriteQuestions();

    final normQuery = normalizeArabic(_searchQuery);
    final filteredFavs = allFavs.where((q) {
      final matchesQuery =
          normQuery.isEmpty ||
          normalizeArabic(q.question).contains(normQuery) ||
          normalizeArabic(q.explanation).contains(normQuery);
      final matchesCat =
          _selectedCategory == null || q.category == _selectedCategory;
      return matchesQuery && matchesCat;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأسئلة المحفوظة'),
        actions: [
          if (allFavs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '${allFavs.length} سؤال',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: IslamicGeometricBackground(
        child: SafeArea(
          child: allFavs.isEmpty
              ? _buildEmptyState(theme)
              : Column(
                  children: [
                    // Search & Filter header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'ابحث في الأسئلة المحفوظة...',
                          prefixIcon: AppIcon(AppIcons.search, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: theme.dividerColor.withValues(alpha: 0.3),
                            ),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF13221C)
                              : theme.colorScheme.surface,
                        ),
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.trim()),
                      ),
                    ),

                    // Category filter chips if multiple categories present
                    _buildCategoryFilter(allFavs, theme),

                    const SizedBox(height: 4),

                    // Questions list
                    Expanded(
                      child: filteredFavs.isEmpty
                          ? Center(
                              child: Text(
                                'لا توجد نتائج مطابقة لبحثك',
                                style: theme.textTheme.bodyMedium,
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: filteredFavs.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (ctx, i) => _buildFavoriteCard(
                                filteredFavs[i],
                                theme,
                                isDark,
                              ),
                            ),
                    ),

                    // Start Quiz Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        border: Border(
                          top: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: AppIcon(AppIcons.advanced, size: 20),
                          label: Text(
                            'اختبار مخصص من المحفوظات (${allFavs.length})',
                          ),
                          onPressed: _startFavoritesQuiz,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(List<Question> allFavs, ThemeData theme) {
    final categories = allFavs.map((q) => q.category).toSet().toList();
    if (categories.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, idx) {
          if (idx == 0) {
            final isAll = _selectedCategory == null;
            return ChoiceChip(
              label: const Text('الكل'),
              selected: isAll,
              onSelected: (_) => setState(() => _selectedCategory = null),
            );
          }
          final cat = categories[idx - 1];
          final isSelected = _selectedCategory == cat;
          return ChoiceChip(
            avatar: AppIcon(
              AppIcons.getCategoryIcon(cat),
              size: 16,
              color: isSelected ? Colors.white : theme.colorScheme.primary,
            ),
            label: Text(cat),
            selected: isSelected,
            onSelected: (_) =>
                setState(() => _selectedCategory = isSelected ? null : cat),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Question q, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: isDark ? 0.2 : 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  avatar: AppIcon(
                    AppIcons.getCategoryIcon(q.category),
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(q.category, style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Spacer(),
                IconButton(
                  icon: AppIcon(
                    AppIcons.starFilled,
                    color: Color(0xFFD7B56D),
                    size: 20,
                  ),
                  tooltip: 'إزالة من المحفوظات',
                  onPressed: () async {
                    await widget.gameState.toggleFavorite(q.id);
                    setState(() {});
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              q.question,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  AppIcon(
                    AppIcons.checkCircle,
                    size: 16,
                    color: Color(0xFF2E8B68),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'الإجابة الصحيحة: ${q.choices[q.correct]}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
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
                    size: 14,
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
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const IslamicStarPattern(
              size: 100,
              color: Color(0xFFD7B56D),
              opacity: 0.25,
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد أسئلة محفوظة بعد',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك حفظ أي سؤال أثناء الاختبار للرجوع إليه وتثبيت حفظه متى شئت.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

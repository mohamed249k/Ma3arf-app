import 'package:flutter/material.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:ma3arf/features/quiz/quiz_screen.dart';

class QuizConfigSheet extends StatefulWidget {
  final GameState gameState;
  final String? initialCategory;
  final String? initialDifficulty;

  const QuizConfigSheet({
    super.key,
    required this.gameState,
    this.initialCategory,
    this.initialDifficulty,
  });

  static Future<void> show(
    BuildContext context,
    GameState gameState, {
    String? category,
    String? difficulty,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuizConfigSheet(
        gameState: gameState,
        initialCategory: category,
        initialDifficulty: difficulty,
      ),
    );
  }

  @override
  State<QuizConfigSheet> createState() => _QuizConfigSheetState();
}

class _QuizConfigSheetState extends State<QuizConfigSheet> {
  late QuizMode _selectedMode;
  late int _selectedCount;
  String? _selectedCategory;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.gameState.quizMode;
    _selectedCount = 10;
    _selectedCategory = widget.initialCategory;
    _selectedDifficulty = widget.initialDifficulty;
  }

  void _onStart() {
    final gs = widget.gameState;
    if (_selectedCategory != null) {
      gs.selectGameConfig(
        'category',
        _selectedCategory!,
        modeType: _selectedMode,
        count: _selectedCount,
      );
    } else if (_selectedDifficulty != null) {
      gs.selectGameConfig(
        'difficulty',
        _selectedDifficulty!,
        modeType: _selectedMode,
        count: _selectedCount,
      );
    } else {
      gs.selectGameConfig(
        'all',
        'all',
        modeType: _selectedMode,
        count: _selectedCount,
      );
    }

    final ready = gs.prepareQuizSession(
      count: _selectedCount,
      mode: _selectedMode,
    );

    Navigator.of(context).pop();

    if (ready) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => QuizScreen(gameState: gs)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر إعداد أسئلة لهذا الاختيار')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppIcon(
                      AppIcons.tune,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تخصيص جلسة الاختبار',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedCategory != null
                              ? 'تصنيف: $_selectedCategory'
                              : 'اختر نمط التعلم وعدد الأسئلة',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const IslamicDivider(height: 16),
              const SizedBox(height: 12),

              // 1. Mode Selection (Learning vs Challenge)
              Text(
                'نمط الجلسة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildModeCard(
                      title: 'وضع التحدي',
                      subtitle: 'مؤقت، نقاط XP، وأوسمة',
                      icon: AppIcons.timer,
                      isSelected: _selectedMode == QuizMode.challenge,
                      onTap: () =>
                          setState(() => _selectedMode = QuizMode.challenge),
                      theme: theme,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModeCard(
                      title: 'وضع التعلّم',
                      subtitle: 'بدون وقت مع توضيح فوري',
                      icon: AppIcons.learningMode,
                      isSelected: _selectedMode == QuizMode.learning,
                      onTap: () =>
                          setState(() => _selectedMode = QuizMode.learning),
                      theme: theme,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Question Count Selection
              Text(
                'عدد الأسئلة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5, 10, 15, 20, 25].map((count) {
                  final isSelected = _selectedCount == count;
                  return ChoiceChip(
                    label: Text('$count أسئلة'),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCount = count),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.textTheme.bodyMedium?.color,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Start Button
              ElevatedButton.icon(
                icon: AppIcon(AppIcons.play, size: 22),
                label: Text(
                  _selectedMode == QuizMode.challenge
                      ? 'بدء التحدي الآن'
                      : 'بدء جلسة التعلّم',
                ),
                onPressed: _onStart,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    final borderColor = isSelected
        ? theme.colorScheme.secondary
        : theme.dividerColor.withValues(alpha: 0.3);
    final bgColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.15)
        : (isDark ? const Color(0xFF13221C) : Colors.white);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppIcon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : theme.iconTheme.color,
                ),
                const Spacer(),
                if (isSelected)
                  AppIcon(
                    AppIcons.checkCircle,
                    size: 18,
                    color: theme.colorScheme.secondary,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? theme.colorScheme.secondary : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/data/questions_data.dart';
import 'package:ma3arf/features/quiz/quiz_screen.dart';

class MistakesReviewScreen extends StatefulWidget {
  final GameState gameState;

  const MistakesReviewScreen({super.key, required this.gameState});

  @override
  State<MistakesReviewScreen> createState() => _MistakesReviewScreenState();
}

class _MistakesReviewScreenState extends State<MistakesReviewScreen> {
  void _startMistakesQuiz() {
    final mistakes = widget.gameState.getMistakeQuestions();
    if (mistakes.isEmpty) return;

    widget.gameState.selectGameConfig('mistakes', 'mistakes');
    final ready = widget.gameState.prepareQuizSession(
      customQuestions: mistakes,
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

    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        final mistakes = widget.gameState.getMistakeQuestions();

        return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('مراجعة الأخطاء'),
        actions: [
          if (mistakes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9534F).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD9534F).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '${mistakes.length} أسئلة',
                    style: const TextStyle(
                      color: Color(0xFFD9534F),
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
          child: mistakes.isEmpty
              ? _buildCleanState(theme)
              : Column(
                  children: [
                    // Info Card
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          AppIcon(
                            AppIcons.mistakesReview,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'هذه الأسئلة أخطأت فيها سابقاً. يمكنك مراجعة الإجابة الصحيحة أو إجراء اختبار تصحيحي لتثبيت المعلومة وحذفها تلقائياً عند الإجابة الصحيحة.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mistakes List
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: mistakes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) =>
                            _buildMistakeCard(mistakes[i], theme, isDark),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8B68),
                          ),
                          icon: AppIcon(AppIcons.dailyChallenge, size: 20),
                          label: Text(
                            'بدء اختبار التصحيح (${mistakes.length} أسئلة)',
                          ),
                          onPressed: _startMistakesQuiz,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildMistakeCard(Question q, ThemeData theme, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFFD9534F).withValues(alpha: 0.25),
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
                  label: Text(q.category, style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Spacer(),
                IconButton(
                  icon: AppIcon(AppIcons.checkCircle, size: 20),
                  tooltip: 'تم تثبيت المعلومة (إزالة من القائمة)',
                  onPressed: () {
                    widget.gameState.removeMistake(q.id);
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
                color: const Color(0xFF2E8B68).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF2E8B68).withValues(alpha: 0.3),
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
                      'الصواب: ${q.choices[q.correct]}',
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

  Widget _buildCleanState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIconContainer(
              icon: AppIcons.checkCircle,
              size: 80,
              iconSize: 42,
              iconColor: const Color(0xFF2E8B68),
              backgroundColor: const Color(0x1F2E8B68),
            ),
            const SizedBox(height: 24),
            Text(
              'سجلّك خالٍ من الأخطاء!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أحسنت! إما أنك أجبت على جميع الأسئلة بصورة صحيحة أو أتممت تصحيح كافة أخطائك السابقة.',
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

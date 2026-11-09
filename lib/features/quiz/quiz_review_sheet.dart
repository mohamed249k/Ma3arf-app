import 'package:flutter/material.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/features/results/results_screen.dart';

class QuizReviewSheet extends StatefulWidget {
  final GameState gameState;
  final Function(int) onJumpToQuestion;

  const QuizReviewSheet({
    super.key,
    required this.gameState,
    required this.onJumpToQuestion,
  });

  static Future<void> show(
    BuildContext context, {
    required GameState gameState,
    required Function(int) onJumpToQuestion,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuizReviewSheet(
        gameState: gameState,
        onJumpToQuestion: onJumpToQuestion,
      ),
    );
  }

  @override
  State<QuizReviewSheet> createState() => _QuizReviewSheetState();
}

class _QuizReviewSheetState extends State<QuizReviewSheet> {
  void _confirmAndFinish() {
    final gs = widget.gameState;
    final total = gs.quizQuestions.length;
    final answered = gs.answersLog.length;
    final unanswered = total - answered;

    if (unanswered > 0) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('تأكيد إنهاء الاختبار'),
          content: Text(
            'لقد أجبت عن $answered من أصل $total أسئلة، وما زالت هناك $unanswered أسئلة دون إجابة.\n\nهل تود إنهاء الاختبار الآن واحتساب النتيجة النهائية؟',
          ),
          actions: [
            TextButton(
              child: const Text('متابعة الإجابة'),
              onPressed: () => Navigator.of(dialogCtx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text('إنهاء واحتساب النتيجة'),
              onPressed: () {
                Navigator.of(dialogCtx).pop(); // Close dialog
                Navigator.of(context).pop(); // Close review sheet
                final finishResult = gs.finishQuizSession();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (ctx) =>
                        ResultsScreen(result: finishResult, gameState: gs),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
      final finishResult = gs.finishQuizSession();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => ResultsScreen(result: finishResult, gameState: gs),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gs = widget.gameState;
    final questions = gs.quizQuestions;
    final answeredIndices = <int, int>{}; // qIndex -> selectedChoice

    for (int i = 0; i < gs.answersLog.length; i++) {
      answeredIndices[i] = gs.answersLog[i].selected;
    }

    final totalAnswered = answeredIndices.length;
    final totalQuestions = questions.length;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.secondary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
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
            const SizedBox(height: 14),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AppIcon(
                    AppIcons.history,
                    color: theme.colorScheme.secondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مراجعة وتعديل الإجابات',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'أجبت عن $totalAnswered من أصل $totalQuestions سؤالاً',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (!gs.isLearningMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7B56D).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD7B56D).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      '${gs.questionTimeLeft} ث',
                      style: const TextStyle(
                        color: Color(0xFFD7B56D),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            const IslamicDivider(height: 14),
            const SizedBox(height: 8),

            // Question Overview List
            Expanded(
              child: ListView.separated(
                itemCount: questions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final q = questions[i];
                  final isAnswered = i < gs.answersLog.length;
                  final selectedChoice = isAnswered
                      ? gs.answersLog[i].selected
                      : null;
                  final isCurrent = i == gs.currentQuestionIdx;

                  return Card(
                    elevation: isCurrent ? 3 : 1,
                    color: isCurrent
                        ? theme.colorScheme.primary.withValues(
                            alpha: isDark ? 0.2 : 0.08,
                          )
                        : (isDark ? const Color(0xFF13221C) : null),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isCurrent
                            ? theme.colorScheme.secondary
                            : (isAnswered
                                  ? const Color(
                                      0xFF2E8B68,
                                    ).withValues(alpha: 0.4)
                                  : theme.dividerColor.withValues(alpha: 0.3)),
                        width: isCurrent ? 1.6 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: isAnswered
                            ? const Color(0xFF2E8B68)
                            : (isCurrent
                                  ? const Color(0xFFD7B56D)
                                  : theme.dividerColor.withValues(alpha: 0.4)),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isAnswered || isCurrent
                                ? Colors.white
                                : null,
                          ),
                        ),
                      ),
                      title: Text(
                        q.question,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        isAnswered &&
                                selectedChoice != null &&
                                selectedChoice >= 0
                            ? 'إجابتك: ${q.choices[selectedChoice]}'
                            : 'لم تتم الإجابة بعد',
                        style: TextStyle(
                          fontSize: 11,
                          color:
                              isAnswered &&
                                  selectedChoice != null &&
                                  selectedChoice >= 0
                              ? const Color(0xFF2E8B68)
                              : const Color(0xFFD7B56D),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCurrent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'الحالي',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          AppIcon(
                            AppIcons.forward,
                            size: 14,
                            matchTextDirection: true,
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onJumpToQuestion(i);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Bottom Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: const Text('متابعة الاختبار'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: AppIcon(AppIcons.checkCircle, size: 18),
                    label: const Text('إنهاء واحتساب النتيجة'),
                    onPressed: _confirmAndFinish,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

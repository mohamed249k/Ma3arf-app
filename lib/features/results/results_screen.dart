import 'package:flutter/material.dart';
import 'package:ma3arf/core/services/audio_feedback_service.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:ma3arf/data/questions_data.dart';
import 'package:ma3arf/features/quiz/quiz_screen.dart';
import 'package:ma3arf/features/share/share_result_dialog.dart';
import 'package:ma3arf/features/sources/source_details_sheet.dart';

class ResultsScreen extends StatefulWidget {
  final FinishResult result;
  final GameState gameState;

  const ResultsScreen({
    super.key,
    required this.result,
    required this.gameState,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isReviewExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.result.newBadges.isNotEmpty) {
        AudioFeedbackService.instance.playAchievement();
      } else {
        AudioFeedbackService.instance.playQuizComplete();
      }
    });
  }

  void _retryQuiz(BuildContext context) {
    AudioFeedbackService.instance.playClick();
    final gs = widget.gameState;
    final ready = gs.prepareQuizSession(
      count: gs.requestedQuestionCount,
      mode: gs.quizMode,
    );
    if (ready) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizScreen(gameState: gs),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final result = widget.result;
    final gs = widget.gameState;
    final isSuccess = result.percent >= 80;

    return Scaffold(
      appBar: AppBar(
        title: const Text('نتيجة الاختبار'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'مشاركة النتيجة',
            icon: AppIcon(AppIcons.share, size: 20),
            onPressed: () {
              ShareResultDialog.show(
                context,
                correctCount: result.correctCount,
                totalQuestions: result.totalQuestions,
                percent: result.percent,
                difficultyName:
                    difficultyNames[gs.selectedVal] ?? gs.selectedVal,
                category: gs.selectedMode == 'category'
                    ? gs.selectedVal
                    : 'مختلط',
                quizModeName: gs.isLearningMode ? 'تعلّم' : 'تحدي',
                questionIds: gs.quizQuestions.map((q) => q.id).toList(),
              );
            },
          ),
          IconButton(
            tooltip: 'الرئيسية',
            icon: AppIcon(AppIcons.home, size: 20),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: IslamicGeometricBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // 1. Performance Banner Card (Score & Percentage)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                    color: isSuccess
                        ? const Color(0xFFD7B56D)
                        : theme.dividerColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  child: Column(
                    children: [
                      // Radial / Icon Badge
                      AppIconContainer(
                        icon: result.percent == 100
                            ? AppIcons.expert
                            : result.percent >= 80
                            ? AppIcons.leaderboard
                            : result.percent >= 50
                            ? AppIcons.achievements
                            : AppIcons.beginner,
                        size: 64,
                        iconSize: 32,
                        iconColor: isSuccess
                            ? const Color(0xFFD7B56D)
                            : theme.colorScheme.primary,
                        backgroundColor: (isSuccess
                                ? const Color(0xFFD7B56D)
                                : theme.colorScheme.primary)
                            .withValues(alpha: 0.15),
                        borderColor: (isSuccess
                                ? const Color(0xFFD7B56D)
                                : theme.colorScheme.primary)
                            .withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),

                      // Motivational Title
                      Text(
                        result.motivationalTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFD7B56D),
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Score Percentage
                      Text(
                        '${result.percent}%',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${result.correctCount} من إجمالي ${result.totalQuestions} أسئلة',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: isDark ? const Color(0xFFA2B5AB) : const Color(0xFF5A6E65),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Motivational Description
                      Text(
                        result.motivationalDesc,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 2. Summary Stats Grid (2x2 to prevent horizontal overflow on any phone)
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'إجابات صحيحة',
                      value: '${result.correctCount}',
                      icon: AppIcons.checkCircle,
                      color: const Color(0xFF198754),
                      theme: theme,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'إجابات خاطئة',
                      value: '${result.wrongCount}',
                      icon: AppIcons.xCircle,
                      color: const Color(0xFFDC3545),
                      theme: theme,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'نقاط الخبرة',
                      value: '+${result.xpEarned} XP',
                      icon: AppIcons.dailyChallenge,
                      color: const Color(0xFFD7B56D),
                      theme: theme,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'الوقت المستغرق',
                      value: result.formattedTime,
                      icon: AppIcons.timer,
                      color: theme.colorScheme.primary,
                      theme: theme,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              // 3. Unlocked Badges Panel (if any)
              if (result.newBadges.isNotEmpty) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    AppIcon(AppIcons.achievements, size: 20, color: const Color(0xFFD7B56D)),
                    const SizedBox(width: 8),
                    Text(
                      'أوسمة جديدة تم فتحها!',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (final badge in result.newBadges)
                  Card(
                    color: isDark ? const Color(0xFF1E3327) : const Color(0xFFFFF8E7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFD7B56D), width: 1.2),
                    ),
                    child: ListTile(
                      leading: AppIconContainer(
                        icon: badge.icon,
                        size: 40,
                        iconSize: 20,
                        iconColor: const Color(0xFFD7B56D),
                        backgroundColor: const Color(0xFFD7B56D).withValues(alpha: 0.15),
                      ),
                      title: Text(badge.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(badge.desc, style: const TextStyle(fontSize: 12)),
                    ),
                  ),
              ],

              const SizedBox(height: 16),

              // 4. Review Answers Accordion (مراجعة الأسئلة والإجابات التفصيلية)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          AudioFeedbackService.instance.playClick();
                          setState(() => _isReviewExpanded = !_isReviewExpanded);
                        },
                        child: Row(
                          children: [
                            AppIcon(AppIcons.history, size: 20, color: theme.colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'مراجعة الأسئلة والإجابات التفصيلية',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            AppIcon(
                              _isReviewExpanded ? AppIcons.caretDown : AppIcons.caretDown,
                              size: 18,
                              color: theme.colorScheme.secondary,
                            ),
                          ],
                        ),
                      ),
                      if (_isReviewExpanded) ...[
                        const Divider(height: 20),
                        for (int i = 0; i < gs.answersLog.length; i++)
                          _buildReviewLogItem(i, gs.answersLog[i], theme, isDark),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 5. Action Buttons (الرئيسية & إعادة نفس الاختبار)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        AudioFeedbackService.instance.playClick();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text('العودة للرئيسية'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: AppIcon(AppIcons.restart, size: 18),
                      label: const Text('إعادة الاختبار'),
                      onPressed: () => _retryQuiz(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewLogItem(
    int idx,
    AnswerLog log,
    ThemeData theme,
    bool isDark,
  ) {
    final isCorrect = log.isCorrect;
    final gs = widget.gameState;
    Question? originalQ;
    try {
      originalQ = allQuestions.firstWhere((q) => q.id == log.questionId);
    } catch (_) {}

    final isFav = originalQ != null && gs.isFavorite(originalQ.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect
            ? const Color(0xFF198754).withValues(alpha: isDark ? 0.15 : 0.08)
            : const Color(0xFFDC3545).withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? const Color(0xFF198754).withValues(alpha: 0.3)
              : const Color(0xFFDC3545).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(
                isCorrect ? AppIcons.checkCircle : AppIcons.xCircle,
                color: isCorrect ? const Color(0xFF198754) : const Color(0xFFDC3545),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'السؤال ${idx + 1}: ${log.question}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              if (originalQ != null)
                IconButton(
                  icon: AppIcon(
                    isFav ? AppIcons.starFilled : AppIcons.star,
                    size: 18,
                    color: isFav ? const Color(0xFFD7B56D) : null,
                  ),
                  tooltip: 'المفضلة',
                  onPressed: () async {
                    await gs.toggleFavorite(originalQ!.id);
                    setState(() {});
                  },
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (log.selected == -1)
            const Text(
              'انتهى الوقت دون إجابة',
              style: TextStyle(color: Color(0xFFDC3545), fontWeight: FontWeight.w600, fontSize: 12),
            )
          else
            Text(
              'إجابتك: ${log.choices[log.selected]}',
              style: TextStyle(
                color: isCorrect ? const Color(0xFF198754) : const Color(0xFFDC3545),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          if (!isCorrect) ...[
            const SizedBox(height: 3),
            Text(
              'الإجابة الصحيحة: ${log.choices[log.correct]}',
              style: const TextStyle(color: Color(0xFF198754), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
          if (originalQ != null && originalQ.source.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'المصدر: ${originalQ.source}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFD7B56D), fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('تفاصيل', style: TextStyle(fontSize: 11)),
                  onPressed: () => SourceDetailsSheet.show(context, originalQ!),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF13221C) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: AppIcon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

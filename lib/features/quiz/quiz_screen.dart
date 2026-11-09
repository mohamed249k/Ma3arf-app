import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ma3arf/core/services/audio_feedback_service.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:ma3arf/features/quiz/quiz_review_sheet.dart';
import 'package:ma3arf/features/results/results_screen.dart';
import 'package:ma3arf/features/sources/source_details_sheet.dart';

class QuizScreen extends StatefulWidget {
  final GameState gameState;

  const QuizScreen({super.key, required this.gameState});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  int? _selectedChoice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startTimerForCurrentQuestion();
      }
    });
  }

  @override
  void dispose() {
    widget.gameState.pauseTimers();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      widget.gameState.pauseTimers();
    } else if (state == AppLifecycleState.resumed) {
      widget.gameState.resumeTimers();
    }
  }

  void _startTimerForCurrentQuestion() {
    final gs = widget.gameState;
    if (gs.currentQuestionIdx < gs.answersLog.length) {
      _selectedChoice = gs.answersLog[gs.currentQuestionIdx].selected;
    } else {
      _selectedChoice = null;
    }

    widget.gameState.startQuestionCountdown(
      () {
        if (!mounted) return;
        widget.gameState.handleAnswerTimeout();
        setState(() {});
      },
      () {
        if (!mounted) return;
        setState(() {});
      },
    );
  }

  void _onChoiceSelected(int index) {
    if (widget.gameState.hasAnswered) return;
    setState(() {
      _selectedChoice = index;
    });
    widget.gameState.handleAnswerSelection(index);
  }

  void _onNextQuestion() {
    AudioFeedbackService.instance.playClick();
    if (widget.gameState.isLastQuestion) {
      final finishResult = widget.gameState.finishQuizSession();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              ResultsScreen(result: finishResult, gameState: widget.gameState),
        ),
      );
    } else {
      widget.gameState.moveToNextQuestion();
      _startTimerForCurrentQuestion();
      setState(() {});
    }
  }

  Future<bool> _onWillPop() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('مغادرة الاختبار'),
        content: const Text(
          'هل تود حقاً الخروج من الاختبار الحالي؟ سيتم إلغاء التقدم في هذه الجلسة.',
        ),
        actions: [
          TextButton(
            child: const Text('مواصلة الاختبار'),
            onPressed: () => Navigator.of(dialogCtx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('مغادرة'),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gs = widget.gameState;
    final questions = gs.quizQuestions;

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('خطأ')),
        body: const Center(child: Text('لا توجد أسئلة متاحة لهذا الاختبار')),
      );
    }

    final currentQ = gs.currentQuestion;
    final isFav = gs.isFavorite(currentQ.id);
    final timeLeft = gs.questionTimeLeft;
    final totalTime = gs.totalQuestionTime;
    final timerRatio = totalTime > 0
        ? (timeLeft / totalTime).clamp(0.0, 1.0)
        : 0.0;

    Color timerColor;
    if (timeLeft <= 4) {
      timerColor = const Color(0xFFDC3545);
    } else if (timeLeft <= 8) {
      timerColor = const Color(0xFFD7B56D);
    } else {
      timerColor = const Color(0xFF198754);
    }

    const choiceLetters = ['أ', 'ب', 'ج', 'د'];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _onWillPop();
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: IconButton(
            icon: AppIcon(AppIcons.close, size: 22),
            tooltip: 'انسحاب',
            onPressed: () async {
              final shouldLeave = await _onWillPop();
              if (shouldLeave && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'السؤال ${gs.currentQuestionIdx + 1} من ${questions.length}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            // Sound Toggle
            IconButton(
              tooltip: gs.isSoundEnabled ? 'الصوت مفعّل' : 'الصوت متوقف',
              icon: AppIcon(
                gs.isSoundEnabled ? AppIcons.soundOn : AppIcons.soundOff,
                size: 20,
              ),
              onPressed: () => gs.toggleSound(),
            ),
            // Review Answers List
            IconButton(
              tooltip: 'مراجعة الإجابات',
              icon: AppIcon(AppIcons.history, size: 20),
              onPressed: () {
                QuizReviewSheet.show(
                  context,
                  gameState: gs,
                  onJumpToQuestion: (idx) {
                    setState(() {
                      gs.jumpToQuestion(idx);
                      _startTimerForCurrentQuestion();
                    });
                  },
                );
              },
            ),
            // Bookmark / Favorite
            IconButton(
              tooltip: isFav ? 'محفوظ في المفضلة' : 'حفظ في المفضلة',
              icon: AppIcon(
                isFav ? AppIcons.starFilled : AppIcons.star,
                color: isFav ? const Color(0xFFD7B56D) : null,
                size: 20,
              ),
              onPressed: () async {
                await gs.toggleFavorite(currentQ.id);
                setState(() {});
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
              value: gs.quizProgress,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.secondary,
              ),
            ),
          ),
        ),
        body: IslamicGeometricBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Top Info Bar (Category & Timer Widget)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // Category Chip (Flexible to prevent overflow)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF13221C) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.dividerColor.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(
                                AppIcons.getCategoryIcon(currentQ.category),
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  currentQ.category,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Score badge
                      if (!gs.isLearningMode)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD7B56D).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD7B56D).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(AppIcons.dailyChallenge, size: 14, color: const Color(0xFFD7B56D)),
                              const SizedBox(width: 4),
                              Text(
                                '${gs.score}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFFD7B56D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),

                      // Smart Timer Widget (Circular / Badge)
                      if (gs.isLearningMode)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E8B68).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF2E8B68).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppIcon(AppIcons.learningMode, size: 14, color: const Color(0xFF2E8B68)),
                              const SizedBox(width: 4),
                              const Text(
                                'تعلّم',
                                style: TextStyle(
                                  color: Color(0xFF2E8B68),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        _SmartTimerRing(
                          secondsLeft: timeLeft,
                          ratio: timerRatio,
                          color: timerColor,
                        ),
                    ],
                  ),
                ),

                // Question & Choices Content (Scrollable, responsive)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    children: [
                      // Question Card
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                            width: 1.2,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    difficultyNames[currentQ.difficulty] ?? currentQ.difficulty,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentQ.question,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  height: 1.45,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 4 Choices
                      for (int i = 0; i < currentQ.choices.length; i++) ...[
                        _buildChoiceTile(
                          index: i,
                          letter: i < choiceLetters.length ? choiceLetters[i] : '',
                          text: currentQ.choices[i],
                          correctIndex: currentQ.correct,
                          theme: theme,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Educational Feedback Explanation Panel (Shown after answering)
                      if (gs.hasAnswered) ...[
                        const SizedBox(height: 10),
                        Card(
                          color: theme.colorScheme.primary.withValues(
                            alpha: isDark ? 0.14 : 0.08,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    AppIcon(
                                      AppIcons.wisdom,
                                      color: theme.colorScheme.secondary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'فائدة وتوضيح',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: theme.colorScheme.secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    Flexible(
                                      child: TextButton.icon(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        icon: AppIcon(AppIcons.verified, size: 14),
                                        label: const Text(
                                          'المصدر',
                                          style: TextStyle(fontSize: 11),
                                        ),
                                        onPressed: () => SourceDetailsSheet.show(
                                          context,
                                          currentQ,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  currentQ.explanation,
                                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                                ),
                                if (currentQ.source.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'المصدر: ${currentQ.source}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFD7B56D),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // Bottom Bar with Next Button & Review Shortcut
                if (gs.hasAnswered)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      border: Border(
                        top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                          icon: AppIcon(AppIcons.history, size: 18),
                          label: const Text('مراجعة'),
                          onPressed: () {
                            QuizReviewSheet.show(
                              context,
                              gameState: gs,
                              onJumpToQuestion: (idx) {
                                setState(() {
                                  gs.jumpToQuestion(idx);
                                  _startTimerForCurrentQuestion();
                                });
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: AppIcon(
                              gs.isLastQuestion ? AppIcons.leaderboard : AppIcons.forward,
                              size: 18,
                              matchTextDirection: true,
                            ),
                            label: Text(
                              gs.isLastQuestion ? 'عرض النتيجة' : 'السؤال التالي',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: _onNextQuestion,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceTile({
    required int index,
    required String letter,
    required String text,
    required int correctIndex,
    required ThemeData theme,
    required bool isDark,
  }) {
    final gs = widget.gameState;
    final hasAnswered = gs.hasAnswered;
    final isSelected = _selectedChoice == index;
    final isCorrect = index == correctIndex;

    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;
    IconData? trailingIcon;
    Color? iconColor;

    if (hasAnswered) {
      if (isCorrect) {
        backgroundColor = const Color(0xFF198754).withValues(alpha: isDark ? 0.25 : 0.15);
        borderColor = const Color(0xFF198754);
        textColor = const Color(0xFF198754);
        trailingIcon = AppIcons.checkCircle;
        iconColor = const Color(0xFF198754);
      } else if (isSelected) {
        backgroundColor = const Color(0xFFDC3545).withValues(alpha: isDark ? 0.25 : 0.15);
        borderColor = const Color(0xFFDC3545);
        textColor = const Color(0xFFDC3545);
        trailingIcon = AppIcons.xCircle;
        iconColor = const Color(0xFFDC3545);
      }
    }

    return Card(
      elevation: isSelected ? 3 : 1,
      color: backgroundColor ?? (isDark ? const Color(0xFF13221C) : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor ?? theme.dividerColor.withValues(alpha: 0.45),
          width: isSelected || (hasAnswered && isCorrect) ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: hasAnswered ? null : () => _onChoiceSelected(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCorrect && hasAnswered
                      ? const Color(0xFF198754)
                      : isSelected && hasAnswered
                      ? const Color(0xFFDC3545)
                      : theme.colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  letter,
                  style: TextStyle(
                    color: hasAnswered && (isCorrect || isSelected)
                        ? Colors.white
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.35,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                AppIcon(trailingIcon, color: iconColor, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SmartTimerRing extends StatelessWidget {
  final int secondsLeft;
  final double ratio;
  final Color color;

  const _SmartTimerRing({
    required this.secondsLeft,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(44, 44),
            painter: _RingPainter(ratio: ratio, color: color),
          ),
          Text(
            '$secondsLeft',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double ratio;
  final Color color;

  _RingPainter({required this.ratio, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 3.0;

    // Background track
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, bgPaint);

    // Active progress arc
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    final sweepAngle = 2 * math.pi * ratio;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.ratio != ratio || oldDelegate.color != color;
  }
}

import 'package:flutter/material.dart';
import 'package:ma3arf/core/services/audio_feedback_service.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/theme/app_theme.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:ma3arf/data/questions_data.dart';
import 'package:ma3arf/features/quiz/quiz_config_sheet.dart';
import 'package:ma3arf/features/quiz/quiz_screen.dart';

class SelectionScreen extends StatefulWidget {
  final GameState gameState;

  const SelectionScreen({super.key, required this.gameState});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  int _activeTab = 0; // 0: Difficulty, 1: Category
  String _selectedMode = 'difficulty';
  String _selectedValue = 'easy';
  String _selectedDisplayName = 'المبتدئ';

  // Cached category counts
  final Map<String, int> _categoryCounts = {};

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.gameState.selectedMode;
    _selectedValue = widget.gameState.selectedVal;
    if (_selectedMode == 'category') {
      _activeTab = 1;
      _selectedDisplayName = _selectedValue;
    } else {
      _activeTab = 0;
      _selectedDisplayName = difficultyNames[_selectedValue] ?? 'المبتدئ';
    }

    for (final q in allQuestions) {
      _categoryCounts[q.category] = (_categoryCounts[q.category] ?? 0) + 1;
    }
  }

  void _selectDifficulty(String val) {
    AudioFeedbackService.instance.playClick();
    setState(() {
      _selectedMode = 'difficulty';
      _selectedValue = val;
      _selectedDisplayName = difficultyNames[val] ?? val;
    });
  }

  void _selectCategory(String cat) {
    AudioFeedbackService.instance.playClick();
    setState(() {
      _selectedMode = 'category';
      _selectedValue = cat;
      _selectedDisplayName = cat;
    });
  }

  void _showFriendChallengeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            AppIcon(AppIcons.sahaba, color: const Color(0xFFD7B56D), size: 22),
            const SizedBox(width: 8),
            const Text('خوض تحدي صديق'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الصق كود التحدي (مثل: MA3ARF-1-5-12...) أو رابط التحدي لخوض نفس الأسئلة والخيارات تماماً والمنافسة عليها:',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'MA3ARF-1-2-3-4-5 أو الرابط',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          ElevatedButton(
            child: const Text('بدء التحدي'),
            onPressed: () {
              final raw = controller.text.trim();
              final qids = <int>[];
              final qidsMatch = RegExp(r'qids=([0-9,]+)').firstMatch(raw);
              if (qidsMatch != null) {
                final parts = qidsMatch.group(1)!.split(',');
                for (final p in parts) {
                  final n = int.tryParse(p.trim());
                  if (n != null) qids.add(n);
                }
              } else {
                final numbers = RegExp(r'\b\d+\b').allMatches(raw);
                for (final m in numbers) {
                  final n = int.tryParse(m.group(0)!);
                  if (n != null && n > 0 && n <= allQuestions.length) {
                    qids.add(n);
                  }
                }
              }

              if (qids.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال كود تحدٍ صالح')),
                );
                return;
              }

              Navigator.of(dialogCtx).pop();
              final started = widget.gameState.startFriendChallenge(
                questionIds: qids,
              );
              if (started) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => QuizScreen(gameState: widget.gameState),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _launchQuiz({QuizMode mode = QuizMode.challenge}) {
    AudioFeedbackService.instance.playClick();
    final gs = widget.gameState;
    final count = gs.requestedQuestionCount;
    gs.selectGameConfig(_selectedMode, _selectedValue, modeType: mode, count: count);
    final ready = gs.prepareQuizSession(count: count, mode: mode);
    if (ready) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizScreen(gameState: gs),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تجهيز أسئلة لهذا الاختيار')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appColors = theme.extension<AppColors>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: AppIcon(AppIcons.back, size: 22, matchTextDirection: true),
          tooltip: 'العودة للرئيسية',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('اختر طريقة اللعب والتعلم'),
        actions: [
          IconButton(
            tooltip: 'خوض تحدي صديق',
            icon: AppIcon(AppIcons.sahaba, size: 20),
            onPressed: () => _showFriendChallengeDialog(context),
          ),
          IconButton(
            tooltip: 'تخصيص الاختبار',
            icon: AppIcon(AppIcons.tune, size: 20),
            onPressed: () => QuizConfigSheet.show(context, widget.gameState),
          ),
          IconButton(
            tooltip: widget.gameState.isSoundEnabled
                ? 'كتم الصوت'
                : 'تفعيل الصوت',
            icon: AppIcon(
              widget.gameState.isSoundEnabled ? AppIcons.soundOn : AppIcons.soundOff,
              size: 20,
            ),
            onPressed: () => widget.gameState.toggleSound(),
          ),
        ],
      ),
      body: IslamicGeometricBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    Text(
                      'اختر الوضع الذي يناسب مستواك أو ركّز على تصنيف علمي محدد',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? const Color(0xFFA2B5AB) : const Color(0xFF5A6E65),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Tabs Header
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF13221C) : const Color(0xFFF6EFE2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF243B31)
                              : (appColors?.border ?? const Color(0xFFEADAA2)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TabButton(
                              label: 'أنماط الصعوبة',
                              icon: AppIcons.achievements,
                              isActive: _activeTab == 0,
                              onTap: () {
                                AudioFeedbackService.instance.playClick();
                                setState(() => _activeTab = 0);
                              },
                            ),
                          ),
                          Expanded(
                            child: _TabButton(
                              label: 'التصنيفات العلمية',
                              icon: AppIcons.quran,
                              isActive: _activeTab == 1,
                              onTap: () {
                                AudioFeedbackService.instance.playClick();
                                setState(() => _activeTab = 1);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _activeTab == 0
                    ? _buildDifficultyTab(theme, isDark)
                    : _buildCategoriesTab(theme, isDark),
              ),

              // Bottom Setup Summary Bar
              _buildSetupSummaryBar(theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyTab(ThemeData theme, bool isDark) {
    final diffs = [
      _DiffInfo(
        key: 'easy',
        title: 'المبتدئ',
        desc: 'أسئلة عامة وميسرة تناسب البدايات لتأسيس معرفي سليم.',
        meta: '20 ثانية / سؤال • 10 أسئلة',
        icon: AppIcons.beginner,
        color: const Color(0xFF2E8B68),
      ),
      _DiffInfo(
        key: 'medium',
        title: 'المتوسط',
        desc: 'تحديات معرفية تتطلب قراءة وإلمامًا بأساسيات العلوم الشرعية.',
        meta: '20 ثانية / سؤال • 15 سؤالاً',
        icon: AppIcons.intermediate,
        color: const Color(0xFF0D6EFD),
      ),
      _DiffInfo(
        key: 'hard',
        title: 'المتقدم',
        desc: 'أسئلة عميقة وتفصيلية في العقيدة، الفقه، والتاريخ الإسلامي.',
        meta: '15 ثانية / سؤال • 20 سؤالاً',
        icon: AppIcons.advanced,
        color: const Color(0xFFD7B56D),
      ),
      _DiffInfo(
        key: 'expert',
        title: 'الخبير',
        desc: 'تحدي النخبة! أسئلة دقيقة جداً للأئمة والباحثين وطلاب العلم الشرعي.',
        meta: '12 ثانية / سؤال • 25 سؤالاً',
        icon: AppIcons.expert,
        color: const Color(0xFFD9534F),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: diffs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final d = diffs[index];
        final isSelected = _selectedMode == 'difficulty' && _selectedValue == d.key;

        return Card(
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isDark ? const Color(0xFF243B31) : const Color(0xFFEADAA2)),
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.20 : 0.08)
              : (isDark ? const Color(0xFF13221C) : Colors.white),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _selectDifficulty(d.key),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: d.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: d.color.withValues(alpha: 0.4)),
                    ),
                    child: AppIcon(d.icon, color: d.color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              d.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? theme.colorScheme.primary : null,
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'المحدد',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.desc,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? const Color(0xFFA2B5AB) : const Color(0xFF5A6E65),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          d.meta,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFD7B56D) : const Color(0xFF9C793B),
                          ),
                        ),
                      ],
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

  Widget _buildCategoriesTab(ThemeData theme, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: categoryNames.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final cat = categoryNames[index];
        final count = _categoryCounts[cat] ?? 0;
        final isSelected = _selectedMode == 'category' && _selectedValue == cat;
        final icon = AppIcons.getCategoryIcon(cat);

        return Card(
          elevation: isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isDark ? const Color(0xFF243B31) : const Color(0xFFEADAA2)),
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.20 : 0.08)
              : (isDark ? const Color(0xFF13221C) : Colors.white),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _selectCategory(cat),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7B56D).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(icon, color: const Color(0xFFD7B56D), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? theme.colorScheme.primary : null,
                          ),
                        ),
                        Text(
                          '$count سؤالاً موثقاً',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: isDark ? const Color(0xFFA2B5AB) : const Color(0xFF5A6E65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    AppIcon(AppIcons.checkCircle, color: theme.colorScheme.primary, size: 22)
                  else
                    AppIcon(AppIcons.caretDown, color: theme.dividerColor, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSetupSummaryBar(ThemeData theme, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 420;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 16,
            vertical: isSmall ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1C17) : Colors.white,
            border: Border(
              top: BorderSide(
                color: isDark ? const Color(0xFF243B31) : const Color(0xFFEADAA2),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: isSmall
              ? Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'الخيار المحدد:',
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                          ),
                          Text(
                            _selectedDisplayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD7B56D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _launchQuiz(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(AppIcons.forward, size: 14, matchTextDirection: true),
                          const SizedBox(width: 4),
                          const Text(
                            'ابدأ رحلة السؤال',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'الخيار المحدد:',
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                          Text(
                            _selectedDisplayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD7B56D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: AppIcon(AppIcons.forward, size: 18, matchTextDirection: true),
                      label: const Text(
                        'ابدأ رحلة السؤال',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () => _launchQuiz(),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? theme.colorScheme.primary : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              icon,
              size: 15,
              color: isActive
                  ? (isDark ? Colors.white : theme.colorScheme.primary)
                  : (isDark ? Colors.white60 : Colors.black54),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive
                      ? (isDark ? Colors.white : theme.colorScheme.primary)
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiffInfo {
  final String key;
  final String title;
  final String desc;
  final String meta;
  final IconData icon;
  final Color color;

  _DiffInfo({
    required this.key,
    required this.title,
    required this.desc,
    required this.meta,
    required this.icon,
    required this.color,
  });
}

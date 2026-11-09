import 'package:flutter/material.dart';
import 'package:ma3arf/app.dart';
import 'package:ma3arf/core/services/audio_feedback_service.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/theme/app_theme.dart';
import 'package:ma3arf/core/widgets/app_footer.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_dome_art.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:ma3arf/features/favorites/favorites_screen.dart';
import 'package:ma3arf/features/feedback/feedback_dialog.dart';
import 'package:ma3arf/features/home/selection_screen.dart';
import 'package:ma3arf/features/leaderboard/leaderboard_screen.dart';
import 'package:ma3arf/features/privacy/privacy_policy_screen.dart';
import 'package:ma3arf/features/profile/profile_switch_dialog.dart';
import 'package:ma3arf/features/quiz/quiz_screen.dart';
import 'package:ma3arf/features/review/mistakes_review_screen.dart';
import 'package:ma3arf/features/search/search_screen.dart';
import 'package:ma3arf/features/stats/stats_dialog.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _isWisdomExpanded = false;
  int _currentNavIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToSelection(BuildContext context, GameState gameState) {
    AudioFeedbackService.instance.playClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectionScreen(gameState: gameState),
      ),
    );
  }

  void _startLearningMode(BuildContext context, GameState gameState) {
    AudioFeedbackService.instance.playClick();
    gameState.selectGameConfig('all', 'all', modeType: QuizMode.learning, count: 10);
    final ready = gameState.prepareQuizSession(count: 10, mode: QuizMode.learning);
    if (ready) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizScreen(gameState: gameState),
        ),
      );
    }
  }

  void _startDailyChallenge(BuildContext context, GameState gameState) {
    AudioFeedbackService.instance.playClick();
    gameState.selectGameConfig('daily', 'daily');
    final ready = gameState.prepareQuizSession(
      count: 5,
      mode: QuizMode.challenge,
    );
    if (ready) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizScreen(gameState: gameState),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appColors = theme.extension<AppColors>();
    final gameState = GameStateScope.of(context);
    final profile = gameState.profile;
    final currentLevel = getCurrentLevel(profile.totalXp);
    final levelProgress = getLevelProgress(profile.totalXp);
    final todayWisdom = gameState.todayKnowledgeQuestion;
    final isWisdomFav = gameState.isFavorite(todayWisdom.id);
    final hasMistakes = gameState.mistakeQuestionIds.isNotEmpty;
    final favCount = gameState.favoriteQuestionIds.length;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                AppIcons.mosque,
                size: 18,
                color: const Color(0xFFD7B56D),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'مَعارِف',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'المنصة التعليمية الإسلامية',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: isDark ? const Color(0xFFA2B5AB) : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Sound toggle button
          IconButton(
            tooltip: gameState.isSoundEnabled
                ? 'كتم المؤثرات الصوتية'
                : 'تفعيل المؤثرات الصوتية',
            icon: AppIcon(
              gameState.isSoundEnabled ? AppIcons.soundOn : AppIcons.soundOff,
              size: 20,
            ),
            onPressed: () => gameState.toggleSound(),
          ),
          // Stats button
          IconButton(
            tooltip: 'الإحصائيات والأوسمة',
            icon: AppIcon(AppIcons.stats, size: 20),
            onPressed: () => StatsDialog.show(context, gameState),
          ),
          // Search button
          IconButton(
            tooltip: 'البحث في المعارف',
            icon: AppIcon(AppIcons.search, size: 20),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SearchScreen(gameState: gameState),
                ),
              );
            },
          ),
          // More menu
          PopupMenuButton<String>(
            icon: AppIcon(AppIcons.moreVertical, size: 20),
            tooltip: 'المزيد',
            onSelected: (value) {
              switch (value) {
                case 'leaderboard':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => LeaderboardScreen(gameState: gameState),
                    ),
                  );
                  break;
                case 'favorites':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => FavoritesScreen(gameState: gameState),
                    ),
                  );
                  break;
                case 'feedback':
                  FeedbackDialog.show(context);
                  break;
                case 'privacy':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => const PrivacyPolicyScreen(),
                    ),
                  );
                  break;
                case 'theme':
                  Ma3arfApp.of(context)?.toggleTheme();
                  break;
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'leaderboard',
                child: Row(
                  children: [
                    AppIcon(AppIcons.leaderboard, size: 18),
                    const SizedBox(width: 8),
                    const Text('لوحة المتصدرين'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'favorites',
                child: Row(
                  children: [
                    AppIcon(AppIcons.bookmark, color: const Color(0xFFD7B56D), size: 18),
                    const SizedBox(width: 8),
                    Text('المفضلة ($favCount)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'feedback',
                child: Row(
                  children: [
                    AppIcon(AppIcons.feedback, color: const Color(0xFF2E8B68), size: 18),
                    const SizedBox(width: 8),
                    const Text('ساهم في تطوير مَعارِف'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'privacy',
                child: Row(
                  children: [
                    AppIcon(AppIcons.shieldCheck, color: const Color(0xFFD7B56D), size: 18),
                    const SizedBox(width: 8),
                    const Text('سياسة الخصوصية'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'theme',
                child: Row(
                  children: [
                    AppIcon(
                      isDark ? AppIcons.themeLight : AppIcons.themeDark,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(isDark ? 'الوضع النهاري' : 'الوضع الليلي'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IslamicGeometricBackground(
        child: SafeArea(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 12, bottom: 0),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ==========================================
                    // 1. HERO SECTION (Matching Reference Website)
                    // ==========================================
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF243B31)
                        : (appColors?.border ?? const Color(0xFFEADAA2)),
                    width: 1.2,
                  ),
                ),
                color: isDark ? const Color(0xFF13221C) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  child: Column(
                    children: [
                      // Floating Islamic Dome Art
                      const IslamicDomeArt(width: 150, height: 110),
                      const SizedBox(height: 14),

                      // Hero Title
                      Text(
                        'اختبر معلوماتك الإسلامية',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? const Color(0xFFD7B56D)
                              : theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Hero Subtitle
                      Text(
                        'رحلة معرفية وإيمانية لاختبار معلوماتك وتوسيع مداركك في رحاب العلوم الشرعية والقرآنية بأسلوب تفاعلي راقٍ.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? const Color(0xFFA2B5AB) : const Color(0xFF5A6E65),
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),

                      // Quick Stats Row (الاختبارات المكتملة + أعلى نتيجة)
                      Row(
                        children: [
                          Expanded(
                            child: _HeroStatBox(
                              value: '${profile.totalQuizzes}',
                              label: 'الاختبارات المكتملة',
                              theme: theme,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _HeroStatBox(
                              value: '${profile.bestScorePercent}%',
                              label: 'أعلى نتيجة',
                              theme: theme,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Main CTA Button: ابدأ الاختبار
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: AppIcon(
                            AppIcons.forward,
                            size: 18,
                            matchTextDirection: true,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'ابدأ الاختبار',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => _navigateToSelection(context, gameState),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 2. USER LEVEL & XP PROGRESS CARD
              // ==========================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: isDark
                        ? const Color(0xFF243B31)
                        : (appColors?.border ?? const Color(0xFFEADAA2)),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Avatar with level badge
                      InkWell(
                        onTap: () => ProfileSwitchDialog.show(context, gameState),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                            ),
                          ),
                          child: AppIcon(currentLevel.icon, size: 24, color: AppGold.rich),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: InkWell(
                                    onTap: () => ProfileSwitchDialog.show(context, gameState),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            profile.displayName,
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        AppIcon(
                                          AppIcons.caretDown,
                                          size: 14,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${profile.totalXp} XP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: theme.colorScheme.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'المستوى: ${currentLevel.name}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? const Color(0xFFA2B5AB) : Colors.black54,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: levelProgress,
                                minHeight: 6,
                                backgroundColor: theme.dividerColor.withValues(alpha: 0.25),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==========================================
              // 3. DAILY CHALLENGE BANNER
              // ==========================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  ),
                ),
                color: isDark ? const Color(0xFF162B21) : const Color(0xFFEBF6F0),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      AppIconContainer(
                        icon: AppIcons.dailyChallenge,
                        size: 44,
                        iconSize: 22,
                        iconColor: const Color(0xFFD7B56D),
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                        borderColor: const Color(0xFFD7B56D).withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'تحدي اليوم المعرفي',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD7B56D),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '+100 XP',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              gameState.isTodayDailyCompleted
                                  ? 'أحسنت! أتممت تحدي اليوم (${gameState.todayDailyScore}%)'
                                  : '5 أسئلة متجددة يومياً لاختبار معلوماتك',
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () => _startDailyChallenge(context, gameState),
                        child: Text(gameState.isTodayDailyCompleted ? 'إعادة' : 'ابدأ'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==========================================
              // 4. DAILY WISDOM CARD ("معلومة اليوم")
              // ==========================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFFD7B56D).withValues(alpha: 0.35),
                  ),
                ),
                color: isDark ? const Color(0xFF13221C) : const Color(0xFFFBF8F0),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppIcon(
                            AppIcons.wisdom,
                            color: const Color(0xFFD7B56D),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'معلومة اليوم المباركة',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD7B56D),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                            icon: AppIcon(
                              isWisdomFav ? AppIcons.starFilled : AppIcons.star,
                              color: isWisdomFav
                                  ? const Color(0xFFD7B56D)
                                  : theme.iconTheme.color,
                              size: 18,
                            ),
                            tooltip: 'حفظ المعلومة',
                            onPressed: () async {
                              await gameState.toggleFavorite(todayWisdom.id);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        todayWisdom.question,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      if (_isWisdomExpanded) ...[
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الصواب: ${todayWisdom.choices[todayWisdom.correct]}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                todayWisdom.explanation,
                                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                              ),
                              if (todayWisdom.source.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'المصدر: ${todayWisdom.source}',
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
                      ],
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: AppIcon(
                            _isWisdomExpanded ? AppIcons.caretDown : AppIcons.caretDown,
                            size: 14,
                          ),
                          label: Text(
                            _isWisdomExpanded ? 'إخفاء الشرح' : 'اطّلع على الإجابة والشرح',
                            style: const TextStyle(fontSize: 11),
                          ),
                          onPressed: () => setState(
                            () => _isWisdomExpanded = !_isWisdomExpanded,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ==========================================
              // 5. QUICK MOBILE ACCELERATORS
              // ==========================================
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'جلسة تدبّر',
                      subtitle: 'بدون مؤقت',
                      icon: AppIcons.learningMode,
                      color: const Color(0xFF2E8B68),
                      onTap: () => _startLearningMode(context, gameState),
                      theme: theme,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'مراجعة الأخطاء',
                      subtitle: hasMistakes
                          ? '${gameState.mistakeQuestionIds.length} سؤال للتصحيح'
                          : 'سجلّك خالٍ',
                      icon: AppIcons.mistakesReview,
                      color: hasMistakes ? const Color(0xFFD9534F) : const Color(0xFFD7B56D),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => MistakesReviewScreen(gameState: gameState),
                          ),
                        );
                      },
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
                    child: _QuickActionCard(
                      title: 'الأسئلة المفضلة',
                      subtitle: favCount > 0 ? '$favCount محفوظة' : 'فارغة',
                      icon: AppIcons.favorites,
                      color: const Color(0xFF3F8CFF),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => FavoritesScreen(gameState: gameState),
                          ),
                        );
                      },
                      theme: theme,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'البحث في المعارف',
                      subtitle: '1000 سؤال موثق',
                      icon: AppIcons.search,
                      color: const Color(0xFFD7B56D),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => SearchScreen(gameState: gameState),
                          ),
                        );
                      },
                      theme: theme,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const AppFooter(),
      ],
    ),
  ),
),
      bottomNavigationBar: _buildBottomNav(context, gameState, theme, isDark),
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    GameState gameState,
    ThemeData theme,
    bool isDark,
  ) {
    final navBg = isDark ? const Color(0xFF0F261E) : const Color(0xFFF7F2E9);

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF243B31)
                : const Color(0xFFE2D6C3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: AppIcons.home,
                label: 'الرئيسية',
                isSelected: _currentNavIndex == 0,
                onTap: () {
                  setState(() => _currentNavIndex = 0);
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
              ),
              _buildNavItem(
                index: 1,
                icon: AppIcons.search,
                label: 'البحث',
                isSelected: _currentNavIndex == 1,
                onTap: () {
                  AudioFeedbackService.instance.playClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => SearchScreen(gameState: gameState),
                    ),
                  );
                },
              ),
              _buildNavItem(
                index: 2,
                icon: AppIcons.calendar,
                label: 'اليومي',
                isSelected: _currentNavIndex == 2,
                onTap: () {
                  _startDailyChallenge(context, gameState);
                },
              ),
              _buildNavItem(
                index: 3,
                icon: AppIcons.heart,
                label: 'المفضلة',
                isSelected: _currentNavIndex == 3,
                onTap: () {
                  AudioFeedbackService.instance.playClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => FavoritesScreen(gameState: gameState),
                    ),
                  );
                },
              ),
              _buildNavItem(
                index: 4,
                icon: AppIcons.stats,
                label: 'الإحصائيات',
                isSelected: _currentNavIndex == 4,
                onTap: () {
                  AudioFeedbackService.instance.playClick();
                  StatsDialog.show(context, gameState);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const goldColor = Color(0xFFD7B56D);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor =
        isDark ? const Color(0xFF7A9488) : const Color(0xFF6B7E75);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              icon,
              size: 21,
              color: isSelected ? goldColor : unselectedColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? goldColor : unselectedColor,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroStatBox extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;
  final bool isDark;

  const _HeroStatBox({
    required this.value,
    required this.label,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF192C23) : const Color(0xFFF6EFE2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? const Color(0xFF243B31)
              : const Color(0xFFEADAA2).withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFFD7B56D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: isDark ? const Color(0xFFA2B5AB) : const Color(0xFF5A6E65),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isDark;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: isDark ? const Color(0xFFA2B5AB) : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/core/widgets/islamic_pattern.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:ma3arf/features/profile/profile_switch_dialog.dart';

class LeaderboardScreen extends StatefulWidget {
  final GameState gameState;

  const LeaderboardScreen({super.key, required this.gameState});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gs = widget.gameState;
    final entries = gs.leaderboardEntries;

    // Filter by difficulty if set
    final filtered = entries.where((e) {
      if (_selectedDifficulty == null) return true;
      return e.difficulty == _selectedDifficulty;
    }).toList();

    // Top results: sort by accuracy desc, then score desc
    final topResults = List<LeaderboardEntry>.from(filtered)
      ..sort((a, b) {
        final accCmp = b.accuracy.compareTo(a.accuracy);
        if (accCmp != 0) return accCmp;
        return b.score.compareTo(a.score);
      });

    // Recent results: sort by date desc
    final recentResults = List<LeaderboardEntry>.from(filtered)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Profiles comparison: sort by totalXp desc
    final profiles = List<UserProfile>.from(gs.localProfiles)
      ..sort((a, b) => b.totalXp.compareTo(a.totalXp));

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المتصدرين المحلية'),
        actions: [
          IconButton(
            tooltip: 'تبديل الملف الشخصي',
            icon: AppIcon(AppIcons.switchProfile, size: 22),
            onPressed: () {
              ProfileSwitchDialog.show(context, gs);
              setState(() {});
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.secondary,
          tabs: const [
            Tab(text: 'أفضل النتائج'),
            Tab(text: 'أحدث النتائج'),
            Tab(text: 'مقارنة الأفراد'),
          ],
        ),
      ),
      body: IslamicGeometricBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Local Notice Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: isDark
                    ? const Color(0xFF13221C)
                    : const Color(0xFFFBF8F0),
                child: Row(
                  children: [
                    AppIcon(AppIcons.stats, size: 16, color: Color(0xFFD7B56D)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سجل محلي خاص بهذا الجهاز لتشجيع أفراد العائلة ومتابعة التقدم.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFFA2B5AB)
                              : const Color(0xFF5A6E65),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Difficulty Filter Chips (for Top & Recent tabs)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(
                        label: const Text(
                          'الكل',
                          style: TextStyle(fontSize: 11),
                        ),
                        selected: _selectedDifficulty == null,
                        onSelected: (_) =>
                            setState(() => _selectedDifficulty = null),
                      ),
                      const SizedBox(width: 8),
                      ...difficultyNames.entries.map((e) {
                        final isSelected = _selectedDifficulty == e.key;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(
                              e.value,
                              style: const TextStyle(fontSize: 11),
                            ),
                            selected: isSelected,
                            onSelected: (_) => setState(
                              () => _selectedDifficulty = isSelected
                                  ? null
                                  : e.key,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Top Results
                    topResults.isEmpty
                        ? _buildEmptyState(
                            theme,
                            'لا توجد نتائج مسجلة بعد في هذا المستوى',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: topResults.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (ctx, i) => _buildLeaderboardTile(
                              rank: i + 1,
                              entry: topResults[i],
                              theme: theme,
                              isDark: isDark,
                            ),
                          ),

                    // Tab 2: Recent Results
                    recentResults.isEmpty
                        ? _buildEmptyState(
                            theme,
                            'لم يتم إجراء أي اختبارات مؤخراً',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: recentResults.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (ctx, i) => _buildLeaderboardTile(
                              rank: i + 1,
                              entry: recentResults[i],
                              theme: theme,
                              isDark: isDark,
                              showDate: true,
                            ),
                          ),

                    // Tab 3: Profiles Comparison
                    ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: profiles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) => _buildProfileComparisonCard(
                        rank: i + 1,
                        profile: profiles[i],
                        isCurrent: profiles[i].id == gs.profile.id,
                        theme: theme,
                        isDark: isDark,
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
  }

  Widget _buildLeaderboardTile({
    required int rank,
    required LeaderboardEntry entry,
    required ThemeData theme,
    required bool isDark,
    bool showDate = false,
  }) {
    IconData? rankIcon;
    Color rankColor;
    if (rank == 1) {
      rankIcon = AppIcons.getRankIcon(1);
      rankColor = const Color(0xFFD7B56D);
    } else if (rank == 2) {
      rankIcon = AppIcons.getRankIcon(2);
      rankColor = const Color(0xFFC0C0C0);
    } else if (rank == 3) {
      rankIcon = AppIcons.getRankIcon(3);
      rankColor = const Color(0xFFCD7F32);
    } else {
      rankIcon = null;
      rankColor = theme.dividerColor;
    }

    return Card(
      elevation: rank <= 3 ? 2.5 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: rank == 1
              ? const Color(0xFFD7B56D).withValues(alpha: 0.6)
              : theme.dividerColor.withValues(alpha: isDark ? 0.2 : 0.4),
          width: rank == 1 ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Rank Icon / Number
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rankColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: rankIcon != null
                  ? AppIcon(rankIcon, size: 18, color: rankColor)
                  : Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Profile & Category Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        entry.profileName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          difficultyNames[entry.difficulty] ?? entry.difficulty,
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.category} • ${entry.totalQuestions} أسئلة',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),

            // Score and Accuracy
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.accuracy}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: entry.accuracy >= 80
                        ? const Color(0xFF2E8B68)
                        : const Color(0xFFD7B56D),
                  ),
                ),
                Text(
                  '+${entry.score} XP',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileComparisonCard({
    required int rank,
    required UserProfile profile,
    required bool isCurrent,
    required ThemeData theme,
    required bool isDark,
  }) {
    return Card(
      elevation: isCurrent ? 3 : 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCurrent
              ? theme.colorScheme.secondary
              : theme.dividerColor.withValues(alpha: 0.3),
          width: isCurrent ? 1.6 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isCurrent
                  ? theme.colorScheme.secondary.withValues(alpha: 0.25)
                  : theme.dividerColor.withValues(alpha: 0.3),
              child: profile.displayName.isNotEmpty
                  ? Text(
                      profile.displayName[0],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? theme.colorScheme.secondary : null,
                      ),
                    )
                  : AppIcon(
                      AppIcons.profile,
                      size: 20,
                      color: isCurrent ? theme.colorScheme.secondary : null,
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        profile.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 6),
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
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.totalQuizzes} اختبار مكتمل • أعلى دقة: ${profile.bestScorePercent}%',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${profile.totalXp} XP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                Text(
                  getCurrentLevel(profile.totalXp).name,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const IslamicStarPattern(
              size: 80,
              color: Color(0xFFD7B56D),
              opacity: 0.25,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج مسجلة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

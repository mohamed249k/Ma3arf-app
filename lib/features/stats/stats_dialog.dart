import 'package:flutter/material.dart' hide Badge;
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/theme/app_theme.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:ma3arf/data/game_config.dart';

class StatsDialog extends StatelessWidget {
  final GameState gameState;

  const StatsDialog({super.key, required this.gameState});

  static Future<void> show(BuildContext context, GameState gameState) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatsDialog(gameState: gameState),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>();
    final profile = gameState.profile;
    final currentLevel = getCurrentLevel(profile.totalXp);
    final nextLevel = getNextLevel(profile.totalXp);
    final progress = getLevelProgress(profile.totalXp);
    final accuracy = profile.totalQuestionsAnswered > 0
        ? ((profile.totalCorrectAnswers / profile.totalQuestionsAnswered) * 100)
              .round()
        : 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  AppIcon(AppIcons.stats, size: 24, color: AppGold.rich),
                  const SizedBox(width: 8),
                  Text(
                    'لوحة الإحصائيات والأوسمة',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: AppIcon(AppIcons.close, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Level and XP Card
                  Card(
                    color: appColors?.bgSecondary ?? theme.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: AppIcon(
                                  currentLevel.icon,
                                  size: 28,
                                  color: AppGold.rich,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'المستوى: ${currentLevel.name}',
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${profile.totalXp} نقطة خبرة (XP)',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 10,
                              backgroundColor: theme.dividerColor.withValues(
                                alpha: 0.3,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${profile.totalXp} XP',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                currentLevel == nextLevel
                                    ? 'الحد الأقصى للمستوى'
                                    : 'التالي: ${nextLevel.name} (${nextLevel.minXp} XP)',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text('سجل الإنجازات', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: AppIcons.quiz,
                          title: 'الاختبارات',
                          value: '${profile.totalQuizzes}',
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: AppIcons.checkCircle,
                          title: 'إجابات صحيحة',
                          value: '${profile.totalCorrectAnswers}',
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: AppIcons.badge,
                          title: 'أعلى نتيجة',
                          value: '${profile.bestScorePercent}%',
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: AppIcons.percent,
                          title: 'دقة الإجابات',
                          value: '$accuracy%',
                          theme: theme,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الأوسمة والشارات',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        '${profile.unlockedBadges.length} من ${allBadges.length}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Badges list
                  for (final badge in allBadges)
                    _BadgeTile(
                      badge: badge,
                      isUnlocked: profile.unlockedBadges.contains(badge.id),
                      theme: theme,
                    ),

                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                    icon: AppIcon(AppIcons.delete, size: 20),
                    label: const Text('إعادة تعيين كافة البيانات'),
                    onPressed: () => _confirmReset(context),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('تأكيد إعادة التعيين'),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف كافة نقاط الخبرة والأوسمة والإحصائيات المسجلة؟ لن يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('تأكيد الحذف'),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await gameState.resetAllData();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تمت إعادة تعيين البيانات بنجاح'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final ThemeData theme;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcon(icon, color: theme.colorScheme.primary, size: 22),
            const SizedBox(height: 6),
            Text(value, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 2),
            Text(title, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final Badge badge;
  final bool isUnlocked;
  final ThemeData theme;

  const _BadgeTile({
    required this.badge,
    required this.isUnlocked,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isUnlocked
          ? theme.cardColor
          : theme.disabledColor.withValues(alpha: 0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUnlocked
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.disabledColor.withValues(alpha: 0.1),
          child: isUnlocked
              ? AppIcon(badge.icon, size: 20, color: theme.colorScheme.primary)
              : AppIcon(AppIcons.lock, size: 20, color: theme.disabledColor),
        ),
        title: Text(
          badge.name,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isUnlocked ? null : theme.disabledColor,
            fontWeight: isUnlocked ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          badge.desc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isUnlocked ? null : theme.disabledColor,
          ),
        ),
        trailing: isUnlocked
            ? AppIcon(AppIcons.checkCircle, color: Color(0xFF198754), size: 20)
            : null,
      ),
    );
  }
}

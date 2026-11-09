import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma3arf/core/theme/app_icons.dart';
import 'package:ma3arf/core/theme/app_theme.dart';
import 'package:ma3arf/core/widgets/app_icon.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  group('Centralized AppIcon and AppIcons Integrity Tests', () {
    test('All semantic AppIcons getters are non-null IconData', () {
      final icons = [
        AppIcons.back,
        AppIcons.forward,
        AppIcons.close,
        AppIcons.check,
        AppIcons.checkCircle,
        AppIcons.xCircle,
        AppIcons.dailyChallenge,
        AppIcons.learningMode,
        AppIcons.mistakesReview,
        AppIcons.favorites,
        AppIcons.search,
        AppIcons.questionBank,
        AppIcons.leaderboard,
        AppIcons.achievements,
        AppIcons.stats,
        AppIcons.progress,
        AppIcons.history,
        AppIcons.settings,
        AppIcons.profile,
        AppIcons.switchProfile,
        AppIcons.feedback,
        AppIcons.lock,
        AppIcons.lockOpen,
        AppIcons.soundOn,
        AppIcons.soundOff,
        AppIcons.themeLight,
        AppIcons.themeDark,
        AppIcons.timer,
        AppIcons.star,
        AppIcons.starFilled,
        AppIcons.share,
        AppIcons.copy,
        AppIcons.send,
        AppIcons.save,
        AppIcons.help,
        AppIcons.info,
        AppIcons.wisdom,
        AppIcons.verified,
        AppIcons.mosque,
        AppIcons.kaaba,
        AppIcons.quran,
        AppIcons.hadith,
        AppIcons.prophets,
        AppIcons.sahaba,
        AppIcons.aqeedah,
        AppIcons.fiqh,
        AppIcons.ethics,
        AppIcons.generalIslamic,
        AppIcons.beginner,
        AppIcons.intermediate,
        AppIcons.advanced,
        AppIcons.expert,
        AppIcons.edit,
        AppIcons.delete,
        AppIcons.userAdd,
        AppIcons.play,
        AppIcons.flag,
        AppIcons.plus,
        AppIcons.quiz,
        AppIcons.badge,
        AppIcons.percent,
        AppIcons.tune,
        AppIcons.target,
      ];

      for (final icon in icons) {
        expect(icon, isNotNull);
        expect(icon.codePoint, greaterThan(0));
      }
    });

    test('Semantic category mapping covers all categories', () {
      const categories = [
        'القرآن الكريم',
        'الحديث الشريف',
        'السيرة النبوية',
        'قصص الأنبياء',
        'الصحابة',
        'العقيدة',
        'الفقه',
        'الأخلاق الإسلامية',
        'العبادات',
        'معلومات إسلامية عامة',
      ];

      for (final cat in categories) {
        final icon = AppIcons.getCategoryIcon(cat);
        expect(icon, isNotNull);
      }
    });

    test('Semantic difficulty mapping covers all 4 difficulties', () {
      for (final diff in ['easy', 'medium', 'hard', 'expert']) {
        final icon = AppIcons.getDifficultyIcon(diff);
        expect(icon, isNotNull);
      }
    });

    testWidgets('AppIcon and AppIconContainer widget rendering test', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Column(
              children: [
                AppIcon(AppIcons.dailyChallenge, size: AppIconSize.large),
                AppIcon(AppIcons.quran, size: AppIconSize.medium),
                AppIcon(AppIcons.mosque, size: AppIconSize.feature),
                AppIconContainer(icon: AppIcons.leaderboard, size: 48),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppIcon), findsWidgets);
      expect(find.byType(AppIconContainer), findsOneWidget);
      expect(find.byType(PhosphorIcon), findsWidgets);
      expect(find.byType(FaIcon), findsWidgets);
    });
  });
}

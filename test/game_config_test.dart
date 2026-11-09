import 'package:flutter_test/flutter_test.dart';
import 'package:ma3arf/data/game_config.dart';

void main() {
  group('GameConfig Level & XP Logic Tests', () {
    test('levelConfigs should be ordered by minXp ascending', () {
      for (int i = 0; i < levelConfigs.length - 1; i++) {
        expect(
          levelConfigs[i].minXp < levelConfigs[i + 1].minXp,
          isTrue,
          reason: 'levelConfigs should have strictly increasing minXp',
        );
      }
    });

    test('getCurrentLevel returns correct level based on XP', () {
      expect(getCurrentLevel(0).name, equals('المبتدئ'));
      expect(getCurrentLevel(50).name, equals('المبتدئ'));
      expect(getCurrentLevel(100).name, equals('المبادر'));
      expect(getCurrentLevel(200).name, equals('المبادر'));
      expect(getCurrentLevel(250).name, equals('المتوسط'));
      expect(getCurrentLevel(500).name, equals('المتقدم'));
      expect(getCurrentLevel(1000).name, equals('الخبير'));
      expect(getCurrentLevel(2000).name, equals('العالم الأثري'));
      expect(getCurrentLevel(5000).name, equals('العالم الأثري'));
    });

    test('getNextLevel returns the immediately higher level', () {
      expect(getNextLevel(0).name, equals('المبادر'));
      expect(getNextLevel(50).name, equals('المبادر'));
      expect(getNextLevel(100).name, equals('المتوسط'));
      expect(getNextLevel(250).name, equals('المتقدم'));
      expect(getNextLevel(500).name, equals('الخبير'));
      expect(getNextLevel(1000).name, equals('العالم الأثري'));
      // At max level, returns current level
      expect(getNextLevel(2000).name, equals('العالم الأثري'));
      expect(getNextLevel(5000).name, equals('العالم الأثري'));
    });

    test(
      'getLevelProgress calculates proportional progress between 0.0 and 1.0',
      () {
        // At 0 XP: progress towards 100 XP is 0.0
        expect(getLevelProgress(0), equals(0.0));
        // At 50 XP: half-way between 0 and 100
        expect(getLevelProgress(50), closeTo(0.5, 0.001));
        // At 100 XP: start of المبادر (100 to 250) -> progress is 0.0
        expect(getLevelProgress(100), equals(0.0));
        // At 175 XP: midway between 100 and 250
        expect(getLevelProgress(175), closeTo(0.5, 0.001));
        // At or beyond max level: progress should be 1.0
        expect(getLevelProgress(2000), equals(1.0));
        expect(getLevelProgress(5000), equals(1.0));
      },
    );

    test('allBadges contains required badges', () {
      final badgeIds = allBadges.map((b) => b.id).toSet();
      expect(
        badgeIds,
        containsAll([
          'first_quiz',
          'perfect_score',
          'hard_core',
          'hadith_streak',
          'quran_streak',
          'xp_master',
        ]),
      );
    });

    test('difficulty maps are consistent and non-empty', () {
      const keys = ['easy', 'medium', 'hard', 'expert'];
      for (final key in keys) {
        expect(difficultyNames[key], isNotNull);
        expect(difficultyTimers[key], greaterThan(0));
        expect(difficultyQuestionCounts[key], greaterThan(0));
        expect(difficultyPoints[key], greaterThan(0));
      }
    });
  });
}

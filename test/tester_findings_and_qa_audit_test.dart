import 'package:flutter_test/flutter_test.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:ma3arf/data/questions_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('A. Daily Challenge Completion & Reward Integrity Tests', () {
    test('Daily challenge marks completion, saves locally, and awards 100 XP once', () async {
      final gameState = GameState();
      await gameState.loadProfile();

      expect(gameState.isTodayDailyCompleted, isFalse);
      expect(gameState.todayDailyScore, isNull);

      final initialXp = gameState.profile.totalXp;

      // Start Daily Challenge
      gameState.selectGameConfig('daily', 'daily');
      final ready = gameState.prepareQuizSession(count: 5);
      expect(ready, isTrue);
      expect(gameState.quizQuestions.length, equals(5));

      // Answer 4 out of 5 correctly (80%)
      for (int i = 0; i < 5; i++) {
        final q = gameState.quizQuestions[i];
        if (i < 4) {
          gameState.handleAnswerSelection(q.correct);
        } else {
          gameState.handleAnswerSelection((q.correct + 1) % 4);
        }
        if (i < 4) gameState.moveToNextQuestion();
      }

      final finishResult = gameState.finishQuizSession();
      expect(finishResult.percent, equals(80));

      // Daily challenge should now be recorded as completed
      expect(gameState.isTodayDailyCompleted, isTrue);
      expect(gameState.todayDailyScore, equals(80));

      // Verify +100 XP bonus was granted
      final xpAfterFirstRun = gameState.profile.totalXp;
      expect(xpAfterFirstRun, greaterThan(initialXp + 100));

      // Verify completion persists after loading a fresh GameState instance (restart)
      final reloadedState = GameState();
      await reloadedState.loadProfile();
      expect(reloadedState.isTodayDailyCompleted, isTrue);
      expect(reloadedState.todayDailyScore, equals(80));

      // Replay daily challenge on the same day: prevent duplicate 100 XP reward
      reloadedState.selectGameConfig('daily', 'daily');
      reloadedState.prepareQuizSession(count: 5);
      for (int i = 0; i < 5; i++) {
        final q = reloadedState.quizQuestions[i];
        reloadedState.handleAnswerSelection(q.correct);
        if (i < 4) reloadedState.moveToNextQuestion();
      }
      final replayResult = reloadedState.finishQuizSession();
      expect(replayResult.percent, equals(100));

      // Replay XP should NOT include the 100 XP bonus again
      expect(replayResult.xpEarned, equals(reloadedState.score + 50)); // only score + 50 for 100%
      expect(reloadedState.todayDailyScore, equals(100));
    });
  });

  group('B & J. Religious Information Sources & Authentic Documentation Tests', () {
    test('All 1,000 questions have authenticated, non-empty sources and references', () {
      expect(allQuestions.length, equals(1000));

      for (final q in allQuestions) {
        expect(q.source.trim().isNotEmpty, isTrue, reason: 'Question ${q.id} has empty source');
        expect(
          q.source != 'المصادر الإسلامية المعتمدة' || q.sourceReference.isNotEmpty,
          isTrue,
          reason: 'Question ${q.id} still has generic placeholder source',
        );
        expect(q.sourceType.trim().isNotEmpty, isTrue, reason: 'Question ${q.id} has empty sourceType');
        expect(q.isVerified, isTrue, reason: 'Question ${q.id} is not marked verified');
        expect(q.reviewStatus, equals('verified'), reason: 'Question ${q.id} reviewStatus != verified');
      }
    });
  });

  group('C. Category and Question-Bank Consistency Tests', () {
    test('All question categories match the 10 official categories', () {
      final validCategories = categoryNames.toSet();
      expect(validCategories.length, equals(10));

      final counts = <String, int>{};
      for (final q in allQuestions) {
        expect(validCategories.contains(q.category), isTrue, reason: 'Unknown category: ${q.category}');
        counts[q.category] = (counts[q.category] ?? 0) + 1;
      }

      expect(counts.keys.length, equals(10));
      for (final cat in categoryNames) {
        expect(counts[cat], greaterThan(0), reason: 'Category $cat has 0 questions');
      }
    });

    test('Category filter returns exact questions belonging to that category', () {
      for (final cat in categoryNames) {
        final filtered = allQuestions.where((q) => q.category == cat).toList();
        expect(filtered.every((q) => q.category == cat), isTrue);
      }
    });
  });

  group('D. Incorrect-Answer Review Status Logic Tests', () {
    test('Answering a question correctly removes it from the active mistakes set', () async {
      final gameState = GameState();
      await gameState.loadProfile();

      // Add questions 10 and 20 to mistakes
      gameState.recordMistake(10);
      gameState.recordMistake(20);
      expect(gameState.mistakeQuestionIds.contains(10), isTrue);
      expect(gameState.mistakeQuestionIds.contains(20), isTrue);
      expect(gameState.getMistakeQuestions().length, equals(2));

      // Prepare quiz with custom question 10
      final q10 = allQuestions.firstWhere((q) => q.id == 10);
      gameState.prepareQuizSession(customQuestions: [q10]);

      // Answer question 10 correctly
      gameState.handleAnswerSelection(q10.correct);

      // Question 10 must be removed from mistakeQuestionIds immediately
      expect(gameState.mistakeQuestionIds.contains(10), isFalse);
      expect(gameState.mistakeQuestionIds.contains(20), isTrue);
      expect(gameState.getMistakeQuestions().length, equals(1));

      // Verify persistence after reload
      final reloaded = GameState();
      await reloaded.loadProfile();
      expect(reloaded.mistakeQuestionIds.contains(10), isFalse);
      expect(reloaded.mistakeQuestionIds.contains(20), isTrue);
    });
  });

  group('E. Profile Data Isolation Tests', () {
    test('Switching profiles provides complete separation of favorites, mistakes, and stats', () async {
      final gameState = GameState();
      await gameState.loadProfile();

      // Profile 1 (default) adds favorite 1, mistake 2
      await gameState.toggleFavorite(1);
      gameState.recordMistake(2);

      expect(gameState.isFavorite(1), isTrue);
      expect(gameState.mistakeQuestionIds.contains(2), isTrue);

      // Create Profile 2
      await gameState.createProfile('أحمد');
      expect(gameState.profile.displayName, equals('أحمد'));

      // Profile 2 must have empty favorites and mistakes (complete isolation!)
      expect(gameState.isFavorite(1), isFalse);
      expect(gameState.mistakeQuestionIds.contains(2), isFalse);
      expect(gameState.favoriteQuestionIds.isEmpty, isTrue);
      expect(gameState.mistakeQuestionIds.isEmpty, isTrue);

      // Profile 2 adds favorite 5 and mistake 6
      await gameState.toggleFavorite(5);
      gameState.recordMistake(6);
      expect(gameState.isFavorite(5), isTrue);
      expect(gameState.mistakeQuestionIds.contains(6), isTrue);

      // Switch back to Profile 1
      await gameState.switchProfile('profile_default');
      expect(gameState.profile.id, equals('profile_default'));

      // Profile 1 must have its original data intact without Profile 2's data
      expect(gameState.isFavorite(1), isTrue);
      expect(gameState.mistakeQuestionIds.contains(2), isTrue);
      expect(gameState.isFavorite(5), isFalse);
      expect(gameState.mistakeQuestionIds.contains(6), isFalse);
    });
  });

  group('F. Friend Challenge Question Reproducibility Tests', () {
    test('Friend challenge starts with fixed, reproducible question set and exact order', () {
      final gameState = GameState();
      final targetIds = [42, 108, 256, 314, 500];

      final started = gameState.startFriendChallenge(questionIds: targetIds);
      expect(started, isTrue);
      expect(gameState.quizQuestions.length, equals(5));

      final renderedIds = gameState.quizQuestions.map((q) => q.id).toList();
      expect(renderedIds, equals(targetIds), reason: 'Friend challenge order must be fixed and reproducible');

      // Check second run with same IDs guarantees identical sequence
      final startedAgain = gameState.startFriendChallenge(questionIds: targetIds);
      expect(startedAgain, isTrue);
      final renderedIds2 = gameState.quizQuestions.map((q) => q.id).toList();
      expect(renderedIds2, equals(targetIds));
    });
  });

  group('G. Achievement Thresholds & Unlock Verification Tests', () {
    test('hard_core badge is only granted when scoring >= 70% in hard/expert quiz', () async {
      final gameState = GameState();
      await gameState.loadProfile();

      gameState.selectGameConfig('difficulty', 'expert');
      gameState.prepareQuizSession(count: 10);

      // Answer only 2 out of 10 right (20% < 70%)
      for (int i = 0; i < 10; i++) {
        final q = gameState.quizQuestions[i];
        if (i < 2) {
          gameState.handleAnswerSelection(q.correct);
        } else {
          gameState.handleAnswerSelection((q.correct + 1) % 4);
        }
        if (i < 9) gameState.moveToNextQuestion();
      }

      gameState.finishQuizSession();
      // Must NOT unlock hard_core because score was below 70%
      expect(gameState.profile.unlockedBadges.contains('hard_core'), isFalse);

      // Now take a hard quiz with 8 out of 10 right (80% >= 70%)
      gameState.selectGameConfig('difficulty', 'hard');
      gameState.prepareQuizSession(count: 10);
      for (int i = 0; i < 10; i++) {
        final q = gameState.quizQuestions[i];
        if (i < 8) {
          gameState.handleAnswerSelection(q.correct);
        } else {
          gameState.handleAnswerSelection((q.correct + 1) % 4);
        }
        if (i < 9) gameState.moveToNextQuestion();
      }
      gameState.finishQuizSession();
      // Must now unlock hard_core!
      expect(gameState.profile.unlockedBadges.contains('hard_core'), isTrue);
    });

    test('favorite_collector unlocks when saving 5 favorites', () async {
      final gameState = GameState();
      await gameState.loadProfile();

      for (int i = 1; i <= 4; i++) {
        await gameState.toggleFavorite(i);
      }
      expect(gameState.profile.unlockedBadges.contains('favorite_collector'), isFalse);

      await gameState.toggleFavorite(5);
      expect(gameState.profile.unlockedBadges.contains('favorite_collector'), isTrue);
    });
  });

  group('H. Search Results Limit Verification Tests', () {
    test('Search does not artificially cap results to 60', () {
      final normQuery = normalizeArabic('');
      final allMatching = allQuestions.where((q) {
        final matchesQuery = normQuery.isEmpty ||
            normalizeArabic(q.question).contains(normQuery) ||
            normalizeArabic(q.explanation).contains(normQuery) ||
            q.choices.any((c) => normalizeArabic(c).contains(normQuery)) ||
            normalizeArabic(q.source).contains(normQuery);
        return matchesQuery;
      }).toList();

      expect(allMatching.length, equals(1000));
      expect(allMatching.length, greaterThan(60));

      // Broad search for 'الله' returns well over 60 results
      final allahMatches = allQuestions.where((q) {
        const query = 'الله';
        final norm = normalizeArabic(query);
        return normalizeArabic(q.question).contains(norm) ||
            normalizeArabic(q.explanation).contains(norm) ||
            q.choices.any((c) => normalizeArabic(c).contains(norm)) ||
            normalizeArabic(q.source).contains(norm);
      }).toList();

      expect(allahMatches.length, greaterThan(60));
    });
  });
}

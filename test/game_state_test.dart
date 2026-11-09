import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/data/game_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserProfile serialization tests', () {
    test('default UserProfile has zero values', () {
      final profile = UserProfile();
      expect(profile.totalQuizzes, equals(0));
      expect(profile.totalQuestionsAnswered, equals(0));
      expect(profile.totalCorrectAnswers, equals(0));
      expect(profile.totalXp, equals(0));
      expect(profile.bestScorePercent, equals(0));
      expect(profile.unlockedBadges, isEmpty);
    });

    test('toJson and fromJson preserve data correctly', () {
      final original = UserProfile(
        totalQuizzes: 5,
        totalQuestionsAnswered: 50,
        totalCorrectAnswers: 42,
        totalXp: 520,
        bestScorePercent: 90,
        unlockedBadges: ['first_quiz', 'xp_master'],
      );

      final json = original.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.totalQuizzes, equals(5));
      expect(restored.totalQuestionsAnswered, equals(50));
      expect(restored.totalCorrectAnswers, equals(42));
      expect(restored.totalXp, equals(520));
      expect(restored.bestScorePercent, equals(90));
      expect(restored.unlockedBadges, equals(['first_quiz', 'xp_master']));
    });

    test('fromJson handles null or missing values gracefully', () {
      final emptyJson = <String, dynamic>{};
      final profile = UserProfile.fromJson(emptyJson);

      expect(profile.totalQuizzes, equals(0));
      expect(profile.unlockedBadges, isEmpty);
    });
  });

  group('GameState quiz flow tests', () {
    test('prepareQuizSession initializes session state properly', () {
      final gameState = GameState();
      gameState.selectGameConfig('difficulty', 'easy');
      final ready = gameState.prepareQuizSession();

      expect(ready, isTrue);
      expect(gameState.quizQuestions.length, equals(10));
      expect(gameState.currentQuestionIdx, equals(0));
      expect(gameState.score, equals(0));
      expect(gameState.correctAnswers, equals(0));
      expect(gameState.wrongAnswers, equals(0));
      expect(gameState.hasAnswered, isFalse);
      expect(gameState.answersLog, isEmpty);

      gameState.dispose();
    });

    test('handleAnswerSelection updates score and answer log', () {
      final gameState = GameState();
      gameState.selectGameConfig('difficulty', 'easy');
      gameState.prepareQuizSession();

      final currentQ = gameState.currentQuestion;
      final correctIdx = currentQ.correct;

      // Select correct answer
      gameState.handleAnswerSelection(correctIdx);

      expect(gameState.hasAnswered, isTrue);
      expect(gameState.correctAnswers, equals(1));
      expect(gameState.wrongAnswers, equals(0));
      expect(gameState.score, greaterThan(0));
      expect(gameState.answersLog.length, equals(1));
      expect(gameState.answersLog.first.isCorrect, isTrue);

      // Subsequent taps are ignored (rapid-tap protection)
      gameState.handleAnswerSelection(correctIdx == 0 ? 1 : 0);
      expect(gameState.answersLog.length, equals(1));

      gameState.dispose();
    });

    test('handleAnswerTimeout marks answer as wrong and records mistake', () {
      final gameState = GameState();
      gameState.selectGameConfig('difficulty', 'easy');
      gameState.prepareQuizSession();

      final qId = gameState.currentQuestion.id;
      gameState.handleAnswerTimeout();

      expect(gameState.hasAnswered, isTrue);
      expect(gameState.correctAnswers, equals(0));
      expect(gameState.wrongAnswers, equals(1));
      expect(gameState.answersLog.length, equals(1));
      expect(gameState.answersLog.first.selected, equals(-1));
      expect(gameState.answersLog.first.isCorrect, isFalse);
      expect(gameState.mistakeQuestionIds, contains(qId));

      gameState.dispose();
    });

    test(
      'finishQuizSession updates profile stats and calculates finish result',
      () {
        final gameState = GameState();
        gameState.selectGameConfig('difficulty', 'easy');
        gameState.prepareQuizSession();

        // Answer all questions correctly
        while (true) {
          final q = gameState.currentQuestion;
          gameState.handleAnswerSelection(q.correct);
          if (gameState.isLastQuestion) break;
          gameState.moveToNextQuestion();
        }

        final result = gameState.finishQuizSession();

        expect(result.percent, equals(100));
        expect(result.correctCount, equals(gameState.quizQuestions.length));
        expect(result.wrongCount, equals(0));
        expect(gameState.profile.totalQuizzes, equals(1));
        expect(gameState.profile.bestScorePercent, equals(100));
        // First quiz and perfect score badges should be unlocked
        expect(gameState.profile.unlockedBadges, contains('first_quiz'));
        expect(gameState.profile.unlockedBadges, contains('perfect_score'));

        gameState.dispose();
      },
    );
  });

  group('Favorites, Mistakes, Daily Challenge, & Learning Mode tests', () {
    test('Favorites toggling and retrieval works properly', () async {
      final gameState = GameState();
      expect(gameState.isFavorite(1), isFalse);

      await gameState.toggleFavorite(1);
      expect(gameState.isFavorite(1), isTrue);
      expect(gameState.favoriteQuestionIds, contains(1));

      final favQuestions = gameState.getFavoriteQuestions();
      expect(favQuestions.any((q) => q.id == 1), isTrue);

      await gameState.toggleFavorite(1);
      expect(gameState.isFavorite(1), isFalse);
      expect(gameState.getFavoriteQuestions(), isEmpty);

      gameState.dispose();
    });

    test(
      'Mistakes are recorded on wrong answer and cleared on correct answer',
      () {
        final gameState = GameState();
        gameState.selectGameConfig('difficulty', 'easy');
        gameState.prepareQuizSession();

        final currentQ = gameState.currentQuestion;
        final wrongIdx = (currentQ.correct + 1) % 4;

        // Answer incorrectly
        gameState.handleAnswerSelection(wrongIdx);
        expect(gameState.mistakeQuestionIds, contains(currentQ.id));

        // Reset answered state to simulate re-taking or practicing
        gameState.hasAnswered = false;
        // Answer correctly
        gameState.handleAnswerSelection(currentQ.correct);
        expect(gameState.mistakeQuestionIds.contains(currentQ.id), isFalse);

        gameState.dispose();
      },
    );

    test('Daily challenge generates 5 deterministic questions for today', () {
      final gameState = GameState();
      final dailyQuestions = gameState.getTodayDailyQuestions(count: 5);

      expect(dailyQuestions.length, equals(5));
      expect(dailyQuestions.map((q) => q.id).toSet().length, equals(5));

      // Same day should yield exact same questions
      final repeat = gameState.getTodayDailyQuestions(count: 5);
      expect(repeat.map((q) => q.id), equals(dailyQuestions.map((q) => q.id)));

      gameState.dispose();
    });

    test('Learning Mode sets zero timer duration', () {
      final gameState = GameState();
      gameState.selectGameConfig(
        'difficulty',
        'easy',
        modeType: QuizMode.learning,
      );
      gameState.prepareQuizSession(mode: QuizMode.learning);

      expect(gameState.isLearningMode, isTrue);
      expect(gameState.questionTimeLeft, equals(0));
      expect(gameState.totalQuestionTime, equals(0));

      gameState.dispose();
    });
  });
}

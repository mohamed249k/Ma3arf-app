import 'package:flutter_test/flutter_test.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:ma3arf/data/questions_data.dart';

void main() {
  group('Question Bank Integrity & Schema Verification Tests', () {
    test('Question library contains exactly 1,000 verified questions with contiguous IDs', () {
      expect(allQuestions.length, equals(1000));
      final ids = <int>{};
      for (final q in allQuestions) {
        expect(
          q.id,
          greaterThan(0),
          reason: 'Question ID must be positive: ${q.question}',
        );
        expect(
          ids.contains(q.id),
          isFalse,
          reason: 'Duplicate question ID found: ${q.id}',
        );
        ids.add(q.id);
      }
      expect(ids.length, equals(1000));
      expect(ids.first, equals(1));
      expect(ids.last, equals(1000));
    });

    test('Phase 4 category distribution matches expected totals', () {
      final categoryCounts = <String, int>{};
      for (final q in allQuestions) {
        categoryCounts[q.category] = (categoryCounts[q.category] ?? 0) + 1;
      }

      expect(categoryCounts['القرآن الكريم'], equals(135));
      expect(categoryCounts['الحديث الشريف'], equals(115));
      expect(categoryCounts['قصص الأنبياء'], equals(115));
      expect(categoryCounts['العقيدة'], equals(115));
      expect(categoryCounts['السيرة النبوية'], equals(110));
      expect(categoryCounts['معلومات إسلامية عامة'], equals(105));
      expect(categoryCounts['الفقه'], equals(95));
      expect(categoryCounts['الأخلاق الإسلامية'], equals(85));
      expect(categoryCounts['العبادات'], equals(70));
      expect(categoryCounts['الصحابة'], equals(55));
    });

    test('All questions have 4 distinct choices and valid correct index', () {
      for (final q in allQuestions) {
        expect(
          q.question.trim().isNotEmpty,
          isTrue,
          reason: 'Empty question for ID ${q.id}',
        );
        expect(
          q.choices.length,
          equals(4),
          reason: 'Question ${q.id} must have exactly 4 choices',
        );

        final choiceSet = <String>{};
        for (final choice in q.choices) {
          expect(
            choice.trim().isNotEmpty,
            isTrue,
            reason: 'Empty choice in question ${q.id}',
          );
          expect(
            choiceSet.contains(choice),
            isFalse,
            reason: 'Duplicate choice "$choice" in question ${q.id}',
          );
          choiceSet.add(choice);
        }

        expect(
          q.correct,
          greaterThanOrEqualTo(0),
          reason: 'Invalid correct index ${q.correct} for question ${q.id}',
        );
        expect(
          q.correct,
          lessThan(4),
          reason:
              'Correct index ${q.correct} out of bounds for question ${q.id}',
        );
        expect(
          q.explanation.trim().isNotEmpty,
          isTrue,
          reason: 'Question ${q.id} must have an explanation',
        );
      }
    });

    test(
      'All questions have valid category, difficulty, and review metadata',
      () {
        const validDifficulties = {'easy', 'medium', 'hard', 'expert'};
        for (final q in allQuestions) {
          expect(
            validDifficulties.contains(q.difficulty),
            isTrue,
            reason: 'Invalid difficulty "${q.difficulty}" for question ${q.id}',
          );
          expect(
            q.category.trim().isNotEmpty,
            isTrue,
            reason: 'Empty category for question ${q.id}',
          );
          expect(
            q.isVerified,
            isTrue,
            reason: 'Question ${q.id} must be marked as verified',
          );
          expect(
            q.reviewStatus,
            equals('verified'),
            reason: 'Question ${q.id} reviewStatus must be verified',
          );
          expect(q.isFullyVerified, isTrue);
          expect(
            q.source.trim().isNotEmpty,
            isTrue,
            reason: 'Question ${q.id} must have a valid source',
          );
        }
      },
    );

    test('Question toJson and fromJson preserve all fields', () {
      for (final q in allQuestions.take(10)) {
        final json = q.toJson();
        final reconstructed = Question.fromJson(json);

        expect(reconstructed.id, equals(q.id));
        expect(reconstructed.category, equals(q.category));
        expect(reconstructed.difficulty, equals(q.difficulty));
        expect(reconstructed.question, equals(q.question));
        expect(reconstructed.choices, equals(q.choices));
        expect(reconstructed.correct, equals(q.correct));
        expect(reconstructed.explanation, equals(q.explanation));
        expect(reconstructed.source, equals(q.source));
        expect(reconstructed.sourceType, equals(q.sourceType));
        expect(reconstructed.sourceReference, equals(q.sourceReference));
        expect(reconstructed.isVerified, equals(q.isVerified));
        expect(reconstructed.reviewStatus, equals(q.reviewStatus));
      }
    });

    test(
      'normalizeArabic handles tashkeel, hamzas, taa marbouta, and alef maqsoora',
      () {
        // Tashkeel removal
        expect(
          normalizeArabic('مَعارِفُ الإِسْلَامِ'),
          equals('معارف الاسلام'),
        );
        // Alef variations: أ, إ, آ -> ا
        expect(normalizeArabic('إبراهيم'), equals('ابراهيم'));
        expect(normalizeArabic('أحمد'), equals('احمد'));
        expect(normalizeArabic('آيات'), equals('ايات'));
        // Taa marbouta -> haa
        expect(normalizeArabic('فاطمة'), equals('فاطمه'));
        expect(normalizeArabic('سورة'), equals('سوره'));
        // Alef maqsoora -> yaa
        expect(normalizeArabic('موسى'), equals('موسي'));
        expect(normalizeArabic('عيسى'), equals('عيسي'));
      },
    );
  });
}

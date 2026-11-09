import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ma3arf/app.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_theme.dart';
import 'package:ma3arf/features/home/landing_screen.dart';
import 'package:ma3arf/features/home/selection_screen.dart';
import 'package:ma3arf/features/quiz/quiz_screen.dart';
import 'package:ma3arf/features/results/results_screen.dart';
import 'package:ma3arf/features/review/mistakes_review_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameState gameState;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    gameState = GameState();
  });

  tearDown(() {
    gameState.dispose();
  });

  const testViewports = [
    Size(320, 640), // 320px narrow
    Size(360, 640), // 360px compact Android
    Size(375, 667), // 375px iPhone 8
    Size(390, 844), // 390px iPhone 12/13/14
    Size(412, 915), // 412px Pixel / Galaxy
    Size(430, 932), // 430px Large display
  ];

  Widget buildTestableWidget(Widget child, [ThemeMode mode = ThemeMode.light]) {
    return GameStateScope(
      gameState: gameState,
      child: MaterialApp(
        locale: const Locale('ar'),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: mode,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: child,
        ),
      ),
    );
  }

  for (final vp in testViewports) {
    group('Viewport ${vp.width.toInt()}x${vp.height.toInt()} Responsive Zero-Overflow Verification', () {
      testWidgets('LandingScreen renders responsive hero & cards with zero overflow', (WidgetTester tester) async {
        tester.view.physicalSize = vp;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestableWidget(const LandingScreen()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('مَعارِف'), findsWidgets);
        expect(find.text('اختبر معلوماتك الإسلامية'), findsOneWidget);
        expect(find.text('ابدأ الاختبار'), findsOneWidget);
      });

      testWidgets('SelectionScreen renders tabs & cards with zero overflow', (WidgetTester tester) async {
        tester.view.physicalSize = vp;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestableWidget(SelectionScreen(gameState: gameState)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('أنماط الصعوبة'), findsOneWidget);
        expect(find.text('التصنيفات العلمية'), findsOneWidget);
        expect(find.text('المبتدئ'), findsOneWidget);
        expect(find.text('ابدأ رحلة السؤال'), findsOneWidget);
      });

      testWidgets('QuizScreen renders timer ring, question, choices with zero overflow', (WidgetTester tester) async {
        tester.view.physicalSize = vp;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        gameState.selectGameConfig('difficulty', 'easy');
        gameState.prepareQuizSession();

        await tester.pumpWidget(buildTestableWidget(QuizScreen(gameState: gameState)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.textContaining('السؤال'), findsOneWidget);
        expect(find.byType(Card), findsWidgets);

        gameState.pauseTimers();
      });

      testWidgets('ResultsScreen renders crescent header & 2x2 stats grid with zero overflow', (WidgetTester tester) async {
        tester.view.physicalSize = vp;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final mockResult = FinishResult(
          percent: 80,
          xpEarned: 85,
          newBadges: [],
          correctCount: 8,
          wrongCount: 2,
          timeSpent: 110,
          totalQuestions: 10,
        );

        await tester.pumpWidget(buildTestableWidget(ResultsScreen(result: mockResult, gameState: gameState)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('نتيجة الاختبار'), findsOneWidget);
        expect(find.text('نقاط الخبرة'), findsOneWidget);
        expect(find.text('إجابات صحيحة'), findsOneWidget);
        expect(find.text('إجابات خاطئة'), findsOneWidget);
      });

      testWidgets('MistakesReviewScreen renders header & review items with zero overflow', (WidgetTester tester) async {
        tester.view.physicalSize = vp;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildTestableWidget(MistakesReviewScreen(gameState: gameState)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(find.text('مراجعة الأخطاء'), findsOneWidget);
      });
    });
  }
}

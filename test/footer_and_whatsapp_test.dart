import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ma3arf/app.dart';
import 'package:ma3arf/core/services/game_state.dart';
import 'package:ma3arf/core/theme/app_theme.dart';
import 'package:ma3arf/core/widgets/app_footer.dart';
import 'package:ma3arf/features/feedback/feedback_dialog.dart';
import 'package:ma3arf/features/home/landing_screen.dart';

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

  Widget buildTestableWidget(Widget child) {
    return GameStateScope(
      gameState: gameState,
      child: MaterialApp(
        locale: const Locale('ar'),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group('Islamic Charity Footer Verification', () {
    testWidgets('Renders all authentic elements matching reference website and screenshot', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const SingleChildScrollView(child: AppFooter())));
      await tester.pumpAndSettle();

      // 1. Hadith quote and attribution
      expect(find.text('«الدَّالُّ عَلَى الخَيْرِ كَفَاعِلِهِ»'), findsOneWidget);
      expect(find.text('(رواه الإمام مسلم)'), findsOneWidget);

      // 2. Sadaqah dedication
      expect(find.text('وقفٌ لله تعالى وصدقة جارية'), findsOneWidget);
      expect(find.textContaining('هذا العمل وقفٌ تعليمي لوجه الله'), findsOneWidget);

      // 3. Sharing appeal text
      expect(find.textContaining('أخي الكريم، أختي الكريمة: إذا وصلك هذا التطبيق'), findsOneWidget);

      // 4. Primary and secondary action buttons
      expect(find.text('مشاركة التطبيق واحتساب الأجر'), findsOneWidget);
      expect(find.text('نسخ الرابط'), findsOneWidget);

      // 5. Developer attribution & WhatsApp contact pill
      expect(find.text('فكرة وإعداد وتطوير:'), findsOneWidget);
      expect(find.text('محمد كرم (Mohamed Karam)'), findsOneWidget);
      expect(find.text('واتساب: 01017325592'), findsOneWidget);

      // 6. Charity statement & copyright
      expect(find.text('— صدقة جارية ومتاح لكل مسلم ومسلمة للنشر والتعلم'), findsOneWidget);
      expect(find.textContaining('منصة معارف | Ma3arf © 2026'), findsOneWidget);
    });
  });

  group('LandingScreen 5-Tab Navigation Bar Verification', () {
    testWidgets('Renders 5 navigation items and AppFooter', (tester) async {
      await tester.pumpWidget(
        GameStateScope(
          gameState: gameState,
          child: MaterialApp(
            locale: const Locale('ar'),
            theme: AppTheme.darkTheme,
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: LandingScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify the 5 bottom navigation tabs from screenshot
      expect(find.text('الرئيسية'), findsWidgets);
      expect(find.text('البحث'), findsWidgets);
      expect(find.text('اليومي'), findsWidgets);
      expect(find.text('المفضلة'), findsWidgets);
      expect(find.text('الإحصائيات'), findsWidgets);

      // Scroll down to verify footer is rendered
      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -1500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(AppFooter), findsOneWidget);
      expect(find.text('محمد كرم (Mohamed Karam)'), findsOneWidget);
    });
  });

  group('FeedbackDialog WhatsApp Integration Verification', () {
    testWidgets('Renders WhatsApp banner, WhatsApp buttons, and local actions', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const FeedbackDialog(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify WhatsApp banner
      expect(find.textContaining('محمد كرم (Mohamed Karam)'), findsOneWidget);
      expect(find.textContaining('01017325592'), findsOneWidget);

      // Verify Suggest tab buttons
      expect(find.text('إرسال الاقتراح عبر واتساب'), findsOneWidget);
      expect(find.text('نسخ الاقتراح'), findsOneWidget);
      expect(find.text('حفظ كمسودة'), findsOneWidget);

      // Switch to Report Issue tab
      await tester.tap(find.text('الإبلاغ عن ملاحظة'));
      await tester.pumpAndSettle();

      // Verify Report tab buttons
      expect(find.text('إرسال البلاغ عبر واتساب'), findsOneWidget);
      expect(find.text('نسخ البلاغ'), findsOneWidget);
      expect(find.text('حفظ كمسودة'), findsOneWidget);
    });
  });
}

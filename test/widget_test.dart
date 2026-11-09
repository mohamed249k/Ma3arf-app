import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ma3arf/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Ma3arfApp smoke test and landing screen verification', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build the app
    await tester.pumpWidget(const Ma3arfApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify app title and hero
    expect(find.text('مَعارِف'), findsWidgets);
    expect(find.text('اختبر معلوماتك الإسلامية'), findsOneWidget);
    expect(find.text('ابدأ الاختبار'), findsOneWidget);

    // Verify Daily Wisdom and Daily Challenge features
    expect(find.text('معلومة اليوم المباركة'), findsOneWidget);
    expect(find.text('تحدي اليوم المعرفي'), findsOneWidget);

    // Verify Quick learning action
    expect(find.text('جلسة تدبّر'), findsOneWidget);
    expect(find.text('مراجعة الأخطاء'), findsOneWidget);

    // Tap "ابدأ الاختبار" to navigate to SelectionScreen
    await tester.tap(find.text('ابدأ الاختبار'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Selection Screen tabs and difficulty levels
    expect(find.text('أنماط الصعوبة'), findsOneWidget);
    expect(find.text('التصنيفات العلمية'), findsOneWidget);
    expect(find.text('المبتدئ'), findsOneWidget);
    expect(find.text('المتوسط'), findsOneWidget);
    expect(find.text('المتقدم'), findsOneWidget);
    expect(find.text('الخبير'), findsOneWidget);

    // Switch to Categories tab
    await tester.tap(find.text('التصنيفات العلمية'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify Categories are rendered
    expect(find.text('القرآن الكريم'), findsOneWidget);
    expect(find.text('الحديث الشريف'), findsOneWidget);
    expect(find.text('السيرة النبوية'), findsOneWidget);
  });
}

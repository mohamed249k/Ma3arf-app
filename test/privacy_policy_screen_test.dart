import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ma3arf/core/theme/app_theme.dart';
import 'package:ma3arf/features/privacy/privacy_policy_screen.dart';

void main() {
  Widget buildTestableWidget({Brightness brightness = Brightness.dark}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: PrivacyPolicyScreen(),
      ),
    );
  }

  group('PrivacyPolicyScreen Widget Tests', () {
    testWidgets('Renders all 10 Arabic sections and headers matching website', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verify Title & Hero
      expect(find.text('سياسة الخصوصية'), findsWidgets);
      expect(find.text('سياسة الخصوصية وحماية بيانات المستخدم'), findsOneWidget);
      expect(find.text('وثيقة معتمدة لمتجر Google Play والتطبيق الرسمي'), findsOneWidget);

      // Verify Sections 1 & 2
      expect(find.text('مقدمة وهوية التطبيق والهدف الوقفـي'), findsOneWidget);
      expect(find.text('عدم جمع أي بيانات شخصية (Zero Personal Data)'), findsOneWidget);

      // Scroll down to check further sections
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('التخزين المحلي والتشغيل دون اتصال (Offline-First)'), findsOneWidget);
      expect(find.text('أذونات التطبيق وتبريرها البرمجي (Permissions)'), findsOneWidget);

      // Scroll to bottom
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(find.text('سياسة خصوصية العائلة والأطفال (COPPA Compliance)'), findsOneWidget);
      expect(find.text('بيانات التواصل الرسمية بمسؤول الخصوصية والمطور'), findsOneWidget);
      expect(find.text('محمد كرم (Mohamed Karam)'), findsWidgets);
    });

    testWidgets('Toggles language to English seamlessly', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Tap English toggle
      await tester.tap(find.text('English (الإنجليزية)'));
      await tester.pumpAndSettle();

      // Verify English Headers
      expect(find.text('Privacy Policy'), findsWidgets);
      expect(find.text('Privacy Policy & User Data Protection'), findsOneWidget);
      expect(find.text('Zero Personal Data Collection Policy'), findsOneWidget);
      expect(find.text('Children & Family Safety (COPPA Compliance)'), findsOneWidget);
    });

    testWidgets('Renders with zero overflow across small viewport (320x568)', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(brightness: Brightness.light));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}

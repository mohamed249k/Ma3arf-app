import 'package:flutter/material.dart';

class AppGold {
  AppGold._();
  static const Color primary = Color(0xFFC6A15B); // Primary gold
  static const Color soft = Color(0xFFD8BD83); // Soft gold
  static const Color antique = Color(0xFF9C793B); // Deep antique gold
  static const Color subtle = Color(0xFFE8D9B5); // Subtle gold tint
  static const Color rich = Color(0xFFD7B56D); // Warm Luxury Gold
}

class AppTheme {
  AppTheme._();

  // Light Theme Colors (Exact Match to Web [data-theme="light"])
  static const Color _lightBgPrimary = Color(0xFFF8F6F0);
  static const Color _lightBgSecondary = Color(0xFFEFE9DE);
  static const Color _lightBgCard = Color(0xFFFFFFFF);
  static const Color _lightBorder = Color(0xFFD6CCC0);
  static const Color _lightTextPrimary = Color(0xFF12221B);
  static const Color _lightTextSecondary = Color(0xFF4A6357);
  static const Color _lightPrimary = Color(0xFF1C6B4F); // Website Light Emerald
  static const Color _lightSecondary = Color(0xFFB88E3E); // Website Light Gold

  // Dark Theme Colors (Exact Match to Web :root)
  static const Color _darkBgPrimary = Color(0xFF0B1512);
  static const Color _darkBgSecondary = Color(0xFF10211B);
  static const Color _darkBgCard = Color(0xFF172B23);
  static const Color _darkBorder = Color(0xFF30463A);
  static const Color _darkTextPrimary = Color(0xFFF4F1E8);
  static const Color _darkTextSecondary = Color(0xFFB9C7BD);
  static const Color _darkPrimary = Color(0xFF2E8B68); // Website Islamic Emerald
  static const Color _darkSecondary = Color(0xFFC6A15B); // Website Luxury Gold

  // Common Semantic Feedback Colors (Exact Match to Web)
  static const Color success = Color(0xFF2E8B68);
  static const Color successLight = Color(0x402E8B68);
  static const Color error = Color(0xFFE05D5D);
  static const Color errorLight = Color(0x38E05D5D);
  static const Color warning = Color(0xFFD7B56D);

  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 28,
        fontWeight: FontWeight.w900,
      ).copyWith(color: primaryColor),
      displayMedium: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ).copyWith(color: primaryColor),
      headlineLarge: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ).copyWith(color: primaryColor),
      headlineMedium: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ).copyWith(color: primaryColor),
      headlineSmall: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ).copyWith(color: primaryColor),
      titleLarge: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ).copyWith(color: primaryColor),
      titleMedium: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ).copyWith(color: primaryColor),
      titleSmall: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ).copyWith(color: secondaryColor),
      bodyLarge: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ).copyWith(color: primaryColor),
      bodyMedium: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ).copyWith(color: secondaryColor),
      bodySmall: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ).copyWith(color: secondaryColor),
      labelLarge: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ).copyWith(color: primaryColor),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBgPrimary,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        secondary: _lightSecondary,
        surface: _lightBgCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _lightTextPrimary,
        outline: _lightBorder,
        error: error,
      ),
      cardColor: _lightBgCard,
      dividerColor: _lightBorder,
      textTheme: _buildTextTheme(_lightTextPrimary, _lightTextSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimary,
          side: const BorderSide(color: _lightPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightBgCard,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _lightBorder.withValues(alpha: 0.5)),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColors(
          bgPrimary: _lightBgPrimary,
          bgSecondary: _lightBgSecondary,
          bgCard: _lightBgCard,
          border: _lightBorder,
          textPrimary: _lightTextPrimary,
          textSecondary: _lightTextSecondary,
          primary: _lightPrimary,
          secondary: _lightSecondary,
          primaryGlow: Color(0x260B6623),
          secondaryGlow: Color(0x66C5A059),
          gold: AppGold.primary,
          goldSoft: AppGold.soft,
          goldAntique: AppGold.antique,
          goldSubtle: AppGold.subtle,
          success: success,
          successLight: successLight,
          error: error,
          errorLight: errorLight,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        secondary: _darkSecondary,
        surface: _darkBgCard,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: _darkTextPrimary,
        outline: _darkBorder,
        error: error,
      ),
      cardColor: _darkBgCard,
      dividerColor: _darkBorder,
      textTheme: _buildTextTheme(_darkTextPrimary, _darkTextSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBgSecondary,
        foregroundColor: _darkTextPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _darkTextPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          side: const BorderSide(color: _darkPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkBgCard,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _darkBorder.withValues(alpha: 0.5)),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        AppColors(
          bgPrimary: _darkBgPrimary,
          bgSecondary: _darkBgSecondary,
          bgCard: _darkBgCard,
          border: _darkBorder,
          textPrimary: _darkTextPrimary,
          textSecondary: _darkTextSecondary,
          primary: _darkPrimary,
          secondary: _darkSecondary,
          primaryGlow: Color(0x332E8B68),
          secondaryGlow: Color(0x4DD7B56D),
          gold: AppGold.rich,
          goldSoft: AppGold.soft,
          goldAntique: AppGold.antique,
          goldSubtle: AppGold.subtle,
          success: Color(0xFF2E8B68),
          successLight: Color(0x332E8B68),
          error: Color(0xFFD9534F),
          errorLight: Color(0x33D9534F),
        ),
      ],
    );
  }
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgCard;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;
  final Color secondary;
  final Color primaryGlow;
  final Color secondaryGlow;
  final Color gold;
  final Color goldSoft;
  final Color goldAntique;
  final Color goldSubtle;
  final Color success;
  final Color successLight;
  final Color error;
  final Color errorLight;

  const AppColors({
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgCard,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.secondary,
    required this.primaryGlow,
    required this.secondaryGlow,
    this.gold = AppGold.primary,
    this.goldSoft = AppGold.soft,
    this.goldAntique = AppGold.antique,
    this.goldSubtle = AppGold.subtle,
    required this.success,
    required this.successLight,
    required this.error,
    required this.errorLight,
  });

  @override
  AppColors copyWith({
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgCard,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? primary,
    Color? secondary,
    Color? primaryGlow,
    Color? secondaryGlow,
    Color? gold,
    Color? goldSoft,
    Color? goldAntique,
    Color? goldSubtle,
    Color? success,
    Color? successLight,
    Color? error,
    Color? errorLight,
  }) {
    return AppColors(
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgCard: bgCard ?? this.bgCard,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      primaryGlow: primaryGlow ?? this.primaryGlow,
      secondaryGlow: secondaryGlow ?? this.secondaryGlow,
      gold: gold ?? this.gold,
      goldSoft: goldSoft ?? this.goldSoft,
      goldAntique: goldAntique ?? this.goldAntique,
      goldSubtle: goldSubtle ?? this.goldSubtle,
      success: success ?? this.success,
      successLight: successLight ?? this.successLight,
      error: error ?? this.error,
      errorLight: errorLight ?? this.errorLight,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      primaryGlow: Color.lerp(primaryGlow, other.primaryGlow, t)!,
      secondaryGlow: Color.lerp(secondaryGlow, other.secondaryGlow, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldSoft: Color.lerp(goldSoft, other.goldSoft, t)!,
      goldAntique: Color.lerp(goldAntique, other.goldAntique, t)!,
      goldSubtle: Color.lerp(goldSubtle, other.goldSubtle, t)!,
      success: Color.lerp(success, other.success, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
    );
  }
}

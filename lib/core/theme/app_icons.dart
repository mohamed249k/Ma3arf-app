import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Centralized sizing tokens for icons throughout Ma3arf
class AppIconSize {
  AppIconSize._();
  static const double small = 16.0;
  static const double medium = 20.0;
  static const double large = 24.0;
  static const double feature = 28.0;
  static const double hero = 36.0;
  static const double display = 48.0;
}

/// Centralized semantic icon registry for the Ma3arf Islamic Learning Platform.
/// Standardizes all iconography to Phosphor Duotone as primary family,
/// with authentic Islamic iconography sourced from FontAwesome.
class AppIcons {
  AppIcons._();

  // ==========================================
  // Navigation & Directional
  // ==========================================
  static IconData get back =>
      PhosphorIcons.arrowRight(PhosphorIconsStyle.duotone); // RTL back
  static IconData get forward =>
      PhosphorIcons.arrowLeft(PhosphorIconsStyle.duotone); // RTL forward
  static IconData get arrowLeft =>
      PhosphorIcons.arrowLeft(PhosphorIconsStyle.duotone);
  static IconData get arrowRight =>
      PhosphorIcons.arrowRight(PhosphorIconsStyle.duotone);
  static IconData get close => PhosphorIcons.x(PhosphorIconsStyle.duotone);
  static IconData get check => PhosphorIcons.check(PhosphorIconsStyle.duotone);
  static IconData get checkCircle =>
      PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone);
  static IconData get xCircle =>
      PhosphorIcons.xCircle(PhosphorIconsStyle.duotone);
  static IconData get caretDown =>
      PhosphorIcons.caretDown(PhosphorIconsStyle.duotone);
  static IconData get moreVertical =>
      PhosphorIcons.dotsThreeVertical(PhosphorIconsStyle.duotone);

  // ==========================================
  // Core Application Features
  // ==========================================
  static IconData get dailyChallenge =>
      PhosphorIcons.lightning(PhosphorIconsStyle.duotone);
  static IconData get learningMode =>
      PhosphorIcons.bookOpenText(PhosphorIconsStyle.duotone);
  static IconData get mistakesReview =>
      PhosphorIcons.arrowCounterClockwise(PhosphorIconsStyle.duotone);
  static IconData get restart =>
      PhosphorIcons.arrowClockwise(PhosphorIconsStyle.duotone);
  static IconData get favorites =>
      PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.duotone);
  static IconData get bookmark =>
      PhosphorIcons.bookmarkSimple(PhosphorIconsStyle.duotone);
  static IconData get search =>
      PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.duotone);
  static IconData get questionBank =>
      PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.duotone);
  static IconData get leaderboard =>
      PhosphorIcons.trophy(PhosphorIconsStyle.duotone);
  static IconData get achievements =>
      PhosphorIcons.medal(PhosphorIconsStyle.duotone);
  static IconData get badge => PhosphorIcons.medal(PhosphorIconsStyle.duotone);
  static IconData get stats =>
      PhosphorIcons.chartBar(PhosphorIconsStyle.duotone);
  static IconData get progress =>
      PhosphorIcons.chartLineUp(PhosphorIconsStyle.duotone);
  static IconData get history =>
      PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.duotone);
  static IconData get settings =>
      PhosphorIcons.gear(PhosphorIconsStyle.duotone);
  static IconData get profile =>
      PhosphorIcons.userCircle(PhosphorIconsStyle.duotone);
  static IconData get switchProfile =>
      PhosphorIcons.arrowsLeftRight(PhosphorIconsStyle.duotone);
  static IconData get feedback =>
      PhosphorIcons.chatsCircle(PhosphorIconsStyle.duotone);
  static IconData get quiz =>
      PhosphorIcons.question(PhosphorIconsStyle.duotone);
  static IconData get percent =>
      PhosphorIcons.percent(PhosphorIconsStyle.duotone);
  static IconData get tune => PhosphorIcons.sliders(PhosphorIconsStyle.duotone);
  static IconData get target =>
      PhosphorIcons.target(PhosphorIconsStyle.duotone);

  // ==========================================
  // Controls, State, & Utility
  // ==========================================
  static IconData get lock => PhosphorIcons.lock(PhosphorIconsStyle.duotone);
  static IconData get lockOpen =>
      PhosphorIcons.lockOpen(PhosphorIconsStyle.duotone);
  static IconData get soundOn =>
      PhosphorIcons.speakerHigh(PhosphorIconsStyle.duotone);
  static IconData get soundOff =>
      PhosphorIcons.speakerSlash(PhosphorIconsStyle.duotone);
  static IconData get themeLight =>
      PhosphorIcons.sun(PhosphorIconsStyle.duotone);
  static IconData get themeDark =>
      PhosphorIcons.moon(PhosphorIconsStyle.duotone);
  static IconData get timer => PhosphorIcons.timer(PhosphorIconsStyle.duotone);
  static IconData get star => PhosphorIcons.star(PhosphorIconsStyle.duotone);
  static IconData get starFilled => PhosphorIcons.star(PhosphorIconsStyle.fill);
  static IconData get share =>
      PhosphorIcons.shareNetwork(PhosphorIconsStyle.duotone);
  static IconData get copy => PhosphorIcons.copy(PhosphorIconsStyle.duotone);
  static IconData get send =>
      PhosphorIcons.paperPlaneTilt(PhosphorIconsStyle.duotone);
  static IconData get save =>
      PhosphorIcons.floppyDisk(PhosphorIconsStyle.duotone);
  static IconData get home => PhosphorIcons.house(PhosphorIconsStyle.duotone);
  static IconData get edit =>
      PhosphorIcons.pencilSimple(PhosphorIconsStyle.duotone);
  static IconData get delete => PhosphorIcons.trash(PhosphorIconsStyle.duotone);
  static IconData get userAdd =>
      PhosphorIcons.userPlus(PhosphorIconsStyle.duotone);
  static IconData get play => PhosphorIcons.play(PhosphorIconsStyle.duotone);
  static IconData get flag => PhosphorIcons.flag(PhosphorIconsStyle.duotone);
  static IconData get plus =>
      PhosphorIcons.plusCircle(PhosphorIconsStyle.duotone);
  static IconData get help =>
      PhosphorIcons.question(PhosphorIconsStyle.duotone);
  static IconData get info => PhosphorIcons.info(PhosphorIconsStyle.duotone);
  static IconData get wisdom =>
      PhosphorIcons.lightbulb(PhosphorIconsStyle.duotone);
  static IconData get verified =>
      PhosphorIcons.sealCheck(PhosphorIconsStyle.duotone);
  static IconData get shieldCheck =>
      PhosphorIcons.shieldCheck(PhosphorIconsStyle.duotone);
  static IconData get privacy =>
      PhosphorIcons.shieldCheck(PhosphorIconsStyle.duotone);
  static IconData get heart =>
      PhosphorIcons.heart(PhosphorIconsStyle.duotone);
  static IconData get heartFilled =>
      PhosphorIcons.heart(PhosphorIconsStyle.fill);
  static IconData get calendar =>
      PhosphorIcons.calendar(PhosphorIconsStyle.duotone);
  static IconData get whatsapp =>
      PhosphorIcons.whatsappLogo(PhosphorIconsStyle.duotone);
  static IconData get whatsappFill =>
      PhosphorIcons.whatsappLogo(PhosphorIconsStyle.fill);

  // ==========================================
  // Authentic Islamic Iconography
  // ==========================================
  static IconData get mosque => FontAwesomeIcons.mosque.data;
  static IconData get kaaba => FontAwesomeIcons.kaaba.data;
  static IconData get quran => FontAwesomeIcons.bookQuran.data;
  static IconData get hadith =>
      PhosphorIcons.scroll(PhosphorIconsStyle.duotone);
  static IconData get prophets =>
      PhosphorIcons.compass(PhosphorIconsStyle.duotone);
  static IconData get sahaba =>
      PhosphorIcons.usersThree(PhosphorIconsStyle.duotone);
  static IconData get aqeedah =>
      PhosphorIcons.scales(PhosphorIconsStyle.duotone);
  static IconData get fiqh => PhosphorIcons.bank(PhosphorIconsStyle.duotone);
  static IconData get ethics =>
      PhosphorIcons.handHeart(PhosphorIconsStyle.duotone);
  static IconData get generalIslamic =>
      PhosphorIcons.globeHemisphereEast(PhosphorIconsStyle.duotone);

  // ==========================================
  // Difficulty Levels (Duotone Progression)
  // ==========================================
  static IconData get beginner =>
      PhosphorIcons.plant(PhosphorIconsStyle.duotone);
  static IconData get intermediate =>
      PhosphorIcons.compass(PhosphorIconsStyle.duotone);
  static IconData get advanced =>
      PhosphorIcons.graduationCap(PhosphorIconsStyle.duotone);
  static IconData get expert => PhosphorIcons.crown(PhosphorIconsStyle.duotone);

  // ==========================================
  // Semantic Mappings
  // ==========================================

  /// Maps an Islamic knowledge category to its authentic verified icon
  static IconData getCategoryIcon(String category) {
    switch (category.trim()) {
      case 'القرآن الكريم':
        return quran;
      case 'الحديث الشريف':
        return hadith;
      case 'السيرة النبوية':
        return mosque;
      case 'قصص الأنبياء':
        return prophets;
      case 'الصحابة':
        return sahaba;
      case 'العقيدة':
        return aqeedah;
      case 'الفقه':
        return fiqh;
      case 'الأخلاق الإسلامية':
        return ethics;
      case 'العبادات':
        return kaaba;
      case 'معلومات إسلامية عامة':
      default:
        return generalIslamic;
    }
  }

  /// Maps a difficulty level code to its Duotone icon
  static IconData getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase().trim()) {
      case 'easy':
      case 'مبتدئ':
        return beginner;
      case 'medium':
      case 'متوسط':
        return intermediate;
      case 'hard':
      case 'متقدم':
        return advanced;
      case 'expert':
      case 'خبير':
      case 'خبير جداً':
        return expert;
      default:
        return beginner;
    }
  }

  /// Maps a user level name to its Duotone icon
  static IconData getLevelIcon(String levelName) {
    switch (levelName.trim()) {
      case 'المبتدئ':
        return beginner;
      case 'المبادر':
        return PhosphorIcons.lightning(PhosphorIconsStyle.duotone);
      case 'المتوسط':
        return intermediate;
      case 'المتقدم':
        return advanced;
      case 'الخبير':
        return expert;
      case 'العالم الأثري':
        return PhosphorIcons.sparkle(PhosphorIconsStyle.duotone);
      default:
        return beginner;
    }
  }

  /// Maps a badge ID to its Duotone icon
  static IconData getBadgeIcon(String badgeId) {
    switch (badgeId.trim()) {
      case 'first_quiz':
        return beginner;
      case 'perfect_score':
        return leaderboard;
      case 'hard_core':
        return expert;
      case 'hadith_streak':
        return hadith;
      case 'quran_streak':
        return quran;
      case 'xp_master':
        return verified;
      case 'daily_champion':
        return dailyChallenge;
      case 'mistake_corrector':
        return PhosphorIcons.target(PhosphorIconsStyle.duotone);
      default:
        return achievements;
    }
  }

  /// Maps a leaderboard rank to an award icon
  static IconData getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return expert; // Crown
      case 2:
      case 3:
        return achievements; // Medal
      default:
        return leaderboard; // Trophy
    }
  }
}

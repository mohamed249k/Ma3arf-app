import 'package:flutter/widgets.dart';
import 'package:ma3arf/core/theme/app_icons.dart';

class LevelConfig {
  final String name;
  final int minXp;
  final int maxXp;
  final IconData icon;

  const LevelConfig({
    required this.name,
    required this.minXp,
    required this.maxXp,
    required this.icon,
  });
}

class Badge {
  final String id;
  final String name;
  final IconData icon;
  final String desc;

  const Badge({
    required this.id,
    required this.name,
    required this.icon,
    required this.desc,
  });
}

final List<LevelConfig> levelConfigs = [
  LevelConfig(name: 'المبتدئ', minXp: 0, maxXp: 100, icon: AppIcons.beginner),
  LevelConfig(
    name: 'المبادر',
    minXp: 100,
    maxXp: 250,
    icon: AppIcons.dailyChallenge,
  ),
  LevelConfig(
    name: 'المتوسط',
    minXp: 250,
    maxXp: 500,
    icon: AppIcons.intermediate,
  ),
  LevelConfig(
    name: 'المتقدم',
    minXp: 500,
    maxXp: 1000,
    icon: AppIcons.advanced,
  ),
  LevelConfig(name: 'الخبير', minXp: 1000, maxXp: 2000, icon: AppIcons.expert),
  LevelConfig(
    name: 'العالم الأثري',
    minXp: 2000,
    maxXp: 999999,
    icon: AppIcons.getLevelIcon('العالم الأثري'),
  ),
];

final List<Badge> allBadges = [
  Badge(
    id: 'first_quiz',
    name: 'باحث عن العلم',
    icon: AppIcons.beginner,
    desc: 'أكملت أول اختبار بنجاح على المنصة.',
  ),
  Badge(
    id: 'quiz_10',
    name: 'طالب علم مجتهد',
    icon: AppIcons.intermediate,
    desc: 'أكملت 10 اختبارات معرفية مكتملة.',
  ),
  Badge(
    id: 'perfect_score',
    name: 'حافظ متقن',
    icon: AppIcons.leaderboard,
    desc: 'حققت نسبة كاملة 100% في أي اختبار.',
  ),
  Badge(
    id: 'hard_core',
    name: 'عالم المستقبل',
    icon: AppIcons.expert,
    desc: 'أكملت بنجاح اختباراً بمستوى المتقدم أو الخبير بنسبة 70% فأكثر.',
  ),
  Badge(
    id: 'hadith_streak',
    name: 'محب السنة',
    icon: AppIcons.hadith,
    desc: 'أجبت على 5 أسئلة متتالية صحيحة في الحديث الشريف.',
  ),
  Badge(
    id: 'quran_streak',
    name: 'صديق القرآن',
    icon: AppIcons.quran,
    desc: 'أجبت على 5 أسئلة متتالية صحيحة في علوم القرآن.',
  ),
  Badge(
    id: 'xp_master',
    name: 'سادن المعرفة',
    icon: AppIcons.verified,
    desc: 'جمعت أكثر من 500 نقطة خبرة (XP) إجمالاً.',
  ),
  Badge(
    id: 'xp_grandmaster',
    name: 'بحر العلوم',
    icon: AppIcons.getLevelIcon('العالم الأثري'),
    desc: 'تجاوزت 1500 نقطة خبرة تراكمية.',
  ),
  Badge(
    id: 'daily_champion',
    name: 'مداوم على التحدي',
    icon: AppIcons.dailyChallenge,
    desc: 'أتممت التحدي اليومي بنجاح.',
  ),
  Badge(
    id: 'favorite_collector',
    name: 'جامع الفوائد',
    icon: AppIcons.starFilled,
    desc: 'حفظت 5 أسئلة أو أكثر في قائمة المفضلة.',
  ),
  Badge(
    id: 'mistake_corrector',
    name: 'المصحح المثابر',
    icon: AppIcons.getBadgeIcon('mistake_corrector'),
    desc: 'راجعت وصححت أخطاءك السابقة بنجاح.',
  ),
  Badge(
    id: 'polymath',
    name: 'موسوعي الثقافة',
    icon: AppIcons.generalIslamic,
    desc: 'أجريت اختبارات في 5 تصنيفات علمية مختلفة.',
  ),
];

enum QuizMode {
  challenge, // Timed, scores XP, badges
  learning, // Untimed, immediate explanations, study mode
}

class QuizPreset {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final QuizMode mode;
  final int questionCount;
  final String? category;
  final String? difficulty;

  const QuizPreset({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.mode,
    required this.questionCount,
    this.category,
    this.difficulty,
  });
}

final List<QuizPreset> standardPresets = [
  QuizPreset(
    id: 'quick_challenge',
    title: 'تحدي سريع',
    subtitle: '5 أسئلة سريعة لاختبار معلوماتك',
    icon: AppIcons.dailyChallenge,
    mode: QuizMode.challenge,
    questionCount: 5,
  ),
  QuizPreset(
    id: 'learning_session',
    title: 'جلسة تدبّر وتعلّم',
    subtitle: '10 أسئلة بدون مؤقت مع شرح وافٍ',
    icon: AppIcons.learningMode,
    mode: QuizMode.learning,
    questionCount: 10,
  ),
  QuizPreset(
    id: 'comprehensive_exam',
    title: 'اختبار المعارف الشامل',
    subtitle: '20 سؤالاً عبر جميع التصنيفات',
    icon: AppIcons.achievements,
    mode: QuizMode.challenge,
    questionCount: 20,
  ),
];

final Map<String, IconData> categoryIcons = {
  'القرآن الكريم': AppIcons.quran,
  'الحديث الشريف': AppIcons.hadith,
  'السيرة النبوية': AppIcons.mosque,
  'قصص الأنبياء': AppIcons.prophets,
  'الصحابة': AppIcons.sahaba,
  'العقيدة': AppIcons.aqeedah,
  'الفقه': AppIcons.fiqh,
  'الأخلاق الإسلامية': AppIcons.ethics,
  'العبادات': AppIcons.kaaba,
  'معلومات إسلامية عامة': AppIcons.generalIslamic,
};

final List<String> categoryNames = categoryIcons.keys.toList();

const Map<String, String> difficultyNames = {
  'easy': 'سهل',
  'medium': 'متوسط',
  'hard': 'صعب',
  'expert': 'خبير جداً',
};

const Map<String, int> difficultyTimers = {
  'easy': 20,
  'medium': 20,
  'hard': 15,
  'expert': 12,
};

const Map<String, int> difficultyQuestionCounts = {
  'easy': 10,
  'medium': 15,
  'hard': 20,
  'expert': 25,
};

const Map<String, int> difficultyPoints = {
  'easy': 10,
  'medium': 15,
  'hard': 20,
  'expert': 25,
};

LevelConfig getCurrentLevel(int xp) {
  LevelConfig current = levelConfigs[0];
  for (final level in levelConfigs) {
    if (xp >= level.minXp) {
      current = level;
    }
  }
  return current;
}

LevelConfig getNextLevel(int xp) {
  final current = getCurrentLevel(xp);
  final currentIndex = levelConfigs.indexOf(current);
  if (currentIndex + 1 < levelConfigs.length) {
    return levelConfigs[currentIndex + 1];
  }
  return current;
}

double getLevelProgress(int xp) {
  final current = getCurrentLevel(xp);
  final next = getNextLevel(xp);
  if (current == next) return 1.0;
  final range = next.minXp - current.minXp;
  if (range <= 0) return 1.0;
  final progress = xp - current.minXp;
  return (progress / range).clamp(0.0, 1.0).toDouble();
}

/// Normalizes Arabic text for flexible search and comparison:
/// - Removes diacritics (tashkeel/harakat)
/// - Normalizes hamzas and alefs (أ, إ, آ -> ا)
/// - Normalizes taa marbouta (ة -> ه)
/// - Normalizes alef maqsoora (ى -> ي)
String normalizeArabic(String text) {
  var s = text;
  s = s.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  s = s.replaceAll(RegExp(r'[إأآا]'), 'ا');
  s = s.replaceAll('ة', 'ه');
  s = s.replaceAll('ى', 'ي');
  return s.toLowerCase().trim();
}

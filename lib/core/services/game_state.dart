import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:ma3arf/core/services/audio_feedback_service.dart';
import 'package:ma3arf/core/services/storage_service.dart';
import 'package:ma3arf/data/game_config.dart';
import 'package:ma3arf/data/questions_data.dart';

class AnswerLog {
  final int? questionId;
  final String question;
  final String category;
  final List<String> choices;
  int selected; // -1 = timeout
  final int correct;
  bool isCorrect;

  AnswerLog({
    this.questionId,
    required this.question,
    required this.category,
    required this.choices,
    required this.selected,
    required this.correct,
    required this.isCorrect,
  });
}

class UserProfile {
  String id;
  String displayName;
  int totalQuizzes;
  int totalQuestionsAnswered;
  int totalCorrectAnswers;
  int totalXp;
  int bestScorePercent;
  List<String> unlockedBadges;
  List<String> testedCategories;

  UserProfile({
    this.id = 'profile_default',
    this.displayName = 'المستخدم الرئيسي',
    this.totalQuizzes = 0,
    this.totalQuestionsAnswered = 0,
    this.totalCorrectAnswers = 0,
    this.totalXp = 0,
    this.bestScorePercent = 0,
    List<String>? unlockedBadges,
    List<String>? testedCategories,
  })  : unlockedBadges = unlockedBadges ?? [],
        testedCategories = testedCategories ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'totalQuizzes': totalQuizzes,
    'totalQuestionsAnswered': totalQuestionsAnswered,
    'totalCorrectAnswers': totalCorrectAnswers,
    'totalXp': totalXp,
    'bestScorePercent': bestScorePercent,
    'unlockedBadges': unlockedBadges,
    'testedCategories': testedCategories,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'profile_default',
      displayName: json['displayName'] as String? ?? 'المستخدم الرئيسي',
      totalQuizzes: json['totalQuizzes'] as int? ?? 0,
      totalQuestionsAnswered: json['totalQuestionsAnswered'] as int? ?? 0,
      totalCorrectAnswers: json['totalCorrectAnswers'] as int? ?? 0,
      totalXp: json['totalXp'] as int? ?? 0,
      bestScorePercent: json['bestScorePercent'] as int? ?? 0,
      unlockedBadges:
          (json['unlockedBadges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      testedCategories:
          (json['testedCategories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class LeaderboardEntry {
  final String id;
  final String profileId;
  final String profileName;
  final int score;
  final int totalQuestions;
  final int accuracy;
  final String difficulty;
  final String category;
  final String quizMode;
  final DateTime date;

  LeaderboardEntry({
    required this.id,
    required this.profileId,
    required this.profileName,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.difficulty,
    required this.category,
    required this.quizMode,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'profileId': profileId,
    'profileName': profileName,
    'score': score,
    'totalQuestions': totalQuestions,
    'accuracy': accuracy,
    'difficulty': difficulty,
    'category': category,
    'quizMode': quizMode,
    'date': date.toIso8601String(),
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        id: json['id'] as String? ?? '',
        profileId: json['profileId'] as String? ?? 'profile_default',
        profileName: json['profileName'] as String? ?? 'المستخدم الرئيسي',
        score: (json['score'] as num?)?.toInt() ?? 0,
        totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 10,
        accuracy: (json['accuracy'] as num?)?.toInt() ?? 0,
        difficulty: json['difficulty'] as String? ?? 'easy',
        category: json['category'] as String? ?? 'عام',
        quizMode: json['quizMode'] as String? ?? 'challenge',
        date: json['date'] != null
            ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

class GameState extends ChangeNotifier {
  UserProfile profile = UserProfile();
  List<UserProfile> localProfiles = [];
  List<LeaderboardEntry> leaderboardEntries = [];
  bool _isLoaded = false;
  bool isSoundEnabled = true;

  // Quiz mode & session config
  QuizMode quizMode = QuizMode.challenge;
  String selectedMode = 'difficulty';
  String selectedVal = 'easy';
  int requestedQuestionCount = 10;

  // Bookmarks & mistakes tracking
  Set<int> favoriteQuestionIds = {};
  Set<int> mistakeQuestionIds = {};
  Map<String, int> dailyHistory = {};

  // Active quiz session state
  List<Question> quizQuestions = [];
  int currentQuestionIdx = 0;
  int score = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int xpEarnedInRun = 0;
  int timeSpent = 0;
  int questionTimeLeft = 20;
  int totalQuestionTime = 20;
  bool hasAnswered = false;
  List<AnswerLog> answersLog = [];

  Timer? _runTimer;
  Timer? _questionTimer;
  VoidCallback? _activeOnTimeout;
  VoidCallback? _activeOnTick;

  bool get isLoaded => _isLoaded;
  bool get isLearningMode => quizMode == QuizMode.learning;

  Future<void> loadProfile() async {
    await AudioFeedbackService.instance.initialize();
    isSoundEnabled = AudioFeedbackService.instance.isSoundEnabled;

    final profileData = await StorageService.loadProfile();
    profile = UserProfile.fromJson(profileData);

    // Load Local Profiles
    final rawProfiles = await StorageService.loadProfiles();
    localProfiles = rawProfiles.map((p) => UserProfile.fromJson(p)).toList();
    if (localProfiles.isEmpty) {
      localProfiles.add(profile);
    } else {
      final activeId = await StorageService.loadActiveProfileId();
      profile = localProfiles.firstWhere(
        (p) => p.id == activeId,
        orElse: () => localProfiles.first,
      );
    }

    // Load Leaderboard
    final rawLeaderboard = await StorageService.loadLeaderboard();
    leaderboardEntries = rawLeaderboard
        .map((e) => LeaderboardEntry.fromJson(e))
        .toList();

    // Load Favorites & Mistakes for active profile
    final favs = await StorageService.loadFavorites(profile.id);
    favoriteQuestionIds = favs.toSet();

    final mistakes = await StorageService.loadMistakes(profile.id);
    mistakeQuestionIds = mistakes.toSet();

    dailyHistory = await StorageService.loadDailyRecords(profile.id);

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> saveProfile() async {
    await StorageService.saveProfile(profile.toJson());

    // Update in localProfiles list
    final idx = localProfiles.indexWhere((p) => p.id == profile.id);
    if (idx >= 0) {
      localProfiles[idx] = profile;
    } else {
      localProfiles.add(profile);
    }
    await StorageService.saveProfiles(
      localProfiles.map((p) => p.toJson()).toList(),
    );
    await StorageService.saveActiveProfileId(profile.id);
  }

  // --- Sound Setting ---
  Future<void> toggleSound() async {
    await AudioFeedbackService.instance.toggleSound();
    isSoundEnabled = AudioFeedbackService.instance.isSoundEnabled;
    notifyListeners();
  }

  // --- Local Profiles Management ---
  Future<void> switchProfile(String profileId) async {
    await saveProfile();

    final target = localProfiles.firstWhere(
      (p) => p.id == profileId,
      orElse: () => profile,
    );
    profile = target;
    await StorageService.saveActiveProfileId(profile.id);
    await StorageService.saveProfile(profile.toJson());

    // Reload isolated data for the switched profile
    final favs = await StorageService.loadFavorites(profile.id);
    favoriteQuestionIds = favs.toSet();

    final mistakes = await StorageService.loadMistakes(profile.id);
    mistakeQuestionIds = mistakes.toSet();

    dailyHistory = await StorageService.loadDailyRecords(profile.id);

    notifyListeners();
  }

  Future<void> createProfile(String displayName) async {
    await saveProfile();

    final newId = 'profile_${DateTime.now().millisecondsSinceEpoch}';
    final newProfile = UserProfile(id: newId, displayName: displayName);
    localProfiles.add(newProfile);
    profile = newProfile;
    await StorageService.saveProfiles(
      localProfiles.map((p) => p.toJson()).toList(),
    );
    await StorageService.saveActiveProfileId(newId);
    await StorageService.saveProfile(profile.toJson());

    // Fresh isolated state for the new profile
    favoriteQuestionIds = {};
    mistakeQuestionIds = {};
    dailyHistory = {};

    await StorageService.saveFavorites([], profile.id);
    await StorageService.saveMistakes([], profile.id);

    notifyListeners();
  }

  Future<void> deleteProfile(String profileId) async {
    if (profileId == 'profile_default' || localProfiles.length <= 1) return;
    localProfiles.removeWhere((p) => p.id == profileId);
    await StorageService.deleteProfileData(profileId);
    await StorageService.saveProfiles(
      localProfiles.map((p) => p.toJson()).toList(),
    );

    if (profile.id == profileId) {
      profile = localProfiles.first;
      await StorageService.saveActiveProfileId(profile.id);
      final favs = await StorageService.loadFavorites(profile.id);
      favoriteQuestionIds = favs.toSet();
      final mistakes = await StorageService.loadMistakes(profile.id);
      mistakeQuestionIds = mistakes.toSet();
      dailyHistory = await StorageService.loadDailyRecords(profile.id);
    }
    notifyListeners();
  }

  Future<void> renameProfile(String profileId, String newName) async {
    final idx = localProfiles.indexWhere((p) => p.id == profileId);
    if (idx >= 0) {
      localProfiles[idx].displayName = newName;
      if (profile.id == profileId) {
        profile.displayName = newName;
      }
      await StorageService.saveProfiles(
        localProfiles.map((p) => p.toJson()).toList(),
      );
      await StorageService.saveProfile(profile.toJson());
      notifyListeners();
    }
  }

  // --- Local Leaderboard Management ---
  Future<void> addLeaderboardEntry(LeaderboardEntry entry) async {
    leaderboardEntries.insert(0, entry);
    // Keep max 100 entries locally
    if (leaderboardEntries.length > 100) {
      leaderboardEntries = leaderboardEntries.sublist(0, 100);
    }
    await StorageService.saveLeaderboard(
      leaderboardEntries.map((e) => e.toJson()).toList(),
    );
    notifyListeners();
  }

  // --- Favorites Management ---
  bool isFavorite(int questionId) => favoriteQuestionIds.contains(questionId);

  Future<void> toggleFavorite(int questionId) async {
    if (favoriteQuestionIds.contains(questionId)) {
      favoriteQuestionIds.remove(questionId);
    } else {
      favoriteQuestionIds.add(questionId);
    }
    await StorageService.saveFavorites(
      favoriteQuestionIds.toList(),
      profile.id,
    );
    if (favoriteQuestionIds.length >= 5 &&
        !profile.unlockedBadges.contains('favorite_collector')) {
      _unlockBadge('favorite_collector', []);
      saveProfile();
    }
    notifyListeners();
  }

  List<Question> getFavoriteQuestions() {
    return allQuestions
        .where((q) => favoriteQuestionIds.contains(q.id))
        .toList();
  }

  // --- Mistakes Management ---
  void recordMistake(int questionId) {
    mistakeQuestionIds.add(questionId);
    StorageService.saveMistakes(mistakeQuestionIds.toList(), profile.id);
    notifyListeners();
  }

  void removeMistake(int questionId) {
    if (mistakeQuestionIds.remove(questionId)) {
      StorageService.saveMistakes(mistakeQuestionIds.toList(), profile.id);
      notifyListeners();
    }
  }

  List<Question> getMistakeQuestions() {
    return allQuestions
        .where((q) => mistakeQuestionIds.contains(q.id))
        .toList();
  }

  // --- Daily Challenge & Wisdom ---
  String get todayDateKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  bool get isTodayDailyCompleted => dailyHistory.containsKey(todayDateKey);
  int? get todayDailyScore => dailyHistory[todayDateKey];

  Question get todayKnowledgeQuestion {
    final now = DateTime.now();
    final daySeed = now.year * 365 + now.month * 31 + now.day;
    final idx = daySeed % allQuestions.length;
    return allQuestions[idx];
  }

  List<Question> getTodayDailyQuestions({int count = 5}) {
    final now = DateTime.now();
    final daySeed = now.year * 10000 + now.month * 100 + now.day;
    final list = List<Question>.from(allQuestions);
    for (int i = list.length - 1; i > 0; i--) {
      final j = (daySeed * (i + 1) + 17) % (i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
    return list.take(count).toList();
  }

  // --- Session Configuration ---
  void selectGameConfig(
    String mode,
    String val, {
    QuizMode? modeType,
    int? count,
  }) {
    selectedMode = mode;
    selectedVal = val;
    if (modeType != null) quizMode = modeType;
    if (count != null) requestedQuestionCount = count;
    notifyListeners();
  }

  List<String> getCategories() {
    final cats = <String>{};
    for (final q in allQuestions) {
      cats.add(q.category);
    }
    return cats.toList();
  }

  int getCategoryQuestionCount(String category) {
    return allQuestions.where((q) => q.category == category).length;
  }

  bool startFriendChallenge({
    required List<int> questionIds,
    QuizMode mode = QuizMode.challenge,
  }) {
    final questions = <Question>[];
    for (final id in questionIds) {
      final match = allQuestions.cast<Question?>().firstWhere(
        (q) => q?.id == id,
        orElse: () => null,
      );
      if (match != null) questions.add(match);
    }
    if (questions.isEmpty) return false;
    selectGameConfig('friend_challenge', 'challenge', modeType: mode);
    return prepareQuizSession(
      customQuestions: questions,
      mode: mode,
    );
  }

  bool prepareQuizSession({
    int? count,
    QuizMode? mode,
    List<Question>? customQuestions,
  }) {
    if (mode != null) quizMode = mode;
    final targetCount = count ?? requestedQuestionCount;

    List<Question> pool;

    if (customQuestions != null && customQuestions.isNotEmpty) {
      pool = List<Question>.from(customQuestions);
      if (selectedMode != 'friend_challenge') {
        pool.shuffle();
      }
    } else if (selectedMode == 'daily') {
      pool = getTodayDailyQuestions(count: 5);
    } else if (selectedMode == 'mistakes') {
      pool = getMistakeQuestions();
      pool.shuffle();
    } else if (selectedMode == 'favorites') {
      pool = getFavoriteQuestions();
      pool.shuffle();
    } else if (selectedMode == 'difficulty') {
      pool = allQuestions.where((q) => q.difficulty == selectedVal).toList();
      pool.shuffle();
      final defaultCount = difficultyQuestionCounts[selectedVal] ?? 10;
      pool = pool.take(count ?? defaultCount).toList();
    } else if (selectedMode == 'all') {
      pool = List<Question>.from(allQuestions);
      pool.shuffle();
      pool = pool.take(targetCount).toList();
    } else {
      // category mode
      pool = allQuestions.where((q) => q.category == selectedVal).toList();
      pool.shuffle();
      pool = pool.take(targetCount).toList();
    }

    if (pool.isEmpty) return false;

    quizQuestions = pool;
    currentQuestionIdx = 0;
    score = 0;
    correctAnswers = 0;
    wrongAnswers = 0;
    timeSpent = 0;
    xpEarnedInRun = 0;
    answersLog = [];
    hasAnswered = false;

    _questionTimer?.cancel();
    _updateQuestionTimer();
    _startRunTimer();

    notifyListeners();
    return true;
  }

  void _updateQuestionTimer() {
    if (currentQuestionIdx < quizQuestions.length) {
      if (quizMode == QuizMode.learning) {
        totalQuestionTime = 0;
        questionTimeLeft = 0;
      } else {
        final q = quizQuestions[currentQuestionIdx];
        totalQuestionTime = difficultyTimers[q.difficulty] ?? 20;
        questionTimeLeft = totalQuestionTime;
      }
    }
  }

  void _startRunTimer() {
    _runTimer?.cancel();
    _runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      timeSpent++;
    });
  }

  void startQuestionCountdown(VoidCallback onTimeout, VoidCallback onTick) {
    _questionTimer?.cancel();
    _activeOnTimeout = onTimeout;
    _activeOnTick = onTick;

    if (quizMode == QuizMode.learning) {
      questionTimeLeft = 0;
      notifyListeners();
      return;
    }

    questionTimeLeft = totalQuestionTime;
    notifyListeners();

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      questionTimeLeft--;
      onTick();
      AudioFeedbackService.instance.playCountdownAlert(questionTimeLeft);
      if (questionTimeLeft <= 0) {
        _questionTimer?.cancel();
        onTimeout();
      }
      notifyListeners();
    });
  }

  void pauseTimers() {
    _runTimer?.cancel();
    _questionTimer?.cancel();
  }

  void resumeTimers() {
    if (hasAnswered) return;
    _startRunTimer();
    if (quizMode == QuizMode.challenge &&
        questionTimeLeft > 0 &&
        _activeOnTimeout != null &&
        _activeOnTick != null) {
      _questionTimer?.cancel();
      _questionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        questionTimeLeft--;
        _activeOnTick!();
        AudioFeedbackService.instance.playCountdownAlert(questionTimeLeft);
        if (questionTimeLeft <= 0) {
          _questionTimer?.cancel();
          _activeOnTimeout!();
        }
        notifyListeners();
      });
    }
  }

  void handleAnswerSelection(int selectedIdx) {
    final currentQ = quizQuestions[currentQuestionIdx];
    final isCorrect = selectedIdx == currentQ.correct;

    // Check if re-answering a previously answered question (during review)
    if (currentQuestionIdx < answersLog.length) {
      final oldLog = answersLog[currentQuestionIdx];
      if (oldLog.isCorrect && !isCorrect) {
        correctAnswers--;
        wrongAnswers++;
        final points = difficultyPoints[currentQ.difficulty] ?? 10;
        score -= points;
        recordMistake(currentQ.id);
      } else if (!oldLog.isCorrect && isCorrect) {
        wrongAnswers--;
        correctAnswers++;
        final points = difficultyPoints[currentQ.difficulty] ?? 10;
        score += points;
        removeMistake(currentQ.id);
      }
      oldLog.selected = selectedIdx;
      oldLog.isCorrect = isCorrect;
      hasAnswered = true;
      _questionTimer?.cancel();

      if (isCorrect) {
        AudioFeedbackService.instance.playCorrect();
      } else {
        AudioFeedbackService.instance.playIncorrect();
      }
      notifyListeners();
      return;
    }

    if (hasAnswered) return;
    hasAnswered = true;
    _questionTimer?.cancel();

    answersLog.add(
      AnswerLog(
        questionId: currentQ.id,
        question: currentQ.question,
        category: currentQ.category,
        choices: currentQ.choices,
        selected: selectedIdx,
        correct: currentQ.correct,
        isCorrect: isCorrect,
      ),
    );

    if (isCorrect) {
      correctAnswers++;
      final points = difficultyPoints[currentQ.difficulty] ?? 10;
      score += points;
      removeMistake(currentQ.id);
      AudioFeedbackService.instance.playCorrect();
    } else {
      wrongAnswers++;
      recordMistake(currentQ.id);
      AudioFeedbackService.instance.playIncorrect();
    }

    notifyListeners();
  }

  void handleAnswerTimeout() {
    if (hasAnswered) return;
    hasAnswered = true;
    _questionTimer?.cancel();
    wrongAnswers++;

    final currentQ = quizQuestions[currentQuestionIdx];
    recordMistake(currentQ.id);

    answersLog.add(
      AnswerLog(
        questionId: currentQ.id,
        question: currentQ.question,
        category: currentQ.category,
        choices: currentQ.choices,
        selected: -1,
        correct: currentQ.correct,
        isCorrect: false,
      ),
    );

    AudioFeedbackService.instance.playIncorrect();
    notifyListeners();
  }

  void jumpToQuestion(int idx) {
    if (idx >= 0 && idx < quizQuestions.length) {
      currentQuestionIdx = idx;
      hasAnswered = idx < answersLog.length;
      _updateQuestionTimer();
      notifyListeners();
    }
  }

  bool moveToNextQuestion() {
    if (currentQuestionIdx < quizQuestions.length - 1) {
      currentQuestionIdx++;
      hasAnswered = currentQuestionIdx < answersLog.length;
      _updateQuestionTimer();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool get isLastQuestion => currentQuestionIdx >= quizQuestions.length - 1;

  Question get currentQuestion => quizQuestions[currentQuestionIdx];

  double get quizProgress => quizQuestions.isEmpty
      ? 0
      : (currentQuestionIdx + 1) / quizQuestions.length;

  FinishResult finishQuizSession() {
    _runTimer?.cancel();
    _questionTimer?.cancel();

    final percent = quizQuestions.isEmpty
        ? 0
        : ((correctAnswers / quizQuestions.length) * 100).round();

    int xpEarned = score;
    if (percent == 100) {
      xpEarned += 50;
    } else if (percent >= 80) {
      xpEarned += 20;
    }

    if (selectedMode == 'daily') {
      final wasAlreadyCompleted = dailyHistory.containsKey(todayDateKey);
      if (!wasAlreadyCompleted) {
        xpEarned += 100;
      }
      dailyHistory[todayDateKey] = percent;
      StorageService.saveDailyRecord(todayDateKey, percent, profile.id);
    }

    for (final q in quizQuestions) {
      if (!profile.testedCategories.contains(q.category)) {
        profile.testedCategories.add(q.category);
      }
    }

    xpEarnedInRun = xpEarned;

    profile.totalQuizzes++;
    profile.totalQuestionsAnswered += quizQuestions.length;
    profile.totalCorrectAnswers += correctAnswers;
    profile.totalXp += xpEarned;
    if (percent > profile.bestScorePercent) {
      profile.bestScorePercent = percent;
    }

    final newBadges = _checkAndUnlockBadges(percent);
    saveProfile();

    // Record in local leaderboard
    final entry = LeaderboardEntry(
      id: 'entry_${DateTime.now().millisecondsSinceEpoch}',
      profileId: profile.id,
      profileName: profile.displayName,
      score: xpEarned,
      totalQuestions: quizQuestions.length,
      accuracy: percent,
      difficulty: selectedVal,
      category: selectedMode == 'category' ? selectedVal : 'مختلط',
      quizMode: quizMode == QuizMode.learning ? 'learning' : 'challenge',
      date: DateTime.now(),
    );
    addLeaderboardEntry(entry);

    AudioFeedbackService.instance.playQuizComplete();
    notifyListeners();

    return FinishResult(
      percent: percent,
      xpEarned: xpEarned,
      newBadges: newBadges,
      correctCount: correctAnswers,
      wrongCount: wrongAnswers,
      timeSpent: timeSpent,
      totalQuestions: quizQuestions.length,
    );
  }

  List<Badge> _checkAndUnlockBadges(int runPercent) {
    final newlyUnlocked = <Badge>[];

    // 1. أول اختبار بنجاح (first_quiz)
    if (!profile.unlockedBadges.contains('first_quiz') &&
        profile.totalQuizzes >= 1 &&
        runPercent >= 50) {
      _unlockBadge('first_quiz', newlyUnlocked);
    }

    // 2. طالب علم مجتهد: 10 اختبارات مكتملة (quiz_10)
    if (!profile.unlockedBadges.contains('quiz_10') &&
        profile.totalQuizzes >= 10) {
      _unlockBadge('quiz_10', newlyUnlocked);
    }

    // 3. حافظ متقن: 100% في أي اختبار (perfect_score)
    if (!profile.unlockedBadges.contains('perfect_score') &&
        runPercent == 100) {
      _unlockBadge('perfect_score', newlyUnlocked);
    }

    // 4. عالم المستقبل: اجتياز اختبار متقدم أو خبير بنسبة 70% فأكثر (hard_core)
    if (!profile.unlockedBadges.contains('hard_core') &&
        selectedMode == 'difficulty' &&
        (selectedVal == 'hard' || selectedVal == 'expert') &&
        runPercent >= 70) {
      _unlockBadge('hard_core', newlyUnlocked);
    }

    // 5. محب السنة: 5 إجابات متتالية صحيحة في الحديث الشريف (hadith_streak)
    if (!profile.unlockedBadges.contains('hadith_streak')) {
      int maxStreak = 0, tempStreak = 0;
      for (final log in answersLog) {
        if (log.category == 'الحديث الشريف') {
          if (log.isCorrect) {
            tempStreak++;
            if (tempStreak > maxStreak) maxStreak = tempStreak;
          } else {
            tempStreak = 0;
          }
        }
      }
      if (maxStreak >= 5) _unlockBadge('hadith_streak', newlyUnlocked);
    }

    // 6. صديق القرآن: 5 إجابات متتالية صحيحة في القرآن الكريم (quran_streak)
    if (!profile.unlockedBadges.contains('quran_streak')) {
      int maxStreak = 0, tempStreak = 0;
      for (final log in answersLog) {
        if (log.category == 'القرآن الكريم') {
          if (log.isCorrect) {
            tempStreak++;
            if (tempStreak > maxStreak) maxStreak = tempStreak;
          } else {
            tempStreak = 0;
          }
        }
      }
      if (maxStreak >= 5) _unlockBadge('quran_streak', newlyUnlocked);
    }

    // 7. سادن المعرفة: تجاوز 500 XP (xp_master)
    if (!profile.unlockedBadges.contains('xp_master') &&
        profile.totalXp >= 500) {
      _unlockBadge('xp_master', newlyUnlocked);
    }

    // 8. بحر العلوم: تجاوز 1500 XP (xp_grandmaster)
    if (!profile.unlockedBadges.contains('xp_grandmaster') &&
        profile.totalXp >= 1500) {
      _unlockBadge('xp_grandmaster', newlyUnlocked);
    }

    // 9. مداوم على التحدي / فارس التحدي اليومي (daily_champion)
    if (!profile.unlockedBadges.contains('daily_champion') &&
        selectedMode == 'daily' &&
        runPercent >= 60) {
      _unlockBadge('daily_champion', newlyUnlocked);
    }

    // 10. جامع الفوائد: 5 مفضلة فأكثر (favorite_collector)
    if (!profile.unlockedBadges.contains('favorite_collector') &&
        favoriteQuestionIds.length >= 5) {
      _unlockBadge('favorite_collector', newlyUnlocked);
    }

    // 11. المصحح المثابر: مراجعة وتصحيح الأخطاء بنسبة 80% فأكثر (mistake_corrector)
    if (!profile.unlockedBadges.contains('mistake_corrector') &&
        selectedMode == 'mistakes' &&
        runPercent >= 80) {
      _unlockBadge('mistake_corrector', newlyUnlocked);
    }

    // 12. موسوعي الثقافة: إجراء اختبارات في 5 تصنيفات مختلفة (polymath)
    if (!profile.unlockedBadges.contains('polymath') &&
        profile.testedCategories.length >= 5) {
      _unlockBadge('polymath', newlyUnlocked);
    }

    return newlyUnlocked;
  }

  void _unlockBadge(String badgeId, List<Badge> newlyUnlocked) {
    profile.unlockedBadges.add(badgeId);
    final badge = allBadges.cast<Badge?>().firstWhere(
      (b) => b?.id == badgeId,
      orElse: () => null,
    );
    if (badge != null) {
      newlyUnlocked.add(badge);
    }
  }

  Future<void> resetAllData() async {
    profile = UserProfile();
    localProfiles = [profile];
    leaderboardEntries.clear();
    favoriteQuestionIds.clear();
    mistakeQuestionIds.clear();
    dailyHistory.clear();
    await StorageService.resetAll();
    notifyListeners();
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _runTimer?.cancel();
    _questionTimer?.cancel();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}

class FinishResult {
  final int percent;
  final int xpEarned;
  final List<Badge> newBadges;
  final int correctCount;
  final int wrongCount;
  final int timeSpent;
  final int totalQuestions;

  FinishResult({
    required this.percent,
    required this.xpEarned,
    required this.newBadges,
    required this.correctCount,
    required this.wrongCount,
    required this.timeSpent,
    required this.totalQuestions,
  });

  String get performanceLevel {
    if (percent == 100) return 'حافظ النخبة';
    if (percent >= 80) return 'طالب علم متمكن';
    if (percent >= 50) return 'باحث متوسط';
    return 'مستكشف مبتدئ';
  }

  String get motivationalTitle {
    if (percent == 100) return 'ما شاء الله! أداء معجز وكامل';
    if (percent >= 80) return 'أحسنت! أداء متميز ومبدع';
    if (percent >= 50) return 'أداء حسن ولديك معرفة طيبة';
    return 'أداء مقبول وبداية جيدة لمسيرتك';
  }

  String get motivationalDesc {
    if (percent == 100) {
      return 'بارك الله في علمك وحفظك، لقد أجبت على كافة الأسئلة بدقة بالغة واستحققت وسام الشرف المعرفي.';
    }
    if (percent >= 80) {
      return 'لقد أظهرت إلماماً واسعاً بمسائل العلوم الشرعية والتاريخ الإسلامي. استمر في طلب العلم النافع.';
    }
    if (percent >= 50) {
      return 'إنجاز جيد جداً، وننصحك بمواصلة القراءة والمراجعة لترقية مستواك المعرفي لآفاق أرحب.';
    }
    return 'العلم بالتعلم والتدبر، هذا الاختبار فرصة رائعة لاكتساب معلومات إضافية. أعد المحاولة مجدداً لتتحسن أكثر.';
  }

  String get formattedTime {
    final mins = timeSpent ~/ 60;
    final secs = timeSpent % 60;
    return mins > 0 ? '$mins د و $secs ث' : '$secs ثانية';
  }
}

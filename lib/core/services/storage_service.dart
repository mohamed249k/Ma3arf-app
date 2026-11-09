import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _profileKey = 'ma3arf_profile';
  static const String _themeKey = 'ma3arf_theme';
  static const String _favoritesKey = 'ma3arf_favorites';
  static const String _mistakesKey = 'ma3arf_mistakes';
  static const String _dailyKey = 'ma3arf_daily_history';
  static const String _soundKey = 'ma3arf_sound_enabled';
  static const String _profilesKey = 'ma3arf_local_profiles';
  static const String _activeProfileIdKey = 'ma3arf_active_profile_id';
  static const String _leaderboardKey = 'ma3arf_local_leaderboard';
  static const String _feedbackKey = 'ma3arf_feedback_drafts';

  static Future<void> saveProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile));
  }

  static Future<Map<String, dynamic>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_profileKey);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
        return _defaultProfile();
      } catch (_) {
        return _defaultProfile();
      }
    }
    return _defaultProfile();
  }

  static Map<String, dynamic> _defaultProfile() {
    return {
      'id': 'profile_default',
      'displayName': 'المستخدم الرئيسي',
      'totalQuizzes': 0,
      'totalQuestionsAnswered': 0,
      'totalCorrectAnswers': 0,
      'totalXp': 0,
      'bestScorePercent': 0,
      'unlockedBadges': <String>[],
    };
  }

  // --- Sound Setting ---
  static Future<void> saveSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, enabled);
  }

  static Future<bool> loadSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true so sound feedback works out of the box
    return prefs.getBool(_soundKey) ?? true;
  }

  // --- Theme ---
  static Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  static Future<String> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'dark';
  }

  // --- Helpers for Profile Isolation ---
  static String _favoritesKeyFor([String? profileId]) {
    if (profileId == null || profileId == 'profile_default') {
      return _favoritesKey;
    }
    return '${_favoritesKey}_$profileId';
  }

  static String _mistakesKeyFor([String? profileId]) {
    if (profileId == null || profileId == 'profile_default') {
      return _mistakesKey;
    }
    return '${_mistakesKey}_$profileId';
  }

  static String _dailyKeyFor([String? profileId]) {
    if (profileId == null || profileId == 'profile_default') {
      return _dailyKey;
    }
    return '${_dailyKey}_$profileId';
  }

  // --- Favorites / Bookmarks ---
  static Future<void> saveFavorites(
    List<int> favoriteIds, [
    String? profileId,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKeyFor(profileId), jsonEncode(favoriteIds));
  }

  static Future<List<int>> loadFavorites([String? profileId]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _favoritesKeyFor(profileId);
    final saved = prefs.getString(key);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is List) {
          return decoded.map((e) => (e as num).toInt()).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  // --- Mistakes Tracking ---
  static Future<void> saveMistakes(
    List<int> mistakeIds, [
    String? profileId,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mistakesKeyFor(profileId), jsonEncode(mistakeIds));
  }

  static Future<List<int>> loadMistakes([String? profileId]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _mistakesKeyFor(profileId);
    final saved = prefs.getString(key);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is List) {
          return decoded.map((e) => (e as num).toInt()).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  // --- Daily Challenge History ---
  static Future<void> saveDailyRecord(
    String dateKey,
    int score, [
    String? profileId,
  ]) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await loadDailyRecords(profileId);
    records[dateKey] = score;
    await prefs.setString(_dailyKeyFor(profileId), jsonEncode(records));
  }

  static Future<Map<String, int>> loadDailyRecords([String? profileId]) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dailyKeyFor(profileId);
    final saved = prefs.getString(key);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is Map) {
          return decoded.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          );
        }
      } catch (_) {}
    }
    return {};
  }

  static Future<void> deleteProfileData(String profileId) async {
    if (profileId == 'profile_default') return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_favoritesKeyFor(profileId));
    await prefs.remove(_mistakesKeyFor(profileId));
    await prefs.remove(_dailyKeyFor(profileId));
  }

  // --- Local Profiles Management ---
  static Future<void> saveProfiles(List<Map<String, dynamic>> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilesKey, jsonEncode(profiles));
  }

  static Future<List<Map<String, dynamic>>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_profilesKey);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is List) {
          return decoded
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      } catch (_) {}
    }
    return [
      {
        'id': 'profile_default',
        'displayName': 'المستخدم الرئيسي',
        'createdAt': DateTime.now().toIso8601String(),
        'totalQuizzes': 0,
        'totalQuestionsAnswered': 0,
        'totalCorrectAnswers': 0,
        'totalXp': 0,
        'bestScorePercent': 0,
      },
    ];
  }

  static Future<void> saveActiveProfileId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileIdKey, id);
  }

  static Future<String> loadActiveProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileIdKey) ?? 'profile_default';
  }

  // --- Local Leaderboard History ---
  static Future<void> saveLeaderboard(
    List<Map<String, dynamic>> entries,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_leaderboardKey, jsonEncode(entries));
  }

  static Future<List<Map<String, dynamic>>> loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_leaderboardKey);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is List) {
          return decoded
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      } catch (_) {}
    }
    return [];
  }

  // --- Feedback Drafts ---
  static Future<void> saveFeedbackDrafts(
    List<Map<String, dynamic>> drafts,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_feedbackKey, jsonEncode(drafts));
  }

  static Future<List<Map<String, dynamic>>> loadFeedbackDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_feedbackKey);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved);
        if (decoded is List) {
          return decoded
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
      } catch (_) {}
    }
    return [];
  }

  static Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_themeKey) ?? 'dark';
    final sound = prefs.getBool(_soundKey) ?? false;
    await prefs.remove(_profileKey);
    await prefs.remove(_favoritesKey);
    await prefs.remove(_mistakesKey);
    await prefs.remove(_dailyKey);
    await prefs.remove(_profilesKey);
    await prefs.remove(_activeProfileIdKey);
    await prefs.remove(_leaderboardKey);
    await prefs.remove(_feedbackKey);
    await prefs.setString(_themeKey, theme);
    await prefs.setBool(_soundKey, sound);
  }
}

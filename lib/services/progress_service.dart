import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../course/course_catalog.dart';

class ProgressService {
  /// DEV: Test için tüm modülleri ve bölümleri kilitsiz gösterir.
  /// Üretime çıkarken false yap.
  static const bool devUnlockAllModules = true;

  static const _kTotalProgress = "totalProgress"; // 0-100
  static const _kTotalXp = "totalXp";

  static String _kModuleUnlocked(String code) => "${code}_unlocked";
  static String _kModuleCompleted(String code) => "${code}_completed";
  static String _kModuleProgress(String code) => "${code}_progress"; // 0-100
  static String _kSectionCompleted(String code, String section) =>
      "${code}_section_$section";
  static String _kModuleCompletedDate(String code) =>
      "${code}_completed_date"; // yyyy-mm-dd

  // Streak
  static const _kStreak = "streak";
  static const _kLastStudyYmd = "lastStudyYmd"; // yyyy-mm-dd

  // Study plan
  static const _kDailyTargetMinutes = "dailyTargetMinutes"; // 15/30/45
  static String _kDoneMinutesYmd(String ymd) => "doneMinutes_$ymd";

  // Study log
  static const _kLastStudyLog =
      "lastStudyLog"; // "2026-02-24 • Bölüm tamamlandı (+10dk)"

  // Resume / Last Position
  static const _kLastPosModule = "lastPosModule";
  static const _kLastPosSection = "lastPosSection";
  static const _kLastPosAt = "lastPosAt"; // yyyy-mm-dd

  // Manual minutes cap
  static const int manualDailyCapMinutes = 30;
  static String _kManualAddedYmd(String ymd) => "manualAdded_$ymd";

  // Daily mission system
  static const _kDailyMissionDate = "dailyMissionDate";
  static const _kDailyVocabDone = "dailyVocabDone";
  static const _kDailyListeningDone = "dailyListeningDone";
  static const _kDailySpeakingDone = "dailySpeakingDone";
  static const _kDailyQuizDone = "dailyQuizDone";
  static const _kDailyGoalVocab = 5;
  static const _kDailyGoalListening = 2;
  static const _kDailyGoalSpeaking = 2;
  static const _kDailyGoalQuiz = 1;

  // Wrong pool / simple SRS foundation
  static const _kWrongWordPool = "wrongWordPool";
  static const _kWrongWordMeta = "wrongWordMeta";

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // ------------------------------------------------------------
  // BOOTSTRAP
  // ------------------------------------------------------------

  /// Uygulama açılışında kursu ilk kez ayaklandırır.
  /// - Modül 1'i unlock eder
  /// - Diğer modülleri kilitler (devUnlockAllModules true ise kilit mantığı bypass)
  Future<void> ensureCourseBoot() async {
    final p = await _prefs;

    // Daha önce boot edildi mi?
    // (Modül-1 unlock key'i varsa boot edilmiş sayıyoruz)
    final booted = p.containsKey(_kModuleUnlocked(CourseCatalog.firstModuleCode));
    if (!booted) {
      // İlk modül unlock
      await p.setBool(_kModuleUnlocked(CourseCatalog.firstModuleCode), true);

      // Diğer modüller default kilitli (devUnlockAllModules true olsa bile kayıt dursun)
      for (final code in CourseCatalog.moduleCodes) {
        if (code == CourseCatalog.firstModuleCode) continue;
        await p.setBool(_kModuleUnlocked(code), false);
      }

      // İlk kurulum log
      await p.setString(_kLastStudyLog, "${todayYmd()} • Kurs başlatıldı");
    }

    await ensureDailyMissions();
  }

  // ------------------------------------------------------------
  // CORE
  // ------------------------------------------------------------

  Future<int> getTotalProgress() async =>
      (await _prefs).getInt(_kTotalProgress) ?? 0;

  Future<void> _setTotalProgress(int value) async =>
      (await _prefs).setInt(_kTotalProgress, value.clamp(0, 100));

  Future<int> getTotalXp() async => (await _prefs).getInt(_kTotalXp) ?? 0;

  Future<void> addXp(int xp) async {
    final p = await _prefs;
    final current = p.getInt(_kTotalXp) ?? 0;
    final safeXp = xp < 0 ? 0 : xp;
    await p.setInt(_kTotalXp, current + safeXp);
  }

  Future<int> getLevel() async {
    final xp = await getTotalXp();
    return (xp ~/ 100) + 1;
  }

  Future<int> getXpIntoCurrentLevel() async {
    final xp = await getTotalXp();
    return xp % 100;
  }

  Future<int> getXpForNextLevel() async => 100;

  Future<double> getLevelProgress() async {
    final current = await getXpIntoCurrentLevel();
    return current / 100.0;
  }

  // ------------------------------------------------------------
  // MODULE LOCKS
  // ------------------------------------------------------------

  Future<bool> isModuleUnlocked(String code) async {
    if (devUnlockAllModules) return true;
    return (await _prefs).getBool(_kModuleUnlocked(code)) ?? false;
  }

  Future<void> setModuleUnlocked(String code, bool v) async =>
      (await _prefs).setBool(_kModuleUnlocked(code), v);

  Future<bool> isModuleCompleted(String code) async =>
      (await _prefs).getBool(_kModuleCompleted(code)) ?? false;

  Future<void> setModuleCompleted(String code, bool v) async =>
      (await _prefs).setBool(_kModuleCompleted(code), v);

  Future<int> getModuleProgress(String code) async =>
      (await _prefs).getInt(_kModuleProgress(code)) ?? 0;

  Future<void> setModuleProgress(String code, int value) async =>
      (await _prefs).setInt(_kModuleProgress(code), value.clamp(0, 100));

  Future<bool> isSectionCompleted(String code, String sectionKey) async =>
      (await _prefs).getBool(_kSectionCompleted(code, sectionKey)) ?? false;

  Future<void> setSectionCompleted(
    String code,
    String sectionKey,
    bool v,
  ) async =>
      (await _prefs).setBool(_kSectionCompleted(code, sectionKey), v);

  // ------------------------------------------------------------
  // COMPLETION DATE
  // ------------------------------------------------------------

  Future<String?> getModuleCompletedDate(String code) async =>
      (await _prefs).getString(_kModuleCompletedDate(code));

  Future<void> _setModuleCompletedDate(String code) async {
    final p = await _prefs;
    await p.setString(_kModuleCompletedDate(code), todayYmd());
  }

  // ------------------------------------------------------------
  // STREAK
  // ------------------------------------------------------------

  Future<int> getStreak() async => (await _prefs).getInt(_kStreak) ?? 0;

  static String todayYmd() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> markStudyToday() async {
    final p = await _prefs;

    final today = todayYmd();
    final last = p.getString(_kLastStudyYmd);

    if (last == null) {
      await p.setInt(_kStreak, 1);
      await p.setString(_kLastStudyYmd, today);
      return;
    }

    if (last == today) return;

    final lastDate = DateTime.tryParse(last);
    final todayDate = DateTime.tryParse(today);
    if (lastDate != null && todayDate != null) {
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 1) {
        final current = p.getInt(_kStreak) ?? 0;
        await p.setInt(_kStreak, current + 1);
      } else {
        await p.setInt(_kStreak, 1);
      }
    } else {
      await p.setInt(_kStreak, 1);
    }

    await p.setString(_kLastStudyYmd, today);
  }

  // ------------------------------------------------------------
  // DAILY MISSIONS
  // ------------------------------------------------------------

  Future<void> ensureDailyMissions() async {
    final p = await _prefs;
    final today = todayYmd();
    final savedDate = p.getString(_kDailyMissionDate);

    if (savedDate == today) return;

    await p.setString(_kDailyMissionDate, today);
    await p.setInt(_kDailyVocabDone, 0);
    await p.setInt(_kDailyListeningDone, 0);
    await p.setInt(_kDailySpeakingDone, 0);
    await p.setInt(_kDailyQuizDone, 0);
  }

  Future<Map<String, int>> getDailyGoals() async {
    return {
      'vocab': _kDailyGoalVocab,
      'listening': _kDailyGoalListening,
      'speaking': _kDailyGoalSpeaking,
      'quiz': _kDailyGoalQuiz,
    };
  }

  Future<Map<String, int>> getDailyProgress() async {
    await ensureDailyMissions();
    final p = await _prefs;
    return {
      'vocab': p.getInt(_kDailyVocabDone) ?? 0,
      'listening': p.getInt(_kDailyListeningDone) ?? 0,
      'speaking': p.getInt(_kDailySpeakingDone) ?? 0,
      'quiz': p.getInt(_kDailyQuizDone) ?? 0,
    };
  }

  Future<int> getDailyCompletedCount() async {
    final progress = await getDailyProgress();
    final goals = await getDailyGoals();

    int done = 0;
    if ((progress['vocab'] ?? 0) >= (goals['vocab'] ?? 0)) done++;
    if ((progress['listening'] ?? 0) >= (goals['listening'] ?? 0)) done++;
    if ((progress['speaking'] ?? 0) >= (goals['speaking'] ?? 0)) done++;
    if ((progress['quiz'] ?? 0) >= (goals['quiz'] ?? 0)) done++;
    return done;
  }

  Future<bool> isDailyMissionCompleted() async =>
      (await getDailyCompletedCount()) >= 4;

  Future<Map<String, dynamic>> getDailyMissionSnapshot() async {
    final progress = await getDailyProgress();
    final goals = await getDailyGoals();
    final rate = await getDailyCompletionRate();
    final streak = await getStreak();
    final completed = await isDailyMissionCompleted();

    final totalDone =
        (progress['vocab'] ?? 0).clamp(0, goals['vocab'] ?? 0) +
        (progress['listening'] ?? 0).clamp(0, goals['listening'] ?? 0) +
        (progress['speaking'] ?? 0).clamp(0, goals['speaking'] ?? 0) +
        (progress['quiz'] ?? 0).clamp(0, goals['quiz'] ?? 0);

    final totalGoal =
        (goals['vocab'] ?? 5) +
        (goals['listening'] ?? 2) +
        (goals['speaking'] ?? 2) +
        (goals['quiz'] ?? 1);

    return {
      'progress': progress,
      'goals': goals,
      'rate': rate,
      'streak': streak,
      'completed': completed,
      'totalDone': totalDone,
      'totalGoal': totalGoal,
    };
  }

  Future<double> getDailyCompletionRate() async {
    final progress = await getDailyProgress();
    final goals = await getDailyGoals();

    final totalDone =
        (progress['vocab'] ?? 0).clamp(0, goals['vocab'] ?? 0) +
        (progress['listening'] ?? 0).clamp(0, goals['listening'] ?? 0) +
        (progress['speaking'] ?? 0).clamp(0, goals['speaking'] ?? 0) +
        (progress['quiz'] ?? 0).clamp(0, goals['quiz'] ?? 0);

    const totalGoal =
        _kDailyGoalVocab +
        _kDailyGoalListening +
        _kDailyGoalSpeaking +
        _kDailyGoalQuiz;

    return totalDone / totalGoal;
  }

  Future<void> _incrementDailyKey(String key, {int max = 999}) async {
    await ensureDailyMissions();
    final p = await _prefs;
    final current = p.getInt(key) ?? 0;
    if (current >= max) return;
    await p.setInt(key, current + 1);
  }

  Future<void> markDailyVocabDone({int count = 1}) async {
    for (int i = 0; i < count; i++) {
      await _incrementDailyKey(_kDailyVocabDone, max: _kDailyGoalVocab);
    }
    await markStudyToday();
  }

  Future<void> markDailyListeningDone({int count = 1}) async {
    for (int i = 0; i < count; i++) {
      await _incrementDailyKey(
        _kDailyListeningDone,
        max: _kDailyGoalListening,
      );
    }
    await markStudyToday();
  }

  Future<void> markDailySpeakingDone({int count = 1}) async {
    for (int i = 0; i < count; i++) {
      await _incrementDailyKey(_kDailySpeakingDone, max: _kDailyGoalSpeaking);
    }
    await markStudyToday();
  }

  Future<void> markDailyQuizDone({int count = 1}) async {
    for (int i = 0; i < count; i++) {
      await _incrementDailyKey(_kDailyQuizDone, max: _kDailyGoalQuiz);
    }
    await markStudyToday();
  }

  // ------------------------------------------------------------
  // WRONG WORD POOL / SPACED REPETITION
  // ------------------------------------------------------------

  Future<List<String>> getWrongWordPool() async {
    final p = await _prefs;
    final raw = p.getString(_kWrongWordPool);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {
      // ignore broken data
    }
    return [];
  }

  Future<void> _saveWrongWordPool(List<String> items) async {
    final p = await _prefs;
    await p.setString(_kWrongWordPool, jsonEncode(items));
  }

  Future<Map<String, dynamic>> _getWrongWordMetaMap() async {
    final p = await _prefs;
    final raw = p.getString(_kWrongWordMeta);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      // ignore broken data
    }
    return <String, dynamic>{};
  }

  Future<void> _saveWrongWordMetaMap(Map<String, dynamic> meta) async {
    final p = await _prefs;
    await p.setString(_kWrongWordMeta, jsonEncode(meta));
  }

  Duration _reviewDelayForWrongCount(int wrongCount) {
    if (wrongCount <= 1) return Duration.zero;
    if (wrongCount == 2) return const Duration(minutes: 10);
    if (wrongCount == 3) return const Duration(hours: 1);
    if (wrongCount == 4) return const Duration(days: 1);
    return const Duration(days: 3);
  }

  Future<Map<String, dynamic>?> getWrongWordMeta(String word) async {
    final clean = word.trim();
    if (clean.isEmpty) return null;

    final meta = await _getWrongWordMetaMap();
    final item = meta[clean];
    if (item is Map<String, dynamic>) return item;
    if (item is Map) {
      return item.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  Future<Map<String, Map<String, dynamic>>> getAllWrongWordMeta() async {
    final meta = await _getWrongWordMetaMap();
    final out = <String, Map<String, dynamic>>{};

    meta.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        out[key] = value;
      } else if (value is Map) {
        out[key] = value.map((k, v) => MapEntry(k.toString(), v));
      }
    });

    return out;
  }

  Future<void> addWrongWord(String word) async {
    final clean = word.trim();
    if (clean.isEmpty) return;

    final now = DateTime.now();
    final pool = await getWrongWordPool();
    if (!pool.contains(clean)) {
      pool.add(clean);
      await _saveWrongWordPool(pool);
    }

    final meta = await _getWrongWordMetaMap();
    final current = (meta[clean] is Map)
        ? Map<String, dynamic>.from(meta[clean] as Map)
        : <String, dynamic>{};
    final wrongCount = ((current['wrongCount'] as int?) ?? 0) + 1;
    final nextReview = now.add(_reviewDelayForWrongCount(wrongCount));

    meta[clean] = {
      'wrongCount': wrongCount,
      'lastSeen': now.toIso8601String(),
      'nextReview': nextReview.toIso8601String(),
    };
    await _saveWrongWordMetaMap(meta);
  }

  Future<void> removeWrongWord(String word) async {
    final clean = word.trim();
    if (clean.isEmpty) return;

    final pool = await getWrongWordPool();
    pool.removeWhere((e) => e == clean);
    await _saveWrongWordPool(pool);

    final meta = await _getWrongWordMetaMap();
    meta.remove(clean);
    await _saveWrongWordMetaMap(meta);
  }

  Future<void> postponeWrongWord(
    String word, {
    Duration delay = const Duration(days: 1),
  }) async {
    final clean = word.trim();
    if (clean.isEmpty) return;

    final meta = await _getWrongWordMetaMap();
    final current = (meta[clean] is Map)
        ? Map<String, dynamic>.from(meta[clean] as Map)
        : <String, dynamic>{};
    final now = DateTime.now();
    final wrongCount = (current['wrongCount'] as int?) ?? 1;

    meta[clean] = {
      'wrongCount': wrongCount,
      'lastSeen': now.toIso8601String(),
      'nextReview': now.add(delay).toIso8601String(),
    };
    await _saveWrongWordMetaMap(meta);

    final pool = await getWrongWordPool();
    if (!pool.contains(clean)) {
      pool.add(clean);
      await _saveWrongWordPool(pool);
    }
  }

  Future<List<String>> getDueWrongWords() async {
    final pool = await getWrongWordPool();
    if (pool.isEmpty) return [];

    final meta = await _getWrongWordMetaMap();
    final now = DateTime.now();
    final out = <String>[];

    for (final word in pool) {
      final item = meta[word];
      if (item is! Map) {
        out.add(word);
        continue;
      }
      final nextReviewRaw = item['nextReview']?.toString();
      final nextReview = DateTime.tryParse(nextReviewRaw ?? '');
      if (nextReview == null || !nextReview.isAfter(now)) {
        out.add(word);
      }
    }
    return out;
  }

  Future<int> getDueWrongWordCount() async => (await getDueWrongWords()).length;

  Future<void> clearWrongWordPool() async {
    final p = await _prefs;
    await p.remove(_kWrongWordPool);
    await p.remove(_kWrongWordMeta);
  }

  // ------------------------------------------------------------
  // STUDY PLAN
  // ------------------------------------------------------------

  Future<int> getDailyTargetMinutes() async =>
      (await _prefs).getInt(_kDailyTargetMinutes) ?? 15;

  Future<void> setDailyTargetMinutes(int v) async =>
      (await _prefs).setInt(_kDailyTargetMinutes, v);

  /// Projede çağrılan isim: getTodayDoneMinutes()
  Future<int> getTodayDoneMinutes() async => getDoneMinutesToday();

  /// İç motor
  Future<int> getDoneMinutesToday() async {
    final p = await _prefs;
    final today = todayYmd();
    return p.getInt(_kDoneMinutesYmd(today)) ?? 0;
  }

  /// Projede çağrılan isim: addStudyMinutesToday(minutes, reason: ...)
  Future<void> addStudyMinutesToday(
    int minutes, {
    String reason = "Çalışma",
  }) async {
    await addDoneMinutesToday(minutes);
    await markStudyToday();
    await ensureDailyMissions();
    await setLastStudyLog("${todayYmd()} • $reason (+${minutes}dk)");
  }

  /// İç motor
  Future<void> addDoneMinutesToday(int add) async {
    final p = await _prefs;
    final today = todayYmd();
    final current = p.getInt(_kDoneMinutesYmd(today)) ?? 0;
    await p.setInt(_kDoneMinutesYmd(today), current + add);
  }

  /// Manual minutes cap helper
  Future<int> getManualAddedToday() async {
    final p = await _prefs;
    final today = todayYmd();
    return p.getInt(_kManualAddedYmd(today)) ?? 0;
  }

  Future<void> _addManualMinutesToday(int add) async {
    final p = await _prefs;
    final today = todayYmd();
    final current = p.getInt(_kManualAddedYmd(today)) ?? 0;
    await p.setInt(_kManualAddedYmd(today), current + add);
  }

  /// Projede çağrılan isim: addManualStudyMinutesToday(minutes)
  /// Dönüş: gerçekten eklenen dakika (cap yüzünden az olabilir)
  Future<int> addManualStudyMinutesToday(int minutes) async {
    final already = await getManualAddedToday();
    final left = (manualDailyCapMinutes - already).clamp(
      0,
      manualDailyCapMinutes,
    );
    final add = minutes.clamp(0, left);

    if (add <= 0) return 0;

    await _addManualMinutesToday(add);
    await addStudyMinutesToday(add, reason: "Manuel çalışma");

    return add;
  }

  /// Son 7 gün dakika listesi (StudyPlan screen bunu istiyor)
  /// Dönüş: [d0, d1, ... d6] (bugün dahil geriye doğru)
  Future<List<int>> getLast7DaysMinutes() async {
    final p = await _prefs;
    final now = DateTime.now();

    final List<int> out = [];
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      final ymd =
          "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      out.add(p.getInt(_kDoneMinutesYmd(ymd)) ?? 0);
    }
    return out;
  }

  // ------------------------------------------------------------
  // STUDY LOG
  // ------------------------------------------------------------

  Future<String?> getLastStudyLog() async =>
      (await _prefs).getString(_kLastStudyLog);

  Future<void> setLastStudyLog(String text) async =>
      (await _prefs).setString(_kLastStudyLog, text);

  // ------------------------------------------------------------
  // RESUME / LAST POSITION
  // ------------------------------------------------------------

  Future<void> setLastPosition({
    required String moduleCode,
    required String sectionKey,
  }) async {
    final p = await _prefs;
    await p.setString(_kLastPosModule, moduleCode);
    await p.setString(_kLastPosSection, sectionKey);
    await p.setString(_kLastPosAt, todayYmd());
  }

  Future<Map<String, String?>> getLastPosition() async {
    final p = await _prefs;
    return {
      "module": p.getString(_kLastPosModule),
      "section": p.getString(_kLastPosSection),
      "at": p.getString(_kLastPosAt),
    };
  }

  // ------------------------------------------------------------
  // COMPLETION LOGIC
  // ------------------------------------------------------------

  Future<void> completeSection({
    required String moduleCode,
    required String sectionKey,
    required int xpReward,
  }) async {
    final alreadyCompleted = await isSectionCompleted(moduleCode, sectionKey);

    if (!alreadyCompleted) {
      await setSectionCompleted(moduleCode, sectionKey, true);
      await addXp(xpReward);
      await markStudyToday();
      await ensureDailyMissions();

      final normalizedKey = sectionKey.toLowerCase();

      if (normalizedKey.contains('vocab') ||
          normalizedKey.contains('wort') ||
          normalizedKey.contains('kelime')) {
        await markDailyVocabDone();
      } else if (normalizedKey.contains('listen') ||
          normalizedKey.contains('hoer') ||
          normalizedKey.contains('hör') ||
          normalizedKey.contains('dinle')) {
        await markDailyListeningDone();
      } else if (normalizedKey.contains('sprech') ||
          normalizedKey.contains('speak') ||
          normalizedKey.contains('konus')) {
        await markDailySpeakingDone();
      } else if (normalizedKey.contains('quiz') ||
          normalizedKey.contains('exam') ||
          normalizedKey.contains('test')) {
        await markDailyQuizDone();
      }
    }

    final keys = CourseCatalog.sectionKeysFor(moduleCode);
    int done = 0;
    for (final k in keys) {
      if (await isSectionCompleted(moduleCode, k)) done++;
    }

    final progress = keys.isEmpty ? 0 : ((done / keys.length) * 100).round();
    await setModuleProgress(moduleCode, progress);

    int sum = 0;
    for (final code in CourseCatalog.moduleCodes) {
      sum += await getModuleProgress(code);
    }

    final total = CourseCatalog.moduleCodes.isEmpty
        ? 0
        : (sum / CourseCatalog.moduleCodes.length).round();

    await _setTotalProgress(total);

    if (progress >= 100) {
      await completeModule(moduleCode: moduleCode);
    }

    await setLastStudyLog("${todayYmd()} • Bölüm tamamlandı (+$xpReward XP)");
    await setLastPosition(moduleCode: moduleCode, sectionKey: sectionKey);
  }

  /// Projede çağrılan isim: completeModule(moduleCode: ...)
  Future<void> completeModule({required String moduleCode}) async {
    await setModuleCompleted(moduleCode, true);
    await setModuleProgress(moduleCode, 100);
    await _setModuleCompletedDate(moduleCode);

    final next = CourseCatalog.nextOf(moduleCode);
    if (next != null) {
      await setModuleUnlocked(next, true);
    }
  }

  // ------------------------------------------------------------
  // UTILITIES
  // ------------------------------------------------------------

  Future<void> resetAll() async {
    final p = await _prefs;
    await p.clear();
  }

  Future<void> resetAllProgress() async {
    await resetAll();
    await ensureCourseBoot();
  }
}
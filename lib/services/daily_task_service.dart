import 'package:shared_preferences/shared_preferences.dart';

class DailyTaskService {
  static const _dateKey = "daily_date";
  static const _vocabKey = "daily_vocab";
  static const _listenKey = "daily_listen";
  static const _speakKey = "daily_speak";
  static const _quizKey = "daily_quiz";
  static const _streakKey = "daily_streak";

  String _today() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  Future<void> ensureTodayTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _today();

    final stored = prefs.getString(_dateKey);

    if (stored != today) {
      await prefs.setString(_dateKey, today);

      await prefs.setBool(_vocabKey, false);
      await prefs.setBool(_listenKey, false);
      await prefs.setBool(_speakKey, false);
      await prefs.setBool(_quizKey, false);
    }
  }

  Future<void> completeVocab() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vocabKey, true);
  }

  Future<void> completeListen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_listenKey, true);
  }

  Future<void> completeSpeak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_speakKey, true);
  }

  Future<void> completeQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quizKey, true);
  }

  Future<bool> isVocabDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vocabKey) ?? false;
  }

  Future<bool> isListenDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_listenKey) ?? false;
  }

  Future<bool> isSpeakDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_speakKey) ?? false;
  }

  Future<bool> isQuizDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_quizKey) ?? false;
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> increaseStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_streakKey) ?? 0;
    await prefs.setInt(_streakKey, current + 1);
  }
}
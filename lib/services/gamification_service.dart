import 'package:shared_preferences/shared_preferences.dart';

class GamificationService {
  static const _xpKey = "user_xp";
  static const _levelKey = "user_level";
  static const _streakKey = "user_streak";
  static const _lastDayKey = "last_study_day";

  static Future<int> getXP() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_xpKey) ?? 0;
  }

  static Future<int> getLevel() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_levelKey) ?? 1;
  }

  static Future<int> getStreak() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_streakKey) ?? 0;
  }

  static Future<void> addXP(int amount) async {
    final p = await SharedPreferences.getInstance();

    int xp = p.getInt(_xpKey) ?? 0;
    int level = p.getInt(_levelKey) ?? 1;

    xp += amount;

    int required = level * 100;

    if (xp >= required) {
      level++;
      xp = 0;
    }

    await p.setInt(_xpKey, xp);
    await p.setInt(_levelKey, level);
  }

  static Future<void> updateStreak() async {
    final p = await SharedPreferences.getInstance();

    final today = DateTime.now().day;
    final last = p.getInt(_lastDayKey);

    int streak = p.getInt(_streakKey) ?? 0;

    if (last == null) {
      streak = 1;
    } else if (today == last) {
      return;
    } else if (today == last + 1) {
      streak++;
    } else {
      streak = 1;
    }

    await p.setInt(_streakKey, streak);
    await p.setInt(_lastDayKey, today);
  }
}
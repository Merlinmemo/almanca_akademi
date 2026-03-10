import 'dart:math';

import '../../models/word_model.dart';
import '../../modules/modul1/modul1_course_data.dart';

class Modul1WordEngine {
  Modul1WordEngine._();
  static final Modul1WordEngine I = Modul1WordEngine._();

  Random _rnd(String seed) => Random(seed.hashCode & 0x7fffffff);

  List<WordItem> byCategory(String category, {int count = 12, bool shuffle = true}) {
    final items = Modul1CourseData.allWords.where((e) => (e.group ?? '').toLowerCase() == category.toLowerCase()).toList();
    if (shuffle) {
      items.shuffle(Random());
    }
    return items.take(items.length < count ? items.length : count).toList();
  }

  List<WordItem> mixedSession({int count = 16}) {
    final items = List<WordItem>.from(Modul1CourseData.allWords);
    items.shuffle(Random());
    return items.take(items.length < count ? items.length : count).toList();
  }
}

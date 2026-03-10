import 'dart:math';

import '../../models/word_model.dart';
import '../../modules/modul1/modul1_course_data.dart';

class Modul1SentenceCard {
  final String de;
  final String tr;
  final String pron;
  final String category;
  final String tip;

  const Modul1SentenceCard({required this.de, required this.tr, required this.pron, required this.category, required this.tip});
}

class Modul1SentenceEngine {
  Modul1SentenceEngine._();
  static final Modul1SentenceEngine I = Modul1SentenceEngine._();

  Random _rnd(String seed) => Random(seed.hashCode & 0x7fffffff);

  List<Modul1SentenceCard> session({String? category, int count = 12}) {
    final all = List<WordItem>.from(Modul1CourseData.allWords);
    final items = category == null ? all : all.where((e) => (e.group ?? '').toLowerCase() == category.toLowerCase()).toList();
    items.shuffle(Random());
    return items.where((e) => (e.exampleDe ?? '').trim().isNotEmpty).take(items.length < count ? items.length : count).map((e) => Modul1SentenceCard(
      de: e.exampleDe ?? e.de,
      tr: e.exampleTr ?? e.tr,
      pron: e.trPron,
      category: e.group ?? 'Genel',
      tip: e.note ?? 'Cümleyi ritmiyle tekrar et.',
    )).toList();
  }
}

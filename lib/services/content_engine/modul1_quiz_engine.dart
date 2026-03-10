import 'dart:math';

import '../../models/word_model.dart';
import '../../modules/modul1/modul1_course_data.dart';

class Modul1QuizItem {
  final String prompt;
  final String hint;
  final List<String> options;
  final int correctIndex;
  final bool playAudio;
  final String audioText;

  const Modul1QuizItem({required this.prompt, required this.hint, required this.options, required this.correctIndex, required this.playAudio, required this.audioText});
}

class Modul1QuizEngine {
  Modul1QuizEngine._();
  static final Modul1QuizEngine I = Modul1QuizEngine._();

  Random _rnd(String seed) => Random(seed.hashCode & 0x7fffffff);

  List<Modul1QuizItem> build({int count = 15}) {
    final rnd = Random();
    final words = List<WordItem>.from(Modul1CourseData.allWords)..shuffle(rnd);
    final picked = words.take(words.length < count ? words.length : count).toList();
    final out = <Modul1QuizItem>[];
    for (int i = 0; i < picked.length; i++) {
      final w = picked[i];
      final type = i % 4;
      late final String prompt;
      late final String hint;
      late final String correct;
      var playAudio = false;
      var audioText = '';
      if (type == 0) {
        prompt = w.de;
        hint = 'Bu ifadenin Türkçesi hangisi?';
        correct = w.tr;
      } else if (type == 1) {
        prompt = w.exampleDe ?? w.de;
        hint = 'Bu cümlenin Türkçesi hangisi?';
        correct = w.exampleTr ?? w.tr;
      } else if (type == 2) {
        prompt = w.tr;
        hint = 'Bu Türkçeye uygun Almanca ifade hangisi?';
        correct = w.de;
      } else {
        prompt = 'Sesli ifadeyi dinle';
        hint = 'Duyduğun ifadenin doğru Türkçesini seç.';
        correct = w.exampleTr ?? w.tr;
        playAudio = true;
        audioText = w.exampleDe ?? w.de;
      }
      final bag = <String>{correct};
      while (bag.length < 4 && words.isNotEmpty) {
        final other = words[rnd.nextInt(words.length)];
        bag.add(type == 2 ? other.de : (type == 1 || type == 3 ? (other.exampleTr ?? other.tr) : other.tr));
      }
      final opts = bag.toList()..shuffle(rnd);
      out.add(Modul1QuizItem(prompt: prompt, hint: hint, options: opts, correctIndex: opts.indexOf(correct), playAudio: playAudio, audioText: audioText));
    }
    return out;
  }
}

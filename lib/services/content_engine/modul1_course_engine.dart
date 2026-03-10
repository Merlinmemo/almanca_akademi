import 'dart:math';

import '../../models/word_model.dart';
import 'modul1_quiz_engine.dart';
import 'modul1_sentence_engine.dart';
import 'modul1_speaking_engine.dart';
import 'modul1_word_engine.dart';

class Modul1ListeningQuestion {
  final WordItem item;
  final List<String> options;
  final int correctIndex;
  const Modul1ListeningQuestion({required this.item, required this.options, required this.correctIndex});
}

class Modul1ExamQuestion {
  final String prompt;
  final String promptTr;
  final List<String> options;
  final int correctIndex;
  final bool playAudio;
  final String audioText;
  const Modul1ExamQuestion({required this.prompt, required this.promptTr, required this.options, required this.correctIndex, required this.playAudio, required this.audioText});
}

class Modul1SpeakingPrompt {
  final String title;
  final String instruction;
  final String de;
  final String tr;
  final String tip;
  const Modul1SpeakingPrompt({required this.title, required this.instruction, required this.de, required this.tr, required this.tip});
}

class Modul1CourseEngine {
  Modul1CourseEngine._();
  static final Modul1CourseEngine I = Modul1CourseEngine._();

  Random _seeded(String seed) => Random(seed.hashCode & 0x7fffffff);

  List<WordItem> lessonPool({String? category, int count = 12}) => category == null ? Modul1WordEngine.I.mixedSession(count: count) : Modul1WordEngine.I.byCategory(category, count: count);

  List<Modul1ListeningQuestion> buildListeningQuestions({int count = 12}) {
    final rnd = Random();
    final cards = Modul1SentenceEngine.I.session(count: count + 10);
    cards.shuffle(rnd);
    final picked = cards.take(cards.length < count ? cards.length : count).toList();
    return picked.map((card) {
      final correct = card.tr;
      final bag = <String>{correct};
      while (bag.length < 4 && cards.isNotEmpty) {
        bag.add(cards[rnd.nextInt(cards.length)].tr);
      }
      final options = bag.toList()..shuffle(rnd);
      return Modul1ListeningQuestion(
        item: WordItem(de: card.de, tr: card.tr, trPron: card.pron, group: card.category, exampleDe: card.de, exampleTr: card.tr, note: card.tip),
        options: options,
        correctIndex: options.indexOf(correct),
      );
    }).toList();
  }

  List<Modul1ExamQuestion> buildExamQuestions({int count = 15}) {
    return Modul1QuizEngine.I.build(count: count).map((q) => Modul1ExamQuestion(prompt: q.prompt, promptTr: q.hint, options: q.options, correctIndex: q.correctIndex, playAudio: q.playAudio, audioText: q.audioText)).toList();
  }

  List<Modul1SpeakingPrompt> buildSpeakingPrompts({int count = 12}) {
    return Modul1SpeakingEngine.I.build(count: count).map((d) => Modul1SpeakingPrompt(title: d.title, instruction: d.instruction, de: d.de, tr: d.tr, tip: d.tip)).toList();
  }
}

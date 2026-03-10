import 'dart:math';

import '../../models/word_model.dart';
import '../../modules/modul1/modul1_course_data.dart';

class Modul1SpeakingDrill {
  final String title;
  final String instruction;
  final String de;
  final String tr;
  final String tip;

  const Modul1SpeakingDrill({required this.title, required this.instruction, required this.de, required this.tr, required this.tip});
}

class Modul1SpeakingEngine {
  Modul1SpeakingEngine._();
  static final Modul1SpeakingEngine I = Modul1SpeakingEngine._();

  Random _rnd(String seed) => Random(seed.hashCode & 0x7fffffff);

  List<Modul1SpeakingDrill> build({int count = 12}) {
    final rnd = Random();
    final words = List<WordItem>.from(Modul1CourseData.allWords)..shuffle(rnd);
    final drills = <Modul1SpeakingDrill>[
      const Modul1SpeakingDrill(title: 'Selam ver', instruction: 'Önce dinle, sonra aynı ritimle tekrar et.', de: 'Hallo! Guten Morgen! Wie geht es dir?', tr: 'Merhaba! Günaydın! Nasılsın?', tip: 'Hallo ve Guten Morgen arasında kısa durak ver.'),
      const Modul1SpeakingDrill(title: 'Kendini tanıt', instruction: 'Adını, geldiğin yeri ve ne yaptığını söyle.', de: 'Ich heiße Mehmet. Ich komme aus der Türkei. Ich arbeite in einer Werkstatt.', tr: 'Adım Mehmet. Türkiye’den geliyorum. Bir atölyede çalışıyorum.', tip: 'Kendi adını ve şehrini yerleştir.'),
      const Modul1SpeakingDrill(title: 'Saat ve plan', instruction: 'Saat söyleyip kısa plan kur.', de: 'Heute ist Montag. Um acht Uhr arbeite ich und am Abend lerne ich Deutsch.', tr: 'Bugün Pazartesi. Saat sekizde çalışıyorum ve akşam Almanca öğreniyorum.', tip: 'um acht Uhr ve am Abend bölümlerini net söyle.'),
    ];
    for (final w in words.take(words.length < (count - drills.length) ? words.length : (count - drills.length))) {
      drills.add(Modul1SpeakingDrill(title: w.group ?? 'Konuşma', instruction: 'Cümleyi önce dinle, sonra bakarak ve son olarak bakmadan söyle.', de: w.exampleDe ?? w.de, tr: w.exampleTr ?? w.tr, tip: w.note ?? 'Vurgu ve ritmi kopyala.'));
    }
    return drills.take(count).toList();
  }
}

import 'dart:convert';
import 'package:flutter/services.dart';

class A1DataService {
  A1DataService._();
  static final A1DataService I = A1DataService._();

  bool _loaded = false;

  List<String> subjects = const ["Ich", "Du", "Wir"];
  List<String> times = const ["heute", "morgen", "jetzt"];
  List<String> places = const ["zu Hause", "hier", "im Büro", "in Berlin"];

  Map<String, List<String>> themes = const {};
  Map<String, String> trMap = const {};

  List<Map<String, dynamic>> sentenceExamples = const [];

  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;

    try {
      final wordsRaw = await rootBundle.loadString("assets/data/words_basic_a1.json");
      final wordsJson = jsonDecode(wordsRaw) as Map<String, dynamic>;

      subjects = (wordsJson["subjects"] as List).cast<String>();
      times = (wordsJson["times"] as List).cast<String>();
      places = (wordsJson["places"] as List).cast<String>();

      final t = wordsJson["themes"] as Map<String, dynamic>;
      themes = t.map((k, v) => MapEntry(k, (v as List).cast<String>()));

      final tm = wordsJson["trMap"] as Map<String, dynamic>;
      trMap = tm.map((k, v) => MapEntry(k, v.toString()));

      final sentRaw = await rootBundle.loadString("assets/data/sentences_a1.json");
      final sentJson = jsonDecode(sentRaw) as Map<String, dynamic>;
      sentenceExamples = (sentJson["examples"] as List).cast<Map<String, dynamic>>();

      _loaded = true;
    } catch (_) {
      // Asset yoksa ya da hata varsa fallback (app patlamasın)
      _loaded = false;
    }
  }

  List<String> objectsByModule(String moduleCode) {
    final list = themes[moduleCode];
    if (list == null || list.isEmpty) return const ["Deutsch", "Wasser", "Termin", "Arbeit", "Hilfe"];
    return list;
  }

  String trOf(String deToken) => trMap[deToken] ?? deToken;

  List<Map<String, dynamic>> examplesByTheme(String moduleCode) {
    return sentenceExamples.where((e) => e["theme"] == moduleCode).toList();
  }
}
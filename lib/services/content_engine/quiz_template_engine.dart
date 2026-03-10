import 'dart:math';

import '../../models/generated_content_models.dart';
import '../data/a1_data_service.dart';

class QuizTemplateEngine {
  QuizTemplateEngine._();
  static final QuizTemplateEngine I = QuizTemplateEngine._();

  final Random _rng = Random();

  // fallback
  List<String> _fallbackObjects(String moduleCode) {
    switch (moduleCode) {
      case "modul1":
        return ["Deutsch", "Türkisch", "Wasser", "Kaffee"];
      case "modul2":
        return ["Termin", "Hilfe", "Zeit", "Pause"];
      case "modul4":
        return ["Brot", "Milch", "Wasser", "Apfel"];
      case "modul5":
        return ["Arzt", "Apotheke", "Problem", "Tee"];
      default:
        return ["Deutsch", "Wasser", "Termin", "Arbeit"];
    }
  }

  List<String> _objectsByModule(String moduleCode) {
    if (A1DataService.I.isLoaded) return A1DataService.I.objectsByModule(moduleCode);
    return _fallbackObjects(moduleCode);
  }

  String _trOf(String token) {
    if (A1DataService.I.isLoaded) return A1DataService.I.trOf(token);
    // fallback minimal
    switch (token) {
      case "Deutsch":
        return "Almanca";
      case "Türkisch":
        return "Türkçe";
      case "Wasser":
        return "Su";
      case "Kaffee":
        return "Kahve";
      case "Termin":
        return "Randevu";
      case "Hilfe":
        return "Yardım";
      case "Zeit":
        return "Zaman";
      case "Pause":
        return "Mola";
      case "Brot":
        return "Ekmek";
      case "Milch":
        return "Süt";
      case "Apfel":
        return "Elma";
      case "Arbeit":
        return "İş";
      default:
        return token;
    }
  }

  String _pick(List<String> xs) => xs[_rng.nextInt(xs.length)];

  List<ListeningItem> generateListeningSet({
    required String moduleCode,
    int count = 10,
  }) {
    final res = <ListeningItem>[];
    final objs = _objectsByModule(moduleCode);

    for (int i = 0; i < count; i++) {
      res.add(_one(moduleCode, objs));
    }
    return res;
  }

  ListeningItem _one(String moduleCode, List<String> objs) {
    final subj = _pick(["Ich", "Du", "Wir"]);
    final verb = (subj == "Du") ? "lernst" : (subj == "Wir") ? "lernen" : "lerne";

    final obj = _pick(objs);

    // ✅ DE SADECE DE
    final de = "$subj $verb $obj.";

    // ✅ TR soru: daha “anlam” odaklı
    final questionTr = "Cümlede öğrenilen şey ne?";

    final correctTr = _trOf(obj);

    final wrongs = <String>{};
    while (wrongs.length < 2) {
      final w = _trOf(_pick(objs));
      if (w != correctTr) wrongs.add(w);
    }

    final options = [correctTr, ...wrongs.toList()]..shuffle(_rng);
    final ci = options.indexOf(correctTr);

    return ListeningItem(
      de: de,
      questionTr: questionTr,
      optionsTr: options,
      correctIndex: ci,
    );
  }
}
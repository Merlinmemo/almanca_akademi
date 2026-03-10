import 'dart:math';
import '../../models/generated_content_models.dart';

/// SentenceEngine
/// - MicroSentenceScreen buradan 5 soru üretir.
/// - Modüle göre içerik farklılaşır.
/// - Level ilerledikçe seçenekler zorlaşır (şimdilik level=1 stabil).
class SentenceEngine {
  SentenceEngine._();
  static final SentenceEngine I = SentenceEngine._();

  List<SentencePattern> generatePatternSet({
    required String moduleCode,
    required int level,
    required int count,
  }) {
    final r = Random();

    final bank = _buildBank(moduleCode, level);
    if (bank.isEmpty) return [];

    // benzersiz seçmeye çalış, yetmezse döndür
    final out = <SentencePattern>[];
    final used = <int>{};

    while (out.length < count) {
      final idx = r.nextInt(bank.length);
      if (bank.length >= count && used.contains(idx)) continue;
      used.add(idx);

      // seçenekleri karıştırıp correctIndex’i düzelt
      out.add(_shuffleOptionsKeepAnswer(bank[idx], r));
      if (used.length >= bank.length) break;
    }

    // count kadar dolmadıysa tekrar döndürerek tamamla
    while (out.length < count && bank.isNotEmpty) {
      out.add(_shuffleOptionsKeepAnswer(bank[r.nextInt(bank.length)], r));
    }

    return out;
  }

  // ------------------------------------------------------------
  // BANK
  // ------------------------------------------------------------

  List<SentencePattern> _buildBank(String moduleCode, int level) {
    // Modüle göre tema seç
    final theme = _themeFor(moduleCode);

    // level=1: fiil 2. sırada + basit zaman/yer/kişi
    // “microRuleTitle / microRuleText” Micro ekran üstünde gösteriliyor.
    final ruleTitle = "Kural";
    final ruleText = "Fiil her zaman 2. sırada (V2). İlk sıraya ne gelirse gelsin fiil 2. sıraya oturur.";

    final List<_Row> rows = [];

    if (theme == _Theme.intro) {
      rows.addAll([
        _Row("Ben ... (ad)", "Ich heiße Mehmet.", "Benim adım Mehmet.", ["Ich", "heiße", "Mehmet"], correct: 1),
        _Row("Ben ... (nereli)", "Ich komme aus der Türkei.", "Ben Türkiye'den geliyorum.", ["Ich", "komme", "aus der Türkei"], correct: 1),
        _Row("Ben ... (meslek)", "Ich arbeite als Elektriker.", "Elektrikçi olarak çalışıyorum.", ["Ich", "arbeite", "als Elektriker"], correct: 1),
        _Row("Ben ... (şehir)", "Ich wohne in Köln.", "Köln'de yaşıyorum.", ["Ich", "wohne", "in Köln"], correct: 1),
      ]);
    } else if (theme == _Theme.job) {
      rows.addAll([
        _Row("İşte: bugün ...", "Heute arbeite ich in der Werkstatt.", "Bugün atölyede çalışıyorum.", ["Heute", "arbeite", "ich in der Werkstatt"], correct: 1),
        _Row("İşte: sonra ...", "Danach prüfe ich die Sicherung.", "Sonra sigortayı kontrol ediyorum.", ["Danach", "prüfe", "ich die Sicherung"], correct: 1),
        _Row("İşte: şimdi ...", "Jetzt mache ich die Anlage aus.", "Şimdi sistemi kapatıyorum.", ["Jetzt", "mache", "ich die Anlage aus"], correct: 1),
        _Row("İşte: dikkat ...", "Bitte schalte ich den Strom ab.", "Lütfen elektriği kapatıyorum.", ["Bitte", "schalte", "ich den Strom ab"], correct: 1),
      ]);
    } else if (theme == _Theme.daily) {
      rows.addAll([
        _Row("Günlük: sabah ...", "Morgens trinke ich Tee.", "Sabahları çay içerim.", ["Morgens", "trinke", "ich Tee"], correct: 1),
        _Row("Günlük: akşam ...", "Abends gehe ich nach Hause.", "Akşamları eve giderim.", ["Abends", "gehe", "ich nach Hause"], correct: 1),
        _Row("Günlük: sonra ...", "Später telefoniere ich mit dir.", "Sonra seninle telefon konuşması yaparım.", ["Später", "telefoniere", "ich mit dir"], correct: 1),
        _Row("Günlük: bugün ...", "Heute lerne ich Deutsch.", "Bugün Almanca öğreniyorum.", ["Heute", "lerne", "ich Deutsch"], correct: 1),
      ]);
    } else if (theme == _Theme.travel) {
      rows.addAll([
        _Row("Şehir: şimdi ...", "Jetzt bin ich am Bahnhof.", "Şimdi istasyondayım.", ["Jetzt", "bin", "ich am Bahnhof"], correct: 1),
        _Row("Şehir: sonra ...", "Dann fahre ich mit der Bahn.", "Sonra trenle giderim.", ["Dann", "fahre", "ich mit der Bahn"], correct: 1),
        _Row("Şehir: bugün ...", "Heute gehe ich zum Amt.", "Bugün resmi daireye gidiyorum.", ["Heute", "gehe", "ich zum Amt"], correct: 1),
        _Row("Şehir: lütfen ...", "Bitte helfen Sie mir.", "Lütfen bana yardım edin.", ["Bitte", "helfen", "Sie mir"], correct: 1),
      ]);
    }

    // Her satırı 4 seçenekli pattern’e çevir
    final patterns = <SentencePattern>[];
    for (final row in rows) {
      patterns.add(_toPattern(row, ruleTitle, ruleText, level));
    }

    // level artarsa: seçeneklerde benzer ama yanlış düzenler ekle
    // şimdilik level=1 stabil.

    return patterns;
  }

  _Theme _themeFor(String moduleCode) {
    // modül kodları projende modul1, modul2 ... gibi
    switch (moduleCode) {
      case "modul1":
        return _Theme.intro;
      case "modul2":
        return _Theme.daily;
      case "modul3":
        return _Theme.travel;
      default:
        return _Theme.job;
    }
  }

  SentencePattern _toPattern(_Row row, String ruleTitle, String ruleText, int level) {
    // doğru dizilim: [A, VERB, B...]
    final correct = row.correctTokens.join(" ");

    // yanlış seçenekler: fiili sona at, fiili 1. sıraya çek, özneyi bozar
    final wrong1 = _moveVerbToEnd(row.correctTokens).join(" ");
    final wrong2 = _moveVerbToStart(row.correctTokens).join(" ");
    final wrong3 = _swapFirstTwo(row.correctTokens).join(" ");

    final options = <String>[
      correct,
      wrong1,
      wrong2,
      wrong3,
    ];

    return SentencePattern(
      title: row.title,
      exampleDe: row.exampleDe,
      exampleTr: row.exampleTr,
      practiceOptions: options,
      correctIndex: 0,
      microRuleTitle: ruleTitle,
      microRuleText: ruleText,
    );
  }

  // ------------------------------------------------------------
  // OPTION SHUFFLE (correctIndex korunur)
  // ------------------------------------------------------------

  SentencePattern _shuffleOptionsKeepAnswer(SentencePattern p, Random r) {
    final indexed = <MapEntry<int, String>>[];
    for (int i = 0; i < p.practiceOptions.length; i++) {
      indexed.add(MapEntry(i, p.practiceOptions[i]));
    }
    indexed.shuffle(r);

    final newOptions = indexed.map((e) => e.value).toList();
    final newCorrect = indexed.indexWhere((e) => e.key == p.correctIndex);

    return SentencePattern(
      title: p.title,
      exampleDe: p.exampleDe,
      exampleTr: p.exampleTr,
      practiceOptions: newOptions,
      correctIndex: newCorrect < 0 ? 0 : newCorrect,
      microRuleTitle: p.microRuleTitle,
      microRuleText: p.microRuleText,
    );
  }

  // ------------------------------------------------------------
  // TOKEN HELPERS (basit ama etkili yanlışlar)
  // ------------------------------------------------------------

  List<String> _moveVerbToEnd(List<String> t) {
    if (t.length < 3) return t;
    final out = List<String>.from(t);
    // 2. token verb varsayımı
    final verb = out.removeAt(1);
    out.add(verb);
    return out;
  }

  List<String> _moveVerbToStart(List<String> t) {
    if (t.length < 3) return t;
    final out = List<String>.from(t);
    final verb = out.removeAt(1);
    out.insert(0, verb);
    return out;
  }

  List<String> _swapFirstTwo(List<String> t) {
    if (t.length < 2) return t;
    final out = List<String>.from(t);
    final a = out[0];
    out[0] = out[1];
    out[1] = a;
    return out;
  }

  int _stableSeed(String moduleCode, int level) {
    // stabil seed => aynı modül+level aynı bankı üretir (testte tutarlılık)
    int h = 17;
    for (final c in moduleCode.codeUnits) {
      h = 37 * h + c;
    }
    h = 37 * h + level;
    return h & 0x7fffffff;
  }
}

// ------------------------------------------------------------
// INTERNAL TYPES
// ------------------------------------------------------------

enum _Theme { intro, daily, travel, job }

class _Row {
  final String title;
  final String exampleDe;
  final String exampleTr;
  final List<String> correctTokens;
  final int correct; // şimdilik kullanılmıyor ama ileride esneklik için dursun

  _Row(this.title, this.exampleDe, this.exampleTr, this.correctTokens, {required this.correct});
}